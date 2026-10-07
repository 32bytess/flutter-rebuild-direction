"""The reproducibility gate, exercised rather than grepped.

`--from-nothing` deletes the corpus. Until this file existed, the only fast-suite coverage of
that decision was assertions on its own source TEXT -- `"deliberately KEPT" in
inspect.getsource(...)` -- because everything lived inside `screen_samples.py` with no
importable interface. Those assertions are still there and still worth having; they check
that the teardown does not reach into a guard and switch it off, which is a property of the
code rather than of a run. These check what it actually does.
"""

from __future__ import annotations

import json

import pytest

from scripts import fixture_skeleton
from scripts.screen import rebuild
from scripts.screen.backend import CACHE_NAME


def _corpus(tmp_path, *, group="0001", authored=None):
    """A minimal source/dest pair: one group, one role, exported."""
    source = tmp_path / "source"
    dest = tmp_path / "dest"
    (source / group).mkdir(parents=True)
    (source / group / "rev_001_aaaaaaaa.dart").write_text("class X {}\n", encoding="utf-8")
    (dest / group).mkdir(parents=True)
    (dest / group / "rev_001_aaaaaaaa.dart").write_text("class X {}\n", encoding="utf-8")
    if authored:
        (dest / group / authored).write_text("hand written\n", encoding="utf-8")
    return source, dest


def test_a_copy_of_a_source_file_is_not_authored(tmp_path):
    source, dest = _corpus(tmp_path)
    assert rebuild.authored_under(source, dest, set()) == {}


def test_a_file_source_cannot_regenerate_is_authored(tmp_path):
    source, dest = _corpus(tmp_path, authored="NOTES.md")
    assert rebuild.authored_under(source, dest, set()) == {"0001": ["NOTES.md"]}


def test_derived_names_are_never_authored(tmp_path):
    """The record, the caches and the stamps are this pipeline's own output."""
    source, dest = _corpus(tmp_path)
    for name in (CACHE_NAME, "exclusions.json", "EXCLUSIONS.md",
                 fixture_skeleton.PROVENANCE_NAME, fixture_skeleton.PRUNED_NAME):
        (dest / "0001" / name).write_text("{}", encoding="utf-8")
    assert rebuild.authored_under(source, dest, set()) == {}


def test_an_unindexed_fixture_is_authored_unless_the_override_wrote_it(tmp_path):
    """`maximal_branch --apply` rewrites a fixture, so it stops matching its index entry.

    That makes `is_generated` call it authored -- correctly, by hash -- but the pipeline
    authored it and `--apply` will write it again. The `overridden` set is what tells the two
    apart, and getting it wrong either destroys somebody's work or refuses a clean rebuild.
    """
    source, dest = _corpus(tmp_path)
    (dest / "0001" / fixture_skeleton.FIXTURE_NAME).write_text("// edited\n", encoding="utf-8")

    assert "0001" in rebuild.authored_under(source, dest, set())
    assert rebuild.authored_under(source, dest, {"0001"}) == {}


def test_teardown_refuses_over_a_measurement(tmp_path, monkeypatch):
    """Arm 2 is at zero measurements, and a rebuild must not be what destroys the first."""
    source, dest = _corpus(tmp_path)
    (dest / "0001" / "performance.jsonl").write_text('{"ms": 1}\n', encoding="utf-8")

    with pytest.raises(SystemExit) as e:
        rebuild.teardown(source, dest, baseline=False)
    assert "measurement file" in str(e.value)
    assert (dest / "0001" / "performance.jsonl").is_file(), "refused, not deleted"
    assert (dest / "0001" / "rev_001_aaaaaaaa.dart").is_file()


def test_teardown_refuses_over_authored_work(tmp_path):
    source, dest = _corpus(tmp_path, authored="NOTES.md")
    with pytest.raises(SystemExit) as e:
        rebuild.teardown(source, dest, baseline=False)
    assert "not regenerable" in str(e.value)
    assert (dest / "0001" / "NOTES.md").is_file(), "refused, not deleted"


def test_teardown_without_a_baseline_still_removes_the_corpus(tmp_path, monkeypatch):
    from scripts import fixture_values, maximal_branch

    monkeypatch.setattr(fixture_values, "VALUES_PATH", tmp_path / "values.json")
    monkeypatch.setattr(maximal_branch, "TABLE_PATH", tmp_path / "branch.json")
    source, dest = _corpus(tmp_path)

    snapshot = rebuild.teardown(source, dest, baseline=False)

    assert not dest.exists(), "the corpus is gone"
    assert source.is_dir(), "the mine is not touched"
    assert snapshot == {"values.json": None, "branch.json": None}


def test_teardown_demands_a_baseline_when_asked_for_one(tmp_path, monkeypatch):
    """`--from-nothing` without the committed tables asserts nothing, which is the
    hand-trim it exists to replace."""
    from scripts import fixture_values, maximal_branch

    monkeypatch.setattr(fixture_values, "VALUES_PATH", tmp_path / "gone.json")
    monkeypatch.setattr(maximal_branch, "TABLE_PATH", tmp_path / "also-gone.json")
    source, dest = _corpus(tmp_path)

    with pytest.raises(SystemExit) as e:
        rebuild.teardown(source, dest, baseline=True)
    assert "nothing to check the rebuild against" in str(e.value)
    assert dest.is_dir(), "refused before deleting anything"


def test_teardown_snapshots_the_tables_it_removes(tmp_path, monkeypatch):
    from scripts import fixture_values, maximal_branch

    values = tmp_path / "values.json"
    branch = tmp_path / "branch.json"
    values.write_text('{"0001": {}}', encoding="utf-8")
    branch.write_text("{}", encoding="utf-8")
    monkeypatch.setattr(fixture_values, "VALUES_PATH", values)
    monkeypatch.setattr(maximal_branch, "TABLE_PATH", branch)
    source, dest = _corpus(tmp_path)

    snapshot = rebuild.teardown(source, dest, baseline=True)

    assert snapshot["values.json"] == '{"0001": {}}'
    assert not values.exists() and not branch.exists(), "removed, having been snapshotted"


def test_verify_reports_a_table_that_came_back_different(tmp_path, monkeypatch, capsys):
    """The assertion the whole gate exists for: the rebuild reproduced the committed table."""
    from scripts import fixture_gate, fixture_values, maximal_branch

    values = tmp_path / "values.json"
    values.write_text('{"0001": {"bindings": {"a": 1}}}', encoding="utf-8")
    monkeypatch.setattr(fixture_values, "VALUES_PATH", values)
    monkeypatch.setattr(fixture_values, "values_version", lambda: "digest-x")
    monkeypatch.setattr(fixture_gate, "check_root", lambda root, group=None: {})

    dest = tmp_path / "dest"
    dest.mkdir()
    records = tmp_path / "records"
    records.mkdir()
    (records / "exclusions.json").write_text(
        json.dumps({"provenance": {"values_digest": "digest-x"}, "totals": {},
                    "unfillable": {}}), encoding="utf-8")

    snapshot = {"values.json": '{"0001": {"bindings": {"a": 2}}}'}   # NOT what came back
    with pytest.raises(SystemExit) as e:
        rebuild.verify(snapshot, dest, records)
    assert "gate FAILED" in str(e.value)
    assert "byte-identical" in capsys.readouterr().out


def test_verify_fails_when_the_record_was_screened_against_another_table(tmp_path, monkeypatch):
    """A record whose values digest is stale describes a corpus that no longer exists."""
    from scripts import fixture_gate, fixture_values

    monkeypatch.setattr(fixture_values, "values_version", lambda: "digest-now")
    monkeypatch.setattr(fixture_gate, "check_root", lambda root, group=None: {})

    dest = tmp_path / "dest"
    dest.mkdir()
    records = tmp_path / "records"
    records.mkdir()
    (records / "exclusions.json").write_text(
        json.dumps({"provenance": {"values_digest": "digest-stale"}, "totals": {},
                    "unfillable": {}}), encoding="utf-8")

    with pytest.raises(SystemExit) as e:
        rebuild.verify({}, dest, records)
    assert "gate FAILED" in str(e.value)


def test_the_published_counts_are_literals_the_gate_cannot_derive():
    """Everything else is compared against the tree the rebuild started from; these are the
    claim, so a rebuild agreeing with a corpus that has drifted must still fail.

    UNSET since 2026-09-08, and the test pins the SHAPE rather than the values while that is
    true. The constructor-field lift and R16 going soft both move the corpus and the
    re-harvest is re-minting ids underneath them, so the old literals -- 191 / 45 / 20 / 65
    -- are not what a rebuild should agree with. A `None` skips its check and says so; what
    must not happen is a key going missing, which would skip silently.

    When the new counts are published, fill them in here as well: this test
    is what stops them being quietly dropped rather than deliberately unset."""
    expect = rebuild.EXPECTED_CORPUS["new_samples"]
    for key in ("eligible_pairs", "eligible_mover_scopes", "eligible_repositories",
                "eligible_adjacent_pairs", "measurable_pairs", "measurable_mover_scopes",
                "awaiting_fixture_groups", "roles", "fixtures"):
        assert key in expect, f"{key} would be skipped silently rather than deliberately"
        assert expect[key] is None or isinstance(expect[key], int)
