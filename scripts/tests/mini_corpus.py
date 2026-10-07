"""A synthetic mined corpus, small enough to reason about and wide enough to fire every rule.

The real corpus is 1,444 groups behind a 107-second analysis pass. This one is ten groups
across two repositories, built so that each group exists to exercise exactly one decision,
and screened on the `--vectors` path so no `spm analyze` run is needed: the feature vectors
are supplied rather than extracted, which is what makes the whole thing run in about a
second.

Everything is written from `build()` rather than checked in as a tree, so what each group
tests is readable as a table instead of as 40 files.

    gid   repo    revisions  exercises
    0001  alpha   3          the clean path: 3 distinct vectors, identical bindings
    0002  alpha   2          a hard rule (R1) on one endpoint only
    0003  alpha   1          R8, fewer than two transplanted states
    0004  alpha   2          R15, distinct code and an identical feature vector
    0005  alpha   2          R14, one role whose walker never descended
    0006  beta    2          R9, a repository the mine has not checkpointed
    0007  alpha   2          R7, a near-duplicate of 0001's representative
    0008  alpha   2          R13, endpoints that mount from different bindings
    0009  alpha   2          R10, a transplant spm could not analyse
    0010  alpha   3          a role that ships and is an endpoint of nothing
    0011  alpha   2          R19/R20, endpoints reaching a shim by builder and by children
"""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

# The twelve features a delta is taken over, in `extract_features.DELTA_FEATURE_KEYS` order.
from scripts.extract_features import DELTA_FEATURE_KEYS

ALPHA, BETA = "owner/alpha", "owner/beta"

# ---------------------------------------------------------------------------------------
# Dart templates
# ---------------------------------------------------------------------------------------
# Shaped like a real `spm isolate` transplant: the generated `GeneratedWidget` wrapper, a
# `_GeneratedWidgetState` whose `initState` seeds its fields from top-level bindings, and the
# `// Fixture block` banner that tells the split where the hoisted declarations begin.

HEAD = """import 'package:flutter/material.dart';

class GeneratedWidget extends StatefulWidget {
  const GeneratedWidget({super.key});

  GeneratedWidget.fixture({super.key});

  @override
  State<GeneratedWidget> createState() => _GeneratedWidgetState();
}

class _GeneratedWidgetState extends State<GeneratedWidget> {
"""

TAIL = """}

// Fixture block
"""


def role(*, seeds: dict[str, str], body: str, extra_state: str = "",
         stand_ins: str = "") -> str:
    """One transplant. `seeds` maps a fixture binding name to its Dart type.

    A `late <type> <name>;` at top level is what the split calls a SEED -- the scope's
    relocated initial state, and one of the two sections R13 compares a pair on.
    """
    init = "".join(f"    _{n} = {n};\n" for n in seeds)
    fields = "".join(f"  late {t} _{n};\n" for n, t in seeds.items())
    hoists = "".join(f"late {t} {n};\n" for n, t in seeds.items())
    return (
        HEAD
        + "  @override\n  void initState() {\n    super.initState();\n"
        + init
        + "  }\n\n"
        + fields
        + extra_state
        + "\n  @override\n  Widget build(BuildContext context) {\n"
        + body
        + "  }\n"
        + TAIL
        + hoists
        # After the banner, so R19 sees these as the generated stand-in region -- the same
        # boundary `standInStart` gives the region map and the R7 hash.
        + stand_ins
    )


# Three widths of the same tree. `marker` is what makes one group's transplant distinct
# from another's: R7 hashes the tokens BEFORE the stand-in block, so without it every group's
# first revision is byte-identical scaffolding and all nine collapse into one duplicate set.
EXTRA = (
    "",
    "        const Divider(),\n",
    "        const Divider(),\n        Row(children: const [Text('x'), Icon(Icons.star)]),\n",
)


def body(width: int, marker: str, *, animated: bool = False) -> str:
    """`width` in 1..3 grows the tree; `animated` puts a spinner in it, which fires R1."""
    spinner = "        const CircularProgressIndicator(),\n" if animated else ""
    return ("    return Column(\n      children: [\n"
            f"        Text('{marker} ${{_count}}'),\n"
            "        const SizedBox(height: 8),\n"
            + EXTRA[width - 1] + spinner
            + "      ],\n    );\n")


def clean(width: int, marker: str) -> str:
    return role(seeds={"fixtureCount": "int"}, body=body(width, marker))


# A shim as `ShimEmitter` writes one: ONE pass-through field, chosen over the union of the
# constructors, and a `build` that renders it or renders nothing. `MiniGrid.builder` does not
# declare `children`, so it initialises the field null and discards the `itemBuilder` it was
# handed -- which is group 0082's defect, reduced to the smallest program that has it.
SHIM = """
// Declaration-only stand-ins
class MiniGrid extends StatelessWidget {
  final dynamic children;
  MiniGrid.count({super.key, dynamic crossAxisCount, this.children});
  MiniGrid.builder({super.key, dynamic itemBuilder, dynamic itemCount})
      : children = null;
  @override
  Widget build(BuildContext context) => Stack(
    children: children is List<Widget>
        ? children as List<Widget>
        : const <Widget>[],
  );
}
"""


def shim_role(*, builder: bool, marker: str) -> str:
    """A transplant reaching `MiniGrid` by the builder form (drops) or the literal form."""
    call = ("        MiniGrid.builder(\n"
            "          itemBuilder: (BuildContext c, int i) => const Text('row'),\n"
            "          itemCount: 3,\n"
            "        ),\n") if builder else (
           "        MiniGrid.count(\n"
           "          crossAxisCount: 2,\n"
           "          children: const [Text('row'), Text('row')],\n"
           "        ),\n")
    return role(
        seeds={"fixtureCount": "int"},
        body=("    return Column(\n      children: [\n"
              f"        Text('{marker} ${{_count}}'),\n"
              + call + "      ],\n    );\n"),
        stand_ins=SHIM,
    )


# ---------------------------------------------------------------------------------------
# Feature vectors
# ---------------------------------------------------------------------------------------

def vector(nonconst: int, *, resolved: int = 1, sha: str | None = None) -> dict:
    """A twelve-feature row. Only `treeNonConstWidgetCount` varies -- one moving feature is
    enough to make a delta nonzero, and holding the other eleven still keeps the golden
    readable."""
    vec = {k: 0 for k in DELTA_FEATURE_KEYS}
    vec["treeNonConstWidgetCount"] = nonconst
    vec["_resolved"] = resolved
    vec["_sha"] = sha or hashlib.sha256(json.dumps(vec, sort_keys=True).encode()
                                        ).hexdigest()[:16]
    return vec


# ---------------------------------------------------------------------------------------
# The corpus
# ---------------------------------------------------------------------------------------
#
# (gid, project, [(ordinal, sha8, source), ...], [vector per revision])

def _groups() -> list[tuple[str, str, list[tuple[int, str, str]], list[dict]]]:
    animated = role(seeds={"fixtureCount": "int"},
                    body=body(2, "g2", animated=True))
    two_seeds = role(seeds={"fixtureCount": "int", "fixtureLabel": "String"},
                     body=body(2, "g8"))
    return [
        # Clean, three distinct vectors, one shared binding set -> 3 eligible contrasts.
        ("0001", ALPHA,
         [(1, "aaaa0001", clean(1, "g1")), (2, "aaaa0002", clean(2, "g1")),
          (3, "aaaa0003", clean(3, "g1"))],
         [vector(2), vector(4), vector(6)]),
        # rev_002 fires R1. A pair needs BOTH endpoints clean, so its one contrast goes.
        ("0002", ALPHA,
         [(1, "bbbb0001", clean(1, "g2")), (2, "bbbb0002", animated)],
         [vector(2), vector(4)]),
        # One transplanted state: no predecessor, so no delta is derivable at all.
        ("0003", ALPHA, [(1, "cccc0001", clean(1, "g3"))], [vector(2)]),
        # Distinct code, identical vector -> the contrast carries nothing to learn from.
        ("0004", ALPHA,
         [(1, "dddd0001", clean(1, "g4")), (2, "dddd0002", clean(2, "g4"))],
         [vector(3, sha="dddd_one"), vector(3, sha="dddd_two")]),
        # rev_002's walker never descended: the row is SHORT, not slightly wrong.
        ("0005", ALPHA,
         [(1, "eeee0001", clean(1, "g5")), (2, "eeee0002", clean(2, "g5"))],
         [vector(2), vector(4, resolved=0)]),
        # owner/beta has no checkpoint: still being written, so HELD rather than excluded.
        ("0006", BETA,
         [(1, "ffff0001", clean(1, "g6")), (2, "ffff0002", clean(2, "g6"))],
         [vector(2), vector(4)]),
        # Byte-identical to 0001's representative -> the higher id is the duplicate.
        ("0007", ALPHA,
         [(1, "aaaa0001", clean(1, "g1")), (2, "99990002", clean(2, "g7"))],
         [vector(2), vector(4)]),
        # rev_002 hoists a second seed: the endpoints mount from different initial state.
        ("0008", ALPHA,
         [(1, "88880001", clean(1, "g8")), (2, "88880002", two_seeds)],
         [vector(2), vector(4)]),
        # spm could not analyse rev_002, so `spm analyze` skips it and it yields no row.
        ("0009", ALPHA,
         [(1, "77770001", clean(1, "g9")), (2, "77770002", clean(2, "g9"))],
         [vector(2), vector(4)]),
        # rev_003 is distinct CODE with a vector already seen, so the duplicate-content
        # filter drops it before any pair is formed -- and it still screens clean, so it
        # ships. That is the shape `--prune-to-endpoints` exists for: a role on disk that
        # is an endpoint of no contrast and would be measured for nothing. 262 of the real
        # corpus's 439 shipped roles are this.
        ("0010", ALPHA,
         [(1, "aaab0001", clean(1, "g10")), (2, "aaab0002", clean(2, "g10")),
          (3, "aaab0003", clean(3, "g10"))],
         # rev_002 and rev_003 get the SAME `_sha`: `vector()` derives it from the row.
         [vector(2), vector(4), vector(4)]),
        # rev_001 reaches the shim by its BUILDER constructor, which renders none of the
        # three rows it was handed; rev_002 reaches it by the literal-`children` one, which
        # renders both of its. R19 flags rev_001 (soft), and R20 excludes the pair, because
        # the delta between them is the shim's constructor coverage rather than the edit.
        # This is group 0082, which was measured on 2026-09-07 before the defect was known.
        ("0011", ALPHA,
         [(1, "66660001", shim_role(builder=True, marker="g11")),
          (2, "66660002", shim_role(builder=False, marker="g11"))],
         [vector(2), vector(4)]),
    ]


UNVERIFIED = {("0009", "rev_002_77770002.dart")}
HAND_EXCLUDED = "0001"          # used only by the --exclude-groups tests

# One role carries source from a hosted package, so R17 has real input here rather than
# passing on the silence of a field nobody wrote. Its vacuity guard refuses a corpus where
# NOT ONE row carries an inlining count -- absent means "this build does not report
# inlining", never "no package source" -- so a golden corpus with none would either abort or
# have to be waved through with a flag, and the rule would then be covered by nothing.
#
# `auto_size_text_field` 2.2.3 is the real package the real corpus inlines, and it is MIT, so
# this role PASSES and the goldens are unmoved. A test that wants a refusal supplies its own
# provenance table; see `test_license_rules.py`.
INLINES_PACKAGES = {("0002", "rev_001_bbbb0001.dart"):
                    {"auto_size_text_field": "2.2.3"}}


def build(root: Path) -> Path:
    """Write the corpus under `root` and return it. Also writes the manifests, the mine's
    per-repository checkpoints, and the `static_vectors.jsonl` the all-pairwise path reads."""
    root.mkdir(parents=True, exist_ok=True)
    groups = _groups()

    vectors, group_rows, code_rows, provenance_rows = [], [], [], []
    by_repo: dict[str, list[str]] = {}

    for gid, project, revs, vecs in groups:
        (root / gid).mkdir(exist_ok=True)
        by_repo.setdefault(project, []).append(gid)
        scope_key = f"{project}::lib/{gid}.dart::_GeneratedWidgetState"
        group_rows.append({
            "id": gid, "project": project,
            "source_file_relative": f"lib/{gid}.dart",
            "scope_name": "_GeneratedWidgetState",
            "source_file_absolute": f"/clones/{project}/lib/{gid}.dart",
            "base_dart": str(root / gid / "base.dart"),
        })
        for (ordinal, sha8, source), vec in zip(revs, vecs):
            name = f"rev_{ordinal:03d}_{sha8}.dart"
            (root / gid / name).write_text(source)
            vectors.append({"group": gid, "role": Path(name).stem, **vec})
            row = {"id": gid, "file": str(root / gid / name), "status": "isolated",
                   "verified": (gid, name) not in UNVERIFIED}
            if (gid, name) in UNVERIFIED:
                row["errorCount"] = 1
            packages = INLINES_PACKAGES.get((gid, name))
            if packages:
                # Emitted exactly as spm emits it: a count, and the packages beside it.
                # Neither fires anything on its own -- R12 reads `thirdPartyInlineReverted`
                # and `thirdPartyInlineTruncated`, not this -- so the only rule that sees it
                # is R17.
                row["inlinedThirdPartyDeclarations"] = len(packages)
                provenance_rows.append({
                    "id": gid, "file": name, "project": project,
                    "inlinedThirdPartyDeclarations": len(packages),
                    "inlinedThirdPartyPackages": packages,
                    "bytes_identical": True,
                })
            code_rows.append(row)
    _write_jsonl(root / "groups.jsonl", group_rows)
    _write_jsonl(root / "code_rows.jsonl", code_rows)
    _write_jsonl(root / "static_vectors.jsonl", vectors)
    # Beside the corpus, not at the real `probe_v2/license_provenance.jsonl`: a table about
    # different files would attribute these ones from someone else's evidence. `regolden`
    # passes it with --license-provenance.
    _write_jsonl(root / "license_provenance.jsonl", provenance_rows)
    # R18 reads the collector's record of what licence each repository was admitted under.
    # These projects are synthetic and are in no real harvest, so the golden corpus carries
    # its own -- one permissive licence each, which is what the real 20 all have.
    _write_jsonl(root / "candidates.jsonl",
                 [{"repo_name": project, "license": "mit"} for project in sorted(by_repo)])
    (root / "id_map.json").write_text(json.dumps(
        {f"{r['project']}::{r['source_file_relative']}::State::"
         f"{r['scope_name']}::0": r["id"] for r in group_rows}, indent=1))

    # `mine` checkpoints a repository when it FINISHES. owner/beta deliberately has none, so
    # its groups are HELD -- never exported, never deleted.
    checkpoints = root / "checkpoints"
    checkpoints.mkdir(exist_ok=True)
    for project in (ALPHA,):
        ids = set(by_repo[project])
        (checkpoints / f"{project.replace('/', '_')}.json").write_text(json.dumps({
            "repo_name": project,
            "new_groups": [r for r in group_rows if r["id"] in ids],
            "code_rows": [r for r in code_rows if r["id"] in ids],
        }, indent=1))
    return root


def _write_jsonl(path: Path, rows: list[dict]) -> None:
    path.write_text("".join(json.dumps(r) + "\n" for r in rows))
