"""The real corpus, screened end to end. This is the refactor guard.

`test_golden_corpus.py` proves the rules compose correctly on ten groups built to fire them.
This proves they still produce THE PUBLISHED NUMBERS on the 1,400-odd groups of
`probe_v2/samples_v2` -- the ones arm 2 will be measured against.

It costs about two and a half minutes and needs `probe_v2/` plus a warm fixture store, so it
is marked `slow` and deselected by default:

    python3 -m pytest scripts/tests -q                  # everything else
    python3 -m pytest scripts/tests -q -m slow          # this

The corpus GROWS -- the mine is still running -- so the group count is deliberately not
pinned. What is pinned is everything downstream of the hold: a group the mine adds arrives
held, and a held group contributes nothing until its repository checkpoints. If a number
below moves, either the corpus reached past the hold or a screening decision changed.
"""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

import pytest

# The published arm-2 triple, as new_samples/exclusions.json records it.
# 191 / 45 / 20 since 2026-09-05, when the value table was trimmed to primitives and five
# groups whose fill needed an object stand-in joined `0607` as R16 exclusions. The 2026-09-01
# 214 / 50 / 20, the 2026-08-31 215 / 51 / 20 and the 2026-08-28 screen's 214 / 50 / 19 are
# all retired -- and the most recent retirement is a CHANGED RULE, not a corrected verdict.
#
# THE EXCLUSIONS ARE PART OF WHAT IS PINNED, and since 2026-09-02 they are not handed to the
# screen: `R16_unfillable_fixture` derives them. The screen below runs with NO hand list, so
# these numbers also assert that `config/fixture_policy.json` alone reproduces the shipped
# corpus. That is a stronger claim than the one this file used to make.
PUBLISHED = {
    "contrasts_screened": 433,
    "eligible_pairs": 191,
    "eligible_adjacent_pairs": 65,
    "eligible_mover_scopes": 45,
    "eligible": 170,
}
# The role funnel behind that pair count. A reader who sees only the contrast total cannot
# tell a small corpus from a heavily filtered one, so the filters are pinned too.
PUBLISHED_FUNNEL = {
    "roles_excluded_R14_short_vector": 305,
    "roles_dropped_duplicate_content": 678,
    "distinct_code_roles": 351,
    "scopes_with_a_contrast": 96,
}
# R13's cost: 83 of the 274 contrasts that survive every other rule carry a binding
# difference and are dropped -- 68 added, 9 both, 6 removed.
PUBLISHED_BINDING = {"identical": 191, "added": 68, "both": 9, "removed": 6}
# The roles the 191 contrasts are actually taken between -- what `--prune-to-endpoints`
# ships and what `device_runner --eligible-only` measures. Pinned because the whole point
# of the prune is that the number on disk and this number are the same one.
PUBLISHED_ENDPOINTS = 156

# The one group the corpus drops for a reason no per-file rule reaches, and the rule that now
# drops it. `0607`'s only binding is a `late TabController`, whose type
# `config/fixture_policy.json` DECLARES unrecoverable -- a TickerProvider vsync cannot exist
# above the element tree -- so the fill records `origin: "none"` and R16 excludes the group.
# Until 2026-09-02 the same drop came from a second authored file,
# `config/arm2_hand_exclusions.txt`, which only restated what the policy already implied.
UNFILLABLE_GROUP = "0607"
# The five that joined it on 2026-09-05, when the value table was trimmed to primitives: each
# needs an object stand-in the policy now NAMES in `out_of_scope` rather than fabricating.
# `1773` is the indirect one -- `Event` is constructible except that it requires a `DateTime`.
UNFILLABLE_GROUPS = {UNFILLABLE_GROUP, "0269", "0734", "0879", "1656", "1773"}


pytestmark = [pytest.mark.slow, pytest.mark.dart]


@pytest.fixture(scope="module")
def screened(container: Path, tmp_path_factory) -> dict:
    source = container / "probe_v2" / "samples_v2"
    if not source.is_dir():
        pytest.skip("probe_v2/samples_v2 is not present")
    records = tmp_path_factory.mktemp("real")
    completed = subprocess.run(
        [sys.executable, "-m", "scripts.screen_samples",
         "--source", str(source), "--records", str(records), "--report-only"],
        cwd=str(container), capture_output=True, text=True, timeout=1800,
    )
    assert completed.returncode == 0, completed.stdout + completed.stderr
    return json.loads((records / "exclusions.json").read_text())


def test_the_published_totals_still_hold(screened):
    got = {k: screened["totals"][k] for k in PUBLISHED}
    assert got == PUBLISHED


def test_the_role_funnel_behind_them_still_holds(screened):
    got = {k: screened["contrast_funnel"][k] for k in PUBLISHED_FUNNEL}
    assert got == PUBLISHED_FUNNEL


def test_r13s_cost_still_holds(screened):
    import collections
    got = collections.Counter(
        r["binding_delta"]["relation"] for r in screened["pairs"] if r.get("binding_delta"))
    assert dict(got) == PUBLISHED_BINDING


def test_the_measured_role_count_still_holds(screened):
    """156 of the corpus's roles are an endpoint of an eligible contrast. Derived here the
    way `device_runner.eligible_endpoints` derives it -- from the pairs, never from a
    group's own `eligible` flag, which disagrees (`1793` is `eligible: false` and carries
    one)."""
    import re

    endpoints: dict[str, set[str]] = {}
    for row in screened["pairs"]:
        if row["verdict"] != "eligible":
            continue
        a, b = re.search(r"@([0-9a-f]{8})\.\.([0-9a-f]{8})$", row["pair_id"]).groups()
        endpoints.setdefault(row["group"], set()).update((a, b))
    assert sum(len(v) for v in endpoints.values()) == PUBLISHED_ENDPOINTS
    assert len(endpoints) == PUBLISHED["eligible_mover_scopes"]


def test_the_record_names_the_values_table_it_was_screened_against(screened):
    """`exclusions.json` records the `values_digest` of the screen that wrote it, and on
    2026-08-31 that digest was `sha256(policy || "{}")` -- the screen had run against an
    EMPTY values table and nothing noticed for a day. The digest was written down correctly
    and read by nobody; this is the reading."""
    from scripts.fixture_values import values_version

    assert screened["provenance"]["values_digest"] == values_version()


def test_every_eligible_contrast_has_identical_bindings(screened):
    """R13 is applied, so nothing eligible may carry a binding difference. The invariant is
    worth stating separately from the counts: a count can match while the rule stopped
    being enforced."""
    for row in screened["pairs"]:
        if row["verdict"] == "eligible":
            assert row["binding_delta"]["relation"] == "identical"


def test_no_group_level_exclusion_carries_an_eligible_contrast(screened):
    """R7 duplicate, R0 hand exclusion and R9 hold remove a group from the corpus. `export`
    ships whatever `carries_pair` names, so a contrast attributed to one of them puts the
    group back."""
    level = {"R7_duplicate", "R0_manual", "R9_repo_unfinished",
             "R16_unfillable_fixture"}
    excluded = {gid for gid, g in screened["groups"].items()
                if level & set(g["excluded_by"])}
    leaked = [r for r in screened["pairs"]
              if r["verdict"] == "eligible" and r["group"] in excluded]
    assert leaked == []


def test_the_adjacent_subset_is_drawn_from_the_same_funnel(screened):
    """The adjacent set is FLAGGED on the all-pairwise rows, never screened separately,
    so the primary test cannot drift from what was screened."""
    adjacent = [r for r in screened["pairs"] if r.get("adjacent")]
    assert sum(1 for r in adjacent if r["verdict"] == "eligible") \
        == screened["totals"]["eligible_adjacent_pairs"]
    assert len(adjacent) < len(screened["pairs"]), "adjacent must be a strict subset"


def test_every_group_the_mine_added_since_arrives_held(screened):
    """Why the group count is not pinned: the corpus grows, and growth must not reach past
    the hold. 1,549 groups were screened for the published record; anything beyond that is
    held until its repository checkpoints.

    All 84 mined repositories have now checkpointed, so nothing is currently held and the
    bound is tight. A future mine that adds a repository must therefore move BOTH numbers --
    if `groups` rises while `held_unfinished` stays at 0, a group reached the funnel without
    ever being held, which is the failure this asserts against.
    """
    assert screened["totals"]["groups"] - screened["totals"]["held_unfinished"] <= 1549


def test_the_exclusions_no_per_file_rule_reaches_are_derived_from_the_policy(screened):
    """The corpus's group-level judgements, and the whole reason `config/fixture_policy.json`
    can be an authored input the corpus is a pure function of.

    Two things are asserted, and the second matters as much as the first: these six groups are
    out, and they are the ONLY ones R16 takes. A rule that quietly removed a seventh would move
    the published triple without anybody choosing to -- which is why the set is written out
    rather than counted.
    """
    unfillable = screened.get("unfillable") or {}
    assert set(unfillable) == UNFILLABLE_GROUPS, (
        f"R16 fired on {sorted(unfillable)}; expected exactly {sorted(UNFILLABLE_GROUPS)}")
    for gid in sorted(UNFILLABLE_GROUPS):
        assert unfillable[gid]["declared"] is True, (
            f"{gid} must be dropped because the policy NAMES the type it needs -- in "
            f"`unrecoverable` or in `out_of_scope` -- not because the policy is missing an "
            f"entry; those are different findings")
        assert "R16_unfillable_fixture" in screened["groups"][gid]["excluded_by"]


def test_no_group_is_dropped_for_a_type_the_policy_merely_omits(screened):
    """The loud half of R16. A group excluded because nobody wrote its type into the map is a
    short policy, not a group that deserves to go, and it must never pass unnoticed."""
    undeclared = sorted(g for g, i in (screened.get("unfillable") or {}).items()
                        if not i.get("declared"))
    assert undeclared == [], (
        f"{undeclared} are unfillable because config/fixture_policy.json has no entry for "
        f"their type. Add the type, or record the omission deliberately.")


def test_the_hand_exclusion_list_is_gone(container: Path):
    """It restated a consequence of the policy in a second authored file. Two records of one
    decision is how they drift apart."""
    assert not (container / "config" / "arm2_hand_exclusions.txt").exists()


# ---------------------------------------------------------------------------------------
# R17 / R18 -- whose code is inside the corpus. Added 2026-09-04; neither moves a count.
# ---------------------------------------------------------------------------------------

# The only group in the corpus whose shipped roles carry inlined third-party SOURCE. Both of
# its roles carry `AutoSizeTextField` and its companion `State` from `auto_size_text_field`,
# which is MIT -- so R17 passes them and the group keeps its one contrast. A blanket ban on
# inlined package source would instead have cost it: 213 / 49 / 20.
INLINING_GROUP = "1793"


def test_neither_licence_rule_fires_on_an_eligible_group(screened):
    """The assertion the whole change has to survive: R17 and R18 exclude nothing that was
    eligible before them. If this fails, the corpus triple above has already moved."""
    fired = {g: d["excluded_by"] for g, d in screened["groups"].items()
             if {"R17_package_license", "R18_repo_license"} & set(d["excluded_by"])
             and any(p["group"] == g and p["verdict"] == "eligible"
                     for p in screened["pairs"])}
    assert fired == {}


def test_every_repository_in_the_corpus_is_under_an_allowed_licence(screened):
    """R18 asserts what `scripts/collector` already enforced and then dropped. It fires on
    nothing here -- 14 MIT and 6 Apache-2.0 -- which is the finding, not a vacuous pass:
    the same rule fires loudly on a repository the collector never recorded."""
    assert (screened.get("repo_license") or {}) == {}


def test_the_group_that_carries_package_source_keeps_its_contrast(screened):
    """`1793` is the case the licence-aware rule exists for. Its endpoints carry package
    source, the package is permissive, and the contrast survives."""
    eligible = [p for p in screened["pairs"]
                if p["group"] == INLINING_GROUP and p["verdict"] == "eligible"]
    assert len(eligible) == 1, "1793 contributes exactly one eligible contrast"
    for role in (INLINING_GROUP,):
        assert "R17_package_license" not in screened["groups"][role]["all_rules"]


def test_the_files_carrying_package_source_are_all_attributed_or_named(screened):
    """R17's two kinds are reported apart, and only one of them can hide a real finding.
    `disallowed` is a policy verdict on a named package and must be empty here.
    `unattributed` is a provenance gap: it is NOT empty, because provenance is recorded for
    the 20 eligible repositories and not for the 81 mined ones outside them, and that is
    stated rather than silently tolerated."""
    licence = screened.get("package_license") or {}
    assert (licence.get("disallowed") or {}) == {}, (
        "a package outside config/license_policy.json reached a transplant")
    assert licence.get("files_with_inlined_packages"), (
        "no file carries an inlining count, so R17 decided nothing -- the vacuity guard "
        "should have refused this run")
