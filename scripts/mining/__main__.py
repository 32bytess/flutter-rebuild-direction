"""CLI for the v2 corpus mine. Each phase is separately re-runnable."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from . import config


def pipeline_module_default(name: str):
    """Read a default off `pipeline` without importing it at CLI-construction time.

    The phase modules are imported lazily in `main()` so `--help` stays fast; these two
    constants are needed while the parser is still being built, and duplicating them here is
    how the documented batch sequence and the pipeline would come to build different corpora.
    """
    from . import pipeline as pipeline_phase

    return getattr(pipeline_phase, name)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        prog="python -m scripts.mining",
        description=(
            "Mine human-written rebuild-scope edits from the repositories harvested "
            "2026-08-17, none of which contributed to the measured corpus. Human "
            "commits carry no directive identity, so a stratum built from them is the "
            "direct antidote to the directive confound."
        ),
    )
    # Shared by every phase, and accepted AFTER the phase name where anyone would
    # naturally type it: `mining prepare --repos owner/name`.
    common = argparse.ArgumentParser(add_help=False)
    common.add_argument(
        "--all",
        action="store_true",
        dest="all_repos",
        help="Act on every eligible repository (all harvested, minus the four "
             "already in the measured corpus). Overrides --repos.",
    )
    common.add_argument(
        "--repos",
        nargs="+",
        metavar="owner/name",
        help="Repositories to act on. Defaults to the 5-repo pilot; the full run is "
             "the same code with a longer list. Corpus repos are excluded either way.",
    )
    common.add_argument(
        "--exclude",
        nargs="+",
        default=None,
        metavar="owner/name|@file|samples",
        help="Repositories to drop from this run, on top of the 8 that built the "
             "measured corpus (those are excluded unconditionally, with or without "
             "this flag). Takes `owner/name`, the on-disk `owner_name`, `@path` to a "
             "file with one name per line (`#` comments allowed), or the alias "
             "`samples` for those same 8. An exclusion that matches no selected "
             "repository is printed as UNMATCHED - almost always a typo.",
    )

    # Resume is spelled identically on every phase that walks repositories. Each phase
    # writes a per-repository checkpoint the moment that repository finishes, so a run
    # that is interrupted -- or that is re-run after the harvest grew -- picks up where
    # it stopped instead of repeating hours of identical work.
    resumable = argparse.ArgumentParser(add_help=False)
    resumable.add_argument(
        "--resume",
        action="store_true",
        help="Skip repositories that already have a checkpoint from a previous run. "
             "Matched by NAME ONLY: a checkpoint records that the walk finished, not "
             "that it finished with the same arguments, so start from scratch after "
             "changing the extractor build or this phase's own limits. In `mine` this "
             "also resumes a repository that was interrupted MID-WALK, by replaying the "
             "per-commit journal at `probe_v2/checkpoints/partial/`; a journal written "
             "under different arguments is refused out loud and its repository re-walked "
             "from its first commit.",
    )
    resumable.add_argument(
        "--retry-failed",
        action="store_true",
        help="With --resume, also re-run repositories whose checkpoint records a "
             "failure. Opt-in because only you know whether a failure was transient "
             "(a `pub get` network hiccup) or terminal (`broken_source`).",
    )

    # `discover`, `mine` and `isolate --history` each have their own half of "look at
    # every revision, not only HEAD", and they must be turned on together: seeding the
    # commits without tracking the scopes finds nothing, and tracking without the seed
    # never visits the commits where the extra scopes live.
    every_revision = argparse.ArgumentParser(add_help=False)
    every_revision.add_argument(
        "--all-revisions",
        action="store_true",
        help="Take rebuild scopes from EVERY commit walked, not only the ones standing "
             "at HEAD. In `discover` this sweeps history for commits touching a "
             "marker-bearing lib/ file; in `mine` and `isolate --history` it registers "
             "each scope the moment a revision first shows it, mints a group id, and "
             "uses that scope's first transplant as its base.dart. Without it a scope "
             "added and later deleted is invisible, which selects the corpus on "
             "survival. Changes what a phase produces: delete that phase's checkpoints "
             "rather than resuming across it.",
    )

    # The history window. Shared by the phases that choose commits, because a cutoff
    # applied in one and not the other produces a corpus whose bounds nobody can state.
    windowed = argparse.ArgumentParser(add_help=False)
    windowed.add_argument(
        "--since",
        metavar="YYYY-MM-DD|null-safety|dart3",
        default=None,
        help="Ignore commits older than this date. `null-safety` is the alias for "
             f"{config.NULL_SAFETY_DATE}, when Dart 2.12 shipped sound null safety: "
             "earlier commits are a different language, do not resolve against a modern "
             "SDK, and yield deltas that record the migration rather than a human's "
             "edit. `dart3` is the alias for "
             f"{config.DART3_DATE}, when Dart 3.0 made null safety mandatory and added "
             "records, patterns and sealed classes. Recorded in the phase summary, so a "
             "bounded corpus never reads as a complete one.",
    )

    subparsers = parser.add_subparsers(dest="phase", required=True)

    clone = subparsers.add_parser(
        "clone",
        parents=[common],
        help="Phase 1: blobless re-clone, so the repositories have history at all.",
    )
    clone.add_argument(
        "--force",
        action="store_true",
        help="Re-clone repositories that are already present.",
    )

    prepare = subparsers.add_parser(
        "prepare",
        parents=[common, resumable],
        help="Phase 2: drive each checkout to zero error-severity diagnostics under "
             "lib/, so a scope's whole dependency closure resolves.",
    )
    prepare.add_argument(
        "--jobs",
        type=int,
        default=1,
        help="Repositories to prepare concurrently. Kept modest: concurrent "
             "`pub get` contends on the shared pub cache.",
    )

    discover = subparsers.add_parser(
        "discover",
        parents=[common, resumable, every_revision, windowed],
        help="Phase 3: find rebuild scopes and the commits that could have moved "
             "them, selecting over each scope's dependency closure rather than "
             "just its declaring file.",
    )
    discover.add_argument("--jobs", type=int, default=1,
                          help="Repositories to scan concurrently.")
    discover.add_argument("--only-clean", action="store_true",
                          help="Restrict to repositories `prepare` marked clean. "
                               "Scanning an unresolved repo finds a fraction of "
                               "its scopes and a short closure.")

    mine = subparsers.add_parser(
        "mine",
        parents=[common, resumable, every_revision, windowed],
        help="Phase 4: walk each scope's candidate commits and pair consecutive "
             "revisions into feature deltas.",
    )
    mine.add_argument(
        "--isolate",
        action="store_true",
        help="Also transplant each scope at every revision, in the SAME checkout "
             "as the metrics. One walk instead of two: `isolate --history` pays "
             "checkout, pub get and codegen a second time for identical state.",
    )
    mine.add_argument(
        "--jobs",
        type=int,
        default=1,
        help="Repositories to walk concurrently. They are independent clones, so "
             "this scales close to linearly until disk or CPU saturates.",
    )
    mine.add_argument(
        "--max-commits",
        type=int,
        default=None,
        help="Walk at most this many of the most recent commits per repository. "
             "Any cap is printed and recorded - a truncated walk must never read "
             "as a complete one.",
    )

    isolate = subparsers.add_parser(
        "isolate",
        parents=[common, resumable, every_revision],
        help="Phase 5: transplant every rebuild scope into a self-contained "
             "base.dart, laid out like samples/ but with no dependencies.dart, "
             "recording project + scope type + commit sha for each.",
    )
    isolate.add_argument(
        "--include-unprepared",
        action="store_true",
        help="Isolate repositories whose lib/ never reached zero errors. The "
             "transplant loses type information there and inlines less than it "
             "should, so the sample is shallower than the code it claims to be.",
    )
    isolate.add_argument(
        "--history",
        action="store_true",
        help="Also isolate each scope at every commit that touched it or its "
             "closure, beside its base.dart. Without this you get one snapshot "
             "per scope, which cannot produce a before/after pair.",
    )
    isolate.add_argument(
        "--max-commits",
        type=int,
        default=None,
        help="With --history, walk at most this many of the most recent commits "
             "per repository. Any cap is printed and recorded.",
    )
    isolate.add_argument(
        "--no-check",
        action="store_true",
        help="Skip the self-containment check (one `dart analyze` over every "
             "generated base.dart).",
    )

    provenance = subparsers.add_parser(
        "license-provenance",
        parents=[common, resumable],
        help="Record which hosted packages each transplant carried source from, by "
             "re-isolating only the commits behind files that carry a positive "
             "`inlinedThirdPartyDeclarations`. Writes config/license_provenance.jsonl "
             "and nothing else -- samples_v2 and new_samples are never touched. Every row "
             "is gated on the re-isolated bytes equalling the shipped transplant.",
    )
    provenance.add_argument(
        "--spm",
        type=Path,
        default=None,
        help="A directory holding `bin/spm.dart`, to run INSTEAD of the container's own "
             "dependency. Rarely wanted: since 2026-09-05 that dependency is 0.7.1 by "
             "path, which emits `inlinedThirdPartyPackages`. The reason to reach for this "
             "is the fallback build `provenance/0.7.0+packages` in spm-publish, which is "
             "0.7.0 plus the field and nothing else.",
    )

    pipeline = subparsers.add_parser(
        "pipeline",
        parents=[common, resumable, windowed],
        help="Every phase, one repository at a time: clone, prepare, discover, mine, "
             "license-provenance, screen -- then the next repository. The corpus at --dest "
             "is complete and consistent after each one, instead of only after the slowest "
             "phase has finished for the whole set. Strictly serial: phases 2-6 contend on "
             "the shared pub cache. `--all-revisions` is PINNED ON -- discover and mine each "
             "hold half of it and must agree, and a corpus that takes scopes only from HEAD "
             "is selected on survival.",
    )
    pipeline.add_argument(
        "--dest",
        type=Path,
        default=config.DEFAULT_PIPELINE_DEST,
        help=f"where the corpus is built. Defaults to "
             f"{config.DEFAULT_PIPELINE_DEST.name}/ -- deliberately NOT new_samples/, which "
             f"holds the frozen arm-2 corpus. Building "
             f"elsewhere keeps arm 2 measurable while this one is under construction.",
    )
    pipeline.add_argument(
        "--source",
        type=Path,
        default=None,
        help=f"the mine to screen from. Defaults to {config.SAMPLES_V2.name}/ beside the "
             f"other probe artifacts.",
    )
    pipeline.add_argument(
        "--max-commits",
        type=int,
        default=pipeline_module_default("DEFAULT_MAX_COMMITS"),
        help="per-repository commit ceiling for the walk. The runbook's value, and the "
             "correction that followed a repository owning 10.8 h of a round.",
    )
    selection = pipeline.add_mutually_exclusive_group()
    selection.add_argument(
        "--new",
        dest="mode",
        action="store_const",
        const="new",
        help="drive repositories the ledger has no settled verdict for: never driven, "
             "interrupted before a verdict, or decided under a rule set or value table "
             "that is no longer in force. The default, and the selection that makes a "
             "wider harvest cheap -- only what is new is walked.",
    )
    selection.add_argument(
        "--eligible",
        dest="mode",
        action="store_const",
        const="eligible",
        help="drive only the repositories that produced at least one eligible contrast. "
             "The rebuild selection: on this harvest most repositories screen out, and "
             "re-walking them to rebuild the corpus buys nothing.",
    )
    selection.add_argument(
        "--ignore-ledger",
        dest="mode",
        action="store_const",
        const="all",
        help="drive every selected repository whatever the ledger says.",
    )
    # `--since` comes from the `windowed` parent, whose default is None because `discover`,
    # `mine` and `isolate` each treat the window as opt-in. The pipeline does not: its
    # constants are the runbook's round-4 defaults, kept in `pipeline.py` "so the pipeline and
    # the documented batch sequence cannot drift into building different corpora". They had
    # drifted -- `--max-commits` read DEFAULT_MAX_COMMITS above while `--since` silently took
    # the parent's None, so a pipeline run walked ALL history and DEFAULT_SINCE was dead code.
    # `set_defaults` beats a parent's argument-level default, and an explicit `--since` on the
    # command line still beats this.
    pipeline.set_defaults(mode="new", resume=True,
                          since=pipeline_module_default("DEFAULT_SINCE"))
    pipeline.add_argument(
        "--no-resume",
        dest="resume",
        action="store_false",
        help="re-run every phase of each repository from scratch. `--resume` is ON by "
             "default here, unlike the individual phases: the ledger already decides which "
             "repositories to drive, so within one, replaying a half-finished walk is "
             "always what is wanted. Turn it off after changing the extractor build.",
    )
    pipeline.add_argument(
        "--stop-after",
        type=int,
        default=None,
        metavar="N",
        help="stop once N repositories have reached a verdict. For getting a measurable "
             "corpus in front of the device without waiting for the whole harvest.",
    )
    pipeline.add_argument(
        "--jobs",
        type=int,
        default=1,
        metavar="N",
        help="how many repositories to take through the phases together (default 1). N is "
             "handed to each PHASE, whose own sweep owns the concurrency -- the batch is "
             "never threaded here, because every phase rewrites a corpus-wide aggregate in "
             "full when it finishes. `pub get` resolutions serialise on a process-wide lock "
             "whatever N is, and a dependency verdict reached under N > 1 is re-driven "
             "serially at the end rather than settled.",
    )
    pipeline.add_argument(
        "--order",
        choices=("cheapest", "candidates"),
        default="cheapest",
        help="which repository the walk takes next. `cheapest` (the default) sorts by "
             "commits in the mine's own window, read from the clone, so the corpus becomes "
             "measurable early: a batch publishes its groups only when its mine call "
             "returns, and this harvest is skewed hard -- the median repository has 2 "
             "commits and eight hold half the total, so file order can spend hours on one "
             "repository before anything ships. `candidates` keeps data/candidates.jsonl "
             "order. The order is recorded in the run summary because it decides which "
             "repository mints which group id.",
    )
    pipeline.add_argument(
        "--from-scratch",
        action="store_true",
        help="tear down --dest and both generated tables before the walk, so the corpus "
             "grows from EMPTY and everything in it was produced by this mine. Without it "
             "the first screen rewrites the manifests to the newly mined set while "
             "previously exported directories survive as stale, and the tree disagrees with "
             "its own manifests until the walk ends. Refuses over anything authored or "
             "measured at --dest.",
    )
    pipeline.add_argument(
        "--skip-screen",
        action="store_true",
        help="mine only; leave the corpus unbuilt. The screen is then one command over "
             "everything at once, which is the phase-major behaviour.",
    )
    pipeline.add_argument(
        "--screen-arg",
        action="append",
        default=[],
        metavar="ARG",
        help="passed through to screen_samples verbatim, repeatable. For the flags this "
             "wrapper does not model, such as --prune-to-endpoints.",
    )

    subparsers.add_parser(
        "backfill-checkpoints",
        help="Reconstruct per-repository checkpoints from the phase summaries already "
             "on disk, so --resume treats work finished before checkpointing existed "
             "as done. Idempotent; never overwrites an existing checkpoint.",
    )

    subparsers.add_parser(
        "pilot-repos",
        parents=[common],
        help="Print the selected repositories and exit. Touches nothing.",
    )

    args = parser.parse_args(argv)

    # `--all` resolves to an explicit name list, so every phase keeps taking the
    # same argument and the selection is visible in logs rather than implied.
    if getattr(args, "all_repos", False):
        args.repos = [r["repo_name"] for r in config.eligible()]

    # `--exclude` is applied here, once, on the resolved name list -- so every phase gets
    # the same semantics without each re-implementing them, and so the selection that
    # reaches a phase is the selection that was printed.
    excluded = config.resolve_exclusions(getattr(args, "exclude", None))
    if excluded:
        if args.repos is None:
            args.repos = list(config.PILOT_REPOS)
        args.repos, dropped = config.apply_exclusions(args.repos, excluded)
        if dropped:
            print(f"excluding {len(dropped)} repositories: {', '.join(sorted(dropped))}")
        # "Matched" is judged against every repository the harvest knows about, not
        # against what this run happened to select: excluding a corpus repo, or one
        # dropped by an earlier `--repos`, is redundant but correct. Only a name no
        # repository anywhere carries is worth flagging, because that is a typo.
        known = {
            config.normalize_repo_name(r["repo_name"]) for r in config.candidates()
        } | config.corpus_keys()
        unmatched = excluded - known
        if unmatched:
            print(f"UNMATCHED --exclude (nothing selected by that name): "
                  f"{', '.join(sorted(unmatched))}")
        if not args.repos:
            raise SystemExit("every selected repository was excluded - nothing to do")

    if args.phase == "backfill-checkpoints":
        from . import checkpoints as checkpoints_module

        made = checkpoints_module.backfill()
        for phase, count in made.items():
            print(f"{phase:10s} {count} checkpoints written "
                  f"-> {checkpoints_module.directory(phase).relative_to(config.PROJECT_ROOT)}")
        if not any(made.values()):
            print("nothing to backfill - every phase summary is already checkpointed")
        return 0

    if args.phase == "pilot-repos":
        for repo in config.selected(args.repos):
            print(f"{repo['repo_name']:50s} stars={repo['stars']:6d} {repo['repo_url']}")
        return 0

    if args.phase == "clone":
        from . import clone as clone_phase

        summary = clone_phase.run(args.repos, force=args.force)
        return 0 if not summary["failed"] else 1

    if args.phase == "prepare":
        from . import prepare as prepare_phase

        summary = prepare_phase.run(args.repos, jobs=args.jobs,
                                    resume=args.resume, retry_failed=args.retry_failed)
        return 0 if summary["clean"] else 1

    if args.phase == "discover":
        from . import discover as discover_phase

        discover_phase.run(args.repos, jobs=args.jobs, only_clean=args.only_clean,
                           resume=args.resume, retry_failed=args.retry_failed,
                           all_revisions=args.all_revisions,
                           since=config.parse_since(args.since))
        return 0

    if args.phase == "mine":
        from . import mine as mine_phase

        mine_phase.run(
            args.repos,
            max_commits=args.max_commits,
            isolate_code=args.isolate,
            jobs=args.jobs,
            resume=args.resume,
            retry_failed=args.retry_failed,
            all_revisions=args.all_revisions,
            since=config.parse_since(args.since),
        )
        return 0

    if args.phase == "isolate":
        from . import isolate as isolate_phase

        isolate_phase.run(
            args.repos,
            only_clean=not args.include_unprepared,
            check=not args.no_check,
            history=args.history,
            max_commits=args.max_commits,
            resume=args.resume,
            retry_failed=args.retry_failed,
            all_revisions=args.all_revisions,
        )
        return 0

    if args.phase == "license-provenance":
        from . import license_provenance

        summary = license_provenance.run(args.repos, spm=args.spm, resume=args.resume)
        print(json.dumps(summary, indent=1))
        # A mismatched row is not a warning to scroll past: it means this pass wrote a
        # different file than the corpus ships, so its package list describes something
        # else. R17 already refuses such a row; saying so here is what stops a run being
        # read as complete when it is not.
        if summary["not_identical"]:
            print(f"\nWARNING: {summary['not_identical']} of {summary['rows_total']} rows "
                  f"did NOT reproduce the shipped transplant byte for byte. R17 treats "
                  f"every one of them as unattributed and fires. Look at them before "
                  f"screening.")
        return 0

    if args.phase == "pipeline":
        from . import pipeline as pipeline_phase

        names = [r["repo_name"] for r in config.selected(args.repos)]
        todo = pipeline_phase.select(names, mode=args.mode,
                                     retry_failed=args.retry_failed)
        skipped = len(names) - len(todo)
        if skipped:
            print(f"ledger: skipping {skipped} of {len(names)} repositories "
                  f"({args.mode} selection)")
        if not todo:
            why = {
                "new": "every selected repository already holds a verdict under the "
                       "current rules",
                "eligible": "no selected repository has produced an eligible contrast yet "
                            "- run --new first",
                "all": "no repository was selected",
            }[args.mode]
            print(f"nothing to do - {why}.")
            return 0

        summary = pipeline_phase.run(
            todo,
            dest=args.dest,
            source=args.source,
            max_commits=args.max_commits,
            since=args.since,
            resume=args.resume,
            retry_failed=args.retry_failed,
            skip_screen=args.skip_screen,
            stop_after=args.stop_after,
            screen_args=args.screen_arg,
            jobs=args.jobs,
            from_scratch=args.from_scratch,
            order=args.order,
        )
        return 0 if summary["driven"] else 1

    parser.error(f"unknown phase {args.phase}")
    return 2


if __name__ == "__main__":
    sys.exit(main())
