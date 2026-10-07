"""The extractor, as one module: how it is invoked, from where, and WHICH BUILD.

`spm` is a Dart package run only as a subprocess, and the cwd is what selects the build --
`pubspec.yaml` pins it (0.7.2 from pub.dev; `../spm-publish` by path while the data were
collected), so `dart run spm:spm` from PROJECT_ROOT is the only thing that pins which emitter
produced a row. Five modules used to state that
independently: two built byte-identical `analyze` argv, `mining` kept its own ENTRY/CWD
constants, and `mutation.gate` and `mining.isolate` each assembled their own list. Same
shape as `ast_tools.py` on the Dart-tooling side, and for the same reason -- this module owns
the subprocess and makes no decision about what the output means.

WHAT THIS DOES NOT UNIFY, DELIBERATELY
--------------------------------------
The callers do not all run the same command, and collapsing them would be a methodology
change wearing a refactor's clothes:

  * `analyze_state_cmd` pins `--scope-types State`. `extract_features` and `device_runner`
    both measure the transplanted `_GeneratedWidgetState` and nothing else, and their two
    copies were identical, so they share one builder.
  * `mining.spm_runner` passes NO `--scope-types`, on purpose: upstream, one scope may be
    a State subclass, a BlocBuilder callback or an Obx, and narrowing there would silently
    decide which kinds of human edit are visible. It gets `entry()`, `CWD` and
    `parse_summary` from here and keeps its own argv.
  * `run`, `isolate` and `validate` each carry knobs only their caller has. They take
    `entry()` and stop there. A universal `run()` would be a twelve-parameter interface,
    which is the shallow module this refactor exists to avoid.

WHY `version()` EXISTS
----------------------
A path dependency records no sha256 -- `pubspec.lock` says `source: path` and a version, and
follows whatever branch the checkout is on. 0.7.0 and 0.7.1 are different transplant
emitters, and a standing rule of this project is that their rows must never be pooled. Until
now nothing in any output said which build wrote it. This reads the identity out of the lock
so callers can stamp it into their records, exactly as `ast_tools.rules_version()` stamps the
Dart rule vocabulary into every screening checkpoint.
"""

from __future__ import annotations

import functools
import re

from .paths import PROJECT_ROOT

# The cwd `dart run spm:spm` resolves the package from -- which, with a path dependency, is
# what pins the build. Never anything else.
CWD = PROJECT_ROOT
ENTRY = ["dart", "run", "spm:spm"]

# This corpus measures the transplanted `_GeneratedWidgetState` and nothing else. 0.3.0 emits
# a row for EVERY rebuild scope by default -- nested Obx/Selector/BlocBuilder callbacks
# alongside the root State -- and those rows' metrics deliberately overlap the enclosing
# State's, so the analyzer is pinned. This is also exactly the pre-0.3.0 output shape.
STATE_SCOPE_TYPE = "State"

# "[spm]: Scanned 5 files (0 skipped with compile errors); found 3 rebuild scopes
#  (State: 2, BlocBuilder: 1); kept 2 rows."
SUMMARY = re.compile(
    r"Scanned\s+(?P<scanned>\d+)\s+files?\s+\((?P<skipped>\d+)\s+skipped[^)]*\);"
    r"\s+found\s+(?P<scopes>\d+)\s+rebuild scopes?"
)

LOCK = PROJECT_ROOT / "pubspec.lock"


def entry(subcommand: str) -> list[str]:
    """`dart run spm:spm <subcommand>`. Run it with `cwd=CWD` and nothing else."""
    return [*ENTRY, subcommand]


def analyze_state_cmd(paths, output) -> list[str]:
    """`spm analyze` over `paths`, pinned to State scopes, writing `output`.

    NOTE on the analysis root: it is the path you pass, not the enclosing package. Passing
    `samples/` yields `01/base.dart`; passing the repo root yields `samples/01/base.dart`.
    `instanceId` is hashed from that same relative path, so the root also decides the id --
    callers must key off the path TAIL and must never assume an id extracted under one root
    matches one extracted under another.
    """
    return [*entry("analyze"), "--scope-types", STATE_SCOPE_TYPE,
            "--output", str(output), *[str(p) for p in paths]]


def parse_summary(text: str) -> dict[str, int] | None:
    """`{scanned, skipped, scopes}` from spm's own summary line, or None if it is absent.

    `skipped` is a first-class result, not noise to swallow: `spm analyze` skips any file
    carrying an error-severity diagnostic, because unresolved types make every widget
    classify as a value object.
    """
    m = SUMMARY.search(text)
    if not m:
        return None
    return {"scanned": int(m["scanned"]), "skipped": int(m["skipped"]),
            "scopes": int(m["scopes"])}


@functools.cache
def version() -> str:
    """Which build of the extractor this checkout runs, read from `pubspec.lock`.

    Returned as a single string for a record to carry, in one of two shapes:

        "0.7.1 (path: ../spm-publish)"      -- no sha256 exists; the checkout is the identity
        "0.7.0 (hosted: sha256:ee65...)"    -- pinned and verifiable

    A path dependency genuinely has no stronger identity than this, and saying so is the
    point: a record that reads `path:` is a record whose build is only as pinned as the
    branch that checkout was on. `"unknown"` when the lock cannot be read, which is a state a
    record should be able to show rather than one that should stop a run.
    """
    try:
        lines = LOCK.read_text(encoding="utf-8").splitlines()
    except OSError:
        return "unknown"

    inside, source, sha, ver, path = False, None, None, None, None
    for line in lines:
        if re.match(r"^  \S+:\s*$", line):
            inside = line.strip() == "spm:"
            continue
        if not inside:
            continue
        if m := re.match(r'^\s*version:\s*"?([^"]+)"?\s*$', line):
            ver = m.group(1)
        elif m := re.match(r'^\s*source:\s*(\S+)\s*$', line):
            source = m.group(1)
        elif m := re.match(r'^\s*sha256:\s*"?([0-9a-f]+)"?\s*$', line):
            sha = m.group(1)
        elif m := re.match(r'^\s*path:\s*"?([^"]+)"?\s*$', line):
            path = m.group(1)

    if ver is None:
        return "unknown"
    if source == "path":
        return f"{ver} (path: {path or '?'})"
    if sha:
        return f"{ver} (hosted: sha256:{sha[:12]})"
    return f"{ver} ({source or 'unknown source'})"
