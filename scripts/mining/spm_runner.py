"""One place that knows how to run `spm analyze` and read what it says.

Three facts about the extractor drive this module, each established by reading
its source rather than assumed:

1. **It resolves, it does not merely parse.** It builds an
   `AnalysisContextCollection` and skips any scanned file carrying an
   error-severity diagnostic, because unresolved types make every widget
   classify as a value object. That skip is a first-class result
   (`files_skipped`), not an error to swallow.

2. **The skip guards only the file being scanned.** A scope's metrics are
   computed from a transitive closure - helpers resolved across libraries, and
   every custom child widget's `build()` merged in. A closure file that will not
   resolve makes the row WRONG rather than absent. `closureResolved` /
   `unresolvedDependencies` on each row are what make that visible, and a row
   without them cannot be trusted for a delta.

3. **The analysis root is the path you pass, not the enclosing package.**
   Pointing it at `<repo>/lib/x` reports `filePath: y.dart`; pointing it at
   `<repo>` reports `lib/x/y.dart`. `instanceId` is hashed from that same
   relative path, so it is NOT stable across invocations with different roots and
   is never used as a key. Identity here is
   `(project, source_file_relative, scope_name)`, which this package controls.

This runs the container's own dependency, `spm: ^0.6.0` from pub.dev, via
`dart run spm:spm` with cwd=PROJECT_ROOT - the same build every other module
here uses. Rows produced under it are not comparable to the measured corpus
until that corpus is re-extracted with the same build; see `config` for what
0.5.0, 0.5.2 and 0.6.0 each changed.
"""

from __future__ import annotations

import json
import subprocess
import tempfile
from dataclasses import dataclass, field
from pathlib import Path

from .. import spm
from . import config

# The summary line's shape belongs to the extractor, not to this package.
_SUMMARY = spm.SUMMARY


@dataclass
class AnalyzeResult:
    """What one `spm analyze` invocation produced, including what it refused to read."""

    ok: bool
    rows: list[dict] = field(default_factory=list)
    files_scanned: int = 0
    files_skipped: int = 0
    scopes_found: int = 0
    stderr: str = ""
    command: list[str] = field(default_factory=list)

    @property
    def resolution_clean(self) -> bool:
        """True when every scanned file resolved. False means rows are simply absent."""
        return self.ok and self.files_skipped == 0

    @property
    def rows_with_complete_closure(self) -> list[dict]:
        """Rows whose every dependency was read. The only rows a delta may use."""
        return [r for r in self.rows if r.get("closureResolved", 0) == 1]

    @property
    def rows_with_broken_closure(self) -> list[dict]:
        """Rows short by an unknown amount - kept, because dropping them silently
        would make 'no edit here' and 'could not read this' indistinguishable."""
        return [r for r in self.rows if r.get("closureResolved", 0) != 1]


def analyze(paths: list[Path], output: Path | None = None) -> AnalyzeResult:
    """Run `spm analyze` over `paths` and read the JSONL it writes.

    Every rebuild scope type, never `--scope-types`: upstream, the same scope may
    be a State subclass, a BlocBuilder callback or an Obx, and narrowing here
    would silently decide which kinds of human edit are visible.
    """
    temporary = output is None
    if temporary:
        handle = tempfile.NamedTemporaryFile(
            suffix=".jsonl", delete=False, prefix="mining_"
        )
        handle.close()
        output = Path(handle.name)

    command = [*config.SPM_ENTRY, "analyze", "-o", str(output), *[str(p) for p in paths]]
    try:
        done = subprocess.run(
            command,
            capture_output=True,
            text=True,
            timeout=config.SPM_TIMEOUT_S,
            cwd=str(config.SPM_CWD),
        )
    except subprocess.TimeoutExpired:
        return AnalyzeResult(
            ok=False, stderr=f"timed out after {config.SPM_TIMEOUT_S}s", command=command
        )

    combined = done.stdout + done.stderr
    result = AnalyzeResult(ok=done.returncode == 0, command=command, stderr=combined[-2000:])

    if summary := spm.parse_summary(combined):
        result.files_scanned = summary["scanned"]
        result.files_skipped = summary["skipped"]
        result.scopes_found = summary["scopes"]

    if output.is_file():
        for line in output.read_text().splitlines():
            if line.strip():
                try:
                    result.rows.append(json.loads(line))
                except json.JSONDecodeError:
                    pass
        if temporary:
            output.unlink(missing_ok=True)

    return result

