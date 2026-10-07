"""One image per role: mount the widget, photograph it, move on. NOT a measurement.

WHY THIS IS A SUBCOMMAND AND NOT A FLAG. `run` collects buildSpans and everything it does is
shaped by that: it interleaves a shuffled schedule so thermal drift is noise rather than a
per-target confound, it gates on battery and SoC temperature, it writes `performance.jsonl`
and `rebuilds.jsonl`, and a group it touches needs a freeze release and a discard before it
can be touched again. A census needs none of that, and putting it behind a flag on `run` would
make "this is not a measurement" something a reader has to check rather than something the
command name says.

WHAT IT SKIPS, measured on the real 2411 captures of 2026-09-15 (126 s per role):

    61.4 s  30 profiled rebuilds. The integration test fires `setState(() {})`, which re-runs
            the same `build` against the same state -- thirty of them photograph one tree
            thirty times. What they exercise is the MEASURED path, which a census does not use.
    ~41 s   `spm run`: its own `flutter pub get` + `flutter analyze` before every execution,
            then injection and revert. A census does not inject: `SPM_SHOT_ONLY` makes the
            test skip the `tester.state<SpmState>()` cast, which is the only thing that
            required an instrumented build.
    22.5 s  Gradle `assembleProfile` -> `assembleDebug`, since nothing here is timed.

WHAT DEBUG COSTS, and it is not nothing. `RenderErrorBox.backgroundColor` is
`Color(0xF0900000)` under `assert`, `Color(0xF0C0C0C0)` otherwise (Flutter's
`rendering/error.dart`), so a build failure paints DARK RED here and grey in a profile build --
`scripts/render_gate.py` knows both. And `assert`s run: a role that trips one the profile
binary never evaluates would be condemned falsely, which is why every row this pass produces
records `build_mode` and a debug-only `renders_error` is worth one profiled execution before
it is treated as final.

    python -m scripts.device_runner shots --samples-root new_samples --roles roles.txt
    python -m scripts.device_runner shots --widget-type 2411

Completeness is "the PNG is there", the same test `--screenshots` already uses to decide
whether to shoot, so an interrupted pass resumes for free and needs no session bookkeeping.
"""

from __future__ import annotations

import argparse
import logging
import os
from pathlib import Path

from . import config


def drive_cmd(shot_name: str) -> list[str]:
    """`flutter drive` on its own -- no `spm run`, no injection, no `--profile`.

    `test_driver/integration_driver.dart` writes the PNG through `integrationDriver`'s
    `onScreenshot` and never mentions spm, so a bare drive produces the image.

    `--no-pub` for the reason `config.spm_run_cmd` gives: `flutter drive` re-resolves
    dependencies on every invocation, `pubspec.yaml` never changes during a pass, and
    `ensure_packages()` below has already done it once.
    """
    serial = os.environ.get("BENCH_DEVICE_SERIAL", "").strip()
    return [
        "flutter", "drive",
        "--no-pub",
        f"--driver={config.INTEGRATION_DRIVER}",
        f"--target={config.INTEGRATION_TEST}",
        "--no-dds",
        *(["-d", serial] if serial else []),
        "--dart-define=SPM_SHOT=true",
        f"--dart-define=SPM_SHOT_NAME={shot_name}",
        # The two that make this a census: mount-and-photograph instead of the measured span,
        # and every framework error printed in full so a condemned role names its own cause.
        "--dart-define=SPM_SHOT_ONLY=true",
        "--dart-define=SPM_DUMP_ERRORS=true",
    ]


def capture(target: dict, *, force: bool) -> str:
    """Photograph one role. Returns `shot`, `skipped` or `failed`."""
    from .runner import _run, assemble          # local: runner imports device-side modules

    shot_dir = config.shots_dir(target["group"])
    name = f"{target['group']}__{target['role']}"
    png = shot_dir / f"{name}.png"
    if png.exists() and not force:
        return "skipped"

    shot_dir.mkdir(parents=True, exist_ok=True)
    assemble(target)
    ok, out = _run(drive_cmd(name), timeout_s=config.SPM_RUN_TIMEOUT_S or 600,
                   env={"SPM_SHOT_DIR": str(shot_dir)})

    # The log is the other half of the evidence: `[SPM:err]` lines are what let the gate name
    # what a role threw, and profile mode's "Multiple exceptions (N) were detected" is exactly
    # the case they exist for. Written where `render_gate` already looks.
    log = config.raw_dir(target["group"]) / "shots" / target["role"] / "e0.log"
    log.parent.mkdir(parents=True, exist_ok=True)
    log.write_text(
        f"# sample_id={target['sample_id']} shot_only=True ok={ok}\n{out}", encoding="utf-8")
    return "shot" if png.exists() else "failed"


def main() -> None:
    from .runner import discover_targets, read_role_list, resolve_packages, restore_active

    ap = argparse.ArgumentParser(
        description="One diagnostic image per role. Produces no measurements.")
    ap.add_argument("--samples-root", metavar="DIR",
                    help="Corpus to photograph (default: samples/). Use new_samples/ for arm 2.")
    ap.add_argument("--widget-type", metavar="GROUP", help="Only <root>/<GROUP>/.")
    ap.add_argument("--roles", metavar="FILE",
                    help="Photograph exactly the `<group>/<role>` lines in FILE. "
                         "`python3 -m scripts.census_roles` writes the set a pre-campaign "
                         "census wants: the eligible endpoints UNION the roles R21 condemned.")
    ap.add_argument("--eligible-only", action="store_true",
                    help="Restrict to endpoints of eligible contrasts. Note this is NOT the "
                         "census set -- 44 of the condemned roles are not endpoints, because "
                         "R21 excluding their contrasts is what stopped them being endpoints.")
    ap.add_argument("--force", action="store_true",
                    help="Re-photograph roles that already have a PNG. Needed after a repair: "
                         "an existing image is assumed current, so a stale one is otherwise "
                         "reused and the gate re-condemns a group that has just been fixed.")
    args = ap.parse_args()

    logging.basicConfig(level=logging.INFO, format="%(levelname)s - %(message)s")
    if args.samples_root:
        config.set_samples_root(args.samples_root)

    targets = discover_targets(
        args.widget_type, eligible_only=args.eligible_only,
        roles=read_role_list(Path(args.roles)) if args.roles else None)
    if not targets:
        raise SystemExit(f"no targets under {config.SAMPLES_ROOT}")

    # A group awaiting a hand-authored fixture is exactly the kind of thing worth a picture, so
    # -- unlike `run` -- nothing is filtered out here. A census reports; it does not select.
    logging.info("Photographing %d role(s) across %d group(s) into %s",
                 len(targets), len({t["group"] for t in targets}), config.OUT_DIR)

    original = config.ACTIVE_WIDGET_PATH.read_text(encoding="utf-8")
    resolve_packages()
    tally = {"shot": 0, "skipped": 0, "failed": 0}
    try:
        for i, target in enumerate(targets, 1):
            outcome = capture(target, force=args.force)
            tally[outcome] += 1
            logging.info("[%d/%d] %-34s %s", i, len(targets), target["sample_id"], outcome)
    finally:
        restore_active(original)

    print(f"\n{tally['shot']} photographed, {tally['skipped']} already had an image, "
          f"{tally['failed']} produced none")
    print(f"census: python3 -m scripts.render_gate --dataset {config.OUT_DIR.name} --report")
    if tally["failed"]:
        # A role that produced no image is not a role that renders nothing -- it is a role
        # nobody looked at, and `render_gate` scores it `unknown` for exactly that reason.
        raise SystemExit(2)


if __name__ == "__main__":
    main()
