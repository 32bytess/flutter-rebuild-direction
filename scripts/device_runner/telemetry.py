"""Split a session's flat telemetry CSV into one CSV per measured execution.

`devices/lib/measure.sh` runs a watchdog that samples battery level/temperature and SoC
temperature every SAMPLE_SECS (5s) for the entire runner session and appends to

    dataset/<group>/<device>/telemetry/telemetry-<session>.csv

One file covers every execution of the group (~1100 rows for 135 executions), so a buildSpan
median in performance.jsonl can only be joined to a session-wide thermal average. This module
derives, next to that file and without modifying it:

    dataset/<group>/<device>/telemetry/<session>/<role>/e<k>.csv   the rows of ONE execution
    dataset/<group>/<device>/telemetry/<session>/index.jsonl       one summary row per execution
    dataset/<group>/<device>/telemetry/<session>/_unassigned.csv   rows inside no execution

Run windows
-----------
Both the telemetry `epoch` column and the capture-log timestamps are stamped by the HOST, so
no clock-skew correction is needed. Current captures carry `preflight_started=` and `started=`
in their header, which bound the execution exactly (`window_source="header"`).

Legacy captures — all captures from the earlier pilot phone and the first redmi9t session — carry only the end
stamp `ts=`, so the window is reconstructed (`window_source="estimated"`):

  * measure_start = ts - device_span, where device_span is the last minus the first rebuild
    `timestamp` in e<k>.jsonl. Those stamps come off the phone, but a *duration* is immune to
    host<->device skew and `ts` anchors it on the host clock.
  * setup_start = the previous execution's end, chronologically (that whole gap is this
    execution's thermal cooldown + assemble). For the first execution of a session there is no
    predecessor and the CSV reaches back through phase 1, so its setup is capped at the median
    setup duration of the rest of the session rather than swallowing the extract phase.

Estimated windows are an approximation and are labelled as such in index.jsonl. `--check`
scores them against ground truth the runner recorded independently: each header's
`battery_pct`/`soc_temp_millic` is a snapshot taken at the END of preflight, i.e. right at
measure_start, so comparing it to the telemetry sample nearest measure_start says whether the
reconstruction landed in the right place.

Usage
-----
    python -m scripts.device_runner telemetry --group 01 --session 20260717-091807
    python -m scripts.device_runner telemetry --backfill --device <device>
    python -m scripts.device_runner telemetry --backfill --device <device> --check
    # one session whose CSV was split in two by a resume under the old code:
    python -m scripts.device_runner telemetry --group 01 --session 20260728-061535 \
        --device redmi9t --extra-csv telemetry/telemetry-20260728-061535.csv --merge-extra
"""
from __future__ import annotations

import argparse
import csv
import json
import logging
import os
import statistics
from datetime import datetime
from pathlib import Path

from . import capture, config

# Non-"run" rows the watchdog writes when it intervenes; worth surfacing per execution because
# a thermal pause or a battery-floor stop inside a window invalidates that measurement.
_NOTABLE_EVENTS = {"thermal_pause", "thermal_resume", "battery_floor_stop", "end"}

# Fallback measured duration when a legacy capture has no usable e<k>.jsonl to size it from.
_FALLBACK_MEASURE_S = 60.0


# ----------------------------------------------------------------------------- session CSV
def read_session_csv(paths: list[Path]) -> tuple[list[str], list[dict]]:
    """Concatenate session CSVs, de-dupe, sort by epoch ascending.

    Multiple paths exist because a resume under the pre-fix measure.sh opened a SECOND file
    for the same session instead of appending, leaving one session's telemetry split in two;
    overlapping halves produce byte-identical rows that must collapse to one.

    The key is (epoch, event), not epoch alone: the watchdog emits an extra tagged row when it
    intervenes (`thermal_pause`, `battery_floor_stop`, the closing `end`), and that row can
    land in the same second as a routine `run` sample. Keying on epoch would drop exactly the
    rows that record something happening.
    """
    fieldnames: list[str] = []
    seen: dict[tuple[int, str], dict] = {}
    for p in paths:
        with p.open(newline="", encoding="utf-8") as fh:
            reader = csv.DictReader(fh)
            if reader.fieldnames:
                fieldnames = fieldnames or list(reader.fieldnames)
            for row in reader:
                try:
                    epoch = int(row["epoch"])
                except (KeyError, TypeError, ValueError):
                    continue
                row["epoch"] = epoch
                seen.setdefault((epoch, row.get("event", "")), row)
    return fieldnames, [seen[k] for k in sorted(seen)]


def _num(row: dict, key: str) -> float | None:
    v = (row.get(key) or "").strip()
    try:
        return float(v)
    except ValueError:
        return None


# ----------------------------------------------------------------------------- run windows
class Window:
    """One execution's slice of the session timeline, on the host clock."""

    def __init__(self, header: capture.Header, log_path: Path):
        self.h = header
        self.log_path = log_path
        self.setup_start: float = 0.0
        self.measure_start: float = 0.0
        self.end: float = header.ended.timestamp() if header.ended else 0.0
        self.source = "header" if (header.started and header.preflight_started) else "estimated"
        self.rows: list[dict] = []


def _device_span_s(vm_path: Path) -> float | None:
    """Duration of the rebuild stream in e<k>.jsonl (device clock, so duration only)."""
    if not vm_path.exists():
        return None
    stamps: list[datetime] = []
    for line in vm_path.read_text(errors="replace").splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            ts = json.loads(line).get("timestamp")
        except json.JSONDecodeError:
            continue
        if ts:
            try:
                stamps.append(datetime.fromisoformat(ts))
            except ValueError:
                pass
    if len(stamps) < 2:
        return None
    return (max(stamps) - min(stamps)).total_seconds()


def build_windows(group: str, session: str, session_start: float | None) -> list[Window]:
    """Ordered, non-overlapping windows for every capture in a session dir."""
    root = config.raw_dir(group) / session
    windows: list[Window] = []
    for log_path in sorted(root.rglob("e*.log")):
        h = capture.read_header(log_path)
        if h is None or h.ended is None:
            logging.warning("  no usable header/end stamp: %s", log_path)
            continue
        windows.append(Window(h, log_path))
    windows.sort(key=lambda w: w.end)

    # Pass 1: measure_start — exact from the header, else end minus the on-device rebuild span.
    spans: list[float] = []
    for w in windows:
        if w.h.started:
            w.measure_start = w.h.started.timestamp()
            spans.append(w.end - w.measure_start)
            continue
        span = _device_span_s(w.log_path.with_suffix(".jsonl"))
        if span is not None:
            spans.append(span)
        w.measure_start = w.end - (span if span is not None else 0.0)
    median_span = statistics.median(spans) if spans else _FALLBACK_MEASURE_S
    for w in windows:
        if not w.h.started and w.measure_start == w.end:  # no jsonl to size it from
            w.measure_start = w.end - median_span

    # Pass 2: setup_start — exact from the header, else the gap since the previous execution.
    setups: list[float] = []
    prev_end: float | None = None
    for w in windows:
        if w.h.preflight_started:
            w.setup_start = w.h.preflight_started.timestamp()
        elif prev_end is not None:
            w.setup_start = prev_end
        else:
            w.setup_start = w.measure_start  # first execution; capped below
        setups.append(w.measure_start - w.setup_start)
        prev_end = w.end
    if windows and not windows[0].h.preflight_started:
        rest = [s for s in setups[1:] if s > 0]
        pad = statistics.median(rest) if rest else 0.0
        floor = windows[0].measure_start - pad
        windows[0].setup_start = max(floor, session_start) if session_start else floor

    # Clamp: no window may reach back past the previous execution's end. This matters for
    # crashed captures — they have no e<k>.jsonl to size the measured window from, so they
    # inherit the median duration, which for a run that died in 3s overruns its predecessor.
    # Unclamped, those windows overlap and (since a row is assigned to at most one) starve the
    # later ones of every sample. measure_start is clamped as well as setup_start, so a short
    # failure ends up with a short honest window rather than a plausible-looking wrong one.
    prev_end = None
    for w in windows:
        if prev_end is not None:
            w.measure_start = max(w.measure_start, prev_end)
            w.setup_start = max(w.setup_start, prev_end)
        w.setup_start = min(w.setup_start, w.measure_start)
        w.measure_start = min(w.measure_start, w.end)
        prev_end = w.end
    return windows


# ----------------------------------------------------------------------------- assignment
def assign_rows(rows: list[dict], windows: list[Window]) -> list[dict]:
    """Attach each telemetry row to at most one window; return the leftovers.

    At-most-one is what makes `sum(per-run rows) + unassigned == session rows` hold exactly,
    so a mis-sized window shows up as an accounting failure instead of double-counted data.
    """
    unassigned: list[dict] = []
    i = 0
    for row in rows:  # rows and windows are both sorted ascending
        epoch = row["epoch"]
        while i < len(windows) and windows[i].end < epoch:
            i += 1
        if i < len(windows) and windows[i].setup_start <= epoch <= windows[i].end:
            windows[i].rows.append(row)
        else:
            unassigned.append(row)
    return unassigned


# ----------------------------------------------------------------------------- output
def _summarise(w: Window, group: str, session: str, rel_csv: str | None) -> dict:
    soc = [v for v in (_num(r, "soc_temp_c") for r in w.rows) if v is not None]
    batt = [v for v in (_num(r, "batt_level") for r in w.rows) if v is not None]
    btemp = [v for v in (_num(r, "batt_temp_c") for r in w.rows) if v is not None]
    events = sorted({r.get("event", "") for r in w.rows} & _NOTABLE_EVENTS)
    n_measure = sum(1 for r in w.rows if r["epoch"] >= w.measure_start)

    rec = {
        "sample_id": w.h.sample_id,
        "group": group,
        "role": w.h.role,
        "exec_index": w.h.exec_index,
        "session": session,
        "device": config.device_slug(),
        "window_source": w.source,
        "setup_start_epoch": w.setup_start,
        "measure_start_epoch": w.measure_start,
        "end_epoch": w.end,
        "setup_start_iso": datetime.fromtimestamp(w.setup_start).isoformat(),
        "measure_start_iso": datetime.fromtimestamp(w.measure_start).isoformat(),
        "end_iso": datetime.fromtimestamp(w.end).isoformat(),
        "setup_duration_s": round(w.measure_start - w.setup_start, 3),
        "measure_duration_s": round(w.end - w.measure_start, 3),
        "n_samples": len(w.rows),
        "n_measure_samples": n_measure,
        "batt_start": batt[0] if batt else None,
        "batt_end": batt[-1] if batt else None,
        "batt_temp_max": max(btemp) if btemp else None,
        "soc_min": min(soc) if soc else None,
        "soc_mean": round(statistics.fmean(soc), 3) if soc else None,
        "soc_max": max(soc) if soc else None,
        "events": events,
        "ok": w.h.ok,
        "perf_lines": w.h.perf_lines,
        "vm_events": w.h.vm_events,
        "complete": w.h.complete,
        "telemetry_csv": rel_csv,
    }
    # Ground truth the runner recorded independently of the watchdog: preflight() snapshots
    # battery/SoC right before the measured window opens. Comparing it to the telemetry sample
    # nearest measure_start is how an estimated window is scored (see --check).
    rec["header_battery_pct"] = w.h.battery_pct
    rec["header_soc_temp_c"] = (
        round(w.h.soc_temp_millic / 1000, 1) if w.h.soc_temp_millic is not None else None
    )
    near = min(w.rows, key=lambda r: abs(r["epoch"] - w.measure_start), default=None)
    if near is not None:
        b, s = _num(near, "batt_level"), _num(near, "soc_temp_c")
        rec["check_batt_delta"] = (
            abs(b - w.h.battery_pct) if b is not None and w.h.battery_pct is not None else None
        )
        rec["check_soc_delta_c"] = (
            round(abs(s - rec["header_soc_temp_c"]), 2)
            if s is not None and rec["header_soc_temp_c"] is not None
            else None
        )
    else:
        rec["check_batt_delta"] = rec["check_soc_delta_c"] = None
    return rec


def _write_run_csv(path: Path, fieldnames: list[str], w: Window) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    out_fields = list(fieldnames) + ["run_elapsed_s", "phase"]
    with path.open("w", newline="", encoding="utf-8") as fh:
        writer = csv.DictWriter(fh, fieldnames=out_fields, extrasaction="ignore")
        writer.writeheader()
        for r in w.rows:
            row = dict(r)
            row["run_elapsed_s"] = round(r["epoch"] - w.setup_start, 3)
            row["phase"] = "measure" if r["epoch"] >= w.measure_start else "setup"
            writer.writerow(row)


def _write_plain_csv(path: Path, fieldnames: list[str], rows: list[dict]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as fh:
        writer = csv.DictWriter(fh, fieldnames=fieldnames, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(rows)


# ----------------------------------------------------------------------------- driver
def split_session(
    group: str, session: str, extra_csv: list[Path] | None = None, merge_extra: bool = False
) -> dict | None:
    """Split one (group, session). Returns a per-session summary, or None if nothing to do."""
    sess_csv = config.session_telemetry_csv(group, session)
    sources = [p for p in [sess_csv, *(extra_csv or [])] if p.exists()]
    windows_root = config.raw_dir(group) / session
    if not windows_root.exists():
        return None
    if not sources:
        n_logs = len(list(windows_root.rglob("e*.log")))
        logging.warning("  %s/%s: no telemetry CSV — %d capture(s) unattributed", group, session, n_logs)
        return {"group": group, "session": session, "missing_csv": True, "n_executions": n_logs,
                "n_windows": 0, "n_rows": 0, "n_assigned": 0, "n_unassigned": 0, "n_empty": n_logs}

    fieldnames, rows = read_session_csv(sources)
    if merge_extra and len(sources) > 1:
        # Fold the split halves back into the canonical session CSV. The extra source files are
        # left untouched, so this stays reversible.
        _write_plain_csv(sess_csv, fieldnames, rows)
        logging.info("  merged %d source CSVs -> %s", len(sources), sess_csv)

    session_start = rows[0]["epoch"] if rows else None
    windows = build_windows(group, session, session_start)
    if not windows:
        logging.warning("  %s/%s: no parseable captures", group, session)
        return None

    unassigned = assign_rows(rows, windows)
    out_dir = config.split_telemetry_dir(group, session)
    index: list[dict] = []
    for w in windows:
        rel = None
        if w.rows:
            path = config.run_telemetry_csv(group, session, w.h.role, w.h.exec_index)
            _write_run_csv(path, fieldnames, w)
            rel = path.relative_to(config.OUT_DIR).as_posix()
        index.append(_summarise(w, group, session, rel))

    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / "index.jsonl").write_text(
        "".join(json.dumps(r) + "\n" for r in index), encoding="utf-8"
    )
    _write_plain_csv(out_dir / "_unassigned.csv", fieldnames, unassigned)

    n_assigned = sum(len(w.rows) for w in windows)
    if n_assigned + len(unassigned) != len(rows):
        raise SystemExit(
            f"conservation failed for {group}/{session}: {n_assigned} assigned + "
            f"{len(unassigned)} unassigned != {len(rows)} session rows"
        )
    n_empty = sum(1 for w in windows if not w.rows)
    logging.info(
        "  %s/%s: %d executions, %d/%d rows assigned, %d unassigned%s",
        group, session, len(windows), n_assigned, len(rows), len(unassigned),
        f", {n_empty} with NO telemetry" if n_empty else "",
    )
    return {
        "group": group, "session": session, "missing_csv": False,
        "n_executions": len(windows), "n_windows": len(windows), "n_rows": len(rows),
        "n_assigned": n_assigned, "n_unassigned": len(unassigned), "n_empty": n_empty,
        "index": index,
    }


def _sessions_of(group: str) -> list[str]:
    root = config.raw_dir(group)
    return sorted(d.name for d in root.glob("*") if d.is_dir()) if root.exists() else []


def _groups() -> list[str]:
    return sorted(d.name for d in config.OUT_DIR.glob("*") if d.is_dir() and d.name.isdigit())


def _report_check(index: list[dict]) -> None:
    """Score reconstructed windows against the runner's independent preflight snapshot.

    Read the three numbers in this order:

    * measure_duration spread is the primary alignment evidence. Every execution runs the same
      fixed N_REBUILDS, so correctly-sized windows are near-identical in length; a wide spread
      means the reconstruction is drifting.
    * battery delta is a clean cross-sensor check — both sides read the same battery level.
    * SoC delta carries a SENSOR BIAS and is only a sanity check: the capture header records
      `_hottest_zone_millic()` (hottest thermal zone) while the watchdog samples the pinned
      THERMAL_ZONE, so a stable non-zero median is expected and harmless. Watch the spread,
      not the magnitude.
    """
    for src in ("header", "estimated"):
        rows = [r for r in index if r["window_source"] == src]
        if not rows:
            continue
        batt = [r["check_batt_delta"] for r in rows if r["check_batt_delta"] is not None]
        soc = [r["check_soc_delta_c"] for r in rows if r["check_soc_delta_c"] is not None]
        # Only COMPLETE captures ran the full N_REBUILDS, so only they should share a duration.
        # Crashed ones legitimately vary from a fraction of a second upward and would swamp the
        # spread; they are counted separately instead of being averaged in.
        done = [r for r in rows if r["complete"]]
        dur = [r["measure_duration_s"] for r in done]
        print(f"\nwindow_source={src}: {len(rows)} executions "
              f"({len(done)} complete, {len(rows) - len(done)} failed/short)")
        if dur:
            print(f"  measure_duration: median {statistics.median(dur):.1f}s  "
                  f"range {min(dur):.1f}-{max(dur):.1f}s  sd "
                  f"{statistics.pstdev(dur) if len(dur) > 1 else 0.0:.2f}s   "
                  f"<- alignment signal (complete captures only)")
            n_no_tel = sum(1 for r in done if r["n_samples"] == 0)
            if n_no_tel:
                print(f"  WARNING: {n_no_tel} COMPLETE capture(s) got no telemetry rows")
        if batt:
            print(f"  battery |delta| : mean {statistics.fmean(batt):.2f} %  (max {max(batt):.0f})")
        if soc:
            print(f"  SoC |delta|     : mean {statistics.fmean(soc):.2f} °C (max {max(soc):.1f}) "
                  f"— includes a hottest-zone vs pinned-zone sensor bias")
        if not batt and not soc:
            print("  no overlapping telemetry to score against")


def main() -> None:
    ap = argparse.ArgumentParser(description="Split session telemetry into per-execution CSVs.")
    ap.add_argument("--group", help="sample group (e.g. 01); default: all groups")
    ap.add_argument("--session", help="raw session name; default: all sessions of the group")
    ap.add_argument("--device", help="device slug override (default: $BENCH_DEVICE_ID)")
    ap.add_argument("--extra-csv", action="append", default=[],
                    help="additional session CSV to merge in (repeatable), relative to the repo")
    ap.add_argument("--merge-extra", action="store_true",
                    help="write the merged rows back to the canonical session CSV")
    ap.add_argument("--backfill", action="store_true",
                    help="walk every group and session that has captures")
    ap.add_argument("--check", action="store_true",
                    help="score windows against the preflight snapshot in each capture header")
    args = ap.parse_args()
    logging.basicConfig(level=logging.INFO, format="%(levelname)s - %(message)s")

    if args.device:
        os.environ["BENCH_DEVICE_ID"] = args.device
    extra = [Path(p) if Path(p).is_absolute() else config.PROJECT_ROOT / p for p in args.extra_csv]

    groups = [args.group] if args.group else _groups()
    if not args.backfill and not args.group:
        ap.error("pass --group, or --backfill to walk every group")

    logging.info("telemetry split: device=%s groups=%d", config.device_slug(), len(groups))
    summaries: list[dict] = []
    for g in groups:
        for s in ([args.session] if args.session else _sessions_of(g)):
            r = split_session(g, s, extra, args.merge_extra)
            if r:
                summaries.append(r)

    if not summaries:
        raise SystemExit("nothing split — no matching captures found")

    all_index = [r for s in summaries for r in s.get("index", [])]
    missing = [s for s in summaries if s["missing_csv"]]
    empty = sum(s["n_empty"] for s in summaries)
    print(f"\n{len(summaries)} session(s), {sum(s['n_executions'] for s in summaries)} executions")
    print(f"  rows assigned  : {sum(s['n_assigned'] for s in summaries)}")
    print(f"  rows unassigned: {sum(s['n_unassigned'] for s in summaries)} (setup gaps, phase 1, cooldowns)")
    est = sum(1 for r in all_index if r["window_source"] == "estimated")
    print(f"  windows        : {len(all_index) - est} exact (header), {est} estimated")
    if empty:
        print(f"  executions with NO telemetry rows: {empty}")
    for s in missing:
        print(f"  MISSING session CSV: {s['group']}/{s['session']} ({s['n_executions']} captures)")
    if args.check:
        _report_check(all_index)
