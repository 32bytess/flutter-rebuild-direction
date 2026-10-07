"""Layer-2 feature-delta audit (log-only) for generated mutations.

NOT a gate: this never blocks a mutation. Layer 1 (``gate.py``) is the blocking content +
input guard. This layer is an independent, after-the-fact check that each directive did what
it claims — the intended static feature moved in the expected direction, and no *untolerated*
feature moved (anti-tangle) — plus an optional cross-check of the directive's expected cost
direction against the measured Faster/Slower label. It validates *transformation / label
quality*, never content: the 12 SPM features are content-blind by construction.

Audit-only (not a hard postcondition) because ``const``-boundary interactions make some
feature counts legitimately non-deterministic; a moved side-effect feature is tolerated, not
rejected.

Feature names below are the exact ``static.jsonl`` JSON keys emitted by the SPM extractor
(spm/.../analysis_result_model.dart ``toJson``). The const-count key is ``constWidgetCount``;
extractor output before 2026-07-18 used the misnamed key ``constConstructorRatio`` for the
same integer count, and ``_load_static`` normalizes it on load.
"""

from __future__ import annotations
import json
import logging
import os

# The 14 numeric structural features (identity keys instanceId/filePath/stateClassName and
# the two bool→int features are handled as ints too). Deltas are computed over these.
# Naming scheme (2026-07-20 extractor): tree* = aggregated over the whole static call
# tree (root build + child builds + helper bodies where documented), root* = root build
# only, helper* = helper bodies only.
FEATURES = (
    "treeNonConstWidgetCount",
    "treeMaxWidgetNestingDepth",
    "treeListRenderingStrategy",
    "rootBuildReturnsConstWidget",
    "treeConstWidgetCount",
    "helperReferenceCount",
    "usesLayoutDependentBuilder",
    "treeCyclomaticComplexity",
    "treeIterationCount",
    "treeMaxIterationNestingDepth",
    "iterationWidgetCount",
    "valueObjectAllocCount",
    "helperWidgetCount",
    "helperMaxWidgetNestingDepth",
)

# Old static.jsonl keys -> current keys, applied on load so every vintage audits
# identically. buildUsesListViewBuilder (bool 0/1) maps onto the 0/1/2 ordinal's
# none/lazy levels; it cannot express the eager level (2).
LEGACY_KEY_RENAMES = {
    "buildWidgetInstanceCount": "treeNonConstWidgetCount",
    "buildMaxWidgetNestingDepth": "treeMaxWidgetNestingDepth",
    "buildUsesListViewBuilder": "treeListRenderingStrategy",
    "buildListRenderingStrategy": "treeListRenderingStrategy",
    "buildReturnsConstWidget": "rootBuildReturnsConstWidget",
    "constConstructorRatio": "treeConstWidgetCount",
    "constWidgetCount": "treeConstWidgetCount",
    "buildHelperMethodCount": "helperReferenceCount",
    "buildCyclomaticComplexity": "treeCyclomaticComplexity",
    "buildIterationCount": "treeIterationCount",
    "buildMaxIterationNestingDepth": "treeMaxIterationNestingDepth",
    "helperMethodWidgetCount": "helperWidgetCount",
    "helperMethodMaxNestingDepth": "helperMaxWidgetNestingDepth",
}

# directive -> {feature: expected sign of (mutation - base)}. Keys match prompt.DIRECTIVES.
FEATURE_EXPECT: dict[str, dict[str, int]] = {
    "nest_deeper":     {"treeMaxWidgetNestingDepth": +1},
    "all_const":       {"treeConstWidgetCount": +1},
    "drop_const":      {"treeConstWidgetCount": -1, "rootBuildReturnsConstWidget": -1},
    # lazy (1) -> eager (2) on the ordinal, and the O(N) expansion adds iteration
    "eager_list":      {"treeListRenderingStrategy": +1, "treeIterationCount": +1},
    "extract_widgets": {"helperReferenceCount": -1, "helperWidgetCount": -1},
    "inline_helpers":  {"helperReferenceCount": -1},
    "add_siblings":    {"treeNonConstWidgetCount": +1},
    "layout_builder":  {"usesLayoutDependentBuilder": +1},
}

# Features a directive may move as a *documented* side-effect (mostly const-boundary
# extraction interactions). Moving one of these is not flagged as a tangled change.
FEATURE_SIDE_EFFECTS: dict[str, set[str]] = {
    "nest_deeper":     {"treeNonConstWidgetCount"},
    "all_const":       {"rootBuildReturnsConstWidget", "treeNonConstWidgetCount",
                        "treeMaxWidgetNestingDepth"},
    "drop_const":      {"treeNonConstWidgetCount", "treeMaxWidgetNestingDepth"},
    "eager_list":      {"treeNonConstWidgetCount", "treeMaxWidgetNestingDepth"},
    "extract_widgets": {"treeConstWidgetCount", "treeNonConstWidgetCount",
                        "treeMaxWidgetNestingDepth", "helperMaxWidgetNestingDepth"},
    "inline_helpers":  {"treeNonConstWidgetCount", "treeMaxWidgetNestingDepth",
                        "helperWidgetCount", "helperMaxWidgetNestingDepth"},
    "add_siblings":    set(),
    "layout_builder":  {"treeMaxWidgetNestingDepth", "treeNonConstWidgetCount"},
}

# The two 2026-07-20 secondary signals move under almost any widget-tree edit
# (styling, wrapping, list/iteration changes); tolerate them for every directive
# rather than flagging tangled changes.
for _d in FEATURE_SIDE_EFFECTS:
    FEATURE_SIDE_EFFECTS[_d] |= {"iterationWidgetCount", "valueObjectAllocCount"}

# directive.expect (cost direction) -> the label it predicts (1 = Slower, 0 = Faster/Stable).
_EXPECT_LABEL = {"slower": 1, "faster": 0, "neutral": 0, "stable": 0}


def audit_pair(
    base: dict, mut: dict, directive: str, expect: str | None = None,
    measured_label: int | None = None,
) -> list[str]:
    """Return a list of audit notes (empty == clean). Pure; no I/O."""
    notes: list[str] = []
    intended = FEATURE_EXPECT.get(directive, {})
    if directive not in FEATURE_EXPECT:
        notes.append(f"unknown directive '{directive}' (no expected-feature map)")
    tolerated = set(intended) | FEATURE_SIDE_EFFECTS.get(directive, set())

    # (a) intended feature(s) moved in the expected direction?
    for feat, sign in intended.items():
        d = int(mut.get(feat, 0)) - int(base.get(feat, 0))
        if (sign > 0 and d <= 0) or (sign < 0 and d >= 0):
            notes.append(
                f"directive weak/wrong-direction: {feat} moved {d:+d}, expected "
                f"{'increase' if sign > 0 else 'decrease'}"
            )

    # (b) any untolerated feature moved? (possible tangled change)
    for feat in FEATURES:
        d = int(mut.get(feat, 0)) - int(base.get(feat, 0))
        if d != 0 and feat not in tolerated:
            notes.append(f"possible tangled change: {feat} moved {d:+d}")

    # (c) expected cost direction vs measured label (only if a label is supplied)
    if measured_label is not None and expect is not None:
        predicted = _EXPECT_LABEL.get(expect.lower())
        if predicted is not None and predicted != measured_label:
            notes.append(
                f"label disagreement: directive expected "
                f"{'Slower' if predicted else 'Faster/Stable'} but measured "
                f"{'Slower' if measured_label else 'Faster/Stable'}"
            )
    return notes


def _load_static(static_path: str) -> dict[str, dict]:
    """static.jsonl -> {instanceId: feature_record}.

    Normalizes every legacy key vintage (pre-2026-07-18 ``constConstructorRatio``,
    pre-2026-07-20 ``build*``/``helperMethod*`` names) to the current schema via
    LEGACY_KEY_RENAMES so old and new files audit identically.
    """
    by_id: dict[str, dict] = {}
    with open(static_path) as f:
        for line in f:
            line = line.strip()
            if line:
                r = json.loads(line)
                for old, new in LEGACY_KEY_RENAMES.items():
                    if new not in r and old in r:
                        r[new] = r.pop(old)
                by_id[r["instanceId"]] = r
    return by_id


def run_audit(
    mutations_path: str,
    static_path: str,
    out_path: str | None = None,
    labels: dict[str, int] | None = None,
) -> dict:
    """Join mutations.jsonl against static.jsonl and audit each accepted mutation.

    Requires each mutations.jsonl row to carry the instanceIds of both the base and the
    mutation so the two feature records can be looked up:
        base_instance_id, mutation_instance_id
    (LINEAGE GAP — see module notes / tasks/2026-07-05: __main__.py does not yet write these;
    rows without them are counted as 'unjoinable' rather than guessed.)

    ``labels`` optionally maps mutation_id -> measured label (1 Slower / 0 Faster-Stable),
    parsed elsewhere from the profile-mode buildSpan delta.
    """
    static = _load_static(static_path)
    summary = {"audited": 0, "clean": 0, "weak": 0, "tangled": 0,
               "label_disagree": 0, "unjoinable": 0}
    out = open(out_path, "w") if out_path else None
    try:
        with open(mutations_path) as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                row = json.loads(line)
                if not row.get("accepted", False):
                    continue
                bid, mid = row.get("base_instance_id"), row.get("mutation_instance_id")
                if bid not in static or mid not in static:
                    summary["unjoinable"] += 1
                    continue
                measured = (labels or {}).get(row.get("mutation_id"))
                notes = audit_pair(
                    static[bid], static[mid], row.get("directive", ""),
                    expect=row.get("expect"), measured_label=measured,
                )
                summary["audited"] += 1
                if not notes:
                    summary["clean"] += 1
                if any(n.startswith("directive weak") for n in notes):
                    summary["weak"] += 1
                if any(n.startswith("possible tangled") for n in notes):
                    summary["tangled"] += 1
                if any(n.startswith("label disagreement") for n in notes):
                    summary["label_disagree"] += 1
                if out:
                    out.write(json.dumps({
                        "mutation_id": row.get("mutation_id"),
                        "directive": row.get("directive"),
                        "notes": notes,
                    }) + "\n")
    finally:
        if out:
            out.close()
    logging.info(f"L2 audit summary: {summary}")
    return summary


if __name__ == "__main__":
    import argparse

    ap = argparse.ArgumentParser(description="Layer-2 feature-delta audit (log-only).")
    ap.add_argument("--mutations", default="samples/mutations.jsonl")
    ap.add_argument("--static", required=True, help="SPM extractor static.jsonl")
    ap.add_argument("--out", default="samples/audit.jsonl")
    args = ap.parse_args()
    logging.basicConfig(level=logging.INFO, format="%(message)s")
    s = run_audit(args.mutations, args.static, out_path=args.out)
    print(json.dumps(s, indent=2))
    if not os.path.exists(args.static):
        print("NOTE: static.jsonl not found — run the SPM extractor first.")
