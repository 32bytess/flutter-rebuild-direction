"""The repo-major pipeline: its ledger, and the guard that keeps it off arm 2's tables.

Two things are checked here, and they fail in opposite directions.

The **ledger** decides which repositories a run drives. Its job is to be cheap without being
wrong: skip a repository that already holds a verdict, but never skip one whose verdict was
reached under a rule set or value table that is no longer in force. The per-phase checkpoint
directories cannot make that distinction -- the runbook says so in as many words, that they
record a phase finished and not that it finished with the same arguments -- so the stamps are
columns and these tests are what say they are read.

The **isolation guard** decides whether a run may start at all. `fixture_values` and
`maximal_branch` are two of the inputs the arm-2 corpus is a pure function of, and a `--full`
run writes both. A second corpus filling its slots into them moves `values_version()`, which
`new_samples/exclusions.json` records and `test_fixture_tables.py` asserts -- so arm 2 fails
its own integrity check with nothing under `new_samples/` touched. That failure is silent,
committed, and would be found long after the run that caused it, which is why the guard
refuses rather than warns and why it is tested here rather than trusted.
"""

from __future__ import annotations

import json
import time
from pathlib import Path

import pytest

from scripts import fixture_values, maximal_branch
from scripts.collector import db
from scripts.mining import config, pipeline

RULES, VALUES = "rules-aaaa", "values-bbbb"


@pytest.fixture
def conn(tmp_path):
    return db.init_db(tmp_path / "ledger.db")


def needing(conn, names, *, rules=RULES, values=VALUES, retry_failed=False):
    return db.repos_needing_work(conn, names, rules_version=rules,
                                 values_version=values, retry_failed=retry_failed)


# --- the ledger ---------------------------------------------------------------------------

def test_unknown_repository_is_work(conn):
    assert needing(conn, ["owner/alpha"]) == ["owner/alpha"]


def test_settled_verdict_is_skipped(conn):
    db.record_pipeline_result(conn, "owner/alpha", stage="screen", eligible=True,
                              scopes=3, contrasts=12, reason="ok",
                              rules_version=RULES, values_version=VALUES)
    assert needing(conn, ["owner/alpha"]) == []


def test_screened_out_repository_is_also_settled(conn):
    """`eligible = 0` is a decision, not a failure: re-walking it would buy nothing.

    This is the case that makes `--new` cheap on this harvest, where most repositories
    contribute nothing.
    """
    db.record_pipeline_result(conn, "owner/alpha", stage="screen", eligible=False,
                              reason="all_screened_out",
                              rules_version=RULES, values_version=VALUES)
    assert needing(conn, ["owner/alpha"]) == []
    assert needing(conn, ["owner/alpha"], retry_failed=True) == ["owner/alpha"]


@pytest.mark.parametrize("stage,eligible", [("prepare", False), ("mine", None),
                                            ("discover", None), ("license", None)])
def test_repository_interrupted_before_a_verdict_is_work(conn, stage, eligible):
    """Stopping at any phase before the screen is not a verdict.

    `eligible IS NULL` and `stage != 'screen'` are two views of the same fact, and either
    alone is enough: an interrupted run must never read as a decided one.
    """
    db.record_pipeline_result(conn, "owner/alpha", stage=stage, eligible=eligible,
                              reason="interrupted",
                              rules_version=RULES, values_version=VALUES)
    assert needing(conn, ["owner/alpha"]) == ["owner/alpha"]


def test_a_prepare_failure_is_settled_but_retryable(conn):
    """Distinct from the case above: `prepare` reached a verdict, it was just a negative one."""
    db.record_pipeline_result(conn, "owner/alpha", stage="screen", eligible=False,
                              reason="prepare_unclean",
                              rules_version=RULES, values_version=VALUES)
    assert needing(conn, ["owner/alpha"]) == []


@pytest.mark.parametrize("rules,values", [("rules-changed", VALUES),
                                          (RULES, "values-changed"),
                                          ("rules-changed", "values-changed")])
def test_a_stamp_change_invalidates_the_verdict(conn, rules, values):
    """The whole reason the stamps are stored.

    A verdict describes a screen. Change the rule set or the value table and that screen no
    longer exists, so the verdict describes nothing and the repository is work again --
    automatically, rather than because someone remembered to delete a checkpoint directory.
    """
    db.record_pipeline_result(conn, "owner/alpha", stage="screen", eligible=True,
                              contrasts=5, reason="ok",
                              rules_version=RULES, values_version=VALUES)
    assert needing(conn, ["owner/alpha"], rules=rules, values=values) == ["owner/alpha"]


def test_order_is_preserved(conn):
    names = ["o/c", "o/a", "o/b"]
    assert needing(conn, names) == names


@pytest.mark.parametrize("spelling", ["Owner/Alpha", "owner/alpha", "owner_alpha",
                                      "OWNER_ALPHA", "github.com/Owner/Alpha", "owner/alpha/"])
def test_every_spelling_finds_the_same_row(conn, spelling):
    """One repository, one row, however the name reached the caller.

    The collector writes `owner/name`, the clones on disk are `owner_name`, and a shell
    completion adds a trailing slash. A row that a later selection cannot find is a
    repository driven twice.
    """
    db.record_pipeline_result(conn, "Owner/Alpha", stage="screen", eligible=True,
                              contrasts=1, rules_version=RULES, values_version=VALUES)
    assert db.pipeline_row(conn, spelling) is not None
    assert needing(conn, [spelling]) == []


def test_the_newest_verdict_wins(conn):
    """An upsert, not `INSERT OR IGNORE`: unlike `scanned_repos`, this row is rewritten."""
    db.record_pipeline_result(conn, "owner/alpha", stage="mine", reason="interrupted",
                              rules_version=RULES, values_version=VALUES)
    db.record_pipeline_result(conn, "owner/alpha", stage="screen", eligible=True,
                              scopes=2, contrasts=7, reason="ok",
                              rules_version=RULES, values_version=VALUES)
    row = db.pipeline_row(conn, "owner/alpha")
    assert (row["stage"], row["eligible"], row["scopes"], row["contrasts"]) == ("screen", 1, 2, 7)


def test_eligible_repos_lists_only_contributors(conn):
    for name, eligible, contrasts in [("o/a", True, 4), ("o/b", False, 0), ("o/c", True, 1)]:
        db.record_pipeline_result(conn, name, stage="screen", eligible=eligible,
                                  contrasts=contrasts, rules_version=RULES,
                                  values_version=VALUES)
    assert db.eligible_repos(conn) == ["o_a", "o_c"]


def test_an_unknown_stage_is_refused(conn):
    with pytest.raises(ValueError):
        db.record_pipeline_result(conn, "o/a", stage="screeen")


def test_the_ledger_is_a_separate_table_from_the_harvest_scan(conn):
    """`scanned_repos` and `repo_pipeline` answer different questions and use different keys.

    Writing one must not be visible in the other, or "did the harvest accept it" and "did it
    produce contrasts" collapse into a single unreadable column.
    """
    db.mark_repo_scanned(conn, "Owner/Alpha", "accepted")
    assert db.pipeline_row(conn, "Owner/Alpha") is None
    db.record_pipeline_result(conn, "Owner/Alpha", stage="screen", eligible=True, contrasts=1)
    assert db.already_scanned_repo(conn, "Owner/Alpha")


# --- the isolation guard ------------------------------------------------------------------

def test_guard_refuses_a_second_corpus_on_the_committed_tables():
    with pytest.raises(SystemExit) as exc:
        pipeline.assert_tables_isolated(Path("new_samples_v3"))
    message = str(exc.value)
    assert "SPM_FIXTURE_VALUES" in message and "SPM_MAXIMAL_BRANCH" in message
    assert "values_version()" in message


def test_guard_allows_rebuilding_arm_2_itself():
    """`new_samples/` IS the corpus the committed tables describe, so they are its tables."""
    pipeline.assert_tables_isolated(config.PROJECT_ROOT / "new_samples")


def test_guard_passes_once_both_tables_are_moved(monkeypatch, tmp_path):
    monkeypatch.setattr(fixture_values, "VALUES_PATH", tmp_path / "fixture_values_v3.json")
    monkeypatch.setattr(maximal_branch, "TABLE_PATH", tmp_path / "maximal_branch_v3.json")
    pipeline.assert_tables_isolated(Path("new_samples_v3"))


def test_guard_refuses_when_only_one_table_is_moved(monkeypatch, tmp_path):
    """Half-isolating is worse than not isolating: the run still rewrites the other table."""
    monkeypatch.setattr(fixture_values, "VALUES_PATH", tmp_path / "fixture_values_v3.json")
    with pytest.raises(SystemExit) as exc:
        pipeline.assert_tables_isolated(Path("new_samples_v3"))
    assert "SPM_MAXIMAL_BRANCH" in str(exc.value)
    assert "SPM_FIXTURE_VALUES" not in str(exc.value)


# --- the table-path override ---------------------------------------------------------------

def test_table_path_defaults_are_the_committed_tables(monkeypatch):
    monkeypatch.delenv("SPM_FIXTURE_VALUES", raising=False)
    default = fixture_values.ROOT / "config" / "fixture_values.json"
    assert fixture_values.table_path("SPM_FIXTURE_VALUES", default) == default


def test_a_relative_override_resolves_against_the_container(monkeypatch):
    """So the variable reads the same from any working directory."""
    monkeypatch.setenv("SPM_FIXTURE_VALUES", "config/fixture_values_v3.json")
    default = fixture_values.ROOT / "config" / "fixture_values.json"
    assert fixture_values.table_path("SPM_FIXTURE_VALUES", default) == \
        fixture_values.ROOT / "config" / "fixture_values_v3.json"


def test_an_absolute_override_is_taken_as_given(monkeypatch, tmp_path):
    monkeypatch.setenv("SPM_FIXTURE_VALUES", str(tmp_path / "v3.json"))
    default = fixture_values.ROOT / "config" / "fixture_values.json"
    assert fixture_values.table_path("SPM_FIXTURE_VALUES", default) == tmp_path / "v3.json"


def test_a_missing_table_still_raises(monkeypatch, tmp_path):
    """The override must not weaken the guard it moves.

    A missing table raises ALWAYS, including on a genuine first run: hashing `b""` would
    answer with a plausible digest that silently invalidates every checkpoint.
    """
    monkeypatch.setattr(fixture_values, "VALUES_PATH", tmp_path / "absent.json")
    with pytest.raises(Exception):
        fixture_values.values_version()


# --- reading the screen's verdict ----------------------------------------------------------

def test_screen_verdict_reads_by_repository(tmp_path):
    (tmp_path / "exclusions.json").write_text(
        '{"by_repository": {"Owner/Alpha": '
        '{"eligible_contrasts": 25, "eligible_mover_scopes": 3}}}')
    assert pipeline.screen_verdict(tmp_path, "Owner/Alpha") == (3, 25)
    assert pipeline.screen_verdict(tmp_path, "owner_alpha") == (3, 25)


def test_a_repository_absent_from_the_report_is_a_decided_zero(tmp_path):
    """`by_repository` lists only survivors, so absence is a verdict rather than a gap."""
    (tmp_path / "exclusions.json").write_text('{"by_repository": {}}')
    assert pipeline.screen_verdict(tmp_path, "owner/alpha") == (0, 0)


def test_no_report_at_all_is_zero(tmp_path):
    assert pipeline.screen_verdict(tmp_path, "owner/alpha") == (0, 0)


# --- a screen refusal must not sink the run -------------------------------------------------

@pytest.fixture
def driven(tmp_path, monkeypatch):
    """`pipeline.run` with every phase stubbed to a no-op, so only the loop is under test.

    The phases are imported inside `run`, so they are patched on their own modules rather
    than on a name `run` holds. `DB_PATH` is redirected for the same reason the probe tree is
    elsewhere: `run` opens the real ledger otherwise.
    """
    from scripts.collector import config as collector_config
    from scripts.mining import (checkpoints, clone as clone_phase,
                                   discover as discover_phase,
                                   license_provenance as license_phase, mine as mine_phase,
                                   prepare as prepare_phase)

    monkeypatch.setattr(collector_config, "DB_PATH", tmp_path / "ledger.db")
    # `run` defaults `--source` to `PROBE_DIR / "samples_v2"`, and the screen is now SKIPPED
    # when that directory does not exist. Pointed at a tmp mine that does, so these tests
    # assert the loop rather than whether this machine happens to carry a probe tree.
    (tmp_path / "probe" / "samples_v2").mkdir(parents=True)
    monkeypatch.setattr(config, "PROBE_DIR", tmp_path / "probe")
    # Both generated tables, redirected for EVERY test that drives the loop -- the same tmp
    # paths the `tables` fixture uses, so combining the two is a no-op. Without this these
    # tests read the live `config/`, which made them depend on whether a rebuild happened to
    # be in flight, and -- once a failed seeding pass began rolling its own table back --
    # gave a test run the power to delete a real one.
    monkeypatch.setattr(fixture_values, "VALUES_PATH", tmp_path / "fixture_values.json")
    monkeypatch.setattr(maximal_branch, "TABLE_PATH", tmp_path / "maximal_branch.json")
    for module in (clone_phase, prepare_phase, discover_phase, mine_phase, license_phase):
        monkeypatch.setattr(module, "run", lambda *a, **k: None)
    monkeypatch.setattr(pipeline, "prepared_repos", lambda: {"owner/alpha", "owner/beta"})
    monkeypatch.setattr(pipeline, "discovered_repos", lambda: {"owner/alpha", "owner/beta"})
    monkeypatch.setattr(checkpoints, "load", lambda phase, name: {"status": "ok"})
    monkeypatch.setattr(pipeline, "extractor_version", lambda: "spm 0.7.1")
    return monkeypatch


def test_a_screen_refusal_is_recorded_and_the_next_repository_still_runs(driven, tmp_path):
    """R17's vacuity guard fired on repository 5 of the 2026-09-06 run and ended the process.

    The screen is called as a library, so a refusal arrives as `SystemExit`, and an uncaught
    one is indistinguishable from the run finishing. Every repository after it went unmined
    -- days of walking, discarded by a guard whose verdict was about the corpus and not about
    any one repository.
    """
    seen = []

    def refuse(source, dest, *, init, extra):
        seen.append(dest)
        raise SystemExit("R17_package_license has no input: not one file ... reports inlining")

    driven.setattr(pipeline, "_screen", refuse)

    summary = pipeline.run(["owner/alpha", "owner/beta"],
                           dest=config.PROJECT_ROOT / "new_samples")

    assert len(seen) == 2, "the second repository was still driven"
    assert summary["driven"] == 2
    assert [r["reason"].split(":")[0] for r in summary["repositories"]] == \
        ["screen_refused", "screen_refused"]
    assert summary["eligible_repositories"] == 0


def test_the_refusal_reason_reaches_the_ledger(driven, tmp_path):
    """`--new` skips a repository the ledger has settled, so a refusal that recorded nothing
    would be re-driven from scratch on the next run, mine and all."""
    driven.setattr(pipeline, "_screen",
                   lambda *a, **k: (_ for _ in ()).throw(SystemExit("no input")))

    pipeline.run(["owner/alpha"], dest=config.PROJECT_ROOT / "new_samples")

    conn = db.init_db(tmp_path / "ledger.db")
    # Addressed by the on-disk `owner_name` key `_pipeline_key` normalises to, not by the
    # `owner/name` the caller passed -- which is the whole point of that normalisation.
    row = conn.execute("select stage, eligible, reason, extractor from repo_pipeline "
                       "where repo_name = ?",
                       (config.normalize_repo_name("owner/alpha"),)).fetchone()
    assert row is not None, "the refusal wrote no ledger row"
    assert row[0] == "mine"
    assert row[1] is None, "refused is not the same verdict as screened-out"
    assert row[2].startswith("screen_refused:")
    assert row[3] == "spm 0.7.1"


# --- the two generated tables must agree about which run this is ----------------------------

@pytest.fixture
def tables(monkeypatch, tmp_path):
    """Point both generated tables at a tmp dir, absent until a test creates them."""
    monkeypatch.setattr(fixture_values, "VALUES_PATH", tmp_path / "fixture_values.json")
    monkeypatch.setattr(maximal_branch, "TABLE_PATH", tmp_path / "maximal_branch.json")
    return tmp_path


def test_a_half_torn_down_pair_is_refused_before_the_walk(driven, tables):
    """The 2026-09-06 failure, in one test.

    `config/fixture_values.json` emptied to `{}` beside a DELETED `config/maximal_branch.json`
    read as a RESUME, because `values_version()` hashes `{}` as happily as a filled table.
    The run then mined four repositories and died in phase 4 of repository 5's screen, on the
    override table the resume path requires. Nothing about that state is screenable: `--init`
    is refused because the values table exists, `--resume` raises because the other does not.
    """
    (tables / "fixture_values.json").write_text("{}\n")   # emptied, not deleted
    driven.setattr(pipeline, "_screen", lambda *a, **k: pytest.fail("walked anyway"))

    with pytest.raises(SystemExit) as exc:
        pipeline.run(["owner/alpha"], dest=config.PROJECT_ROOT / "new_samples")

    message = str(exc.value)
    assert "disagree about which run this is" in message
    assert "maximal_branch.json: ABSENT" in message
    assert "git checkout -- config/" in message, "the refusal must name the remedy"


def test_the_refusal_fires_before_anything_is_mined(driven, tables):
    """It is a startup check or it is worthless: the point is to cost zero hours."""
    walked = []
    from scripts.mining import mine as mine_phase
    driven.setattr(mine_phase, "run", lambda *a, **k: walked.append(a))
    (tables / "fixture_values.json").write_text("{}\n")

    with pytest.raises(SystemExit):
        pipeline.run(["owner/alpha", "owner/beta"], dest=config.PROJECT_ROOT / "new_samples")

    assert walked == [], "the walk started before the tables were checked"


def test_skip_screen_tolerates_a_half_torn_down_pair(driven, tables):
    """`--skip-screen` writes neither table, and mining is exactly what a torn-down tree
    should be free to do first -- it is how you get back to a screenable state."""
    (tables / "fixture_values.json").write_text("{}\n")

    summary = pipeline.run(["owner/alpha", "owner/beta"],
                           dest=config.PROJECT_ROOT / "new_samples", skip_screen=True)

    assert summary["driven"] == 2
    assert [r["reason"] for r in summary["repositories"]] == \
        ["mined_not_screened", "mined_not_screened"]


def test_both_tables_absent_is_a_first_run(driven, tables):
    seen = []

    def seed(source, dest, *, init, extra):
        seen.append(init)
        (tables / "fixture_values.json").write_text("{}\n")     # what --init does
        (tables / "maximal_branch.json").write_text("{}\n")     # what phase 4 does
        return 0

    driven.setattr(pipeline, "_screen", seed)
    driven.setattr(pipeline, "screen_verdict", lambda dest, name: (0, 0))

    pipeline.run(["owner/alpha", "owner/beta"], dest=config.PROJECT_ROOT / "new_samples")

    assert seen == [True, False], "only the seed pass gets --init; the rest resume onto it"


def test_both_tables_present_is_a_resume(driven, tables):
    (tables / "fixture_values.json").write_text("{}\n")
    (tables / "maximal_branch.json").write_text("{}\n")
    seen = []
    driven.setattr(pipeline, "_screen",
                   lambda source, dest, *, init, extra: (seen.append(init), 0)[1])
    driven.setattr(pipeline, "screen_verdict", lambda dest, name: (0, 0))

    pipeline.run(["owner/alpha"], dest=config.PROJECT_ROOT / "new_samples")

    assert seen == [False]


def test_an_empty_override_table_is_a_seeded_one(driven, tables):
    """Presence, not content. A corpus with no decidable branch binding writes `{}` -- and
    `merge_table`'s own contract is that an absent table and an empty one mean opposite
    things, so the check must not collapse them."""
    (tables / "fixture_values.json").write_text('{"0058": {}}\n')
    (tables / "maximal_branch.json").write_text("{}\n")
    driven.setattr(pipeline, "_screen", lambda *a, **k: 0)
    driven.setattr(pipeline, "screen_verdict", lambda dest, name: (0, 0))

    summary = pipeline.run(["owner/alpha"], dest=config.PROJECT_ROOT / "new_samples")

    assert summary["driven"] == 1, "an empty override table was read as a missing one"


# --- a seeding pass is atomic: both tables, or neither ---------------------------------------
#
# The 2026-09-06 wedge. `--init` writes the values table in phase 0 and the branch table only
# in phase 4, so a seeding screen that dies in between leaves the pair MIXED -- the exact state
# the startup guard above refuses. The old latch was cleared only by `rc == 0`, so every batch
# after that failure re-offered `--init` to a table the seed itself had written, and
# `init_values_table` refused it: 35 consecutive `screen_refused` batches while the mine ran
# perfectly. The walk now MAINTAINS the invariant the guard checks, instead of only being
# checked against it once.


@pytest.mark.parametrize("outcome, expected", [
    (lambda: (_ for _ in ()).throw(SystemExit("no feature vectors")), "screen_refused"),
    (lambda: (_ for _ in ()).throw(RuntimeError("phase 4 blew up")), "screen_failed"),
    (lambda: 3, "screen_exit_3"),
])
def test_a_failed_seeding_pass_is_rolled_back(driven, tables, outcome, expected):
    """All three failure paths, because 2026-09-06 arrived by two of them in one day.

    The seed must be undone whichever way the pass died, or the NEXT batch inherits a mix
    that neither `--init` nor `--resume` can screen.
    """
    seen = []

    def screen(source, dest, *, init, extra):
        seen.append(init)
        if init:
            (tables / "fixture_values.json").write_text("{}\n")   # what phase 0 does
        return outcome()

    driven.setattr(pipeline, "_screen", screen)

    summary = pipeline.run(["owner/alpha", "owner/beta"],
                           dest=config.PROJECT_ROOT / "new_samples", jobs=1)

    assert seen == [True, True], \
        "the second batch was not offered --init, so the rolled-back seed never retried"
    assert not (tables / "fixture_values.json").is_file(), \
        "the half-seeded values table survived a failed seeding pass"
    assert not (tables / "maximal_branch.json").is_file()
    assert [r["reason"].split(":")[0] for r in summary["repositories"]] == \
        [expected, expected]


def test_the_rollback_never_touches_a_finished_pair(tables):
    """`rollback_seed` is about a HALF seed. Once phase 4 has written the branch table the
    pair is complete, the next pass resumes onto it, and removing the values table would
    invalidate every checkpoint the run just earned."""
    (tables / "fixture_values.json").write_text('{"0058": {"binding": "x"}}\n')
    (tables / "maximal_branch.json").write_text("{}\n")

    assert pipeline.rollback_seed() is False
    assert json.loads((tables / "fixture_values.json").read_text()) == \
        {"0058": {"binding": "x"}}


def test_a_seeding_pass_that_reaches_phase_four_is_kept(driven, tables):
    """The success path is unchanged: seed once, then resume onto the pair forever."""
    seen = []

    def screen(source, dest, *, init, extra):
        seen.append(init)
        (tables / "fixture_values.json").write_text("{}\n")
        (tables / "maximal_branch.json").write_text("{}\n")     # phase 4 reached
        return 0

    driven.setattr(pipeline, "_screen", screen)
    driven.setattr(pipeline, "screen_verdict", lambda dest, name: (2, 7))

    summary = pipeline.run(["owner/alpha", "owner/beta"],
                           dest=config.PROJECT_ROOT / "new_samples", jobs=1)

    assert seen == [True, False], "only the seed pass gets --init"
    assert (tables / "fixture_values.json").is_file(), "a successful seed was rolled back"
    assert summary["values_version"] is not None, \
        "the stamp only exists after the seed, and the ledger must carry it"


# --- nothing mined yet is not a screen failure -----------------------------------------------

def test_the_screen_is_skipped_before_the_mine_has_written_anything(driven, tables, tmp_path):
    """`--source` is written by `mine`, and does not exist until a repository transplants its
    first group. On 2026-09-06 the walk's first 14 repositories each recorded
    `screen_refused: 2` -- argparse's exit code for `--source is not a directory`, with the
    message on a stderr nobody kept. Screening an absent mine is vacuous."""
    driven.setattr(pipeline, "_screen", lambda *a, **k: pytest.fail("screened an absent mine"))

    summary = pipeline.run(["owner/alpha"], dest=config.PROJECT_ROOT / "new_samples",
                           source=tmp_path / "never-mined")

    assert [r["reason"] for r in summary["repositories"]] == ["nothing_mined_yet"]
    assert summary["repositories"][0]["eligible"] is None, \
        "unsettled, so --new re-drives it; it is not a decided zero"


def test_a_bare_exit_code_is_not_recorded_as_a_reason(driven, tables):
    """`str(SystemExit(2))` is `"2"`, and argparse's actual message went to stderr. A ledger
    row reading `screen_refused: 2` says nothing about what was wrong."""
    driven.setattr(pipeline, "_screen",
                   lambda *a, **k: (_ for _ in ()).throw(SystemExit(2)))

    summary = pipeline.run(["owner/alpha"], dest=config.PROJECT_ROOT / "new_samples")

    assert summary["repositories"][0]["reason"] == "screen_argv_rejected_2"


def test_a_screen_crash_is_recorded_and_the_next_repository_still_runs(driven, tmp_path):
    """The `SystemExit` clause was not enough on 2026-09-06.

    R17's refusal arrives as `SystemExit` and was caught. The `FileNotFoundError` phase 4
    raised on the missing override table is an ordinary exception, walked straight past it,
    and ended the run with 219 repositories unwalked -- the identical failure the refusal
    clause exists to prevent, one exception class over.
    """
    seen = []

    def crash(source, dest, *, init, extra):
        seen.append(dest)
        raise FileNotFoundError("override table missing: config/maximal_branch.json")

    driven.setattr(pipeline, "_screen", crash)

    summary = pipeline.run(["owner/alpha", "owner/beta"],
                           dest=config.PROJECT_ROOT / "new_samples")

    assert len(seen) == 2, "the second repository was still driven"
    assert summary["driven"] == 2
    assert all(r["reason"].startswith("screen_failed: FileNotFoundError")
               for r in summary["repositories"])
    assert summary["eligible_repositories"] == 0


# --- batching: N repositories together, concurrency inside each phase ------------------------

@pytest.fixture
def spy(driven, tables):
    """`driven`, plus a record of every phase call and the arguments it was given."""
    from scripts.mining import (clone as clone_phase, discover as discover_phase,
                                   license_provenance as license_phase, mine as mine_phase,
                                   prepare as prepare_phase)
    calls = {"screen": [], "phases": []}
    depth = {"n": 0}

    def watch(label, module):
        def fake(repos=None, **kw):
            # Every phase rewrites a corpus-wide aggregate in full when it finishes, so a
            # re-entrant call would race on that rewrite. The batch must never be threaded.
            depth["n"] += 1
            assert depth["n"] == 1, f"{label} was re-entered concurrently"
            calls["phases"].append((label, list(repos or []), kw.get("jobs")))
            depth["n"] -= 1
            return None
        module.run = fake

    for label, module in (("clone", clone_phase), ("prepare", prepare_phase),
                          ("discover", discover_phase), ("mine", mine_phase),
                          ("license", license_phase)):
        driven.setattr(module, "run", lambda *a, **k: None)   # restored by monkeypatch
        watch(label, module)

    def screen(source, dest, *, init, extra):
        calls["screen"].append(init)
        (tables / "fixture_values.json").write_text("{}\n")
        (tables / "maximal_branch.json").write_text("{}\n")
        return 0

    driven.setattr(pipeline, "_screen", screen)
    driven.setattr(pipeline, "screen_verdict", lambda dest, name: (1, 2))
    driven.setattr(pipeline, "prepared_repos", lambda: {f"owner/r{i}" for i in range(9)})
    driven.setattr(pipeline, "discovered_repos", lambda: {f"owner/r{i}" for i in range(9)})
    return calls


REPOS = [f"owner/r{i}" for i in range(5)]


def test_jobs_two_drives_five_repositories_in_three_batches(spy):
    pipeline.run(REPOS, dest=config.PROJECT_ROOT / "new_samples", jobs=2)

    # One screen per BATCH, not per repository: it is a corpus-wide pass over shared state.
    assert len(spy["screen"]) == 3, "expected 3 batches, got a screen per repository"
    mined = [repos for label, repos, _ in spy["phases"] if label == "mine"]
    assert [len(r) for r in mined] == [2, 2, 1]


def test_jobs_is_handed_to_the_phases_not_used_to_thread_the_batch(spy):
    pipeline.run(REPOS, dest=config.PROJECT_ROOT / "new_samples", jobs=2)

    for label, _repos, jobs in spy["phases"]:
        if label in ("prepare", "discover", "mine"):
            assert jobs == 2, f"{label} was not given the batch size"
    # `clone` is network-bound and takes no jobs; it is called per repository.
    assert all(len(r) == 1 for label, r, _ in spy["phases"] if label == "clone")


def test_jobs_one_is_the_serial_walk(spy):
    pipeline.run(REPOS, dest=config.PROJECT_ROOT / "new_samples", jobs=1)

    assert len(spy["screen"]) == 5, "a batch of one is one repository, screened each time"
    mined = [repos for label, repos, _ in spy["phases"] if label == "mine"]
    assert [len(r) for r in mined] == [1, 1, 1, 1, 1]


def test_every_repository_still_reaches_the_ledger_under_jobs_two(spy):
    summary = pipeline.run(REPOS, dest=config.PROJECT_ROOT / "new_samples", jobs=2)

    assert summary["driven"] == 5
    assert [r["repo"] for r in summary["repositories"]] == REPOS
    assert summary["eligible_repositories"] == 5


# --- a dependency verdict reached under contention is provisional ---------------------------

def test_a_dependency_failure_under_jobs_two_is_re_driven_serially(driven, tables):
    """A shared pub cache can fabricate `unsatisfiable_dependencies`, and a settled verdict is
    never re-driven -- `--new` skips it forever. So the corpus would be selected on which
    repository lost a cache race."""
    from scripts.mining import checkpoints as cp, prepare as prepare_phase

    seen = []
    driven.setattr(prepare_phase, "run",
                   lambda repos=None, **kw: seen.append((list(repos or []), kw.get("jobs"))))
    driven.setattr(pipeline, "prepared_repos", set)          # nothing ever prepares clean
    driven.setattr(cp, "load", lambda phase, name: {"status": "unsatisfiable_dependencies"})
    (tables / "fixture_values.json").write_text("{}\n")
    (tables / "maximal_branch.json").write_text("{}\n")

    pipeline.run(["owner/alpha", "owner/beta"],
                 dest=config.PROJECT_ROOT / "new_samples", jobs=2)

    assert seen[0] == (["owner/alpha", "owner/beta"], 2), "the batch ran concurrently first"
    # ...then each is re-driven on its own, where no contention can explain the failure.
    assert seen[1:] == [(["owner/alpha"], 1), (["owner/beta"], 1)]


def test_a_source_failure_is_never_re_driven(driven, tables):
    """`broken_source` cannot be caused by contention, so re-driving it only wastes minutes."""
    from scripts.mining import checkpoints as cp, prepare as prepare_phase

    seen = []
    driven.setattr(prepare_phase, "run",
                   lambda repos=None, **kw: seen.append((list(repos or []), kw.get("jobs"))))
    driven.setattr(pipeline, "prepared_repos", set)
    driven.setattr(cp, "load", lambda phase, name: {"status": "broken_source"})
    (tables / "fixture_values.json").write_text("{}\n")
    (tables / "maximal_branch.json").write_text("{}\n")

    pipeline.run(["owner/alpha", "owner/beta"],
                 dest=config.PROJECT_ROOT / "new_samples", jobs=2)

    assert len(seen) == 1, "a source failure was re-driven"


def test_serial_runs_defer_nothing(driven, tables):
    """Serially there is no race to blame, so nothing is provisional."""
    from scripts.mining import checkpoints as cp, prepare as prepare_phase

    seen = []
    driven.setattr(prepare_phase, "run",
                   lambda repos=None, **kw: seen.append(list(repos or [])))
    driven.setattr(pipeline, "prepared_repos", set)
    driven.setattr(cp, "load", lambda phase, name: {"status": "unsatisfiable_dependencies"})
    (tables / "fixture_values.json").write_text("{}\n")
    (tables / "maximal_branch.json").write_text("{}\n")

    pipeline.run(["owner/alpha"], dest=config.PROJECT_ROOT / "new_samples", jobs=1)

    assert seen == [["owner/alpha"]], "a serial verdict was treated as provisional"


# --- the pub-get lock -----------------------------------------------------------------------

def test_pub_get_resolutions_never_overlap(monkeypatch, tmp_path):
    """The reason the pipeline could stop being strictly serial.

    Two concurrent `pub get`s race on the shared cache at ~/.pub-cache and fail in a way
    indistinguishable from a genuinely unsatisfiable pubspec.
    """
    import threading
    from scripts.mining import prepare as prepare_phase

    live, overlapped = [], []
    barrier = threading.Lock()

    def slow_pub_get(root):
        with barrier:
            live.append(1)
            if len(live) > 1:
                overlapped.append(True)
        time.sleep(0.02)
        with barrier:
            live.pop()
        return {"ok": True, "overrides": {}}

    import scripts.flutter_checkout as fc
    monkeypatch.setattr(fc, "pub_get", slow_pub_get)
    monkeypatch.setattr(fc, "apply_overrides", lambda *a, **k: None)

    threads = [threading.Thread(target=prepare_phase.pub_get_with_conflicts, args=(tmp_path,))
               for _ in range(4)]
    for t in threads:
        t.start()
    for t in threads:
        t.join()

    assert not overlapped, "two pub get resolutions ran at once"


# --- --from-scratch: recoverability, not regenerability -------------------------------------

def _git_repo(root: Path) -> None:
    import subprocess
    for cmd in (["init", "-q"], ["config", "user.email", "t@t"], ["config", "user.name", "t"]):
        subprocess.run(["git", *cmd], cwd=root, check=True, capture_output=True)


def _commit_all(root: Path) -> None:
    import subprocess
    subprocess.run(["git", "add", "-A"], cwd=root, check=True, capture_output=True)
    subprocess.run(["git", "commit", "-qm", "corpus"], cwd=root, check=True,
                   capture_output=True)


@pytest.fixture
def corpus(monkeypatch, tmp_path):
    """A committed corpus in its own git repo, with both tables redirected into it."""
    monkeypatch.setattr(config, "PROJECT_ROOT", tmp_path)
    monkeypatch.setattr(fixture_values, "VALUES_PATH", tmp_path / "config/fixture_values.json")
    monkeypatch.setattr(maximal_branch, "TABLE_PATH", tmp_path / "config/maximal_branch.json")
    _git_repo(tmp_path)
    dest = tmp_path / "new_samples"
    (dest / "0058").mkdir(parents=True)
    (dest / "0058" / "rev_001_aaaa.dart").write_text("// role\n")
    (tmp_path / "config").mkdir()
    (tmp_path / "config/fixture_values.json").write_text("{}\n")
    (tmp_path / "config/maximal_branch.json").write_text("{}\n")
    _commit_all(tmp_path)
    return dest


def test_from_scratch_clears_a_committed_corpus(corpus):
    """The 45 committed groups are recoverable from HEAD, so deleting them costs nothing."""
    pipeline.clear_for_rebuild(corpus)

    assert not corpus.exists()
    assert not fixture_values.VALUES_PATH.is_file()
    assert not maximal_branch.TABLE_PATH.is_file()


def test_from_scratch_refuses_over_uncommitted_work(corpus):
    """Only what is COMMITTED survives a delete, and git is what decides that."""
    (corpus / "0058" / "hand_written.dart").write_text("// somebody's work\n")

    with pytest.raises(SystemExit) as exc:
        pipeline.clear_for_rebuild(corpus)

    message = str(exc.value)
    assert "uncommitted or untracked" in message
    assert "hand_written.dart" in message
    assert corpus.exists(), "the tree was deleted despite the refusal"


def test_from_scratch_refuses_over_a_measurement(corpus):
    """Arm 2 is at zero device measurements and a rebuild must not destroy the first one."""
    (corpus / "0058" / "performance.jsonl").write_text('{"ms": 1}\n')
    _commit_all(config.PROJECT_ROOT)          # committed, and STILL refused

    with pytest.raises(SystemExit) as exc:
        pipeline.clear_for_rebuild(corpus)

    assert "measurement file(s)" in str(exc.value)
    assert corpus.exists()


def test_from_scratch_does_not_ask_whether_source_can_regenerate_the_corpus(corpus):
    """`screen/rebuild.teardown` refuses over any file `--source` cannot regenerate. That is
    right when source and dest describe the same mine and wrong here: a re-harvest rebuilds
    the mine, so `probe_v2/samples_v2` holds different group ids than the corpus was exported
    from. On 2026-09-06 that check called all 45 committed groups authored."""
    other_source = config.PROJECT_ROOT / "probe_v2" / "samples_v2" / "9999"
    other_source.mkdir(parents=True)          # a group id the corpus has never heard of
    (other_source / "rev_001_zzzz.dart").write_text("// a different mine\n")
    _commit_all(config.PROJECT_ROOT)

    pipeline.clear_for_rebuild(corpus)        # a source sharing no group id is irrelevant

    assert not corpus.exists()


# --- the walk order ------------------------------------------------------------------------

def test_cheapest_repository_is_walked_first(monkeypatch):
    """A batch publishes its groups only when its mine call returns, so order decides how
    soon the corpus is measurable. This harvest is skewed hard: median 2 commits, eight
    repositories holding half the total."""
    cost = {"o/big": 3625, "o/small": 2, "o/mid": 281}
    monkeypatch.setattr(pipeline, "repo_cost", lambda n, *, since: cost[n])

    order, costs = pipeline.walk_order(list(cost), since=1683676800)

    assert order == ["o/small", "o/mid", "o/big"]
    assert costs == cost


def test_equal_cost_repositories_are_ordered_by_name(monkeypatch):
    """The tie-break is not cosmetic. Walk order decides which repository mints which group
    id, the duplicate pass keeps the LOWEST id, and a run that cannot restate its order
    cannot reproduce those ids."""
    monkeypatch.setattr(pipeline, "repo_cost", lambda n, *, since: 2)
    names = ["o/charlie", "o/alpha", "o/bravo"]

    first, _ = pipeline.walk_order(names, since=None)
    again, _ = pipeline.walk_order(list(reversed(names)), since=None)

    assert first == again == ["o/alpha", "o/bravo", "o/charlie"]


def test_a_repository_with_no_clone_is_walked_last(monkeypatch):
    """Unknown cost may mean huge, and putting a giant first is the failure being fixed."""
    monkeypatch.setattr(pipeline, "repo_cost",
                        lambda n, *, since: None if n == "o/uncloned" else 900)

    order, costs = pipeline.walk_order(["o/uncloned", "o/known"], since=None)

    assert order == ["o/known", "o/uncloned"]
    assert "o/uncloned" not in costs, "an unknown cost was reported as known"


def test_cost_asks_git_nothing_when_the_clone_is_absent(monkeypatch, tmp_path):
    """224 repositories times one doomed subprocess is a slow way to learn nothing."""
    import subprocess
    monkeypatch.setattr(config, "REPOS_FULL_ROOT", tmp_path)
    monkeypatch.setattr(subprocess, "run",
                        lambda *a, **k: pytest.fail("git was run for a missing clone"))

    assert pipeline.repo_cost("owner/never-cloned", since=None) is None


def test_cost_survives_a_git_failure(monkeypatch, tmp_path):
    """Ranking is an optimisation. A repository that cannot be counted is walked last, not
    crashed on."""
    import subprocess
    (tmp_path / "owner_broken").mkdir()
    monkeypatch.setattr(config, "REPOS_FULL_ROOT", tmp_path)
    monkeypatch.setattr(subprocess, "run",
                        lambda *a, **k: (_ for _ in ()).throw(OSError("no git")))

    assert pipeline.repo_cost("owner/broken", since=None) is None


def test_order_candidates_keeps_the_file_order(spy):
    shuffled = ["owner/r3", "owner/r0", "owner/r4", "owner/r1", "owner/r2"]

    summary = pipeline.run(shuffled, dest=config.PROJECT_ROOT / "new_samples",
                           order="candidates")

    assert summary["walk"] == shuffled
    assert [r["repo"] for r in summary["repositories"]] == shuffled


def test_the_order_is_recorded_in_the_summary(spy, monkeypatch):
    """A rebuild that cannot restate its order cannot reproduce the group ids."""
    monkeypatch.setattr(pipeline, "repo_cost",
                        lambda n, *, since: {"owner/r0": 9, "owner/r1": 1}.get(n, 5))

    summary = pipeline.run(["owner/r0", "owner/r1", "owner/r2"],
                           dest=config.PROJECT_ROOT / "new_samples", order="cheapest")

    assert summary["order"] == "cheapest"
    assert summary["walk"] == ["owner/r1", "owner/r2", "owner/r0"]


def test_batch_mates_are_cost_adjacent(spy, monkeypatch):
    """Why --jobs 2 stays nearly free: the barrier only costs the difference between two
    neighbours in a sorted walk, not between the cheapest and the most expensive."""
    cost = {"owner/r0": 1, "owner/r1": 2, "owner/r2": 300, "owner/r3": 301}
    monkeypatch.setattr(pipeline, "repo_cost", lambda n, *, since: cost[n])

    pipeline.run(["owner/r3", "owner/r0", "owner/r2", "owner/r1"],
                 dest=config.PROJECT_ROOT / "new_samples", jobs=2, order="cheapest")

    mined = [repos for label, repos, _ in spy["phases"] if label == "mine"]
    assert mined == [["owner/r0", "owner/r1"], ["owner/r2", "owner/r3"]]
