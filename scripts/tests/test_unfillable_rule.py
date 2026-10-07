"""R16: the rule that derives the arm-2 corpus's one hand exclusion from the policy table.

(Until 2026-09-04 this was "the rule that makes `config/fixture_policy.json` the ONLY
hand-written input". `R17_package_license` added a second one, `config/license_policy.json`,
deliberately -- see `scripts/screen/licenses.py`. R16 is unaffected; only the slogan moved.)

The arm-2 corpus used to drop `0607` from a second authored file,
`config/arm2_hand_exclusions.txt`, which restated something the policy already implied: the
group's one binding is a `late TabController`, and the policy DECLARES that type
unrecoverable. R16 derives the exclusion instead.

It is SOFT: an unresolved binding names authoring work, and `fixture_gate.py` is the hard
refusal that keeps such a group off the device. `--strict` restores the excluding behaviour,
and one test below pins that so the strict corpus stays reproducible.

Three properties are load-bearing and are what this file pins:

  * it is INERT on an empty values table, so phase 1 of `--full` -- which runs before any
    slot is resolved -- screens exactly as it did before;
  * it fires from the TABLE, not from a `// TODO: value` left in a fixture on disk. Reading
    the fixture would exclude every group the fill had not yet visited, and
    `fixture_values --apply --eligible-only` visits only groups that ALREADY carry an
    eligible contrast -- so a group with no eligible contrast on pass one would be excluded
    on pass three for not having been filled, and the exclusion would be its own cause;
  * it FLAGS rather than excludes, and a flagged group keeps its contrasts -- without which
    it could never be measured even once its fixture was authored.
"""

from __future__ import annotations

import json
from pathlib import Path

import pytest

from scripts import screen_samples as screen
from scripts.screen.backend import Screener
from scripts.tests import mini_corpus

DECLARED = {"decl": "late TabController fixtureTabController;", "origin": "none",
            "rule": "unrecoverable", "rule_id": "ticker_provider",
            "note": "requires a TickerProvider vsync; cannot be constructed at top level"}
# The pre-2026-09-05 shape: a note and no id. Kept so the decl-type fallback stays covered --
# a table written before ids were carried must still classify.
LEGACY_DECLARED = {"decl": "late TabController fixtureTabController;", "origin": "none",
                   "rule": "unrecoverable",
                   "note": "requires a TickerProvider vsync; cannot be constructed at top level"}
# A type the primitives-only table declines to fabricate. Constructible in Dart, unlike
# `TabController` -- and still a DECLARED refusal, because the policy names it.
OUT_OF_SCOPE = {"decl": "late TextEditingController fixtureController;", "origin": "none",
                "rule": "unrecoverable", "rule_id": "object_type_out_of_scope",
                "note": "a controller owning mutable text state and a listener list"}
# A refusal belonging to a resolution ROUTE, not to a named type. Its declared type is
# `dynamic`, so the decl-type fallback cannot place it and only the id can.
ROUTE_DECLARED = {"decl": "const dynamic brandColour = null;", "origin": "none",
                  "rule": "unrecoverable", "rule_id": "const_standin_unrecovered",
                  "note": "no self-contained upstream literal, and a const declaration takes "
                          "no primitive stand-in"}
UNDECLARED = {"decl": "late Mystery fixtureThing;", "origin": "none",
              "rule": "unrecoverable"}
ALIVE = {"decl": "late int fixtureCount;", "origin": "default",
         "rule": "protocol_constant", "expr": "0"}


# ---------------------------------------------------------------------------------------
# The deriver
# ---------------------------------------------------------------------------------------

def test_an_empty_table_excludes_nothing():
    """Phase 1 of `--full` runs against a table `--init` has just emptied."""
    assert screen.unfillable_groups({}) == {}
    assert screen.unfillable_groups(None) == {}


def test_a_fully_resolved_group_is_not_unfillable():
    assert screen.unfillable_groups({"0001": {"bindings": {"fixtureCount": ALIVE}}}) == {}


def test_a_declared_unrecoverable_type_carries_the_policys_own_words():
    got = screen.unfillable_groups({"0607": {"bindings": {"c": DECLARED, "d": ALIVE}}})
    assert got["0607"]["declared"] is True
    assert got["0607"]["bindings"] == ["c"]
    assert "TickerProvider" in got["0607"]["reason"]


def test_a_type_the_policy_merely_omits_is_reported_as_a_different_kind():
    """The loud case. A group dropped because nobody wrote its type into the map is a policy
    that is short, not a group that deserves to go."""
    got = screen.unfillable_groups({"9999": {"bindings": {"t": UNDECLARED}}})
    assert got["9999"]["declared"] is False
    assert "no entry" in got["9999"]["reason"]


def test_a_table_written_before_ids_were_carried_still_classifies():
    """The decl-type fallback. Verdicts key on `rule_id` since 2026-09-05, and a stored table
    predating it has none -- it must not silently become the loud case."""
    got = screen.unfillable_groups({"0607": {"bindings": {"c": LEGACY_DECLARED}}})
    assert got["0607"]["declared"] is True


def test_a_type_the_policy_declines_to_fabricate_is_declared_not_loud():
    """`out_of_scope` is the other declared block. The 2026-09-05 trim dropped thirteen object
    types from the value table and NAMED them, precisely so this stays distinguishable from a
    type nobody wrote down: an omission the policy does not own must still be loud."""
    got = screen.unfillable_groups({"0269": {"bindings": {"c": OUT_OF_SCOPE}}})
    assert got["0269"]["declared"] is True
    assert "controller" in got["0269"]["reason"]


def test_a_route_refusal_is_declared_even_though_no_type_names_it():
    """`const dynamic X = null;` has type `dynamic`, so the decl-type fallback cannot place it.
    Only the id can, which is why the id exists."""
    got = screen.unfillable_groups({"0058": {"bindings": {"c": ROUTE_DECLARED}}})
    assert got["0058"]["declared"] is True


def test_deleting_a_type_from_the_table_without_naming_it_stays_loud():
    """The property the `out_of_scope` block protects. If a declined type were declared merely
    by being absent from `types`, a typo that dropped `String` would become a sanctioned
    exclusion and the `--from-nothing` gate would stop catching it."""
    typo = {"decl": "late String fixtureName;", "origin": "none", "rule": "unrecoverable",
            "note": "no policy entry and no stand-in class for `String`"}
    got = screen.unfillable_groups({"9998": {"bindings": {"t": typo}}})
    assert got["9998"]["declared"] is False


# ---------------------------------------------------------------------------------------
# The wiring
# ---------------------------------------------------------------------------------------

@pytest.fixture
def corpus(tmp_path) -> Path:
    return mini_corpus.build(tmp_path / "corpus")


def _screen(corpus: Path, table: dict, monkeypatch, *, strict: bool = False) -> dict:
    """One in-process screen against a supplied values table.

    In process rather than through `regolden.run_screen`, because the table is read from
    `config/fixture_values.json` by a module global and a subprocess cannot be handed one.
    """
    monkeypatch.setattr(screen, "_FIXTURE_VALUES", table)
    screener = Screener(corpus, corpus / ".screen_cache.json", enabled=False)
    return screen.screen(corpus, screener, strict=strict, checkpoints=corpus / "checkpoints",
                         vectors_path=corpus / "static_vectors.jsonl",
                         # The mini corpus's own licence inputs. Without them R17 aborts on
                         # a pool that reports no inlining and R18 fires on every synthetic
                         # repository, and this file would be measuring those instead of R16.
                         license_provenance=corpus / "license_provenance.jsonl",
                         license_candidates=corpus / "candidates.jsonl")


@pytest.mark.dart
def test_the_rule_is_inert_without_a_table(corpus, monkeypatch):
    out = _screen(corpus, {}, monkeypatch)
    assert out["unfillable"] == {}
    assert not any(screen.UNFILLABLE_RULE in g["all_rules"] for g in out["groups"].values())


@pytest.mark.dart
def test_a_dead_binding_flags_its_group_and_keeps_its_contrasts(corpus, monkeypatch):
    """The soft rule, stated as a test.

    `0001` is the clean group: three distinct vectors and three eligible contrasts. A binding
    the GENERATED fill gave up on used to take the whole group, contrasts included. It now
    names authoring work: the group is flagged, its contrasts survive, and `fixture_gate.py`
    is what holds it back from the device until the fixture is written by hand.

    The contrasts surviving is the load-bearing half. Without an `spm analyze` pass the group
    has no vectors, forms no pairs, and R14/R15 never see it -- so it could not be measured
    even after someone authored its fixture, and the flag would be an invitation to do work
    that could not pay off."""
    before = _screen(corpus, {}, monkeypatch)
    after = _screen(corpus, {"0001": {"bindings": {"c": DECLARED}}}, monkeypatch)

    assert screen.UNFILLABLE_RULE not in after["groups"]["0001"]["excluded_by"]
    assert screen.UNFILLABLE_RULE in after["groups"]["0001"]["all_rules"]
    assert screen.UNFILLABLE_RULE in after["groups"]["0001"]["flagged_by"]
    assert after["groups"]["0001"]["eligible"] is True
    # The verdict itself is unchanged: the fill really did refuse, and the policy really does
    # name the type. Only the consequence moved.
    assert after["unfillable"]["0001"]["declared"] is True

    was = {r["pair_id"] for r in before["pair_rows"] if r["verdict"] == "eligible"}
    now = {r["pair_id"] for r in after["pair_rows"] if r["verdict"] == "eligible"}
    assert now == was


@pytest.mark.dart
def test_strict_still_excludes_it_and_its_contrasts(corpus, monkeypatch):
    """`--strict` reproduces the strict corpus exactly, which makes the soft rule checkable
    against the figures it replaces rather than merely asserted."""
    before = _screen(corpus, {}, monkeypatch, strict=True)
    after = _screen(corpus, {"0001": {"bindings": {"c": DECLARED}}}, monkeypatch, strict=True)

    assert screen.UNFILLABLE_RULE in after["groups"]["0001"]["excluded_by"]
    assert after["groups"]["0001"]["eligible"] is False

    was = {r["pair_id"] for r in before["pair_rows"] if r["verdict"] == "eligible"}
    now = {r["pair_id"] for r in after["pair_rows"] if r["verdict"] == "eligible"}
    lost = {r["pair_id"] for r in before["pair_rows"]
            if r["verdict"] == "eligible" and r["group"] == "0001"}
    assert lost, "0001 is the clean group; it must have had eligible contrasts to lose"
    assert now == was - lost


@pytest.mark.dart
def test_a_group_the_table_does_not_mention_is_untouched(corpus, monkeypatch):
    """The self-fulfilment guard, stated as a test. Every group but `0001` is absent from
    this table -- unvisited by the fill, not refused by it -- and none of them may fire."""
    out = _screen(corpus, {"0001": {"bindings": {"c": DECLARED}}}, monkeypatch)
    fired = {g for g, d in out["groups"].items() if screen.UNFILLABLE_RULE in d["all_rules"]}
    assert fired == {"0001"}


@pytest.mark.dart
def test_the_verdict_is_never_written_into_a_checkpoint(corpus, monkeypatch, tmp_path):
    """It is decided from a table a LATER phase writes, so a checkpoint carrying it would
    replay phase 5's verdict into phase 1."""
    from scripts.screen.checkpoints import screen_mode, write_screen_checkpoints

    out = _screen(corpus, {"0001": {"bindings": {"c": DECLARED}}}, monkeypatch)
    screener = Screener(corpus, corpus / ".screen_cache.json", enabled=False)
    ckpt = tmp_path / "ckpt"
    ckpt.mkdir()
    write_screen_checkpoints(
        ckpt, screen_mode(strict=False, keep_unpairable=False, screen_revisions=True,
                          source=corpus, dest=None, backend=screener.backend),
        out["groups"], out["project_by_id"], {}, {}, set(out["finished_repos"]), screener)
    for path in ckpt.glob("*.json"):
        for rec in json.loads(path.read_text())["groups"].values():
            assert screen.UNFILLABLE_RULE not in rec["rules"]


# ---- the gap R16 cannot see --------------------------------------------------------------
#
# R16 reads the VALUES TABLE and never the fixture on disk, for the reason this module's
# docstring gives. That is right, and it leaves one blind spot: a group whose fixture carries
# a stamp the table has never seen. The fill has simply not run since the group joined the
# corpus, so there is no entry, so R16 is silent, so the group ships and the runner SCHEDULES
# it -- and `fixture_gate`'s hard refusal then aborts the whole campaign rather than skipping
# one group. `2039` and `2386` reached the 2026-09-15 corpus that way.

def test_a_stamp_the_table_has_never_seen_is_reported_apart(tmp_path, monkeypatch):
    from scripts import fixture_gate

    root = tmp_path / "corpus"
    (root / "2039").mkdir(parents=True)
    (root / "2039" / "dependencies.dart").write_text(
        "part of generated_widget;\n\n"
        "late bool fixtureWithZoom; // TODO: value\n"
        "late TabController fixtureTab; // TODO: value\n")
    table = tmp_path / "values.json"
    table.write_text('{"2039": {"bindings": {"fixtureTab": {"expr": null, '
                     '"origin": "none", "rule": "unrecoverable"}}}}')
    monkeypatch.setenv("SPM_FIXTURE_VALUES", str(table))

    assert fixture_gate.unexplained(root) == {"2039": ["fixtureWithZoom"]}, \
        "an `origin: none` entry EXPLAINS a stamp -- it is the authoring worklist, not a gap"


def test_an_explained_stamp_is_not_a_gap(tmp_path, monkeypatch):
    """The authoring worklist is not a defect. Reporting it here would make the loud case --
    a fill that never ran -- indistinguishable from the ordinary one."""
    from scripts import fixture_gate

    root = tmp_path / "corpus"
    (root / "0352").mkdir(parents=True)
    (root / "0352" / "dependencies.dart").write_text(
        "part of generated_widget;\n\nlate TabController fixtureTab; // TODO: value\n")
    table = tmp_path / "values.json"
    table.write_text('{"0352": {"bindings": {"fixtureTab": {"expr": null, '
                     '"origin": "none"}}}}')
    monkeypatch.setenv("SPM_FIXTURE_VALUES", str(table))
    assert fixture_gate.unexplained(root) == {}


def test_the_banner_is_not_a_gap(tmp_path, monkeypatch):
    """Every generated fixture quotes `// TODO: value` in its header, 170 times corpus-wide.
    `fixture_body` already strips it for the refusal; this must strip it too."""
    from scripts import fixture_gate

    root = tmp_path / "corpus"
    (root / "0001").mkdir(parents=True)
    (root / "0001" / "dependencies.dart").write_text(
        "// A slot the hierarchy cannot resolve keeps its `// TODO: value`.\n"
        "part of generated_widget;\n\nbool fixtureFilled = false;\n")
    table = tmp_path / "values.json"
    table.write_text("{}")
    monkeypatch.setenv("SPM_FIXTURE_VALUES", str(table))
    assert fixture_gate.unexplained(root) == {}


# ---- the release: an authored fixture stops the work being owed ---------------------------
#
# R16 names work. `device_runner.awaiting_fixture_groups` reads the set out of
# `exclusions.json` and SKIPS every group in it, so until 2026-09-15 a human could write
# exactly the fixture the rule was asking for and the runner would go on refusing to measure
# the group, with nothing anywhere saying why.

def _values(gid: str = "0463") -> dict:
    return {gid: {"anchor": "abc", "repo": "o/r", "bindings": {
        "fixtureController": {"decl": "late TextEditingController fixtureController;",
                              "expr": None, "origin": "none", "rule": "out_of_scope",
                              "rule_id": "object_type_out_of_scope",
                              "note": "a controller owning mutable text state"}}}}


def test_an_authored_fixture_releases_the_group(tmp_path):
    from scripts import screen_samples

    store = tmp_path / "fixtures"
    (store / "0463").mkdir(parents=True)
    (store / "0463" / "dependencies.dart").write_text(
        "part of generated_widget;\n\n"
        "TextEditingController fixtureController = TextEditingController();\n")
    assert screen_samples.unfillable_groups(_values(), store) == {}


def test_an_unwritten_fixture_still_owes_the_work(tmp_path):
    from scripts import screen_samples

    store = tmp_path / "fixtures"
    (store / "0463").mkdir(parents=True)
    (store / "0463" / "dependencies.dart").write_text(
        "part of generated_widget;\n\n"
        "late TextEditingController fixtureController; // TODO: value\n")
    assert list(screen_samples.unfillable_groups(_values(), store)) == ["0463"]


def test_without_a_store_nothing_is_released(tmp_path):
    """The signature default keeps every existing caller -- and phase 1 of `--full`, which
    runs against an empty table -- behaving exactly as before."""
    from scripts import screen_samples

    assert list(screen_samples.unfillable_groups(_values())) == ["0463"]


def test_the_table_still_decides_membership(tmp_path):
    """The release is NOT a fixture-derived rule. A group the fill never visited has no
    `origin: "none"` entry, so nothing on disk can put it in this set -- which is why a
    fixture-based TEST would have made the exclusion its own cause (config/README.md)."""
    from scripts import screen_samples

    store = tmp_path / "fixtures"
    (store / "9999").mkdir(parents=True)
    (store / "9999" / "dependencies.dart").write_text(
        "part of generated_widget;\n\nlate int fixtureX; // TODO: value\n")
    assert screen_samples.unfillable_groups({}, store) == {}
