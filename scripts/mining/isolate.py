"""Phase 5 (OPTIONAL) - transplant every rebuild scope in the HEAD checkout.

Optional because `mine --isolate --all-revisions` mints a group for every scope it meets,
whether or not this phase ran. Run it when you specifically want HEAD as a reference
snapshot, or when you want files to hand-edit before a multi-hour walk finishes. A corpus
built by `mine` alone has no `base.dart` at all - a group is its numbered revisions, and
none of them is the one the others are read against.


Output mirrors `samples/`, which is the layout the measurement harness and every
downstream notebook already understand:

    samples_v2/
      0001/base.dart          <- the transplanted scope, one group per scope
      0002/base.dart
      sources.jsonl           <- id, project, trigger, source file
      map.jsonl               <- id, nodeType, scope name, isolated path
      groups.jsonl            <- everything, including the provenance below

**No `dependencies.dart`.** In `samples/` that file held enums, fixtures and
shims a human wrote by hand while repairing the transplant. `spm isolate` now
inlines the widget classes and enums it can reach into the single file, so a
group is one file with package imports and nothing else. Whatever it still
cannot supply is left undefined rather than invented - a stub would make the
sample stop being the code the commit contained.

Every group records **project, scope type, and commit sha**, because a
transplanted widget without them is unattributable: the same file path holds
different code at different revisions, and the scope type decides which harness
trigger applies. Two independent fingerprints of the source are stored with it:

  * `commit_sha`  - the revision the repository was on when this was isolated;
  * `blob_sha`    - git's hash of the source file's contents AT that commit,
                    which survives any history rewrite that preserves content;
  * `source_sha256` - a hash of the file as it sat on disk, independent of git
                    entirely, so a rewritten object store is still detectable.

`dirty_worktree` flags a checkout with uncommitted changes. `prepare` writes
`dependency_overrides` into `pubspec.yaml`, so this is normally true and normally
harmless - but a modified file under `lib/` means the transplant may correspond to
no commit at all, which is a finding to resolve rather than a value to record and
forget.

Group ids are stable across runs: an identity is hashed to an id once and kept in
`id_map.json`, so adding repositories later never renumbers what exists.
"""

from __future__ import annotations

import hashlib
import json
import re
import shutil
import subprocess
import threading
from datetime import datetime, timezone
from pathlib import Path

from . import checkpoints, config

SAMPLES_DIR = config.PROBE_DIR / "samples_v2"
ID_MAP = SAMPLES_DIR / "id_map.json"
# `spm isolate` names files "<file>_<type>_<scope>_<n>.dart"; the trailing index
# is a per-run counter, so it is parsed off rather than used as identity.
RUN_INDEX = re.compile(r"_(\d+)\.dart$")

# ---- what `spm isolate` says about its own output (0.5.2+) ------------------------------
# 0.5.2 analyses each file it wrote, in the same process and against a `pubspec.yaml` and
# `.dart_tool/package_config.json` it drops beside them, and folds the result into the
# mapping row. That verdict is the one that decides how much of a transplant is usable:
# `spm analyze` SKIPS any file carrying an error-severity diagnostic, so an unclean
# transplant is not merely imperfect, it is absent from the metrics.
#
# Carried through to every group and revision record rather than recomputed, because
# reproducing it here would mean re-resolving `package:flutter` per file -- and getting a
# DIFFERENT answer, since a local `dart analyze` sees neither spm's package config nor the
# one-library-per-file arrangement it verified under.
VERIFICATION_KEYS = (
    "verified",          # false when the file could not be analysed at all
    "errorCount",        # error-severity diagnostics; 0 is the only measurable value
    "warningCount",
    "topCodes",
    "unresolvedImports",
    "unresolvedNames",
    # Set (to false) only when the SOURCE project's own dependencies never resolved, in
    # which case nothing third-party resolved either and the transplant is shallow by an
    # unknown amount. Distinct from a dirty transplant: the input was wrong, not the output.
    "sourceDependenciesResolved",
    # 0.6.0. `isolate` now carries third-party UI into the file as source instead of
    # standing every package symbol in, and these three say what that cost. Each is
    # OMITTED unless it applies, so absent reads as "this build did not report it" and
    # never as zero, exactly like the keys above.
    "inlinedThirdPartyDeclarations",  # third-party declarations carried into the file
    # The scope hit the per-scope inline budget (200 declarations / 200,000 characters).
    "thirdPartyInlineTruncated",
    # Carrying analysed WORSE than standing in, so spm re-extracted the scope with the
    # package source stood in for and kept that version. Both of these say the same thing
    # about the row: the file describes a smaller tree than the code it came from builds,
    # which is the same footing as `closureResolved: 0` on the analyze side.
    "thirdPartyInlineReverted",
    # 0.7.1. WHOSE code that is -- hosted package name to version, written inside
    # `InlineBudget.take` in the same statement that increments the count above, so the two
    # cannot drift. Omitted when empty and removed alongside the count on revert, so absent
    # keeps reading as "this build did not report it" exactly like its neighbours.
    #
    # The corpus on disk was mined under 0.7.0 and carries none of these, which is why
    # `R17_package_license` reads `config/license_provenance.jsonl` instead. Carrying the key
    # here is what makes that side artifact unnecessary for anything mined from now on.
    "inlinedThirdPartyPackages",
)


def verification(row: dict) -> dict:
    """The verification fields present on a mapping row, and only those.

    A row from spm <= 0.5.1 carries none of them. The keys are therefore OMITTED rather
    than defaulted: absent must keep reading as "this corpus predates verification", never
    as "verified clean" (which would wave every legacy transplant through) and never as
    "unclean" (which would reject every one of them).
    """
    return {key: row[key] for key in VERIFICATION_KEYS if key in row}


def is_clean(row: dict) -> bool | None:
    """True/False when the row was verified, None when this spm build did not verify.

    None is a third answer on purpose; see `verification`.
    """
    if "verified" not in row:
        return None
    if not row.get("verified"):
        return False
    return row.get("errorCount", 0) == 0


def verification_summary(rows: list[dict]) -> dict:
    """Repository-level counts, in the same terms `spm isolate` prints them."""
    verdicts = [is_clean(row) for row in rows]
    return {
        "verified": sum(1 for v in verdicts if v is not None),
        "clean": sum(1 for v in verdicts if v is True),
        "unclean": sum(1 for v in verdicts if v is False),
        "errors": sum(row.get("errorCount", 0) for row in rows if row.get("verified")),
        # A revision spm could not trust its own inputs for. Reported separately because
        # the fix is to re-prepare the checkout, not to drop the scope.
        #
        # A FLOOR, not a count. spm treats an existing `package_config.json` as proof
        # that resolution happened, so in a history walk the flag could only ever fire on
        # the first revision of a broken pubspec window: the synthesised config spm writes
        # there satisfies the check for every revision after it. Corpora mined before the
        # 0.6.0 fix understate this by an unknown amount, and a low number is not evidence
        # of a healthy corpus.
        "source_unresolved": sum(
            1 for row in rows if row.get("sourceDependenciesResolved") is False
        ),
    }


def git(repo: Path, *args: str) -> str | None:
    done = subprocess.run(
        ["git", "-C", str(repo), *args],
        capture_output=True, text=True, timeout=config.GIT_TIMEOUT_S,
    )
    return done.stdout.strip() if done.returncode == 0 else None


def sha256(path: Path) -> str | None:
    if not path.is_file():
        return None
    digest = hashlib.sha256()
    digest.update(path.read_bytes())
    return digest.hexdigest()


def load_id_map() -> dict[str, str]:
    if ID_MAP.is_file():
        return json.loads(ID_MAP.read_text())
    return {}


def assign_id(identity: str, id_map: dict[str, str]) -> str:
    """A stable four-digit id per scope identity, allocated once and reused.

    Ids must not move when repositories are added later: a group id ends up in
    result tables, figures and file names, and renumbering silently invalidates
    every one of them.
    """
    if identity in id_map:
        return id_map[identity]
    used = {int(v) for v in id_map.values() if v.isdigit()}
    next_id = 1
    while next_id in used:
        next_id += 1
    id_map[identity] = f"{next_id:04d}"
    return id_map[identity]


# Group ids are allocated from one file, and `mine --jobs N` allocates from several
# repository walks at once. The walks are threads in one process, so one lock is enough;
# the map is re-read inside it so an id `isolate` allocated meanwhile is not overwritten.
_ID_LOCK = threading.Lock()


def allocate_group_id(identity: str) -> str:
    """A group id for a scope that was NOT present at HEAD.

    `isolate` allocates ids for the scopes it finds in the HEAD checkout. A scope that
    was added and then deleted -- or renamed, or moved -- exists only inside history, so
    the walk is the only place it can ever be seen, and it needs an id at the moment it
    is first seen rather than from a pass that will never see it.

    Same map, same allocator, so an id means the same thing whichever phase minted it.
    """
    with _ID_LOCK:
        id_map = load_id_map()
        group_id = assign_id(identity, id_map)
        SAMPLES_DIR.mkdir(parents=True, exist_ok=True)
        ID_MAP.write_text(json.dumps(id_map, indent=2, sort_keys=True) + "\n")
        return group_id


def merge_groups(new_groups: list[dict]) -> list[dict]:
    """Fold walk-discovered groups into `groups.jsonl` and rewrite the manifests.

    `mine --isolate --all-revisions` materialises groups that `isolate` never saw, so
    without this they would exist as directories on disk and be absent from every index -
    and `screen_samples` enumerates the corpus from the manifests.
    """
    path = SAMPLES_DIR / "groups.jsonl"
    existing = []
    if path.is_file():
        existing = [
            json.loads(line) for line in path.read_text().splitlines() if line.strip()
        ]
    known = {g["id"] for g in existing}
    added = [g for g in new_groups if g["id"] not in known]
    if not added:
        return existing
    merged = sorted(existing + added, key=lambda g: g["id"])
    write_manifests(merged)
    return merged


def write_manifests(all_groups: list[dict]) -> None:
    """`groups.jsonl` is the complete record; `sources`/`map` mirror `samples/` field
    names so existing tooling reads them without translation."""
    with (SAMPLES_DIR / "groups.jsonl").open("w") as sink:
        for group in all_groups:
            sink.write(json.dumps(group) + "\n")

    with (SAMPLES_DIR / "sources.jsonl").open("w") as sink:
        for number, group in enumerate(all_groups, 1):
            sink.write(json.dumps({
                "number": number,
                "id": group["id"],
                "trigger": group["scope_type"],
                "project": group["project"],
                "commit_sha": group["commit_sha"],
                "sourceFile": group["source_file_absolute"],
                "sourceFileRelative": group["source_file_relative"],
            }) + "\n")

    with (SAMPLES_DIR / "map.jsonl").open("w") as sink:
        for number, group in enumerate(all_groups, 1):
            sink.write(json.dumps({
                "number": number,
                "id": group["id"],
                "nodeType": group["scope_type"],
                "project": group["project"],
                "commit_sha": group["commit_sha"],
                "blob_sha": group["blob_sha"],
                "samples_split": group["id"],
                "sourceRepoPath": group["source_file_absolute"],
                "name": group["scope_name"],
            }) + "\n")


def run_isolate(repo_root: Path, out_dir: Path, *, entry: list[str] | None = None,
                cwd: Path | None = None) -> tuple[bool, list[dict], str]:
    """`spm isolate` over one checkout; returns its mapping rows.

    [entry] and [cwd] name the build to run, and default to the container's own dependency.
    That was `spm 0.7.1`, resolved by path from `../spm-publish` since 2026-09-05 because the
    field `R17_package_license` needs was not yet on pub.dev; the release pins 0.7.2 from
    pub.dev, which carries the same field.

    It is NOT the build that mined this corpus: `probe_v2/samples_v2` was written by 0.7.0
    from pub.dev, and 0.7.1 is a different transplant emitter. Nothing here re-mines, and
    `license_provenance` is the one caller that runs spm against those commits again -- it
    proves the substitution sound by comparing the bytes it writes against the ones already
    on disk, rather than by trusting the version.

    Since 0.5.2 each row carries spm's own analysis of the file it names -- see
    `verification`. `out_dir` also receives a `pubspec.yaml` and a `.dart_tool/` that spm
    writes so those files resolve `package:flutter` where they sit, so the directory is
    no longer transplants alone. It is wiped on every call, which is what keeps one
    revision's leftovers out of the next revision's verification pass.
    """
    if out_dir.exists():
        shutil.rmtree(out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    map_path = out_dir / "map.jsonl"

    done = subprocess.run(
        [*(entry or config.SPM_ENTRY), "isolate", "-o", str(out_dir), "-j", str(map_path),
         str(repo_root)],
        capture_output=True, text=True, timeout=config.SPM_TIMEOUT_S,
        cwd=str(cwd or config.SPM_CWD),
    )
    output = done.stdout + done.stderr
    rows = []
    if map_path.is_file():
        for line in map_path.read_text().splitlines():
            if line.strip():
                try:
                    rows.append(json.loads(line))
                except json.JSONDecodeError:
                    pass
    return done.returncode == 0, rows, output[-2000:]


def isolate_repo(repo: dict, scratch: Path, id_map: dict[str, str]) -> dict:
    name = repo["repo_name"]
    root = config.REPOS_FULL_ROOT / config.repo_dir_name(name)
    record: dict = {"repo_name": name, "path": str(root)}

    if not root.is_dir():
        record["status"] = "missing_clone"
        return record

    commit = git(root, "rev-parse", "HEAD")
    dirty = bool(git(root, "status", "--porcelain") or "")
    dirty_lib = any(
        line.split()[-1].startswith("lib/")
        for line in (git(root, "status", "--porcelain") or "").splitlines()
        if line.strip()
    )
    record.update({
        "commit_sha": commit,
        "committed_at": int(git(root, "show", "-s", "--format=%ct", "HEAD") or 0),
        "dirty_worktree": dirty,
        "dirty_lib": dirty_lib,
    })

    ok, rows, output = run_isolate(root, scratch / config.repo_dir_name(name))
    record["isolate_ok"] = ok
    record["scopes_isolated"] = len(rows)
    # spm 0.5.2 analysed what it wrote; how much of it `spm analyze` can actually read is
    # the number that decides whether this repository contributed anything measurable.
    record["verification"] = verification_summary(rows)
    if not ok and not rows:
        record["status"] = "isolate_failed"
        record["stderr"] = output
        return record

    # Deterministic ordinal per (file, type, scope name), so an identity does not
    # depend on the order `spm isolate` happened to emit files in.
    rows.sort(key=lambda r: (r["originalPath"], r["nodeType"], r["name"],
                             int(RUN_INDEX.search(r["isolatedPath"]).group(1))
                             if RUN_INDEX.search(r["isolatedPath"]) else 0))
    counters: dict[tuple, int] = {}
    groups = []

    for row in rows:
        source = Path(row["originalPath"])
        try:
            relative = source.relative_to(root).as_posix()
        except ValueError:
            relative = source.name

        signature = (relative, row["nodeType"], row["name"])
        ordinal = counters.get(signature, 0)
        counters[signature] = ordinal + 1

        identity = f"{name}::{relative}::{row['nodeType']}::{row['name']}::{ordinal}"
        group_id = assign_id(identity, id_map)

        group_dir = SAMPLES_DIR / group_id
        group_dir.mkdir(parents=True, exist_ok=True)
        isolated = Path(row["isolatedPath"])
        base = group_dir / "base.dart"
        if isolated.is_file():
            shutil.copyfile(isolated, base)

        groups.append({
            "id": group_id,
            "identity": identity,
            # The three the study is keyed on.
            "project": name,
            "scope_type": row["nodeType"],
            "commit_sha": commit,
            # Provenance, so any group can be re-derived or falsified.
            "blob_sha": git(root, "rev-parse", f"HEAD:{relative}"),
            "source_sha256": sha256(source),
            "committed_at": record["committed_at"],
            "dirty_worktree": dirty,
            "dirty_lib": dirty_lib,
            "repo_url": repo.get("repo_url"),
            "scope_name": row["name"],
            "source_file_relative": relative,
            "source_file_absolute": str(source),
            "ordinal": ordinal,
            "base_dart": str(base),
            "base_bytes": base.stat().st_size if base.is_file() else 0,
            "isolated_at": datetime.now(timezone.utc).isoformat(),
            # spm's own verdict on this file. Absent on a corpus mined under <= 0.5.1.
            **verification(row),
        })

    record["groups"] = groups
    record["status"] = "ok"
    return record


# `dart analyze` output: "  error - g0001.dart:12:5 - Message - code"
ANALYZE_ROW = re.compile(
    r"^\s*error - (?P<file>g\d+)\.dart:\d+:\d+ - (?P<message>.*?) - (?P<code>\S+)\s*$",
    re.M,
)
UNDEFINED_NAME = re.compile(
    r"Undefined (?:name|class|function) '([^']+)'"
    r"|The (?:function|method|getter|setter) '([^']+)' isn't defined"
)


SELF_CONTAINMENT_NOTE = (
    "Undefined names are expected: the transplant inlines anything that can produce UI "
    "and stands the rest in, so models, services, themes and controllers stay undefined. "
    "In samples/ these were supplied by a hand-written dependencies.dart, which this "
    "layout deliberately omits. Since spm 0.5.2 an unresolved third-party name is stood "
    "in for rather than left dangling, and since 0.6.0 a third-party WIDGET is inlined "
    "with its own tree instead, so the count is smaller than an earlier round's and "
    "reflects what the crawl could not reach at all."
)


def check_self_containment(groups: list[dict]) -> dict:
    """How much of each `base.dart` the transplant could not supply.

    Expected to be non-zero, and not a defect: `spm isolate` inlines widget
    classes and enums, so every model, service, theme and controller type stays
    undefined by design - in `samples/` those were what the hand-written
    `dependencies.dart` provided. Dropping that file is the point here, so the
    cost of dropping it is measured rather than left to be discovered later.

    Counted as DISTINCT undefined names, not diagnostics: the analyzer emits one
    per use site, so occurrence counts mostly measure how often a name is used.

    Analyzed inside the container because the files import `package:flutter`,
    and each in its own library, so repeated `GeneratedWidget` declarations across
    groups do not collide.

    **Since spm 0.5.2 this is normally read rather than recomputed.** `spm isolate`
    analyses every file it writes before it reports, against a `pubspec.yaml` and
    `.dart_tool/package_config.json` it drops beside them, and puts `errorCount` and
    `unresolvedNames` on the mapping row. Those are the numbers to use: they were
    produced under the arrangement the transplant will actually be read in, whereas
    the `dart analyze` below sees a scratch directory whose package resolution is the
    container's, not the source project's, and disagrees for that reason alone.

    The `dart analyze` path is kept for groups carrying no verification, which is any
    group isolated by spm <= 0.5.1. A corpus part-mined across the upgrade therefore
    still gets one number per group; the counts below say how many came from where, so
    a mixed corpus is visible rather than silently pooled.
    """
    # Split first: a group spm already verified is not copied, not analyzed, and not
    # counted against the batch.
    from_spm = [g for g in groups if is_clean(g) is not None]
    for group in from_spm:
        group["analyze_errors"] = group.get("errorCount", 0)
        group["undefined_names"] = sorted(group.get("unresolvedNames", []))
        group["verification_source"] = "spm"

    groups = [g for g in groups if is_clean(g) is None]

    if not groups:
        # The whole batch came from spm 0.5.2+. Skipped rather than run over an empty
        # directory: `dart analyze` costs an SDK start-up and a Flutter resolution to
        # report nothing.
        names: set[str] = set()
        for group in from_spm:
            names.update(group["undefined_names"])
        counts = sorted(g["analyze_errors"] for g in from_spm)
        return {
            "groups_checked": len(from_spm),
            "groups_clean": sum(1 for c in counts if c == 0),
            "verified_by_spm": len(from_spm),
            "verified_by_dart_analyze": 0,
            "distinct_undefined_names": len(names),
            "errors_per_group": {
                "min": counts[0] if counts else 0,
                "median": counts[len(counts) // 2] if counts else 0,
                "max": counts[-1] if counts else 0,
            },
            "note": SELF_CONTAINMENT_NOTE,
        }

    scratch = config.SPM_CWD / ".sample_check"
    if scratch.exists():
        shutil.rmtree(scratch)
    scratch.mkdir(parents=True)
    checked = []
    for group in groups:
        base = Path(group["base_dart"])
        if base.is_file():
            shutil.copyfile(base, scratch / f"g{group['id']}.dart")
            checked.append(group)
    groups = checked

    done = subprocess.run(
        ["dart", "analyze", str(scratch)],
        capture_output=True, text=True, timeout=config.SPM_TIMEOUT_S,
        cwd=str(config.SPM_CWD),
    )
    output = done.stdout + done.stderr

    per_group: dict[str, int] = {}
    names: set[str] = set()
    names_by_group: dict[str, set[str]] = {}
    for match in ANALYZE_ROW.finditer(output):
        group_id = match["file"][1:]
        per_group[group_id] = per_group.get(group_id, 0) + 1
        found = UNDEFINED_NAME.search(match["message"])
        if found:
            name = found.group(1) or found.group(2)
            names.add(name)
            names_by_group.setdefault(group_id, set()).add(name)

    shutil.rmtree(scratch, ignore_errors=True)

    for group in groups:
        group["analyze_errors"] = per_group.get(group["id"], 0)
        group["undefined_names"] = sorted(names_by_group.get(group["id"], set()))
        group["verification_source"] = "dart analyze"

    # Both populations answer the same question, so they are reported together -- with
    # the split kept visible, because only the spm half was measured in the arrangement
    # the file is read in.
    everything = from_spm + groups
    for group in from_spm:
        names.update(group["undefined_names"])
    counts = sorted(g["analyze_errors"] for g in everything)
    return {
        "groups_checked": len(everything),
        "groups_clean": sum(1 for c in counts if c == 0),
        "verified_by_spm": len(from_spm),
        "verified_by_dart_analyze": len(groups),
        "distinct_undefined_names": len(names),
        "errors_per_group": {
            "min": counts[0] if counts else 0,
            "median": counts[len(counts) // 2] if counts else 0,
            "max": counts[-1] if counts else 0,
        },
        "note": SELF_CONTAINMENT_NOTE,
    }


def isolate_history(repo: dict, groups: list[dict], targets: list[dict],
                    scratch: Path, *, max_commits: int | None,
                    gate: dict[str, set[str]] | None,
                    all_revisions: bool = False) -> tuple[list[dict], list[dict]]:
    """The same scopes at every revision that touched them, not just at HEAD.

    A single snapshot per scope is not a stratum of human edits - the deltas this
    study needs are between two revisions of the SAME scope, so each group needs
    its history materialised beside its `base.dart`.

    One worktree per repository, walked oldest commit first, `pub get` and codegen
    re-run only when the pubspec changes. `spm isolate` runs once per revision and
    serves every scope in that repository, rather than once per scope.

    Scopes are matched across revisions by `(source file, node type, scope name,
    ordinal)`, recomputed at each revision. A scope that was renamed or moved
    simply stops matching and its history ends there - recorded as `absent`,
    never guessed at, because silently pairing two different scopes would
    fabricate a delta.
    """
    from .mine import checkout, make_worktree, pubspec_fingerprint, resolve_worktree

    name = repo["repo_name"]
    clone = config.REPOS_FULL_ROOT / config.repo_dir_name(name)
    worktree = config.PROBE_DIR / "worktrees" / config.repo_dir_name(name)

    # Every commit any tracked scope cares about, oldest first. One walk serves
    # them all; walking per scope would re-pay the checkout for shared files.
    commits: dict[str, dict] = {}
    for scope in targets:
        for commit in scope["commits"]:
            commits[commit["commit"]] = commit
    ordered = sorted(commits.values(), key=lambda c: c["committed_at"])

    if max_commits is not None and len(ordered) > max_commits:
        print(
            f"  CAP: {max_commits} most recent of {len(ordered)} commits "
            f"(a truncated walk must not read as a complete one)", flush=True
        )
        ordered = ordered[-max_commits:]

    if not ordered or not make_worktree(clone, worktree, ordered[0]["commit"]):
        return [], []

    # group identity -> the group it belongs to, so a revision's isolate output
    # can be routed back to the right directory.
    by_identity = {g["identity"]: g for g in groups}
    revisions: list[dict] = []
    # Groups for scopes that HEAD does not have, minted as the walk meets them.
    new_groups: list[dict] = []
    minted_ids: set[str] = set()
    fingerprint = None
    # Fingerprints whose `pub get` failed. A failed resolution must never be adopted as
    # the accepted fingerprint, or every later commit carrying the same pubspec compares
    # equal, skips resolution and is isolated against whatever `.dart_tool` happens to be
    # lying in the worktree. Remembering the failure separately keeps that guarantee
    # without re-running `pub get` once per commit across a window that can be hundreds
    # of commits long.
    failed_fingerprints: set[str] = set()
    sequence: dict[str, int] = {}
    # Last transplanted content per group. The walk visits every commit in the
    # repository that touched ANY tracked scope, so most commits leave a given
    # scope byte-identical - measured on `fluent-reader-lite`, 4 of 5 consecutive
    # revisions of one scope were the same file. Writing them all would fill the
    # corpus with duplicates and make every pair built from them zero-delta by
    # construction. Only a changed transplant becomes a new revision; the commits
    # in between are still recorded, as `unchanged`.
    last_digest: dict[str, str] = {}

    for index, commit in enumerate(ordered):
        sha = commit["commit"]
        if not checkout(worktree, sha):
            continue

        current = pubspec_fingerprint(worktree)
        if current in failed_fingerprints:
            revisions.append({
                "project": name, "commit_sha": sha,
                "status": "unresolved_pubspec",
                "committed_at": commit["committed_at"],
            })
            continue
        if current != fingerprint:
            resolution = resolve_worktree(worktree)
            if not resolution["pub_get_ok"]:
                # No package graph means the transplant would inline nothing and
                # the output would be shallow rather than wrong-looking.
                #
                # The stale graph goes with it. Leaving the previous revision's
                # `.dart_tool` in place is what let a later commit resolve against the
                # wrong dependency set, and spm cannot tell the difference: it takes an
                # existing `package_config.json` as proof that resolution happened.
                shutil.rmtree(worktree / ".dart_tool", ignore_errors=True)
                failed_fingerprints.add(current)
                revisions.append({
                    "project": name, "commit_sha": sha,
                    "status": "unresolved_pubspec",
                    "committed_at": commit["committed_at"],
                })
                continue
            fingerprint = current

        ok, rows, _ = run_isolate(worktree, scratch / "history")
        if index % 10 == 0:
            print(
                f"  [{index:4d}/{len(ordered)}] {sha[:10]} isolated {len(rows):3d} scopes",
                flush=True,
            )
        if not ok and not rows:
            revisions.append({
                "project": name, "commit_sha": sha, "status": "isolate_failed",
                "committed_at": commit["committed_at"],
            })
            continue

        rows.sort(key=lambda r: (r["originalPath"], r["nodeType"], r["name"]))
        counters: dict[tuple, int] = {}
        for row in rows:
            source = Path(row["originalPath"])
            try:
                relative = source.relative_to(worktree).as_posix()
            except ValueError:
                relative = source.name
            signature = (relative, row["nodeType"], row["name"])
            ordinal = counters.get(signature, 0)
            counters[signature] = ordinal + 1

            identity = f"{name}::{relative}::{row['nodeType']}::{row['name']}::{ordinal}"
            group = by_identity.get(identity)
            if group is None:
                if not all_revisions:
                    continue  # a scope with no group at HEAD; not tracked
                # With --all-revisions it IS tracked: a scope that was deleted before
                # HEAD is still a rebuild scope a human wrote and later edited, and
                # dropping it selects the corpus on survival.
                group = {
                    "id": allocate_group_id(identity),
                    "identity": identity,
                    "project": name,
                    "scope_type": row["nodeType"],
                    "scope_name": row["name"],
                    "source_file_relative": relative,
                    "seen_in_head_pass": False,
                    "discovered_in_walk": True,
                }
                by_identity[identity] = group

            # `mine` decides which revisions carry trustworthy metrics. When its
            # output is present, only those are materialised - a revision whose
            # closure did not resolve produces a transplant that is quietly
            # shallower than the code it claims to be.
            if gate is not None and sha not in gate.get(group["id"], set()):
                continue

            isolated = Path(row["isolatedPath"])
            if not isolated.is_file():
                continue
            digest = hashlib.sha256(isolated.read_bytes()).hexdigest()

            if last_digest.get(group["id"]) == digest:
                revisions.append({
                    "id": group["id"],
                    "project": name,
                    "commit_sha": sha,
                    "committed_at": commit["committed_at"],
                    "content_sha256": digest,
                    "status": "unchanged",
                })
                continue
            last_digest[group["id"]] = digest

            order = sequence.get(group["id"], 0) + 1
            sequence[group["id"]] = order
            target = SAMPLES_DIR / group["id"] / f"rev_{order:03d}_{sha[:8]}.dart"
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(isolated, target)

            # NO `base.dart` for a walk-discovered group: it is its revisions, the same
            # as under `mine`. Writing one here would make the two paths disagree about
            # what a group is, and would reintroduce the privileged commit that taking
            # every revision on equal footing exists to remove.
            if group.get("discovered_in_walk") and group["id"] not in minted_ids:
                minted_ids.add(group["id"])
                group.update({
                    "commit_sha": sha,
                    "blob_sha": git(worktree, "rev-parse", f"{sha}:{relative}"),
                    "source_sha256": digest,
                    "committed_at": commit["committed_at"],
                    "dirty_worktree": False,
                    "dirty_lib": False,
                    "repo_url": repo.get("repo_url"),
                    "source_file_absolute": str(worktree / relative),
                    "ordinal": ordinal,
                    "isolated_at": datetime.now(timezone.utc).isoformat(),
                    "base_dart": None,
                    "first_revision": target.name,
                    "first_revision_commit": sha,
                })
                new_groups.append(group)

            revisions.append({
                "id": group["id"],
                "order": order,
                "content_sha256": digest,
                "project": name,
                "scope_type": row["nodeType"],
                "scope_name": row["name"],
                "commit_sha": sha,
                "committed_at": commit["committed_at"],
                "author": commit["author"],
                "subject": commit["subject"],
                "blob_sha": git(worktree, "rev-parse", f"{sha}:{relative}"),
                "source_file_relative": relative,
                "touched_declaring_file": group["source_file_relative"] in commit["touched"],
                "file": str(target),
                "bytes": target.stat().st_size if target.is_file() else 0,
                "status": "isolated",
                **verification(row),
            })

    shutil.rmtree(worktree, ignore_errors=True)
    subprocess.run(["git", "-C", str(clone), "worktree", "prune"],
                   capture_output=True, timeout=300)
    return revisions, new_groups


def load_mine_gate() -> dict[str, set[str]] | None:
    """Revisions `mine` judged trustworthy, keyed by group id.

    Returns None when `mine` has not run, in which case every candidate commit is
    isolated and the summary says the output carries no resolution gate.
    """
    if not config.HISTORY_FEATURES.is_file():
        return None
    groups_file = SAMPLES_DIR / "groups.jsonl"
    if not groups_file.is_file():
        return None

    identity_to_id = {}
    for line in groups_file.read_text().splitlines():
        if line.strip():
            group = json.loads(line)
            key = config.scope_key(
                group["project"], group["source_file_relative"], group["scope_name"]
            )
            identity_to_id[key] = group["id"]

    gate: dict[str, set[str]] = {}
    for line in config.HISTORY_FEATURES.read_text().splitlines():
        if not line.strip():
            continue
        row = json.loads(line)
        if row.get("status") != "extracted":
            continue
        group_id = identity_to_id.get(row["scope_key"])
        if group_id:
            gate.setdefault(group_id, set()).add(row["commit"])
    return gate or None


def run(repo_names: list[str] | None = None, *, only_clean: bool = True,
        check: bool = True, history: bool = False,
        max_commits: int | None = None, resume: bool = False,
        retry_failed: bool = False, all_revisions: bool = False) -> dict:
    repos = config.selected(repo_names)

    # Only repositories whose `lib/` resolves may be isolated: the transplant
    # loses type information otherwise, and inlines nothing it cannot resolve, so
    # the sample would be quietly shallower than the code it claims to be.
    if only_clean and config.PREPARE_REPORT.is_file():
        report = json.loads(config.PREPARE_REPORT.read_text())
        clean = set(report.get("clean_repos", []))
        skipped = [r["repo_name"] for r in repos if r["repo_name"] not in clean]
        repos = [r for r in repos if r["repo_name"] in clean]
        for skip in skipped:
            print(f"  skipping {skip}: lib/ did not reach zero errors in prepare")

    if not repos:
        raise SystemExit(
            "no prepared repositories to isolate - run `prepare` first, or pass "
            "--include-unprepared to isolate anyway (the transplant will be shallow)"
        )

    SAMPLES_DIR.mkdir(parents=True, exist_ok=True)
    scratch = config.PROBE_DIR / "isolate_scratch"
    id_map = load_id_map()

    # A repository whose transplant is already on disk is not re-transplanted. `spm
    # isolate` re-parses the whole checkout, and its output is a function of the checkout,
    # so re-running it on an unchanged clone rewrites byte-identical files.
    resumed: list[dict] = []
    if resume:
        resumed, repos = checkpoints.split("isolate", repos, retry_failed=retry_failed)
        checkpoints.announce("isolate", resumed, repos, retry_failed=retry_failed)

    records, all_groups = [], []
    # Groups this run actually produced, so the self-containment check can be scoped to
    # them rather than re-analyzing every group in the corpus on every run.
    fresh_ids: set[str] = set()
    for i, repo in enumerate(repos, 1):
        print(f"[{i}/{len(repos)}] {repo['repo_name']}", flush=True)
        record = isolate_repo(repo, scratch, id_map)
        # Written before the id map so a crash can only ever cost ids, never claim a
        # repository was isolated when its groups were not recorded.
        checkpoints.write("isolate", repo["repo_name"], record)
        ID_MAP.write_text(json.dumps(id_map, indent=2, sort_keys=True) + "\n")
        if record["status"] == "ok":
            groups = record["groups"]
            all_groups.extend(groups)
            fresh_ids.update(g["id"] for g in groups)
            print(
                f"  {len(groups)} scopes -> groups "
                f"{groups[0]['id']}..{groups[-1]['id']} @ {record['commit_sha'][:10]}"
                + ("  DIRTY lib/" if record["dirty_lib"] else ""),
                flush=True,
            )
        else:
            print(f"  {record['status']}", flush=True)
        records.append(record)

    # Resumed repositories contribute their groups from their checkpoints; they are not
    # re-derived, so their recorded provenance and analyze results carry over unchanged.
    for record in resumed:
        if record.get("status") == "ok":
            all_groups.extend(record.get("groups") or [])
    records = resumed + records
    # Sorted by repository so the output does not depend on thread completion order,
    # nor on which repositories this particular run happened to walk versus resume.
    records.sort(key=lambda r: r.get("repo_name") or "")
    for record in records:
        record.pop("groups", None)

    ID_MAP.write_text(json.dumps(id_map, indent=2, sort_keys=True) + "\n")

    # Merge with what is already recorded. A run scoped to `--repos` must not
    # truncate the corpus to that subset: the other projects' `base.dart` files
    # stay on disk, so dropping their manifest rows would leave groups that exist
    # but are unlisted - present to anyone reading the directory, invisible to
    # anyone reading the index.
    processed = {r["repo_name"] for r in records}
    existing_file = SAMPLES_DIR / "groups.jsonl"
    if existing_file.is_file():
        kept = [
            json.loads(line)
            for line in existing_file.read_text().splitlines()
            if line.strip() and json.loads(line)["project"] not in processed
        ]
        if kept:
            print(f"  keeping {len(kept)} groups from projects not in this run")
        all_groups = kept + all_groups
    all_groups.sort(key=lambda g: g["id"])

    # --- the same scopes at their other revisions -------------------------
    history_revisions: list[dict] = []
    gate = load_mine_gate() if history else None
    if history and all_groups:
        by_project_groups: dict[str, list[dict]] = {}
        for group in all_groups:
            by_project_groups.setdefault(group["project"], []).append(group)
        targets_by_project: dict[str, list[dict]] = {}
        if config.TARGETS.is_file():
            for line in config.TARGETS.read_text().splitlines():
                if line.strip():
                    scope = json.loads(line)
                    targets_by_project.setdefault(scope["project"], []).append(scope)
        (config.PROBE_DIR / "worktrees").mkdir(parents=True, exist_ok=True)

        for repo in repos:
            name = repo["repo_name"]
            if name not in targets_by_project:
                print(f"  {name}: no targets.jsonl entries - run `discover` first")
                continue
            print(f"\nhistory: {name}", flush=True)
            walked, minted = isolate_history(
                repo, by_project_groups.get(name, []), targets_by_project[name],
                scratch, max_commits=max_commits, gate=gate,
                all_revisions=all_revisions,
            )
            history_revisions.extend(walked)
            if minted:
                print(f"  {len(minted)} scopes absent at HEAD were given groups")
                all_groups.extend(minted)

        with (SAMPLES_DIR / "revisions.jsonl").open("w") as sink:
            for revision in sorted(
                history_revisions, key=lambda r: (r.get("id", ""), r.get("order", 0))
            ):
                sink.write(json.dumps(revision) + "\n")

    containment = None
    if check and all_groups:
        # `dart analyze` over every group is minutes of work whose answer cannot change
        # for a group whose `base.dart` did not. Groups carrying a recorded
        # `analyze_errors` from an earlier run keep it; everything new or never-checked
        # is analyzed now.
        to_check = [
            g for g in all_groups
            if g["id"] in fresh_ids or "analyze_errors" not in g
        ] if resume else all_groups
        if to_check:
            print(f"\nchecking self-containment ({len(to_check)} of {len(all_groups)} "
                  f"groups) ...", flush=True)
            containment = check_self_containment(to_check)
            containment["scope"] = (
                f"{len(to_check)} new or never-checked groups of {len(all_groups)}"
                if len(to_check) != len(all_groups) else "every group"
            )
        else:
            print("\nself-containment: nothing new to check", flush=True)

    all_groups.sort(key=lambda g: g["id"])
    write_manifests(all_groups)

    shutil.rmtree(scratch, ignore_errors=True)

    by_type: dict[str, int] = {}
    for group in all_groups:
        by_type[group["scope_type"]] = by_type.get(group["scope_type"], 0) + 1
    summary = {
        "phase": "isolate",
        "ran_at": datetime.now(timezone.utc).isoformat(),
        "extractor": "spm isolate (pub.dev 0.6.0, the container's pinned build)",
        "groups": len(all_groups),
        "by_scope_type": dict(sorted(by_type.items(), key=lambda kv: -kv[1])),
        "by_project": {
            r["repo_name"]: r.get("scopes_isolated", 0) for r in records
        },
        "commits": {
            r["repo_name"]: r.get("commit_sha") for r in records if r.get("commit_sha")
        },
        "dirty_lib": [r["repo_name"] for r in records if r.get("dirty_lib")],
        "self_containment": containment,
        "history": {
            "enabled": history,
            "all_revisions": all_revisions,
            "groups_minted_in_walk": sum(
                1 for g in all_groups if g.get("discovered_in_walk")
            ),
            "resolution_gate": (
                "mine (only revisions with a resolved closure)" if gate
                else "NONE - `mine` has not run, so revisions are unfiltered"
            ),
            # Distinct transplanted states - the only ones that can produce a
            # nonzero pair.
            "revisions_isolated": sum(
                1 for r in history_revisions if r.get("status") == "isolated"
            ),
            "revisions_unchanged": sum(
                1 for r in history_revisions if r.get("status") == "unchanged"
            ),
            "revisions_skipped": sum(
                1 for r in history_revisions
                if r.get("status") not in ("isolated", "unchanged")
            ),
            "groups_with_a_pair": len({
                r["id"] for r in history_revisions
                if r.get("status") == "isolated" and r.get("order", 0) >= 2
            }),
            "groups_with_history": len({
                r["id"] for r in history_revisions if r.get("status") == "isolated"
            }),
            "max_commits_per_repo": max_commits,
        } if history else None,
        "repos": records,
    }
    (config.PROBE_DIR / "isolate_summary.json").write_text(
        json.dumps(summary, indent=2) + "\n"
    )
    print(f"\n{len(all_groups)} groups in {SAMPLES_DIR.relative_to(config.PROJECT_ROOT)}")
    print(f"  by scope type: {summary['by_scope_type']}")
    if containment:
        print(
            f"  self-contained: {containment['groups_clean']}/{containment['groups_checked']} "
            f"analyze clean; {containment['distinct_undefined_names']} distinct undefined "
            f"names; errors/group median {containment['errors_per_group']['median']}"
        )
        print(
            "  (undefined names are expected - isolate inlines widgets and enums "
            "only; samples/ covered the rest with a hand-written dependencies.dart)"
        )
    if history:
        h = summary["history"]
        print(
            f"  history: {h['revisions_isolated']} distinct states across "
            f"{h['groups_with_history']} groups "
            f"({h['revisions_unchanged']} commits left the transplant unchanged); "
            f"{h['groups_with_a_pair']} groups have >=2 states and can form a pair"
        )
        print(f"  gate = {h['resolution_gate']}")
    if summary["dirty_lib"]:
        print(f"  WARNING dirty lib/ (transplant may match no commit): {summary['dirty_lib']}")
    return summary
