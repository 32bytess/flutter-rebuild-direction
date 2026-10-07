"""Retiring a group's measurements, and the guard that stops it being casual.

`run` resumes the MOST COMPLETE session, so a repaired group with a finished session on disk
re-runs into a no-op. Clearing the way is therefore a required step -- and a required step
that exists only as a remembered `rm -rf` is one that gets skipped, or mistyped against a
tree where the wrong group id destroys hours of device time.
"""

from __future__ import annotations

import json
from pathlib import Path

import pytest

from scripts.device_runner import config as runner_config
from scripts.device_runner import discard as discard_mod
from scripts.screen import freeze


@pytest.fixture
def measured(tmp_path, monkeypatch):
    """A corpus with one measured group, and stores of this test's own."""
    monkeypatch.setattr(freeze, "STORE", tmp_path / "measured_freeze.json")
    monkeypatch.setattr(runner_config, "OUT_DIR", tmp_path / "dataset")
    monkeypatch.setenv("BENCH_DEVICE_ID", "redmi9t")

    dest = tmp_path / "corpus"
    (dest / "0508").mkdir(parents=True)
    (dest / "0508" / "rev_001_a.dart").write_text("// role")

    device = runner_config.device_dir("0508")
    (device / "raw" / "20260910-180223" / "rev_001_a").mkdir(parents=True)
    (device / "performance.jsonl").write_text('{"median_us": 1}\n{"median_us": 2}\n')
    return dest, device


def test_a_frozen_group_refuses(measured):
    """The freeze release and the discard are two halves of one decision. Splitting them
    would let the rows go while the record still says they describe the code on disk."""
    dest, _ = measured
    freeze.seed(dest)
    with pytest.raises(SystemExit) as exc:
        discard_mod.discard("0508", "fixture repaired")
    assert "--release 0508" in str(exc.value)


def test_a_released_group_moves_to_the_attic(measured):
    """Moved, never deleted: the device session cost hours and cannot be re-derived."""
    dest, device = measured
    freeze.seed(dest)
    freeze.release("0508", "renders RenderErrorBox")

    stamp = discard_mod.discard("0508", "fixture repaired: provider passthrough")
    assert not device.exists(), "the stale captures are still in the runner's way"
    assert stamp["performance_rows"] == 2
    assert stamp["sessions"] == ["20260910-180223"]

    attic = list((runner_config.OUT_DIR / discard_mod.ATTIC_NAME).glob("*/0508/redmi9t"))
    assert len(attic) == 1
    written = json.loads((attic[0] / discard_mod.STAMP_NAME).read_text())
    assert written["reason"] == "fixture repaired: provider passthrough"
    assert "renders RenderErrorBox" in written["freeze"], \
        "the stamp must carry WHY the pin was lifted, not just that it was"
    assert (attic[0] / "performance.jsonl").read_text().count("median_us") == 2


def test_an_unpinned_group_needs_no_release(measured):
    """The pin protects MEASURED code. A group nobody pinned has nothing to protect, and
    requiring a release there would be ceremony over an empty record."""
    _, device = measured
    assert discard_mod.released("0508") == (True, "never pinned")
    discard_mod.discard("0508", "never measured cleanly")
    assert not device.exists()


def test_discarding_nothing_says_so(measured):
    """A group with no measurements is already in the state the caller wants. Saying that is
    better than a silent success that reads as "the rows are gone"."""
    with pytest.raises(SystemExit) as exc:
        discard_mod.discard("9999", "typo")
    assert "nothing to discard" in str(exc.value)


def test_dry_run_moves_nothing(measured):
    _, device = measured
    stamp = discard_mod.discard("0508", "looking", dry_run=True)
    assert device.exists()
    assert stamp["performance_rows"] == 2


def test_static_jsonl_survives(measured):
    """`static.jsonl` sits ABOVE the device segment because AST features do not depend on the
    phone. Discarding a device's rows must not take it."""
    dest, _ = measured
    static = runner_config.group_dir("0508") / "static.jsonl"
    static.write_text('{"instance_id": "x"}\n')
    discard_mod.discard("0508", "fixture repaired")
    assert static.is_file()
