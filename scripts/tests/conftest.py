"""Test-suite wiring.

`scripts/` is a namespace package with no `__init__.py`, and every documented invocation is
`python3 -m scripts.<name>` from the repository root. pytest would otherwise put
`scripts/tests/` on `sys.path` and `import scripts.screen_samples` would fail, so the
container root goes on the path here instead of the layout being changed to suit the tests.
"""

from __future__ import annotations

import sys
from pathlib import Path

import pytest

CONTAINER = Path(__file__).resolve().parents[2]
if str(CONTAINER) not in sys.path:
    sys.path.insert(0, str(CONTAINER))


def pytest_configure(config):
    config.addinivalue_line(
        "markers",
        "slow: screens the real corpus; needs probe_v2/ and the Dart toolchain")
    config.addinivalue_line(
        "markers", "dart: shells out to scripts/dart_tools")


def pytest_collection_modifyitems(config, items):
    """`slow` is opt-in: `-m slow` runs it, a bare run does not.

    Deselecting rather than requiring a flag, because the guard only earns its two and a half
    minutes when something structural changed -- and a suite nobody runs because it is slow
    guards nothing. An explicit `-m` on the command line always wins.
    """
    if config.getoption("-m"):
        return
    deselected = pytest.mark.skip(reason="slow; run with -m slow")
    for item in items:
        if "slow" in item.keywords:
            item.add_marker(deselected)


@pytest.fixture(scope="session")
def container() -> Path:
    """The repository root, the directory every documented invocation runs from."""
    return CONTAINER
