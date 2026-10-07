"""Whether an execution may start, and the thresholds that decide it.

The protocol has three device gates and they used to be three implementations. `preflight.sh`
checks a band once per session; `measure.sh` watches from outside and SIGSTOPs the runner on a
thermal ceiling or SIGINTs it on a battery floor; `runner.py` checked again, from inside,
before every execution. Bash carried `BAND_LO/BAND_HI=30/85`, `HARD_LO/HARD_HI=30/85` and
`RUN_FLOOR=20`; Python carried `BATTERY_BAND_PCT=(30, 85)`, `BATTERY_ABORT_PCT=25`,
`BATTERY_PAUSE_PCT=30` and `BATTERY_RESUME_PCT=85`. Seven literals for one protocol, in two
languages, with nothing holding them together.

THE LADDER IS NOT COLLAPSED, AND MUST NOT BE
--------------------------------------------
These are not duplicates that drifted; they are different rungs, and they are ordered:

    85  resume / band ceiling   charging stops here, and above it heat rises
    30  pause / band floor      pause the session and let it charge back to 85
    25  abort                   only reachable with pause disabled (POWER_MODE=suspend,
                                where the level only ever falls and a wait could never
                                succeed); below this DVFS behaviour itself changes
    20  run_floor               the bash watchdog's SIGINT, deliberately BELOW the Python
                                floor so the in-process stop gets to happen first

Making them one number would change the protocol, not tidy it. What this module fixes is that
they are now in one place, named, with the ordering asserted -- so a change to one is visibly
a change to the ladder.

WHAT IS PURE AND WHAT IS NOT
----------------------------
`decide` is a pure function of a `Snapshot` and a `Policy`. Everything that talks to a phone
-- the cooldown poll loop, the wait-for-charge loop, the adb and sysfs reads -- stays in
`runner.py`, which is the adapter. That split is the whole reason this file can be tested at
all: before it, `device_runner` was 2,464 lines with no test of any kind, because every path
into it needed a device.
"""

from __future__ import annotations

import dataclasses
from typing import Literal

from . import config

Verdict = Literal["proceed", "cool", "pause", "abort"]


@dataclasses.dataclass(frozen=True)
class Policy:
    """Every threshold the per-execution gate uses, as one object.

    Defaults are read from `config`, which is where the environment overrides
    (`BENCH_BATTERY_PAUSE_PCT` and friends) are applied, so a device wrapper still tunes them
    exactly as it did.
    """

    cooldown_millic: int
    cooldown_max_wait_s: int
    cooldown_poll_s: int
    band: tuple[int, int]
    abort_pct: int
    pause_pct: int
    resume_pct: int
    charge_poll_s: int
    charge_stall_s: int
    # Not acted on here: it is the bash watchdog's floor, named so the ladder is complete and
    # so a change to the Python floors can be seen against it. `devices/lib/pipeline.sh`
    # still owns its own default, and this is the value it must stay below.
    run_floor_pct: int = 20

    @classmethod
    def from_config(cls) -> "Policy":
        return cls(
            cooldown_millic=config.COOLDOWN_TEMP_MILLIC,
            cooldown_max_wait_s=config.COOLDOWN_MAX_WAIT_S,
            cooldown_poll_s=config.COOLDOWN_POLL_S,
            band=config.BATTERY_BAND_PCT,
            abort_pct=config.BATTERY_ABORT_PCT,
            pause_pct=config.BATTERY_PAUSE_PCT,
            resume_pct=config.BATTERY_RESUME_PCT,
            charge_poll_s=config.BATTERY_CHARGE_POLL_S,
            charge_stall_s=config.BATTERY_CHARGE_STALL_S,
        )

    def check_ordering(self) -> list[str]:
        """Rungs that are out of order. Empty is the healthy case.

        A misordered ladder is silently wrong rather than loudly broken: with `abort` above
        `pause`, a session aborts where it was meant to charge and continue.
        """
        lo, hi = self.band
        problems = []
        if self.pause_pct and self.abort_pct >= self.pause_pct:
            problems.append(
                f"abort {self.abort_pct}% >= pause {self.pause_pct}%: the session would abort "
                f"where it was meant to pause and charge")
        if self.resume_pct <= self.pause_pct:
            problems.append(
                f"resume {self.resume_pct}% <= pause {self.pause_pct}%: no hysteresis, so one "
                f"execution's drain re-triggers the pause and the gate flaps at the edge")
        if self.pause_pct and self.run_floor_pct >= self.abort_pct:
            problems.append(
                f"watchdog floor {self.run_floor_pct}% >= abort {self.abort_pct}%: bash would "
                f"SIGINT before the in-process stop could happen")
        if lo > hi:
            problems.append(f"band {lo}-{hi}% is inverted")
        return problems


@dataclasses.dataclass(frozen=True)
class Snapshot:
    """What the phone said. `None` means the read failed, which is not the same as zero."""

    battery_pct: int | None = None
    battery_temp_c: float | None = None
    soc_millic: int | None = None
    charging: bool = False


@dataclasses.dataclass(frozen=True)
class Decision:
    verdict: Verdict
    reason: str
    # Advisory, and deliberately separate from `verdict`: being outside the band or plugged in
    # is a fact the record should carry, never a reason to stop measuring.
    warnings: tuple[str, ...] = ()


def decide(snap: Snapshot, policy: Policy) -> Decision:
    """Whether this execution may start.

    Precedence is the order `preflight` has always evaluated in, and it is load-bearing:
    thermal first, then pause, then abort. Because `abort_pct` (25) sits BELOW `pause_pct`
    (30), the abort rung is unreachable while pause-to-charge is on -- a phone that low pauses
    and charges instead. It becomes reachable exactly when pause is disabled, which is
    `POWER_MODE=suspend`, where the level only ever falls and waiting could never succeed.
    """
    warnings: list[str] = []
    pct = snap.battery_pct

    if pct is not None:
        lo, hi = policy.band
        if not (lo <= pct <= hi):
            warnings.append(f"battery {pct}% is outside the protocol band {lo}-{hi}%")
    if snap.charging:
        warnings.append("device reports CHARGING - run: adb shell dumpsys battery unplug")

    if snap.soc_millic is not None and snap.soc_millic >= policy.cooldown_millic:
        return Decision("cool",
                        f"SoC {snap.soc_millic} milli-C >= {policy.cooldown_millic}",
                        tuple(warnings))
    if pct is not None and policy.pause_pct and pct < policy.pause_pct:
        return Decision("pause",
                        f"battery {pct}% below pause floor {policy.pause_pct}%",
                        tuple(warnings))
    if pct is not None and pct < policy.abort_pct:
        return Decision("abort",
                        f"battery {pct}% below abort floor {policy.abort_pct}%",
                        tuple(warnings))
    return Decision("proceed", "device is in band", tuple(warnings))


def charge_stalled(best_pct: int, current_pct: int, stalled_s: int,
                   policy: Policy) -> bool:
    """Whether a pause has stopped making progress, i.e. the phone is not actually charging.

    Split out of the wait loop so the give-up rule can be tested without waiting ten minutes.
    """
    return current_pct <= best_pct and stalled_s >= policy.charge_stall_s


def as_dict(policy: Policy) -> dict:
    """The policy as data, for the manifest and for `device_runner gate --json`.

    `devices/lib/pipeline.sh` keeps its own control flow -- the watchdog runs outside this
    process and stopping a hung runner is exactly what it is for -- but this is where its
    defaults can be read from rather than restated.
    """
    return dataclasses.asdict(policy)


def main() -> None:
    """`python -m scripts.device_runner gate [--json]` -- print the ladder.

    Exits non-zero if the rungs are out of order, so a device wrapper that overrode one into
    an unusable position finds out before it measures anything.
    """
    import argparse
    import json
    import sys

    ap = argparse.ArgumentParser(prog="python -m scripts.device_runner gate",
                                 description=main.__doc__)
    ap.add_argument("--json", action="store_true", help="machine-readable, for a shell wrapper")
    args = ap.parse_args()

    policy = Policy.from_config()
    problems = policy.check_ordering()
    if args.json:
        print(json.dumps({**as_dict(policy), "problems": problems}, indent=2))
    else:
        for field, value in as_dict(policy).items():
            print(f"{field:22} {value}")
        for problem in problems:
            print(f"PROBLEM  {problem}", file=sys.stderr)
    sys.exit(1 if problems else 0)
