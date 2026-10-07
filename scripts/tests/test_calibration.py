"""The screen, run against the corpus it has to reproduce.

`samples/` is the 66-unit corpus that was screened BY HAND, in two rounds, and measured. The
mechanical rules were written to reproduce those judgements, so screening it is the one check
that says whether the rule set still means what it meant when the exclusions were decided.
Two units are expected to fire and are adjudicated: 05 and 16 prune an indeterminate progress
indicator with an `if`/ternary whose frozen input disables it, which removes the widget from
the tree entirely. R1 cannot see that -- telling the two cases apart needs the fixture, which
is why `pumpAndSettle`'s timeout stays the operational detector and this rule stays a
conservative pre-filter.

This lived in docs/mining-runbook.md as a heredoc, as the standing instruction to re-run after any
rule change. It called `screen.classify()` and unpacked `screen.RULES` as 3-tuples; the
2026-08-20 regex -> AST port removed the first and reshaped the second, so the check has been
dead since the port that made it necessary. It is a test now so that it cannot rot silently
again.
"""

from __future__ import annotations

from pathlib import Path

import pytest

from scripts import screen_samples as screen

# Adjudicated in round 1, recorded in this module's docstring and in the screen's own:
# "that is exactly why old seeds 05 and 16 were KEPT".
ADJUDICATED = {"05", "16"}
CURATED_UNITS = 66


@pytest.fixture(scope="module")
def curated(container: Path) -> list[Path]:
    paths = sorted((container / "samples").glob("*/base.dart"))
    if not paths:
        pytest.skip("the curated samples/ corpus is not present")
    return paths


@pytest.fixture(scope="module")
def verdicts(curated: list[Path]) -> dict[str, list[str]]:
    """Every curated unit's hard-rule firings, primed in one batch."""
    backend = screen.DartBackend()
    backend.prime(curated)
    # R10/R11/R12 are read from the manifests, never from a file, so a hand-curated unit can
    # only ever fire R1-R6 here. Group-level rules (R7-R9, R13-R15) are not file verdicts.
    hard = {rid for rid, _ in screen.RULES} - screen.SOFT_RULES
    out = {}
    for path in curated:
        rules, _, _ = backend.analyse(path)
        out[path.parent.name] = sorted(set(rules) & hard)
    return out


@pytest.mark.dart
def test_the_curated_corpus_is_all_there(curated):
    assert len(curated) == CURATED_UNITS


@pytest.mark.dart
def test_calibration_holds_at_two_false_exclusions(verdicts):
    """The number the runbook pins. If a rule change moves it, that is a decision to
    adjudicate against the hand screen, not a test to update."""
    fired = {unit for unit, rules in verdicts.items() if rules}
    assert fired == ADJUDICATED, (
        f"expected exactly the adjudicated units {sorted(ADJUDICATED)} to fire; "
        f"got {sorted(fired)}. A rule has widened or narrowed against the hand screen.")


@pytest.mark.dart
def test_the_two_adjudicated_units_fire_only_the_animation_rule(verdicts):
    """Both are the pruned-progress-indicator shape. A second rule appearing on either means
    something other than the documented false positive is now firing."""
    for unit in sorted(ADJUDICATED):
        assert verdicts[unit] == ["R1_animation"], \
            f"unit {unit} fired {verdicts[unit]}, not the documented R1 false positive"


@pytest.mark.dart
def test_the_rule_digest_is_recorded_with_this_calibration(verdicts):
    """The calibration above is a statement about one rule vocabulary. Recording the digest
    beside it is what lets a future reader tell "still calibrated" from "never re-run"."""
    from scripts import ast_tools
    assert ast_tools.rules_version(), "no rule digest; the checkpoint mode would be blind too"
