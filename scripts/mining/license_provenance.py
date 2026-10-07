"""Re-isolate, only to record whose package code each transplant carried.

WHY A SEPARATE PASS
-------------------
`spm isolate` learned to name the hosted packages it inlines -- `inlinedThirdPartyPackages`
on the mapping row, name to version -- after this corpus was mined. It shipped in `spm 0.7.1`.
The mine ran `spm 0.7.0` from pub.dev, which reports the COUNT and not the names, so
`probe_v2/samples_v2` records that 1,182 revision files carry package source and cannot say
whose it is. `R17_package_license` needs the names.

The container's own dependency has the field -- 0.7.1 by path from `../spm-publish` when this
ran, 0.7.2 from pub.dev in the release -- so this pass runs `config.SPM_ENTRY` like every other
phase and `--spm` is an override rather than a necessity. What it does NOT do is make the field
appear in the corpus already on disk: those files were written by 0.7.0, and re-mining them is
the wrong instrument (see below).

Re-running `mine` would repopulate the field and is the wrong instrument: it walks 95,160
revisions, rewrites every manifest, and re-decides a corpus whose counts are frozen at
214 / 50 / 20. This pass instead visits ONLY the commits behind files that carry a positive
count, records the packages, and writes them to a side artifact -- `config/license_provenance.jsonl`,
committed beside the fixture tables because it is evidence rather than scratch. Nothing under
`probe_v2/samples_v2` or `new_samples` is written.

THE BYTE-IDENTITY GATE
----------------------
A side artifact produced by a DIFFERENT build than the one that mined the corpus is a claim
about a file, not evidence about it. So every row is checked: the transplant this pass
writes must be byte-identical to the one already in `probe_v2/samples_v2/<gid>/<rev>.dart`,
which `mine` put there with a plain `shutil.copyfile` off spm's own output.

That gate is load-bearing rather than ceremonial, because 0.7.1 is NOT the build that mined the
corpus and is not merely 0.7.0 plus a field: twelve files under `lib/src/features/isolation/`
differ, three of them in the emitter path. `AppConstants.builderScopeWidgets` replaced a
five-name literal in `transplant_extractor.dart`, adding `Obx`, `GetX`, `GetBuilder` and
`Observer` to the walk-out from a builder callback, and this corpus carries `get`.

When it matches, two things are proved at once and neither has to be assumed. The package
list describes the file the screen actually reads; and 0.7.1 is behaviourally identical to the
published 0.7.0 on this input, which is the substitution this pass rests on -- and which is
0.7.1's own changelog claim ("the emitted Dart is byte-identical to 0.7.0's for every scope")
tested on 745 real transplants rather than taken on trust. When it does not match, the row
records `bytes_identical: false` and R17 refuses to use it -- an unattributed file fires,
exactly as a missing row does.

FIDELITY OF THE WALK
--------------------
The commits are visited in the mine's own order, under the mine's own resolution rule:
oldest first, `pub get` + codegen only when the pubspec fingerprint moves, a failed
resolution poisoning its fingerprint rather than being carried forward. That is not
decoration -- `spm isolate` reads the types out of `.dart_tool`, so a checkout resolved
under a different pubspec produces a different file, and the gate above would then fail on a
difference this pass introduced rather than one it found.

The FULL commit list is walked, not just the commits needed, for the same reason: the state
of `.dart_tool` at a commit depends on which pubspec windows preceded it. Only the isolate
run -- the expensive part -- is skipped where nothing is needed.
"""

from __future__ import annotations

import json
import shutil
import time
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path

from . import config
from .isolate import SAMPLES_DIR, run_isolate
from .mine import (checkout, log, make_worktree, pubspec_fingerprint, resolve_worktree,
                   set_total)

OUTPUT = config.PROJECT_ROOT / "config" / "license_provenance.jsonl"
CHECKPOINT_DIR = config.PROBE_DIR / "checkpoints_license_provenance"
WORKTREES = config.PROBE_DIR / "license_provenance_worktrees"
SCRATCH = config.PROBE_DIR / "license_provenance_scratch"

# No SPM_CHECKOUT constant any more. Until 2026-09-05 this pass had to run a checkout the
# container did not depend on, because the container's dependency was the published 0.7.0 and
# the field did not exist in any release. 0.7.1 shipped it (by path from `../spm-publish` at the
# time, 0.7.2 from pub.dev in the release), and so the default is the same build every other phase runs.


def _rows(path: Path):
    if not path.is_file():
        return
    for line in path.read_text(errors="ignore").splitlines():
        if line.strip():
            try:
                yield json.loads(line)
            except json.JSONDecodeError:
                continue


def needed_revisions(samples: Path | None = None
                     ) -> dict[str, dict[str, list[tuple[str, str]]]]:
    """`{project: {commit sha: [(group id, revision file name)]}}` -- every file R17 decides.

    A file with no `inlinedThirdPartyDeclarations` carries no package source, and a reverted
    one had its carried source replaced by stand-ins before it was written; neither needs a
    name, and R17 passes both without consulting this artifact. What is left is the set this
    pass exists for.

    The GROUP ID is carried through from the manifest rather than looked up from the file
    name afterwards, because a name does not identify a revision on its own. `mine` names a
    revision `rev_<order>_<sha8>.dart` where the order is per GROUP, so two scopes in the
    same file at the same commit produce the same name in different group directories --
    30 of them at one commit of `cairuoyu/flutter_admin`. Reverse-mapping name to group
    collapsed 1,182 rows onto 936 keys, silently attributing eight files out of every nine
    from a ninth file's isolate run.
    """
    src = (samples or SAMPLES_DIR) / "revisions.jsonl"
    out: dict[str, dict[str, list[tuple[str, str]]]] = defaultdict(lambda: defaultdict(list))
    for row in _rows(src):
        if not row.get("inlinedThirdPartyDeclarations"):
            continue
        if row.get("thirdPartyInlineReverted"):
            continue
        project, sha, path, gid = (row.get("project"), row.get("commit_sha"),
                                   row.get("file"), row.get("id"))
        if project and sha and path and gid:
            out[project][sha].append((gid, Path(path).name))
    return {k: dict(v) for k, v in out.items()}


def identities(samples: Path | None = None) -> dict[str, dict]:
    """`{group id: group record}` from the mine's own manifest."""
    src = (samples or SAMPLES_DIR) / "groups.jsonl"
    return {row["id"]: row for row in _rows(src) if row.get("id")}


def walked_commits(samples: Path | None = None) -> dict[str, dict[str, int]]:
    """`{project: {commit sha: committed_at}}` -- every commit the mine actually recorded.

    The second half of the walk, and the half that cannot be reconstructed from
    `targets.jsonl`. See `ordered_commits`.
    """
    src = (samples or SAMPLES_DIR) / "revisions.jsonl"
    out: dict[str, dict[str, int]] = defaultdict(dict)
    for row in _rows(src):
        project, sha, at = row.get("project"), row.get("commit_sha"), row.get("committed_at")
        if project and sha and at is not None:
            out[project][sha] = at
    return out


def ordered_commits(repo_name: str, since: int | None,
                    walked: dict[str, dict[str, int]] | None = None) -> list[dict]:
    """Every commit to visit for [repo_name], oldest first.

    The UNION of two sources, and both halves are load-bearing.

    `targets.jsonl` is what `mine_repo` builds its walk from, so it carries the pubspec
    windows the mine resolved through -- including commits that produced no revision row,
    which still moved `.dart_tool` and therefore still decide what `spm isolate` sees at the
    commits that follow.

    It is also **not sufficient**, and assuming it was cost a row before this was written.
    `mine --all-revisions` mints a group for a scope it meets mid-walk, and a later
    `discover` rewrites `targets.jsonl` against the tree as it then is, so the file on disk
    is not the list the mine walked. Measured across the nine repositories this pass covers,
    26 commits carrying package source are absent from it -- one of them
    `23caef43` of `mllrr96/Neumorphic-Calculator`, which is an endpoint of the only eligible
    contrast in the corpus that carries inlined package source. Skipping it silently would
    have made R17 fire `unattributed` on that endpoint and taken the group: 213 / 49 / 20.

    So the mine's own revision rows are unioned in. They ARE the walk, by construction:
    `mine` writes one per commit it processed, `status: "unchanged"` included.
    """
    commits: dict[str, dict] = {}
    for scope in _rows(config.TARGETS):
        if scope.get("kind") != "scope" or scope.get("project") != repo_name:
            continue
        for commit in scope.get("commits", []):
            commits[commit["commit"]] = commit
    for sha, at in (walked or walked_commits()).get(repo_name, {}).items():
        commits.setdefault(sha, {"commit": sha, "committed_at": at})
    ordered = sorted(commits.values(), key=lambda c: c["committed_at"])
    if since is not None:
        ordered = [c for c in ordered if c["committed_at"] >= since]
    return ordered


def mine_cutoff() -> int | None:
    """The `--since` the mine ran under, read from its own summary.

    Read rather than passed, because a cutoff that disagrees with the mine's changes which
    commits precede a given one and therefore which pubspec window it is resolved in.
    """
    summary = config.PROBE_DIR / "mine_summary.json"
    if not summary.is_file():
        return None
    try:
        return json.loads(summary.read_text()).get("since")
    except json.JSONDecodeError:
        return None


def spm_entry(checkout_dir: Path | None) -> tuple[list[str], Path]:
    """The build to run and the cwd that resolves it.

    `None` is the normal case and means the container's own dependency, exactly as `mine` and
    `isolate` run it. A path is an override for a build the container does not depend on --
    the fallback if `bytes_identical` starts coming back false, since
    `provenance/0.7.0+packages` in `spm-publish` is 0.7.0 plus the field and nothing else.
    """
    if checkout_dir is None:
        return list(config.SPM_ENTRY), config.SPM_CWD
    if not (checkout_dir / "bin" / "spm.dart").is_file():
        raise SystemExit(
            f"no spm checkout at {checkout_dir}. Pass a directory holding `bin/spm.dart`, or "
            f"omit --spm to run the container's own dependency.")
    return ["dart", "run", str(checkout_dir / "bin" / "spm.dart")], checkout_dir


def resolved_build() -> str:
    """How `pubspec.lock` names the `spm` the default entry resolves to.

    Recorded in the summary because a path dependency carries no sha256, so the lock says
    `source: path` and a version and nothing that survives a branch switch. Naming it in the
    artifact is what lets a later reader tell which build wrote these rows.
    """
    lock = config.PROJECT_ROOT / "pubspec.lock"
    if not lock.is_file():
        return "unknown"
    lines = lock.read_text(errors="ignore").splitlines()
    for index, line in enumerate(lines):
        if line.strip() != "spm:":
            continue
        block = []
        for entry in lines[index + 1:]:
            if entry and not entry.startswith("  " * 2):
                break
            block.append(entry.strip())
        # `dependency:` says how it is depended on and `description:` is a bare header; what
        # names the build is what is under them -- source, version, and path or sha256.
        return "; ".join(part for part in block
                         if part and not part.endswith(":")
                         and not part.startswith("dependency:"))
    return "unknown"


def provenance_repo(repo_name: str, wanted: dict[str, list[tuple[str, str]]],
                    groups: dict[str, dict], *, entry: list[str], cwd: Path,
                    since: int | None,
                    walked: dict[str, dict[str, int]] | None = None
                    ) -> tuple[list[dict], dict]:
    """Walk one repository and return its provenance rows plus a summary."""
    clone = config.REPOS_FULL_ROOT / config.repo_dir_name(repo_name)
    worktree = WORKTREES / config.repo_dir_name(repo_name)
    scratch = SCRATCH / config.repo_dir_name(repo_name)
    record = {"repo_name": repo_name, "commits_needed": len(wanted),
              "rows": 0, "identical": 0, "mismatched": 0, "unmatched": 0,
              "commits_walked": 0, "resolutions": 0, "unresolved": 0}
    rows: list[dict] = []

    if not clone.is_dir():
        record["status"] = "no_clone"
        log(f"no clone at {clone}", repo=repo_name)
        return rows, record

    ordered = ordered_commits(repo_name, since, walked)
    if not ordered or not make_worktree(clone, worktree, ordered[0]["commit"]):
        record["status"] = "worktree_failed"
        return rows, record

    fingerprint = None
    failed_fingerprints: set[str] = set()
    started = time.monotonic()
    for index, commit in enumerate(ordered):
        sha = commit["commit"]
        record["commits_walked"] += 1
        if not checkout(worktree, sha):
            continue
        current = pubspec_fingerprint(worktree)
        if current in failed_fingerprints:
            record["unresolved"] += 1
            continue
        if current != fingerprint:
            record["resolutions"] += 1
            resolution = resolve_worktree(worktree)
            if not resolution["pub_get_ok"]:
                # Identical to the mine's handling: a stale `.dart_tool` left in place would
                # silently supply the types for a revision that never resolved, and the file
                # spm then writes is not the file the mine wrote.
                shutil.rmtree(worktree / ".dart_tool", ignore_errors=True)
                failed_fingerprints.add(current)
                record["unresolved"] += 1
                continue
            fingerprint = current

        targets = wanted.get(sha)
        if not targets:
            continue                      # walked for its pubspec window, nothing to record

        ok, iso_rows, tail = run_isolate(worktree, scratch, entry=entry, cwd=cwd)
        if not ok and not iso_rows:
            log(f"  isolate failed at {sha[:10]}: {tail.strip()[-200:]}", repo=repo_name)
            record["unmatched"] += len(targets)
            continue

        # Identity is rebuilt exactly as `mine` rebuilds it -- same sort, same per-signature
        # ordinal -- because the ordinal is positional and any other order renames scopes.
        iso_rows.sort(key=lambda r: (r["originalPath"], r["nodeType"], r["name"]))
        counters: dict[tuple, int] = {}
        by_identity: dict[str, dict] = {}
        for iso in iso_rows:
            source = Path(iso["originalPath"])
            try:
                relative = source.relative_to(worktree).as_posix()
            except ValueError:
                relative = source.name
            signature = (relative, iso["nodeType"], iso["name"])
            ordinal = counters.get(signature, 0)
            counters[signature] = ordinal + 1
            by_identity[f"{repo_name}::{relative}::{iso['nodeType']}::{iso['name']}"
                        f"::{ordinal}"] = iso

        for gid, name in sorted(targets):
            group = groups.get(gid)
            shipped = SAMPLES_DIR / gid / name
            row = {"id": gid, "file": name, "project": repo_name, "commit_sha": sha}
            iso = by_identity.get((group or {}).get("identity", "")) if group else None
            if iso is None:
                # The scope is not in this checkout under the identity the mine recorded.
                # Left as a row rather than dropped: R17 has to be able to tell "looked and
                # could not attribute" from "never looked".
                row["bytes_identical"] = False
                row["why"] = "the scope's identity is not in this checkout's isolate output"
                record["unmatched"] += 1
            else:
                written = Path(iso["isolatedPath"])
                identical = (written.is_file() and shipped.is_file()
                             and written.read_bytes() == shipped.read_bytes())
                row["bytes_identical"] = identical
                row["inlinedThirdPartyDeclarations"] = iso.get(
                    "inlinedThirdPartyDeclarations")
                row["inlinedThirdPartyPackages"] = iso.get(
                    "inlinedThirdPartyPackages") or {}
                if iso.get("thirdPartyInlineTruncated"):
                    row["thirdPartyInlineTruncated"] = True
                if identical:
                    record["identical"] += 1
                else:
                    record["mismatched"] += 1
                    row["why"] = ("re-isolated bytes differ from the shipped transplant, so "
                                  "this package list describes a different file")
            rows.append(row)
            record["rows"] += 1

        if record["rows"] and index % 20 == 0:
            log(f"  [{index + 1}/{len(ordered)}] {record['identical']} identical, "
                f"{record['mismatched']} mismatched, {record['unmatched']} unmatched "
                f"({time.monotonic() - started:.0f}s)", repo=repo_name)

    # Anything wanted and not written. A commit skipped for a failed checkout or a failed
    # `pub get` never reaches the loop above, so without this its targets would vanish from
    # both the artifact and the count -- and R17 would fire `unattributed` on them with
    # nothing anywhere saying why. Silence is the one outcome this pass must not produce.
    recorded = {(r["id"], r["file"]) for r in rows}
    for sha, targets in sorted(wanted.items()):
        for gid, name in sorted(targets):
            if (gid, name) in recorded:
                continue
            rows.append({"id": gid, "file": name, "project": repo_name, "commit_sha": sha,
                         "bytes_identical": False,
                         "why": "the walk never reached this commit, or it was skipped for a "
                                "failed checkout or an unresolvable pubspec"})
            record["rows"] += 1
            record["unmatched"] += 1

    record["status"] = "done"
    log(f"{record['rows']} rows: {record['identical']} identical, "
        f"{record['mismatched']} mismatched, {record['unmatched']} unmatched; "
        f"{record['resolutions']} resolutions over {record['commits_walked']} commits",
        repo=repo_name)
    return rows, record


def run(repos: list[str], *, spm: Path | None = None, resume: bool = False,
        output: Path | None = None) -> dict:
    """The phase. Returns its summary and writes `config/license_provenance.jsonl`."""
    entry, cwd = spm_entry(spm)
    since = mine_cutoff()
    wanted_all = needed_revisions()
    walked = walked_commits()
    groups = identities()
    out_path = output or OUTPUT
    CHECKPOINT_DIR.mkdir(parents=True, exist_ok=True)

    # Existing rows are kept and overwritten per key, so a run over one repository does not
    # discard what another run recorded. The digest over this file is in `screen_mode`, so
    # rewriting it invalidates the screening checkpoints either way.
    existing: dict[tuple[str, str], dict] = {}
    for row in _rows(out_path):
        if row.get("id") and row.get("file"):
            existing[(row["id"], row["file"])] = row

    selected = [r for r in repos if wanted_all.get(r)]
    skipped = [r for r in repos if not wanted_all.get(r)]
    set_total(len(selected))
    summary = {"phase": "license-provenance",
               "ran_at": datetime.now(timezone.utc).isoformat(),
               "spm_cwd": str(cwd),
               # The build, not just where it was run from. `--spm` names itself; the default
               # is whatever `pubspec.lock` resolved, which a path dependency leaves unpinned.
               "spm_build": str(spm) if spm else resolved_build(),
               "since": since,
               "repositories_selected": len(selected),
               # A repository with nothing to record is not a failure and not a gap: not one
               # of its transplants carries package source, so R17 passes every one of them
               # without an entry here.
               "repositories_with_nothing_to_record": skipped,
               "repos": []}

    for repo_name in selected:
        checkpoint = CHECKPOINT_DIR / f"{config.repo_dir_name(repo_name)}.json"
        if resume and checkpoint.is_file():
            log("already recorded, skipping", repo=repo_name)
            summary["repos"].append(json.loads(checkpoint.read_text()))
            continue
        rows, record = provenance_repo(repo_name, wanted_all[repo_name], groups,
                                       entry=entry, cwd=cwd, since=since, walked=walked)
        for row in rows:
            if row.get("id") and row.get("file"):
                existing[(row["id"], row["file"])] = row
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(
            "".join(json.dumps(existing[k]) + "\n" for k in sorted(existing)),
            encoding="utf-8")
        checkpoint.write_text(json.dumps(record, indent=1), encoding="utf-8")
        summary["repos"].append(record)

    summary["rows_total"] = len(existing)
    summary["identical"] = sum(1 for r in existing.values() if r.get("bytes_identical"))
    summary["not_identical"] = summary["rows_total"] - summary["identical"]
    return summary
