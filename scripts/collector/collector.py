import csv
import json
import logging
import re
import shutil
from dataclasses import asdict, fields
from pathlib import Path

from .api import root_entries
from .config import (
    ALLOWED_LICENSES,
    CANDIDATES_FILE,
    CANDIDATES_CSV,
    DB_PATH,
    GITHUB_TOKEN,
    MAX_CANDIDATES,
    MIN_FORKS,
    MIN_STARS,
    SEARCH_PATTERNS,
)
from .db import init_db, mark_repo_scanned
from .discovery import discover_candidates
from .models import Candidate
from .repo import clone_repo

log = logging.getLogger(__name__)


def append_candidate(candidate: Candidate) -> None:
    # JSONL
    CANDIDATES_FILE.parent.mkdir(parents=True, exist_ok=True)
    with CANDIDATES_FILE.open("a", encoding="utf-8") as f:
        f.write(json.dumps(asdict(candidate)) + "\n")

    # CSV
    write_header = not CANDIDATES_CSV.exists()
    with CANDIDATES_CSV.open("a", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(
            f, fieldnames=[field.name for field in fields(Candidate)]
        )
        if write_header:
            writer.writeheader()
        writer.writerow(asdict(candidate))


def _discard(repo_dir: Path) -> None:
    try:
        shutil.rmtree(repo_dir)
    except Exception as e:
        log.debug("Could not remove %s: %s", repo_dir, e)


def _pattern_regex(pattern: str) -> re.Pattern:
    """Word-boundary matcher so `Consumer` does not match `ConsumerWidget`."""
    body = re.escape(pattern)
    prefix = r"\b" if pattern[:1].isalnum() or pattern[:1] == "_" else ""
    suffix = r"\b" if pattern[-1:].isalnum() or pattern[-1:] == "_" else ""
    return re.compile(prefix + body + suffix)


_PATTERN_REGEXES = [(p, _pattern_regex(p)) for p in SEARCH_PATTERNS]


def detect_patterns(repo_dir: Path) -> list[str]:
    """Return every SEARCH_PATTERNS entry occurring in the repo's lib/**/*.dart."""
    lib_dir = repo_dir / "lib"
    if not lib_dir.is_dir():
        return []

    found: set[str] = set()
    for dart_file in lib_dir.rglob("*.dart"):
        if len(found) == len(_PATTERN_REGEXES):
            break
        try:
            content = dart_file.read_text(errors="ignore")
        except OSError as e:
            log.debug("Could not read %s: %s", dart_file, e)
            continue
        for pattern, regex in _PATTERN_REGEXES:
            if pattern not in found and regex.search(content):
                found.add(pattern)

    # Preserve SEARCH_PATTERNS order for stable output.
    return [p for p in SEARCH_PATTERNS if p in found]


def _is_null_safe(content: str) -> bool:
    """Return True if pubspec.yaml declares a null-safe SDK lower bound (>= 2.12.0)."""
    # Both forms are current: `sdk: >=2.17.0 <4.0.0` and `sdk: ^3.5.0`.
    match = re.search(
        r'sdk\s*:\s*["\']?\s*(?:>=|\^)\s*([\d]+)\.([\d]+)(?:\.([\d]+))?', content
    )
    if not match:
        return False
    major, minor = int(match.group(1)), int(match.group(2))
    patch = int(match.group(3)) if match.group(3) else 0
    return (major, minor, patch) >= (2, 12, 0)


def is_package(repo_dir: Path) -> bool:
    pubspec = repo_dir / "pubspec.yaml"
    if not pubspec.exists():
        log.debug("No pubspec.yaml found in %s", repo_dir)
        return True

    try:
        content = pubspec.read_text(errors="ignore")

        if "plugin:" in content and "platforms:" in content:
            log.info("Skipping %s (detected as Flutter Plugin)", repo_dir.name)
            return True

        # Android is required; iOS and web are tolerated; desktop is not allowed.
        has_android = (repo_dir / "android").exists()
        if not has_android:
            log.info("Skipping %s (no android/ folder)", repo_dir.name)
            return True

        desktop = [p for p in ("linux", "macos", "windows") if (repo_dir / p).exists()]
        if desktop:
            log.info(
                "Skipping %s (has desktop platform(s): %s)",
                repo_dir.name,
                ", ".join(desktop),
            )
            return True

        if not _is_null_safe(content):
            log.info(
                "Skipping %s (SDK constraint does not opt into null safety)",
                repo_dir.name,
            )
            return True

        return False
    except Exception as e:
        log.error("Error reading pubspec.yaml in %s: %s", repo_dir, e)
        return True


def collect(max_candidates: int = MAX_CANDIDATES) -> None:
    if not GITHUB_TOKEN:
        log.warning(
            "GITHUB_TOKEN not set. Unauthenticated requests are severely rate-limited."
        )

    conn = init_db(DB_PATH)
    accepted: list[Candidate] = []
    accepted_repos: set[str] = set()

    log.info("=== Phase 1: Discovery ===")
    # Licence, project-shape and pattern checks reject ~97% of repos, so ask
    # discovery for far more than the target.
    raw_items = discover_candidates(conn, limit=max(max_candidates * 50, 200))
    log.info("Found %d raw candidates.", len(raw_items))

    log.info("=== Phase 2 & 3: License + Clone ===")
    for info in raw_items:
        if len(accepted) >= max_candidates:
            log.info("Reached target of %d candidates.", max_candidates)
            break

        repo_name = info["full_name"]
        repo_url = info["html_url"]
        stars = info["stars"]
        forks = info["forks"]
        license_id = info["license"]
        description = info["description"]

        if repo_name in accepted_repos:
            log.debug("Skip %s — already accepted this run", repo_name)
            continue

        # stars/forks/license come straight from the search payload — no extra
        # request needed, so the cheap filters run before any clone.
        if stars < MIN_STARS or forks < MIN_FORKS:
            log.info(
                "Rejected %s — stars=%d forks=%d (below threshold)",
                repo_name,
                stars,
                forks,
            )
            mark_repo_scanned(conn, repo_name, "rejected")
            continue

        if license_id not in ALLOWED_LICENSES:
            log.info("Rejected %s — license: %s", repo_name, license_id or "none")
            mark_repo_scanned(conn, repo_name, "rejected")
            continue

        # Cheapest possible shape check: one API call rules out the Flutter SDK
        # itself, awesome-lists, tutorial collections and monorepos before we
        # pay to clone hundreds of megabytes.
        entries = root_entries(repo_name)
        if entries is None:
            log.warning("Could not list root of %s — skipping (not recorded)", repo_name)
            continue
        missing = {"pubspec.yaml", "android"} - entries
        if missing:
            log.info(
                "Rejected %s — repo root lacks %s",
                repo_name,
                ", ".join(sorted(missing)),
            )
            mark_repo_scanned(conn, repo_name, "rejected")
            continue

        log.info(
            "Cloning %s (stars=%d, forks=%d, license=%s) ...",
            repo_name,
            stars,
            forks,
            license_id,
        )
        repo_dir = clone_repo(repo_url, repo_name)
        if not repo_dir:
            log.error("Failed to clone %s — skipping", repo_name)
            mark_repo_scanned(conn, repo_name, "rejected")
            continue

        if is_package(repo_dir):
            _discard(repo_dir)
            mark_repo_scanned(conn, repo_name, "rejected")
            continue

        found_patterns = detect_patterns(repo_dir)
        if not found_patterns:
            log.info("Skipping %s (no state-management patterns found)", repo_name)
            _discard(repo_dir)
            mark_repo_scanned(conn, repo_name, "rejected")
            continue

        candidate = Candidate(
            repo_name=repo_name,
            repo_url=repo_url,
            stars=stars,
            forks=forks,
            license=license_id,
            pattern=found_patterns[0],
            description=description,
            local_path=str(repo_dir),
            item_url="",
            patterns=",".join(found_patterns),
        )
        append_candidate(candidate)
        mark_repo_scanned(conn, repo_name, "accepted")

        accepted.append(candidate)
        accepted_repos.add(repo_name)
        log.info("[%d/%d] Accepted %s", len(accepted), max_candidates, repo_name)

    conn.close()
    log.info(
        "=== Done. %d candidates saved to %s and %s ===",
        len(accepted),
        CANDIDATES_FILE,
        CANDIDATES_CSV,
    )
