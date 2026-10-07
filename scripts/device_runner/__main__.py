"""Dispatch: run | shots | parse | telemetry | status | gate | discard.

    python -m scripts.device_runner run       [--widget-type NN] [--executions 5] [--seed 42]
    python -m scripts.device_runner parse     [--warmup 10]
    python -m scripts.device_runner telemetry [--group NN] [--session S] [--backfill]
    python -m scripts.device_runner status    --group NN [--session S] [--quiet]
    python -m scripts.device_runner gate      [--json]
    python -m scripts.device_runner discard   --group NN --reason "..."
    python -m scripts.device_runner shots     [--roles FILE] [--widget-type NN]

`run` collects raw captures on-device; `parse` is off-device and re-runnable on the stored
raw captures. `telemetry` is likewise off-device: it derives per-execution telemetry CSVs
from the flat session CSV the measure watchdog wrote. `status` reports how much of a
session is already complete and is what `devices/lib/measure.sh` asks before it decides to
resume a session or start a new one. `gate` prints the device-gate thresholds -- the ladder
`device_runner/gate.py` owns -- so a shell wrapper can read its defaults from the protocol
rather than restating them. `discard` retires a group's measurements into the attic so a
repaired fixture can be re-measured; `run` resumes the most complete session, so without it a
re-run over a finished group skips every execution and changes nothing. `shots` is the census:
one image per role and no buildSpans at all, at roughly a quarter of `run`'s cost per role --
it is a separate command precisely so that "this produces no measurements" is the command
name rather than a flag. With no subcommand, defaults to `run` (back-compat).

This package collects and normalizes measurements; it does not label them. Turning
execution medians into (base, mutation) contrasts is the analysis path's job — see
`analysis/01_data_and_labels.ipynb`.
"""

import sys

_COMMANDS = {"run", "shots", "parse", "telemetry", "status", "gate", "discard"}
# Retired subcommands, rejected by name. Without this they fall through to the `run`
# default and an old `... label` in a script would start a device measurement session
# instead of failing — the one failure mode worth spending an explicit branch on.
_RETIRED = {
    "label": "labelling moved to analysis/01_data_and_labels.ipynb",
}


def _main() -> None:
    cmd = "run"
    if len(sys.argv) > 1 and sys.argv[1] in _RETIRED:
        sys.exit(f"`{sys.argv[1]}` is no longer a subcommand: {_RETIRED[sys.argv[1]]}")
    if len(sys.argv) > 1 and sys.argv[1] in _COMMANDS:
        cmd = sys.argv.pop(1)  # let the subcommand parse its own flags

    if cmd == "parse":
        from .parse import main
    elif cmd == "telemetry":
        from .telemetry import main
    elif cmd == "status":
        from .status import main
    elif cmd == "gate":
        from .gate import main
    elif cmd == "discard":
        from .discard import main
    elif cmd == "shots":
        from .shots import main
    else:
        from .runner import main
    main()


_main()
