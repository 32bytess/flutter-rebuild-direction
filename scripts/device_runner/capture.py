"""One definition of "this execution is done" — shared by the runner, `status`, and `telemetry`.

Every measured execution writes `raw/<session>/<role>/e<k>.log` whose first line is a header
emitted by `runner.py::phase2_measure`:

    # sample_id=01/mutation_1 exec_index=1 ok=True perf_lines=30 vm_events=30 battery_pct=84
      soc_temp_millic=39500 battery_temp_c=30.8 charging=False
      preflight_started=... started=... ts=2026-07-28T03:27:10.650050+00:00

The header is written AFTER `spm run` returns, so its presence is the completion marker; the
sibling `e<k>.jsonl` is created by `spm run` mid-flight and must never be used as one.

Two header generations exist in the committed corpus and both must parse:

  * legacy (all earlier pilot-phone captures, and redmi9t before this change) — no `vm_events=`, no `preflight_started=`
    / `started=`. Completeness falls back to `perf_lines` alone and the run window has to be
    reconstructed (see `telemetry.py`).
  * current — every field present, so the run window is exact on the host clock.

Resume hinges on this module: `raw_path.exists()` alone treats a crashed or empty capture as
done, which is how executions with `ok=False` / `perf_lines=0` ended up permanently missing
from the corpus instead of being retried.
"""
from __future__ import annotations

import re
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path

from . import config

# Fields are matched individually rather than as one fixed sequence: the legacy headers omit
# some of them, and a positional regex would silently fail to match instead of degrading.
_FIELD = re.compile(r"(?P<key>[a-z_]+)=(?P<val>\S+)")


@dataclass
class Header:
    """Parsed `e<k>.log` header. Missing legacy fields stay None rather than being guessed."""

    sample_id: str
    exec_index: int
    ok: bool
    perf_lines: int
    vm_events: int | None = None
    battery_pct: int | None = None
    soc_temp_millic: int | None = None
    battery_temp_c: float | None = None
    charging: bool | None = None
    preflight_started: datetime | None = None
    started: datetime | None = None
    ended: datetime | None = None

    @property
    def group(self) -> str:
        return self.sample_id.partition("/")[0]

    @property
    def role(self) -> str:
        return self.sample_id.partition("/")[2]

    @property
    def n_captured(self) -> int:
        """Rebuilds actually captured. The VM stream leads; stdout is the fallback, because
        stdout can truncate on process teardown while the VM stream is intact."""
        return max(self.perf_lines, self.vm_events or 0)

    @property
    def complete(self) -> bool:
        return self.ok and self.n_captured >= config.N_REBUILDS


def _as_dt(raw: str) -> datetime | None:
    try:
        return datetime.fromisoformat(raw)
    except ValueError:
        return None


def parse_header(text: str) -> Header | None:
    """Parse the first `# ...` line of a capture log. None if it carries no usable header."""
    line = next((l for l in text.splitlines() if l.startswith("#") and "sample_id=" in l), None)
    if line is None:
        return None
    f = {m["key"]: m["val"] for m in _FIELD.finditer(line)}
    if "sample_id" not in f or "exec_index" not in f:
        return None

    def _int(key: str) -> int | None:
        v = f.get(key, "")
        return int(v) if v.lstrip("-").isdigit() else None

    def _float(key: str) -> float | None:
        try:
            return float(f[key])
        except (KeyError, ValueError):
            return None

    return Header(
        sample_id=f["sample_id"],
        exec_index=int(f["exec_index"]),
        ok=f.get("ok") == "True",
        perf_lines=_int("perf_lines") or 0,
        vm_events=_int("vm_events"),
        battery_pct=_int("battery_pct"),
        soc_temp_millic=_int("soc_temp_millic"),
        battery_temp_c=_float("battery_temp_c"),
        charging={"True": True, "False": False}.get(f.get("charging", "")),
        preflight_started=_as_dt(f.get("preflight_started", "")),
        started=_as_dt(f.get("started", "")),
        # `ts` is the end-of-execution stamp; it predates `started=` and keeps its name so
        # analysis/exclude_failed_runs.py's regex keeps matching.
        ended=_as_dt(f.get("ts", "")),
    )


def read_header(log_path: Path) -> Header | None:
    try:
        return parse_header(log_path.read_text(errors="replace"))
    except OSError:
        return None


def capture_complete(log_path: Path) -> bool:
    """True only for a capture worth keeping: header present, ok=True, full rebuild count.

    A log that exists but fails this is a crashed or truncated attempt — the caller should
    discard it and re-measure, which is what makes a resumed session fill in missing values
    rather than inherit them.
    """
    h = read_header(log_path)
    return h is not None and h.complete


def session_progress(group: str, session: str) -> tuple[int, int]:
    """(complete, present) executions in one session dir of a group, for the resume banner."""
    root = config.raw_dir(group) / session
    if not root.exists():
        return 0, 0
    logs = sorted(root.rglob("e*.log"))
    return sum(1 for p in logs if capture_complete(p)), len(logs)
