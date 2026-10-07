"""R20: the two endpoints of a contrast must agree about which shims drop their children.

Pair-level and HARD, on exactly R13's footing -- it says nothing about whether either
transplant is measurable on its own, only that the two cannot be compared to each other. The
role-level half is R19, which is soft; `scripts/screen/rules.py` holds why the partition falls
there and `scripts/dart_tools/lib/src/shims.dart` holds how a drop is detected.

Written as a function rather than a class because, unlike `Bindings`, this pass has no cache
of its own to own: the drops were computed on the same `dart` batch that produced the rule
verdicts, and `Screener` has been carrying them since. Nothing here re-reads a file.
"""

from __future__ import annotations

from pathlib import Path

from scripts.screen.rules import SHIM_FORM_RULE


def drop_keys(screener, path: Path) -> set[str]:
    """The `class.constructor` keys whose shim renders none of what `path` handed it.

    The discarded ARGUMENT names are deliberately not part of the key. Two endpoints reaching
    the same dropping constructor erase the same subtree, and which arguments they passed to
    it is the edit talking -- keying on those would exclude a pair for the very change it is
    there to measure.
    """
    return {f"{d['class']}.{d['constructor']}" for d in screener.shim_drops(path)}


def apply(screener, pair_rows: list[dict], *, enforce: bool = True) -> dict:
    """Record `shim_drop_delta` on every surviving pair, and exclude the ones that differ.

    Recorded whether or not `enforce` is set, for the reason `Bindings.apply` records
    `binding_delta` either way: the rule's justification is its rate, and the rate has to be
    readable off the same corpus snapshot the verdicts were taken on.

    Unlike R13 there is NO vacuity guard. A corpus where no pair disagrees is the expected
    state, not a symptom of reading the wrong tree: the drops come from the screened files
    themselves, not from a fixture split that an export has already emptied. What the returned
    counts do instead is make the silence legible -- `pairs_compared` says the rule had input.
    """
    survivors = [r for r in pair_rows if r["verdict"] == "eligible" and r["_endpoints"]]
    counts = {"pairs_compared": len(survivors), "pairs_disagreeing": 0,
              "pairs_dropping_at_both": 0, "enforced": bool(enforce)}
    for r in survivors:
        before, after = r["_endpoints"]
        b, a = drop_keys(screener, before), drop_keys(screener, after)
        r["shim_drop_delta"] = {
            "before": sorted(b), "after": sorted(a),
            "relation": ("identical" if b == a else "differs"),
        }
        if b != a:
            counts["pairs_disagreeing"] += 1
            if enforce:
                r["verdict"], r["rules"] = "excluded", [SHIM_FORM_RULE]
        elif b:
            # Symmetric: both endpoints erase the same subtree, so the delta is still the
            # edit's -- understated in magnitude, which is R19's soft finding and not this
            # rule's business.
            counts["pairs_dropping_at_both"] += 1
    return counts
