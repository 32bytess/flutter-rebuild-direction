"""What the device actually drew, read back off the artifacts the campaign already wrote.

THE PROBLEM THIS ANSWERS. A transplant can mount, survive every static rule, and draw
nothing -- or draw Flutter's error box, because its `build` threw. Either way a row lands in
`performance.jsonl` and it is not noise: it is a buildSpan for a tree the feature vector does
not describe, which is a systematically wrong label. `fixture_gate` catches the unfilled
slot; `R19`/`R20` catch a shim that renders none of its subtree; neither can see a `_Stub`
reaching a typed slot, because the flow is `dynamic` and the failure is a runtime type error.
`integration_test/integration_test.dart` has captured one screenshot per role since the day
that was written down -- and nothing has ever opened one.

    python3 -m scripts.render_gate --report
    python3 -m scripts.render_gate --apply        # write config/render_exclusions.json

TWO INDEPENDENT WITNESSES, and the gate says which one spoke:

  raw log    a stack frame `#0 ... (package:benchmark_container/generated_widget.dart:N)`.
             The transplant's own `build` is frame zero, so the throw is the role's, not the
             harness's. Decisive, and it carries the message.
  screenshot the band below the app bar is Flutter's `RenderErrorBox` grey, or one flat
             colour. The error box is `0xF0C0C0C0`, which over the container's white
             `Scaffold` composites to exactly (196, 196, 196).

WHY NOT "IS IT GREY". `--normalise` REPLACES every image in the corpus with
`Container(color: Colors.grey.shade300, ...)` (`dart_tools/lib/src/normalise.dart`), so a
grey rectangle is a DESIRED export artifact and a naive grey test would condemn every
placeholder in the corpus. `shade300` is (224, 224, 224); the error box is (196, 196, 196).
The gate keys on the narrow band around the error box's own composite and on nothing else.

WHAT IT DOES NOT DO. It does not decide what a role SHOULD render, and `ok` is not a claim
that a screenshot looks right -- only that it is neither of the two dead states. A role with
no shot and no log is `unknown`, never `ok`: the census is a floor, and saying so is the
point of having the bucket.
"""

from __future__ import annotations

import argparse
import json
import re
from datetime import datetime, timezone
from pathlib import Path

from scripts import jsonio, render_png
from scripts.paths import PROJECT_ROOT as ROOT, rel

TABLE = ROOT / "config" / "render_exclusions.json"

# Frame zero inside the transplanted library. `dependencies.dart` is `part of
# generated_widget`, so a throw from a stand-in reports this same file -- which is correct:
# the fixture is as much the role's mounting state as its own code is.
BUILD_FRAME = re.compile(
    r"#0\s+.*\(package:benchmark_container/generated_widget\.dart:\d+")
FLUTTER_LINE = re.compile(r"^[A-Z]/flutter\s*\(\s*\d+\):\s?(.*)$")
FRAME_LINE = re.compile(r"^#\d+\s")

# `runner --dump-errors` prints every `FlutterErrorDetails` in full, message first and then
# its top frames. It exists because profile mode otherwise collapses the lot to
# "Multiple exceptions (N) were detected during the running of the current test" and prints
# no exception and no stack for any of them -- which is the entire log for the roles this
# gate can only condemn on pixels. The first `[SPM:err]` line that is not a frame is the
# message.
DUMP_LINE = re.compile(r"\[SPM:err\]\s+(.*)$")

# `RenderErrorBox` paints `Color(0xF0C0C0C0)`. Over the container's white Scaffold that
# composites to (196, 196, 196); the tolerance covers the same box over a slightly different
# ground without reaching `Colors.grey.shade300` (224) in either direction.
ERROR_GREY = range(190, 203)

# THE SAME BOX IN A DEBUG BUILD IS RED, NOT GREY. From the SDK, `rendering/error.dart`:
#
#     static Color backgroundColor = _initBackgroundColor();
#     static Color _initBackgroundColor() {
#       var result = const Color(0xF0C0C0C0);
#       assert(() { result = const Color(0xF0900000); return true; }());
#       return result;
#     }
#
# so under `assert` it is `0xF0900000`, which over the same white Scaffold composites to
# (151, 15, 15), with yellow monospace text drawn over it instead of dark grey.
#
# `device_runner shots` builds debug, and a gate that knew only the grey would score every
# debug error box as `ok` -- silent, and in the permissive direction, which is the worst way
# for a gate to be wrong. The two are matched separately and reported separately, because
# which one appeared says which binary drew it.
ERROR_RED_R = range(144, 159)
ERROR_RED_GB = range(0, 26)
# A single flat colour across the whole band. Not a threshold to tune: one colour means one
# `RenderBox` painted the band and nothing else did.
FLAT = 0.999
# Enough of the band to say the error box is on screen rather than inside one list row.
ERROR_SHARE = 0.02

VERDICTS = ("renders_error", "renders_nothing", "ok", "unknown")

# The two verdicts that are also screening rules, named here so the table and
# `scripts/screen/rules.py` cannot drift apart over a string.
RENDER_ERROR_RULE = "R21_renders_error"
RENDER_NOTHING_RULE = "R22_renders_nothing"


def _is_error_grey(rgb: tuple[int, int, int]) -> bool:
    r, g, b = rgb
    return r == g == b and r in ERROR_GREY


def _is_error_red(rgb: tuple[int, int, int]) -> bool:
    """The debug error box. Narrow on purpose -- a dark red WIDGET is ordinary, and the band
    is tight enough around (151, 15, 15) that an app's own red does not land in it."""
    r, g, b = rgb
    return r in ERROR_RED_R and g in ERROR_RED_GB and b in ERROR_RED_GB and abs(g - b) <= 4


def build_exception(log: Path) -> str | None:
    """The message of the first exception thrown from the transplant's own build, if any.

    Two witnesses, and the explicit one is preferred. `runner --dump-errors` prints
    `[SPM:err] <exception>` followed by its frames, so a diagnostic pass names the throw
    outright; without it, the message has to be recovered from the logcat stream.

    Failing that: scan for frame zero inside the transplanted library and walk BACK to the
    nearest `I/flutter` line that is not itself a frame -- the message is printed before the
    trace, and everything between is logcat from other tags.
    """
    try:
        lines = log.read_text(encoding="utf-8", errors="replace").splitlines()
    except OSError:
        return None
    for line in lines:
        m = DUMP_LINE.search(line)
        if m and m.group(1).strip() and not FRAME_LINE.match(m.group(1).strip()):
            return m.group(1).strip()
    for i, line in enumerate(lines):
        if not BUILD_FRAME.search(line):
            continue
        for back in range(i - 1, max(i - 40, -1), -1):
            m = FLUTTER_LINE.match(lines[back].strip())
            if m and m.group(1) and not FRAME_LINE.match(m.group(1)):
                return m.group(1).strip()
        return "an exception was thrown from the transplant's build"
    return None


def shot_evidence(shot: Path) -> dict:
    """Dominant colour of the body band, how much of it that colour holds, and the grey share."""
    try:
        total, counts = render_png.region_histogram(shot)
    except (render_png.UnsupportedPng, OSError) as exc:
        return {"shot": shot.name, "error": str(exc)}
    if not total:
        return {"shot": shot.name, "error": "empty sample"}
    rgb, n = max(counts.items(), key=lambda kv: kv[1])
    grey = sum(k for c, k in counts.items() if _is_error_grey(c))
    red = sum(k for c, k in counts.items() if _is_error_red(c))
    return {"shot": shot.name, "dominant": list(rgb), "flat": round(n / total, 4),
            "error_grey": round(grey / total, 4), "error_red": round(red / total, 4)}


def classify(evidence: dict) -> str:
    """One role's verdict. The log outranks the image: it names the throw."""
    if evidence.get("exception"):
        return "renders_error"
    shot = evidence.get("shot_evidence")
    if not shot or "error" in shot:
        return "unknown"
    # Either box, and the debug one is checked with `.get` so a row written before the red
    # signature existed still classifies instead of raising.
    if shot["error_grey"] >= ERROR_SHARE or shot.get("error_red", 0) >= ERROR_SHARE:
        return "renders_error"
    if shot["flat"] >= FLAT:
        return "renders_nothing"
    return "ok"


def _roles(group_dir: Path) -> dict[str, dict]:
    """role -> {shot, logs} for one `<dataset>/<group>/<device>/` directory."""
    out: dict[str, dict] = {}
    shots = group_dir / "shots"
    if shots.is_dir():
        for png in sorted(shots.glob("*.png")):
            # `<gid>__<role>.png`, per device_runner.config.shots_dir
            role = png.stem.split("__", 1)[-1]
            out.setdefault(role, {"logs": []})["shot"] = png
    raw = group_dir / "raw"
    if raw.is_dir():
        for log in sorted(raw.glob("*/*/e*.log")):
            out.setdefault(log.parent.name, {"logs": []})["logs"].append(log)
    return out


def survey(dataset: Path) -> dict:
    """group -> device -> role -> {verdict, evidence}. Reads only; writes nothing."""
    out: dict = {}
    for group_dir in sorted(d for d in dataset.iterdir() if d.is_dir() and d.name != "_meta"):
        for device_dir in sorted(d for d in group_dir.iterdir() if d.is_dir()):
            roles = _roles(device_dir)
            if not roles:
                continue
            for role, found in sorted(roles.items()):
                evidence: dict = {}
                for log in found["logs"]:
                    message = build_exception(log)
                    if message:
                        evidence["exception"] = message
                        evidence["log"] = rel(log)
                        break
                if found.get("shot"):
                    evidence["shot_evidence"] = shot_evidence(found["shot"])
                out.setdefault(group_dir.name, {}).setdefault(device_dir.name, {})[role] = {
                    "verdict": classify(evidence), **evidence}
    return out


def table_rows(surveyed: dict, dataset: Path | None = None,
               build_mode: str | None = None) -> dict:
    """The committed table: only the roles a rule fires on, keyed group -> role -> row.

    Devices are folded in rather than kept as a level, because the verdict is a property of
    the CODE plus its fixture, not of the phone. A role that throws on one device and not on
    another would be a finding about the device, so the fold records every device that saw
    it and the union is what the screen reads.
    """
    rows: dict = {}
    for gid, devices in surveyed.items():
        for device, roles in devices.items():
            for role, found in roles.items():
                if found["verdict"] not in ("renders_error", "renders_nothing"):
                    continue
                row = rows.setdefault(gid, {}).setdefault(role, {
                    "verdict": found["verdict"], "devices": [], "evidence": {},
                    # Which run saw this. A merged table holds rows from several passes, and a
                    # campaign verdict and a one-execution validation verdict are not the same
                    # claim -- `dataset-validate` says so in the file rather than in memory.
                    **({"observed_in": rel(dataset)} if dataset is not None else {}),
                    # DEBUG OR PROFILE. `device_runner shots` builds debug, where `assert`s
                    # run -- so a role can trip an assertion the profile binary never
                    # evaluates and be condemned for it. The exclusion is conservative either
                    # way (it keeps a role OUT), but a `renders_error` seen only in debug is
                    # worth one profiled execution before it is treated as final, and this is
                    # what tells a reader which rows those are.
                    **({"build_mode": build_mode} if build_mode else {})})
                if device not in row["devices"]:
                    row["devices"].append(device)
                # `renders_error` outranks `renders_nothing`: a throw explains a flat screen,
                # and reporting the milder of the two would drop the message that names it.
                if found["verdict"] == "renders_error":
                    row["verdict"] = "renders_error"
                for key in ("exception", "log", "shot_evidence"):
                    if key in found:
                        row["evidence"].setdefault(key, found[key])
    for gid in rows:
        for role in rows[gid]:
            rows[gid][role]["devices"].sort()
    return rows


def load(path: Path | None = None) -> dict:
    """The committed verdicts, group -> role -> row. A missing table is empty, not an error.

    Empty is the honest answer before the gate has ever run: unlike the values table, nothing
    is silently re-derived from it, so there is no quiet degradation to refuse over.

    `path` overrides the committed table, for the reason `--license-provenance` exists: this
    file is GLOBAL while `--source` and `--dest` are arguments, so a test corpus screened
    without it would be judged on the real corpus's device verdicts. The golden record caught
    exactly that.
    """
    doc = jsonio.read_json(path or TABLE, {}) or {}
    groups = doc.get("groups", {}) if isinstance(doc, dict) else {}
    return groups if isinstance(groups, dict) else {}


def version(path: Path | None = None) -> str:
    """Digest for the checkpoint fingerprint. An absent table hashes as absent, not as `{}`.

    `license_version` raises on a missing file because a checkpoint written against a real
    table must not resume against nothing. This table is different in one way that matters:
    it is legitimately absent until the first device campaign, and a screen must run before
    then. So the absence is NAMED in the digest instead -- writing the table for the first
    time still moves it, which is what invalidates the checkpoints that ran without it.
    """
    import hashlib
    table = path or TABLE
    if not table.is_file():
        return hashlib.sha256(b"render_exclusions:absent").hexdigest()[:16]
    return hashlib.sha256(table.read_bytes()).hexdigest()[:16]


def observed(surveyed: dict) -> set[tuple[str, str]]:
    """(group, role) this pass actually looked at -- `ok` and `renders_*` alike, `unknown` not.

    The set a merge is allowed to change. `unknown` is excluded on purpose: it means the pass
    found neither a screenshot nor a raw log for that role, which is no evidence at all and
    must not be able to clear a verdict some earlier pass recorded from real artifacts.
    """
    return {(gid, role)
            for gid, devices in surveyed.items()
            for roles in devices.values()
            for role, found in roles.items()
            if found["verdict"] != "unknown"}


def merge(rows: dict, surveyed: dict, prior: dict) -> dict:
    """The committed table updated by what this pass saw, and by nothing else.

    MERGE, NEVER REPLACE, for the reason `fixture_values.run` gives about its own table -- and
    here the failure it prevents is circular rather than merely lossy. A pass normally covers
    the ELIGIBLE ENDPOINTS, and 44 of the 106 roles condemned on 2026-09-15 are not endpoints:
    they stopped being endpoints precisely BECAUSE R21 excluded their contrasts. Writing this
    pass's rows straight out would drop them, R21 would stop firing, their contrasts would come
    back, and the corpus would silently re-admit roles known to draw an error box. The
    exclusion would have erased its own evidence.

    So: a role this pass observed takes the new verdict, including being dropped when it now
    renders. A role it did not observe keeps whatever is on record. The asymmetry is deliberate
    and it is conservative -- a stale verdict keeps a role OUT, and clearing one costs a device
    run, which is the right price for re-admitting something to the corpus.
    """
    seen = observed(surveyed)
    out = {gid: dict(roles) for gid, roles in prior.items()}
    for gid, role in seen:
        if role in out.get(gid, {}):
            del out[gid][role]                       # observed: the new verdict is the verdict
    for gid, roles in rows.items():
        out.setdefault(gid, {}).update(roles)
    return {gid: roles for gid, roles in sorted(out.items()) if roles}


def write(rows: dict, dataset: Path, surveyed: dict, *, replace: bool = False) -> None:
    counts: dict[str, int] = {v: 0 for v in VERDICTS}
    for devices in surveyed.values():
        for roles in devices.values():
            for found in roles.values():
                counts[found["verdict"]] += 1
    prior = {} if replace else load()
    groups = merge(rows, surveyed, prior)
    carried = sum(len(r) for r in groups.values()) - sum(len(r) for r in rows.values())
    TABLE.parent.mkdir(parents=True, exist_ok=True)
    TABLE.write_text(json.dumps({
        "version": 1,
        "_comment": (
            "Roles the device drew nothing useful for. Written by scripts/render_gate.py "
            "from the screenshots and raw logs of a measurement campaign; read by "
            "scripts/screen/rules.py as R21_renders_error and R22_renders_nothing. "
            "Hand-editable: add a role to record a verdict the artifacts cannot show, and "
            "say so in its `evidence`."),
        "generated": datetime.now(timezone.utc).isoformat(),
        "dataset": rel(dataset),
        "role_verdicts": counts,
        "rows_carried_from_earlier_passes": carried,
        "_coverage": (
            "`unknown` is roles with neither a screenshot nor a raw log. The census is a "
            "FLOOR: a role that was never measured, or measured before --screenshots "
            "existed, cannot be condemned or cleared by this pass."),
        "_merge": (
            "Rows are MERGED, never replaced. A role this pass observed takes its new verdict, "
            "including being dropped when it now renders; a role it did not observe keeps what "
            "is on record, and `observed_in` on each row says which dataset root last saw it. "
            "A pass over the eligible endpoints does not see the roles R21 already excluded "
            "-- they stopped being endpoints because of it -- so replacing would let the "
            "exclusion erase its own evidence. `--replace` rebuilds from one root deliberately."),
        "groups": groups,
    }, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Classify what each measured role actually drew.")
    parser.add_argument("--dataset", default="dataset-new_samples",
                        help="Measurement root (default: dataset-new_samples).")
    parser.add_argument("--apply", action="store_true",
                        help=f"Write {rel(TABLE)} (default: report only).")
    parser.add_argument("--report", action="store_true", help="Print every role's verdict.")
    parser.add_argument("--group", help="Restrict to one group id.")
    parser.add_argument(
        "--build-mode", choices=("debug", "profile"), default=None,
        help="Stamp each row with the build that drew it. `device_runner shots` builds "
             "debug, where asserts run, so a debug-only `renders_error` may be an assertion "
             "the measured binary never evaluates -- recording which is which is what makes "
             "that checkable later.")
    parser.add_argument(
        "--replace", action="store_true",
        help="Rebuild the table from THIS root alone, dropping every row the pass did not "
             "observe. Almost never what you want: a pass over the eligible endpoints cannot "
             "see the roles R21 already excluded -- they stopped being endpoints because of "
             "it -- so replacing lets the exclusion erase its own evidence and the corpus "
             "quietly re-admits roles known to draw an error box. Merging is the default.")
    args = parser.parse_args()

    dataset = Path(args.dataset)
    if not dataset.is_absolute():
        dataset = ROOT / dataset
    if not dataset.is_dir():
        raise SystemExit(f"no measurement root at {rel(dataset)}")

    surveyed = survey(dataset)
    if args.group:
        surveyed = {g: v for g, v in surveyed.items() if g == args.group}
    rows = table_rows(surveyed, dataset, args.build_mode)

    counts = {v: 0 for v in VERDICTS}
    for devices in surveyed.values():
        for roles in devices.values():
            for found in roles.values():
                counts[found["verdict"]] += 1

    for gid in sorted(rows):
        print(f"[{gid}]")
        for role in sorted(rows[gid]):
            row = rows[gid][role]
            why = row["evidence"].get("exception") \
                or f"flat {row['evidence'].get('shot_evidence', {}).get('dominant')}"
            print(f"    {row['verdict']:15} {role:24} {why}")
    if args.report:
        for gid in sorted(surveyed):
            for device in sorted(surveyed[gid]):
                for role, found in sorted(surveyed[gid][device].items()):
                    print(f"{gid}/{device}/{role:24} {found['verdict']}")
    print(f"\nroles: " + ", ".join(f"{counts[v]} {v}" for v in VERDICTS))
    print(f"groups with a condemned role: {len(rows)}")
    if args.apply:
        write(rows, dataset, surveyed, replace=args.replace)
        kept = sum(len(r) for r in load().values()) - sum(len(r) for r in rows.values())
        print(f"wrote {rel(TABLE)}  (render_version {version()})")
        if not args.replace:
            print(f"  {kept} row(s) carried from earlier passes -- this run did not observe "
                  f"them, so their verdict stands")
    else:
        print(f"(report only -- --apply writes {rel(TABLE)})")


if __name__ == "__main__":
    main()
