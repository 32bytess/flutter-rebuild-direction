"""Report how much of a session is already measured — the resume decision, in one place.

`devices/lib/measure.sh` calls this to decide whether to reuse the newest session dir (resume)
or mint a fresh one. Both halves of that decision live here rather than in the shell:

  * what counts as done — delegated to `capture.capture_complete`, so the runner's skip rule
    and the resume banner can never disagree;
  * how many executions a group owes — `len(discover_targets(group)) * executions`, using the
    runner's own discovery so the shell never has to re-derive which .dart files are targets
    (dependencies.dart is not one);
  * WHICH session `--resume` continues into — `pick_session`, the most complete of the group's
    session dirs, newest name breaking a tie.

--quiet prints `<complete>/<expected>` and nothing else, for the shell to read.
--pick-session prints the session name to continue (empty when there is none) on stdout and the
human sentence on stderr, so `$( ... )` in the shell captures the name alone.
--best scores the group against `pick_session` rather than `latest_session` -- what `--resume`
will actually continue, which is not always the newest dir.
--all reports every group in the corpus from ONE process, which is what `pipeline.sh` asks
before a `--resume all` campaign: `discover_targets` re-reads the root's exclusions.json on
every call, so 85 separate invocations would be a two-minute prelude to every run.

`--samples-root` names the corpus; the DATASET root it is read against is still
`$BENCH_DATASET_DIR` (`pipeline.sh` exports it, derived from the corpus name). By hand, set
both or every group reads as unmeasured -- arm 2's captures are under `dataset-new_samples/`,
not `dataset/`.

    python -m scripts.device_runner status --group 01
    python -m scripts.device_runner status --group 01 --executions 15 --quiet
    python -m scripts.device_runner status --group 0058 --samples-root new_samples --eligible-only
    python -m scripts.device_runner status --group 0058 --samples-root new_samples --pick-session
    python -m scripts.device_runner status --all --best --quiet --samples-root new_samples \
        --eligible-only --executions 15
"""
from __future__ import annotations

import argparse
import os
import re
import sys

from . import capture, config


# A group directory is named by its numeric id. Everything else at the root of a corpus is
# bookkeeping -- exclusions.json, map.jsonl, .screen_cache.json -- so the name is the filter.
_GROUP_DIR = re.compile(r"^[0-9]+$")


def corpus_groups() -> list[str]:
    """Every group under the ACTIVE corpus root (`config.SAMPLES_ROOT`), sorted.

    Sorted because the campaign order must be reproducible: `--resume all` measures groups in
    exactly this order, and a rerun after a battery-floor stop has to walk the same list.
    """
    return sorted(d.name for d in config.SAMPLES_ROOT.glob("*")
                  if d.is_dir() and _GROUP_DIR.match(d.name))


def latest_session(group: str) -> str | None:
    root = config.raw_dir(group)
    if not root.exists():
        return None
    # Session names are YYYYmmdd-HHMMSS, so lexical order is chronological order.
    sessions = sorted(d.name for d in root.glob("*") if d.is_dir())
    return sessions[-1] if sessions else None


def pick_session(group: str) -> tuple[str | None, int, int]:
    """The session `--resume` should continue: (name, complete, present).

    MOST COMPLETE wins, newest name breaking a tie — not simply the newest, because a run that
    started a fresh dir and died early strands the progress in the older one, and `latest_session`
    would then hand the runner an empty dir to re-measure everything into. Scoring is
    `capture.session_progress`, so "done" keeps its single definition (scripts/device_runner/
    capture.py) here too.

    In the ordinary one-session-per-group case this IS the newest session. (None, 0, 0) when the
    group has no session dir yet, which the caller reads as "mint a fresh stamp".
    """
    root = config.raw_dir(group)
    if not root.exists():
        return None, 0, 0
    best: tuple[str, int, int] | None = None
    for name in sorted(d.name for d in root.glob("*") if d.is_dir()):
        complete, present = capture.session_progress(group, name)
        # `>=` with the names walked in ascending order is what makes the NEWEST win a tie.
        if best is None or complete >= best[1]:
            best = (name, complete, present)
    return best if best is not None else (None, 0, 0)


def progress_of(group: str, *, executions: int, eligible_only: bool, session: str | None,
                best: bool, discover_targets) -> tuple[str | None, int, int, int]:
    """(session, complete, present, expected) for one group.

    The one place the three inputs are combined, so `--all` and the single-group path cannot
    drift: an explicit `--session` wins, then `--best` (what `--resume` will continue), then
    the historical newest-session reading.
    """
    expected = len(discover_targets(group, eligible_only=eligible_only)) * executions
    if session is None:
        session = pick_session(group)[0] if best else latest_session(group)
    if session is None:
        return None, 0, 0, expected
    complete, present = capture.session_progress(group, session)
    return session, complete, present, expected


def main() -> None:
    ap = argparse.ArgumentParser(description="Report measured/expected executions of a session.")
    ap.add_argument("--group")
    ap.add_argument("--all", action="store_true", dest="all_groups",
                    help="Report EVERY group under the corpus root instead of one, from a "
                         "single process. With --quiet the format gains the id: one "
                         "`<group> <complete>/<expected>` line per group, sorted. This is what "
                         "`devices/lib/pipeline.sh` reads before a `--resume all` campaign.")
    ap.add_argument("--best", action="store_true",
                    help="Score against `pick_session` (the session --resume would continue) "
                         "rather than the newest one. Without it a group whose progress sits "
                         "in an older dir beside an empty newer one reports 0/expected, and a "
                         "caller acting on that would re-measure a nearly finished group.")
    ap.add_argument("--session", help="default: the group's newest session")
    ap.add_argument("--device", help="device slug override (default: $BENCH_DEVICE_ID)")
    ap.add_argument("--samples-root", metavar="DIR",
                    help="Corpus the group belongs to (default: samples/). Must match the root "
                         "`run` will measure, or the expected count belongs to another arm.")
    ap.add_argument("--eligible-only", action="store_true",
                    help="Count only the revisions that are an endpoint of an eligible contrast, "
                         "exactly as `run --eligible-only` measures them.")
    ap.add_argument("--executions", type=int, default=config.N_EXECUTIONS,
                    help="executions per target expected in a full session")
    ap.add_argument("--quiet", action="store_true", help="print only '<complete>/<expected>'")
    ap.add_argument("--pick-session", action="store_true",
                    help="print the session `--resume` should continue (most complete, newest "
                         "breaking a tie) on stdout, empty if the group has none. The sentence "
                         "explaining the pick goes to stderr.")
    args = ap.parse_args()

    # --all is a corpus-wide REPORT; --group, --session and --pick-session are all statements
    # about one group. Refuse the combination rather than silently honouring one of them.
    if args.all_groups:
        for flag, value in (("--group", args.group), ("--session", args.session),
                            ("--pick-session", args.pick_session)):
            if value:
                ap.error(f"--all cannot be combined with {flag} (it reports every group)")
    elif not args.group:
        ap.error("one of --group or --all is required")

    if args.device:
        os.environ["BENCH_DEVICE_ID"] = args.device

    from .runner import discover_targets  # imported lazily: runner pulls in the whole toolchain

    if args.samples_root:
        config.set_samples_root(args.samples_root)

    if args.all_groups:
        # Sorted, and every group listed even when it has no session at all — the caller is
        # building a work list, so "0/N" and "absent" must not look the same as "missing row".
        for group in corpus_groups():
            session, complete, present, expected = progress_of(
                group, executions=args.executions, eligible_only=args.eligible_only,
                session=None, best=args.best, discover_targets=discover_targets)
            if args.quiet:
                print(f"{group} {complete}/{expected}")
                continue
            where = f"session {session}" if session else "no sessions yet"
            extra = f", {present - complete} incomplete" if present > complete else ""
            print(f"{group}: {complete}/{expected} complete ({where}, {present} present{extra})")
        return

    expected = len(discover_targets(args.group, eligible_only=args.eligible_only)) * args.executions

    if args.pick_session:
        # stdout carries the NAME ALONE (or an empty line) — devices/lib/measure.sh reads it with
        # $( ... ) — so every word for a human goes to stderr, where the run log still shows it.
        name, complete, present = pick_session(args.group)
        if name is None:
            print(f"{args.group}: no session yet — a fresh one will be started", file=sys.stderr)
            print("")
            return
        extra = f", {present - complete} incomplete" if present > complete else ""
        print(f"{args.group}: continuing {name} ({complete}/{expected} complete, "
              f"{present} present{extra})", file=sys.stderr)
        print(name)
        return

    session, complete, present, expected = progress_of(
        args.group, executions=args.executions, eligible_only=args.eligible_only,
        session=args.session, best=args.best, discover_targets=discover_targets)
    if session is None:
        print(f"0/{expected}" if args.quiet else f"{args.group}: no sessions yet", )
        return

    if args.quiet:
        print(f"{complete}/{expected}")
        return
    print(f"{args.group} session {session} (device {config.device_slug()})")
    print(f"  complete : {complete}/{expected}")
    print(f"  present  : {present}  ({present - complete} incomplete, will be re-measured)")
