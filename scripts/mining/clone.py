"""Phase 1 - give the harvested repositories the history this study needs.

The collector cloned with `--depth 1`, so every clone holds exactly one commit.
Mining human edits needs the opposite, and the obvious fix - `git fetch
--unshallow` - is the wrong one here: these are application repositories whose
history is mostly assets. `deckerst/aves` is 167M at depth 1 and its full blob
history is several times that, none of which is Dart.

`--filter=blob:none` gets the whole commit and tree graph and no file contents,
fetching a blob only when something reads it. That is exactly the access pattern
downstream: `git log` walks trees, and only the handful of `.dart` revisions that
survive filtering are ever read.

Cloned alongside the depth-1 checkouts rather than over them, so
`data/candidates.jsonl` keeps describing something that exists.
"""

from __future__ import annotations

import json
import shutil
import subprocess
import time
from datetime import datetime, timezone
from pathlib import Path

from . import config


def _run(command: list[str], timeout: int) -> tuple[bool, str]:
    try:
        done = subprocess.run(
            command, capture_output=True, text=True, timeout=timeout
        )
    except subprocess.TimeoutExpired:
        return False, f"timed out after {timeout}s: {' '.join(command)}"
    return done.returncode == 0, (done.stdout + done.stderr)


def git(repo: Path, *args: str, timeout: int = config.GIT_TIMEOUT_S) -> str | None:
    """Run git in `repo`. None rather than an exception when there is no answer."""
    ok, out = _run(["git", "-C", str(repo), *args], timeout)
    return out.strip() if ok else None


def _dir_size_mb(path: Path) -> int:
    total = 0
    for entry in path.rglob("*"):
        if entry.is_file() and not entry.is_symlink():
            try:
                total += entry.stat().st_size
            except OSError:
                pass
    return total // (1024 * 1024)


def clone_one(repo: dict, *, force: bool = False) -> dict:
    """Blobless-clone one repository and describe what arrived."""
    name = repo["repo_name"]
    target = config.REPOS_FULL_ROOT / config.repo_dir_name(name)
    shallow = config.REPOS_ROOT / config.repo_dir_name(name)

    record: dict = {
        "repo_name": name,
        "repo_url": repo["repo_url"],
        "path": str(target),
        "cloned_at": datetime.now(timezone.utc).isoformat(),
    }

    if target.exists() and not force:
        record["status"] = "already_present"
    else:
        if target.exists():
            shutil.rmtree(target)
        target.parent.mkdir(parents=True, exist_ok=True)
        started = time.monotonic()
        ok, output = _run(
            [
                "git", "clone", "--filter=blob:none",
                repo["repo_url"], str(target),
            ],
            config.GIT_TIMEOUT_S,
        )
        record["seconds"] = round(time.monotonic() - started, 1)
        if not ok:
            record["status"] = "failed"
            record["error"] = output[-2000:]
            return record
        record["status"] = "cloned"

    head = git(target, "rev-parse", "HEAD")
    count = git(target, "rev-list", "--count", "HEAD")
    record["head"] = head
    record["commits"] = int(count) if count and count.isdigit() else None
    record["size_mb"] = _dir_size_mb(target)

    # The anchor question: is this the same code the collector accepted? A repo
    # whose upstream moved since 2026-08-17 is not disqualified - but the pilot
    # numbers describe a different HEAD than `candidates.jsonl` does, and that
    # has to be visible rather than assumed away.
    shallow_head = git(shallow, "rev-parse", "HEAD") if shallow.is_dir() else None
    record["shallow_head"] = shallow_head
    record["head_matches_shallow"] = (
        shallow_head is not None and shallow_head == head
    )
    # `git log` over one commit is not history. This is the whole point of the
    # phase, so it is asserted rather than hoped for.
    record["has_history"] = bool(record["commits"] and record["commits"] > 1)
    return record


def run(repo_names: list[str] | None = None, *, force: bool = False) -> dict:
    repos = config.selected(repo_names)
    if not repos:
        raise SystemExit(
            "no repositories selected - check the names against data/candidates.jsonl "
            "(corpus repos are excluded unconditionally)"
        )

    config.PROBE_DIR.mkdir(parents=True, exist_ok=True)
    config.REPOS_FULL_ROOT.mkdir(parents=True, exist_ok=True)

    records = []
    for i, repo in enumerate(repos, 1):
        print(f"[{i}/{len(repos)}] {repo['repo_name']}", flush=True)
        record = clone_one(repo, force=force)
        note = (
            f"  {record['status']:15s} commits={record.get('commits')} "
            f"size={record.get('size_mb')}M "
            f"seconds={record.get('seconds', '-')}"
        )
        if not record.get("has_history"):
            note += "  NO HISTORY"
        if record.get("shallow_head") and not record.get("head_matches_shallow"):
            note += "  HEAD MOVED since harvest"
        print(note, flush=True)
        records.append(record)

    ok = [r for r in records if r.get("has_history")]
    summary = {
        "phase": "clone",
        "ran_at": datetime.now(timezone.utc).isoformat(),
        "requested": len(repos),
        "with_history": len(ok),
        "failed": [r["repo_name"] for r in records if r["status"] == "failed"],
        "head_moved": [
            r["repo_name"]
            for r in records
            if r.get("shallow_head") and not r["head_matches_shallow"]
        ],
        "total_size_mb": sum(r.get("size_mb") or 0 for r in records),
        "total_commits": sum(r.get("commits") or 0 for r in ok),
        "repos": records,
    }
    config.CLONE_REPORT.write_text(json.dumps(summary, indent=2) + "\n")
    print(
        f"\n{summary['with_history']}/{summary['requested']} with history, "
        f"{summary['total_commits']} commits, {summary['total_size_mb']}M on disk"
    )
    print(f"wrote {config.CLONE_REPORT.relative_to(config.PROJECT_ROOT)}")
    return summary
