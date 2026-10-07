"""Each committed table has one reader, and an override moves all of them.

`config/fixture_values.json` and `config/maximal_branch.json` are both overridable by
environment variable (`fixture_values.table_path`). `screen_samples` used to re-derive the
default path and read the file itself, so an override moved the fill's reader and left R16
judging against the committed table -- two answers to "what did the fill decide", with
nothing in any artifact saying which one a run used.
"""

from __future__ import annotations

import json

from scripts import fixture_values, jsonio, maximal_branch, screen_samples


def test_screen_samples_follows_the_values_override(monkeypatch, tmp_path):
    """The regression: the override must reach R16's reader, not just the fill's."""
    other = tmp_path / "fixture_values_v3.json"
    other.write_text(json.dumps({"9999": {"anchor": "deadbeef", "repo": "o/r",
                                          "bindings": {}}}), encoding="utf-8")
    monkeypatch.setattr(fixture_values, "VALUES_PATH", other)
    screen_samples._reset_fixture_values()
    try:
        assert "9999" in screen_samples._fixture_values()
        assert screen_samples._fixture_values() == fixture_values.load()
    finally:
        screen_samples._reset_fixture_values()


def test_an_absent_values_table_reads_as_empty(monkeypatch, tmp_path):
    monkeypatch.setattr(fixture_values, "VALUES_PATH", tmp_path / "nope.json")
    assert fixture_values.load() == {}


def test_an_absent_branch_table_reads_as_empty(monkeypatch, tmp_path):
    monkeypatch.setattr(maximal_branch, "TABLE_PATH", tmp_path / "nope.json")
    assert maximal_branch.load() == {}


def test_a_truncated_table_is_retried_then_reported_absent(tmp_path):
    """The hardened reader's contract: a half-written file is not-yet-there, never a crash."""
    half = tmp_path / "half.json"
    half.write_text('{"0001": {"bind', encoding="utf-8")
    assert jsonio.read_json(half, {}) == {}


def test_require_json_refuses_rather_than_returning_empty(tmp_path):
    """Where absence is not a state the pipeline can be in, it must be fatal.

    `--eligible-only` reading `{}` would select no groups and report a clean run over none.
    """
    import pytest

    with pytest.raises(SystemExit):
        jsonio.require_json(tmp_path / "missing.json", "a caller that needs it")
