"""Compute the maximal-render branch assignment for branch-selecting fixture bindings.

Implements the primary rule of the fixture value-fill protocol, 3.1:
a bool, enum or nullability binding that gates a conditional takes the value selecting the arm
that renders MORE non-const widgets.

The rule is EDIT-BLIND by construction and that is the property that makes it defensible: this
module reads the two arms of a conditional and never reads the diff between a pair's endpoints.

Arms are read from the AST, via `scripts/ast_tools.branches` and `dart_tools/lib/src/branches.dart`
-- not from a regex over raw source, which is what this module used until 2026-08-31 and which
`screen_samples` had already retired for the same reasons. That scanner counted `TextStyle`,
`EdgeInsets` and `Color` as widgets, saw only `if` statements (never a ternary or a collection `if`
element), and could not tell a lazy `itemBuilder` from a materialised subtree.
A value chosen with knowledge of the edit would be a value chosen to produce an effect, which
R14 forbids -- R14 drops such a pair instead.

Anything the rule cannot decide on static grounds -- a non-constant condition, an arm whose
widget count cannot be established, a binding gating nothing -- is reported `undecidable` and
is EXCLUDED AND COUNTED, never guessed.

    python -m scripts.maximal_branch --root new_samples --eligible-only
    python -m scripts.maximal_branch --root new_samples --eligible-only --apply
    python -m scripts.maximal_branch --root new_samples --init      # first run only

Both invocations WRITE `config/maximal_branch.json`; only `--apply` touches a fixture.

A missing table raises, and `--init` is the one way past it. The refusal is about RE-RUNNING
against a corpus whose fixtures already sit on their overridden arm: `current` is then the
post-override value, `analyse()` cannot see what it replaced, and `merge_table`'s
`value_at_head` can recover it only while the pre-override fixture is still in HEAD. Delete
the table in that state and the history is gone.

From NOTHING the table is fully derivable, and `screen_samples --full --from-nothing` relies
on it: `analyse()` re-reads every field off the AST, and `--apply` records `replaced_value`
from the freshly generated fixture, which is the pre-override value by construction. The one
field a rebuild cannot recreate is `applied`, the date an override was first written -- which
is why `table_digest()` exists and excludes it.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
from datetime import datetime, timezone
from pathlib import Path

from . import ast_tools, fixture_skeleton
from .fixture_values import anchor_sha, table_path
from . import jsonio
from .paths import PROJECT_ROOT as ROOT


# Overridable for the same reason `fixture_values.VALUES_PATH` is, and it must move with it:
# both are generated tables the corpus is a pure function of, `--from-nothing` tears down the
# pair together (`screen_samples.py`, `tables = [VALUES_PATH, TABLE_PATH]`), and isolating one
# while a second corpus rewrites the other is worse than isolating neither.
TABLE_PATH = table_path("SPM_MAXIMAL_BRANCH", ROOT / "config" / "maximal_branch.json")


def load() -> dict:
    """The committed override table, or `{}` when it has not been built yet.

    The one way to read this file, so an `SPM_MAXIMAL_BRANCH` override cannot move this
    module's reader while another module re-derives the default path and reads the other.
    """
    return jsonio.read_json(TABLE_PATH, {}) or {}

# The one regex left, and it reads the GENERATED fixture, never a transplant.
# `fixture_skeleton` writes `dependencies.dart` one declaration per line in a fixed shape, and
# `fixture_values` parses it with the same construction; changing only this copy would leave
# the two modules disagreeing about what a binding is. Everything that reads TRANSPLANT source
# now goes through `dart_tools` -- see the module docstring.
BINDING = re.compile(
    r"^(?:late\s+)?(?P<type>bool\??|[A-Z]\w*\??)\s+(?P<name>\w+)\s*=\s*(?P<val>[^;]+);")


def decide(cond: str, field: str, then_n: int, else_n: int, decl_type: str):
    """Which literal for the binding selects the larger arm, or None if undecidable."""
    take_then = then_n >= else_n
    c = cond.strip()
    if re.fullmatch(rf"!\s*{re.escape(field)}", c):
        return ("false" if take_then else "true"), "negated bool"
    if re.fullmatch(re.escape(field), c):
        return ("true" if take_then else "false"), "bare bool"
    m = re.fullmatch(rf"{re.escape(field)}\s*!=\s*null", c)
    if m:
        return ("NONNULL" if take_then else "null"), "null check"
    m = re.fullmatch(rf"{re.escape(field)}\s*==\s*null", c)
    if m:
        return ("null" if take_then else "NONNULL"), "null check"
    m = re.fullmatch(rf"{re.escape(field)}\s*==\s*([\w.]+)", c)
    if m and take_then:
        return m.group(1), "enum equality"
    return None, f"non-constant or compound condition: {c[:60]}"


def _ordering_is_safe(then: dict, other: dict) -> bool:
    """Whether the widget ordering survives every unclassifiable instantiation.

    `unknown` is a name `dart_tools` could not place: a user-defined type, which cannot be
    classified without resolving a transplant that does not resolve. Treating it as a widget
    would inflate an arm and treating it as nothing would deflate one, so neither is done --
    the ordering is accepted only when the winner's KNOWN widget count already covers the
    loser's maximum possible count. Every override in the corpus today is `n` against `0`,
    which is safe under any assignment of the unknowns.
    """
    win, lose = (then, other) if then["widgets"] >= other["widgets"] else (other, then)
    return win["widgets"] >= lose["widgets"] + lose["unknown"]


def analyse(group_dir: Path, rows_by_path: dict[str, dict]) -> list[dict]:
    """Every branch-selecting binding in one group, with the arm it should render.

    `rows_by_path` is `ast_tools.branches` output for this group's transplants: one row per
    file carrying every conditional -- `if`, ternary and collection `if` element alike -- with
    per-arm counts, and the plain identifier assignments that say which State field a fixture
    binding was mounted into.
    """
    fixture = group_dir / "dependencies.dart"
    if not fixture.exists():
        return []
    ftext = fixture.read_text(encoding="utf-8", errors="replace")

    group_rows = {p: r for p, r in rows_by_path.items()
                  if Path(p).parent == group_dir.resolve()}

    # `showAllApps = fixtureShowAllApps;` -- which field the binding reaches the build through.
    # Recovered from the AST rather than from `(\w+)\s*=\s*name\s*;` over raw source, which
    # matched inside comments and string literals.
    mounted: dict[str, set[str]] = {}
    for row in group_rows.values():
        for a in row.get("assignments", ()):
            mounted.setdefault(a["value"], set()).add(a["target"])

    rows = []
    for line in ftext.splitlines():
        s = line.strip()
        if "operator" in s or "=>" in s or s.startswith("//"):
            continue
        m = BINDING.match(s)
        if not m:
            continue
        t, name, val = m.group("type"), m.group("name"), m.group("val").strip()
        is_bool = t.startswith("bool")
        is_enum = bool(re.fullmatch(r"[A-Z]\w*\.\w+", val))
        if not (is_bool or is_enum):
            continue

        fields = mounted.get(name, set()) | {name}
        best = None
        for row in group_rows.values():
            for b in row.get("branches", ()):
                # Identifier-level, not substring: `showAllAppsToggle` must not answer for
                # `showAllApps`.
                for f in sorted(fields & set(b.get("conditionNames", ()))):
                    then, other = b["then"], b["else"]
                    an, bn = then["widgets"], other["widgets"]
                    # Genuinely empty on both sides: the binding gates a conditional that
                    # instantiates nothing at all, which is the `gates_nothing` case. An arm
                    # holding only UNCLASSIFIABLE instantiations is not that -- it renders
                    # something this pass cannot count -- and falls through to `undecidable`
                    # below. The old scanner could not tell the two apart, because it counted
                    # any capitalised call as a widget.
                    if not any((an, bn, then["unknown"], other["unknown"])):
                        continue
                    choice, why = decide(b["condition"], f, an, bn, t)
                    # The rule is "the arm that renders MORE". Equal counts mean no arm does,
                    # and `decide`'s `>=` would silently hand the tie to `then`.
                    if an == bn:
                        choice, why = None, "arms render equally; neither renders more"
                    # A lazy builder renders a viewport window sized by the device, not a
                    # number this pass can compute. One `Card(...)` in an `itemBuilder` is one
                    # source widget and N runtime widgets, so an arm carrying one cannot be
                    # ranked against an eager arm on source counts. Excluded and counted,
                    # never guessed -- the same rule this module already applies to a
                    # compound condition.
                    elif then["hasLazyBuilder"] != other["hasLazyBuilder"]:
                        choice, why = None, ("lazy builder in one arm only: source widget "
                                             "counts do not rank a viewport against a "
                                             "materialised subtree")
                    elif choice is not None and not _ordering_is_safe(then, other):
                        choice, why = None, (
                            f"unclassifiable instantiation could change the ordering "
                            f"({an}+{then['unknown']} vs {bn}+{other['unknown']})")
                    cand = {"binding": name, "type": t, "current": val, "field": f,
                            "kind": b["kind"],
                            "condition": b["condition"][:80],
                            "then_widgets": an, "else_widgets": bn,
                            "then_value_objects": then["valueObjects"],
                            "else_value_objects": other["valueObjects"],
                            "then_unknown": then["unknown"],
                            "else_unknown": other["unknown"],
                            "then_const_widgets": then["constWidgets"],
                            "else_const_widgets": other["constWidgets"],
                            "then_lazy": then["hasLazyBuilder"],
                            "else_lazy": other["hasLazyBuilder"],
                            "verdict": "decidable" if choice else "undecidable",
                            "maximal_value": choice, "rule": why,
                            "spread": abs(an - bn)}
                    if best is None or cand["spread"] > best["spread"]:
                        best = cand
        if best:
            rows.append(best)
        else:
            rows.append({"binding": name, "type": t, "current": val,
                         "verdict": "gates_nothing", "maximal_value": None,
                         "rule": "binding gates no conditional that renders widgets"})
    return rows



def _rel(path: Path) -> str:
    """`path` relative to the container, or absolute when it is outside it. Never raises."""
    try:
        return str(path.relative_to(ROOT))
    except ValueError:
        return str(path)


def value_at_head(root: Path, gid: str, binding: str) -> str | None:
    """The binding's value in the last commit, or None if unavailable.

    Used only to BACKFILL `replaced_value` for overrides applied before this tool recorded
    them. Once an override is recorded at apply time the git lookup is never consulted again,
    so committing the fixtures does not erase the history.
    """
    rel = f"{root.name}/{gid}/dependencies.dart"
    try:
        r = subprocess.run(["git", "show", f"HEAD:{rel}"], cwd=ROOT,
                           capture_output=True, text=True, timeout=30)
    except Exception:
        return None
    if r.returncode != 0:
        return None
    m = re.search(rf"^\s*(?:late\s+)?[\w<>?]+\s+{re.escape(binding)}\s*=\s*([^;]+);",
                  r.stdout, re.M)
    return m.group(1).strip() if m else None


def merge_table(fresh: dict, root: Path, allow_missing: bool = False) -> dict:
    """Carry override history forward across re-runs.

    `analyse()` reads the fixture as it stands, so once an override is applied the fresh row's
    `current` IS the maximal value and the replaced value is no longer visible in the corpus.
    Writing the fresh table straight out would therefore erase exactly the provenance the
    ratified protocol promises -- the record states that an override is recorded together with
    the value it replaced, and a table that forgets it cannot support that claim.

    Precedence: a `replaced_value` already on disk wins; otherwise, if the fixture now differs
    from the last commit, the committed value is adopted as the backfill.

    A MISSING table raises unless `allow_missing`. This file is not reproducible the way
    `fixture_values.json` is: `--apply` records `replaced_value` at the only moment it is still
    knowable without git, and `value_at_head` can recover it only while the pre-override fixture
    is still in HEAD. An absent table and an empty one mean opposite things and must not read
    the same.
    """
    if not TABLE_PATH.is_file() and not allow_missing:
        raise FileNotFoundError(
            f"override table missing: {TABLE_PATH}. Against an ALREADY-OVERRIDDEN corpus it "
            f"carries `replaced_value` / `applied` history that nothing else holds -- "
            f"`current` is the post-override value and `value_at_head` can rebuild what it "
            f"replaced only while the pre-override fixture is still in HEAD. Restore it with "
            f"`git checkout -- {_rel(TABLE_PATH)}`, or pass --init if this really "
            f"is a first run, or a rebuild from nothing, and there is no history to lose.")
    prior = {}
    if TABLE_PATH.is_file():
        for gid, rows in load().items():
            for r in rows:
                prior[(gid, r["binding"])] = r

    for gid, rows in fresh.items():
        for r in rows:
            was = prior.get((gid, r["binding"]), {})
            replaced = was.get("replaced_value")
            applied = was.get("applied")
            # Backfill only where an override PLAUSIBLY happened -- the fixture already sits on
            # the maximal arm. Without this the direction inverts on a rebuilt corpus: `current`
            # is then the pre-override value and HEAD holds the post-override one, so the old
            # test (`head != current`) recorded the value the override WROTE as the value it
            # replaced. An undecidable row has `maximal_value is None` and never matches, which
            # is what keeps a pending revert from being backfilled as an applied override.
            if replaced is None and r.get("maximal_value") is not None \
                    and r["current"] == r["maximal_value"]:
                head = value_at_head(root, gid, r["binding"])
                if head is not None and head != r["current"]:
                    replaced, applied = head, was.get("applied") or "backfilled-from-git"
            r["replaced_value"] = replaced
            r["applied"] = applied
            r["overridden"] = replaced is not None
    return fresh


def table_digest(table: dict) -> str:
    """The override table's DERIVED content, hashed -- `applied` excluded.

    Every other field is a pure function of the mine plus `config/fixture_policy.json`: the
    arms and the verdict come off the AST, `current` off the generated fixture, and
    `replaced_value` off the fixture as it stood immediately before `--apply` wrote to it. On
    a rebuild from nothing all of them come back identical. `applied` is the date the override
    was FIRST written, which a rebuild necessarily restamps with its own, so hashing it would
    make an otherwise byte-faithful rebuild read as a difference.

    This is what `screen_samples --from-nothing` compares the regenerated table against, so
    that the reproducibility claim is a gate rather than an eyeballed diff.
    """
    stripped = {gid: [{k: v for k, v in sorted(row.items()) if k != "applied"}
                      for row in rows]
                for gid, rows in sorted((table or {}).items())}
    return hashlib.sha256(
        json.dumps(stripped, sort_keys=True).encode("utf-8")).hexdigest()[:16]


def write_provenance(root: Path, table: dict) -> int:
    """Fold every override into the group's `fixture_provenance.json`.

    The protocol record promises `rule: maximal_branch` alongside the value it replaced, in the
    per-group provenance -- not only in this tool's own table. Written here so the two agree.
    """
    written = 0
    for gid, rows in table.items():
        overrides = {r["binding"]: {
            "rule": "maximal_branch",
            "expr": r["current"],
            "origin": "default",
            "replaced_value": r["replaced_value"],
            "relocated_value": r["replaced_value"],
            "applied": r["applied"],
            "condition": r.get("condition"),
            "then_widgets": r.get("then_widgets"),
            "else_widgets": r.get("else_widgets"),
        } for r in rows if r.get("overridden")}
        if not overrides:
            continue
        path = root / gid / fixture_skeleton.PROVENANCE_NAME
        doc = jsonio.read_json(path, {}) or {}
        # A group whose bindings all carried relocated values has no value-hierarchy provenance
        # file yet; give the one created here the same anchor the rest of the corpus records,
        # so every provenance file names the commit its group is pinned to.
        if not doc.get("anchor"):
            doc["anchor"] = anchor_sha(root / gid)
        doc.setdefault("bindings", {}).update(overrides)
        path.write_text(json.dumps(doc, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        written += len(overrides)
    return written


def main() -> None:
    ap = argparse.ArgumentParser(description="Maximal-render branch assignment.")
    ap.add_argument("--root", default="new_samples")
    ap.add_argument("--eligible-only", action="store_true")
    ap.add_argument("--apply", action="store_true")
    ap.add_argument("--init", action="store_true",
                    help="Accept a missing override table as a first run. Only for a corpus "
                         "rebuilt from scratch: the table holds `replaced_value` history that "
                         "nothing else carries once the pre-override fixture leaves HEAD.")
    args = ap.parse_args()
    run(ROOT / args.root, eligible_only=args.eligible_only, apply=args.apply, init=args.init)


def run(root: Path, *, eligible_only: bool = False, apply: bool = False,
        init: bool = False) -> dict:
    """The branch-override pass, callable without argparse. `main()` and
    `screen_samples --full` share it.

    Returns the counts it prints, so a caller that is one phase of a longer run can report
    them in its own summary rather than only on stdout.
    """
    # Refused on a corpus pruned to measured endpoints: the override is decided over the
    # roles this globs off disk. See `fixture_skeleton.PRUNED_NAME`.
    fixture_skeleton.refuse_if_pruned(root, "maximal_branch")
    groups = sorted(d.name for d in root.iterdir() if d.is_dir())
    if eligible_only:
        ex = jsonio.require_json(root / "exclusions.json", "maximal_branch --eligible-only")
        groups = sorted({p["group"] for p in ex["pairs"] if p["verdict"] == "eligible"})

    # One `dart_tools` batch for every transplant this run reads. A `dart` spawn costs more
    # to start than to run, which is why `screen` primes in bulk too.
    transplants = [q for g in groups for q in sorted((root / g).glob("rev_*.dart"))]
    rows_by_path = ast_tools.branches(transplants) if transplants else {}

    table, counts = {}, {"decidable": 0, "undecidable": 0, "gates_nothing": 0}
    for g in groups:
        found = analyse(root / g, rows_by_path)
        rows = [r for r in found if r["verdict"] != "gates_nothing"]
        counts["gates_nothing"] += sum(1 for r in found if r["verdict"] == "gates_nothing")
        if rows:
            table[g] = rows
            for r in rows:
                counts[r["verdict"]] += 1

    table = merge_table(table, root, allow_missing=init)
    TABLE_PATH.write_text(json.dumps(table, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    # Said out loud: a run without --apply still WRITES the table, because carrying the override
    # history forward is what `merge_table` is for. Only the fixtures are left alone.
    #
    # The mode is read off `apply` rather than asserted. Until 2026-09-08 this line said "no
    # --apply: fixtures untouched" UNCONDITIONALLY, including under `screen_samples --full`,
    # which has always passed `apply=True` -- so a full run announced that it had changed
    # nothing while it was overriding fixtures, and the only way to find out which had happened
    # was to reach `applied: N` at the bottom of the phase.
    print(f"table written                        : {_rel(TABLE_PATH)} "
          + ("(--apply: fixtures overridden below)" if apply
             else "(no --apply: fixtures untouched)"))
    overridden = sum(1 for rows in table.values() for r in rows if r.get("overridden"))
    print(f"groups with a branch-gating binding : {len(table)}")
    print(f"  overridden (history preserved)     : {overridden}")
    print(f"  decidable                          : {counts['decidable']}")
    print(f"  undecidable (excluded and counted) : {counts['undecidable']}")
    print(f"  gate no widget-rendering branch    : {counts['gates_nothing']}")
    for g in sorted(table):
        for r in table[g]:
            pending = (r["maximal_value"] not in (None, r["current"]))
            mark = "PENDING" if pending else ("OVERRODE " + str(r["replaced_value"])
                                              if r.get("overridden") else "")
            print(f"  [{g}] {r['binding']:<24} {r['current']:<22} -> "
                  f"{str(r['maximal_value']):<10} then={r.get('then_widgets')} "
                  f"else={r.get('else_widgets')} {mark:<16} ({r['rule'][:34]})")

    changed = 0
    if apply:
        # AUTHORED FIXTURES ARE NOT OURS TO TOUCH -- the rule `fixture_values --apply` follows,
        # for the same reason: `place()` protects an edited fixture by hash, and a tool that
        # rewrites one behind that check makes the protection decorative. This loop is the
        # more dangerous of the two. It substitutes on the value it read FROM the fixture, so
        # a branch-gating bool a human set by hand IS `current` -- the regex matches, and the
        # override lands on top of the edit with the hand-set value recorded as
        # `replaced_value`, which is provenance for something nobody did.
        # No index at all means no export has run and nothing can be classified, so keep the
        # historical behaviour there and treat every group as this pipeline's own.
        index_path = root / fixture_skeleton.INDEX_NAME
        index = fixture_skeleton.load_index(root) if index_path.is_file() else None
        hands_off = set() if index is None else {
            g for g in table
            if (root / g / "dependencies.dart").is_file()
            and not fixture_skeleton.is_generated(root, g, index)}
        if hands_off:
            print(f"authored, skipped: {len(hands_off)} group(s) edited by hand "
                  f"({', '.join(sorted(hands_off)[:10])}); their fixture and provenance "
                  f"are left exactly as they are")
        stamp = datetime.now(timezone.utc).date().isoformat()
        for g, rows in table.items():
            if g in hands_off:
                continue
            f = root / g / "dependencies.dart"
            text = f.read_text(encoding="utf-8", errors="replace")
            for r in rows:
                v = r["maximal_value"]
                if r["verdict"] != "decidable" or v in (None, "NONNULL", r["current"]):
                    continue
                new = re.sub(rf"^(\s*(?:late\s+)?[\w<>?]+\s+{re.escape(r['binding'])}\s*=\s*)"
                             rf"{re.escape(r['current'])}\s*;",
                             rf"\g<1>{v};", text, count=1, flags=re.M)
                if new != text:
                    # Record BEFORE overwriting `current`: this is the only moment the replaced
                    # value is still knowable without going to git.
                    r["replaced_value"] = r["current"]
                    r["applied"] = stamp
                    r["overridden"] = True
                    r["current"] = v
                    text, changed = new, changed + 1
            f.write_text(text, encoding="utf-8")
        TABLE_PATH.write_text(json.dumps(table, indent=2, sort_keys=True) + "\n",
                              encoding="utf-8")
        n = write_provenance(root, table)
        print(f"applied: {changed} binding(s) set to their maximal-render arm")
        print(f"provenance: {n} override(s) recorded in fixture_provenance.json")
    return {"groups": len(table), "overridden": overridden, "applied": changed, **counts}


if __name__ == "__main__":
    main()
