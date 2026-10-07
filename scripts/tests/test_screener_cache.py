"""`Screener`'s cache, driven through the backend seam by a stub that counts calls.

The cache decides how much of a screen re-reads the corpus, and until now nothing tested it
directly: every test that touched it went through the real `DartBackend`, so a cache bug
showed up only as a slow run, never as a failure.

The stub here returns fixed verdicts. It is emphatically NOT a recording of Dart's output --
that would be a second golden corpus needing regeneration on every rule edit, which is what
the project rules forbid doing to make a test pass. The rule verdicts stay with the real backend in
`test_golden_corpus.py` and `test_calibration.py`; what is tested here is the memoisation in
front of them.
"""

from __future__ import annotations

import json
from pathlib import Path

from scripts.screen.backend import CACHE_NAME, Screener


class StubBackend:
    """Satisfies the backend interface and counts what it was asked to do."""

    name = "stub"

    def __init__(self, digest: str = "rules-v1", rules=("R1_animation",)):
        self.digest = digest
        self.rules = list(rules)
        self.analysed: list[str] = []
        self.primed: list[list[str]] = []

    def fingerprint(self) -> str:
        return self.digest

    def prime(self, paths) -> None:
        self.primed.append([Path(p).name for p in paths])

    def analyse(self, path: Path):
        self.analysed.append(Path(path).name)
        # Third element since 2026-09-09: the shim drops R19/R20 read. The stub reports none,
        # which is what a transplant with no reconstructed stand-in looks like.
        return list(self.rules), f"norm-{Path(path).name}", []


def _corpus(tmp_path, *names):
    source = tmp_path / "source"
    source.mkdir(exist_ok=True)
    for n in names:
        (source / n).write_text(f"// {n}\n", encoding="utf-8")
    return source


def test_a_second_look_at_an_unchanged_file_does_not_reach_the_backend(tmp_path):
    source = _corpus(tmp_path, "a.dart")
    cache = tmp_path / CACHE_NAME
    backend = StubBackend()

    first = Screener(source, cache, backend=backend)
    assert first.rules_for(source / "a.dart") == ["R1_animation"]
    first.save()

    second = Screener(source, cache, backend=backend)
    assert second.rules_for(source / "a.dart") == ["R1_animation"]

    assert backend.analysed == ["a.dart"], "the second run reused the stored verdict"
    assert (second.hits, second.misses) == (1, 0)


def test_a_changed_file_is_re_read(tmp_path):
    """Cache hits are decided by (size, mtime_ns), which `rsync -a` and `copy2` preserve --
    that is what makes a stat comparison sufficient rather than merely fast."""
    source = _corpus(tmp_path, "a.dart")
    cache = tmp_path / CACHE_NAME
    backend = StubBackend()

    Screener(source, cache, backend=backend).rules_for(source / "a.dart")
    Screener(source, cache, backend=backend).save()

    first = Screener(source, cache, backend=backend)
    first.rules_for(source / "a.dart")
    first.save()

    (source / "a.dart").write_text("// a.dart changed materially\n", encoding="utf-8")
    again = Screener(source, cache, backend=backend)
    again.rules_for(source / "a.dart")
    assert again.misses == 1


def test_a_rule_edit_invalidates_the_whole_cache(tmp_path):
    """The stamp carries the backend's rule digest, exactly as the checkpoint mode does.
    Without it a `dart` run silently reuses verdicts written under an older vocabulary."""
    source = _corpus(tmp_path, "a.dart")
    cache = tmp_path / CACHE_NAME

    old = Screener(source, cache, backend=StubBackend(digest="rules-v1"))
    old.rules_for(source / "a.dart")
    old.save()

    edited = StubBackend(digest="rules-v2", rules=["R2_async"])
    fresh = Screener(source, cache, backend=edited)
    assert fresh.rules_for(source / "a.dart") == ["R2_async"]
    assert fresh.misses == 1, "the stored verdict was written under another rule set"


def test_a_truncated_cache_costs_a_re_screen_not_a_wrong_answer(tmp_path):
    source = _corpus(tmp_path, "a.dart")
    cache = tmp_path / CACHE_NAME
    cache.write_text('{"stamp": "stub:rules-v1", "files": {"a.d', encoding="utf-8")

    s = Screener(source, cache, backend=StubBackend())
    assert s.rules_for(source / "a.dart") == ["R1_animation"]
    assert s.misses == 1


def test_disabling_the_cache_reads_everything_and_writes_nothing(tmp_path):
    """`--rescreen` passes `enabled=False`: the point is to distrust the stored verdicts."""
    source = _corpus(tmp_path, "a.dart")
    cache = tmp_path / CACHE_NAME
    primed = Screener(source, cache, backend=StubBackend())
    primed.rules_for(source / "a.dart")
    primed.save()
    before = cache.read_text()

    off = Screener(source, cache, backend=StubBackend(), enabled=False)
    off.rules_for(source / "a.dart")
    off.save()

    assert off.misses == 1, "stored verdicts are not consulted"
    assert cache.read_text() == before, "and not overwritten"


def test_priming_skips_what_the_cache_already_answers(tmp_path):
    """Priming reads nothing it would not have read anyway, which is what keeps a
    `--resume` mid-mine as cheap as it was before the rules moved into a subprocess."""
    source = _corpus(tmp_path, "a.dart", "b.dart")
    cache = tmp_path / CACHE_NAME

    first = Screener(source, cache, backend=StubBackend())
    first.rules_for(source / "a.dart")
    first.save()

    backend = StubBackend()
    second = Screener(source, cache, backend=backend)
    second.prime([source / "a.dart", source / "b.dart"])

    assert backend.primed == [["b.dart"]], "a.dart was already answered by the cache"


def test_the_screener_uses_the_instance_it_was_given(tmp_path):
    """The reason the parameter exists: `_one_pass` shares ONE primed backend between
    `screen_mode`, the screener and `build_fixtures`. A second instance would re-run dart."""
    source = _corpus(tmp_path, "a.dart")
    backend = StubBackend()
    s = Screener(source, tmp_path / CACHE_NAME, backend=backend)
    assert s.backend is backend
    assert s.stamp == "stub:rules-v1"


def test_the_saved_cache_carries_its_stamp(tmp_path):
    source = _corpus(tmp_path, "a.dart")
    cache = tmp_path / CACHE_NAME
    s = Screener(source, cache, backend=StubBackend())
    s.rules_for(source / "a.dart")
    s.save()

    stored = json.loads(cache.read_text())
    assert stored["stamp"] == "stub:rules-v1"
    assert "a.dart" in stored["files"]
