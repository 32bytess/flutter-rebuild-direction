"""A role that fails on its own must not cost the session.

On 2026-09-09 four roles of group 0344 could not be staged -- they declare no
`part 'dependencies.dart';` and their group ships a part-file fixture, so `flutter analyze`
refused the orphan part. Three of them failed back-to-back, tripped `WEAK_CAPTURE_ABORT`,
and the abort took 0334, 0331 and 0314 -- three groups with nothing wrong -- down with it,
because `devices/lib/pipeline.sh` died on the first failing group.

`scripts/device_runner/transplant.py` fixes the staging bug. These tests pin the other
half: one bad role is quarantined and the session carries on, while a failure that spans
DIFFERENT roles -- the systematic break `WEAK_CAPTURE_ABORT` exists for -- still aborts.
"""

from __future__ import annotations

import json

import pytest

from scripts.device_runner import config, runner


ANALYZE_FAILURE = (
    "[spm]: Running flutter analyze...\n"
    "  error • Undefined class 'Color' • lib/dependencies.dart:85:1 • undefined_class\n"
    "error_type: FlutterAnalyzeFailure\n"
    "message: flutter analyze reported errors. Fix them before running.\n"
)


def _good_capture() -> str:
    return "".join(
        f"[SPM:perf] GeneratedWidget buildSpan: {1000 + i}\n"
        for i in range(config.N_REBUILDS)
    )


def _targets(n: int) -> list[dict]:
    return [
        {"sample_id": f"0344/rev_{i:03d}", "group": "0344", "role": f"rev_{i:03d}",
         "safe": f"0344__rev_{i:03d}", "target_path": None, "deps_path": None}
        for i in range(1, n + 1)
    ]


@pytest.fixture
def harness(tmp_path, monkeypatch):
    """phase2_measure with the device, the transplant and spm stubbed out."""
    cache = tmp_path / "static_cache"
    cache.mkdir()
    monkeypatch.setattr(config, "STATIC_CACHE_DIR", cache)
    monkeypatch.setattr(config, "STATIC_FILE", tmp_path / "static.jsonl")
    monkeypatch.setattr(config, "capture_dir",
                        lambda session, group, role: tmp_path / session / group / role)
    monkeypatch.setattr(runner, "preflight", lambda i, total: {
        "battery_pct": 63, "soc_temp_millic": 43000,
        "battery_temp_c": 32.8, "charging": False})
    monkeypatch.setattr(runner, "assemble", lambda target: True)
    monkeypatch.setattr(runner, "restore_active", lambda original: None)
    monkeypatch.setattr(runner, "_mirror_capture", lambda vm, t, k: None)
    monkeypatch.setattr(runner, "recover_device", lambda reason: None)

    return tmp_path, cache



def _drive(monkeypatch, tmp_path, cache, targets, outcome, n_exec=4):
    """Run phase2_measure over `targets`, `outcome(sample_id) -> (success, stdout)`."""
    for t in targets:
        (cache / f"{t['safe']}.jsonl").write_text(
            json.dumps({"sample_id": t["sample_id"]}) + "\n", encoding="utf-8")
    calls: list[str] = []

    def fake_run(cmd, timeout_s=None, env=None):
        sid = json.loads(config.STATIC_FILE.read_text())["sample_id"]
        calls.append(sid)
        return outcome(sid)

    monkeypatch.setattr(runner, "_run", fake_run)
    complete, quarantined = runner.phase2_measure(
        targets, n_exec, seed=42, original_widget="", session_arg="s1")
    return complete, quarantined, calls


def test_one_broken_role_is_quarantined_and_the_others_are_measured(harness, monkeypatch):
    tmp_path, cache = harness
    targets = _targets(3)
    broken = "0344/rev_001"

    complete, quarantined, calls = _drive(
        monkeypatch, tmp_path, cache, targets,
        lambda sid: (False, ANALYZE_FAILURE) if sid == broken else (True, _good_capture()))

    assert list(quarantined) == [broken]
    assert quarantined[broken] == "analyze_error"
    # ROLE_WEAK_LIMIT attempts on the broken role, then never again.
    assert calls.count(broken) == config.ROLE_WEAK_LIMIT
    # Every execution of every other role still ran.
    assert calls.count("0344/rev_002") == 4
    assert calls.count("0344/rev_003") == 4
    # Not an abort -- but the session is NOT complete, so the exit code stays nonzero.
    assert complete is True


def test_a_failure_that_spans_roles_still_aborts_the_session(harness, monkeypatch):
    """The systematic break WEAK_CAPTURE_ABORT exists for: nothing measures at all."""
    tmp_path, cache = harness
    targets = _targets(4)

    complete, quarantined, calls = _drive(
        monkeypatch, tmp_path, cache, targets, lambda sid: (False, ANALYZE_FAILURE))

    assert complete is False
    assert len(calls) == config.WEAK_CAPTURE_ABORT


def test_a_clean_session_quarantines_nothing(harness, monkeypatch):
    tmp_path, cache = harness
    targets = _targets(2)

    complete, quarantined, calls = _drive(
        monkeypatch, tmp_path, cache, targets, lambda sid: (True, _good_capture()))

    assert (complete, quarantined) == (True, {})
    assert len(calls) == 8
