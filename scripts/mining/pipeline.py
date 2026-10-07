"""Drive one repository end to end, so the corpus grows one repository at a time.

`docs/mining-runbook.md` runs the phases **phase-major**: clone every repository, then prepare
every repository, then discover, then mine, then screen once at the end. Nothing is
measurable until the slowest phase has finished for the *whole* set, and the mine is hours
per repository -- one of them once owned 10.8 h on its own.

This module runs the same phases **repo-major**: one repository is taken from clone to a
screened corpus before the next one starts, so `--dest` holds a complete, internally
consistent corpus after every repository rather than only at the end.

**The corpus does not depend on the order.** Every screening rule is local -- R1 to R13 decide
a pair, R14 and R17 a file or role, R15 a pair, R16 and R18 a group -- so a repository screened
alone gets the verdicts it would get in a batch. The one corpus-wide quantity the screen
reports, the largest contributor's share, is descriptive and admits nothing. `--from-nothing`
at the end of a run is what checks this rather than assumes it.

**`--jobs N` drives N repositories together, and the serialism it replaces was load-bearing.**
Phases 2 to 6 all shell out to `pub get`, which contends on the shared pub cache; contention
surfaces as spurious `unsatisfiable_dependencies` and silently discards repositories that would
otherwise resolve. That is now answered where it happens rather than by the shape of this loop:
`prepare.pub_get_with_conflicts` holds a process-wide lock, so resolutions serialise while the
expensive work -- `spm analyze`, `flutter analyze` -- stays concurrent. A dependency verdict
reached under `N > 1` is treated as PROVISIONAL and re-driven serially at the end of the walk,
because the alternative is a corpus selected on which repository lost a cache race.

**A batch is never threaded here.** Each phase rewrites a corpus-wide aggregate in full when it
finishes -- `mine` reopens `history_pairs.jsonl` with `"w"` -- so two concurrent per-repository
calls would race on that rewrite and lose rows. `N` is handed to each phase, and
`checkpoints.sweep` owns the concurrency: the path they were written and tested for.

    python3 -m scripts.mining pipeline --new --dest new_samples_v3
    python3 -m scripts.mining pipeline --all --dest new_samples --from-scratch --jobs 2

What survives a run is the ledger in `data/collected_repos.db`, not a directory listing: each
repository ends with a stamped verdict saying whether it contributed anything, so a later
harvest drives only what is new and a rebuild drives only what produced contrasts.
"""

from __future__ import annotations

import json
import time
import traceback
from pathlib import Path

from . import checkpoints, config

# The runbook's round-4-onwards defaults, in one place so the pipeline and the documented
# batch sequence cannot drift into building different corpora.
DEFAULT_SINCE = "dart3"
DEFAULT_MAX_COMMITS = 400


# Prepare verdicts a CONCURRENT `pub get` can fabricate: all three are outcomes of the pub
# get / codegen loop, which contends on the shared cache. `broken_source` and
# `missing_untracked_file` are properties of the checkout, cannot be caused by contention,
# and are never re-driven.
CONTENTION_PRONE = frozenset({
    "unsatisfiable_dependencies", "no_progress", "exhausted_rounds",
})


def repo_cost(name: str, *, since: int | None) -> int | None:
    """Commits `mine` would walk in this repository, or None when it cannot be known.

    A proxy, not a promise: `mine` walks the CANDIDATE commits discover found, which is a
    subset. It only has to rank, and over this harvest it ranks well -- the spread it sorts
    on is three orders of magnitude wide.
    """
    import subprocess

    clone = config.REPOS_FULL_ROOT / config.repo_dir_name(name)
    if not clone.is_dir():
        return None                 # nothing cloned yet: no subprocess, no guess
    argv = ["git", "-C", str(clone), "rev-list", "--count"]
    if since is not None:
        argv.append(f"--since={since}")
    argv.append("HEAD")
    try:
        done = subprocess.run(argv, capture_output=True, text=True, timeout=30)
    except Exception:
        return None                 # ranking is an optimisation; never fatal
    if done.returncode != 0:
        return None
    try:
        return int(done.stdout.strip())
    except ValueError:
        return None


def walk_order(names: list[str], *, since: int | None) -> tuple[list[str], dict[str, int]]:
    """`names` cheapest repository first. Returns the order and the costs it knew.

    The walk publishes a batch's groups only when `mine.run()` returns for that batch --
    `merge_groups` folds them into `groups.jsonl` once, at the end -- so until a repository
    finishes, nothing it found is visible to the screen. Order is therefore what decides how
    soon the corpus becomes measurable, and this harvest is savagely skewed: the median
    repository has 2 commits in the window and eight repositories hold half the total. In
    file order a 3625-commit repository can land early and produce nothing for hours.

    Sorted by `(cost, normalized name)`. The name tie-break is not cosmetic: walk order
    decides which repository mints which group id, the duplicate pass keeps the LOWEST id,
    and a run that cannot restate its order cannot reproduce those ids.

    A repository with no clone yet sorts LAST. Its cost is unknown, unknown may mean huge,
    and putting it first is the failure this exists to prevent.
    """
    costs = {n: repo_cost(n, since=since) for n in names}
    known = {n: c for n, c in costs.items() if c is not None}
    return (
        sorted(names, key=lambda n: (costs[n] is None,
                                     costs[n] if costs[n] is not None else 0,
                                     config.normalize_repo_name(n))),
        known,
    )


def describe_order(order: str, ordered: list[str], costs: dict[str, int]) -> list[str]:
    """The startup banner for the walk order, and the expensive tail by name."""
    if order != "cheapest" or not costs:
        return [f"  walk order: {order} ({len(ordered)} repositories)"]
    ranked = sorted(costs.values())
    total = sum(ranked)
    half, run_sum, carry = total / 2, 0, 0
    for value in reversed(ranked):          # how few repositories hold half the cost
        run_sum += value
        carry += 1
        if run_sum >= half:
            break
    lines = [f"  walk order: cheapest-first (median {ranked[len(ranked) // 2]}, "
             f"max {ranked[-1]} commits; {carry} of {len(ranked)} hold half the cost)"]
    tail = [n for n in ordered if n in costs][-4:]
    if tail:
        lines.append("  expensive tail, mined last: "
                     + ", ".join(f"{n} ({costs[n]})" for n in tail))
    unknown = len(ordered) - len(costs)
    if unknown:
        lines.append(f"  {unknown} repository(ies) not cloned yet, driven last")
    return lines


def clear_for_rebuild(dest: Path) -> None:
    """Empty `dest` and both generated tables, so the corpus grows from nothing.

    NOT `screen/rebuild.teardown`, and the difference is the whole point. That one refuses
    over any file at `--dest` that `--source` cannot regenerate, which is right when the two
    describe the SAME mine: a leftover file is then somebody's work. Here the mine is being
    rebuilt, so `--source` legitimately holds different group ids than the corpus last
    exported from -- on 2026-09-06 it called all 45 committed groups authored -- and the
    check answers a question nobody asked.

    The property that actually matters is that nothing UNRECOVERABLE is destroyed, and git
    decides that, not `--source`. A tracked, unmodified corpus is fully recoverable with
    `git checkout`; an uncommitted or untracked file at `--dest` is not, and is refused.

    The measurement guard is kept verbatim: arm 2 is at zero device measurements and a
    rebuild must never be the thing that destroys the first one.
    """
    import shutil
    import subprocess

    from scripts import fixture_values, maximal_branch

    from scripts.screen import rebuild as _rebuild
    measured = _rebuild.measured_under(dest)
    if measured:
        raise SystemExit(
            f"--from-scratch refused: {len(measured)} measurement file(s) for groups under "
            f"{dest} ({measured[0]} ...). A rebuild deletes the corpus, and a rebuilt fixture "
            f"is not the one those rows were measured against; measured rows are not "
            f"rebuildable from the mine.")

    if dest.is_dir():
        try:
            dirty = subprocess.run(
                ["git", "status", "--porcelain", "--untracked-files=all", "--", str(dest)],
                cwd=config.PROJECT_ROOT, capture_output=True, text=True, timeout=60,
            ).stdout.strip()
        except Exception as exc:                 # no git, no way to prove recoverability
            raise SystemExit(
                f"--from-scratch refused: cannot ask git whether {dest} is recoverable "
                f"({exc}). Commit or clear it by hand.") from exc
        if dirty:
            shown = "\n".join(f"    {ln}" for ln in dirty.splitlines()[:10])
            raise SystemExit(
                f"--from-scratch refused: {len(dirty.splitlines())} uncommitted or untracked "
                f"path(s) under {dest}:\n{shown}\n"
                f"  A rebuild deletes the tree, and only what is COMMITTED can be recovered "
                f"from it. Commit the corpus first, or discard the changes with "
                f"`git checkout -- {_rel(dest)}`.")

    print(f"--from-scratch: clearing {dest} and both generated tables", flush=True)
    _rebuild.warn_captures(dest)
    if dest.is_dir():
        shutil.rmtree(dest)
        print(f"  removed corpus            : {_rel(dest)}", flush=True)
    for table in (fixture_values.VALUES_PATH, maximal_branch.TABLE_PATH):
        if table.is_file():
            table.unlink()
            print(f"  removed table             : {_rel(table)}", flush=True)
    # The store is an input under `config/` and survived the rmtree. `place()` restores each
    # group as the export reaches it -- see `rebuild.teardown` for why that is the only place
    # the restore can check it is putting the fixture on the same scope it came off.
    from scripts import authored_fixtures
    owned = authored_fixtures.groups()
    if owned:
        print(f"  authored fixtures kept    : {len(owned)} group(s) "
              f"({', '.join(owned[:10])})", flush=True)


def _batches(names: list[str], size: int):
    """`names` in chunks of `size`, order preserved. A size of 1 yields the serial walk."""
    size = max(1, size)
    for i in range(0, len(names), size):
        yield names[i:i + size]


def _rel(path: Path) -> str:
    """`path` relative to the container, or absolute when it is outside it. Never raises."""
    try:
        return str(path.relative_to(config.PROJECT_ROOT))
    except ValueError:
        return str(path)


def extractor_version() -> str:
    """The `spm` the mine runs under, read from the container's `pubspec.lock`.

    Until the release this read the `spm-publish` checkout that `pubspec.yaml` pointed at by
    path; it is now the pub.dev pin (see the README, "Getting `spm`").
    """
    from .. import spm
    v = spm.version()
    return "unknown" if v == "unknown" else f"spm {v}"


def prepared_repos() -> set[str]:
    """Repositories whose `lib/` resolves, as `prepare` recorded them.

    Read from `prepare`'s own report rather than recomputed, because it is the same gate
    `discover --only-clean` applies: deciding it twice is how the pipeline would come to
    admit a repository that discover then silently drops.
    """
    if not config.PREPARE_REPORT.is_file():
        return set()
    return set(json.loads(config.PREPARE_REPORT.read_text()).get("clean_repos", []))


def discovered_repos() -> set[str]:
    """Repositories with at least one scope in `probe_v2/targets.jsonl`.

    `mine` selects from exactly this file, so a repository absent from it has nothing to
    walk and the pipeline stops there rather than paying for an empty walk.
    """
    if not config.TARGETS.is_file():
        return set()
    return {
        json.loads(line)["project"]
        for line in config.TARGETS.read_text().splitlines()
        if line.strip()
    }


def screen_verdict(dest: Path, repo_name: str) -> tuple[int, int]:
    """`(mover scopes, eligible contrasts)` this repository contributed.

    Taken from the screen's own `by_repository`, which lists only repositories that
    survived -- so an absent repository is a decided zero, not a missing measurement.
    """
    report = dest / "exclusions.json"
    if not report.is_file():
        return (0, 0)
    by_repo = json.loads(report.read_text(encoding="utf-8")).get("by_repository", {})
    row = by_repo.get(repo_name)
    if row is None:
        wanted = config.normalize_repo_name(repo_name)
        row = next(
            (v for k, v in by_repo.items() if config.normalize_repo_name(k) == wanted),
            None,
        )
    if row is None:
        return (0, 0)
    return (row.get("eligible_mover_scopes", 0), row.get("eligible_contrasts", 0))


def assert_tables_isolated(dest: Path) -> None:
    """Refuse to build a second corpus onto arm 2's generated tables.

    `fixture_values` and `maximal_branch` are two of the inputs the arm-2 corpus is a pure
    function of, and a `--full` run WRITES both. Filling this corpus's slots into them would
    move `values_version()`, which `new_samples/exclusions.json` records and a test asserts --
    so arm 2 would fail its own integrity check without a single file under `new_samples/`
    being touched. Refused rather than warned, because the damage is silent and committed.
    """
    from scripts import fixture_values, maximal_branch

    if dest.resolve() == (config.PROJECT_ROOT / "new_samples").resolve():
        return  # rebuilding arm 2 itself: the committed tables ARE its tables

    suffix = dest.name.removeprefix("new_samples_") or dest.name
    clashing = [
        (var, default, f"config/{Path(default).stem}_{suffix}.json")
        for var, path, default in (
            ("SPM_FIXTURE_VALUES", fixture_values.VALUES_PATH, "config/fixture_values.json"),
            ("SPM_MAXIMAL_BRANCH", maximal_branch.TABLE_PATH, "config/maximal_branch.json"),
        )
        if path == config.PROJECT_ROOT / default
    ]
    if clashing:
        lines = "\n".join(f"    export {var}={suggested}"
                           for var, _default, suggested in clashing)
        raise SystemExit(
            f"refusing to build {dest.name} onto arm 2's generated tables.\n"
            f"A --full run WRITES them, which moves values_version() and breaks the digest\n"
            f"new_samples/exclusions.json records -- arm 2 would fail its own integrity check\n"
            f"with nothing under new_samples/ touched. Give this corpus its own tables:\n\n"
            f"{lines}\n\n"
            f"Set them BEFORE the run: both constants are bound at import time."
        )


def _screen(source: Path, dest: Path, *, init: bool, extra: list[str]) -> int:
    """One incremental screen over everything mined so far.

    NOT `--from-nothing`: that drops the verdict cache and tears down every derived table, so
    running it per repository would make each pass cost the whole corpus and the run
    quadratic. It is the acceptance gate at the END of a run, once.

    `--resume` replays finished repositories from their checkpoints, so a pass is exactly the
    work the mine has added. Repositories the mine has not checkpointed are HELD by default,
    never exported -- which is what makes screening mid-run safe.
    """
    from scripts import screen_samples

    argv = ["--source", str(source), "--dest", str(dest), "--records", str(dest),
            "--full", "--markdown"]
    argv += ["--init"] if init else ["--resume"]
    return screen_samples.main(argv + extra)


def seeding_pass() -> bool:
    """Whether the next screen is still the SEEDING pass, read off disk at every call.

    NOT latched on success, which is the 2026-09-06 wedge. `--init` writes the values table
    in phase 0 and the branch table only in phase 4, so a seeding screen that dies in between
    leaves the pair MIXED. A latch cleared only by `rc == 0` then re-offers `--init` to a
    table it created itself, `init_values_table` refuses it, and every batch for the rest of
    the walk dies on that same line -- 35 of them, with the mine running perfectly the whole
    time.

    The two screenable states are the ones the startup guard names: BOTH absent is a first
    run, BOTH present is a resume. Answering from the files is what lets a rolled-back seed
    be retried by the next batch instead of poisoning it.
    """
    from scripts import fixture_values, maximal_branch

    return (not fixture_values.VALUES_PATH.is_file()
            and not maximal_branch.TABLE_PATH.is_file())


def rollback_seed() -> bool:
    """Undo a seeding pass that did not finish, so the pair is BOTH-ABSENT again.

    Returns whether it removed anything.

    The walk is what breaks the invariant the startup guard checks, and this is what keeps it:
    a seeding screen either reaches phase 4 and leaves both tables, or leaves neither.

    Refuses to act once the branch table exists, so it can only ever remove a values table
    written moments ago by the same failed pass -- phase 0's seed, possibly filled by phase 2.
    Both are a pure function of `config/fixture_policy.json` plus the mine, so nothing
    unrecoverable is discarded; the next batch simply seeds again.
    """
    from scripts import fixture_values, maximal_branch

    if maximal_branch.TABLE_PATH.is_file():
        return False                # phase 4 ran: this is a finished pair, not a half seed
    if not fixture_values.VALUES_PATH.is_file():
        return False                # never got as far as phase 0
    fixture_values.VALUES_PATH.unlink()
    print(f"  rolled back the seeded value table: {_rel(fixture_values.VALUES_PATH)} "
          f"(the seeding screen did not reach phase 4; the next batch re-seeds)", flush=True)
    return True


def run(
    repo_names: list[str],
    *,
    dest: Path,
    source: Path | None = None,
    max_commits: int | None = DEFAULT_MAX_COMMITS,
    since: str | None = DEFAULT_SINCE,
    resume: bool = True,
    retry_failed: bool = False,
    skip_screen: bool = False,
    stop_after: int | None = None,
    screen_args: list[str] | None = None,
    jobs: int = 1,
    from_scratch: bool = False,
    order: str = "cheapest",
) -> dict:
    """Drive each repository in turn. Returns the run summary; writes the ledger as it goes.

    `jobs` is how many repositories are taken through the phases together, and is handed
    STRAIGHT to each phase rather than used to thread this loop -- see `drive_batch`.
    """
    from scripts.collector import db
    from scripts.collector.config import DB_PATH
    from scripts import ast_tools, fixture_values, maximal_branch

    from . import clone as clone_phase
    from . import discover as discover_phase
    from . import license_provenance as license_phase
    from . import mine as mine_phase
    from . import prepare as prepare_phase

    source = source or (config.PROBE_DIR / "samples_v2")
    dest = Path(dest)
    assert_tables_isolated(dest)

    since_ts = config.parse_since(since)
    extractor = extractor_version()
    rules_version = ast_tools.rules_version()
    conn = db.init_db(DB_PATH)

    # Before anything reads the tables: a corpus that grows from EMPTY. Without it the first
    # screen rewrites the manifests to the newly mined set while the previously exported
    # directories survive as `stale` -- "reported, never removed without --prune" -- and the
    # tree stops agreeing with its own manifests for the length of the walk. `teardown` is
    # reused rather than an `rm`: it refuses over anything authored or measured, and an
    # un-scripted step is the hand-trim the reproducibility claim exists to exclude.
    if from_scratch:
        clear_for_rebuild(dest)

    # `values_version()` raises on a missing table, which is correct everywhere else and
    # wrong here: on a first run the table is SUPPOSED to be absent, and `--init` is what
    # seeds it. The ledger records the stamp it can see.
    #
    # The two generated tables must AGREE about which run this is, because only two states
    # are screenable: both ABSENT is a first run and wants `--init`, both PRESENT is a
    # resume. The test is presence and not content -- `init_values_table()` seeds `{}\n`
    # and an override table with no decidable binding is legitimately `{}` too, so an EMPTY
    # table is a seeded one. Every mix satisfies neither gate: `init_values_table()` refuses
    # because the values table exists, and `merge_table()` raises because the override table
    # does not.
    #
    # On 2026-09-06 a values table emptied to `{}` beside a DELETED `maximal_branch.json`
    # read as a resume -- `values_version()` hashes `{}` as happily as a filled table -- and
    # the run died in phase 4 of the screen after repository 5, four repositories mined.
    # Refused HERE, before the walk, and only when a screen is actually going to run:
    # `--skip-screen` touches neither table, and mining is exactly what a half-torn-down
    # tree should be free to do first.
    #
    # The walk MAINTAINS this invariant rather than only being checked against it: see
    # `rollback_seed`. A mix reaching this point is therefore one an earlier run or a hand
    # edit left behind, and the remedy depends on which -- so the message offers both.
    values_present = fixture_values.VALUES_PATH.is_file()
    branch_present = maximal_branch.TABLE_PATH.is_file()
    if not skip_screen and values_present != branch_present:
        stray = fixture_values.VALUES_PATH if values_present else maximal_branch.TABLE_PATH
        raise SystemExit(
            f"the generated tables disagree about which run this is:\n"
            f"  {_rel(fixture_values.VALUES_PATH)}: "
            f"{'present' if values_present else 'ABSENT'}\n"
            f"  {_rel(maximal_branch.TABLE_PATH)}: "
            f"{'present' if branch_present else 'ABSENT'}\n"
            f"A screen needs them BOTH absent (a first run, which --init seeds) or BOTH "
            f"present (a resume). This mix takes the resume path and raises in phase 4, "
            f"after the walk has mined for hours.\n"
            f"  If the pair is COMMITTED, restore it with `git checkout -- config/`.\n"
            f"  If it is not -- a from-scratch rebuild, where neither table is in HEAD --\n"
            f"  delete the one that survived with `rm {_rel(stray)}` and let the run seed\n"
            f"  both again; it is a pure function of the policy tables plus the mine.\n"
            f"  Or walk with --skip-screen and rebuild at the end with `screen_samples "
            f"--full --from-nothing`, which tears both tables down itself.")

    try:
        values_version = fixture_values.values_version()
    except Exception:
        values_version = None

    records: list[dict] = []
    deferred: list[str] = []        # dependency verdicts to re-drive serially at the end
    screen_crash_reported = False   # latch: print one traceback, not 224
    started = time.monotonic()
    print(f"pipeline: {len(repo_names)} repositories -> {dest}", flush=True)
    print(f"  extractor={extractor} rules={rules_version} values={values_version}", flush=True)
    print(f"  since={since} ({since_ts}) max_commits={max_commits} jobs={jobs}", flush=True)
    costs: dict[str, int] = {}
    if order == "cheapest":
        repo_names, costs = walk_order(repo_names, since=since_ts)
    for line in describe_order(order, repo_names, costs):
        print(line, flush=True)

    def record(name: str, stage: str, eligible, reason: str, *, t0: float,
               scopes: int = 0, contrasts: int = 0) -> None:
        db.record_pipeline_result(
            conn, name, stage=stage, eligible=eligible, scopes=scopes,
            contrasts=contrasts, reason=reason, rules_version=rules_version,
            values_version=values_version, extractor=extractor,
        )
        records.append({"repo": name, "stage": stage, "eligible": eligible,
                        "reason": reason, "scopes": scopes, "contrasts": contrasts,
                        "seconds": round(time.monotonic() - t0, 1)})
        print(f"  -> {name}: {stage}: {reason} "
              f"(scopes={scopes} contrasts={contrasts} {records[-1]['seconds']}s)", flush=True)

    def report_readiness() -> None:
        """What is measurable NOW, and what is still waiting on a hand-authored value.

        The point of screening per batch is to measure while the walk continues, and
        "shipped" is not the same as "measurable": `fixture_gate` refuses a group carrying an
        unfilled `// TODO: value`, because an unassigned `late` throws at mount. The screen
        reports values awaited over CANDIDATE groups; this reports it over what was shipped.
        """
        from scripts import fixture_gate

        if not dest.is_dir():
            return
        shipped = sorted(d.name for d in dest.iterdir() if d.is_dir() and d.name.isdigit())
        try:
            waiting = sorted(fixture_gate.check_root(dest))
        except Exception:                      # readiness is a report, never a gate here
            return
        line = (f"  corpus now: {len(shipped)} group(s), "
                f"{len(shipped) - len(waiting)} ready to measure")
        if waiting:
            shown = ", ".join(waiting[:6]) + (" ..." if len(waiting) > 6 else "")
            line += f", {len(waiting)} awaiting a value ({shown})"
        print(line, flush=True)

    def drive_batch(batch: list[str], *, workers: int, retry: bool) -> None:
        """One batch of repositories, taken clone -> screen.

        `workers` is the `jobs` each PHASE is given. The batch is never threaded here: every
        phase rewrites a corpus-wide aggregate in full when it finishes -- `mine` reopens
        `history_pairs.jsonl` with "w" -- so two concurrent per-repository calls would race
        on that rewrite and lose rows. `checkpoints.sweep` owns the concurrency instead,
        which is the path the phases were written and tested for.
        """
        nonlocal values_version, screen_crash_reported

        t0 = time.monotonic()
        alive: list[str] = []
        for name in batch:
            try:
                clone_phase.run([name], force=False)
                alive.append(name)
            except SystemExit as exc:
                record(name, "clone", False, f"clone_failed: {exc}", t0=t0)
        if not alive:
            return

        prepare_phase.run(alive, jobs=workers, resume=resume, retry_failed=retry)
        prepared, survivors = prepared_repos(), []
        for name in alive:
            if name in prepared:
                survivors.append(name)
                continue
            record(name, "prepare", False, "prepare_unclean", t0=t0)
            # A verdict a concurrent `pub get` could have FABRICATED is not settled. The
            # pub cache is shared, and contention surfaces as a resolution failure that a
            # serial run would not have hit -- so the corpus would be selected on which
            # repository lost a cache race. Deferred to the serial pass at the end of the
            # walk. Only under `workers > 1`: serially there is no race to blame.
            if workers > 1 and (checkpoints.load("prepare", name) or {}) \
                    .get("status") in CONTENTION_PRONE:
                deferred.append(name)
        alive = survivors
        if not alive:
            return

        discover_phase.run(alive, jobs=workers, only_clean=True, resume=resume,
                           retry_failed=retry, all_revisions=True, since=since_ts)
        discovered, survivors = discovered_repos(), []
        for name in alive:
            if name in discovered:
                survivors.append(name)
            else:
                record(name, "discover", False, "no_scopes", t0=t0)
        alive = survivors
        if not alive:
            return

        mine_phase.run(alive, max_commits=max_commits, isolate_code=True, jobs=workers,
                       resume=resume, retry_failed=retry, all_revisions=True,
                       since=since_ts)
        survivors = []
        for name in alive:
            if checkpoints.load("mine", name) is None:
                record(name, "mine", None, "mine_incomplete", t0=t0)
            else:
                survivors.append(name)
        alive = survivors
        if not alive:
            return

        # R17 can only attribute a package it has a provenance row for, and treats an
        # unattributable file as a hard exclusion -- so this runs before the screen, not
        # after it. It is a no-op for a repository that inlines nothing.
        try:
            license_phase.run(alive, resume=resume)
        except SystemExit as exc:
            for name in alive:
                record(name, "license", None, f"license_provenance_failed: {exc}", t0=t0)
            return

        if skip_screen:
            for name in alive:
                record(name, "mine", None, "mined_not_screened", t0=t0)
            return

        # The screen runs as a library, so its refusals arrive as `SystemExit` rather than a
        # return code, and an uncaught one ends the RUN -- not the batch. That is the wrong
        # granularity for a walk measured in days: on 2026-09-06 R17's vacuity guard fired on
        # repository 5 and would have discarded the remaining 219, every one of whose mining
        # is kept. Caught the way `clone` and `license-provenance` catch theirs. A screen
        # refusal is corpus-wide and so recurs, but each repository is mined and checkpointed
        # on the way past and one final screen builds the corpus.
        #
        # ONE screen per batch, not one per repository: it is a corpus-wide pass over shared
        # state -- both generated tables and every manifest at `--dest` -- so it can neither
        # be threaded nor usefully repeated within a batch. Repositories the mine has not
        # checkpointed are HELD by R9 rather than excluded, which is what makes screening
        # mid-walk safe at all.

        # A screen needs something to screen. `--source` is written by `mine`, and until a
        # repository transplants its first group the directory does not exist at all -- on
        # 2026-09-06 the first 14 repositories of the walk mined nothing shippable and every
        # one of them recorded `screen_refused: 2`, argparse's exit code for
        # "--source is not a directory" with the message itself on a stderr nobody kept.
        # Screening an absent mine is vacuous, so it is skipped rather than attempted.
        if not source.is_dir():
            for name in alive:
                record(name, "mine", None, "nothing_mined_yet", t0=t0)
            return

        init = seeding_pass()
        try:
            rc = _screen(source, dest, init=init, extra=list(screen_args or []))
        except SystemExit as exc:
            # A bare exit CODE, not a message: argparse writes the reason to stderr and
            # raises `SystemExit(2)`, whose str() is "2" -- which told the ledger nothing.
            reason = (f"screen_argv_rejected_{exc}" if str(exc).strip().isdigit()
                      else f"screen_refused: {exc}")
            if init:
                rollback_seed()
            for name in alive:
                record(name, "mine", None, reason, t0=t0)
            return
        except Exception as exc:
            # Same granularity argument as the refusal above, one class wider. A refusal
            # arrives as `SystemExit`; a BUG arrives as an ordinary exception, and on
            # 2026-09-06 a `FileNotFoundError` out of phase 4 walked straight past the
            # `SystemExit` clause and ended the run. Whatever the screen does, the mine is
            # checkpointed on the way past and the final screen is what builds the corpus.
            # Printed in full once, because a reason string is not enough to debug from.
            if not screen_crash_reported:
                screen_crash_reported = True
                traceback.print_exc()
            if init:
                rollback_seed()
            for name in alive:
                record(name, "mine", None, f"screen_failed: {type(exc).__name__}: {exc}",
                       t0=t0)
            return
        if rc != 0:
            if init:
                rollback_seed()
            for name in alive:
                record(name, "mine", None, f"screen_exit_{rc}", t0=t0)
            return
        if init:
            # The seed pass created the table; every later pass resumes onto it, and the
            # stamp only exists now.
            values_version = fixture_values.values_version()

        for name in alive:
            scopes, contrasts = screen_verdict(dest, name)
            record(name, "screen", contrasts > 0, "ok" if contrasts else "all_screened_out",
                   scopes=scopes, contrasts=contrasts, t0=t0)
        report_readiness()

    consumed = 0
    for batch in _batches(repo_names, jobs):
        if stop_after is not None and len(records) >= stop_after:
            print(f"\n--stop-after {stop_after} reached; "
                  f"{len(repo_names) - consumed} left", flush=True)
            break
        first, consumed = consumed + 1, consumed + len(batch)
        head = (f"[{first}/{len(repo_names)}] {batch[0]}" if len(batch) == 1 else
                f"[{first}-{consumed}/{len(repo_names)}] " + ", ".join(batch))
        print(f"\n{'=' * len(head)}\n{head}\n{'=' * len(head)}", flush=True)
        drive_batch(batch, workers=jobs, retry=retry_failed)

    # The serial re-drive. Every verdict deferred above is one a shared pub cache could have
    # fabricated, and a settled verdict is never re-driven -- `--new` skips it forever. This
    # is where those become real: one repository at a time, so there is no contention left to
    # explain the failure, and `retry_failed` so the failed checkpoint is redone rather than
    # resumed straight back to the same answer.
    if deferred:
        again, head = list(deferred), \
            f"re-driving {len(deferred)} dependency verdict(s) serially"
        deferred.clear()
        print(f"\n{'=' * len(head)}\n{head}\n{'=' * len(head)}", flush=True)
        for name in again:
            drive_batch([name], workers=1, retry=True)

    eligible = [r for r in records if r["eligible"]]
    summary = {
        "dest": str(dest),
        "requested": len(repo_names),
        "driven": len(records),
        "eligible_repositories": len(eligible),
        "contrasts": sum(r["contrasts"] for r in records),
        "mover_scopes": sum(r["scopes"] for r in records),
        "extractor": extractor,
        "rules_version": rules_version,
        "values_version": values_version,
        # Walk order decides which repository mints which group id, and the duplicate pass
        # keeps the lowest id -- so the order is part of how this corpus was built, and a
        # rebuild that cannot restate it cannot reproduce the ids.
        "order": order,
        "walk": list(repo_names),
        "seconds": round(time.monotonic() - started, 1),
        "repositories": records,
    }
    print(f"\n{'-' * 60}")
    print(f"driven {summary['driven']}/{summary['requested']} · "
          f"{summary['eligible_repositories']} eligible · "
          f"{summary['contrasts']} contrasts · {summary['mover_scopes']} mover scopes "
          f"· {summary['seconds']}s")
    if not skip_screen:
        print(f"\nthe corpus at {dest} is complete for the repositories above.")
        print("before adopting it, run the acceptance gate ONCE:")
        print(f"  python3 -m scripts.screen_samples --source {source} --dest {dest} \\")
        print(f"      --records {dest} --markdown --full --from-nothing")
    return summary


def select(
    names: list[str],
    *,
    mode: str,
    retry_failed: bool = False,
) -> list[str]:
    """Which of `names` this run should drive, given the ledger.

    `new`      -- no verdict, an interrupted one, or one reached under different rules
    `eligible` -- only repositories that produced contrasts, for a rebuild
    `all`      -- everything selected, ledger ignored
    """
    from scripts.collector import db
    from scripts.collector.config import DB_PATH
    from scripts import ast_tools, fixture_values

    if mode == "all":
        return names

    conn = db.init_db(DB_PATH)
    if mode == "eligible":
        wanted = set(db.eligible_repos(conn))
        return [n for n in names if config.normalize_repo_name(n) in wanted]

    try:
        values_version = fixture_values.values_version()
    except Exception:
        values_version = None
    return db.repos_needing_work(
        conn, names, rules_version=ast_tools.rules_version(),
        values_version=values_version, retry_failed=retry_failed,
    )
