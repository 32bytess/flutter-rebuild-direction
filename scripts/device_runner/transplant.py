"""Staging a sample into `lib/`, in one place.

Two tools transplant a role into the Flutter app: the measurement runner, once per
execution, and `scripts/reset_lib.sh`, by hand. They were written separately and drifted:
the hand copy rewrote `import 'base.dart';` unconditionally, which corrupts an arm-2 fixture
that happens to carry that string in a comment -- the exact case `runner.assemble` grew
`is_part_file` to guard. A second copy of a rewrite rule is a second answer to "what does
staging mean", so there is now one.

Deliberately path-explicit and free of `device_runner.config`: `reset_lib.sh` stages into a
`lib/` it resolves itself, and importing the runner's configuration would pull the device
environment into a tool that never touches a device.
"""

from __future__ import annotations

import os
from pathlib import Path

# Arm 1's fixture is a library that imports the active role by name. Arm 2's is
# `part of generated_widget;`, which has no import to rewrite.
BASE_IMPORT = "import 'base.dart';"
STAGED_IMPORT = "import 'generated_widget.dart';"
PART_DIRECTIVE = "part 'dependencies.dart';"


def is_part_file(text: str) -> bool:
    """True when a fixture is `part of <library>;` rather than a library of its own.

    Read off directives, not a substring search: `part of` inside a comment or a string
    must not count. Directives precede all declarations, so the first non-trivial line
    that is not a comment or an `ignore_for_file` pragma settles it.
    """
    for line in text.splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("//") or stripped.startswith("/*"):
            continue
        return stripped.startswith("part of")
    return False


def declares_part(text: str) -> bool:
    """True when a role pulls the group fixture in as `part 'dependencies.dart';`.

    Read off directives for the same reason `is_part_file` is: the string can appear in a
    comment. Directives precede all declarations, so the scan stops at the first one.
    """
    for line in text.splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("//") or stripped.startswith("/*"):
            continue
        if stripped.startswith(PART_DIRECTIVE):
            return True
        if not (stripped.startswith("library ") or stripped.startswith("import ")
                or stripped.startswith("export ") or stripped.startswith("part ")
                or stripped.startswith("@")):
            return False          # past the directives; there is no part to find
    return False


def stage_deps(text: str) -> str:
    """A fixture's text as it should sit in `lib/dependencies.dart`.

    Rewriting a part file would be a no-op today -- it has no imports -- but the guard keeps
    a fixture that happens to contain that string in a comment from being corrupted.
    """
    if is_part_file(text):
        return text
    return text.replace(BASE_IMPORT, STAGED_IMPORT)


def write_transplant(
    widget_src: Path, deps_src: Path | None, widget_dst: Path, deps_dst: Path
) -> bool:
    """Transplant a role and its fixture into the active slot so the app compiles.

    `widget_src` -> `widget_dst` verbatim; `deps_src` -> `deps_dst` through `stage_deps`.
    A `deps_src` of None stages the role alone, which is what a group with no fixture wants.
    Returns whether the fixture was staged.

    A role whose split hoisted nothing keeps neither directive -- see
    `dart_tools/lib/src/fixture.dart`, `if (hoisted.isEmpty)` -- while its SIBLINGS in the
    same group may hoist plenty, so the group still ships a `part of generated_widget;`
    fixture. Staging that fixture beside such a role leaves it an orphan part and `flutter
    analyze` fails on the fixture before the app is ever built: that is what cost group 0344
    a measurement session on 2026-09-09. It hoisted nothing, so it references nothing the
    fixture declares, and staging it alone mounts exactly the file whose feature vector is on
    record. The `unlink` is load-bearing: `assemble` runs once per execution and the previous
    role's fixture is still sitting in `lib/`.
    """
    widget_text = widget_src.read_text(encoding="utf-8")
    widget_dst.write_text(widget_text, encoding="utf-8")
    staged = False
    if deps_src is not None:
        deps_text = deps_src.read_text(encoding="utf-8")
        if is_part_file(deps_text) and not declares_part(widget_text):
            deps_dst.unlink(missing_ok=True)
        else:
            deps_dst.write_text(stage_deps(deps_text), encoding="utf-8")
            staged = True
    os.utime(widget_dst, None)  # bust build caches
    return staged
