"""The per-repository sweep: resume, carry-forward, crash isolation, deterministic order.

`prepare`, `discover` and `mine` each wrote this loop out. The step worth having in one place
is the carry-forward: every one of those phases rewrites a corpus-wide aggregate IN FULL, so a
repository missing from the results loses every row it ever contributed, and a `--repos`-scoped
re-run without it silently truncates the corpus to the one repository named. That failure is
quiet, which is exactly why it deserves a test.
"""

from __future__ import annotations

import pytest

from scripts.mining import checkpoints, config


@pytest.fixture
def probe(tmp_path, monkeypatch):
    monkeypatch.setattr(config, "PROBE_DIR", tmp_path)
    return tmp_path


# Every output path is bound off `PROBE_DIR` at IMPORT time (config.py:45-56), so moving
# `PROBE_DIR` alone moves the checkpoint directories -- resolved through
# `checkpoints.directory()` on each call -- and NOTHING ELSE. A phase redirected that way
# still writes its report, targets and history files into the live `probe_v2/`. Not
# hypothetical: writing this test did exactly that, dropping an empty `prepare_report.json`
# over the real one, which is the file `pipeline.prepared_repos()` reads `clean_repos` from.
_PROBE_OUTPUTS = ("CLONE_REPORT", "PREPARE_REPORT", "TARGETS", "HISTORY_FEATURES",
                  "HISTORY_PAIRS", "MINE_SUMMARY", "STATE_FILE", "SAMPLES_V2")


@pytest.fixture
def probe_tree(tmp_path, monkeypatch):
    """`probe`, plus every path constant derived from it. For anything that RUNS a phase
    rather than calling `sweep` directly.

    `PROJECT_ROOT` moves with it because each phase ends by logging its output path as
    `relative_to(config.PROJECT_ROOT)`, which raises for a tmp dir outside the repo. And
    `targets.jsonl` is created empty because `mine` refuses outright when the file is ABSENT
    (mine.py:753) -- absent means discover never ran, empty means it ran and found nothing,
    and only the second is "nothing to walk".
    """
    monkeypatch.setattr(config, "PROBE_DIR", tmp_path)
    monkeypatch.setattr(config, "PROJECT_ROOT", tmp_path)
    for name in _PROBE_OUTPUTS:
        monkeypatch.setattr(config, name, tmp_path / getattr(config, name).name)
    config.TARGETS.write_text("", encoding="utf-8")
    # An empty candidate list, so the test runs without the data repository linked in.
    monkeypatch.setattr(config, "CANDIDATES_FILE", tmp_path / "candidates.jsonl")
    config.CANDIDATES_FILE.write_text("", encoding="utf-8")
    return tmp_path


def _repos(*names):
    return [{"repo_name": n} for n in names]


def _ok(repo):
    return {"repo_name": repo["repo_name"], "status": "ok"}


def test_every_repository_is_walked_once(probe):
    seen = []

    def work(repo):
        seen.append(repo["repo_name"])
        return _ok(repo)

    records, this_run, *_ = checkpoints.sweep("prepare", _repos("b", "a", "c"), work)

    assert sorted(seen) == ["a", "b", "c"]
    assert this_run == 3
    assert [r["repo_name"] for r in records] == ["a", "b", "c"], "sorted, not walk order"


def test_results_are_ordered_by_name_not_by_completion(probe):
    """Thread completion order must not reach the aggregate: the corpus would differ
    between two runs over identical inputs."""
    records, *_ = checkpoints.sweep("prepare", _repos("z", "m", "a"), _ok, jobs=3)
    assert [r["repo_name"] for r in records] == ["a", "m", "z"]


def test_a_crash_is_recorded_and_does_not_sink_the_run(probe):
    def work(repo):
        if repo["repo_name"] == "bad":
            raise RuntimeError("pub get exploded")
        return _ok(repo)

    records, *_ = checkpoints.sweep("prepare", _repos("good", "bad"), work, jobs=2)

    by_name = {r["repo_name"]: r for r in records}
    assert by_name["good"]["status"] == "ok"
    assert by_name["bad"]["status"] == "crashed"
    assert "pub get exploded" in by_name["bad"]["error"]
    # ...and it is durable, so the next run can retry it with --retry-failed.
    assert checkpoints.load("prepare", "bad")["status"] == "crashed"


def test_resume_skips_what_is_already_checkpointed(probe):
    checkpoints.write("prepare", "done", {"repo_name": "done", "status": "ok"})
    walked = []

    def work(repo):
        walked.append(repo["repo_name"])
        return _ok(repo)

    records, this_run, *_ = checkpoints.sweep(
        "prepare", _repos("done", "fresh"), work, resume=True)

    assert walked == ["fresh"]
    assert this_run == 1, "the resumed one is not 'this run'"
    assert {r["repo_name"] for r in records} == {"done", "fresh"}


def test_retry_failed_rewalks_a_failure_but_not_a_success(probe):
    """"Done" is per phase: `prepare`'s success status is `clean`, not `ok`. Anything else
    -- including `dirty`, which is a real verdict -- is what --retry-failed re-runs."""
    checkpoints.write("prepare", "good", {"repo_name": "good", "status": "clean"})
    checkpoints.write("prepare", "bad", {"repo_name": "bad", "status": "crashed"})
    walked = []

    checkpoints.sweep("prepare", _repos("good", "bad"),
                      lambda r: (walked.append(r["repo_name"]), _ok(r))[1],
                      resume=True, retry_failed=True)

    assert walked == ["bad"]


def test_resume_without_retry_failed_keeps_even_a_crash(probe):
    """A crashed checkpoint still says the phase visited it. Re-running the whole harvest
    must not silently re-attempt every failure that was triaged as terminal."""
    checkpoints.write("prepare", "bad", {"repo_name": "bad", "status": "crashed"})
    walked = []

    checkpoints.sweep("prepare", _repos("bad"),
                      lambda r: (walked.append(r["repo_name"]), _ok(r))[1], resume=True)

    assert walked == []


def test_untouched_repositories_are_carried_forward(probe):
    """The quiet failure: a --repos-scoped run must not truncate the aggregate to its own
    subset. `prepare_report.json`'s clean_repos, which discover and isolate both gate on,
    is derived from exactly this list."""
    checkpoints.write("prepare", "earlier", {"repo_name": "earlier", "status": "ok"})

    records, this_run, *_ = checkpoints.sweep("prepare", _repos("now"), _ok)

    assert this_run == 1
    assert [r["repo_name"] for r in records] == ["earlier", "now"]


def test_a_rewalked_repository_is_not_duplicated_by_the_carry_forward(probe):
    checkpoints.write("prepare", "r", {"repo_name": "r", "status": "stale"})

    records, *_ = checkpoints.sweep("prepare", _repos("r"), _ok)

    assert len(records) == 1
    assert records[0]["status"] == "ok", "this run's record wins over the carried one"


def test_the_work_function_owns_its_success_checkpoint(probe):
    """Deliberate: `mine` discards its per-commit journal immediately after writing the
    checkpoint, and a sweep that wrote it later would let the next run replay the journal."""
    checkpoints.sweep("prepare", _repos("r"), _ok)
    assert checkpoints.load("prepare", "r") is None, "sweep did not write it"

    def work_that_checkpoints(repo):
        record = _ok(repo)
        checkpoints.write("prepare", repo["repo_name"], record)
        return record

    checkpoints.sweep("prepare", _repos("r2"), work_that_checkpoints)
    assert checkpoints.load("prepare", "r2")["status"] == "ok"


def test_the_hooks_fire_where_the_phases_expect_them(probe):
    begun, started, done = [], [], []

    checkpoints.sweep(
        "prepare", _repos("a", "b"), _ok,
        on_begin=lambda todo, workers: begun.append((len(todo), workers)),
        on_start=lambda repo, i, total: started.append((repo["repo_name"], i, total)),
        on_done=lambda repo, rec, n, total, parallel: done.append(
            (repo["repo_name"], parallel)))

    assert begun == [(2, 1)]
    assert started == [("a", 1, 2), ("b", 2, 2)]
    assert done == [("a", False), ("b", False)]


def test_on_start_is_serial_only_and_on_done_says_which_mode(probe):
    started, done = [], []
    checkpoints.sweep("prepare", _repos("a", "b"), _ok, jobs=2,
                      on_start=lambda *a: started.append(a),
                      on_done=lambda repo, rec, n, t, parallel: done.append(parallel))
    assert started == [], "no meaningful start order when repositories interleave"
    assert done == [True, True]


def test_begin_sees_the_post_resume_set(probe):
    """`mine` counts scopes and candidate commits here, before hours of walking start.
    Counting them over the pre-resume set would state work it is not going to do."""
    checkpoints.write("prepare", "done", {"repo_name": "done", "status": "ok"})
    seen = []

    checkpoints.sweep("prepare", _repos("done", "fresh"), _ok, resume=True,
                      on_begin=lambda todo, workers: seen.append(
                          [r["repo_name"] for r in todo]))

    assert seen == [["fresh"]]


def test_an_empty_selection_still_returns_the_carried_records(probe):
    checkpoints.write("prepare", "earlier", {"repo_name": "earlier", "status": "ok"})
    records, this_run, *_ = checkpoints.sweep("prepare", [], _ok)
    assert this_run == 0
    assert [r["repo_name"] for r in records] == ["earlier"]


def test_the_sweep_returns_where_every_record_came_from(probe):
    """`resumed`, `carried` and `workers` are decided here and reported by every phase.

    They used to be computed and dropped, so all three phase summaries referenced locals the
    sweep had taken over -- `prepare.py` raised `NameError: name 'resumed' is not defined`
    AFTER the work was done, which in `mine` is hours in. The phases cannot re-derive these:
    `workers` is sized on the post-resume set and `carried` is whatever this run did not see.
    """
    checkpoints.write("prepare", "done", {"repo_name": "done", "status": "ok"})
    checkpoints.write("prepare", "elsewhere", {"repo_name": "elsewhere", "status": "ok"})

    swept = checkpoints.sweep("prepare", _repos("done", "fresh"), _ok,
                              jobs=4, resume=True)

    assert swept.this_run == 1
    assert [r["repo_name"] for r in swept.resumed] == ["done"]
    assert [r["repo_name"] for r in swept.carried] == ["elsewhere"], \
        "carried is what this run neither walked nor resumed"
    assert swept.workers == 1, "sized on the post-resume set (one repo), not on jobs=4"
    assert [r["repo_name"] for r in swept.records] == ["done", "elsewhere", "fresh"]


@pytest.mark.parametrize("phase_name", ["prepare", "discover", "mine"])
def test_the_phase_summary_builds_with_nothing_to_walk(phase_name, probe_tree):
    """Every phase must be able to WRITE its summary, not merely finish its walk.

    `config.selected([])` is empty, so each `run([])` falls straight through the sweep to the
    summary dict -- which is the line that broke and the line no test reached. The suite
    covered `sweep` itself in thirteen cases and never once called into a phase, so a
    `NameError` three lines below the sweep call shipped against a green run.
    """
    import importlib

    module = importlib.import_module(f"scripts.mining.{phase_name}")

    summary = module.run([])

    assert summary["phase"] == phase_name
    assert summary["resumed_from_checkpoint"] == []
    assert summary["carried_from_checkpoint"] == []
    assert summary["workers"] >= 1
    assert list(probe_tree.iterdir()), "the phase wrote its summary under the tmp probe"
