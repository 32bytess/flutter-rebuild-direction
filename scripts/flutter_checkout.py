"""Make a Flutter checkout resolve, so `spm analyze` can actually read it.

`spm analyze` skips any file carrying an error-severity diagnostic, on purpose: unresolved
types would make every widget classify as a value object and the row become near-zero garbage.
So resolution is not a nice-to-have, it is the entry condition for any mined checkout.

Three distinct causes, and these helpers address each:

  1. **No packages.** A clone's `.dart_tool/package_config.json` is a stale artifact of the
     mining run that produced it. `flutter pub get` restores it.
  2. **Version solving fails.** Old apps against the installed SDK. pub itself prints the fix
     ("Try upgrading your constraint on intl: flutter pub add intl:^0.20.2"); `pub_get` parses
     that suggestion, applies it as a `dependency_overrides` entry and retries. Overrides are
     returned so the caller can record them -- they change what the analyzer sees, and that is
     a caveat the yield inherits, not a detail to bury.
  3. **Missing generated code.** A freezed-based project that gitignores its `*.freezed.dart` /
     `*.g.dart` has undefined symbols until `build_runner` has run.

Extracted from `history_probe/prepare.py`, which is where these were written and which still
uses them; `mining/prepare.py` imports them too, and that shared use is why they live here
rather than inside either caller.
"""

from __future__ import annotations

import re
import subprocess
from pathlib import Path

# pub prints its own fix for a version conflict. Capturing it is what lets this work for a
# repository nobody has looked at, instead of a hardcoded list of known-bad pins.
PUB_SUGGESTION = re.compile(
    r"(?:flutter|dart)\s+pub\s+add\s+(?P<package>[a-zA-Z0-9_]+):(?P<constraint>\S+)"
)

# Packages whose presence means the project cannot resolve until codegen has run.
CODEGEN_MARKERS = ("freezed", "json_serializable", "injectable", "auto_route", "retrofit")

MAX_OVERRIDE_ROUNDS = 6

# The block `apply_overrides` writes is delimited by this marker, and a rewrite finds the old
# block by searching for it. It still says `history_probe` because checkouts on disk carry that
# text: renaming it would leave every existing override block unrecognised and so unremoved.
OVERRIDE_MARKER = "\n# --- history_probe overrides ---\n"


def run_command(
    command: list[str], cwd: Path, timeout: int = 1800
) -> tuple[bool, str]:
    try:
        completed = subprocess.run(
            command, cwd=str(cwd), capture_output=True, text=True, timeout=timeout
        )
    except subprocess.TimeoutExpired:
        return False, f"timed out after {timeout}s: {' '.join(command)}"
    return completed.returncode == 0, (completed.stdout + completed.stderr)


def read_pubspec(root: Path) -> str:
    path = root / "pubspec.yaml"
    return path.read_text() if path.is_file() else ""


def apply_overrides(root: Path, overrides: dict[str, str]) -> None:
    """Rewrite `dependency_overrides` in pubspec.yaml with the accumulated pins.

    Text manipulation rather than a YAML round-trip on purpose: these pubspecs carry comments
    and ordering that a reformatting writer would churn, and the diff has to stay readable for
    anyone auditing what was changed.
    """
    path = root / "pubspec.yaml"
    text = path.read_text()
    block = "dependency_overrides:\n" + "".join(
        f"  {name}: {constraint}\n" for name, constraint in sorted(overrides.items())
    )

    if OVERRIDE_MARKER in text:
        text = text[: text.index(OVERRIDE_MARKER)]
    path.write_text(text.rstrip("\n") + "\n" + OVERRIDE_MARKER + block)


def pub_get(root: Path) -> dict:
    """`flutter pub get`, retrying with the overrides pub itself asks for."""
    overrides: dict[str, str] = {}
    attempts = []

    for attempt in range(MAX_OVERRIDE_ROUNDS):
        ok, output = run_command(["flutter", "pub", "get"], root)
        attempts.append({
            "attempt": attempt,
            "ok": ok,
            "overrides_applied": dict(overrides),
            "tail": output[-600:] if not ok else "",
        })
        if ok:
            return {"ok": True, "overrides": overrides, "attempts": attempts}

        suggestions = {
            match["package"]: match["constraint"]
            for match in PUB_SUGGESTION.finditer(output)
        }
        # Only accept suggestions that add something new, or the retry loops forever.
        new = {p: c for p, c in suggestions.items() if overrides.get(p) != c}
        if not new:
            return {"ok": False, "overrides": overrides, "attempts": attempts}
        overrides.update(new)
        apply_overrides(root, overrides)

    return {"ok": False, "overrides": overrides, "attempts": attempts}


def needs_codegen(root: Path) -> bool:
    pubspec = read_pubspec(root)
    return "build_runner" in pubspec and any(m in pubspec for m in CODEGEN_MARKERS)


def build_runner(root: Path, timeout: int = 2400) -> dict:
    ok, output = run_command(
        ["dart", "run", "build_runner", "build", "--delete-conflicting-outputs"],
        root,
        timeout=timeout,
    )
    generated = len(list(root.glob("lib/**/*.g.dart"))) + len(
        list(root.glob("lib/**/*.freezed.dart"))
    )
    return {"ran": True, "ok": ok, "generated_files": generated, "tail": output[-600:]}
