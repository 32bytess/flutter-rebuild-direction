"""Python side of the parse-only Dart tool in `dart_tools/`.

(Named `ast_tools` rather than `dart_tools` so it cannot shadow, or be shadowed by, the
Dart package directory of that name sitting beside it.)

Read `dart_tools/bin/dart_tools.dart` for why it exists. In short: `screen_samples` used to
classify and rewrite Dart source with regexes and two hand-written scanners -- a
string/comment lexer and a paren balancer -- which is the work `package:analyzer` does
correctly and they did not. This module is the subprocess boundary, and nothing more: it
owns no rule and makes no decision.

Same shape as `history_probe/ast_probe.py`, deliberately -- one `dart pub get` on first use,
paths over stdin rather than argv, JSONL back.
"""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

TOOL_DIR = Path(__file__).resolve().parent / "dart_tools"
ENTRY = TOOL_DIR / "bin" / "dart_tools.dart"
# AOT, not `dart run`. The tool is invoked once per batch and `dart run` pays a JIT warm-up
# of a second or more every time, which on a 40-group screen was most of the wall clock.
# `.dart_tool/` is already gitignored, so the binary is a build artefact like the rest of it.
EXE = TOOL_DIR / ".dart_tool" / "dart_tools"

# `normalise` returns whole rewritten files, and the raw mine is ~440 MB of Dart, so a
# single batch would buffer the entire corpus in memory twice. Screening rows are small
# enough that the same chunk size costs nothing there.
CHUNK = 500


class DartToolError(RuntimeError):
    """The tool failed, or reported a file it could not read or parse.

    A file that will not parse is an error, never an empty result: a silently empty rule set
    would let an unscreened transplant into the corpus, which is the one failure this whole
    pass exists to prevent.
    """


def ensure_ready() -> None:
    """`dart pub get` and an AOT compile for the tool's own package, once.

    It has its own pubspec precisely so that analysing corpus source can never perturb
    benchmark_container's dependency resolution -- the project whose lockfile defines the
    pinned `spm` that produced the measured corpus.

    The binary is rebuilt whenever a source file is newer than it, so editing a rule takes
    effect without anyone having to remember to recompile.
    """
    if not (TOOL_DIR / ".dart_tool" / "package_config.json").is_file():
        completed = subprocess.run(
            ["dart", "pub", "get"], cwd=str(TOOL_DIR), capture_output=True, text=True
        )
        if completed.returncode != 0:
            raise DartToolError(f"dart pub get failed in {TOOL_DIR}:\n{completed.stderr}")

    sources = [TOOL_DIR / "pubspec.yaml", *TOOL_DIR.rglob("bin/*.dart"),
               *TOOL_DIR.rglob("lib/**/*.dart")]
    newest = max(p.stat().st_mtime_ns for p in sources if p.is_file())
    if EXE.is_file() and EXE.stat().st_mtime_ns >= newest:
        return
    completed = subprocess.run(
        ["dart", "compile", "exe", str(ENTRY), "-o", str(EXE)],
        cwd=str(TOOL_DIR), capture_output=True, text=True,
    )
    if completed.returncode != 0:
        raise DartToolError(f"dart compile exe failed in {TOOL_DIR}:\n{completed.stderr}")


def rules_version() -> str:
    """Digest of the rule vocabulary, for the checkpoint mode.

    `screen_samples.rules_fingerprint` used to hash the regex patterns themselves. The
    patterns now live in Dart, so the digest has to come from there -- otherwise widening a
    rule leaves the fingerprint identical and a checkpoint written under the narrower rule
    resumes as valid, which is exactly the bug the fingerprint exists to prevent.
    """
    ensure_ready()
    completed = subprocess.run(
        [str(EXE), "--rules-version"], cwd=str(TOOL_DIR), capture_output=True, text=True,
    )
    if completed.returncode != 0:
        raise DartToolError(f"dart_tools --rules-version failed:\n{completed.stderr[-2000:]}")
    return completed.stdout.strip()


def screen(paths: list[Path], timeout: int = 900) -> dict[str, dict]:
    """`{absolute path: {"rules": [...], "normHash": ...}}` for every path."""
    return _run("screen", paths, timeout)


def normalise(paths: list[Path], timeout: int = 900, *,
              prune_imports: bool = True) -> dict[str, dict]:
    """`{absolute path: {"text": ..., "counts": {...}}}` for every path.

    `prune_imports` additionally drops every import whose contribution is already covered by
    another import that stays -- unused and merely-redundant alike. See
    `dart_tools/lib/src/normalise.dart` `collectCoveredImports` for why this is not left to
    the analyzer's own `unused_import`.
    """
    extra = [] if prune_imports else ["--no-prune-imports"]
    return _run("normalise", paths, timeout, extra)


def fixture(paths: list[Path], timeout: int = 900, *,
            prune_imports: bool = True, lift_fields: bool = True,
            lift_mode: str = "state") -> dict[str, dict]:
    """`{absolute path: {"text": ..., "plainText": ..., "counts": ..., "hoisted": [...],
    "imports": [...]}}` for every path.

    The split that turns a mined transplant into a runnable one: seeds, declaration-only
    stand-ins and unresolved-reference stand-ins move out to the group's shared
    `dependencies.dart`, and what stays gets the `library` and `part` directives that join
    the two. Normalisation runs first and the split is computed against its output, so
    `text` is the finished file and `counts` are the same substitution counts `normalise`
    reports -- which is why this replaces that call rather than following it.

    See `dart_tools/lib/src/fixture.dart` for why the fixture is a `part` rather than a
    library of its own: most seeds in the mined corpus are private, and a private name moved
    into another library stops being visible.

    `lift_fields` lifts the transplanted widget's own constructor fields into fixture bindings
    too, so nothing invents a value inside a measured file and `GeneratedWidget()` can always
    be mounted. `lift_mode` says how far that goes, and the DEFAULT IS THE CORPUS SHAPE:

      * `"state"` -- what the corpus is built in, decided 2026-09-08. A `late final` field on
        the `State` per constructor field, assigned in `initState` from the top-level binding,
        and `widget.x` rewritten to `x`. Since 2026-09-09 the widget itself is left as
        `const GeneratedWidget({super.key})`: the fields and the copied constructor are gone,
        because the `State` owns them and `lib/main.dart` mounts the unnamed constructor.
        NOT feature-neutral: removing a `widget.` access moves `helperReferenceCount`, which
        is one of the arm-2 model's eight features. The move is measured by
        `scripts/widget_field_fidelity.py` and reported, never absorbed. Dropping the
        constructor is, since it is not in the measured region.
      * `"constructor"` -- the build body stays byte-identical, the copied constructor stays,
        and the role mounts through `GeneratedWidget.fixture`. Kept because the fidelity check
        needs both sides to compare.
    """
    extra = [] if prune_imports else ["--no-prune-imports"]
    if not lift_fields:
        extra = [*extra, "--no-lift-fields"]
    extra = [*extra, "--lift-mode", lift_mode]
    return _run("fixture", paths, timeout, extra)


def branches(paths: list[Path], timeout: int = 900) -> dict[str, dict]:
    """`{absolute path: {"branches": [...]}}` for every path.

    One row per conditional -- `if` statement, ternary and collection `if` element alike --
    carrying the condition verbatim and, per arm, how many non-const Flutter widgets, known
    non-widget value objects and unclassifiable instantiations it creates, plus whether it
    builds children lazily.

    Reports only. `scripts/maximal_branch` decides which literal a branch-selecting fixture
    binding takes and what counts as undecidable, the same split screening uses: the
    matching lives here, the vocabulary and the policy live there.

    A name in neither generated set is `unknown`, never a widget -- a user-defined type
    cannot be classified without resolving the transplant, and a mined transplant does not
    resolve. See `dart_tools/lib/src/branches.dart`.
    """
    return _run("branches", paths, timeout)


def _run(command: str, paths: list[Path], timeout: int,
         extra: list[str] | None = None) -> dict[str, dict]:
    ensure_ready()
    if not paths:
        return {}
    # Absolute, because the tool runs with cwd=TOOL_DIR: a relative path would resolve
    # against the package directory and every file would come back "absent".
    absolute = [str(Path(p).resolve()) for p in paths]

    rows: dict[str, dict] = {}
    failures: list[str] = []
    for start in range(0, len(absolute), CHUNK):
        batch = absolute[start:start + CHUNK]
        completed = subprocess.run(
            [str(EXE), command, "--stdin-list", *(extra or [])],
            cwd=str(TOOL_DIR),
            input="\n".join(batch),
            capture_output=True,
            text=True,
            timeout=timeout,
        )
        if completed.returncode != 0:
            raise DartToolError(
                f"dart_tools {command} failed:\n{completed.stderr[-4000:]}")
        for line in completed.stdout.splitlines():
            if not line.startswith("{"):
                continue
            row = json.loads(line)
            if row.get("status") != "ok":
                failures.append(f"{row['file']}: {row['status']} {row.get('error', '')}")
                continue
            rows[row["file"]] = row

    if failures:
        raise DartToolError(
            f"dart_tools {command}: {len(failures)} file(s) could not be analysed:\n  "
            + "\n  ".join(failures[:20]))

    unknown = sorted({u for row in rows.values() for u in row.get("unknownImports", ())})
    if unknown:
        # Never fatal: an unknown URI is simply never dropped and never counted as covering
        # anything, so the rule stays conservative. But the table should learn about it --
        # regenerate with `dart run tool/export_namespaces.dart <project-root>`.
        print(f"dart_tools: {len(unknown)} import URI(s) not in namespaces.g.dart, so never "
              f"pruned: {', '.join(unknown[:8])}", file=sys.stderr)

    missing = [p for p in absolute if p not in rows]
    if missing:
        raise DartToolError(
            f"dart_tools {command} returned no row for {len(missing)} file(s), "
            f"first: {missing[0]}")
    return rows
