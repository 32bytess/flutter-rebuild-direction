"""The measurement pin: a re-screen may not change code the device has already measured.

`export.copy_file` has always compared content and re-copied nothing, so in practice a
re-screen was already a no-op. That is an OBSERVED property of one set of flags, and the
three things that break it are ordinary: editing `fixture_policy.json` moves every generated
fixture, `--prune` removes a group that left the eligible set for one batch, a normalisation
change rewrites every role. These tests are about the difference between observing and
enforcing.
"""

from __future__ import annotations

import json
from pathlib import Path

import pytest

from scripts import fixture_skeleton
from scripts.screen import export as export_mod, freeze
from scripts.tests import mini_corpus
from scripts.tests.regolden import run, screen_argv

pytestmark = pytest.mark.dart


@pytest.fixture
def store(tmp_path, monkeypatch):
    """A store of this test's own. The real one lives in `config/` and is not a fixture."""
    path = tmp_path / "measured_freeze.json"
    monkeypatch.setattr(freeze, "STORE", path)
    return path


def test_a_missing_store_is_empty_not_an_error(store):
    """The ordinary state of a fresh clone. Unlike the values table, nothing is re-derived
    from this one, so there is no silent degradation to refuse over."""
    assert freeze.load() == {}


def test_digests_are_keyed_on_names_not_paths(tmp_path, store):
    group = tmp_path / "0001"
    group.mkdir()
    (group / "rev_001_a.dart").write_text("a")
    (group / "dependencies.dart").write_text("b")
    got = freeze.digests(group)
    assert sorted(got) == ["dependencies.dart", "rev_001_a.dart"]
    assert all("/" not in k for k in got)


def test_seed_pins_only_measured_groups(tmp_path, store, monkeypatch):
    dest = tmp_path / "corpus"
    for gid in ("0001", "0002"):
        (dest / gid).mkdir(parents=True)
        (dest / gid / "rev_001_a.dart").write_text(gid)
    dataset = tmp_path / "dataset-corpus"
    (dataset / "0001" / "redmi9t").mkdir(parents=True)
    (dataset / "0001" / "redmi9t" / "performance.jsonl").write_text("{}\n")

    added = freeze.seed(dest)
    assert sorted(added) == ["0001"], "an unmeasured group must not be pinned"
    assert added["0001"]["devices"] == ["redmi9t"]
    assert "rev_001_a.dart" in added["0001"]["files"]


def test_seed_never_re_pins_an_already_drifted_group(tmp_path, store):
    """Re-seeding a group whose bytes have already moved would launder the drift into the
    store as though the current files were the measured ones."""
    dest = tmp_path / "corpus"
    (dest / "0001").mkdir(parents=True)
    role = dest / "0001" / "rev_001_a.dart"
    role.write_text("as measured")
    dataset = tmp_path / "dataset-corpus"
    (dataset / "0001" / "redmi9t").mkdir(parents=True)
    (dataset / "0001" / "redmi9t" / "performance.jsonl").write_text("{}\n")
    freeze.seed(dest)

    role.write_text("changed behind our back")
    assert freeze.seed(dest) == {}
    assert freeze.verify(dest) == {"0001": {"rev_001_a.dart": "changed"}}


def test_verify_names_what_happened(tmp_path, store):
    dest = tmp_path / "corpus"
    (dest / "0001").mkdir(parents=True)
    (dest / "0001" / "kept.dart").write_text("k")
    (dest / "0001" / "gone.dart").write_text("g")
    dataset = tmp_path / "dataset-corpus"
    (dataset / "0001" / "redmi9t").mkdir(parents=True)
    (dataset / "0001" / "redmi9t" / "performance.jsonl").write_text("{}\n")
    freeze.seed(dest)

    (dest / "0001" / "gone.dart").unlink()
    (dest / "0001" / "new.dart").write_text("n")
    assert freeze.verify(dest) == {"0001": {"gone.dart": "missing", "new.dart": "added"}}


def test_release_is_recorded_and_lifts_the_pin(tmp_path, store):
    dest = tmp_path / "corpus"
    (dest / "0001").mkdir(parents=True)
    (dest / "0001" / "a.dart").write_text("a")
    dataset = tmp_path / "dataset-corpus"
    (dataset / "0001" / "redmi9t").mkdir(parents=True)
    (dataset / "0001" / "redmi9t" / "performance.jsonl").write_text("{}\n")
    freeze.seed(dest)
    assert "0001" in freeze.load()

    entry = freeze.release("0001", "renders an error box; repairing the fixture")
    assert entry["released"]["reason"].startswith("renders an error box")
    assert freeze.load() == {}, "a released group must stop gating"
    assert "0001" in json.loads(store.read_text())["groups"], \
        "the release is the record; deleting the entry would erase it"


def test_releasing_twice_refuses(tmp_path, store):
    dest = tmp_path / "corpus"
    (dest / "0001").mkdir(parents=True)
    (dest / "0001" / "a.dart").write_text("a")
    dataset = tmp_path / "dataset-corpus"
    (dataset / "0001" / "redmi9t").mkdir(parents=True)
    (dataset / "0001" / "redmi9t" / "performance.jsonl").write_text("{}\n")
    freeze.seed(dest)
    freeze.release("0001", "first")
    with pytest.raises(SystemExit):
        freeze.release("0001", "second")


# ---- the gate, through the real write paths --------------------------------------------

def test_copy_file_wakes_the_guard_only_on_a_real_write(tmp_path):
    """The whole contract. A re-export of a measured group reaches the content comparison,
    writes nothing and must not raise; one that would change the bytes must."""
    src, dst = tmp_path / "s.dart", tmp_path / "d.dart"
    src.write_text("same")
    dst.write_text("same")
    calls = []
    acted, _ = export_mod.copy_file(src, dst, dry_run=False, guard=lambda: calls.append(1))
    assert (acted, calls) == (False, [])

    src.write_text("different")
    with pytest.raises(freeze.FrozenGroupError):
        export_mod.copy_file(src, dst, dry_run=False,
                             guard=lambda: freeze.refuse("0001", "d.dart",
                                                         {"0001": {"devices": ["redmi9t"]}}))
    assert dst.read_text() == "same", "the guard must fire BEFORE the byte lands"


def test_copy_file_ignores_a_touch_that_changes_no_bytes(tmp_path):
    """A re-clone of `--source` gives every file a new mtime. Waking the guard on that would
    refuse an ordinary re-screen over nothing."""
    src, dst = tmp_path / "s.dart", tmp_path / "d.dart"
    src.write_text("same")
    dst.write_text("same")
    import os
    os.utime(src, (0, 0))
    acted, _ = export_mod.copy_file(
        src, dst, dry_run=False, guard=lambda: pytest.fail("guard woke on identical bytes"))
    assert acted is False


def test_place_wakes_the_guard_only_when_the_fixture_changes(tmp_path):
    dest = tmp_path / "corpus"
    (dest / "0001").mkdir(parents=True)
    fixture = dest / "0001" / fixture_skeleton.FIXTURE_NAME
    fixture.write_text("// fixture\n")
    index = {"0001": fixture_skeleton.digest("// fixture\n")}

    assert fixture_skeleton.place(dest, "0001", "// fixture\n", index, dry_run=False,
                                  guard=lambda: pytest.fail("guard woke on an unchanged "
                                                            "fixture")) == "current"
    with pytest.raises(freeze.FrozenGroupError):
        fixture_skeleton.place(dest, "0001", "// different\n", index, dry_run=False,
                               guard=lambda: freeze.refuse(
                                   "0001", fixture_skeleton.FIXTURE_NAME,
                                   {"0001": {"devices": ["redmi9t"]}}))
    assert fixture.read_text() == "// fixture\n"


def test_a_frozen_group_is_not_pruned(tmp_path, store, monkeypatch):
    """`--prune` is what cost 0082 its fill three times. A pinned group is a measured one, so
    removing its directory orphans every row under it -- the screen refuses instead."""
    source = mini_corpus.build(tmp_path / "corpus")
    dest, records = tmp_path / "dest", tmp_path / "records"
    argv = screen_argv(source, records, ["--dest", str(dest), "--no-fixtures"])
    run(argv)

    dataset = tmp_path / "dataset-dest"
    (dataset / "0001" / "redmi9t").mkdir(parents=True)
    (dataset / "0001" / "redmi9t" / "performance.jsonl").write_text("{}\n")
    freeze.seed(dest)
    assert "0001" in freeze.load()

    # 0001 leaves the eligible set -- exactly the batch-to-batch case a prune is for.
    out = run(screen_argv(source, records,
                          ["--dest", str(dest), "--no-fixtures", "--prune", "--rescreen",
                           "--exclude-groups", "0001"]),
              expect_failure=True, env={"SPM_MEASURED_FREEZE": str(store)})
    assert (dest / "0001").is_dir(), "a measured group was pruned"
    assert "0001 is frozen" in (out.stdout + out.stderr)
    assert "--release 0001" in (out.stdout + out.stderr)


def test_the_refusal_names_the_group_and_the_way_out():
    with pytest.raises(freeze.FrozenGroupError) as exc:
        freeze.refuse("0508", "dependencies.dart", {"0508": {"devices": ["redmi9t"]}})
    message = str(exc.value)
    assert "0508" in message and "redmi9t" in message
    assert "--release 0508" in message, "a refusal with no way past it is a dead end"


def test_an_unfrozen_group_is_not_refused():
    freeze.refuse("9999", "anything.dart", {"0508": {"devices": ["redmi9t"]}})
