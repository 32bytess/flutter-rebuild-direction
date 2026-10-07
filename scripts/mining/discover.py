"""Phase 3 - which commits could have moved a rebuild scope's features?

The naive filter is "commits that touched the file declaring the scope". It is
wrong, and wrong in a way that biases the result rather than merely shrinking it.

`spm analyze` resolves helper methods and getters through
`element.library.identifier` - any library - and runs a BFS over custom child
widgets, merging each child's `build()` (or its State's `build()`) into the
totals, then that child's helpers, then its grandchildren. A scope's 14 metrics
are therefore a function of a transitive CLOSURE of files. Editing a `MyCard` two
files away moves `treeNonConstWidgetCount`, `helperWidgetCount` and the depth
metrics while the scope's own declaration and file are untouched.

So a file-level filter drops real edits, and drops them hardest in well-composed
codebases where child trees are deepest - understating the yield in a way that
looks exactly like "human edits do not move the features".

This phase asks SPM for the closure (`dependencyFiles`, added for this study) and
selects commits over the union of the seed file and that closure. It also records
how many candidate commits came from the closure ALONE, which is the measurement
that decides whether the extra machinery was necessary at all.

The closure is itself revision-dependent - a refactor moves a widget into another
file - so HEAD's closure is a seed, not the final answer. `mine` re-reads it at
every revision and folds new files back into the watch set.
"""

from __future__ import annotations

import json
import subprocess
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path

from . import checkpoints, config
from .spm_runner import analyze


def git(repo: Path, *args: str, timeout: int = config.GIT_TIMEOUT_S) -> str:
    done = subprocess.run(
        ["git", "-C", str(repo), *args],
        capture_output=True, text=True, timeout=timeout,
    )
    return done.stdout if done.returncode == 0 else ""


def seed_files(repo: Path) -> list[str]:
    """Files whose text mentions a rebuild-scope marker, at HEAD.

    A cheap pre-filter only: SPM decides what is really a rebuild scope. Being
    generous here costs one `analyze`; being strict would silently decide which
    kinds of scope this study can see.
    """
    found: set[str] = set()
    for marker in config.SCOPE_MARKERS:
        output = git(repo, "grep", "-l", "--fixed-strings", marker, "HEAD", "--", "lib")
        for line in output.splitlines():
            # `git grep HEAD` prefixes each path with "HEAD:".
            path = line.split(":", 1)[-1].strip()
            if path.endswith(".dart"):
                found.add(path)
    return sorted(found)


def parse_log(output: str) -> dict[str, dict]:
    """`git log --format=%x00%H%x09%ct%x09%an%x09%s --name-only` -> commits by sha."""
    commits: dict[str, dict] = {}
    for block in output.split("\x00"):
        lines = [line for line in block.splitlines() if line.strip()]
        if not lines:
            continue
        parts = (lines[0].split("\t", 3) + ["", "", ""])[:4]
        commits[parts[0]] = {
            "commit": parts[0],
            "committed_at": int(parts[1]) if parts[1].isdigit() else 0,
            "author": parts[2],
            "subject": parts[3][:200],
            "touched": [line for line in lines[1:] if line.endswith(".dart")],
        }
    return commits


def history_sweep_commits(repo: Path, *, since: int | None = None) -> dict[str, dict]:
    """Every commit that touched a `lib/` Dart file carrying a scope marker AT that commit.

    HEAD's scopes cannot lead the walk to a scope that HEAD does not have. A widget added
    in 2021 and deleted in 2022 leaves no trace in the HEAD checkout, so its files are in
    no scope's closure, so no commit that touched it is ever a candidate, so the walk never
    visits a revision where it exists. Those scopes are not rare - a rebuild scope being
    rewritten out of existence is exactly the kind of human edit this stratum is looking
    for, and selecting only survivors is a survivorship filter on the very population
    being measured.

    This sweeps the whole history instead: every commit touching `lib/**.dart`, kept when
    at least one file it touched contained a marker at that revision. It is a seed for the
    walk, not a claim that a scope exists - `spm analyze` decides that per revision, in
    `mine`. Cost is one `git grep` per commit over a handful of blobs; the expensive part
    stays where it was, in the per-revision analyze that `--max-commits` bounds.
    """
    window = ["--since", str(since)] if since is not None else []
    commits = parse_log(
        git(repo, "log", "--format=%x00%H%x09%ct%x09%an%x09%s", "--name-only",
            *window, "--", "lib")
    )
    markers: list[str] = []
    for marker in config.SCOPE_MARKERS:
        markers += ["-e", marker]

    kept: dict[str, dict] = {}
    for sha, commit in commits.items():
        paths = [p for p in commit["touched"] if p.startswith("lib/")]
        if not paths:
            continue
        # Files deleted BY this commit do not exist at it and simply do not match; the
        # revision before the deletion is a separate commit and is caught on its own.
        if git(repo, "grep", "-l", "--fixed-strings", *markers, sha, "--", *paths).strip():
            kept[sha] = commit
    return kept


def commits_touching(repo: Path, paths: list[str], *,
                     since: int | None = None) -> dict[str, dict]:
    """Every commit that touched any of `paths`, keyed by sha.

    `--follow` is deliberately NOT used: it accepts only one pathspec, and this
    asks about a set. Renames inside the closure are recovered in `mine`, which
    re-reads the closure at each revision.
    """
    if not paths:
        return {}
    # `--since` is applied by git rather than in Python: it prunes the walk itself, which
    # on a repository with a decade of history is most of the cost of asking.
    window = ["--since", str(since)] if since is not None else []
    return parse_log(git(
        repo, "log", "--format=%x00%H%x09%ct%x09%an%x09%s", "--name-only", *window, "--",
        *paths,
    ))


def discover_repo(repo: dict, *, all_revisions: bool = False,
                  since: int | None = None) -> dict:
    name = repo["repo_name"]
    root = config.REPOS_FULL_ROOT / config.repo_dir_name(name)
    record: dict = {"repo_name": name, "path": str(root)}

    if not root.is_dir():
        record["status"] = "missing_clone"
        return record

    seeds = seed_files(root)
    record["seed_files"] = len(seeds)

    # SPM over the repository root, so `filePath` is repo-relative and lines up
    # with git's paths without translation.
    result = analyze([root])
    record["analyze_ok"] = result.ok
    record["files_scanned"] = result.files_scanned
    record["files_skipped"] = result.files_skipped
    record["scopes_found"] = result.scopes_found

    if not result.ok:
        record["status"] = "analyze_failed"
        record["stderr"] = result.stderr[-1000:]
        return record

    scopes = []
    seen_ordinal: dict[str, int] = defaultdict(int)
    for row in result.rows:
        declaring = row["filePath"]
        ordinal = seen_ordinal[f"{declaring}::{row['scopeName']}"]
        seen_ordinal[f"{declaring}::{row['scopeName']}"] += 1

        closure = [f for f in row.get("dependencyFiles", []) if f != declaring]
        watch = sorted({declaring, *row.get("dependencyFiles", [])})

        commits = commits_touching(root, watch, since=since)
        seed_only = commits_touching(root, [declaring], since=since)
        via_closure = sorted(set(commits) - set(seed_only))

        scopes.append({
            "kind": "scope",
            "project": name,
            "scope_key": config.scope_key(name, declaring, row["scopeName"]),
            "declaring_file": declaring,
            "scope_name": row["scopeName"],
            "scope_type": row["scopeType"],
            "ordinal": ordinal,
            "closure_files": closure,
            "closure_size": len(closure),
            "closure_resolved": row.get("closureResolved", 0) == 1,
            "unresolved_dependencies": row.get("unresolvedDependencies", []),
            "watch_set": watch,
            "candidate_commits": len(commits),
            "commits_via_seed_file": len(seed_only),
            "commits_via_closure_only": len(via_closure),
            "commits": sorted(
                commits.values(), key=lambda c: c["committed_at"]
            ),
        })

    # The sweep is a COMMIT seed, not a scope: it says "a rebuild scope may have
    # existed here" and leaves the decision to `mine`, which analyzes each revision.
    # It rides in the scope list because that is what carries commits to the walk,
    # and is filtered back out wherever scopes are counted or tracked.
    if all_revisions:
        already = {c["commit"] for s in scopes for c in s["commits"]}
        sweep = history_sweep_commits(root, since=since)
        extra = [c for sha, c in sweep.items() if sha not in already]
        record["sweep_commits"] = len(sweep)
        record["sweep_commits_new"] = len(extra)
        scopes.append({
            "kind": "history_sweep",
            "project": name,
            "scope_key": config.scope_key(name, "*", "*"),
            "declaring_file": "*",
            "scope_name": "*",
            "scope_type": "*",
            "ordinal": 0,
            "closure_files": [],
            "closure_size": 0,
            "closure_resolved": True,
            "unresolved_dependencies": [],
            "watch_set": [],
            "candidate_commits": len(extra),
            "commits_via_seed_file": 0,
            "commits_via_closure_only": 0,
            "commits": sorted(extra, key=lambda c: c["committed_at"]),
        })

    record["scopes"] = scopes
    record["status"] = "ok"
    scopes = [s for s in scopes if s.get("kind") != "history_sweep"]
    record["scopes_kept"] = len(scopes)
    record["scopes_with_broken_closure"] = sum(
        1 for s in scopes if not s["closure_resolved"]
    )
    record["candidate_commits"] = sum(s["candidate_commits"] for s in scopes)
    record["commits_via_closure_only"] = sum(
        s["commits_via_closure_only"] for s in scopes
    )
    return record


def run(repo_names: list[str] | None = None, *, jobs: int = 1,
        only_clean: bool = False, resume: bool = False,
        retry_failed: bool = False, all_revisions: bool = False,
        since: int | None = None) -> dict:
    repos = config.selected(repo_names)

    # Discovery on a repository whose `lib/` does not resolve is wasted work: SPM
    # skips the unresolved files, so it finds a fraction of the scopes and
    # reports a closure that is short by an unknown amount.
    if only_clean and config.PREPARE_REPORT.is_file():
        clean = set(json.loads(config.PREPARE_REPORT.read_text()).get("clean_repos", []))
        before = len(repos)
        repos = [r for r in repos if r["repo_name"] in clean]
        print(f"restricting to prepared repositories: {len(repos)} of {before}")

    config.PROBE_DIR.mkdir(parents=True, exist_ok=True)

    # Scope discovery re-runs `spm analyze` over the whole checkout and then walks the
    # closure of every scope it finds; nothing about that changes unless the checkout
    # does, so a repository with a checkpoint is not re-scanned.
    def discover_and_checkpoint(repo: dict) -> dict:
        record = discover_repo(repo, all_revisions=all_revisions, since=since)
        checkpoints.write("discover", repo["repo_name"], record)
        return record

    def begin(todo: list[dict], workers: int) -> None:
        if workers > 1:
            print(f"discovering across {len(todo)} repositories with {workers} workers",
                  flush=True)

    def started(repo: dict, i: int, total: int) -> None:
        print(f"[{i}/{total}] {repo['repo_name']}", flush=True)

    def finished(repo: dict, record: dict, done: int, total: int, parallel: bool) -> None:
        if parallel:                       # serial already named it in `started`
            print(f"[{done}/{total}] {repo['repo_name']}", flush=True)

    # `targets.jsonl` is rewritten in full every run, so a repository missing from the
    # results loses its scopes entirely -- and `mine` reads that file to decide what to
    # walk. The sweep's carry-forward recovers the ones this run did not touch.
    swept = checkpoints.sweep(
        "discover", repos, discover_and_checkpoint, jobs=jobs, resume=resume,
        retry_failed=retry_failed, on_begin=begin, on_start=started, on_done=finished)
    results = swept.records

    records = []
    with config.TARGETS.open("w") as sink:
        for record in results:
            if record["status"] == "ok":
                share = (
                    record["commits_via_closure_only"] / record["candidate_commits"]
                    if record["candidate_commits"] else 0.0
                )
                print(
                    f"  {record['repo_name']}: scopes={record['scopes_kept']} "
                    f"(broken closure: {record['scopes_with_broken_closure']}) "
                    f"commits={record['candidate_commits']} "
                    f"closure-only={record['commits_via_closure_only']} ({share:.0%})",
                    flush=True,
                )
                for scope in record["scopes"]:
                    sink.write(json.dumps(scope) + "\n")
            else:
                print(f"  {record['repo_name']}: {record['status']}", flush=True)
            records.append({k: v for k, v in record.items() if k != "scopes"})

    total_commits = sum(r.get("candidate_commits", 0) for r in records)
    via_closure = sum(r.get("commits_via_closure_only", 0) for r in records)
    summary = {
        "phase": "discover",
        "all_revisions": all_revisions,
        "since": since,
        "sweep_commits_new": sum(r.get("sweep_commits_new", 0) for r in records),
        "ran_at": datetime.now(timezone.utc).isoformat(),
        "scanned_this_run": swept.this_run,
        "resumed_from_checkpoint": [r["repo_name"] for r in swept.resumed],
        "carried_from_checkpoint": [r["repo_name"] for r in swept.carried],
        "repos": records,
        "scopes_total": sum(r.get("scopes_kept", 0) for r in records),
        "scopes_with_broken_closure": sum(
            r.get("scopes_with_broken_closure", 0) for r in records
        ),
        "workers": swept.workers,
        "candidate_commits": total_commits,
        "commits_via_closure_only": via_closure,
        # The number that justifies (or refutes) closure-based selection. Near
        # zero and the cheap file-level filter can be reinstated for the full run.
        "closure_only_share": round(via_closure / total_commits, 4) if total_commits else None,
    }
    (config.PROBE_DIR / "discover_summary.json").write_text(
        json.dumps(summary, indent=2) + "\n"
    )
    print(
        f"\n{summary['scopes_total']} scopes, {total_commits} candidate commits, "
        f"{via_closure} reachable ONLY through the closure "
        f"({summary['closure_only_share']:.1%})"
        if total_commits else "\nno candidate commits"
    )
    print(f"wrote {config.TARGETS.relative_to(config.PROJECT_ROOT)}")
    return summary
