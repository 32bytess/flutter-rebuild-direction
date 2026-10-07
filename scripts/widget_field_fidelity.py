"""Measure what the widget-field lift moves, and refuse anything it must not.

WHAT IS AT STAKE
----------------
`scripts/dart_tools/lib/src/widget_fields.dart` lifts the transplanted widget's constructor
fields into fixture bindings. Under `--lift-mode state` -- the corpus shape since 2026-09-08 --
it also gives the `State` a `late final` field per lifted field, assigns it in `initState`, and
rewrites `widget.title` to `title`. The build body is a measurement input: `spm analyze`
computes the 14-feature vector from exactly that AST, so a rewrite that moves a feature moves
the independent variable of the study and every contrast built from it.

Since 2026-09-09 state mode also strips the widget itself down to
`const GeneratedWidget({super.key})`, so a role mounts from `lib/main.dart` without an
argument. That is outside the measured region -- `spm analyze` reads
`_GeneratedWidgetState.build` and nothing else -- so it cannot move a feature, and this script
is what says so rather than assuming it.

ONE FEATURE IS KNOWN TO MOVE, AND IT IS WHY THIS SCRIPT EXISTS
--------------------------------------------------------------
`State.widget` is itself an explicitly declared widget-returning getter, so `spm analyze`
counts every `widget.` access as a helper reference. Removing them moves
`helperReferenceCount` on any role that had one inside the measured region -- and unequally
between the two endpoints of a pair, so the contrast delta moves too.

`helperReferenceCount` is one of `extract_features.DELTA_FEATURE_KEYS` and it is one of the
eight features the arm-2 model uses. (The features dropped from the 12 are
`usesLayoutDependentBuilder` and three that rarely move in arm 2, not this one.) So arm-2 `d_helperReferenceCount` is
measured under a convention arm 1 was not. That is a real cross-arm inconsistency; this script
is what QUANTIFIES it so the threats to validity can state a number instead of an assurance.

    python3 -m scripts.widget_field_fidelity --source probe_v2/samples_v2 --groups new_samples

Exit status is 0 when `helperReferenceCount` is the ONLY feature that moved -- expected, and
written to the report -- and nonzero the moment any other feature does, because that is a
defect in the lift rather than a cost to be written up. `--strict` restores the older,
stronger contract: nonzero on any movement at all, which is what `--lift-mode constructor`
should always satisfy.

The report goes to `<groups>/lift_fidelity.json`: roles compared, roles moved, the per-feature
tally, the per-pair delta changes, and the roles that got a vector ONLY after the lift -- the
last being the defect the lift was written for, since a role whose fixture constructor the
extractor refused to emit could not be mounted at all.

WHY IT BUILDS BOTH TREES ITSELF, rather than analysing `new_samples` in place: the exported
corpus on disk was built by whichever version of the split last ran, and comparing against it
would measure that as well as the lift. Both sides here come from ONE source tree through ONE
code path, differing only in `--lift-fields`.

The vectors come from `scripts.extract_features.staged_vectors`, not from a second `spm analyze`
call written here. A transplant does not analyse standalone -- it is skipped with compile
errors unless it is staged inside a project where `package:flutter` resolves, and staging it
with its group's fixture is what that function exists to do. Its cache is keyed on
`(role text, fixture digest)`, so the two sides never collide in it.
"""

from __future__ import annotations

import argparse
import collections
import itertools
import json
import logging
import shutil
import sys
import tempfile
from pathlib import Path

from scripts import extract_features, ast_tools, fixture_skeleton

# The features compared are `extract_features.DELTA_FEATURE_KEYS` -- the same set the contrast
# vectors are built from, so this checks exactly what the study reads.
#
# `_sha` is the staged text's own digest and MUST differ: the lift rewrote the file. `_resolved`
# is carried beside the vector rather than in it. Neither is a feature.
SKIP = {"_sha", "_resolved"}

# The one feature the `state` lift is ALLOWED to move, and the whole reason this script reports
# rather than refuses. It is not a tolerance: a move here is written to the report, counted, and
# has to reach the write-up. Every other feature is a defect -- the lift touches identifier
# spelling and nothing else, so nothing else has a mechanism by which to move.
EXPECTED_MOVERS = {"helperReferenceCount"}

REPORT_NAME = "lift_fidelity.json"


def build_side(roles: dict[str, list[Path]], work: Path, *, lift: bool,
               mode: str = "constructor"):
    """The staged text and fixture for every role, built one way or the other.

    Returns what `extract_features.staged_vectors` takes: `gid -> [(stem, text)]` plus the
    group's fixture path. The fixture is REGENERATED per side rather than shared, because the
    lift adds bindings to it -- a side carrying the other's fixture would not compile, and a
    file that does not compile is skipped rather than reported as moved, which is precisely
    how a fidelity check passes without checking anything.
    """
    staged: dict[str, list[tuple[str, str]]] = {}
    fixtures: dict[str, Path] = {}
    for gid, paths in sorted(roles.items()):
        rows = ast_tools.fixture(paths, lift_fields=lift, lift_mode=mode)
        by_file = {p.name: rows[str(p.resolve())] for p in paths}
        staged[gid] = [(p.stem, by_file[p.name]["text"]) for p in paths]
        fixture = fixture_skeleton.build(by_file)
        if fixture is not None:
            group_dir = work / gid
            group_dir.mkdir(parents=True, exist_ok=True)
            path = group_dir / "dependencies.dart"
            path.write_text(fixture.text, encoding="utf-8")
            fixtures[gid] = path
    return staged, fixtures


def _pair_deltas(before: dict, after: dict) -> dict:
    """How many within-group pairs have a feature DELTA that the lift changed.

    The role-level tally under-reports and over-reports at once. A feature that moves by the
    same amount at both endpoints cancels in the difference and the contrast is untouched; a
    feature that moves at one endpoint only changes the delta the model reads. The study
    differences all-pairwise within scope (`screen/contrasts.py`), so this is the quantity the
    write-up owes a number for -- not the role count.

    Pairs are unordered and formed only where BOTH endpoints have a vector on both sides: a
    role the lift recovered has no `before` to difference against, and counting it here would
    mix a recovery in with a movement.
    """
    by_group: dict[str, list[str]] = collections.defaultdict(list)
    for gid, stem in before:
        if (gid, stem) in after:
            by_group[gid].append(stem)

    total = moved = 0
    per_feature: dict[str, int] = collections.Counter()
    for gid, stems in by_group.items():
        for a, b in itertools.combinations(sorted(stems), 2):
            total += 1
            changed = set()
            for feature in extract_features.DELTA_FEATURE_KEYS:
                was = _delta(before, gid, a, b, feature)
                now = _delta(after, gid, a, b, feature)
                if was is not None and now is not None and was != now:
                    changed.add(feature)
            if changed:
                moved += 1
                per_feature.update(changed)
    return {"total": total, "moved": moved,
            "by_feature": dict(sorted(per_feature.items()))}


def _delta(vectors: dict, gid: str, a: str, b: str, feature: str):
    """`feature(a) - feature(b)`, or None when either endpoint does not carry it."""
    left = vectors[(gid, a)].get(feature)
    right = vectors[(gid, b)].get(feature)
    if not isinstance(left, (int, float)) or not isinstance(right, (int, float)):
        return None
    return left - right


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--source", type=Path, required=True,
                    help="the mine the roles are read from")
    ap.add_argument("--groups", type=Path, required=True,
                    help="an exported corpus, read only for WHICH group/role names to test")
    ap.add_argument("--project-root", type=Path, default=extract_features.PROJECT_ROOT,
                    help="the package the staged roles are analysed inside")
    ap.add_argument("--lift-mode", default="state",
                    choices=("constructor", "state"),
                    help="which lift to check; the default is the corpus shape. "
                         "See dart_tools/lib/src/widget_fields.dart.")
    ap.add_argument("--strict", action="store_true",
                    help="refuse ANY movement, including helperReferenceCount. This is the "
                         "contract `--lift-mode constructor` must always satisfy.")
    ap.add_argument("--report", type=Path, default=None,
                    help=f"where the JSON report goes (default: <groups>/{REPORT_NAME})")
    ap.add_argument("--keep", type=Path, default=None,
                    help="keep the generated fixtures here instead of a temporary directory")
    args = ap.parse_args(argv)

    logging.basicConfig(level=logging.INFO, format="%(message)s")

    roles: dict[str, list[Path]] = {}
    for group_dir in sorted(p for p in args.groups.iterdir() if p.is_dir()):
        found = [args.source / group_dir.name / f.name
                 for f in sorted(group_dir.glob("rev_*.dart"))]
        present = [p for p in found if p.is_file()]
        if present:
            roles[group_dir.name] = present
    total = sum(len(v) for v in roles.values())
    print(f"{total} roles across {len(roles)} groups", flush=True)

    work = Path(args.keep) if args.keep else Path(tempfile.mkdtemp(prefix="lift-fidelity-"))
    work.mkdir(parents=True, exist_ok=True)
    try:
        sides = {}
        for name, lift in (("before", False), ("after", True)):
            print(f"\n== {name} (lift_fields={lift}, mode={args.lift_mode})",
                  flush=True)
            staged, fixtures = build_side(roles, work / name, lift=lift,
                                          mode=args.lift_mode)
            vectors, funnel = extract_features.staged_vectors(
                staged, fixtures,
                project_root=args.project_root, store=work / name)
            print(f"  {funnel}")
            sides[name] = vectors

        before, after = sides["before"], sides["after"]
        moved: dict[tuple[str, str], dict] = {}
        for key, row in before.items():
            other = after.get(key)
            if other is None:
                moved[key] = {"(whole vector)": ("analysed", "no vector")}
                continue
            diff = {f: (v, other.get(f)) for f, v in row.items()
                    if f not in SKIP and other.get(f) != v}
            if diff:
                moved[key] = diff
        recovered = set(after) - set(before)

        by_feature: dict[str, int] = collections.Counter()
        for diff in moved.values():
            # `.keys()`, not the dict: `Counter.update` on a mapping ADDS ITS VALUES as
            # counts, and these values are `(before, after)` tuples.
            by_feature.update(diff.keys())
        unexpected = sorted(set(by_feature) - EXPECTED_MOVERS - {"(whole vector)"})

        report = {
            "lift_mode": args.lift_mode,
            "roles_compared": len(before),
            "roles_moved": len(moved),
            "groups": len(roles),
            "by_feature": dict(sorted(by_feature.items())),
            "expected_movers": sorted(EXPECTED_MOVERS),
            "unexpected_movers": unexpected,
            "recovered_only_after_lift": sorted(f"{g}/{s_}" for g, s_ in recovered),
            "moved": {f"{g}/{s_}": {f: {"before": w, "after": n}
                                    for f, (w, n) in sorted(d.items())}
                      for (g, s_), d in sorted(moved.items())},
            "pair_deltas_moved": _pair_deltas(before, after),
        }
        report_path = args.report or (args.groups / REPORT_NAME)
        report_path.write_text(json.dumps(report, indent=2, sort_keys=False) + "\n",
                               encoding="utf-8")

        print(f"\ncompared {len(before)} vectors")
        if recovered:
            # The defect the lift was written for: the extractor emitted no fixture
            # constructor at all for these, so the role could not be mounted.
            print(f"  {len(recovered)} role(s) got a vector only AFTER the lift: "
                  f"{sorted(f'{g}/{s_}' for g, s_ in recovered)[:10]}")
        print(f"  report -> {report_path}")

        if not moved:
            print("\nNO FEATURE MOVED. The lift is vector-preserving on this corpus.")
            return 0

        print(f"\n{len(moved)} of {len(before)} role(s) moved, by feature:")
        for feature, n in sorted(by_feature.items()):
            flag = "expected" if feature in EXPECTED_MOVERS else "UNEXPECTED"
            print(f"  {feature}: {n} role(s)  [{flag}]")
        pairs = report["pair_deltas_moved"]
        print(f"{pairs['moved']} of {pairs['total']} within-group pairs change a delta")

        if unexpected:
            print(f"\nREFUSED: {', '.join(unexpected)} moved. The lift rewrites identifier "
                  f"spelling and nothing else, so nothing here has a mechanism to move. "
                  f"This is a defect in the lift, not a cost to write up.")
            for (gid, stem), diff in sorted(moved.items()):
                hits = {f: v for f, v in diff.items() if f in unexpected}
                if not hits:
                    continue
                print(f"  {gid}/{stem}")
                for feature, (was, now) in sorted(hits.items()):
                    print(f"      {feature}: {was} -> {now}")
            return 1
        if args.strict:
            print("\nREFUSED under --strict: any movement at all is a failure.")
            return 1
        print(f"\nOnly {', '.join(sorted(EXPECTED_MOVERS))} moved. Expected, and quantified "
              f"above -- this number belongs in the threats to validity, "
              f"never absorbed.")
        return 0
    finally:
        if not args.keep:
            shutil.rmtree(work, ignore_errors=True)


if __name__ == "__main__":
    sys.exit(main())
