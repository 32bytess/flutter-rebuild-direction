import logging
import time

import requests

from .config import API_DELAY, GITHUB_API, GITHUB_TOKEN, REPO_SEARCH_DELAY

log = logging.getLogger(__name__)

_session = requests.Session()


def _headers() -> dict:
    h = {
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
        "User-Agent": "Flutter-Benchmark-Collector/1.0",
    }
    if GITHUB_TOKEN:
        h["Authorization"] = f"Bearer {GITHUB_TOKEN}"
    return h


def _get(
    url: str, params: dict | None = None, max_retries: int = 3
) -> dict | list | None:
    """GET with retries. Returns None when every attempt failed (or 404)."""
    log.debug("GET %s params=%s", url, params)
    for attempt in range(1, max_retries + 1):
        try:
            r = _session.get(url, headers=_headers(), params=params, timeout=30)

            if r.status_code == 401:
                # Retrying will never help — the token is expired or revoked.
                log.error(
                    "HTTP 401 Bad credentials: GITHUB_TOKEN is missing, expired or "
                    "revoked. Rotate it in .env before re-running."
                )
                return None

            if r.status_code == 403:
                reset = int(r.headers.get("X-RateLimit-Reset", time.time() + 60))
                wait = max(reset - time.time(), 5)
                log.warning(
                    "Rate-limited (HTTP 403). Sleeping %.0fs then retrying (attempt %d/%d).",
                    wait,
                    attempt,
                    max_retries,
                )
                time.sleep(wait)
                continue

            if r.status_code == 404:
                log.debug("Not found (HTTP 404): %s", url)
                return None

            r.raise_for_status()
            log.debug("Response %d from %s", r.status_code, url)
            return r.json()

        except requests.RequestException as exc:
            # 408/503 are routine on the search endpoints — back off and retry.
            log.warning(
                "Request failed: %s (attempt %d/%d)", exc, attempt, max_retries
            )
            time.sleep(2.0 * attempt)

    log.error("Giving up after %d attempts: %s", max_retries, url)
    return None


def repo_fields(data: dict) -> dict:
    """Project a GitHub repo payload onto the fields the collector uses."""
    license_info = data.get("license") or {}
    license_id = (license_info.get("spdx_id") or license_info.get("key") or "").lower()
    return {
        "full_name": data.get("full_name", ""),
        "html_url": data.get("html_url", ""),
        "clone_url": data.get("clone_url", ""),
        "stars": data.get("stargazers_count", 0),
        "forks": data.get("forks_count", 0),
        "license": license_id,
        "description": data.get("description") or "",
    }


def root_entries(full_name: str) -> set[str] | None:
    """Names of the entries at the repo root, or None if the request failed.

    Lets the collector reject non-apps (the Flutter SDK itself, awesome-lists,
    tutorial collections, monorepos) before paying for a clone.
    """
    time.sleep(API_DELAY)
    data = _get(f"{GITHUB_API}/repos/{full_name}/contents/")
    if not isinstance(data, list):
        return None
    return {entry.get("name", "") for entry in data}


def search_repositories(query: str, page: int = 1) -> list[dict] | None:
    """Search repos, most-starred first.

    Returns None on request failure and [] when the page is genuinely empty —
    the caller needs to tell those apart to page correctly.
    """
    time.sleep(REPO_SEARCH_DELAY)
    data = _get(
        f"{GITHUB_API}/search/repositories",
        params={
            "q": query,
            "sort": "stars",
            "order": "desc",
            "per_page": 100,
            "page": page,
        },
    )
    if not isinstance(data, dict):
        return None
    return data.get("items", [])
