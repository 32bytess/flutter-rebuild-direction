"""The census command: what it runs, and what it refuses to be mistaken for.

`shots` exists because ~102 s of `run`'s 126 s per role buys nothing a census uses -- 61.4 s
of profiled rebuilds that re-photograph one tree thirty times, and ~41 s of `spm run` doing
its own pub resolve, `flutter analyze`, injection and revert. These pin the shape of what is
left, because the value of the command is entirely in what it does NOT do.
"""

from __future__ import annotations

import pytest

from scripts.device_runner import shots


def test_the_drive_command_never_reaches_spm():
    """`spm run` always adds `--profile`, always analyses first, and always injects. Going
    through it would put all three back."""
    argv = shots.drive_cmd("0719__rev_001")
    assert argv[:2] == ["flutter", "drive"]
    assert not any("spm" in a for a in argv), argv


def test_the_drive_command_is_debug():
    """No `--profile`, so `flutter drive` builds debug -- the census times nothing."""
    assert "--profile" not in shots.drive_cmd("x")


def test_the_drive_command_asks_for_the_shot_only_path():
    """Without SPM_SHOT_ONLY the test casts to `SpmState`, which only exists on an injected
    build -- and needing injection is exactly what would drag `spm run` back in."""
    argv = shots.drive_cmd("0719__rev_001")
    assert "--dart-define=SPM_SHOT_ONLY=true" in argv
    assert "--dart-define=SPM_SHOT=true" in argv
    assert "--dart-define=SPM_SHOT_NAME=0719__rev_001" in argv


def test_errors_are_dumped():
    """Profile mode collapses repeated errors to `Multiple exceptions (N) were detected` with
    no message and no stack; the census needs the cause, not just the pixels."""
    assert "--dart-define=SPM_DUMP_ERRORS=true" in shots.drive_cmd("x")


def test_no_rebuild_count_is_passed():
    """`SPM_REBUILDS` sizes the measured loop, which this path never reaches."""
    assert not any("SPM_REBUILDS" in a for a in shots.drive_cmd("x"))


def test_pub_is_not_resolved_per_role():
    """`flutter drive` re-resolves on every invocation; `resolve_packages()` does it once."""
    assert "--no-pub" in shots.drive_cmd("x")


def test_the_device_is_pinned_when_a_serial_is_exported(monkeypatch):
    monkeypatch.setenv("BENCH_DEVICE_SERIAL", "TESTSERIAL0001")
    argv = shots.drive_cmd("x")
    assert argv[argv.index("-d") + 1] == "TESTSERIAL0001"


def test_no_device_flag_without_a_serial(monkeypatch):
    """A bare `-d` with an empty value makes `flutter drive` fail on its own arguments."""
    monkeypatch.delenv("BENCH_DEVICE_SERIAL", raising=False)
    assert "-d" not in shots.drive_cmd("x")


def test_an_existing_image_is_skipped(tmp_path, monkeypatch):
    """Completeness is "the PNG is there", so an interrupted pass resumes for free."""
    from scripts.device_runner import config as runner_config

    monkeypatch.setattr(runner_config, "OUT_DIR", tmp_path / "dataset")
    monkeypatch.setenv("BENCH_DEVICE_ID", "redmi9t")
    shot_dir = runner_config.shots_dir("0719")
    shot_dir.mkdir(parents=True)
    (shot_dir / "0719__rev_001.png").write_bytes(b"png")

    target = {"group": "0719", "role": "rev_001", "sample_id": "0719/rev_001"}
    assert shots.capture(target, force=False) == "skipped"


def test_force_re_photographs(tmp_path, monkeypatch):
    """After a repair the image on disk is the PRE-repair one. Without --force it is reused
    and the gate re-condemns a group that has just been fixed."""
    from scripts.device_runner import config as runner_config

    monkeypatch.setattr(runner_config, "OUT_DIR", tmp_path / "dataset")
    monkeypatch.setenv("BENCH_DEVICE_ID", "redmi9t")
    shot_dir = runner_config.shots_dir("0719")
    shot_dir.mkdir(parents=True)
    (shot_dir / "0719__rev_001.png").write_bytes(b"png")

    called = []
    monkeypatch.setattr(shots, "capture", shots.capture)      # keep the real one
    import scripts.device_runner.runner as runner_mod
    monkeypatch.setattr(runner_mod, "assemble", lambda t: called.append(t) or True)
    monkeypatch.setattr(runner_mod, "_run", lambda *a, **k: (True, "out"))

    target = {"group": "0719", "role": "rev_001", "sample_id": "0719/rev_001",
              "target_path": tmp_path / "r.dart", "deps_path": None}
    assert shots.capture(target, force=True) == "shot"
    assert called, "--force must actually stage and drive the role again"
