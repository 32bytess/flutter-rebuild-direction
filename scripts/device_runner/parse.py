"""Parse raw per-execution captures into the hierarchical dataset tables.

raw/<session>/<group>/<role>/e<k>.jsonl  ->  rebuilds.jsonl (inner, one row per rebuild)
                            (+ e<k>.log) ->  performance.jsonl (outer, one row per execution)

Readings come from the VM-service capture `spm run` writes; the stdout `[SPM:perf]` lines
are the fallback for sessions predating it, or when the VM stream came up short. The chosen
path is recorded per execution in `source`.

Aggregation follows the protocol: drop timeout readings, discard the first
WARMUP_DISCARD rebuilds, take the MEDIAN of the rest = one execution-level value.
Statistics later run on the 5 medians, never the pooled raw readings — but every raw
reading is retained here (required for hierarchical bootstrap / warm-up re-tuning / gates).

Every execution with a readable header gets a row, including the ones `flutter drive`
reported as failed: `status` carries the header's `ok=` verbatim and a hard failure that
produced no readings at all still lands as a row with `median_us: null`. Parsing RECORDS
run status, it never acts on it — `ok=False perf_lines=30 vm_events=30` (a full profiler
capture behind a non-zero driver exit) is not obviously bad data, so deciding which
executions to drop is an analysis call made downstream, where it can be counted and
justified. Consumers doing arithmetic on `median_us` must filter `status == "ok"` first.

    python -m scripts.device_runner parse [--warmup 10]
"""

import argparse
import json
import logging
import re
import statistics
from pathlib import Path

from . import capture, config

# [SPM:perf] <instanceId>  buildSpan: <int>µs   (0µs "(timeout)" rows are profiler misses)
_LINE = re.compile(r"\[SPM:perf\]\s+(?P<id>\S+)\s+buildSpan:\s+(?P<us>\d+)µs(?P<timeout>\s+\(timeout\))?")


def _write_jsonl(records: list[dict], path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        for r in records:
            f.write(json.dumps(r, ensure_ascii=False) + "\n")


def _readings_from_vm(path: Path) -> list[tuple[int, str | None]]:
    """(buildSpan µs, instanceId) per event from the VM-service capture written by `spm run`.

    This is the structured stream the profiler posts over `ext.spm.profiler`, not a reprint
    of it. Preferred over stdout because stdout can truncate on process teardown without any
    error surfacing — the debugPrint line and the posted event come from the same call site
    (`profiler_data_source_impl.dart:178-179`), so identical values, different reliability.
    """
    out: list[tuple[int, str | None]] = []
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            e = json.loads(line)
        except json.JSONDecodeError:
            continue
        us = e.get("buildSpan")
        if isinstance(us, int):
            out.append((us, e.get("instanceId")))
    return out


def _readings_from_stdout(text: str) -> list[tuple[int, str | None]]:
    """Fallback: the `[SPM:perf]` debugPrint lines scraped out of the flutter-drive capture."""
    return [(int(m["us"]), m["id"]) for m in _LINE.finditer(text)]


def _execution_row(sample_id, group, role, instance_id, exec_index, status, session,
                   *, median_us, rebuilds, used, source) -> dict:
    """One `performance.jsonl` row. `median_us` is None when nothing was captured."""
    return {
        "sample_id": sample_id,
        "group": group,
        "role": role,
        "instance_id": instance_id,
        "exec_index": exec_index,
        # "ok" | "failed", straight off the capture header's `ok=` — whether `flutter drive`
        # exited cleanly, NOT a judgement about the readings (a failed execution routinely
        # carries a full 30-rebuild capture). Filter on this before averaging anything.
        "status": status,
        "session": session,  # raw/<session> this row came from, for provenance
        "median_us": median_us,
        "n_raw": len(rebuilds),
        "n_used": len(used),
        "warmup_dropped": len(rebuilds) - len(used),
        "readings_us": [r["buildspan_us"] for r in rebuilds],
        "source": source,  # "vm" (structured stream) or "stdout" (scraped fallback)
    }


def parse_capture(path: Path, warmup: int, session: str = "") -> tuple[list[dict], dict | None]:
    """Return (per-rebuild rows, per-execution row) for one raw capture.

    The header is parsed by `capture.parse_header` — the same reader the runner, `status`
    and `telemetry` use — so `ok=` is read off the one definition that handles both header
    generations in the corpus, rather than a second regex that has to be kept in step.
    """
    text = path.read_text(encoding="utf-8", errors="replace")
    header = capture.parse_header(text)
    if header is None:
        logging.warning("no header in %s — skipping", path.name)
        return [], None
    sample_id = header.sample_id
    exec_index = header.exec_index
    group, role = header.group, header.role
    status = "ok" if header.ok else "failed"

    # VM capture leads; stdout backs it up. Sessions recorded before `spm run -o` was wired
    # up have no sidecar and take the stdout path, reproducing their original rows exactly.
    vm_path = path.with_suffix(".jsonl")
    readings = _readings_from_vm(vm_path) if vm_path.exists() else []
    source = "vm"
    if not readings:
        readings = _readings_from_stdout(text)
        source = "stdout"
    elif len(readings) < len(_readings_from_stdout(text)):
        # Never take the shorter stream: a partial VM capture (connect race, early exit)
        # must not silently discard readings stdout did manage to carry.
        readings = _readings_from_stdout(text)
        source = "stdout"
        logging.warning("%s: VM capture shorter than stdout — using stdout", path.name)

    rebuilds: list[dict] = []
    instance_id = None
    idx = 0
    for us, ev_id in readings:
        if us == 0:  # profiler miss (stdout marks these "(timeout)"), not a measurement
            continue
        instance_id = ev_id or instance_id
        rebuilds.append(
            {
                "sample_id": sample_id,
                "group": group,
                "role": role,
                "instance_id": instance_id,
                "exec_index": exec_index,
                "rebuild_index": idx,
                "buildspan_us": us,
                "is_warmup": idx < warmup,
            }
        )
        idx += 1

    if not rebuilds:
        # An execution that crashed before the profiler emitted anything. It still gets a
        # row — dropping it here is what used to make a hard failure indistinguishable from
        # an execution that was never scheduled. There are no rebuild rows to write because
        # there is genuinely nothing to record at that level.
        logging.warning("no valid readings in %s", path.name)
        return [], _execution_row(
            sample_id, group, role, None, exec_index, status, session,
            median_us=None, rebuilds=[], used=[], source=source,
        )
    if len(rebuilds) < config.N_REBUILDS:
        logging.warning(
            "%s: %d readings from %s, expected %d",
            path.name, len(rebuilds), source, config.N_REBUILDS,
        )

    used = [r["buildspan_us"] for r in rebuilds if not r["is_warmup"]]
    if not used:  # fewer readings than warmup budget — fall back to all
        used = [r["buildspan_us"] for r in rebuilds]
    execution = _execution_row(
        sample_id, group, role, instance_id, exec_index, status, session,
        median_us=statistics.median(used), rebuilds=rebuilds, used=used, source=source,
    )
    return rebuilds, execution


def _resolve_session(group: str, name: str | None) -> Path | None:
    """Pick which session dir of THIS group to parse.

    Sessions are per group and per device — dataset/<group>/<device>/raw/<session>/. Default:
    that group's newest session, so a re-run's captures are parsed without mixing in the
    earlier attempt (which would duplicate executions). 206 executions were measured more
    than once; newest-wins is what the committed corpus already reflects. Pass an explicit
    session name to re-parse an older one."""
    root = config.raw_dir(group)
    if not root.exists():
        return None
    if name:
        d = root / name
        return d if d.exists() else None
    sessions = sorted(d for d in root.glob("*") if d.is_dir())
    return sessions[-1] if sessions else None


def main() -> None:
    parser = argparse.ArgumentParser(description="Parse raw captures -> rebuilds/performance jsonl.")
    parser.add_argument("--warmup", type=int, default=config.WARMUP_DISCARD)
    parser.add_argument("--session", help="raw/<SESSION> subdir to parse (default: newest run).")
    args = parser.parse_args()
    logging.basicConfig(level=logging.INFO, format="%(levelname)s - %(message)s")

    all_rebuilds: list[dict] = []
    all_execs: list[dict] = []
    n_groups = 0
    for gdir in config.group_dirs():
        session_dir = _resolve_session(gdir.name, args.session)
        if session_dir is None:
            continue
        captures = sorted(session_dir.rglob("*.log"))
        if not captures:
            continue
        n_groups += 1
        logging.info(
            "group %s: session '%s' (%d captures)", gdir.name, session_dir.name, len(captures)
        )
        for cap in captures:
            rebuilds, execution = parse_capture(cap, args.warmup, session_dir.name)
            all_rebuilds.extend(rebuilds)
            if execution:
                all_execs.append(execution)

    if not all_execs:
        logging.error("No captures found under %s/<group>/%s/raw/ — run `run` first.",
                      config.OUT_DIR.name, config.device_slug())
        return

    all_rebuilds.sort(key=lambda r: (r["group"], r["role"], r["exec_index"], r["rebuild_index"]))
    all_execs.sort(key=lambda r: (r["group"], r["role"], r["exec_index"]))

    # Split per sample group AND device: dataset/<group>/<device>/{rebuilds,performance}.jsonl.
    # Only the groups parsed in this run are (re)written, so a single-sample run leaves other
    # samples — and the other device's rows for the same sample — alone.
    groups = sorted({r["group"] for r in all_rebuilds} | {r["group"] for r in all_execs})
    for g in groups:
        _write_jsonl([r for r in all_rebuilds if r["group"] == g], config.rebuilds_path(g))
        _write_jsonl([r for r in all_execs if r["group"] == g], config.performance_path(g))
    n_failed = sum(1 for e in all_execs if e["status"] == "failed")
    logging.info(
        "Wrote %d rebuilds + %d executions across %d sample group(s) -> %s/<group>/%s/",
        len(all_rebuilds), len(all_execs), len(groups), config.OUT_DIR.name, config.device_slug(),
    )
    if n_failed:
        # Written, not dropped — see the module docstring. Loud because these rows look
        # like measurements and a consumer that forgets to filter will treat them as such.
        logging.warning(
            "%d of %d executions are status=failed and ARE in %s — filter status == 'ok' "
            "before aggregating", n_failed, len(all_execs), config.PERFORMANCE_NAME,
        )
