"""Where the repository is. One definition, imported rather than recomputed.

Eleven live modules used to answer this question independently, and they answered it four
different ways: `parents[2]` in `mining/config.py`, `device_runner/config.py`,
`screen/fixtures.py`, `screen/manifests.py`, `screen/licenses.py` and `collector/config.py`;
`parent.parent` in `fixture_values.py` and `maximal_branch.py`; `parents[1]` in
`screen_samples.py` and `extract_features.py`; and a marker-file walk in
`record_source_commits.py`, which is where the approach used here was written.

They all agreed, and the agreement was a coincidence of directory depth. A count of parents
is not a statement about the repository, it is a statement about how deep the file that asks
happens to sit, so every one of those constants becomes silently wrong the moment its module
moves a level -- which is exactly what the `screen/` extraction did to three of them, and
what any further extraction would do again. A marker makes depth stop mattering.

WHY THREE MARKERS
-----------------
`pubspec.yaml` alone is not enough: `scripts/dart_tools/` is its own Dart package and has
one, so a module underneath it would stop there and call that directory the repository. The
mined checkouts under `../new_data/` each have one too, and some of them also have a
`scripts/` directory of their own. `analysis/` is the discriminator -- it is this
repository's results directory and no Flutter application has one. All three are tracked, so
a fresh clone satisfies them before anything has been built or run.

WHAT THIS DOES NOT FIX
----------------------
It does not make the tree relocatable, and nothing here should be read as claiming it does.
`ACADEMIC_ROOT` is the container's parent by definition and `mining.config.REPOS_ROOT`
resolves 2.4 GB of clones beneath it, so moving the container without moving `new_data/`
alongside it breaks the mine exactly as it did before. What is fixed is narrower and worth
having on its own: a module can move within the repository without acquiring a different
root, and a wrong root now raises where it used to resolve to some ancestor directory and
carry on.

The marker walk itself is `record_source_commits.py`'s, generalised: it was the one module
that already refused to count parents, for the same reason given here. It now imports this
one, which costs it the ability to be run as a bare path -- its docstring records the
module form.
"""

from __future__ import annotations

from pathlib import Path

# Jointly unique to the repository root, and all three are tracked.
MARKERS = ("pubspec.yaml", "scripts", "analysis")


def find_project_root(start: Path | None = None) -> Path:
    """The repository root, by walking up from `start` (default: this file's directory).

    Raises rather than falling back to a guess. A missing root means the module was imported
    from outside the tree, and a plausible-looking wrong answer is how a run reads the wrong
    corpus -- the failure this module exists to make impossible.
    """
    origin = Path(start).resolve() if start is not None else Path(__file__).resolve()
    first = origin if origin.is_dir() else origin.parent
    for candidate in (first, *first.parents):
        if all((candidate / marker).exists() for marker in MARKERS):
            return candidate
    raise FileNotFoundError(
        f"could not locate the repository root above {origin}: no ancestor directory holds "
        f"all of {', '.join(MARKERS)}"
    )


PROJECT_ROOT = find_project_root()
ACADEMIC_ROOT = PROJECT_ROOT.parent


def rel(path: Path) -> str:
    """`path` relative to the container, or absolute when it is outside it. Never raises.

    For messages only. A path outside PROJECT_ROOT is exactly the stale-path or
    environment-override case these messages exist to report, so letting `relative_to` throw
    would replace a useful error with a confusing one -- and in `screen.rebuild.teardown` it
    threw AFTER the corpus had already been removed.
    """
    try:
        return str(path.relative_to(PROJECT_ROOT))
    except ValueError:
        return str(path)
