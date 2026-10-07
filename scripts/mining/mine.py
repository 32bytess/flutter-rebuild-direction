"""Phase 4 - walk each scope's candidate commits and pair consecutive revisions.

One worktree per repository, walked oldest commit first. `.dart_tool/` and
generated sources are gitignored, so they survive `git checkout` and are reused;
`pub get` and codegen re-run only when the pubspec changes between commits, which
consecutive commits almost never do. That is what makes walking hundreds of
revisions affordable rather than ruinous.

**The resolution gate is SPM's own skipped count, not `flutter analyze`.** They
agree - on `fluent-reader-lite`, `flutter analyze` reported errors in exactly the
22 lib files SPM skipped - and SPM's opinion is the one that decides the metrics.
Using it costs one tool run per revision instead of two.

Two rules keep a delta meaning "a human edited this code":

  * A revision whose scope row has `closureResolved == 0` is recorded as
    `skipped_unresolved` and never paired. An incomplete closure at one endpoint
    manufactures a delta out of resolution state - a false positive, which is far
    more expensive than a missed pair.
  * Pairs are consecutive revisions whose `pubspec.yaml`/`pubspec.lock` did not
    change, so one prepared state legitimately covers both endpoints.

The closure is re-read at every revision and folded back into the scope's watch
set, so a closure that grew or moved during history keeps being followed instead
of being frozen at HEAD's shape.

**The walk resumes per COMMIT, not per repository.** Each commit's rows are appended to
`probe_v2/checkpoints/partial/<owner_name>.jsonl` and flushed before the next checkout, so
`--resume` replays them and continues from where the walk stopped; see the journal section
of `checkpoints.py`. The checkpoint written when the repository finishes supersedes the
journal and deletes it.
"""

from __future__ import annotations

import hashlib
import json
import shutil
import subprocess
import threading
import time
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path

from . import checkpoints, config
from .isolate import is_clean, verification, verification_summary
from .spm_runner import analyze

# A walk runs for hours across several worker threads, so every line it prints has to
# say *when* it happened and *which* repository it came from -- otherwise interleaved
# output from `--jobs N` is unreadable and a stalled repository is indistinguishable
# from a slow one. `log` is the only thing in this module that writes to the terminal.
_PRINT_LOCK = threading.Lock()
_RUN_STARTED = time.monotonic()

# Repositories finished / to walk this run. A walk is hours long and every line it
# prints is about one repository, so without this the terminal never says how far
# through the run it is until the very end.
_DONE = 0
_TOTAL = 0


def set_total(total: int) -> None:
    global _DONE, _TOTAL
    _DONE, _TOTAL = 0, total


def mark_done() -> int:
    global _DONE
    with _PRINT_LOCK:
        _DONE += 1
        return _DONE


def elapsed(since: float | None = None) -> str:
    """`1h02m`, `4m37s`, `12s` - whichever unit reads without arithmetic."""
    total = int(time.monotonic() - (since if since is not None else _RUN_STARTED))
    if total >= 3600:
        return f"{total // 3600}h{(total % 3600) // 60:02d}m"
    if total >= 60:
        return f"{total // 60}m{total % 60:02d}s"
    return f"{total}s"


def log(message: str, *, repo: str | None = None) -> None:
    progress = f" {_DONE}/{_TOTAL}" if _TOTAL else ""
    stamp = f"[{elapsed():>6}{progress}]"
    where = f" {short_name(repo):<24.24}" if repo else ""
    with _PRINT_LOCK:
        print(f"{stamp}{where} {message}", flush=True)


def short_name(name: str) -> str:
    """`owner/repo` -> `repo`, which is what distinguishes lines in practice."""
    return name.split("/")[-1]


def git(repo: Path, *args: str, timeout: int = config.GIT_TIMEOUT_S) -> tuple[bool, str]:
    done = subprocess.run(
        ["git", "-C", str(repo), *args], capture_output=True, text=True, timeout=timeout
    )
    return done.returncode == 0, done.stdout


def make_worktree(clone: Path, worktree: Path, commit: str) -> bool:
    """A throwaway checkout, so the prepared clone is never disturbed.

    `prepare` may have written `dependency_overrides` into the clone's pubspec.
    Walking history inside that clone would either fight the dirty file on every
    checkout or silently discard the override; a worktree keeps the two apart.
    """
    if worktree.exists():
        shutil.rmtree(worktree, ignore_errors=True)
    git(clone, "worktree", "prune")
    ok, _ = git(clone, "worktree", "add", "--detach", "--force", str(worktree), commit)
    return ok


def checkout(worktree: Path, commit: str) -> bool:
    ok, _ = git(worktree, "checkout", "--detach", "--force", commit)
    return ok


def pubspec_fingerprint(worktree: Path) -> str:
    parts = []
    for name in ("pubspec.yaml", "pubspec.lock"):
        path = worktree / name
        parts.append(path.read_text(errors="ignore") if path.is_file() else "")
    return str(hash("\x00".join(parts)))


def resolve_worktree(worktree: Path) -> dict:
    """`pub get` plus codegen, reusing prepare's logic including its overrides."""
    from .prepare import pub_get_with_conflicts, run_codegen

    pub = pub_get_with_conflicts(worktree)
    codegen = run_codegen(worktree) if pub["ok"] else {"ran": False, "steps": []}
    return {"pub_get_ok": pub["ok"], "overrides": pub.get("overrides", {}), "codegen": codegen}


def extract_revision(worktree: Path) -> dict:
    """One `spm analyze` over the checkout, keyed by scope identity."""
    result = analyze([worktree])
    rows: dict[str, dict] = {}
    ordinals: dict[str, int] = defaultdict(int)
    for row in result.rows:
        base = f"{row['filePath']}::{row['scopeName']}"
        key = f"{base}#{ordinals[base]}"
        ordinals[base] += 1
        rows[key] = row
    return {
        "ok": result.ok,
        "files_scanned": result.files_scanned,
        "files_skipped": result.files_skipped,
        "rows": rows,
    }


def ordinal_of(row_key: str) -> int:
    """`lib/a.dart::Foo#2` -> 2. The revision-local disambiguator, not an identity."""
    return int(row_key.rsplit("#", 1)[1]) if "#" in row_key else 0


def vector(row: dict, features: list[str]) -> dict:
    out = {}
    for name in features:
        value = row.get(name)
        out[name] = int(value) if isinstance(value, bool) else value
    return out


def load_group_ids() -> dict[str, str]:
    """Scope identity -> group id, from the `isolate` HEAD pass.

    Ids are allocated there and must not be re-derived here: a group id ends up
    in result tables and file names, so two places inventing them independently
    is how a corpus quietly renumbers itself.
    """
    from .isolate import SAMPLES_DIR

    path = SAMPLES_DIR / "groups.jsonl"
    if not path.is_file():
        return {}
    ids = {}
    for line in path.read_text().splitlines():
        if line.strip():
            group = json.loads(line)
            ids[group["identity"]] = group["id"]
    return ids


def mine_repo(repo: dict, scopes: list[dict], *, max_commits: int | None,
              isolate_code: bool = False, all_revisions: bool = False,
              since: int | None = None, resume: bool = False) -> dict:
    name = repo["repo_name"]
    clone = config.REPOS_FULL_ROOT / config.repo_dir_name(name)
    worktree = config.PROBE_DIR / "worktrees" / config.repo_dir_name(name)
    features = config.features_12()

    record: dict = {"repo_name": name, "scopes_tracked": len(scopes)}

    # Every commit any tracked scope cares about, oldest first. One walk serves
    # all of them: re-checking out per scope would multiply the expensive step by
    # the number of scopes sharing a file.
    commits: dict[str, dict] = {}
    for scope in scopes:
        for commit in scope["commits"]:
            commits[commit["commit"]] = commit
    ordered = sorted(commits.values(), key=lambda c: c["committed_at"])

    # Applied here as well as in `discover`, so a walk is bounded by the cutoff even when
    # `targets.jsonl` was written by an older run that had none. Recorded, because a
    # window that is not stated reads as "this is all the history there was".
    if since is not None:
        before = len(ordered)
        ordered = [c for c in ordered if c["committed_at"] >= since]
        record["commits_before_cutoff_dropped"] = before - len(ordered)
        record["since"] = since

    # `discover --all-revisions` adds a `history_sweep` row carrying commits that no
    # HEAD scope points at. It contributes commits to the walk above and nothing else -
    # it is not a scope, and counting or tracking it as one would put a phantom row in
    # every summary.
    scopes = [s for s in scopes if s.get("kind") != "history_sweep"]
    record["scopes_tracked"] = len(scopes)

    record["commits_available"] = len(ordered)
    if max_commits is not None and len(ordered) > max_commits:
        # Capped runs must say so: a truncated walk that reports a yield reads as
        # "this is what history contains" when it is not.
        log(f"CAP: walking the {max_commits} most recent of "
            f"{len(ordered)} commits", repo=name)
        ordered = ordered[-max_commits:]
        record["capped"] = True
    record["commits_walked"] = len(ordered)

    log(f"{len(scopes)} scopes, {len(ordered)} commits to walk"
        + (f" (of {record['commits_available']} available)"
           if record.get("capped") else "")
        + (f", transplanting code" if isolate_code else ""), repo=name)

    if not ordered:
        log("nothing to walk: no commits after filtering", repo=name)
        record["status"] = "worktree_failed"
        return record

    # The commits already walked, from a run that was interrupted before this repository
    # could checkpoint. `checkpoints.read_journal` refuses one written under different
    # arguments, so a replay can only ever extend the same walk.
    header = {"kind": "header", "repo_name": name, "since": since,
              "max_commits": max_commits, "all_revisions": all_revisions,
              "isolate": isolate_code,
              "started_at": datetime.now(timezone.utc).isoformat()}
    replay = checkpoints.read_journal(name, header) if resume else None

    # A replayed walk keeps the worktree it left behind: `.dart_tool/` and the codegen
    # output are the expensive part of a resolution, and `make_worktree` would delete
    # them to rebuild a checkout the loop immediately replaces anyway.
    reusable = bool(replay) and git(worktree, "rev-parse", "HEAD")[0]
    if not reusable and not make_worktree(clone, worktree, ordered[0]["commit"]):
        log(f"FAILED to create worktree from {clone}", repo=name)
        record["status"] = "worktree_failed"
        return record

    features_out: list[dict] = []
    history: dict[str, list[dict]] = defaultdict(list)
    watch: dict[str, set[str]] = {s["scope_key"]: set(s["watch_set"]) for s in scopes}
    by_key = {s["scope_key"]: s for s in scopes}
    # Scope identity used inside a revision is `file::name#ordinal`; the study's
    # identity is `scope_key`. This maps between them and is refreshed per
    # revision, so an ordinal that shifts cannot silently pair two scopes.
    row_key_of = {
        s["scope_key"]: f"{s['declaring_file']}::{s['scope_name']}#{s['ordinal']}"
        for s in scopes
    }

    fingerprint = None
    unresolved = 0
    # Fingerprints whose `pub get` failed. See the same set in `isolate.isolate_history`:
    # a failed resolution adopted as the accepted fingerprint makes every later commit in
    # that pubspec window skip resolution and extract its features against the previous
    # revision's dependency graph.
    failed_fingerprints: set[str] = set()
    started = time.monotonic()

    # Transplanted code, produced in the SAME checkout as the metrics rather than
    # in a second walk. Two walks pay checkout, `pub get` and codegen twice for
    # identical state, and force the code pass to gate on the metrics pass's
    # output instead of just knowing.
    group_ids = load_group_ids() if isolate_code else {}
    last_digest: dict[str, str] = {}
    code_rows: list[dict] = []
    iso_scratch = config.PROBE_DIR / "mine_isolate_scratch" / config.repo_dir_name(name)

    # Scopes first seen mid-history, with `--all-revisions`. Groups minted here, so a
    # scope that HEAD does not have still gets an id, a directory and manifest rows.
    new_groups: list[dict] = []
    minted_ids: set[str] = set()
    # Keys declined for collision, as a SET: the registration check re-runs at every
    # revision, so counting each encounter would report one colliding scope hundreds of
    # times and read as a corpus-wide problem.
    ambiguous_keys: set[str] = set()

    # Counted only to be reported: a walk that yields little for a boring reason
    # (every checkout failed, every pubspec refused to resolve) must not look the
    # same on the terminal as one whose history genuinely holds no edits.
    checkout_failed = 0
    resolutions = 0
    transplanted = 0
    # Of those, the ones spm could analyse without an error. A walk that transplants
    # thousands of files and verifies none of them clean has produced nothing
    # measurable, and that has to be visible while it runs rather than at the end.
    transplanted_clean = 0
    last_beat = time.monotonic()

    # --- replay whatever the interrupted run already walked ------------------
    # Every counter and every collection the loop below appends to is restored here, so
    # the record this repository ends with is the one an uninterrupted walk would have
    # written. `last_digest` matters most: without it the first resumed revision looks
    # like a change for every scope, and `order` -- counted off `code_rows` -- restarts
    # at 1 and writes a second `rev_001_*.dart` into a directory that already has one.
    walked: set[str] = set()
    resumed_from = None
    for entry in replay or []:
        if entry.get("kind") == "scope":
            scope = entry["scope"]
            by_key[scope["scope_key"]] = scope
            row_key_of[scope["scope_key"]] = entry["row_key"]
            watch[scope["scope_key"]] = set(scope["watch_set"])
            continue
        if entry.get("kind") != "commit":
            continue
        walked.add(entry["commit"])
        resumed_from = entry["commit"]
        resolutions += 1 if entry.get("resolved") else 0
        if entry["outcome"] == "checkout_failed":
            checkout_failed += 1
            continue
        if entry["outcome"] == "pubspec_unresolved":
            unresolved += 1
            continue
        for row in entry.get("features") or []:
            features_out.append(row)
            if row["status"] == "extracted":
                history[row["scope_key"]].append(row)
        for row in entry.get("code_rows") or []:
            code_rows.append(row)
            # In journal order, so the last row for a group wins - which is the digest the
            # next revision has to differ from.
            last_digest[row["id"]] = row["content_sha256"]
            if row["status"] == "isolated":
                transplanted += 1
                if is_clean(row):
                    transplanted_clean += 1
        for group in entry.get("new_groups") or []:
            new_groups.append(group)
            minted_ids.add(group["id"])
    if walked:
        log(f"resuming from the journal: {len(walked)} commits already walked, "
            f"{len(ordered) - len(walked)} to go"
            + (" (worktree reused)" if reusable else ""), repo=name)
    # `failed_fingerprints` is deliberately NOT replayed: it is an optimisation, and one
    # re-attempted `pub get` on the first resumed commit costs less than a wrong skip.

    journal = checkpoints.open_journal(name, header, append=bool(walked))

    def journalled(record: dict) -> None:
        """One line per commit, flushed. A crash may lose the line being written and
        nothing before it, which is exactly the guarantee `--resume` needs."""
        if journal is None:
            return
        try:
            journal.write(json.dumps(record) + "\n")
            journal.flush()
        except Exception:
            pass

    for index, commit in enumerate(ordered):
        sha = commit["commit"]
        if sha in walked:
            continue
        # Where this commit's rows start, so the journal line can carry exactly the ones
        # this iteration appends without every append site having to hand them over.
        mark = (len(features_out), len(code_rows), len(new_groups))
        resolved = False
        if not checkout(worktree, sha):
            checkout_failed += 1
            if checkout_failed <= 3:
                log(f"  checkout failed at {sha[:10]}, skipping", repo=name)
            journalled({"kind": "commit", "commit": sha, "index": index,
                        "outcome": "checkout_failed", "resolved": resolved})
            continue

        current = pubspec_fingerprint(worktree)
        if current in failed_fingerprints:
            unresolved += 1
            journalled({"kind": "commit", "commit": sha, "index": index,
                        "outcome": "pubspec_unresolved", "resolved": resolved})
            continue
        if current != fingerprint:
            resolutions += 1
            resolved = True
            log(f"  [{index + 1}/{len(ordered)}] {sha[:10]} pubspec changed - "
                f"pub get + codegen", repo=name)
            resolution = resolve_worktree(worktree)
            if not resolution["pub_get_ok"]:
                # The stale graph goes with the revision. `extract_revision` runs
                # `spm analyze` on the next line, so a `.dart_tool` left over from an
                # earlier pubspec would silently supply the types for a revision that
                # never resolved.
                shutil.rmtree(worktree / ".dart_tool", ignore_errors=True)
                failed_fingerprints.add(current)
                unresolved += 1
                log(f"  [{index + 1}/{len(ordered)}] {sha[:10]} pub get FAILED, "
                    f"revision skipped", repo=name)
                journalled({"kind": "commit", "commit": sha, "index": index,
                            "outcome": "pubspec_unresolved", "resolved": resolved})
                continue
            fingerprint = current

        revision = extract_revision(worktree)

        # identity -> the whole mapping row, not just its path: spm 0.5.2 puts its own
        # verdict on the row (`verified`, `errorCount`, `unresolvedNames`), and that
        # verdict has to reach `code_rows.jsonl` beside the file it describes. A screen
        # cannot recompute it -- see `isolate.verification`.
        isolated_by_identity: dict[str, dict] = {}
        if isolate_code:
            from .isolate import run_isolate

            ok, iso_rows, _ = run_isolate(worktree, iso_scratch)
            if ok or iso_rows:
                iso_rows.sort(key=lambda r: (r["originalPath"], r["nodeType"], r["name"]))
                counters: dict[tuple, int] = {}
                for iso in iso_rows:
                    source = Path(iso["originalPath"])
                    try:
                        relative = source.relative_to(worktree).as_posix()
                    except ValueError:
                        relative = source.name
                    signature = (relative, iso["nodeType"], iso["name"])
                    ordinal = counters.get(signature, 0)
                    counters[signature] = ordinal + 1
                    identity = (
                        f"{name}::{relative}::{iso['nodeType']}::{iso['name']}::{ordinal}"
                    )
                    isolated_by_identity[identity] = iso

        # Every 10 commits, and at least every 30 seconds: on a slow repository a
        # fixed commit stride can go minutes without a line, which is exactly when
        # someone starts wondering whether the run has hung.
        now = time.monotonic()
        if index % 10 == 0 or now - last_beat >= 30:
            last_beat = now
            done = index + 1
            # Rate over the commits THIS process walked. Counting the replayed ones would
            # divide them by time they did not take and report an ETA that never arrives.
            rate = (done - len(walked)) / max(now - started, 0.001)
            remaining = (len(ordered) - done) / rate if rate else 0
            extracted = sum(len(v) for v in history.values())
            log(
                f"  [{done:4d}/{len(ordered)}] {sha[:10]} "
                f"scanned={revision['files_scanned']:4d} "
                f"skipped={revision['files_skipped']:4d} "
                f"rows={len(revision['rows']):4d} "
                f"extracted={extracted:5d}"
                + (f" transplants={transplanted:4d}"
                   f"/{transplanted_clean:4d} clean" if isolate_code else "")
                + f" | {rate * 60:.1f} commits/min, ~{elapsed(now - remaining)} left",
                repo=name,
            )

        # A scope the HEAD pass never saw, standing in this revision. Registering it
        # here costs nothing extra: the `analyze` that would have found it has already
        # run for this checkout. From this commit forward it is tracked like any other,
        # and its earlier revisions are simply not in this walk - it did not exist then.
        if all_revisions:
            known_rows = set(row_key_of.values())
            for row_key, row in revision["rows"].items():
                if row_key in known_rows:
                    continue
                declaring = row["filePath"]
                key = config.scope_key(name, declaring, row["scopeName"])
                if key in by_key:
                    # `scope_key` drops the ordinal, so two scopes of the same name in
                    # one file collide. Tracking the second under the first's key would
                    # interleave two scopes' revisions into one fabricated history, so
                    # it is skipped and counted rather than merged.
                    ambiguous_keys.add(f"{key}#{ordinal_of(row_key)}")
                    continue
                ordinal = ordinal_of(row_key)
                scope = {
                    "kind": "scope_from_walk",
                    "project": name,
                    "scope_key": key,
                    "declaring_file": declaring,
                    "scope_name": row["scopeName"],
                    "scope_type": row["scopeType"],
                    "ordinal": ordinal,
                    "watch_set": sorted({declaring, *row.get("dependencyFiles", [])}),
                    "commits": [],
                    "first_seen_commit": sha,
                    "seen_in_head_pass": False,
                }
                by_key[key] = scope
                row_key_of[key] = row_key
                watch[key] = set(scope["watch_set"])
                journalled({"kind": "scope", "scope": scope, "row_key": row_key})

        for scope_key, row_key in list(row_key_of.items()):
            row = revision["rows"].get(row_key)
            entry = {
                "scope_key": scope_key,
                "commit": sha,
                "committed_at": commit["committed_at"],
                "author": commit["author"],
                "subject": commit["subject"],
            }
            if row is None:
                entry["status"] = "scope_absent"
                features_out.append(entry)
                continue
            if row.get("closureResolved", 0) != 1:
                # Recorded, never paired: "history contains no edit here" and
                # "this revision would not resolve" must stay distinguishable.
                entry["status"] = "skipped_unresolved"
                entry["unresolved_dependencies"] = row.get("unresolvedDependencies", [])[:10]
                features_out.append(entry)
                continue

            entry["status"] = "extracted"
            entry.update(vector(row, features))
            entry["dependency_files"] = row.get("dependencyFiles", [])
            features_out.append(entry)
            history[scope_key].append(entry)

            # Only a revision whose metrics are trustworthy gets its code kept:
            # the two artefacts describe the same checkout, so they must agree
            # about which revisions count.
            if isolate_code:
                scope = by_key[scope_key]
                identity = (
                    f"{name}::{scope['declaring_file']}::{scope['scope_type']}"
                    f"::{scope['scope_name']}::{scope['ordinal']}"
                )
                iso_row = isolated_by_identity.get(identity) or {}
                source_file = Path(iso_row["isolatedPath"]) if iso_row else None
                group_id = group_ids.get(identity)
                if group_id is None:
                    # First time this scope has been transplanted anywhere, for either
                    # of two reasons: it was never in the HEAD checkout, or `isolate`
                    # was never run. Both are legitimate - a corpus that takes every
                    # revision on equal footing has no reason to pay for a HEAD pass
                    # whose only privilege is being last - so the id is minted here,
                    # from the same map and under the same lock `isolate` uses.
                    from .isolate import allocate_group_id

                    group_id = allocate_group_id(identity)
                    group_ids[identity] = group_id
                    scope["group_id"] = group_id
                if source_file and group_id and source_file.is_file():
                    digest = hashlib.sha256(source_file.read_bytes()).hexdigest()
                    if last_digest.get(group_id) != digest:
                        last_digest[group_id] = digest
                        order = sum(
                            1 for c in code_rows
                            if c["id"] == group_id and c["status"] == "isolated"
                        ) + 1
                        from .isolate import SAMPLES_DIR

                        target = (
                            SAMPLES_DIR / group_id / f"rev_{order:03d}_{sha[:8]}.dart"
                        )
                        target.parent.mkdir(parents=True, exist_ok=True)
                        shutil.copyfile(source_file, target)
                        transplanted += 1
                        if is_clean(iso_row):
                            transplanted_clean += 1

                        # NO `base.dart`. Every revision of a scope is one numbered file
                        # named for its commit -- `rev_<order>_<sha8>.dart` -- and none of
                        # them is the reference the others are read against. A base would
                        # have to be some particular commit (HEAD, or the first walked),
                        # and privileging one is exactly what a corpus meant to compare
                        # revisions against each other must not do.
                        #
                        # The group record is still written once, at the first revision
                        # that produces a file, because that is when the group starts to
                        # exist on disk.
                        if group_id not in minted_ids:
                            minted_ids.add(group_id)
                            # Capped: a big repository mints hundreds of groups, and a
                            # line each would bury the progress it is printed beside.
                            if len(minted_ids) <= 10:
                                log(f"  group {group_id} <- {scope['scope_name']} "
                                    f"({scope['declaring_file']})", repo=name)
                            elif len(minted_ids) == 11:
                                log("  (further new groups not listed individually)",
                                    repo=name)
                            new_groups.append({
                                "id": group_id,
                                "identity": identity,
                                "project": name,
                                "scope_type": scope["scope_type"],
                                "commit_sha": sha,
                                "blob_sha": git(
                                    worktree, "rev-parse",
                                    f"{sha}:{scope['declaring_file']}"
                                )[1].strip() or None,
                                "source_sha256": digest,
                                "committed_at": commit["committed_at"],
                                "dirty_worktree": False,
                                "dirty_lib": False,
                                "repo_url": repo.get("repo_url"),
                                "scope_name": scope["scope_name"],
                                "source_file_relative": scope["declaring_file"],
                                "source_file_absolute": str(
                                    worktree / scope["declaring_file"]
                                ),
                                "ordinal": scope["ordinal"],
                                "isolated_at": datetime.now(timezone.utc).isoformat(),
                                # No base: the group is its revisions. `commit_sha` above
                                # is simply the earliest one walked, not a reference point.
                                "base_dart": None,
                                "first_revision": target.name,
                                "first_revision_commit": sha,
                                "discovered_in_walk": True,
                                **verification(iso_row),
                                "seen_in_head_pass": scope.get("kind") != "scope_from_walk",
                            })
                        code_rows.append({
                            "id": group_id, "order": order, "project": name,
                            "scope_type": scope["scope_type"],
                            "scope_name": scope["scope_name"],
                            "commit_sha": sha,
                            "committed_at": commit["committed_at"],
                            "author": commit["author"], "subject": commit["subject"],
                            "content_sha256": digest,
                            "source_file_relative": scope["declaring_file"],
                            "touched_declaring_file":
                                scope["declaring_file"] in commit["touched"],
                            "file": str(target),
                            "bytes": target.stat().st_size,
                            "status": "isolated",
                            # spm's verdict on THIS transplant. `screen_samples` reads it
                            # from here: whether a revision can be an endpoint of a pair
                            # is not derivable from its own source.
                            **verification(iso_row),
                        })
                    else:
                        code_rows.append({
                            "id": group_id, "project": name, "commit_sha": sha,
                            "committed_at": commit["committed_at"],
                            "content_sha256": digest, "status": "unchanged",
                        })
            # The closure moves with the code; follow it rather than freezing it.
            watch[scope_key].update(row.get("dependencyFiles", []))

        journalled({"kind": "commit", "commit": sha, "index": index,
                    "outcome": "walked", "resolved": resolved,
                    "features": features_out[mark[0]:],
                    "code_rows": code_rows[mark[1]:],
                    "new_groups": new_groups[mark[2]:]})

    # --- pair consecutive extracted revisions -------------------------------
    pairs = []
    for scope_key, revisions in history.items():
        scope = by_key[scope_key]
        for before, after in zip(revisions, revisions[1:]):
            deltas = {
                f"d_{name}": (after[name] or 0) - (before[name] or 0)
                for name in features
            }
            pairs.append({
                "pair_id": f"{scope_key}@{before['commit'][:10]}..{after['commit'][:10]}",
                "project": name,
                "scope_key": scope_key,
                "declaring_file": scope["declaring_file"],
                "scope_name": scope["scope_name"],
                "scope_type": scope["scope_type"],
                "before_commit": before["commit"],
                "after_commit": after["commit"],
                "before_at": before["committed_at"],
                "after_at": after["committed_at"],
                "author": after["author"],
                "subject": after["subject"],
                "all_zero_delta": all(v == 0 for v in deltas.values()),
                # Did the edit touch the declaring file at all, or only the
                # closure? A nonzero delta with this False is a change a
                # file-level filter would never have found.
                "touched_declaring_file": scope["declaring_file"]
                in commits[after["commit"]]["touched"],
                **deltas,
            })

    record["revisions_extracted"] = sum(len(v) for v in history.values())
    record["revisions_unresolved"] = sum(
        1 for f in features_out if f["status"] == "skipped_unresolved"
    )
    record["pubspec_unresolved_commits"] = unresolved
    record["scopes_from_walk"] = sum(
        1 for v in by_key.values() if v.get("kind") == "scope_from_walk"
    )
    record["scopes_ambiguous_skipped"] = len(ambiguous_keys)
    record["new_groups"] = new_groups
    record["pairs"] = pairs
    record["features"] = features_out
    record["seconds"] = round(time.monotonic() - started, 1)
    record["status"] = "ok"
    record["code_rows"] = code_rows
    record["checkout_failed"] = checkout_failed
    if isolate_code:
        record["transplanted"] = transplanted
        record["transplanted_clean"] = transplanted_clean
    record["pubspec_resolutions"] = resolutions
    if walked:
        # A resumed walk must never read as one continuous run: its wall time, its
        # `commits/min` and the interval between its first and last commit all describe
        # only the part this process did.
        record["resumed_from_commit"] = resumed_from
        record["commits_replayed_from_journal"] = len(walked)

    nonzero = sum(1 for p in pairs if not p["all_zero_delta"])
    log(
        f"finished in {elapsed(started)}: {record['revisions_extracted']} revisions, "
        f"{len(pairs)} pairs ({nonzero} nonzero), "
        f"{record['revisions_unresolved']} unresolved revisions, "
        f"{unresolved} unresolvable pubspec states, "
        f"{checkout_failed} failed checkouts"
        + (f", {transplanted} transplanted files ({transplanted_clean} clean) "
           f"in {len(minted_ids)} new groups"
           if isolate_code else ""),
        repo=name,
    )

    if journal is not None:
        journal.close()
    shutil.rmtree(iso_scratch, ignore_errors=True)
    shutil.rmtree(worktree, ignore_errors=True)
    git(clone, "worktree", "prune")
    return record


def run(repo_names: list[str] | None = None, *, max_commits: int | None = None,
        isolate_code: bool = False, jobs: int = 1, resume: bool = False,
        retry_failed: bool = False, all_revisions: bool = False,
        since: int | None = None) -> dict:
    global _RUN_STARTED
    _RUN_STARTED = time.monotonic()

    if not config.TARGETS.is_file():
        raise SystemExit("run `discover` first - probe_v2/targets.jsonl is missing")

    targets = [json.loads(line) for line in config.TARGETS.read_text().splitlines() if line.strip()]
    by_project: dict[str, list[dict]] = defaultdict(list)
    for scope in targets:
        by_project[scope["project"]].append(scope)

    repos = [r for r in config.selected(repo_names) if r["repo_name"] in by_project]
    (config.PROBE_DIR / "worktrees").mkdir(parents=True, exist_ok=True)

    # Repositories are independent - separate clones, separate worktrees,
    # separate subprocesses - so the walk parallelises cleanly across them. The
    # work is subprocess-bound (`git`, `pub`, `dart`), so threads are enough and
    # avoid pickling the whole target set per worker.
    # A full walk runs for hours. Writing every result only at the end means a
    # crash in the last repository discards all the ones that already succeeded,
    # so each repository checkpoints itself the moment it finishes. The
    # transplanted `.dart` files are already written as the walk goes; this makes
    # the metrics equally durable.
    def walk(repo: dict) -> dict:
        record = mine_repo(
            repo, by_project[repo["repo_name"]], max_commits=max_commits,
            isolate_code=isolate_code, all_revisions=all_revisions, since=since,
            resume=resume,
        )
        checkpoints.write("mine", repo["repo_name"], record)
        # Only now: the checkpoint holds everything the journal did, and a journal left
        # beside a finished repository would be replayed by every later run. This is why
        # the sweep leaves the success checkpoint to `work` rather than writing it itself.
        checkpoints.discard_journal(repo["repo_name"])
        return record

    def begin(todo: list[dict], workers: int) -> None:
        """What this run was actually asked to do, printed before the hours start.

        Counted over the POST-RESUME set, which is why the sweep splits before calling this:
        every one of these flags changes what the corpus ends up containing, so a log that
        does not state them cannot be matched back to the artifact it produced.
        """
        set_total(len(todo))
        total_commits = sum(
            len({c["commit"] for s in by_project[r["repo_name"]] for c in s["commits"]})
            for r in todo
        )
        log(f"mine: {len(todo)} repositories to walk, "
            f"{sum(len(by_project[r['repo_name']]) for r in todo)} scopes tracked, "
            f"~{total_commits} candidate commits")
        log(f"  options: jobs={workers} max_commits={max_commits} "
            f"isolate={isolate_code} all_revisions={all_revisions} "
            f"since={since} resume={resume} retry_failed={retry_failed}")
        if not todo:
            log("  nothing to do - every selected repository is already checkpointed"
                if resume else "  nothing to do - no selected repository has targets")
        elif workers > 1:
            log(f"walking {len(todo)} repositories with {workers} workers")

    def started(repo: dict, i: int, total: int) -> None:
        log(f"=== [{i}/{total}] {repo['repo_name']} ===")

    def finished(repo: dict, record: dict, done_n: int, total: int, parallel: bool) -> None:
        if record.get("status") == "crashed":
            log(f"CRASHED: {record.get('error', ''):.300}", repo=repo["repo_name"])
        done = mark_done()
        log(f"done [{done}/{total} repositories, {total - done} left]",
            repo=repo["repo_name"])

    all_pairs, records, all_code = [], [], []
    # `history_features.jsonl`, `history_pairs.jsonl` and `code_rows.jsonl` are rewritten
    # in full every run, so a repository absent from the results loses every row it ever
    # contributed. That is what makes a `--repos`-scoped re-run destructive without the
    # sweep's carry-forward: it would truncate the whole corpus to the one repository named.
    swept = checkpoints.sweep(
        "mine", repos, walk, jobs=jobs, resume=resume, retry_failed=retry_failed,
        log=log, on_begin=begin, on_start=started, on_done=finished)
    results = swept.records

    with config.HISTORY_FEATURES.open("w") as sink:
        for record in results:
            if record["status"] == "ok":
                for row in record.pop("features"):
                    sink.write(json.dumps(row) + "\n")
                all_pairs.extend(record.pop("pairs"))
                all_code.extend(record.pop("code_rows", []))
            records.append(record)

    # Per-repository roll-up, sorted by yield: the whole point of reading it is to see
    # which repositories carried the run and which contributed nothing, and a repository
    # that failed has to appear here rather than only in the JSON summary.
    log("")
    log(f"per-repository results ({len(records)} repositories):")
    for record in sorted(records, key=lambda r: -r.get("revisions_extracted", 0)):
        if record["status"] != "ok":
            log(f"  {short_name(record['repo_name']):<28.28} {record['status'].upper()}"
                + (f" - {record.get('error', '')[:80]}" if record.get("error") else ""))
            continue
        log(f"  {short_name(record['repo_name']):<28.28} "
            f"commits={record.get('commits_walked', 0):<5d} "
            f"extracted={record['revisions_extracted']:<5d} "
            f"unresolved={record['revisions_unresolved']:<4d} "
            f"scopes={record.get('scopes_tracked', 0):<4d} "
            f"{record['seconds']}s")

    failed = [r for r in records if r["status"] != "ok"]
    if failed:
        log(f"  {len(failed)} repositories did not produce results: "
            + ", ".join(sorted(short_name(r["repo_name"]) for r in failed)))

    # Groups minted during the walk are folded into the manifests before anything reads
    # them. A directory of `.dart` files that no index lists is present to anyone who
    # looks at the corpus and invisible to every tool that reads it.
    minted = [g for record in results for g in (record.get("new_groups") or [])]
    for record in results:
        record.pop("new_groups", None)
    if minted:
        from .isolate import merge_groups

        merge_groups(sorted(minted, key=lambda g: g["id"]))
        log(f"{len(minted)} groups discovered in the walk added to groups.jsonl")

    if isolate_code and all_code:
        from .isolate import SAMPLES_DIR

        path = SAMPLES_DIR / "revisions.jsonl"
        existing = []
        if path.is_file():
            processed = {r["repo_name"] for r in records}
            existing = [
                json.loads(line) for line in path.read_text().splitlines()
                if line.strip() and json.loads(line).get("project") not in processed
            ]
        with path.open("w") as sink:
            for row in sorted(existing + all_code,
                              key=lambda r: (r.get("id", ""), r.get("order", 0))):
                sink.write(json.dumps(row) + "\n")

    with config.HISTORY_PAIRS.open("w") as sink:
        for pair in all_pairs:
            sink.write(json.dumps(pair) + "\n")

    nonzero = [p for p in all_pairs if not p["all_zero_delta"]]
    closure_only = [p for p in nonzero if not p["touched_declaring_file"]]
    summary = {
        "phase": "mine",
        "all_revisions": all_revisions,
        "since": since,
        "commits_before_cutoff_dropped": sum(
            r.get("commits_before_cutoff_dropped", 0) for r in records
        ),
        "scopes_from_walk": sum(r.get("scopes_from_walk", 0) for r in records),
        "scopes_ambiguous_skipped": sum(
            r.get("scopes_ambiguous_skipped", 0) for r in records
        ),
        "groups_minted_in_walk": len(minted),
        "ran_at": datetime.now(timezone.utc).isoformat(),
        "extractor": "spm analyze from the local fix/isolate checkout",
        "max_commits_per_repo": max_commits,
        "scopes_tracked": sum(r.get("scopes_tracked", 0) for r in records),
        "commits_walked": sum(r.get("commits_walked", 0) for r in records),
        "revisions_extracted": sum(r.get("revisions_extracted", 0) for r in records),
        "revisions_unresolved": sum(r.get("revisions_unresolved", 0) for r in records),
        "pairs": len(all_pairs),
        "pairs_with_nonzero_delta": len(nonzero),
        "nonzero_share": round(len(nonzero) / len(all_pairs), 4) if all_pairs else None,
        # Nonzero deltas whose commit never touched the declaring file: pairs a
        # file-level filter could not have found at all.
        "nonzero_via_closure_only": len(closure_only),
        "code": {
            "enabled": isolate_code,
            "distinct_states": sum(1 for c in all_code if c["status"] == "isolated"),
            "unchanged_commits": sum(1 for c in all_code if c["status"] == "unchanged"),
            "groups_with_a_pair": len({
                c["id"] for c in all_code
                if c["status"] == "isolated" and c.get("order", 0) >= 2
            }),
            # spm 0.5.2's verdict on the transplants this run wrote, aggregated. The
            # number that matters is `clean`: `spm analyze` skips a file carrying an
            # error, so an unclean transplant yields no metrics at all, and a pair needs
            # BOTH endpoints clean. `verified` short of `distinct_states` means part of
            # the corpus predates 0.5.2 and its two halves are not comparable.
            "verification": verification_summary(
                [c for c in all_code if c["status"] == "isolated"]
            ),
        } if isolate_code else None,
        "workers": swept.workers,
        "walked_this_run": swept.this_run,
        "resumed_from_checkpoint": [r["repo_name"] for r in swept.resumed],
        "carried_from_checkpoint": [r["repo_name"] for r in swept.carried],
        "repos": records,
    }
    config.MINE_SUMMARY.write_text(json.dumps(summary, indent=2) + "\n")

    log("")
    log(f"=== mine finished in {elapsed()} "
        f"({swept.this_run} repositories walked this run, {len(swept.resumed)} resumed, "
        f"{len(swept.carried)} carried) ===")
    log(f"scopes tracked      {summary['scopes_tracked']}"
        + (f" (+{summary['scopes_from_walk']} first seen mid-history, "
           f"{summary['scopes_ambiguous_skipped']} skipped as ambiguous)"
           if summary["scopes_from_walk"] or summary["scopes_ambiguous_skipped"]
           else ""))
    log(f"commits walked      {summary['commits_walked']}"
        + (f" ({summary['commits_before_cutoff_dropped']} dropped before --since)"
           if summary["commits_before_cutoff_dropped"] else ""))
    log(f"revisions           {summary['revisions_extracted']} extracted, "
        f"{summary['revisions_unresolved']} unresolved")
    log(f"pairs               {summary['pairs']}, "
        f"{summary['pairs_with_nonzero_delta']} with a nonzero delta "
        f"({(summary['nonzero_share'] or 0):.1%}), "
        f"{len(closure_only)} of those reachable only through the closure")
    if isolate_code:
        code = summary["code"]
        log(f"code                {code['distinct_states']} distinct transplanted "
            f"states, {code['unchanged_commits']} commits left them unchanged, "
            f"{code['groups_with_a_pair']} groups have >=2 states")
        check = code["verification"]
        if check["verified"]:
            log(f"transplants verified {check['clean']} of {check['verified']} analyse "
                f"clean ({check['unclean']} carry errors and yield no metrics)"
                + (f", >={check['source_unresolved']} from projects whose own "
                   f"dependencies never resolved (a floor; see "
                   f"`isolate.verification_summary`)"
                   if check["source_unresolved"] else ""))
            if check["verified"] < code["distinct_states"]:
                log(f"  NOTE: {code['distinct_states'] - check['verified']} transplants "
                    f"carry no verification -- they were written by spm <= 0.5.1 and "
                    f"cannot be pooled with the rest")
        elif code["distinct_states"]:
            log("transplants verified  none -- this corpus was written by spm <= 0.5.1")
    for path in (config.HISTORY_PAIRS, config.HISTORY_FEATURES, config.MINE_SUMMARY):
        log(f"wrote               {path.relative_to(config.PROJECT_ROOT)} "
            f"({path.stat().st_size / 1e6:.1f} MB)")
    return summary
