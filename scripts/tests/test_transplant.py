"""Staging a role into `lib/` -- the rule two tools used to answer differently.

`scripts/reset_lib.sh` rewrote `import 'base.dart';` unconditionally; `runner.assemble`
guarded the rewrite behind a part-file check. An arm-2 fixture carrying that string in a
comment was corrupted by one and left alone by the other. These tests pin the guard, so a
future third caller cannot quietly reintroduce the unguarded form.
"""

from __future__ import annotations

import pytest

from scripts.device_runner import transplant


LIBRARY_FIXTURE = """// dependencies for the staged role
import 'base.dart';

class Dep {}
"""

PART_FIXTURE = """// arm 2 fixture
part of generated_widget;

class Dep {}
"""

# The case that made the two copies disagree: a part file that merely MENTIONS the import.
PART_MENTIONING_IMPORT = """// historical note: this used to say import 'base.dart';
part of generated_widget;

class Dep {}
"""


@pytest.mark.parametrize(
    "text, expected",
    [
        (LIBRARY_FIXTURE, False),
        (PART_FIXTURE, True),
        (PART_MENTIONING_IMPORT, True),
        ("", False),
        ("/* block comment first */\npart of generated_widget;", True),
    ],
)
def test_is_part_file_reads_directives_not_substrings(text, expected):
    assert transplant.is_part_file(text) is expected


def test_a_library_fixture_has_its_import_retargeted():
    assert transplant.stage_deps(LIBRARY_FIXTURE) == LIBRARY_FIXTURE.replace(
        transplant.BASE_IMPORT, transplant.STAGED_IMPORT
    )


def test_a_part_file_is_left_byte_for_byte_alone():
    """The defect the hand copy carried: this used to come back rewritten."""
    assert transplant.stage_deps(PART_MENTIONING_IMPORT) == PART_MENTIONING_IMPORT
    assert transplant.stage_deps(PART_FIXTURE) == PART_FIXTURE


def test_write_transplant_stages_both_files(tmp_path):
    src = tmp_path / "src"
    src.mkdir()
    (src / "base.dart").write_text("class GeneratedWidget {}\n", encoding="utf-8")
    (src / "dependencies.dart").write_text(LIBRARY_FIXTURE, encoding="utf-8")
    lib = tmp_path / "lib"
    lib.mkdir()

    transplant.write_transplant(
        src / "base.dart",
        src / "dependencies.dart",
        lib / "generated_widget.dart",
        lib / "dependencies.dart",
    )

    assert (lib / "generated_widget.dart").read_text() == "class GeneratedWidget {}\n"
    assert transplant.STAGED_IMPORT in (lib / "dependencies.dart").read_text()


def test_a_group_with_no_fixture_stages_the_role_alone(tmp_path):
    src = tmp_path / "src"
    src.mkdir()
    (src / "base.dart").write_text("class GeneratedWidget {}\n", encoding="utf-8")
    lib = tmp_path / "lib"
    lib.mkdir()

    transplant.write_transplant(
        src / "base.dart", None, lib / "generated_widget.dart", lib / "dependencies.dart"
    )

    assert (lib / "generated_widget.dart").is_file()
    assert not (lib / "dependencies.dart").exists()


# ---- the orphan `part` -----------------------------------------------------------------
# A role whose split hoisted nothing keeps neither `library generated_widget;` nor
# `part 'dependencies.dart';` (dart_tools/lib/src/fixture.dart, `if (hoisted.isEmpty)`), but
# its siblings may hoist plenty, so the GROUP still ships a part-file fixture. Staging that
# fixture beside this role orphans the part and `flutter analyze` fails on it -- which is
# what cost group 0344 a measurement session on 2026-09-09.
ORPHAN_ROLE = """import 'package:flutter/material.dart';

class GeneratedWidget extends StatefulWidget {
  const GeneratedWidget({super.key});
}
"""

PART_ROLE = """// ignore_for_file: unused_import, unused_element, unused_field
library generated_widget;

import 'package:flutter/material.dart';
part 'dependencies.dart';

class GeneratedWidget extends StatefulWidget {
  const GeneratedWidget({super.key});
}
"""

# The mirror of PART_MENTIONING_IMPORT, from the role's side.
ROLE_MENTIONING_PART = """// this group's siblings carry part 'dependencies.dart';
import 'package:flutter/material.dart';

class GeneratedWidget extends StatefulWidget {}
"""


@pytest.mark.parametrize(
    "text, expected",
    [
        (PART_ROLE, True),
        (ORPHAN_ROLE, False),
        (ROLE_MENTIONING_PART, False),
        ("", False),
    ],
)
def test_declares_part_reads_directives_not_substrings(text, expected):
    assert transplant.declares_part(text) is expected


def _stage(tmp_path, role_text, fixture_text):
    src = tmp_path / "src"
    src.mkdir(exist_ok=True)
    (src / "role.dart").write_text(role_text, encoding="utf-8")
    (src / "dependencies.dart").write_text(fixture_text, encoding="utf-8")
    lib = tmp_path / "lib"
    lib.mkdir(exist_ok=True)
    staged = transplant.write_transplant(
        src / "role.dart", src / "dependencies.dart",
        lib / "generated_widget.dart", lib / "dependencies.dart",
    )
    return staged, lib


def test_a_role_that_declares_no_part_does_not_get_the_part_fixture(tmp_path):
    staged, lib = _stage(tmp_path, ORPHAN_ROLE, PART_FIXTURE)
    assert staged is False
    assert (lib / "generated_widget.dart").read_text() == ORPHAN_ROLE
    assert not (lib / "dependencies.dart").exists()


def test_a_role_that_declares_the_part_still_gets_the_fixture(tmp_path):
    staged, lib = _stage(tmp_path, PART_ROLE, PART_FIXTURE)
    assert staged is True
    assert (lib / "dependencies.dart").read_text() == PART_FIXTURE


def test_the_previous_roles_fixture_is_removed_not_left_behind(tmp_path):
    """`assemble` runs once per execution; `restore_active` only cleans up at the end. A
    fixture left by the previous role would orphan itself against this one."""
    _stage(tmp_path, PART_ROLE, PART_FIXTURE)
    assert (tmp_path / "lib" / "dependencies.dart").is_file()
    staged, lib = _stage(tmp_path, ORPHAN_ROLE, PART_FIXTURE)
    assert staged is False
    assert not (lib / "dependencies.dart").exists()


def test_an_arm_1_library_fixture_is_staged_for_a_role_with_no_part(tmp_path):
    """The guard is scoped to PART files: arm 1's fixture is a library of its own and the
    role never declares a part for it, so it must still be staged and retargeted."""
    staged, lib = _stage(tmp_path, ORPHAN_ROLE, LIBRARY_FIXTURE)
    assert staged is True
    assert transplant.STAGED_IMPORT in (lib / "dependencies.dart").read_text()
