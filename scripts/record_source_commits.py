#!/usr/bin/env python3
"""Record the exact commit every transplanted widget was taken from.

`samples/sources.jsonl` says which repository and which file each seed group came from. It does
not say *which version* of that file, and the clones are `--depth 1`, so the answer currently
exists only as the checked-out HEAD of a shallow clone. That is fragile: `git fetch --unshallow`,
a re-clone, or an upstream force-push would destroy it silently, and with it the ability to say
what was measured.

This script freezes that answer into `samples/source_commits.jsonl`.

For every repository it records the remote, the anchor commit, and whether the clone was shallow
when the anchor was taken. For every seed group it records the anchor commit plus two independent
fingerprints of the source file at that commit:

  * `blob_sha`   - git's own content hash (`git rev-parse HEAD:<path>`). Survives any history
                   rewrite that preserves content, and is what `git cat-file blob` takes to
                   reproduce the exact bytes.
  * `sha256`     - a hash of the file as it sits in the working tree, independent of git
                   entirely, so a corrupted or rewritten object store can still be detected.

`dirty` flags a file with uncommitted local edits. A dirty file means the working tree is not the
anchor commit, and the transplanted widget may not correspond to any commit at all - that is a
finding to resolve, not a value to record and forget.

Run it again after unshallowing to verify nothing moved: the blob hashes must be identical.

    python3 -m scripts.record_source_commits

(As a module, not as a path: it reads `PROJECT_ROOT` from `scripts.paths` like every other
module here, and `python3 scripts/record_source_commits.py` cannot resolve that import.)
"""

from __future__ import annotations

import hashlib
import json
import subprocess
from datetime import datetime, timezone
from pathlib import Path

from scripts.paths import PROJECT_ROOT


ROOT = PROJECT_ROOT
SOURCES = ROOT / "samples" / "sources.jsonl"
OUT_JSONL = ROOT / "samples" / "source_commits.jsonl"
OUT_JSON = ROOT / "samples" / "source_commits.json"
PAIRS = ROOT / "analysis" / "data" / "redmi9t_pairs_labelled.csv"


def git(repo: Path, *args: str) -> str | None:
    """Run git in `repo`; None rather than an exception when the question has no answer."""
    try:
        result = subprocess.run(
            ["git", "-C", str(repo), *args],
            capture_output=True, text=True, check=True,
        )
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None
    return result.stdout.strip() or None


def sha256(path: Path) -> str | None:
    if not path.is_file():
        return None
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1 << 20), b""):
            digest.update(block)
    return digest.hexdigest()


def repo_root_for(source_file: Path, relative: str) -> Path:
    """The clone directory: the absolute source path with its repo-relative tail removed."""
    absolute, tail = str(source_file), relative.replace("\\", "/")
    assert absolute.replace("\\", "/").endswith(tail), f"{absolute} does not end with {tail}"
    return Path(absolute[: -len(tail)].rstrip("/"))


def measured_groups() -> set[str]:
    """Groups present in the current measurement snapshot, so the manifest can mark them."""
    if not PAIRS.is_file():
        return set()
    with PAIRS.open() as handle:
        header = handle.readline().rstrip("\n").split(",")
        index = header.index("group")
        return {line.split(",")[index] for line in handle if line.strip()}


def main() -> None:
    sources = [json.loads(line) for line in SOURCES.read_text().splitlines() if line.strip()]
    snapshot = measured_groups()
    recorded_at = datetime.now(timezone.utc).isoformat()

    repositories: dict[str, dict] = {}
    entries: list[dict] = []

    for row in sources:
        relative = row["sourceFileRelative"]
        source_file = Path(row["sourceFile"])
        repo = repo_root_for(source_file, relative)
        project = row["project"]

        if project not in repositories:
            repositories[project] = {
                "project": project,
                "clone_path": str(repo),
                # The shard directory records which GitHub code-search pattern found the repo.
                "shard": repo.parent.name,
                "remote_url": git(repo, "config", "--get", "remote.origin.url"),
                "anchor_commit": git(repo, "rev-parse", "HEAD"),
                "anchor_commit_short": git(repo, "rev-parse", "--short", "HEAD"),
                "anchor_date": git(repo, "log", "-1", "--format=%cI"),
                "anchor_author": git(repo, "log", "-1", "--format=%an"),
                "anchor_subject": git(repo, "log", "-1", "--format=%s"),
                "anchor_tree": git(repo, "rev-parse", "HEAD^{tree}"),
                "shallow_when_recorded": (repo / ".git" / "shallow").is_file(),
                "commits_available_locally": int(git(repo, "rev-list", "--count", "HEAD") or 0),
                "default_branch": git(repo, "rev-parse", "--abbrev-ref", "HEAD"),
                "groups": [],
            }
        repositories[project]["groups"].append(row["id"])

        status = git(repo, "status", "--porcelain", "--", relative)
        entries.append({
            "group": row["id"],
            "in_measurement_snapshot": row["id"] in snapshot,
            "project": project,
            "trigger": row.get("trigger"),
            "source_file_relative": relative,
            "source_file_absolute": str(source_file),
            "anchor_commit": repositories[project]["anchor_commit"],
            # Content fingerprints: git's own, and one that does not trust git at all.
            "blob_sha": git(repo, "rev-parse", f"HEAD:{relative}"),
            "sha256": sha256(source_file),
            "size_bytes": source_file.stat().st_size if source_file.is_file() else None,
            "exists_on_disk": source_file.is_file(),
            "dirty": bool(status),
            "last_commit_touching_file": git(
                repo, "log", "-1", "--format=%H", "--", relative
            ),
            "recover_with": f"git -C <clone> cat-file blob {git(repo, 'rev-parse', f'HEAD:{relative}')}",
        })

    for repository in repositories.values():
        repository["groups"] = sorted(repository["groups"])
        repository["groups_in_snapshot"] = sorted(
            g for g in repository["groups"] if g in snapshot
        )

    OUT_JSONL.write_text("".join(json.dumps(e) + "\n" for e in entries))

    problems = {
        "missing_anchor_commit": [e["group"] for e in entries if not e["anchor_commit"]],
        "missing_blob_sha": [e["group"] for e in entries if not e["blob_sha"]],
        "missing_on_disk": [e["group"] for e in entries if not e["exists_on_disk"]],
        "dirty_working_tree": [e["group"] for e in entries if e["dirty"]],
    }

    summary = {
        "recorded_at": recorded_at,
        "recorded_by": "scripts/record_source_commits.py",
        "why": (
            "The clones are --depth 1, so the transplant source version existed only as the "
            "checked-out HEAD of a shallow clone. Unshallowing, re-cloning or an upstream "
            "force-push would have destroyed it. This manifest is the durable record."
        ),
        "verify_after_unshallow": (
            "Re-run this script and diff samples/source_commits.jsonl. Every anchor_commit and "
            "blob_sha must be unchanged; a changed blob_sha means the file you are reading is "
            "not the file that was measured."
        ),
        "groups_total": len(entries),
        "groups_in_measurement_snapshot": sum(e["in_measurement_snapshot"] for e in entries),
        "repositories": repositories,
        "problems": problems,
    }
    OUT_JSON.write_text(json.dumps(summary, indent=2) + "\n")

    print(f"wrote {OUT_JSONL.relative_to(ROOT)}  ({len(entries)} groups)")
    print(f"wrote {OUT_JSON.relative_to(ROOT)}   ({len(repositories)} repositories)")
    print()
    for repository in sorted(repositories.values(), key=lambda r: -len(r["groups_in_snapshot"])):
        print(
            f"{repository['project']:46s} {repository['anchor_commit_short'] or '???':10s} "
            f"{(repository['anchor_date'] or '?')[:10]}  "
            f"groups={len(repository['groups']):2d} "
            f"(snapshot {len(repository['groups_in_snapshot']):2d})  "
            f"shallow={repository['shallow_when_recorded']}"
        )
    print()
    for name, groups in problems.items():
        print(f"{name}: {groups if groups else 'none'}")


if __name__ == "__main__":
    main()
