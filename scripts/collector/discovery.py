import logging
import sqlite3

from .api import repo_fields, search_repositories
from .config import (
    MAX_REPO_SEARCH_PAGES,
    MIN_FORKS,
    MIN_STARS,
    OWNER_BLACKLIST,
    REPO_SEARCH_QUERIES,
    barred_repo_keys,
)
from .db import already_scanned_repo, mark_repo_scanned

log = logging.getLogger(__name__)


def discover_candidates(
    conn: sqlite3.Connection, limit: int | None = None
) -> list[dict]:
    """Return repo-level candidates from GitHub repo search, newest ones first seen.

    Star/fork thresholds are pushed into the query so the API does the filtering;
    licence and project-shape checks stay client-side. `limit` stops paging early —
    most candidates get rejected downstream, so pass generous headroom.
    """
    seen: set[str] = set()
    raw: list[dict] = []
    # Read once per discovery run, not per candidate: the file is small but this loop
    # runs thousands of times.
    barred = barred_repo_keys()

    for base_query in REPO_SEARCH_QUERIES:
        if limit is not None and len(raw) >= limit:
            break

        query = f"{base_query} stars:>={MIN_STARS} forks:>={MIN_FORKS}"
        log.info("Searching repos: %s", query)

        for page in range(1, MAX_REPO_SEARCH_PAGES + 1):
            items = search_repositories(query, page=page)

            if items is None:
                # Request failed even after retries — one more shot, then move on.
                log.warning("Search failed for page %d; retrying once.", page)
                items = search_repositories(query, page=page)
                if items is None:
                    log.error("Abandoning query after repeated failures: %s", query)
                    break

            if not items:
                break

            for item in items:
                info = repo_fields(item)
                full_name = info["full_name"]
                if not full_name:
                    continue

                key = full_name.lower()
                if key in seen:
                    continue

                owner = key.split("/", 1)[0]
                if owner in OWNER_BLACKLIST:
                    log.debug("Skip (blacklisted owner): %s", full_name)
                    continue

                if key.replace("/", "_") in barred:
                    # Recorded as scanned-and-rejected rather than merely skipped: a repo
                    # that is only skipped is rediscovered and re-evaluated by every future
                    # harvest, and the scan log exists precisely so that cannot happen.
                    log.info("Skip (excluded): %s", full_name)
                    mark_repo_scanned(conn, full_name, "excluded")
                    seen.add(key)
                    continue

                if already_scanned_repo(conn, full_name):
                    log.debug("Skip (already scanned): %s", full_name)
                    continue

                seen.add(key)
                raw.append(info)

            log.info("  page %d -> %d new candidates so far", page, len(raw))

            if limit is not None and len(raw) >= limit:
                log.info("Discovery limit of %d reached.", limit)
                break

    return raw
