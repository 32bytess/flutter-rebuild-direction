"""The store that makes a hand-edited `dependencies.dart` survive a rebuild.

The bug these cover, concretely: between 02:08 and 04:58 on 2026-09-07 group 0082 lost the
same hand-written fill three times. Every writer already refused to overwrite an edited
fixture -- `place()`, `fixture_values --apply` and `maximal_branch --apply` all check the
sha256 against `.fixture_index.json` -- and every one of those checks needs the file to still
be there. `screen/export` removes a stale group directory whenever `--prune` is set, which
`--from-nothing` force-sets, so a group that left the eligible set for one batch came back
with nothing to compare against and was regenerated over.

`test_a_pruned_group_comes_back_with_its_fill` is that exact sequence.
"""

from __future__ import annotations

import shutil

import pytest

from scripts import authored_fixtures, fixture_skeleton

FILL = "dynamic get title => 'Design Systems';\n"
STUB = "dynamic get title => '';\n"


@pytest.fixture(autouse=True)
def store(tmp_path, monkeypatch):
    """A store per test. The real one lives in `config/` and must never be touched here."""
    monkeypatch.setattr(authored_fixtures, "STORE", tmp_path / "store")
    monkeypatch.setattr(authored_fixtures, "INDEX", tmp_path / "store" / "index.json")
    monkeypatch.setattr(authored_fixtures, "_warned", set())
    return tmp_path / "store"


def _group(tmp_path, gid="0082", *, text=FILL, roles=("rev_001_aaaaaaaa.dart",)):
    """`text=None` leaves the group with no fixture yet -- a group the screen has not reached.

    Passing a fixture with an EMPTY index is a different state and not the one most of these
    want: `place()` reads that as a fixture written before the generator ever ran, which is
    authored by its existing and correct rule, nothing to do with the store.
    """
    dest = tmp_path / "dest"
    (dest / gid).mkdir(parents=True, exist_ok=True)
    if text is not None:
        (dest / gid / "dependencies.dart").write_text(text, encoding="utf-8")
    for name in roles:
        (dest / gid / name).write_text("class X {}\n", encoding="utf-8")
    return dest


def test_adopt_then_the_generator_cannot_write(tmp_path):
    dest = _group(tmp_path)
    assert authored_fixtures.adopt(dest, "0082")
    assert fixture_skeleton.place(dest, "0082", STUB, {}, dry_run=False) == "authored"
    assert (dest / "0082" / "dependencies.dart").read_text() == FILL


def test_a_pruned_group_comes_back_with_its_fill(tmp_path):
    """The regression. `--prune` removed the directory; the re-export must not regenerate."""
    dest = _group(tmp_path)
    authored_fixtures.adopt(dest, "0082")

    shutil.rmtree(dest / "0082")                       # export.py's prune
    (dest / "0082").mkdir()                            # the re-export copies roles back
    (dest / "0082" / "rev_001_aaaaaaaa.dart").write_text("class X {}\n", encoding="utf-8")

    assert fixture_skeleton.place(dest, "0082", STUB, {}, dry_run=False) == "restored"
    assert (dest / "0082" / "dependencies.dart").read_text() == FILL


def test_an_unstored_group_is_still_regenerated(tmp_path):
    """The store must not make the whole corpus un-derivable."""
    dest = _group(tmp_path, "0344", text=None)
    assert fixture_skeleton.place(dest, "0344", STUB, {}, dry_run=False) == "written"
    assert (dest / "0344" / "dependencies.dart").read_text() == STUB


def test_editing_a_generated_fixture_adopts_it_automatically(tmp_path):
    """Nobody should have to run a command to keep their own edit."""
    dest = _group(tmp_path, text=None)
    index = {}
    assert fixture_skeleton.place(dest, "0082", STUB, index, dry_run=False) == "written"
    assert not authored_fixtures.is_authored("0082")

    (dest / "0082" / "dependencies.dart").write_text(FILL, encoding="utf-8")   # the hand edit
    assert fixture_skeleton.place(dest, "0082", STUB, index, dry_run=False) == "authored"
    assert authored_fixtures.is_authored("0082"), "the edit was captured where a prune cannot reach"
    assert (authored_fixtures.STORE / "0082" / "dependencies.dart").read_text() == FILL


def test_a_dry_run_adopts_nothing(tmp_path):
    dest = _group(tmp_path, text=None)
    index = {}
    fixture_skeleton.place(dest, "0082", STUB, index, dry_run=False)
    (dest / "0082" / "dependencies.dart").write_text(FILL, encoding="utf-8")
    assert fixture_skeleton.place(dest, "0082", STUB, index, dry_run=True) == "authored"
    assert not authored_fixtures.is_authored("0082")


def test_a_re_minted_id_is_generated_not_restored(tmp_path, capsys):
    """The 2026-09-06 re-harvest re-mints ids, so a stored 0082 can name another scope."""
    dest = _group(tmp_path)
    authored_fixtures.adopt(dest, "0082")

    shutil.rmtree(dest / "0082")
    (dest / "0082").mkdir()
    (dest / "0082" / "rev_004_ffffffff.dart").write_text("class Y {}\n", encoding="utf-8")

    assert authored_fixtures.scope_changed(dest, "0082")
    assert not authored_fixtures.owns(dest, "0082")
    assert fixture_skeleton.place(dest, "0082", STUB, {}, dry_run=False) == "written"
    assert (dest / "0082" / "dependencies.dart").read_text() == STUB
    assert "NOT restored" in capsys.readouterr().out


def test_is_generated_is_false_so_every_writer_stands_off(tmp_path):
    """`fixture_values`, `maximal_branch` and `rebuild` all derive hands_off from this."""
    dest = _group(tmp_path)
    index = {"0082": fixture_skeleton.digest(FILL)}          # bytes agree with the index
    assert fixture_skeleton.is_generated(dest, "0082", index)
    authored_fixtures.adopt(dest, "0082")
    assert not fixture_skeleton.is_generated(dest, "0082", index)


def test_release_hands_the_group_back(tmp_path):
    dest = _group(tmp_path)
    authored_fixtures.adopt(dest, "0082")
    assert authored_fixtures.release("0082")
    assert not authored_fixtures.is_authored("0082")
    # Back under the ordinary rule: the index agrees with the bytes, so it is the
    # generator's again and the next build overwrites it.
    index = {"0082": fixture_skeleton.digest(FILL)}
    assert fixture_skeleton.place(dest, "0082", STUB, index, dry_run=False) == "written"
    assert (dest / "0082" / "dependencies.dart").read_text() == STUB


def test_adopting_twice_writes_nothing_new(tmp_path):
    dest = _group(tmp_path)
    assert authored_fixtures.adopt(dest, "0082")
    assert not authored_fixtures.adopt(dest, "0082"), "idempotent by content"


def test_an_index_entry_with_no_dart_is_not_owned(tmp_path):
    """A half-store must not report the fixture as safe when there is nothing to restore."""
    dest = _group(tmp_path)
    authored_fixtures.adopt(dest, "0082")
    (authored_fixtures.STORE / "0082" / "dependencies.dart").unlink()
    assert not authored_fixtures.is_authored("0082")


# ---------------------------------------------------------------------------------------
# The `roles` backfill, and seeding before the edit (2026-09-08)
# ---------------------------------------------------------------------------------------

def test_an_entry_with_no_roles_list_is_backfilled_rather_than_left_inert(tmp_path):
    """The five hand-adopted entries of 2026-09-07 carried no `roles`, and `scope_changed()`
    reads an empty stored list as "cannot tell" -- so the re-mint protection was inert on
    exactly the groups it was written for, while the re-harvest re-mints ids underneath them.

    Re-adopting must repair that. It cannot go through the normal write path, because adopt
    is idempotent by content digest and returns early on a settled fixture."""
    dest = _group(tmp_path, roles=("rev_001_aaaaaaaa.dart", "rev_002_bbbbbbbb.dart"))
    authored_fixtures.adopt(dest, "0082")

    index = authored_fixtures._index()
    index["0082"] = {k: v for k, v in index["0082"].items() if k != "roles"}
    authored_fixtures._write_index(index)
    assert authored_fixtures.scope_changed(dest, "0082") is False, "inert, as described"

    assert authored_fixtures.adopt(dest, "0082") is False, "nothing was re-stored"
    assert authored_fixtures._index()["0082"]["roles"] == [
        "rev_001_aaaaaaaa.dart", "rev_002_bbbbbbbb.dart"]


def test_the_backfill_does_not_move_the_adopted_date(tmp_path):
    """Authorship was recorded when it happened. Repairing the identity check is not a new
    adoption and must not read as one."""
    dest = _group(tmp_path)
    authored_fixtures.adopt(dest, "0082")
    index = authored_fixtures._index()
    index["0082"] = {**{k: v for k, v in index["0082"].items() if k != "roles"},
                     "adopted": "2026-09-07"}
    authored_fixtures._write_index(index)

    authored_fixtures.adopt(dest, "0082")
    entry = authored_fixtures._index()["0082"]
    assert entry["adopted"] == "2026-09-07"
    assert entry["roles"]


def test_the_backfill_restores_the_re_mint_protection(tmp_path):
    """The point of the repair, not just its mechanics: once the roles are recorded, a stored
    fixture written against a different scope is refused again."""
    dest = _group(tmp_path)
    authored_fixtures.adopt(dest, "0082")
    index = authored_fixtures._index()
    index["0082"] = {k: v for k, v in index["0082"].items() if k != "roles"}
    authored_fixtures._write_index(index)
    authored_fixtures.adopt(dest, "0082")

    # The re-harvest re-mints ids: `0082` now names a scope with different content-addressed
    # role names entirely.
    shutil.rmtree(dest / "0082")
    _group(tmp_path, roles=("rev_001_ffffffff.dart",), text=None)
    assert authored_fixtures.scope_changed(dest, "0082") is True
    assert authored_fixtures.owns(dest, "0082") is False


def test_seeding_takes_the_generated_fixture_before_any_edit(tmp_path):
    """`--adopt` is for a fixture already edited under the corpus -- the state that cost
    `0082` three fills on 2026-09-07, because the edit was only safe once someone noticed.
    Seeding is the other order: into the store first, then edit it where `--prune` cannot
    reach it."""
    dest = _group(tmp_path, text=STUB)
    assert authored_fixtures.adopt(dest, "0082", reason="seeded for hand authoring")
    assert authored_fixtures.is_authored("0082")
    assert authored_fixtures._index()["0082"]["reason"] == "seeded for hand authoring"
    # And the protection is live immediately, on the unedited text.
    assert fixture_skeleton.place(dest, "0082", FILL, {}, dry_run=False) in {
        "authored", "restored"}
    assert (dest / "0082" / "dependencies.dart").read_text() == STUB
