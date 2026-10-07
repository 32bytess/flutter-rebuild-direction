"""The device gate's ladder, and the order it is evaluated in.

The first test in this repository to import `device_runner`. Before `gate.py` split the
decision out of the poll loops, all 2,464 lines of that package needed a physical phone to
reach, so none of it had a test -- including `_classify`, which is a five-line pure function.

These pin the ladder itself. Its rungs are not duplicates that drifted; they are ordered, and
the order is what makes the protocol work.
"""

from __future__ import annotations

import pytest

from scripts.device_runner import gate


POLICY = gate.Policy(
    cooldown_millic=55000, cooldown_max_wait_s=120, cooldown_poll_s=3,
    band=(30, 85), abort_pct=25, pause_pct=30, resume_pct=85,
    charge_poll_s=30, charge_stall_s=600, run_floor_pct=20,
)


def test_the_shipped_policy_is_the_shipped_ladder():
    """These are the protocol's numbers. A change here is a protocol change."""
    live = gate.Policy.from_config()
    assert live.band == (30, 85)
    assert live.abort_pct == 25
    assert live.pause_pct == 30
    assert live.resume_pct == 85
    assert live.cooldown_millic == 55000


def test_the_shipped_ladder_is_in_order():
    assert gate.Policy.from_config().check_ordering() == []


@pytest.mark.parametrize("pct, expected", [
    (90, "proceed"),   # above the band ceiling: a warning, never a stop
    (85, "proceed"),
    (50, "proceed"),
    (30, "proceed"),   # exactly at the pause floor is still in band
    (29, "pause"),
    (25, "pause"),     # abort_pct sits BELOW pause_pct, so pause wins here
    (10, "pause"),
])
def test_the_battery_rungs(pct, expected):
    assert gate.decide(gate.Snapshot(battery_pct=pct), POLICY).verdict == expected


def test_abort_is_only_reachable_with_pause_disabled():
    """`BENCH_BATTERY_PAUSE_PCT=0` is mandatory under POWER_MODE=suspend, where the level
    only ever falls and waiting to charge could never succeed. That is the one configuration
    in which the abort rung does anything."""
    suspended = gate.Policy(**{**gate.as_dict(POLICY), "pause_pct": 0})
    assert gate.decide(gate.Snapshot(battery_pct=10), suspended).verdict == "abort"
    assert gate.decide(gate.Snapshot(battery_pct=10), POLICY).verdict == "pause"


def test_thermal_outranks_battery():
    """`preflight` has always cooled first. A hot phone waits before anything else is read."""
    hot_and_low = gate.Snapshot(battery_pct=10, soc_millic=60000)
    assert gate.decide(hot_and_low, POLICY).verdict == "cool"


def test_the_thermal_rung_is_a_ceiling_not_a_range():
    assert gate.decide(gate.Snapshot(soc_millic=54999), POLICY).verdict == "proceed"
    assert gate.decide(gate.Snapshot(soc_millic=55000), POLICY).verdict == "cool"


def test_an_unreadable_reading_is_not_zero():
    """`None` means the adb or sysfs read failed. Treating it as 0 would abort every session
    on a device whose fuel gauge is not exposed."""
    assert gate.decide(gate.Snapshot(), POLICY).verdict == "proceed"
    assert gate.decide(gate.Snapshot(battery_pct=None, soc_millic=None),
                       POLICY).verdict == "proceed"


def test_out_of_band_and_charging_warn_but_never_stop():
    d = gate.decide(gate.Snapshot(battery_pct=95, charging=True), POLICY)
    assert d.verdict == "proceed"
    assert any("outside the protocol band" in w for w in d.warnings)
    assert any("CHARGING" in w for w in d.warnings)


def test_hysteresis_between_pause_and_resume():
    """Resuming at the pause floor would flap: one execution's drain re-triggers the pause."""
    assert POLICY.resume_pct > POLICY.pause_pct
    flappy = gate.Policy(**{**gate.as_dict(POLICY), "resume_pct": 30})
    assert any("hysteresis" in p for p in flappy.check_ordering())


def test_a_misordered_ladder_is_reported():
    inverted = gate.Policy(**{**gate.as_dict(POLICY), "abort_pct": 40})
    problems = inverted.check_ordering()
    assert any("abort" in p and "pause" in p for p in problems)


def test_the_watchdog_floor_sits_below_the_in_process_floor():
    """bash SIGINTs at RUN_FLOOR from outside; Python stops at abort_pct from inside. If the
    watchdog fired first the in-process stop -- which keeps completed executions -- would
    never happen."""
    assert POLICY.run_floor_pct < POLICY.abort_pct
    bad = gate.Policy(**{**gate.as_dict(POLICY), "run_floor_pct": 30})
    assert any("watchdog floor" in p for p in bad.check_ordering())


def test_charge_stall_gives_up_only_after_no_progress():
    assert not gate.charge_stalled(best_pct=40, current_pct=41, stalled_s=9999, policy=POLICY)
    assert not gate.charge_stalled(best_pct=40, current_pct=40, stalled_s=300, policy=POLICY)
    assert gate.charge_stalled(best_pct=40, current_pct=40, stalled_s=600, policy=POLICY)


def test_the_policy_serialises_for_the_manifest_and_the_shell():
    d = gate.as_dict(gate.Policy.from_config())
    assert d["pause_pct"] == 30 and d["run_floor_pct"] == 20
    assert gate.Policy(**d) == gate.Policy.from_config(), "round-trips"
