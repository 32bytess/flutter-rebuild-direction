"""One fill-ready `dependencies.dart` per group, unioned from its roles' splits.

WHY THIS EXISTS
---------------
A mined transplant does not run on its own, and what it is missing moved with spm 0.7.0.

Up to 0.6.0 it was missing values outright: `late` seeds nothing assigned, stand-in bodies
that threw, stand-in constants at `null`. 0.7.0 reverses the emitter's preference for
throwing over inventing. It drops `initState`/`didChangeDependencies` as members `build`
cannot reach and RELOCATES what they seeded into a top-level fixture block -- `int _limit =
20` in the State becomes `late int _limit`, `_limit = fixtureLimit` in the generated
`initState`, and `int fixtureLimit = 20` at the top of the file. The value is relocated,
never replaced: a list seeded with twenty rows still builds twenty.

So three things now need hoisting rather than one, and only one of them needs a value:

  * LIFTED BINDINGS -- the 0.7.0 fixture block, which is the whole of a scope's initial
    state in one region. Most carry a relocated value and are copied verbatim. Where the
    binding came from the application and no value existed to move, the block gets an empty
    collection or a `null`, and THAT is a decision, because how many elements go in one is
    tree size and tree size is the dependent variable.
  * SEEDS -- what is left of the old shape. Where no value of a binding's type could be
    built, 0.7.0 keeps the unassigned `late` form and reports the name in
    `unseededBindings`. 349 of these survive in the current mine, against 2,835 lifted
    bindings.
  * STAND-INS -- unchanged, both blocks, bodies still throwing and constants still `null`.

Arm 1 did all of this by hand: 66 `samples/<NN>/dependencies.dart`, one per group, shared by
`base.dart` and all 8 mutations. This module reproduces the shape mechanically. What it does
NOT do is supply a value -- a generated value that changes tree size manufactures the very
effect the study measures. It moves declarations and leaves `// TODO: value`.

0.7.0 does NOT make the hoist redundant, and it is worth being precise about why, because
the fixture block was built for the same purpose. The block is per FILE. Two revisions of one
scope get one each, and where the edit touched the scope's fields they differ -- which is
exactly when the pair is least able to afford it. Hoisting makes one fixture serve the whole
group, so symmetry is structural rather than coincidental, and a genuine disagreement between
two revisions surfaces as a clash instead of as two files quietly mounting from different
initial state.

ONE FILE PER GROUP, AND WHY THAT IS THE POINT
---------------------------------------------
The v2 pilot gate asks whether stubbing is symmetric across a pair. A single fixture shared
by every role in the group makes that structural rather than checkable: a fixture held
constant across a pair can shift the level and cannot produce the direction. So the union is
an invariant, not a convenience, and where two roles cannot share one the ROLE is dropped --
never the fixture split in two.

THE UNION, AND WHAT COUNTS AS A CLASH
-------------------------------------
Roles are merged in filename order, with runs of whitespace collapsed so that formatting
alone never counts as a difference.

A stand-in is RECONSTRUCTED from the call sites the role reaches, so two roles routinely
disagree about a type without contradicting each other: one revision touches
`AsyncValue.requireValue` and its sibling does not, one reaches a `const` constructor and the
other the unnamed one. Merged verbatim that is a clash in 239 of 245 cases on the current
corpus, which would be most of the corpus thrown away for nothing. So a class, mixin or
extension is merged MEMBER BY MEMBER: same header, union of members, and where the same
member arrives in two shapes the longer one wins -- every stand-in body throws, so the longer
signature is the one that satisfies both call sites.

What remains a clash is a header that differs -- `AsyncValue<T>` against
`AsyncValue<ValueT>`, where members naming the type parameter cannot be pooled -- or two
irreconcilable declarations of one name, `const dynamic markdownProvider = null;` against
`late dynamic markdownProvider;`. A role that contradicts the registry that way is dropped
whole and reported: a partial merge would leave the fixture describing a role that is no
longer in the group.

Imports are unioned rather than compared. A `part` has no imports of its own -- it sees the
library's -- so a declaration hoisted out of a role that imports `dart:io` has to compile
inside a sibling that does not. Every role therefore gets the group's whole import set, and
the `unused_import` that follows for some of them is what arm 1's own
`// ignore_for_file: unused_import, unused_element` header was for.

THE TRAP: THE SPLIT MOVES ERRORS OUT OF SPM'S WAY
-------------------------------------------------
`spm analyze` skips any scanned file carrying an error-severity diagnostic, because
unresolved types make every widget classify as a value object. Diagnostics inside a `part`
are reported against the PART, not against the library file -- so hoisting a broken stand-in
into `dependencies.dart` leaves `generated_widget.dart` clean and the row gets emitted.

Measured on the first 35 exported groups: `spm analyze` kept 12 rows before the split and 41
after it, from the same 78 transplants. That is not 29 transplants repaired. It is 29 that
now slip past a gate built to stop exactly them.

So a row is only trustworthy when BOTH files analyse clean, and that has to be checked on the
staged pair with `dart analyze` -- never inferred from `spm analyze` having produced a row.
The measurement campaign takes its roles from that check, not from this module's output.

REGENERABLE UNTIL TOUCHED
-------------------------
The emitted file carries a sentinel and its hash is recorded in `<dest>/.fixture_index.json`.
A file whose hash still matches what was recorded is this module's own output and is
regenerated freely. A file whose hash differs has been edited -- that is the fixture work
itself -- and is never overwritten. This is what lets the mine keep running, and the screen
keep re-running, while values are being filled in.
"""

from __future__ import annotations

import hashlib
import json
import re
from dataclasses import dataclass, field
from pathlib import Path

SENTINEL = "spm-fixture-v2"
FIXTURE_NAME = "dependencies.dart"
INDEX_NAME = ".fixture_index.json"
# Written per group by `fixture_values --apply` and `maximal_branch --apply`, so it is
# generated like the fixture itself. Named here because `screen.export` has to know not
# to read it as hand-authored work.
PROVENANCE_NAME = "fixture_provenance.json"
# Written once by `screen_samples --prune-to-endpoints`. Its presence says the corpus holds
# ONLY the roles that will be measured, which makes it a one-way door for anything that
# derives a value from the roles on disk rather than from the record: `fixture_values`'
# `anchor_sha()` takes the lowest-ordinal revision PRESENT, and `constructible()` is fed the
# union of every `rev_*.dart` in the group. Both would silently see a narrower corpus and
# could move a stored value -- and therefore `values_version()`, which the screening
# fingerprint folds in. They refuse rather than run; the way back is a rebuild from the mine.
PRUNED_NAME = ".roles_pruned.json"


def pruned_stamp(root: Path) -> dict | None:
    """The prune stamp at `root`, or None if the corpus still holds every screened role."""
    path = Path(root) / PRUNED_NAME
    if not path.is_file():
        return None
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError):
        # A stamp too damaged to read still says the corpus was pruned. Reading it as
        # "not pruned" would reopen the door it exists to close.
        return {}


def refuse_if_pruned(root: Path, tool: str) -> None:
    """Hard-exit when `root` holds only measured endpoints. See `PRUNED_NAME`."""
    stamp = pruned_stamp(root)
    if stamp is None:
        return
    when = stamp.get("pruned_at", "an earlier run")
    raise SystemExit(
        f"{root} was pruned to measured endpoints ({when}) and {tool} decides what it "
        f"writes from the roles it globs off disk, not from the screening record. It would "
        f"see a narrower corpus than the one the stored values and overrides were resolved "
        f"against -- `fixture_values.anchor_sha()` takes the lowest-ordinal revision PRESENT "
        f"and `constructible()` the union of them all -- and could move a value silently.\n"
        f"  Rebuild from the mine before re-running this: see docs/mining-runbook.md. "
        f"`fixture_gate --root {root}` is safe and still reads the measured set."
    )
LIBRARY_LINE = "library generated_widget;"
PART_LINE = "part 'dependencies.dart';"
IGNORE_LINE = "// ignore_for_file: unused_import, unused_element, unused_field"

# Section order in the emitted file, with the banner each gets. The wording of the two
# stand-in banners is `spm isolate`'s own, kept so a reader who has seen a raw transplant
# recognises what was moved.
SECTIONS = (
    ("seed", (
        "// SEEDS -- the values the generated `initState` reads, for which `spm isolate`",
        "// could build none. It declares each of these `late` and leaves it unassigned on",
        "// purpose: a fabricated default would be measured as though it were the value that",
        "// was really there. Assign one below and every role in this group gets it.",
    )),
    ("lifted", (
        "// LIFTED BINDINGS -- the scope's initial state, which `spm isolate` 0.7.0 moves out",
        "// of the application and into a fixture block of its own. Most of these carry the",
        "// value that was really there, relocated rather than invented, and are reproduced",
        "// here verbatim: do not \"tidy\" one, it is a measurement input.",
        "//",
        "// The ones marked TODO are the exception. Where the binding came from the",
        "// application and no value existed to move, the block gets an empty collection or a",
        "// null, and how many elements you put in one IS tree size -- the dependent variable.",
        "// That is a decision, and it is why they are hoisted: filled in once here, the whole",
        "// group mounts from identical values, so a measured difference is attributable to",
        "// the edit rather than to the scaffolding.",
    )),
    ("declaration", (
        "// DECLARATION-ONLY STAND-INS -- repo-local declarations that build no UI, and",
        "// third-party ones the transplant does not inline. Supertypes are mirrored so a",
        "// widget still reads as a widget; everything else is `dynamic`, because none of it",
        "// is measured.",
    )),
    ("unresolved", (
        "// UNRESOLVED-REFERENCE STAND-INS -- reconstructed from the call sites, because the",
        "// symbol lives in a package this file may not import or the source project's own",
        "// dependencies were never installed. Every type here is `dynamic`.",
    )),
)

HEADER = f"""// GENERATED FIXTURE SKELETON -- {SENTINEL}
//
// Declarations lifted out of this group's transplants so that ONE fixture serves every role in
// it. That is the point of the file: the same values mount for both endpoints of every
// contrast, so a measured difference is attributable to the edit and not to the scaffolding.
//
// HOW THE VALUES GOT HERE. They are not authored by hand and not invented by the generator.
// Each one is resolved by a pre-registered hierarchy and the rule that fired is recorded, per
// binding, in this group's `fixture_provenance.json`:
//
//   relocated        the value really was in the application; `spm isolate` moved it here
//                    verbatim. Do not "tidy" one -- it is a measurement input.
//   upstream_literal not relocated, but the repository declares it at this group's anchor
//                    commit; taken verbatim, with `file@sha` recorded.
//   protocol_constant neither of the above; the committed table in `config/fixture_policy.json`.
//                    Collection cardinality is one declared constant, corpus-wide.
//   maximal_branch   a bool/enum/nullability that decides WHICH subtree renders takes the arm
//                    that renders more. This one OVERRIDES a relocated value, and says so.
//
// WHAT REMAINS TRUE REGARDLESS OF WHO OR WHAT FILLS A SLOT:
//
//   * The same values serve every role in the group. That is what makes the stubbing
//     symmetric across a pair, which is what makes a measured difference attributable to
//     the edit rather than to the scaffolding.
//   * Fixed collection cardinality. A list of 3 in one place and 10 in another is a change
//     in tree size, and tree size is the dependent variable.
//   * Deterministic values only: no `Random`, no `DateTime.now()`, no I/O, no network, no
//     animation controllers left ticking.
//   * Keep `extends` and `implements` clauses exactly as they are. `spm analyze` decides
//     widget versus value object by walking the supertype chain, so a stand-in that stops
//     extending its widget base silently moves allocations into `valueObjectAllocCount`.
//   * Fill before measuring, then freeze. A fixture edited after seeing a result is a
//     fixture the result cannot be defended against.
//
// A slot the hierarchy cannot resolve keeps its `// TODO: value` and is NOT guessed.
// `scripts/fixture_gate.py` then refuses the group, so an unfilled fixture cannot reach the
// device.
//
// This file is a pure function of the mine plus two committed tables, and is regenerated as
// long as it is untouched. The first HAND edit makes it yours: the screen sees the file no
// longer matches the hash it recorded, copies it into config/authored_fixtures/, and never
// generates over it again -- including after a prune deletes this directory, which is how
// the hash alone used to lose an edit. `scripts/authored_fixtures.py --list` says which
// groups the corpus no longer derives from the mine; `--release <group>` hands one back.
{IGNORE_LINE}
part of generated_widget;
"""

_WHITESPACE = re.compile(r"\s+")


def _merge(existing: dict, incoming: dict) -> dict | None:
    """One declaration seen twice. Returns the merged entry, or None if they contradict.

    Only class-like declarations carry a header and members; everything else has to arrive
    identical. `spm isolate` emits enums whole rather than member by member for the same
    reason this refuses to merge them: their constants are part of the type's identity.
    """
    if _shape(existing["text"]) == _shape(incoming["text"]):
        return existing
    if existing.get("header") is None or incoming.get("header") is None:
        return None
    if _shape(existing["header"]) != _shape(incoming["header"]):
        return None

    members: dict[str, str] = {}
    for source in (existing, incoming):
        for member in source["members"]:
            kept = members.get(member["name"])
            # Longer wins: the bodies all throw, so the difference is in the signature, and
            # the longer signature is the one both call sites resolve against.
            if kept is None or len(member["text"]) > len(kept):
                members[member["name"]] = member["text"]
    body = "\n".join(f"  {text}" for text in members.values())
    return {
        **existing,
        "text": f"{existing['header']} {{\n{body}\n}}",
        "members": [{"name": name, "text": text} for name, text in members.items()],
        "needsValue": existing["needsValue"] or incoming["needsValue"],
    }


def _shape(text: str) -> str:
    """Source with runs of whitespace collapsed, for comparing two roles' declarations.

    Formatting is not a difference: `dart format` disagreeing with itself across two
    revisions of a file must not cost a role its place in the group.
    """
    return _WHITESPACE.sub(" ", text).strip()


def digest(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


@dataclass
class GroupFixture:
    """What one group's roles agreed on."""

    text: str
    """The `dependencies.dart` to write."""

    residuals: dict[str, str] = field(default_factory=dict)
    """Role filename -> the transplant with its share hoisted out and imports unioned in."""

    dropped: dict[str, str] = field(default_factory=dict)
    """Role filename -> the declaration name that could not be reconciled."""

    clash_kinds: dict[str, str] = field(default_factory=dict)
    """Role filename -> `lifted_value` or `stand_in`, for the same roles as `dropped`.

    The two mean opposite things and must not be reported as one. A `stand_in` clash is a
    reconstruction artefact -- two roles reached different call sites of the same symbol --
    and says nothing about the scope. A `lifted_value` clash is a finding: 0.7.0 relocates
    the scope's initial state, so two revisions carrying DIFFERENT values for one binding
    would be mounted from different initial state, and a measured difference between them
    would not be attributable to the edit. That is exactly the asymmetry the shared fixture
    exists to catch, and it should read as caught rather than as noise.
    """

    entries: int = 0
    needs_value: int = 0


def apply_value(decl: str, entry: dict | None) -> str | None:
    """`decl` with its value substituted, or None when there is nothing to substitute.

    Pure text surgery on the declaration the split produced. This module CONSUMES the
    committed table and never resolves anything itself -- `scripts/fixture_values.py` owns
    resolution, which reaches git and must stay out of the screen.
    """
    if not entry or entry.get("expr") is None:
        return None
    core = decl.rstrip()
    if not core.endswith(";"):
        return None
    core = core[:-1]
    if "=" in core:
        core = core.split("=")[0].rstrip()
    core = core.removeprefix("late ").rstrip() if core.startswith("late ") else core
    return f"{core} = {entry['expr']};"


def build(rows: dict[str, dict], values: dict[str, dict] | None = None) -> GroupFixture | None:
    """Union one group's per-role splits. `rows` is filename -> the `fixture` row.

    `values` is this group's `bindings` block from `config/fixture_values.json`. Where it carries
    an expression the declaration is emitted with it; where it does not, the `// TODO: value`
    stamp survives and `scripts/fixture_gate.py` refuses the group. A fixture is therefore a
    pure function of the mine plus the two committed tables, which is what keeps it
    reproducible rather than hand-authored.

    Returns `None` when the group needs no fixture at all: nothing was hoisted out of any of
    its roles, so the transplants stand alone and adding an empty `part` would only give
    them a file to fail to find.
    """
    registry: dict[str, dict] = {}                 # name -> the merged entry
    order: list[str] = []
    dropped: dict[str, str] = {}
    kinds: dict[str, str] = {}
    imports: list[str] = []

    for name in sorted(rows):
        row = rows[name]
        # Merged into a copy first: a role that turns out to contradict the group must leave
        # the registry exactly as it found it, or the roles after it inherit half of it.
        merged = dict(registry)
        clash = None
        for h in row["hoisted"]:
            if h["name"] not in merged:
                merged[h["name"]] = h
                continue
            reconciled = _merge(merged[h["name"]], h)
            if reconciled is None:
                clash = h["name"]
                # `lifted` on either side: the roles disagree about the value the scope
                # started from, not about a reconstructed signature. See `clash_kinds`.
                clash_kind = ("lifted_value"
                              if "lifted" in (h["section"],
                                              merged[h["name"]]["section"])
                              else "stand_in")
                break
            merged[h["name"]] = reconciled
        if clash is not None:
            # Reported, not merged: a role whose stand-in contradicts the group cannot be
            # measured against the same fixture as its siblings, and the fixture is the
            # thing that must not fork.
            dropped[name] = clash
            kinds[name] = clash_kind
            continue
        for h in row["hoisted"]:
            if h["name"] not in registry:
                order.append(h["name"])
        registry = merged
        for directive in row["imports"]:
            if directive not in imports:
                imports.append(directive)

    if not registry:
        return None

    needs_value = {name for name, entry in registry.items() if entry["needsValue"]}

    body: list[str] = [HEADER]
    for section, banner in SECTIONS:
        names = [n for n in order if registry[n]["section"] == section]
        if not names:
            continue
        body.append("\n" + "\n".join(banner))
        for name in names:
            text = registry[name]["text"]
            if name in needs_value:
                filled = apply_value(text, (values or {}).get(name))
                text = filled if filled is not None else (
                    f"// TODO: value\n{text}" if "\n" in text
                    else f"{text} // TODO: value")
            body.append("\n" + text)
    fixture_text = "\n".join(body).rstrip() + "\n"

    residuals = {}
    for name in sorted(rows):
        if name in dropped:
            continue
        residual = rows[name]["text"]
        missing = [d for d in imports if d not in rows[name]["imports"]]
        if missing:
            # Before the `part`, which is where the grammar wants imports, and where the
            # role's own imports already are.
            residual = residual.replace(PART_LINE, "\n".join(missing) + "\n" + PART_LINE, 1)
        residuals[name] = residual.replace(LIBRARY_LINE, f"{IGNORE_LINE}\n{LIBRARY_LINE}", 1)

    return GroupFixture(text=fixture_text, residuals=residuals, dropped=dropped,
                        clash_kinds=kinds, entries=len(registry),
                        needs_value=len(needs_value))


def load_index(dest: Path) -> dict[str, str]:
    path = dest / INDEX_NAME
    if not path.is_file():
        return {}
    try:
        stored = json.loads(path.read_text())
    except json.JSONDecodeError:
        return {}                      # a truncated index costs protection, never content
    return stored if isinstance(stored, dict) else {}


def save_index(dest: Path, index: dict[str, str]) -> None:
    (dest / INDEX_NAME).write_text(json.dumps(index, indent=0, sort_keys=True) + "\n")


def place(dest: Path, gid: str, text: str, index: dict[str, str], *,
          dry_run: bool, guard=None) -> str:
    """Write one group's fixture unless a human has edited it.

    Returns `written`, `current`, `authored` or `restored`. `authored` covers both an edited
    skeleton and a fixture written before this ever ran: neither is reproducible from the mine,
    so neither is ever overwritten.

    The hash check below can only speak about a file that is THERE, and that was the hole:
    `screen/export` removes a stale group directory whenever `--prune` is set, so a group that
    leaves the eligible set for one batch comes back with nothing to compare against and is
    regenerated over -- which is how 0082 lost the same fill three times on 2026-09-07. The
    store is consulted FIRST because it survives a prune, and adoption happens here, at the one
    moment authorship is still visible.

    `guard` is called on the two paths that change the file on disk -- a restore from the
    store and a regeneration -- and on neither of the paths that leave it alone. That is what
    lets `screen.freeze` refuse a fixture rewrite under a measured group without refusing the
    ordinary re-screen, which reaches `current` or `authored` and writes nothing.
    """
    from . import authored_fixtures

    path = dest / gid / FIXTURE_NAME
    if authored_fixtures.owns(dest, gid):
        if dry_run:
            return "authored"
        if authored_fixtures.differs(dest, gid):
            if guard is not None:
                guard()
            return "restored" if authored_fixtures.restore(dest, gid) else "authored"
        return "authored"
    if authored_fixtures.is_authored(gid) and not dry_run:
        # Stored, but the roles under this id are not the ones it was adopted against. Say so
        # and fall through: generating is right for a scope the fill was never read against.
        authored_fixtures.warn_scope(dest, gid)
    if path.is_file():
        with open(path, encoding="utf-8", newline="") as fh:
            existing = fh.read()
        if index.get(gid) != digest(existing):
            if not dry_run:
                authored_fixtures.adopt(dest, gid)
            return "authored"
        if existing == text:
            return "current"
    if guard is not None:
        guard()
    if not dry_run:
        path.parent.mkdir(parents=True, exist_ok=True)
        with open(path, "w", encoding="utf-8", newline="") as fh:
            fh.write(text)
    index[gid] = digest(text)
    return "written"


def is_generated(dest: Path, gid: str, index: dict[str, str]) -> bool:
    """True when the fixture at `dest/gid` is this module's own untouched output.

    `screen_samples.authored_files` treats any file at `dest` the corpus does not have as
    hand-authored, and protects its group from pruning. A skeleton nobody has edited is not
    that: it is derived, and a group should not survive exclusion merely because the screen
    generated something into it.

    A group in `authored_fixtures` is never generated, whatever the bytes on disk say. Saying
    it HERE rather than at each caller is deliberate: `fixture_values`, `maximal_branch` and
    `rebuild.authored_under` all build their hands-off set from this one predicate, and three
    copies of the same test are three chances for one of them to drift.
    """
    from . import authored_fixtures

    if authored_fixtures.owns(dest, gid):
        return False
    path = dest / gid / FIXTURE_NAME
    if not path.is_file():
        return False
    with open(path, encoding="utf-8", newline="") as fh:
        return index.get(gid) == digest(fh.read())
