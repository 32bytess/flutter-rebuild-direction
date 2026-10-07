"""Absolute static feature vectors for every role in a mined corpus, in one `spm analyze`.

WHY THIS EXISTS
---------------
`screen_samples.py` decides eligibility on the pairs `mining/mine` recorded, and those are
ADJACENT COMMIT pairs carrying `d_<feature>` deltas. Contrasts are wanted all-pairwise within
a scope -- a-b, a-c, a-d, b-c, ... -- and the mine's checkpoints cannot supply them: their
`features` rows carry `scope_key/commit/author/subject/status` and no feature values at all,
so there is nothing to difference between two non-adjacent revisions.

Absolute vectors are recoverable a different way: analyse the shipped roles themselves. That
is what this module does, and it is the only new input all-pairwise screening needs.

WHAT IT REUSES
--------------
The one-pass arrangement in `device_runner/runner.py:index_samples`, for the reason given
there: roles sit inside the package root, so `package:flutter` and the sibling
`dependencies.dart` resolve in place and the corpus needs no transplanting into `lib/`. That
turns a whole-project analyze per role into a single pass -- measured here at 107 s for 1,352
roles, against hours the other way.

Two differences from that function, both of which are why this is not just a call to it:

  * the corpus root is a PARAMETER. `index_samples` reads `config.SAMPLES_ROOT`, which is
    arm 1's hand-curated corpus.
  * `spm analyze` is given ONE root, so `filePath` comes back as `<group>/<role>.dart` and
    the group is readable from it. Passing group directories individually relativizes each
    against itself and loses the group -- see `config.spm_analyze_cmd`'s note.

Selection by class name is unchanged and needs no adaptation: `spm isolate` renames a
transplanted scope to `_GeneratedWidgetState` in the v2 corpus exactly as in arm 1, and 109
of the 1,352 v2 roles declare a second `State` alongside the root one, so "first row wins"
would be a coin flip on declaration order.

WHAT A MISSING VECTOR MEANS, AND WHY IT IS REPORTED RATHER THAN DROPPED
----------------------------------------------------------------------
`spm analyze` SKIPS any file carrying an error-severity diagnostic (`fixture_skeleton.py`
documents the same trap from the other side). A role with no vector cannot enter any
contrast, so silently dropping it would shrink the corpus by an amount nothing records.
`coverage()` returns the funnel instead.

The dominant cause measured on the 2026-08-27 corpus is NOT the transplants: it is the
group's own generated fixture. `dependencies.dart` is a `part of` the role's library, so one
`duplicate_definition` in the union fixture puts an error in EVERY role of that group at
once. Group `1440` loses 17 of 19 roles to a single `assistant_error` declared twice.
"""

from __future__ import annotations

import collections
import hashlib
import json
import logging
import os
import shutil
import subprocess
from pathlib import Path, PurePosixPath

from . import spm
from .paths import PROJECT_ROOT

# The scope every transplanted role declares, and the type the analyzer is pinned to. Both
# match `device_runner/config.py`; they are restated rather than imported because that
# module also binds arm 1's corpus paths and device configuration, none of which applies to
# a static pass over a mined corpus.
GENERATED_STATE_CLASS = "_GeneratedWidgetState"
STATE_SCOPE_TYPE = spm.STATE_SCOPE_TYPE   # kept as a name; defined once in `spm`
SCOPE_NAME_KEYS = ("scopeName", "stateClassName")

# The features a delta is taken over: exactly the twelve `mining/mine` emits `d_<name>`
# for. NOT `pipeline/config.STATIC_FEATURE_KEYS`, which is fourteen -- differencing over a
# wider set than the mine used would make this pass and the mine's stored deltas
# incomparable, and comparing them is how the pass is verified.
DELTA_FEATURE_KEYS: tuple[str, ...] = (
    "treeNonConstWidgetCount",
    "treeMaxWidgetNestingDepth",
    "treeListRenderingStrategy",
    "rootBuildReturnsConstWidget",
    "treeConstWidgetCount",
    "helperReferenceCount",
    "usesLayoutDependentBuilder",
    "treeCyclomaticComplexity",
    "treeIterationCount",
    "iterationWidgetCount",
    "valueObjectAllocCount",
    "helperWidgetCount",
)

VECTORS_FILE = "static_vectors.jsonl"


def scope_name(row: dict) -> str | None:
    """The rebuild scope's declaring class, across spm 0.3.0's `stateClassName` rename."""
    for key in SCOPE_NAME_KEYS:
        if key in row:
            return row[key]
    return None


def analyze_cmd(root: Path, output: Path) -> list[str]:
    return spm.analyze_state_cmd([root], output)


def run_analyze(root: Path, output: Path, *, project_root: Path,
                timeout: int = 3600) -> str:
    """One `spm analyze` over `root`. Returns spm's own summary line for the record."""
    output.parent.mkdir(parents=True, exist_ok=True)
    proc = subprocess.run(analyze_cmd(root, output), cwd=project_root,
                          capture_output=True, text=True, timeout=timeout)
    if proc.returncode != 0:
        raise RuntimeError(f"`spm analyze` over {root} failed:\n{proc.stderr}")
    summary = next((ln for ln in reversed(proc.stdout.splitlines()) if "Scanned" in ln), "")
    return summary.strip()


def index(rows_path: Path) -> dict[tuple[str, str], dict]:
    """`(group, role) -> the analyzed row`, one per file.

    Keyed off the path TAIL because the analyzer relativizes `filePath` against the analysis
    root it picked, and `instanceId` is hashed from that same relative path -- so an id
    extracted under one root does not match one extracted under another and is never a key.
    """
    by_file: dict[tuple[str, str], list[dict]] = collections.defaultdict(list)
    for line in rows_path.read_text().splitlines():
        if not line.strip():
            continue
        row = json.loads(line)
        parts = PurePosixPath(row.get("filePath", "")).parts
        if len(parts) < 2:
            continue
        by_file[(parts[-2], parts[-1].removesuffix(".dart"))].append(row)

    out: dict[tuple[str, str], dict] = {}
    for key, rows in by_file.items():
        rec = next((r for r in rows if scope_name(r) == GENERATED_STATE_CLASS), None)
        if rec is not None:
            out[key] = rec
    return out


def roles_on_disk(corpus: Path) -> set[tuple[str, str]]:
    return {(d.name, f.stem)
            for d in corpus.iterdir() if d.is_dir() and d.name.isdigit()
            for f in d.glob("rev_*.dart")}


def content_hash(corpus: Path, group: str, role: str) -> str:
    """Identity for role dedup.

    The file's bytes, not the mine's `content_sha256`: that one is taken over the scope's
    SOURCE at the commit, and 905 of 1,179 ordinal-adjacent shipped roles are byte-identical
    to their neighbour despite carrying distinct source hashes. Contrast construction has to
    dedup on what will actually be measured, which is the file.
    """
    return hashlib.sha256((corpus / group / f"{role}.dart").read_bytes()).hexdigest()


def vectors(corpus: Path, rows_path: Path) -> tuple[dict[tuple[str, str], dict], dict]:
    """`(group, role) -> {feature: value, "_sha": ...}` for every role that analysed, plus
    the coverage funnel."""
    analyzed = index(rows_path)
    roles = roles_on_disk(corpus)
    kept: dict[tuple[str, str], dict] = {}
    for key in sorted(roles & set(analyzed)):
        row = analyzed[key]
        vec = {k: row[k] for k in DELTA_FEATURE_KEYS if k in row}
        if len(vec) != len(DELTA_FEATURE_KEYS):
            continue                      # a row missing a feature is never differenced
        vec["_sha"] = content_hash(corpus, *key)
        # Carried, not acted on. Whether an unresolved walk disqualifies a role is a
        # SCREENING decision and lives with the other rules in `screen_samples.R14`; this
        # module's job is to report what the analyzer said, including when it says the row
        # it just produced is short.
        vec["_resolved"] = row.get("closureResolved")
        kept[key] = vec

    missing = roles - set(kept)
    by_group = collections.Counter(g for g, _ in missing)
    funnel = {
        "roles_on_disk": len(roles),
        "roles_with_vector": len(kept),
        "roles_without_vector": len(missing),
        "groups_affected": len(by_group),
        "worst_groups": by_group.most_common(10),
        "missing": sorted(f"{g}/{r}" for g, r in missing),
    }
    return kept, funnel


def write(corpus: Path, kept: dict[tuple[str, str], dict]) -> Path:
    path = corpus / VECTORS_FILE
    with path.open("w") as fh:
        for (group, role), vec in sorted(kept.items()):
            fh.write(json.dumps({"group": group, "role": role, **vec}) + "\n")
    return path


def load(corpus: Path, path: Path | None = None) -> dict[tuple[str, str], dict]:
    """Read back what `write` produced. Empty when the pass has not been run.

    `path` overrides where the file is looked for, because the tree the vectors were
    EXTRACTED from is not always the tree being screened. Vectors need the group's
    `dependencies.dart` to resolve, so they can only be taken from an exported corpus; the
    fixture split and R13 need the bindings still in the role, so they can only be taken
    from the un-hoisted one. The `(group, role)` key is the same in both.
    """
    path = path or corpus / VECTORS_FILE
    if not path.is_file():
        return {}
    out = {}
    for line in path.read_text().splitlines():
        if not line.strip():
            continue
        row = json.loads(line)
        key = (row.pop("group"), row.pop("role"))
        out[key] = row
    return out


CACHE_NAME = ".vector_cache.json"


def _role_key(role_text: str, fixture_digest: str) -> str:
    """What makes a vector reusable: the role's staged text and its group's fixture.

    Both, because a vector is a property of the pair. Editing a `// TODO: value` changes what
    the walker can resolve without touching a single role, and a cache keyed on the role
    alone would serve the pre-edit answer forever -- which is the failure `screen_mode` already
    guards against by folding `values_version()` into the screen fingerprint.
    """
    return hashlib.sha256(
        role_text.encode() + b"\x00" + fixture_digest.encode()
    ).hexdigest()


def staged_vectors(roles: dict[str, list[tuple[str, str]]], fixtures: dict[str, Path], *,
                   project_root: Path, store: Path,
                   log=logging.info) -> tuple[dict[tuple[str, str], dict], dict]:
    """Absolute vectors for `roles`, resolving each group against its own fixture.

    `roles` is `gid -> [(role stem, STAGED TEXT)]`, and the text must be the split's `text`,
    not the source file's bytes.

    THAT DISTINCTION IS THE WHOLE CORRECTNESS ARGUMENT. What runs on the device is the
    exported role: normalised, imports pruned, its lifted bindings hoisted out and replaced by
    `part 'dependencies.dart'`. The raw mined file still carries those bindings inline and
    still references resources the container cannot resolve, so analysing it measures a file
    that never mounts. Measured: staging the source instead of the split made
    `closureResolved` come back 1 on 1,250 of 1,250 roles and collapsed byte-duplicate
    detection to 19, against 1,029 of 1,334 and 656 for the artefact that actually ships.
    `screener.backend.splits()` already returns exactly this text, so nothing extra is
    computed for it.

    The two inputs live in different trees -- roles in the frozen mine output, fixtures in a
    store beside it -- so neither is a corpus `spm analyze` can be pointed at. This stages a
    third: one directory per group holding the group's staged roles and its
    `dependencies.dart`, rooted inside `project_root` so `package:flutter` resolves.

    ONE root, never a list of group directories: the analyzer relativizes `filePath` against
    the root it picks, so passing the directories individually returns a bare
    `rev_001_x.dart` and loses the group (`device_runner/config.spm_analyze_cmd` says the
    same thing from the other side).
    """
    cache_path = store / CACHE_NAME
    cache = {}
    if cache_path.is_file():
        try:
            cache = json.loads(cache_path.read_text())
        except json.JSONDecodeError:
            cache = {}                 # a truncated cache costs time, never correctness

    digests = {}
    for gid, fixture in fixtures.items():
        digests[gid] = hashlib.sha256(fixture.read_bytes()).hexdigest() \
            if fixture.is_file() else ""

    wanted: dict[tuple[str, str], str] = {}
    stale: dict[str, list[tuple[str, str]]] = collections.defaultdict(list)
    kept: dict[tuple[str, str], dict] = {}
    for gid, staged in roles.items():
        for stem, text in staged:
            key = _role_key(text, digests.get(gid, ""))
            wanted[(gid, stem)] = key
            if key not in cache:
                stale[gid].append((stem, text))
            elif cache[key] is not None:
                kept[(gid, stem)] = cache[key]
            # else: cached NEGATIVE -- see below. Not a vector, and not re-analysed.

    log("  vectors: %d reused from cache, %d to analyze",
        len(kept), sum(len(v) for v in stale))

    if stale:
        staging = project_root / f".analyze_staging_{os.getpid()}"
        shutil.rmtree(staging, ignore_errors=True)
        try:
            for gid, staged in stale.items():
                d = staging / gid
                d.mkdir(parents=True, exist_ok=True)
                for stem, text in staged:
                    (d / f"{stem}.dart").write_text(text)
                fixture = fixtures.get(gid)
                if fixture is not None and fixture.is_file():
                    (d / fixture.name).write_text(fixture.read_text())
            rows_path = staging / ".static_rows.jsonl"
            log("  %s", run_analyze(staging, rows_path, project_root=project_root))
            analyzed = index(rows_path)
            for gid, staged in stale.items():
                for stem, text in staged:
                    row = analyzed.get((gid, stem))
                    vec = {k: row[k] for k in DELTA_FEATURE_KEYS if k in row} if row else {}
                    if len(vec) != len(DELTA_FEATURE_KEYS):
                        # A NEGATIVE is cached like any other answer. `spm analyze` skips a
                        # file carrying an error-severity diagnostic, and that is a pure
                        # function of the same (text, fixture) the key is built from -- so
                        # re-running it every screen buys nothing and costs a `dart run`.
                        # Left uncached, these were the 4 roles that kept a warm run from
                        # reaching zero analyses.
                        cache[wanted[(gid, stem)]] = None
                        continue
                    # Over the STAGED text, so "same role twice" means the same file will be
                    # measured twice -- which is the question dedup asks.
                    vec["_sha"] = hashlib.sha256(text.encode()).hexdigest()
                    vec["_resolved"] = row.get("closureResolved")
                    kept[(gid, stem)] = vec
                    cache[wanted[(gid, stem)]] = vec
        finally:
            shutil.rmtree(staging, ignore_errors=True)
        store.mkdir(parents=True, exist_ok=True)
        cache_path.write_text(json.dumps(cache, sort_keys=True) + "\n")

    asked = sum(len(v) for v in roles.values())
    funnel = {"roles_offered": asked, "roles_with_vector": len(kept),
              "roles_analysed_to_no_vector": sum(
                  1 for k in wanted.values() if cache.get(k, "") is None),
              "roles_without_vector": asked - len(kept),
              "analyzed_this_run": sum(len(v) for v in stale)}
    return kept, funnel


def main() -> None:
    import argparse
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("corpus", type=Path, help="the corpus root, e.g. new_samples")
    ap.add_argument("--project-root", type=Path, default=PROJECT_ROOT,
                    help="the Flutter package `dart run spm:spm` resolves against")
    ap.add_argument("--rows", type=Path,
                    help="reuse an existing `spm analyze` JSONL instead of running one")
    args = ap.parse_args()

    logging.basicConfig(level=logging.INFO, format="%(message)s")
    corpus = args.corpus.resolve()
    rows_path = args.rows or (corpus / ".static_rows.jsonl")
    if args.rows is None:
        logging.info("analyzing %s in place…", corpus.name)
        logging.info("  %s", run_analyze(corpus, rows_path, project_root=args.project_root))

    kept, funnel = vectors(corpus, rows_path)
    path = write(corpus, kept)

    logging.info("\nvectors -> %s", path)
    logging.info("  roles on disk        %d", funnel["roles_on_disk"])
    logging.info("  with a vector        %d", funnel["roles_with_vector"])
    logging.info("  WITHOUT a vector     %d  (%d groups)",
                 funnel["roles_without_vector"], funnel["groups_affected"])
    for group, n in funnel["worst_groups"]:
        logging.info("      %s  %d", group, n)
    (corpus / "vector_coverage.json").write_text(json.dumps(funnel, indent=2) + "\n")


if __name__ == "__main__":
    main()
