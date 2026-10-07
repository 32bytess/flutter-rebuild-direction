import sqlite3
from pathlib import Path


def init_db(db_path: Path) -> sqlite3.Connection:
    db_path.parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(db_path)
    conn.execute("""
        CREATE TABLE IF NOT EXISTS scanned_files (
            item_url TEXT PRIMARY KEY,
            result TEXT NOT NULL,
            scanned_at TEXT NOT NULL DEFAULT (datetime('now'))
        )
        """)
    conn.execute("""
        CREATE TABLE IF NOT EXISTS scanned_repos (
            repo_name TEXT PRIMARY KEY,
            result TEXT NOT NULL,
            scanned_at TEXT NOT NULL DEFAULT (datetime('now'))
        )
        """)
    # The per-repository pipeline verdict. `scanned_repos` answers "did the GitHub harvest
    # accept this repository"; this answers "did driving it end to end produce anything the
    # corpus can use". They are deliberately separate tables because they are separate
    # questions, and because their keys differ -- see `_pipeline_key`.
    #
    # It exists to make two selections cheap and correct: after a wider harvest, run only the
    # repositories with no verdict; on a re-run, touch only the ones that produced contrasts.
    # The per-phase checkpoint directories cannot answer either, because they record only that
    # a phase finished, never under what rules -- which is why the stamps below are columns
    # rather than a comment in a runbook.
    conn.execute("""
        CREATE TABLE IF NOT EXISTS repo_pipeline (
            repo_name      TEXT PRIMARY KEY,
            stage          TEXT NOT NULL,
            eligible       INTEGER,
            scopes         INTEGER NOT NULL DEFAULT 0,
            contrasts      INTEGER NOT NULL DEFAULT 0,
            reason         TEXT,
            rules_version  TEXT,
            values_version TEXT,
            extractor      TEXT,
            updated_at     TEXT NOT NULL DEFAULT (datetime('now'))
        )
        """)
    conn.commit()
    return conn


def already_scanned_repo(conn: sqlite3.Connection, repo_name: str) -> bool:
    row = conn.execute(
        "SELECT 1 FROM scanned_repos WHERE repo_name = ?", (repo_name.lower(),)
    ).fetchone()
    return row is not None


def mark_repo_scanned(conn: sqlite3.Connection, repo_name: str, result: str) -> None:
    conn.execute(
        "INSERT OR IGNORE INTO scanned_repos (repo_name, result) VALUES (?, ?)",
        (repo_name.lower(), result),
    )
    conn.commit()


# ---------------------------------------------------------------------------
# The pipeline ledger
#
# `stage` is the last phase that completed, so an interrupted repository says where it
# stopped: clone | prepare | discover | mine | license | screen. Only `screen` is terminal.
#
# `eligible` is the verdict and is deliberately three-valued:
#     1     the repository contributed at least one eligible contrast
#     0     it reached a verdict and contributed nothing
#     NULL  no verdict yet -- the run was interrupted before the screen
# The distinction between 0 and NULL is what stops an interrupted run being read as a
# decided one, which is the failure the phase checkpoints already have and this table
# exists partly to avoid repeating.
# ---------------------------------------------------------------------------

PIPELINE_STAGES = ("clone", "prepare", "discover", "mine", "license", "screen")


def _pipeline_key(repo_name: str) -> str:
    """The `owner_name` key `mining` uses for clones, worktrees and checkpoints.

    NOT the key `scanned_repos` uses. That table stores `owner/name` lowercased, which is
    the shape the collector receives from the GitHub API; everything downstream of the
    harvest addresses a repository by its on-disk directory name instead. Normalising here,
    against the one canonical implementation, is what keeps a row written by the pipeline
    findable by a later `--eligible` selection that spelled the name differently.

    Imported inside the function because `scripts.collector.config` already imports
    `scripts.mining.config` at module level; doing it the other way round at import time
    would close the loop.
    """
    from scripts.mining.config import normalize_repo_name

    return normalize_repo_name(repo_name)


def record_pipeline_result(
    conn: sqlite3.Connection,
    repo_name: str,
    *,
    stage: str,
    eligible: bool | None = None,
    scopes: int = 0,
    contrasts: int = 0,
    reason: str | None = None,
    rules_version: str | None = None,
    values_version: str | None = None,
    extractor: str | None = None,
) -> None:
    """Upsert one repository's verdict. Always refreshes `updated_at`.

    An upsert rather than `INSERT OR IGNORE` -- unlike `mark_repo_scanned`, which records an
    immutable fact about a harvest, this row is rewritten every time the repository is driven
    again, and the newest verdict is the one that counts.
    """
    if stage not in PIPELINE_STAGES:
        raise ValueError(f"unknown stage {stage!r}; expected one of {PIPELINE_STAGES}")
    conn.execute(
        """
        INSERT INTO repo_pipeline
            (repo_name, stage, eligible, scopes, contrasts, reason,
             rules_version, values_version, extractor, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, datetime('now'))
        ON CONFLICT(repo_name) DO UPDATE SET
            stage          = excluded.stage,
            eligible       = excluded.eligible,
            scopes         = excluded.scopes,
            contrasts      = excluded.contrasts,
            reason         = excluded.reason,
            rules_version  = excluded.rules_version,
            values_version = excluded.values_version,
            extractor      = excluded.extractor,
            updated_at     = excluded.updated_at
        """,
        (
            _pipeline_key(repo_name),
            stage,
            None if eligible is None else int(eligible),
            scopes,
            contrasts,
            reason,
            rules_version,
            values_version,
            extractor,
        ),
    )
    conn.commit()


def pipeline_row(conn: sqlite3.Connection, repo_name: str) -> dict | None:
    """This repository's verdict, or None if it has never been driven."""
    cur = conn.execute(
        "SELECT * FROM repo_pipeline WHERE repo_name = ?", (_pipeline_key(repo_name),)
    )
    row = cur.fetchone()
    if row is None:
        return None
    return dict(zip([c[0] for c in cur.description], row))


def repos_needing_work(
    conn: sqlite3.Connection,
    names: list[str],
    *,
    rules_version: str,
    values_version: str,
    retry_failed: bool = False,
) -> list[str]:
    """The subset of `names` the pipeline still has work to do on, in the order given.

    A repository is skipped only when it holds a verdict that was reached under the rules
    now in force. Everything else is work:

      * no row                          -- never driven
      * `stage` is not `screen`         -- driven, but interrupted before a verdict
      * `eligible IS NULL`              -- same, seen from the other column
      * either stamp differs            -- decided under a different rule set or value table,
                                          so the verdict describes a screen that no longer
                                          exists. This is the case name-only checkpoints get
                                          wrong, and the reason the stamps are stored.

    `retry_failed` additionally re-drives repositories that reached `eligible = 0`, matching
    the flag of the same name on every walking phase: only the operator knows whether a
    failure was a transient `pub get` or a terminal `broken_source`.
    """
    todo: list[str] = []
    for name in names:
        row = pipeline_row(conn, name)
        if row is None:
            todo.append(name)
        elif row["stage"] != "screen" or row["eligible"] is None:
            todo.append(name)
        elif (row["rules_version"], row["values_version"]) != (rules_version, values_version):
            todo.append(name)
        elif retry_failed and not row["eligible"]:
            todo.append(name)
    return todo


def eligible_repos(conn: sqlite3.Connection) -> list[str]:
    """Every repository that produced at least one eligible contrast, normalised keys.

    The re-run selection: rebuilding the corpus does not need the repositories that were
    screened out, and on this harvest that is most of them.
    """
    return [
        r[0]
        for r in conn.execute(
            "SELECT repo_name FROM repo_pipeline WHERE eligible = 1 ORDER BY repo_name"
        ).fetchall()
    ]
