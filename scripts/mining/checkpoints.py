"""Per-repository checkpoints, so every phase resumes instead of restarting.

WHY THIS EXISTS
---------------
`prepare`, `discover`, `isolate` and `mine` all walk repositories independently and all
run for hours. Two failure modes follow from writing their results only at the end:

  * a crash in the last repository discards every repository that already succeeded;
  * a run scoped with `--repos` REWRITES the phase's output file from that subset alone,
    silently truncating the corpus to it. `isolate` already guarded against this for
    `groups.jsonl`; `prepare` and `discover` did not.

A checkpoint written the moment a repository finishes fixes both. It is keyed by
repository directory name, holds that repository's whole record, and is the durable form
of the phase's output -- the summary file is then an aggregate over checkpoints plus
whatever this run added.

WHAT A CHECKPOINT DOES NOT PROMISE
----------------------------------
It records that the walk FINISHED, not that it finished with the same arguments. Resuming
across a change to `--max-commits`, to the rule set, or to the extractor build would
silently mix two different runs, so the phase summaries record which repositories came
from checkpoints and every phase's `--resume` help says to re-run from scratch after such
a change. Matching on arguments instead was considered and rejected: it would make a
checkpoint invalid on any cosmetic flag change, which trains people to delete the
directory rather than trust it.

`--retry-failed` re-runs the repositories whose checkpoint records a non-success status.
That is the honest form of "try again": a failure can be transient (a network hiccup
during `pub get`) or terminal (`broken_source`), and only the operator knows which, so it
is opt-in rather than automatic.

THE JOURNAL, AND WHY A CHECKPOINT IS NOT ENOUGH
-----------------------------------------------
A checkpoint is written when a REPOSITORY finishes, so a repository interrupted mid-walk had
nothing durable at all: its per-revision feature vectors and spm's verdict on each transplant
lived only in `mine_repo`'s locals, and the next `--resume` restarted it from its first commit.
On 2026-08-28 that cost two repositories 32 hours of walking, 1,129 commits between them.

`mine` therefore appends one line per commit to `checkpoints/partial/<owner_name>.jsonl` as it
walks, and `--resume` replays it before continuing. The journal carries exactly what the
checkpoint would have held for those commits -- feature rows, code rows, groups minted, and the
scopes `--all-revisions` registered mid-history -- so a resumed walk produces the same record an
uninterrupted one would.

It is discarded the moment the repository's checkpoint is written: the checkpoint supersedes it,
and a journal left beside a finished repository would be replayed forever.

Its header records the arguments the walk started with and is compared on resume, because the
rule a checkpoint states loosely -- do not resume across a flag change -- has to be enforced
here: replaying commits walked under `--since null-safety` into a `--since dart3` run would put
two windows in one record with nothing to say so.
"""

from __future__ import annotations

from concurrent.futures import ThreadPoolExecutor, as_completed

import json
from pathlib import Path
from typing import NamedTuple

from . import config

# `mine` shipped first and its directory name is already referenced by the runbook, the
# recovery snippet and `screen_samples`, so it keeps the unprefixed name.
DIRS = {
    "mine": "checkpoints",
    "prepare": "checkpoints_prepare",
    "discover": "checkpoints_discover",
    "isolate": "checkpoints_isolate",
}

# What counts as "this repository is done" per phase. Anything else is a failure that
# `--retry-failed` will re-run.
OK_STATUS = {
    "mine": {"ok"},
    "prepare": {"clean"},
    "discover": {"ok"},
    "isolate": {"ok"},
}


def directory(phase: str) -> Path:
    return config.PROBE_DIR / DIRS[phase]


def path_for(phase: str, repo_name: str) -> Path:
    return directory(phase) / f"{config.repo_dir_name(repo_name)}.json"


def write(phase: str, repo_name: str, record: dict) -> None:
    """Persist one repository's record. A checkpoint that cannot be written must never
    fail the walk -- losing the ability to resume is strictly better than losing the run."""
    try:
        path = path_for(phase, repo_name)
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(record) + "\n")
    except Exception:
        pass


def load(phase: str, repo_name: str) -> dict | None:
    path = path_for(phase, repo_name)
    if not path.is_file():
        return None
    try:
        return json.loads(path.read_text())
    except json.JSONDecodeError:
        return None          # a truncated checkpoint costs a re-walk, not a wrong answer


def split(phase: str, repos: list[dict], *, retry_failed: bool = False
          ) -> tuple[list[dict], list[dict]]:
    """Partition repositories into (already-done records, still-to-do repos)."""
    ok = OK_STATUS[phase]
    done, todo = [], []
    for repo in repos:
        record = load(phase, repo["repo_name"])
        if record is None:
            todo.append(repo)
        elif retry_failed and record.get("status") not in ok:
            todo.append(repo)
        else:
            done.append(record)
    return done, todo


def load_all(phase: str, exclude: set[str] | None = None) -> list[dict]:
    """Every checkpointed record for a phase, optionally minus some repository names.

    This is what lets a `--repos`-scoped run rewrite its summary without truncating it to
    that subset: the repositories this run did not touch are recovered from their own
    checkpoints rather than dropped.
    """
    exclude = exclude or set()
    out = []
    d = directory(phase)
    if not d.is_dir():
        return out
    for path in sorted(d.glob("*.json")):
        try:
            record = json.loads(path.read_text())
        except json.JSONDecodeError:
            continue
        if record.get("repo_name") not in exclude:
            out.append(record)
    return out


# --------------------------------------------------------------------------------------
# The per-commit journal
# --------------------------------------------------------------------------------------

# Inside `checkpoints/` rather than beside it: it belongs to the same phase, and every reader
# of that directory -- `checkpoints.load_all`, `screen_samples.find_checkpoints` -- globs
# `*.json`, which never matches a `.jsonl` one level down.
JOURNAL_SUBDIR = "partial"

# The header fields a resume must agree on. `started_at` and `repo_name` are recorded for the
# reader and deliberately not compared.
JOURNAL_FLAGS = ("since", "max_commits", "all_revisions", "isolate")


def journal_path(repo_name: str) -> Path:
    return directory("mine") / JOURNAL_SUBDIR / f"{config.repo_dir_name(repo_name)}.jsonl"


def open_journal(repo_name: str, header: dict, *, append: bool):
    """The sink `mine` appends a line to per commit, or None if it cannot be opened.

    Losing the journal must never fail the walk, for the same reason losing a checkpoint
    must not: the walk's output is worth more than its resumability.
    """
    try:
        path = journal_path(repo_name)
        path.parent.mkdir(parents=True, exist_ok=True)
        handle = path.open("a" if append else "w")
        if not append:
            handle.write(json.dumps(header) + "\n")
            handle.flush()
        return handle
    except Exception:
        return None


def read_journal(repo_name: str, header: dict) -> list[dict] | None:
    """Every record after the header, or None when there is nothing safe to replay.

    None covers three cases that must not be confused with an empty journal: no journal,
    a journal whose header disagrees with this run's arguments, and one whose header is
    unreadable. All three mean "walk this repository from its first commit".

    The final line is allowed to be truncated -- the process was killed mid-write, which is
    the case this whole mechanism exists for -- and is dropped rather than fatal.
    """
    path = journal_path(repo_name)
    if not path.is_file():
        return None
    lines = path.read_text(errors="replace").splitlines()
    if not lines:
        return None
    try:
        written = json.loads(lines[0])
    except json.JSONDecodeError:
        return None
    if written.get("kind") != "header":
        return None
    differing = [k for k in JOURNAL_FLAGS if written.get(k) != header.get(k)]
    if differing:
        print(f"journal for {repo_name} was written with a different "
              f"{', '.join(differing)} - walking it from the start instead", flush=True)
        return None
    records = []
    for index, line in enumerate(lines[1:], start=2):
        if not line.strip():
            continue
        try:
            records.append(json.loads(line))
        except json.JSONDecodeError:
            # Only the last line can legitimately be half-written; anything earlier means
            # the file is not what it claims, and replaying past the gap would silently
            # drop a commit's rows while still marking it walked.
            if index != len(lines):          # `index` counts the header, so this is the last line
                print(f"journal for {repo_name} is corrupt at line {index} - "
                      f"walking it from the start instead", flush=True)
                return None
    return records


def discard_journal(repo_name: str) -> None:
    """Called once the repository's checkpoint is written, which supersedes it."""
    try:
        journal_path(repo_name).unlink(missing_ok=True)
    except Exception:
        pass


def announce(phase: str, resumed: list[dict], todo: list[dict], *, retry_failed: bool) -> None:
    if not resumed:
        return
    note = " (failed ones will be retried)" if retry_failed else ""
    print(f"resuming {phase}: {len(resumed)} repositories already done, "
          f"{len(todo)} to go{note}", flush=True)


# --------------------------------------------------------------------------------------
# Backfill
# --------------------------------------------------------------------------------------

def backfill() -> dict[str, int]:
    """Reconstruct checkpoints for work finished before checkpointing existed.

    Without this, `--resume` is worthless on the corpus that exists today: `prepare`,
    `discover` and `isolate` all completed for round 2 and left only their aggregate
    summary files, so the first resumed run would re-do every repository and arrive at the
    same answer hours later.

    Each phase's summary already carries a per-repository record; the rows those records
    dropped are recovered from the phase's own output file, keyed the way that file keys
    them. Nothing is invented -- a phase with no summary is skipped, and a repository the
    summary does not mention gets no checkpoint and will simply be walked.

    `mine` is absent because it has checkpointed since it was written; its directory is
    the original.
    """
    made: dict[str, int] = {}

    # ---- prepare: the report already holds the whole per-repository record ------------
    if config.PREPARE_REPORT.is_file():
        report = json.loads(config.PREPARE_REPORT.read_text())
        n = 0
        for record in report.get("repos") or []:
            if record.get("repo_name") and not path_for("prepare", record["repo_name"]).is_file():
                write("prepare", record["repo_name"], record)
                n += 1
        made["prepare"] = n

    # ---- discover: summary rows minus `scopes`, which live in targets.jsonl -----------
    summary_path = config.PROBE_DIR / "discover_summary.json"
    if summary_path.is_file():
        scopes_by_project: dict[str, list[dict]] = {}
        if config.TARGETS.is_file():
            for line in config.TARGETS.read_text().splitlines():
                if line.strip():
                    scope = json.loads(line)
                    scopes_by_project.setdefault(scope["project"], []).append(scope)
        n = 0
        for record in json.loads(summary_path.read_text()).get("repos") or []:
            name = record.get("repo_name")
            if not name or path_for("discover", name).is_file():
                continue
            record = dict(record)
            record["scopes"] = scopes_by_project.get(name, [])
            write("discover", name, record)
            n += 1
        made["discover"] = n

    # ---- isolate: summary rows minus `groups`, which live in groups.jsonl -------------
    summary_path = config.PROBE_DIR / "isolate_summary.json"
    if summary_path.is_file():
        from .isolate import SAMPLES_DIR

        groups_by_project: dict[str, list[dict]] = {}
        groups_file = SAMPLES_DIR / "groups.jsonl"
        if groups_file.is_file():
            for line in groups_file.read_text().splitlines():
                if line.strip():
                    group = json.loads(line)
                    groups_by_project.setdefault(group["project"], []).append(group)
        n = 0
        for record in json.loads(summary_path.read_text()).get("repos") or []:
            name = record.get("repo_name")
            if not name or path_for("isolate", name).is_file():
                continue
            record = dict(record)
            groups = groups_by_project.get(name, [])
            # A repository the summary called ok but whose groups are no longer in the
            # manifest is NOT recorded as done: resuming past it would leave the corpus
            # permanently missing those groups with nothing to show why.
            if record.get("status") == "ok" and not groups:
                continue
            record["groups"] = groups
            write("isolate", name, record)
            n += 1
        made["isolate"] = n

    return made


# --------------------------------------------------------------------------------------
# The sweep
# --------------------------------------------------------------------------------------

def plan(phase: str, repos: list[dict], *, jobs: int, resume: bool,
         retry_failed: bool) -> tuple[list[dict], list[dict], int]:
    """(already-done records, still-to-do repos, worker count) for one phase.

    Split out of `sweep` because `mine` states what it is about to do -- repository count,
    scope count, candidate commits, every flag -- BEFORE hours of walking start, and it can
    only count those over the post-resume set.
    """
    resumed: list[dict] = []
    if resume:
        resumed, repos = split(phase, repos, retry_failed=retry_failed)
        announce(phase, resumed, repos, retry_failed=retry_failed)
    workers = max(1, min(jobs, len(repos))) if repos else 1
    return resumed, repos, workers


class SweepResult(NamedTuple):
    """Everything one sweep decided, so a phase summary never has to re-derive it.

    A phase reports where each record came from -- walked now, resumed from this phase's own
    checkpoint, or carried forward from an earlier run -- and how wide the pool was. All four
    are decided inside `sweep`, and returning only `(records, this_run)` meant the three
    phases each referenced locals that no longer existed once the loop moved here. The arity
    is the guard: a caller that has not been updated fails at the unpack rather than at the
    line that reads the missing name, which is minutes into a walk instead of hours.

    `records` is the union -- resumed + walked + carried -- sorted by repository.
    """

    records: list[dict]
    this_run: int
    resumed: list[dict]
    carried: list[dict]
    workers: int


def sweep(phase: str, repos: list[dict], work, *, jobs: int = 1, resume: bool = False,
          retry_failed: bool = False, log=print, on_begin=None, on_start=None,
          on_done=None) -> SweepResult:
    """Walk `repos` for one phase, resumably. Returns a `SweepResult`.

    `prepare`, `discover` and `mine` each wrote this loop out: select, split, announce, size
    a thread pool, run, record a crash rather than sinking the run, then recover from their
    own checkpoints every repository this run did not touch and sort by name. That last step
    is the one worth having in one place -- each phase rewrites a corpus-wide aggregate in
    full, so a repository missing from the results loses every row it ever contributed, and a
    `--repos`-scoped re-run without the carry-forward silently truncates the corpus to the
    one repository named.

    `work(repo) -> record` writes its OWN success checkpoint, exactly as the four copies did.
    That is deliberate: `mine` discards its per-commit journal immediately after writing the
    checkpoint, and the order matters -- a journal discarded first would be lost to a crash
    in between, and one discarded later would be replayed by the next run.

    `isolate` is deliberately NOT a caller. It is serial-only, has no carry-forward, and
    mutates a shared id map inside its loop; routing it through here would need hooks that
    exist for one caller. It keeps using `split`/`announce` directly.

    The reporting hooks, and why there are three of them: `on_begin(todo, workers)` fires
    once after the resume split, because `mine` states its scope and commit counts over the
    post-split set before hours of walking start. `on_start(repo, i, total)` fires only in
    serial mode, where a repository can be named before it runs. `on_done(repo, record,
    done, total, parallel)` fires in both, and carries `parallel` because every phase words
    its progress line differently depending on whether the count is an ordinal or a
    completion tally.
    """
    resumed, todo, workers = plan(phase, repos, jobs=jobs, resume=resume,
                                  retry_failed=retry_failed)
    if on_begin:
        on_begin(todo, workers)

    results: list[dict] = []
    if workers > 1:
        with ThreadPoolExecutor(max_workers=workers) as pool:
            futures = {pool.submit(work, repo): repo for repo in todo}
            for future in as_completed(futures):
                repo = futures[future]
                try:
                    record = future.result()
                except Exception as error:      # one repository must not sink the run
                    record = {"repo_name": repo["repo_name"], "status": "crashed",
                              "error": str(error)[:500]}
                    write(phase, repo["repo_name"], record)
                results.append(record)
                if on_done:
                    on_done(repo, record, len(results), len(todo), True)
    else:
        for i, repo in enumerate(todo, 1):
            if on_start:
                on_start(repo, i, len(todo))
            record = work(repo)
            results.append(record)
            if on_done:
                on_done(repo, record, i, len(todo), False)

    this_run = len(results)
    records = resumed + results

    seen = {r["repo_name"] for r in records}
    carried = load_all(phase, exclude=seen)
    if carried:
        log(f"  carrying {len(carried)} repositories from earlier runs")
    records = records + carried
    # Sorted by repository so the output does not depend on thread completion order, nor on
    # which repositories this particular run happened to walk versus resume.
    records.sort(key=lambda r: r.get("repo_name") or "")
    return SweepResult(records, this_run, resumed, carried, workers)
