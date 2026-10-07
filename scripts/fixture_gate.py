"""Refuse to measure a group whose fixture is not finished.

`fixture_skeleton.py` emits `// TODO: value` for every binding it will not invent, and until
2026-08-27 nothing stopped a group carrying one from reaching the device. An unfilled slot is
not a cosmetic defect: an unassigned `late` throws `LateInitializationError` at mount, and a
`const dynamic x = null` reaching a typed slot renders nothing, so the role either dies or
builds a tree the feature vector does not describe.

This is the hard refusal required by the fixture value-fill protocol, §6.
It is deliberately NOT part of `scripts/mutation/gate.py`: that gate validates a generated
mutation against its base -- frozen fields, content drift, `spm validate` with a directive --
and arm 2's roles are real human commits, which change text and fields by design. The two
gates answer different questions and only this one applies to both arms.

    python -m scripts.fixture_gate --root new_samples
    python -m scripts.fixture_gate --root samples --group 01
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

TODO_MARKER = "// TODO: value"


def fixture_body(text: str) -> str:
    """The fixture below its banner comment.

    The generated HEADER quotes `// TODO: value` once, as documentation, in every file --
    170 times corpus-wide. Counting it as an unfilled slot turns a naive `grep -c` from 282
    into 452. Directives and declarations begin at the first line that is neither blank nor a
    comment, so everything before that is banner.
    """
    lines = text.splitlines()
    for i, line in enumerate(lines):
        stripped = line.strip()
        if not stripped or stripped.startswith("//") or stripped.startswith("/*"):
            continue
        return "\n".join(lines[i:])
    return ""


def unfilled_slots(text: str) -> list[str]:
    """Every real `// TODO: value` in a fixture, in file order.

    Both stamp shapes are caught: `<decl>; // TODO: value` for single-line declarations and a
    standalone `// TODO: value` line preceding a multi-line one (`fixture_skeleton.py:317-319`).
    """
    return [ln.strip() for ln in fixture_body(text).splitlines() if TODO_MARKER in ln]


def check_group(group_dir: Path) -> list[str]:
    """Violations for one group. Empty means the group may be measured."""
    fixture = group_dir / "dependencies.dart"
    if not fixture.exists():
        return []  # a group with no hoisted bindings needs no fixture
    slots = unfilled_slots(fixture.read_text(encoding="utf-8", errors="replace"))
    if not slots:
        return []
    shown = "\n".join(f"      {s}" for s in slots[:5])
    more = f"\n      ... and {len(slots) - 5} more" if len(slots) > 5 else ""
    return [f"{len(slots)} unfilled fixture slot(s) in {fixture}:\n{shown}{more}"]


def binding_name(slot: str) -> str | None:
    """The binding a stamped line declares, or None for the standalone-marker form.

    `<decl>; // TODO: value` names it; a bare `// TODO: value` line precedes a multi-line
    declaration this function cannot see, and guessing there would be worse than abstaining.
    """
    decl = slot.split(TODO_MARKER)[0].strip()
    if not decl.endswith(";"):
        return None
    parts = decl.rstrip(";").split()
    return parts[-1] if parts else None


def unexplained(root: Path, group: str | None = None) -> dict[str, list[str]]:
    """Unfilled slots the values table does NOT account for, per group.

    THE DIRECTION MATTERS, and it is the opposite of R16's. R16 reads the values table and
    never the fixture, because a fixture-based test would fire on every group the fill has not
    visited yet and the exclusion would be its own cause (see `config/README.md`). This asks
    the other question -- does the table EXPLAIN every stamp still on disk -- and an entry
    with `origin: "none"` is an explanation: the fill looked and gave up, which is the
    authoring worklist.

    A slot with no entry at all means the fill has not run since this group joined the corpus.
    That is what happened to `2039` and `2386`: they carried four `late bool` and a
    `late TabController` that the table had never seen, so R16 could not name them, they
    shipped, they were scheduled, and the hard refusal below ABORTED the whole campaign
    instead of skipping them. The gate could say only "unfilled"; it can now say which.

    Read straight from the table rather than through `fixture_values.load()`, because that
    module reaches git on import paths this one has no business on.
    """
    import json

    table_path = Path(__import__("os").environ.get(
        "SPM_FIXTURE_VALUES", "config/fixture_values.json"))
    if not table_path.is_absolute():
        table_path = Path(__file__).resolve().parents[1] / table_path
    try:
        table = json.loads(table_path.read_text())
    except (OSError, ValueError):
        return {}                      # no table: everything is unexplained and nothing is news

    dirs = [root / group] if group else sorted(d for d in root.iterdir() if d.is_dir())
    out: dict[str, list[str]] = {}
    for d in dirs:
        fixture = d / "dependencies.dart"
        if not fixture.is_file():
            continue
        known = (table.get(d.name) or {}).get("bindings") or {}
        for slot in unfilled_slots(fixture.read_text(encoding="utf-8", errors="replace")):
            name = binding_name(slot)
            if name is not None and name not in known:
                out.setdefault(d.name, []).append(name)
    return out


def check_root(root: Path, group: str | None = None) -> dict[str, list[str]]:
    """Violations per group id, for every group that has any."""
    dirs = [root / group] if group else sorted(d for d in root.iterdir() if d.is_dir())
    out = {}
    for d in dirs:
        violations = check_group(d)
        if violations:
            out[d.name] = violations
    return out


def main() -> None:
    parser = argparse.ArgumentParser(description="Refuse groups whose fixtures are unfinished.")
    parser.add_argument("--root", default="new_samples", help="Corpus root (default: new_samples).")
    parser.add_argument("--group", help="Check only this group.")
    args = parser.parse_args()

    root = Path(args.root)
    if not root.is_dir():
        raise SystemExit(f"no such corpus root: {root}")

    failures = check_root(root, args.group)
    gaps = unexplained(root, args.group)
    total = sum(len(v) for v in failures.values())
    checked = 1 if args.group else len([d for d in root.iterdir() if d.is_dir()])

    if not failures:
        print(f"fixture gate: PASS -- {checked} group(s) under {root}, no unfilled slots")
        return

    print(f"fixture gate: REFUSED -- {len(failures)} of {checked} group(s) under {root}")
    for gid in sorted(failures):
        for message in failures[gid]:
            print(f"  [{gid}] {message}")
    if gaps:
        print()
        for gid in sorted(gaps):
            print(f"  [{gid}] {len(gaps[gid])} slot(s) the values table has never seen: "
                  f"{', '.join(gaps[gid])}")
        print("  The fill has not run since these groups joined the corpus, so R16 cannot "
              "name them\n  and the runner schedules them instead of skipping them. Run "
              "`python3 -m scripts.fixture_values\n  --root <root> --eligible-only --apply` "
              "and re-screen.")
    print(f"\n{total} violation(s). No group above may be measured until its fixture is filled.")
    sys.exit(1)


if __name__ == "__main__":
    main()
