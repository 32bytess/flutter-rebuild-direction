"""`--full`: the five phases, their order, and the combinations it refuses.

Building the corpus is five steps that must run in one order, because each of the two table
passes rewrites a group's `dependencies.dart` and that fixture decides the feature vectors,
which decide the contrast set. `--full` runs them in one process.

What is under test here is the ORDER and the REFUSALS, not the corpus: a real `--full` run
needs three `spm analyze` passes over the whole mine, which this suite does not pay for. The
corpus itself is pinned by `test_real_corpus.py`, whose numbers are the acceptance test for
this feature -- 214 contrasts / 50 mover scopes / 20 repositories, and 177 measured roles.

The refusals `--full` satisfies in sequence are NOT removed, and that matters: they are what
makes the phase-by-phase path checkable by hand. `test_export.py` and `fixture_values` /
`maximal_branch`'s own guards cover them; here we only prove `--full` does not weaken them.
"""

from __future__ import annotations

import inspect
import json
from pathlib import Path

import pytest

from scripts import fixture_values, maximal_branch, screen_samples
from scripts.tests import mini_corpus
from scripts.tests.regolden import run, screen_argv


def code_of(fn) -> str:
    """A function's source with its docstring and comments stripped.

    These assertions are about what the code DOES. Matching against the prose as well makes
    them fire on a comment that merely names a guard -- which is exactly what a function
    explaining why it does not weaken one is full of.
    """
    src = inspect.getsource(fn)
    body = src.split('"""')[2] if src.count('"""') >= 2 else src
    return "\n".join(line.split("#")[0] for line in body.splitlines())


def full_argv(source: Path, records: Path, extra: list[str] | None = None) -> list[str]:
    """`--full` without `--vectors`, which it refuses: it computes its own."""
    argv = [a for a in screen_argv(source, records, extra)
            if a != "--vectors" and not a.endswith("static_vectors.jsonl")]
    return argv


# ---------------------------------------------------------------------------------------
# The refusals. Each is a real contradiction, so each must name the phase it collides with.
# ---------------------------------------------------------------------------------------

@pytest.mark.parametrize("flag,expected", [
    ("--report-only", "phases 1, 3 and 5 each write"),
    ("--prune-to-endpoints", "already prunes, in phase 5"),
    ("--dry-run", "phases 2 and 4"),
])
def test_full_refuses_what_contradicts_it(tmp_path, flag, expected):
    source = mini_corpus.build(tmp_path / "corpus")
    out = run(full_argv(source, tmp_path / "records",
                        ["--dest", str(tmp_path / "dest"), "--full", flag]),
              expect_failure=True)
    assert expected in out.stderr


def test_full_refuses_supplied_vectors(tmp_path):
    """`--vectors` says "the vectors already exist". Phases 2 and 4 rewrite the fixtures
    those vectors are taken from, so a supplied set describes the corpus before phase 2."""
    source = mini_corpus.build(tmp_path / "corpus")
    out = run(screen_argv(source, tmp_path / "records",
                          ["--dest", str(tmp_path / "dest"), "--full"]),
              expect_failure=True)
    assert "computes its own vectors" in out.stderr


def test_full_refuses_no_fixtures(tmp_path):
    """Phase 2 fills the fixtures at `--dest` and phases 3 and 5 read them back. With none
    there, the fill is a no-op and the corpus ships without a `dependencies.dart`, which does
    not mount -- a silent wrong answer rather than a loud refusal."""
    source = mini_corpus.build(tmp_path / "corpus")
    out = run(full_argv(source, tmp_path / "records",
                        ["--dest", str(tmp_path / "dest"), "--full", "--no-fixtures"]),
              expect_failure=True)
    assert "cannot run with --no-fixtures" in out.stderr


def test_the_fill_skips_table_groups_the_corpus_does_not_ship(tmp_path):
    """`config/fixture_values.json` is the durable artifact and the corpus is derived from
    it, so it legitimately holds a group the export dropped -- `0607` is hand-excluded and
    has no directory. Iterating the table blind died on its missing fixture."""
    # Matched without its trailing colon: the same guard now also skips a fixture a human has
    # edited (`or gid in hands_off`), and pinning the whole line made this assert the shape of
    # a neighbouring rule rather than its own.
    src = inspect.getsource(fixture_values.run)
    assert "if not f.is_file()" in src and "continue" in src


def test_init_without_full_is_refused(tmp_path):
    """The individual tools have their own `--init`; this one only sequences theirs."""
    source = mini_corpus.build(tmp_path / "corpus")
    out = run(full_argv(source, tmp_path / "records",
                        ["--dest", str(tmp_path / "dest"), "--init"]),
              expect_failure=True)
    assert "only meaningful with --full" in out.stderr


def test_init_refuses_to_overwrite_a_committed_table(tmp_path):
    """`--init` seeds a FIRST run. Reseeding would move `values_version()` and silently
    invalidate every screening checkpoint, which is why it is a flag and never a default.

    The table is redirected because it is the one input `--dest` does not move: this ran
    against `config/fixture_values.json` itself, so it asserted the refusal only while a
    committed table happened to exist, and SEEDED one over the live tree when it did not.
    Supplying the table here is also what makes the assertion honest -- the refusal is now
    tested against a table this test created, not against whatever the checkout carried.
    """
    source = mini_corpus.build(tmp_path / "corpus")
    values = tmp_path / "fixture_values.json"
    values.write_text('{"0041": {"bindings": {}}}\n', encoding="utf-8")
    out = run(full_argv(source, tmp_path / "records",
                        ["--dest", str(tmp_path / "dest"), "--full", "--init"]),
              expect_failure=True,
              env={"SPM_FIXTURE_VALUES": str(values),
                   "SPM_MAXIMAL_BRANCH": str(tmp_path / "maximal_branch.json")})
    assert "refusing to overwrite" in (out.stderr + out.stdout)
    assert json.loads(values.read_text()) == {"0041": {"bindings": {}}}, \
        "the refusal must leave the table it refused to overwrite untouched"


def test_init_reseeds_an_empty_table_instead_of_refusing(tmp_path, monkeypatch):
    """`{}` is the exact byte string `--init` writes, so seeding onto it is a no-op.

    Refusing it is what made 2026-09-06 permanent rather than transient: phase 0 seeded the
    table, a later phase of the SAME pass failed, and every retry afterwards died here on the
    seed's own output. The digest cannot move -- there is nothing stored to lose.
    """
    from scripts import fixture_values

    values = tmp_path / "fixture_values.json"
    values.write_text("{}\n", encoding="utf-8")
    monkeypatch.setattr(fixture_values, "VALUES_PATH", values)
    monkeypatch.setattr(fixture_values, "POLICY_PATH", tmp_path / "fixture_policy.json")
    (tmp_path / "fixture_policy.json").write_text("{}\n", encoding="utf-8")

    before = fixture_values.values_version()
    assert fixture_values.init_values_table() == before, "the seed moved the digest"
    assert values.read_text() == "{}\n"


def test_init_still_refuses_a_table_holding_bindings(tmp_path, monkeypatch):
    """The guard the exception above must not weaken. A stored value is somebody's resolution
    and re-seeding would discard it while invalidating every checkpoint."""
    from scripts import fixture_values

    values = tmp_path / "fixture_values.json"
    values.write_text('{"0041": {"bindings": {}}}\n', encoding="utf-8")
    monkeypatch.setattr(fixture_values, "VALUES_PATH", values)

    with pytest.raises(SystemExit, match="refusing to overwrite"):
        fixture_values.init_values_table()
    assert json.loads(values.read_text()) == {"0041": {"bindings": {}}}


# ---------------------------------------------------------------------------------------
# The phase order, asserted against the driver rather than against a run.
# ---------------------------------------------------------------------------------------

def test_the_two_table_tools_are_callable_without_argparse():
    """`--full` calls them as libraries. If either reverts to doing its work inside `main()`,
    the driver silently stops running that phase."""
    assert callable(fixture_values.run) and callable(maximal_branch.run)
    fv = inspect.signature(fixture_values.run).parameters
    assert {"root", "eligible_only", "apply"} <= set(fv)
    mb = inspect.signature(maximal_branch.run).parameters
    assert {"root", "eligible_only", "apply", "init"} <= set(mb)


def test_the_fill_pass_runs_between_two_screens():
    """Phase 2 must be bracketed by screens: without the one after it, the fixture store and
    the exported corpus disagree about what the roles mount from, and the vectors the
    contrast set was differenced over describe the pre-fill fixtures."""
    src = inspect.getsource(screen_samples._full)
    order = [src.index("fixture_values.run("), src.index("maximal_branch.run(")]
    passes = [i for i in range(len(src)) if src.startswith("_one_pass(", i)]
    assert len(passes) == 3, "five phases means exactly three screen passes"
    assert passes[0] < order[0] < passes[1] < order[1] < passes[2]


def test_the_pass_after_the_fill_never_resumes():
    """`screen_mode` folds `values_version()` into every checkpoint and the fill moves that
    digest, so phase 1's checkpoints describe a different values regime. Resuming across the
    fill would mix two of them in one corpus."""
    src = inspect.getsource(screen_samples._full)
    after_fill = src[src.index("fixture_values.run("):src.index("maximal_branch.run(")]
    assert "resume=False" in after_fill and "rescreen=True" in after_fill


def test_the_last_pass_resumes_and_prunes():
    """`config/maximal_branch.json` is not in `values_version()`, so phase 3's checkpoints
    are still valid and the third pass is cheap."""
    src = inspect.getsource(screen_samples._full)
    last = src[src.index("maximal_branch.run("):]
    assert "resume=True" in last and "prune_to_endpoints=True" in last


def test_the_values_cache_is_dropped_between_phases():
    """`_fixture_values()` caches the table in a module global, read once. Phases 3 and 5
    must see what phase 2 wrote, or they rebuild the fixtures from the pre-fill table --
    which would produce a corpus whose fixtures still carry `// TODO: value`."""
    src = inspect.getsource(screen_samples._full)
    assert "_reset_fixture_values()" in src
    screen_samples._FIXTURE_VALUES = {"sentinel": True}
    screen_samples._reset_fixture_values()
    assert screen_samples._FIXTURE_VALUES is None


def test_full_does_not_weaken_the_hand_run_guards():
    """The three refusals that enforce the order for someone running the phases separately
    stay in place; `--full` satisfies them in sequence rather than bypassing them."""
    assert "require_fixture_pass_done" in inspect.getsource(screen_samples._one_pass)
    assert "refuse_if_pruned" in inspect.getsource(fixture_values.run)
    assert "refuse_if_pruned" in inspect.getsource(maximal_branch.run)


# ---------------------------------------------------------------------------------------
# `--from-nothing`: the teardown that makes fixture_policy.json the only authored input
# ---------------------------------------------------------------------------------------
#
# The five phases already rebuilt the corpus faithfully -- that was measured on 2026-09-01.
# What they could not do was run against the state they had produced: `init_values_table`
# refuses to overwrite a table and `refuse_if_pruned` hard-exits both table tools on a pruned
# tree, so a rebuild needed three `rm`s nobody had scripted. `--from-nothing` scripts them,
# and the guards below are what keep that from being a licence to delete anything else.

def test_from_nothing_without_full_is_refused(tmp_path):
    """It tears down what the five phases regenerate; one phase alone rebuilds a fragment."""
    source = mini_corpus.build(tmp_path / "corpus")
    out = run(full_argv(source, tmp_path / "records",
                        ["--dest", str(tmp_path / "dest"), "--from-nothing"]),
              expect_failure=True)
    assert "only meaningful with --full" in out.stderr


def test_no_baseline_without_from_nothing_is_refused(tmp_path):
    """It suppresses a comparison nothing else makes."""
    source = mini_corpus.build(tmp_path / "corpus")
    out = run(full_argv(source, tmp_path / "records",
                        ["--dest", str(tmp_path / "dest"), "--no-baseline"]),
              expect_failure=True)
    assert "only meaningful with --from-nothing" in out.stderr


def _isolated_tables(tmp_path) -> dict[str, str]:
    """Both generated tables, in a tmp dir, for a subprocess that runs `--from-nothing`.

    `teardown` snapshots them BEFORE the authored/measured checks and refuses outright when
    either is missing, so a checkout with no committed tables -- which is precisely a
    from-scratch rebuild in progress -- made these tests refuse for the wrong reason and
    assert against the wrong message. Redirecting also stops the run deleting the real pair,
    which is what `--from-nothing` does to whatever tables it is pointed at.
    """
    values = tmp_path / "fixture_values.json"
    branch = tmp_path / "maximal_branch.json"
    values.write_text("{}\n", encoding="utf-8")
    branch.write_text("{}\n", encoding="utf-8")
    return {"SPM_FIXTURE_VALUES": str(values), "SPM_MAXIMAL_BRANCH": str(branch)}


def test_from_nothing_refuses_a_dest_holding_authored_work(tmp_path):
    """A rebuild deletes the tree, so anything at `--dest` that `--source` cannot regenerate
    stops it. This is the same "authored is sacred" rule `export` applies to `--prune`, at
    the granularity of the whole corpus."""
    source = mini_corpus.build(tmp_path / "corpus")
    dest = tmp_path / "dest"
    (dest / "0001").mkdir(parents=True)
    (dest / "0001" / "mutation_hand_written.dart").write_text("// somebody's work\n")
    out = run(full_argv(source, tmp_path / "records",
                        ["--dest", str(dest), "--full", "--from-nothing"]),
              expect_failure=True, env=_isolated_tables(tmp_path))
    assert "not regenerable" in (out.stderr + out.stdout)
    assert "mutation_hand_written.dart" in (out.stderr + out.stdout)
    assert (dest / "0001" / "mutation_hand_written.dart").is_file(), "refused, not deleted"


def test_from_nothing_refuses_a_corpus_that_has_been_measured(tmp_path):
    """Arm 2 is at zero device measurements and a rebuild must never destroy the first one:
    a measured row is not rebuildable from the mine."""
    source = mini_corpus.build(tmp_path / "corpus")
    dest = tmp_path / "dest"
    (dest / "0001").mkdir(parents=True)
    (dest / "0001" / "performance.jsonl").write_text('{"buildSpan": 1}\n')
    out = run(full_argv(source, tmp_path / "records",
                        ["--dest", str(dest), "--full", "--from-nothing"]),
              expect_failure=True, env=_isolated_tables(tmp_path))
    assert "measurement file" in (out.stderr + out.stdout)
    assert (dest / "0001" / "performance.jsonl").is_file(), "refused, not deleted"


def test_from_nothing_does_not_weaken_the_guards_it_steps_around():
    """The refusals stay. `--from-nothing` removes the state they refuse BEFORE they are
    consulted; it must never reach into either tool and switch one off."""
    body = code_of(screen_samples._teardown_for_rebuild)
    assert "refuse_if_pruned(" not in body, "the teardown must not call the guard"
    assert "init_values_table(" not in body, "phase 0 of --full seeds the table, not this"
    # The guards themselves are still where they were, intact for every other caller.
    assert "refuse_if_pruned" in inspect.getsource(fixture_values.run)
    assert "refuse_if_pruned" in inspect.getsource(maximal_branch.run)
    assert "refusing to overwrite" in inspect.getsource(fixture_values.init_values_table)


def test_from_nothing_keeps_the_vector_cache_and_the_checkpoints():
    """Both are safe to keep and expensive to lose: the cache is keyed on
    sha256(role text || fixture digest) so it cannot serve a stale answer, and phase 1
    screens with `rescreen=True` under --init so no checkpoint is trusted anyway."""
    assert "deliberately KEPT" in inspect.getsource(screen_samples._teardown_for_rebuild)
    body = code_of(screen_samples._teardown_for_rebuild)
    assert "rmtree" in body, "it does delete the corpus"
    # Scoped to the lines that DELETE. This used to forbid the words anywhere in the body,
    # which also forbade naming either thing in order to say it is being kept -- and the
    # authored-fixture store has to be named, because a reader of the rebuild output needs to
    # know how many groups the corpus is no longer deriving from the mine.
    destructive = [ln for ln in body.splitlines()
                   if "rmtree" in ln or "unlink" in ln]
    assert not any("checkpoints" in ln or "fixtures" in ln for ln in destructive), destructive


def test_the_gate_runs_after_phase_five_and_not_instead_of_it():
    """A gate that ran before the prune would check a corpus the rebuild had not finished."""
    body = code_of(screen_samples._full)
    assert body.index("phase(5") < body.index("rebuild.verify")
    assert body.index("rebuild.teardown") < body.index("phase(1")


def test_the_gate_asserts_the_published_counts_as_literals():
    """Everything else is compared against the tree the rebuild started from. These are the
    published claim, so a rebuild agreeing with a corpus that has drifted must still fail.

    Every one is UNSET as of 2026-09-08 and the check is skipped, loudly, per key. The
    constructor-field lift and R16 going soft both move the corpus and the re-harvest is
    re-minting ids underneath them, so 191 / 45 / 20 / 65 with 156 roles and 45 fixtures is
    not what a rebuild should now agree with. What this test protects while that is true is
    that a key is never MISSING -- a missing key would skip silently, which is the one
    failure mode indistinguishable from a passing gate.

    Fill the literals in when the counts are published, and restore the equality
    assertions here at the same time."""
    expect = screen_samples.EXPECTED_CORPUS["new_samples"]
    for key in ("eligible_pairs", "eligible_mover_scopes", "eligible_repositories",
                "eligible_adjacent_pairs", "measurable_pairs", "measurable_mover_scopes",
                "awaiting_fixture_groups", "roles", "fixtures"):
        assert key in expect, f"{key} would be skipped silently rather than deliberately"


def test_the_override_table_digest_ignores_only_the_date():
    """`applied` is the one field a rebuild cannot recreate. Everything else is derived, so
    hashing it is what lets the gate be strict."""
    base = {"1637": [{"binding": "b", "current": "false", "replaced_value": None,
                      "applied": "2026-08-30", "verdict": "decidable"}]}
    moved_date = {"1637": [{**base["1637"][0], "applied": "2099-01-01"}]}
    moved_value = {"1637": [{**base["1637"][0], "replaced_value": "true"}]}
    assert maximal_branch.table_digest(base) == maximal_branch.table_digest(moved_date)
    assert maximal_branch.table_digest(base) != maximal_branch.table_digest(moved_value)


def test_full_clears_a_stale_prune_stamp_before_the_table_phases():
    """`--full` has to be re-runnable against the same --dest, and was not.

    Phase 5 stamps the corpus as pruned to endpoints, and BOTH table tools hard-exit against
    a stamped tree. So `--full` worked exactly once against a given `--dest`: the next run
    died in phase 2, before touching anything. `--from-nothing` never noticed, because its
    teardown deletes the tree, stamp and all.

    Screening once per BATCH is what surfaced it -- on 2026-09-06 batch 1 screened clean and
    every batch after it recorded `screen_refused`, mining kept and nothing shipped.

    Phase 1 re-exports the COMPLETE eligible role set before either table tool runs -- the
    copy loop only adds -- so the stamp is false by the time it would be read, and clearing
    it there is what makes the refusal describe the tree again.
    """
    body = code_of(screen_samples._full)
    cleared = body.index("PRUNED_NAME")

    assert ".unlink()" in body[cleared:cleared + 240], "the stamp is read but not removed"
    assert body.index("_one_pass") < cleared, \
        "cleared before phase 1 restored the roles that make the stamp false"
    assert cleared < body.index("fixture_values.run"), \
        "phase 2 would already have refused"
    assert cleared < body.index("maximal_branch.run"), \
        "phase 4 would already have refused"


def test_the_prune_guard_still_refuses_a_standalone_table_run(tmp_path):
    """The clearing is scoped to `--full`, where phase 1 has just restored every role.

    Run on its own against a tree that really does hold only endpoints, both tools must
    still refuse -- that is the case the guard was written for, and `--full` must not be the
    thing that weakens it.
    """
    from scripts import fixture_skeleton

    dest = tmp_path / "dest"
    dest.mkdir()
    (dest / fixture_skeleton.PRUNED_NAME).write_text('{"pruned_at": "2026-09-06T12:30:35Z"}')

    with pytest.raises(SystemExit) as exc:
        maximal_branch.run(dest)
    assert "pruned to measured endpoints" in str(exc.value)

    with pytest.raises(SystemExit) as exc:
        fixture_values.run(dest, eligible_only=True, apply=True)
    assert "pruned to measured endpoints" in str(exc.value)
