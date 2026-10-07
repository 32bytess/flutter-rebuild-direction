"""The whole screen, end to end, over a ten-group synthetic corpus.

`test_units.py` pins the pieces and `test_calibration.py` pins the rule vocabulary against
the hand-screened corpus. This is the one that pins how they COMPOSE: which groups survive,
which contrasts are formed, which rule removes each of the rest, and what lands in
`exclusions.json` -- the artifact `maximal_branch.py` and `fixture_values.py` read.

It runs on the `--vectors` path so it needs no `spm analyze`: the feature vectors are
supplied by `mini_corpus`, which is what makes a full screen take about a second. See that
module for what each of the ten groups exists to exercise.

Regenerate the golden after a DELIBERATE change:

    python3 -m scripts.tests.regolden
"""

from __future__ import annotations

import json
from pathlib import Path

import pytest

from scripts import screen_samples as screen
from scripts.tests import mini_corpus
from scripts.tests.regolden import GOLDEN, run_screen, stable


@pytest.fixture(scope="module")
def screened(tmp_path_factory) -> dict:
    root = tmp_path_factory.mktemp("golden")
    return run_screen(root)


# ---------------------------------------------------------------------------------------
# The golden itself
# ---------------------------------------------------------------------------------------

@pytest.mark.dart
def test_exclusions_json_matches_the_golden(screened):
    """The whole record, field for field. A diff here is a behaviour change: either intended,
    in which case regenerate, or the thing this file exists to catch."""
    expected = json.loads(GOLDEN.read_text())
    assert stable(screened) == expected


# ---------------------------------------------------------------------------------------
# Provenance -- what produced the record, in the record
# ---------------------------------------------------------------------------------------
#
# Held out of the golden on purpose: a digest changes whenever a rule or the fixture-value
# table is edited, and a golden that fails on that would be failing about the wrong thing.
# What matters is that the fields are THERE and filled, so two records made under different
# rule generations can be told apart.

@pytest.mark.dart
def test_the_record_names_the_rule_set_and_the_value_table(screened):
    prov = screened["provenance"]
    assert prov["rules_digest"], "without this, two rule generations look identical"
    assert prov["values_digest"], "the fixture values decide what the roles mount from"
    assert prov["backend"] == "dart"
    assert prov["screened_at"].startswith("20")


@pytest.mark.dart
def test_the_record_names_the_command_that_produced_it(screened):
    """There is no script or CI entry for this tool -- every documented invocation is prose
    in docs/mining-runbook.md -- so the argv is the only machine-readable statement of how the
    corpus was produced."""
    assert "--report-only" in screened["provenance"]["argv"]
    assert "--source" in screened["provenance"]["argv"]


@pytest.mark.dart
def test_the_record_names_the_trees_that_are_not_source(screened):
    """`--vectors` and `--binding-source` each silently change what is screened. A record
    that does not name them cannot be reproduced from itself."""
    flags = screened["provenance"]["flags"]
    assert flags["vectors"], "this run supplies its own vectors and must say so"
    assert flags["contrasts"] == "all_pairwise"
    assert flags["strict"] is False and flags["promoted_by_strict"] == []


@pytest.mark.dart
def test_strict_records_every_rule_it_promotes(tmp_path):
    """R12 fires on roughly half the real corpus, so `--strict` removes far more evidence
    than the R6 its help text used to name. Whatever it promoted is recorded per run."""
    out = run_screen(tmp_path, extra=["--strict"])
    assert out["provenance"]["flags"]["promoted_by_strict"] == sorted(screen.SOFT_RULES)


# ---------------------------------------------------------------------------------------
# Concentration -- recomputable from the record, not only beside it
# ---------------------------------------------------------------------------------------

@pytest.mark.dart
def test_every_group_row_carries_its_repository(screened):
    """Without this the per-repository spread had to be derived elsewhere, and the largest-
    share figure the decisions record quotes could not be checked against the screen."""
    assert all(g["project"] for g in screened["groups"].values())


@pytest.mark.dart
def test_the_spread_across_scopes_and_repositories_is_recorded(screened):
    totals = screened["totals"]
    assert sum(screened["contrasts_per_scope"].values()) == totals["eligible_pairs"]
    assert sum(v["eligible_contrasts"] for v in screened["by_repository"].values()) \
        == totals["eligible_pairs"]
    assert sum(v["eligible_mover_scopes"] for v in screened["by_repository"].values()) \
        == totals["eligible_mover_scopes"]
    assert 0 < totals["largest_repository_share"] <= 1.0


# ---------------------------------------------------------------------------------------
# What each group was built to prove, asserted by name so a golden diff is readable
# ---------------------------------------------------------------------------------------

def rules_on(out: dict, gid: str) -> list[str]:
    return out["groups"][gid]["all_rules"]


def contrasts_of(out: dict, gid: str) -> list[dict]:
    return [r for r in out["pairs"] if r["group"] == gid]


@pytest.mark.dart
def test_a_clean_group_forms_every_within_scope_pair(screened):
    """Three distinct-code roles -> a-b, a-c, b-c. Two of them are adjacent; the a-c pair
    spans two commits and is the augmentation, never the adjacent set."""
    rows = contrasts_of(screened, "0001")
    assert len(rows) == 3 and all(r["verdict"] == "eligible" for r in rows)
    assert sum(1 for r in rows if r["adjacent"]) == 2


@pytest.mark.dart
def test_a_hard_rule_on_one_endpoint_removes_the_contrast(screened):
    """A pair needs BOTH endpoints clean. 0002's representative is clean, so the GROUP
    verdict says nothing -- which is the point of screening per pair."""
    assert rules_on(screened, "0002") == [], "the representative is clean"
    assert [r["rules"] for r in contrasts_of(screened, "0002")] == [["R1_animation"]]


@pytest.mark.dart
def test_a_single_revision_group_fires_r8(screened):
    assert rules_on(screened, "0003") == [screen.NO_PAIR_RULE]
    assert contrasts_of(screened, "0003") == []


@pytest.mark.dart
def test_an_identical_feature_vector_fires_r15(screened):
    """Distinct code, identical vector. `mine`'s own nonzero-delta filter was taken over the
    SOURCE scope; this is that filter re-applied to what is on disk."""
    assert [r["rules"] for r in contrasts_of(screened, "0004")] == [[screen.ZERO_DELTA_RULE]]


@pytest.mark.dart
def test_a_short_vector_role_never_reaches_a_pair(screened):
    """R14 is role-level: the role is dropped before any pair exists, so 0005's two
    revisions become one usable role and the group forms nothing."""
    assert screened["contrast_funnel"]["roles_excluded_R14_short_vector"] == 1
    assert contrasts_of(screened, "0005") == []


@pytest.mark.dart
def test_an_unfinished_repository_is_held(screened):
    assert rules_on(screened, "0006") == [screen.UNFINISHED_RULE]


@pytest.mark.dart
def test_the_higher_id_of_a_duplicate_pair_is_the_one_dropped(screened):
    """0007's representative is byte-identical to 0001's. Keep the lowest id, drop the rest."""
    assert rules_on(screened, "0001") == []
    assert rules_on(screened, "0007") == [screen.DUPLICATE_RULE]


@pytest.mark.dart
def test_different_binding_sets_fire_r13(screened):
    """0008's second revision hoists a second seed, so the two endpoints mount from
    different initial state and the contrast is not a change against identical state."""
    row, = contrasts_of(screened, "0008")
    assert row["rules"] == [screen.BINDING_RULE]
    assert row["binding_delta"]["relation"] == "added"
    assert row["binding_delta"]["added"] == ["fixtureLabel"]


@pytest.mark.dart
def test_an_unverified_transplant_fires_r10_from_the_manifest(screened):
    """R10 is read from `code_rows.jsonl`, never from the file: the package resolution the
    transplant was verified under is gone by the time the screen runs."""
    assert [r["rules"] for r in contrasts_of(screened, "0009")] == [[screen.UNVERIFIED_RULE]]


@pytest.mark.dart
def test_binding_delta_is_recorded_on_every_pair_that_reached_r13(screened):
    """The rule's whole justification is its rate, so the cost stays recoverable from the
    JSON without a second pass."""
    reached = [r for r in screened["pairs"] if r["binding_delta"] is not None]
    assert {r["binding_delta"]["relation"] for r in reached} == {"identical", "added"}


# ---------------------------------------------------------------------------------------
# Group-level exclusions must reach the contrast set
# ---------------------------------------------------------------------------------------
#
# `all_pairwise_rows` intersects each endpoint's FILE rules with the hard set and consults no
# group verdict, while the adjacent path's `verdict_for` checks R7 and R0 explicitly. On the
# normal run that difference is invisible: phase B builds fixtures only for groups that are
# not duplicate / manual / unfinished, so an excluded group has no vector and forms no pair.
# Supply `--vectors` -- the path the 2026-08-28 record's own reproduction command uses -- and
# that protection is gone.

@pytest.mark.dart
def test_a_duplicate_group_forms_no_eligible_contrast(screened):
    """R7 removes a group from the corpus. A contrast attributed to it would ship it back:
    `export` gates on `carries_pair`, and `carries_pair` comes from these rows."""
    assert [r for r in contrasts_of(screened, "0007") if r["verdict"] == "eligible"] == []


@pytest.mark.dart
def test_a_held_group_forms_no_eligible_contrast(screened):
    """A repository still being mined has no settled revision list, so a contrast over it is
    a contrast over a half-written group. `export` subtracts `held` and is protected; the
    reported mover-scope count is not."""
    assert [r for r in contrasts_of(screened, "0006") if r["verdict"] == "eligible"] == []


@pytest.mark.dart
def test_a_hand_excluded_group_forms_no_eligible_contrast(tmp_path):
    """`--exclude-groups` is the judgement no rule makes. It prints `hand-excluded: 1 groups`
    and marks the group R0_manual -- and on the --vectors path the group's contrasts stay
    eligible, so the exclusion is cosmetic and `export` ships it anyway."""
    gid = mini_corpus.HAND_EXCLUDED
    out = run_screen(tmp_path, extra=["--exclude-groups", f"{gid}  # nothing to measure"])
    assert out["groups"][gid]["excluded_by"] == [screen.MANUAL_RULE]
    assert [r for r in out["pairs"] if r["group"] == gid and r["verdict"] == "eligible"] == []
    assert out["manual_reasons"][gid] == "nothing to measure", \
        "R0 is the one rule whose justification cannot be re-derived from anything"


@pytest.mark.dart
def test_the_mover_scope_count_excludes_held_and_duplicate_groups(screened):
    """The headline `ELIGIBLE MOVER SCOPES`. It is the number that travels with every
    contrast count, so it must not include a scope the corpus does not contain."""
    assert screened["totals"]["eligible_mover_scopes"] == 2, \
        "only 0001 and 0010 are clean scopes carrying an eligible contrast"
