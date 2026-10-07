"""One module owns how the extractor is invoked, and every argv it builds is unchanged.

Five modules used to state independently that `spm` is `dart run spm:spm` from PROJECT_ROOT.
The cwd is what selects the build -- `pubspec.yaml` pins it (0.7.2 from pub.dev) -- so
that statement decides which emitter produced every row in the corpus.

The literals below are what each call site emitted BEFORE `scripts/spm.py` existed. They are
written out in full rather than derived, because deriving them from the thing under test
would assert nothing: a refactor that changed the command would change both sides together.
"""

from __future__ import annotations

import re
from pathlib import Path

from scripts import extract_features, spm
from scripts.paths import PROJECT_ROOT
from scripts.mining import config as corpus_config
from scripts.device_runner import config as runner_config


def test_the_entry_and_cwd_are_what_they_were():
    assert spm.ENTRY == ["dart", "run", "spm:spm"]
    assert spm.CWD == PROJECT_ROOT
    assert spm.entry("isolate") == ["dart", "run", "spm:spm", "isolate"]


def test_extract_features_argv_is_unchanged():
    assert extract_features.analyze_cmd(Path("/repo"), Path("/out.jsonl")) == [
        "dart", "run", "spm:spm", "analyze",
        "--scope-types", "State",
        "--output", "/out.jsonl",
        "/repo",
    ]


def test_device_runner_analyze_argv_is_unchanged():
    """The two `analyze` builders were byte-identical, which is why they now share one."""
    assert runner_config.spm_analyze_cmd(["/a", "/b"], "/out.jsonl") == [
        "dart", "run", "spm:spm", "analyze",
        "--scope-types", "State",
        "--output", "/out.jsonl",
        "/a", "/b",
    ]


def test_device_runner_run_argv_still_starts_the_same_way():
    cmd = runner_config.spm_run_cmd("/capture.jsonl")
    assert cmd[:5] == ["dart", "run", "spm:spm", "run", "--jsonl"]
    assert "--no-dds" in cmd


def test_mining_still_reaches_entry_and_cwd_through_its_own_config():
    """Every phase in that package reads `config.SPM_ENTRY`; the names had to survive."""
    assert corpus_config.SPM_ENTRY == ["dart", "run", "spm:spm"]
    assert corpus_config.SPM_CWD == spm.CWD


def test_mining_analyze_is_deliberately_not_pinned_to_state():
    """The one difference that must NOT be unified.

    Upstream, one scope may be a State subclass, a BlocBuilder callback or an Obx. Narrowing
    `mining` to State would silently decide which kinds of human edit are visible, so it
    keeps its own argv and takes only the entry from `spm`.
    """
    import inspect

    from scripts.mining import spm_runner

    # The argv line only: the docstring says "never `--scope-types`", which would match.
    argv_line = next(l for l in inspect.getsource(spm_runner.analyze).splitlines()
                     if l.strip().startswith("command = ["))
    assert "--scope-types" not in argv_line
    assert "SPM_ENTRY" in argv_line
    assert '"analyze"' in argv_line


def test_the_summary_line_is_parsed_in_one_place():
    line = ("[spm]: Scanned 12 files (3 skipped with compile errors); "
            "found 7 rebuild scopes (State: 5, BlocBuilder: 2); kept 5 rows.")
    assert spm.parse_summary(line) == {"scanned": 12, "skipped": 3, "scopes": 7}
    assert spm.parse_summary("nothing to see here") is None


def test_version_names_the_build_and_says_how_pinned_it_is():
    """A path dependency has no sha256, and a record that reads `path:` is a record whose
    build is only as pinned as the branch that checkout was on. Saying so is the point."""
    v = spm.version()
    assert re.match(r"^\d+\.\d+\.\d+ \((path|hosted): ", v) or v == "unknown", v


def test_the_screening_record_names_the_extractor_build():
    from scripts.screen.checkpoints import ScreenRun, provenance
    from scripts.tests.test_screen_run import MODE, _args

    out = provenance(MODE, ScreenRun.from_args(_args()), argv=[])
    assert out["spm_build"] == spm.version()
    assert out["spm_build"] != ""
