"""The two committed fixture tables, and what happens when one is not there.

Nothing covered the missing-table case before, and the two tables want OPPOSITE treatment:

  `config/fixture_values.json`   is fully reproducible from `fixture_policy.json` plus the
                                mine, and still refuses to be absent -- because re-derivation
                                degrades quietly when a clone is gone.
  `config/maximal_branch.json`  is NOT reproducible: `--apply` records `replaced_value` at the
                                only moment it is knowable without git, and `value_at_head`
                                recovers it only while the pre-override fixture is in HEAD.

Both refuse. `--init` is the single explicit way past either, so a bootstrap can never happen
as a side effect of a screen.
"""

from __future__ import annotations

import json
from pathlib import Path

import pytest

from scripts import fixture_values as fv
from scripts import maximal_branch as mb


# ---------------------------------------------------------------------------------------
# values_version -- absence raises, and git only decides the WORDING
# ---------------------------------------------------------------------------------------

def _redirect(monkeypatch, tmp_path, *, policy=True, values=True):
    """Point both table constants at a tmp dir, creating whichever ones the case wants."""
    p, v = tmp_path / "fixture_policy.json", tmp_path / "fixture_values.json"
    if policy:
        p.write_text('{"cardinality": 3}\n')
    if values:
        v.write_text("{}\n")
    monkeypatch.setattr(fv, "POLICY_PATH", p)
    monkeypatch.setattr(fv, "VALUES_PATH", v)
    return p, v


def test_values_version_is_stable_for_the_same_two_files(monkeypatch, tmp_path):
    _redirect(monkeypatch, tmp_path)
    assert fv.values_version() == fv.values_version()
    assert len(fv.values_version()) == 16


def test_values_version_moves_when_the_policy_moves(monkeypatch, tmp_path):
    """The whole point of the digest: editing the policy must invalidate checkpoints."""
    policy, _ = _redirect(monkeypatch, tmp_path)
    before = fv.values_version()
    policy.write_text('{"cardinality": 4}\n')
    assert fv.values_version() != before


def test_a_missing_table_raises_rather_than_hashing_empty_bytes(monkeypatch, tmp_path):
    """Hashing `b""` would answer with a plausible digest and silently invalidate every
    checkpoint -- and auto-creating would be worse, because a missing clone then sends a
    binding to a policy default with no error anywhere."""
    _redirect(monkeypatch, tmp_path, values=False)
    with pytest.raises(FileNotFoundError):
        fv.values_version()


def test_a_tracked_table_says_deletion_not_first_run(monkeypatch, tmp_path):
    _redirect(monkeypatch, tmp_path, values=False)
    monkeypatch.setattr(fv, "_is_tracked", lambda p: True)
    with pytest.raises(FileNotFoundError, match="not a first run"):
        fv.values_version()


def test_an_untracked_table_names_the_bootstrap(monkeypatch, tmp_path):
    _redirect(monkeypatch, tmp_path, values=False)
    monkeypatch.setattr(fv, "_is_tracked", lambda p: False)
    with pytest.raises(FileNotFoundError, match="--init"):
        fv.values_version()


def test_tracked_is_assumed_when_git_cannot_answer(monkeypatch, tmp_path):
    """A guard that gets weaker when git is unavailable would be the wrong way round, so the
    fallback is the louder message, not the quieter one."""
    def explode(*a, **k):
        raise OSError("no git here")
    monkeypatch.setattr(fv.subprocess, "run", explode)
    assert fv._is_tracked(tmp_path / "anything.json") is True


# ---------------------------------------------------------------------------------------
# --init -- the one explicit way past the refusal
# ---------------------------------------------------------------------------------------

def test_init_seeds_an_empty_table_and_returns_its_digest(monkeypatch, tmp_path):
    _redirect(monkeypatch, tmp_path, values=False)
    digest = fv.init_values_table()
    assert json.loads(fv.VALUES_PATH.read_text()) == {}
    assert digest == fv.values_version()


def test_init_refuses_to_overwrite_a_real_table(monkeypatch, tmp_path):
    """The table is the durable artifact and the corpus is derived from it. Clobbering it
    would discard every recovered value in favour of whatever re-derivation can still reach."""
    _, values = _redirect(monkeypatch, tmp_path)
    values.write_text('{"0041": {"bindings": {}}}\n')
    with pytest.raises(SystemExit):
        fv.init_values_table()
    assert json.loads(values.read_text()) == {"0041": {"bindings": {}}}


# ---------------------------------------------------------------------------------------
# merge_table -- the override history, and the direction the backfill runs in
# ---------------------------------------------------------------------------------------

def _row(binding, current, maximal, verdict="decidable"):
    return {"binding": binding, "current": current,
            "maximal_value": maximal, "verdict": verdict}


def test_a_missing_override_table_raises(monkeypatch, tmp_path):
    monkeypatch.setattr(mb, "TABLE_PATH", tmp_path / "gone.json")
    with pytest.raises(FileNotFoundError, match="history that nothing else holds"):
        mb.merge_table({"G": [_row("b", "false", "true")]}, Path("new_samples"))


def test_init_accepts_a_missing_override_table(monkeypatch, tmp_path):
    monkeypatch.setattr(mb, "TABLE_PATH", tmp_path / "gone.json")
    monkeypatch.setattr(mb, "value_at_head", lambda *a: None)
    out = mb.merge_table({"G": [_row("b", "false", "true")]}, Path("new_samples"),
                         allow_missing=True)
    assert out["G"][0]["overridden"] is False


def test_a_replaced_value_on_disk_wins_over_any_rederivation(monkeypatch, tmp_path):
    table = tmp_path / "maximal_branch.json"
    table.write_text(json.dumps({"G": [{"binding": "b", "replaced_value": "false",
                                        "applied": "2026-08-30"}]}))
    monkeypatch.setattr(mb, "TABLE_PATH", table)
    monkeypatch.setattr(mb, "value_at_head", lambda *a: "SOMETHING ELSE")
    out = mb.merge_table({"G": [_row("b", "true", "true")]}, Path("new_samples"))
    assert out["G"][0]["replaced_value"] == "false"
    assert out["G"][0]["applied"] == "2026-08-30"


def test_the_backfill_runs_only_where_an_override_plausibly_happened(monkeypatch, tmp_path):
    """The fixture already sits on the maximal arm, so HEAD holds what the override replaced.
    This is the case the git lookup exists for."""
    monkeypatch.setattr(mb, "TABLE_PATH", tmp_path / "gone.json")
    monkeypatch.setattr(mb, "value_at_head", lambda *a: "false")
    out = mb.merge_table({"G": [_row("b", "true", "true")]}, Path("new_samples"),
                         allow_missing=True)
    assert out["G"][0]["replaced_value"] == "false"
    assert out["G"][0]["applied"] == "backfilled-from-git"


def test_the_backfill_does_not_invert_on_a_rebuilt_corpus(monkeypatch, tmp_path):
    """A rebuilt corpus holds the PRE-override value while HEAD holds the post-override one.
    The old test -- `head != current` -- recorded the value the override WROTE as the value it
    replaced, which is backwards and would have shipped as provenance."""
    monkeypatch.setattr(mb, "TABLE_PATH", tmp_path / "gone.json")
    monkeypatch.setattr(mb, "value_at_head", lambda *a: "true")
    out = mb.merge_table({"G": [_row("b", "false", "true")]}, Path("new_samples"),
                         allow_missing=True)
    assert out["G"][0]["replaced_value"] is None
    assert out["G"][0]["overridden"] is False


def test_an_undecidable_binding_is_never_backfilled_as_an_override(monkeypatch, tmp_path):
    """`1777` after the AST port: the fixture carries an override the rule no longer supports
    and is pending a revert. Recording it as an applied override would launder exactly the
    fact that needs to stay visible."""
    monkeypatch.setattr(mb, "TABLE_PATH", tmp_path / "gone.json")
    monkeypatch.setattr(mb, "value_at_head", lambda *a: "false")
    out = mb.merge_table({"G": [_row("b", "true", None, verdict="undecidable")]},
                         Path("new_samples"), allow_missing=True)
    assert out["G"][0]["overridden"] is False


# ---------------------------------------------------------------------------------------
# recover_literal -- self-contained is a property of the EXPRESSION, not of its first line
# ---------------------------------------------------------------------------------------
#
# `git grep` is line-oriented, and the initializer regex used to require the value to close
# on the line the declaration opened. `layout_title` in `maheshj01/awesome_flutter_layouts`
# is a `const List` of eight strings written over nine lines: it matched as a declaration,
# failed as an initializer, and fell through to the `Color` policy default -- which the four
# revisions of `1860` then index with `.length`, so the role throws at mount. Third instance
# of one defect class, after `f627e20`'s typed non-colour consts and `0792`'s empty map.

def _repo(tmp_path, text, name="lib/const/const.dart"):
    """A one-commit git repo holding `text`, and the sha to read it at."""
    import subprocess
    r = tmp_path / "clone"
    (r / Path(name).parent).mkdir(parents=True, exist_ok=True)
    (r / name).write_text(text)
    run = lambda *a: subprocess.run(a, cwd=r, capture_output=True, check=True)
    run("git", "init", "-q")
    run("git", "config", "user.email", "t@t"); run("git", "config", "user.name", "t")
    run("git", "add", "-A"); run("git", "commit", "-qm", "x")
    sha = subprocess.run(["git", "rev-parse", "HEAD"], cwd=r, capture_output=True,
                         text=True).stdout.strip()
    return r, sha


def test_a_single_line_literal_is_unchanged(tmp_path):
    r, sha = _repo(tmp_path, "const white = Color(0xFFFFFFFF);\n")
    assert fv.recover_literal(r, sha, "white")[0] == "Color(0xFFFFFFFF)"


def test_a_multi_line_list_is_recovered_and_collapsed(tmp_path):
    """The 1860 case. Many lines in, one line out, every entry present.

    A trailing comma survives: the doctrine is to take the initializer VERBATIM, and a
    trailing comma is legal Dart. Tidying it would be this pass editing the repository's
    own value, which is the one thing recovery must not do."""
    r, sha = _repo(tmp_path, """
const List layout_title = [
  'CustomListView',
  'User Profile Page',
  'Awesome end Drawer',
];
""")
    got, source = fv.recover_literal(r, sha, "layout_title")
    assert got == "[ 'CustomListView', 'User Profile Page', 'Awesome end Drawer', ]"
    assert source.endswith(f"@{sha[:8]}")


def test_a_semicolon_inside_a_string_does_not_end_the_scan(tmp_path):
    r, sha = _repo(tmp_path, "const List xs = [\n  'a;b',\n  'c',\n];\n")
    assert fv.recover_literal(r, sha, "xs")[0] == "[ 'a;b', 'c', ]"


def test_a_bracket_inside_a_string_does_not_unbalance_the_scan(tmp_path):
    r, sha = _repo(tmp_path, "const List xs = [\n  ']',\n  '[',\n];\n")
    assert fv.recover_literal(r, sha, "xs")[0] == "[ ']', '[', ]"


def test_comments_inside_a_multi_line_literal_are_dropped(tmp_path):
    r, sha = _repo(tmp_path, "const List xs = [\n  'a', // trailing\n  /* mid */ 'b',\n];\n")
    assert fv.recover_literal(r, sha, "xs")[0] == "[ 'a', 'b', ]"


def test_a_nested_map_is_recovered_whole(tmp_path):
    r, sha = _repo(tmp_path, "const Map m = {\n  'k': {'a': 1},\n  'j': [2, 3],\n};\n")
    assert fv.recover_literal(r, sha, "m")[0] == "{ 'k': {'a': 1}, 'j': [2, 3], }"


def test_a_multi_line_initializer_naming_another_symbol_is_still_refused(tmp_path):
    """Widening WHAT can be read must not widen WHAT is accepted: the bare-identifier
    refusal is applied to the recovered text exactly as before."""
    r, sha = _repo(tmp_path, "const c =\n  AppColors.primary;\n")
    assert fv.recover_literal(r, sha, "c") is None


def test_a_multi_line_initializer_that_is_non_deterministic_is_still_refused(tmp_path):
    r, sha = _repo(tmp_path, "final xs = [\n  DateTime.now(),\n];\n")
    assert fv.recover_literal(r, sha, "xs") is None


def test_an_unterminated_initializer_is_refused_rather_than_guessed(tmp_path):
    r, sha = _repo(tmp_path, "const List xs = [\n  'a',\n")
    assert fv.recover_literal(r, sha, "xs") is None


# ---------------------------------------------------------------------------------------
# the shipped corpus was screened against the table it ships with
# ---------------------------------------------------------------------------------------
#
# The one check that would have caught 2026-08-31. `exclusions.json` records the
# `values_digest` of the screen that wrote it, and on that day it recorded
# `0702b92fc2980729` -- `sha256(fixture_policy.json + "{}")`, an EMPTY values table. The
# corpus had been screened in the documented sequence's first pass, whose fixtures still carry
# `// TODO: value`, and the second pass that re-screens against the filled table was never
# run. R13, R14 and R15 were therefore decided on vectors extracted from unfilled fixtures.
#
# It was silent because `screen_mode()` folds `values_version()` into the screening
# fingerprint to guard REUSE, not ORDERING: one `--rescreen` pass recomputes everything
# consistently against whatever table is on disk and records the digest faithfully. Nothing
# reads it back. This does.
#
# Not marked `slow`: it reads two files and screens nothing.

def test_the_shipped_corpus_was_screened_against_the_filled_values_table(container):
    ex = container / "new_samples" / "exclusions.json"
    if not ex.is_file():
        pytest.skip("new_samples/ is not present")
    recorded = json.loads(ex.read_text())["provenance"]["values_digest"]
    assert recorded == fv.values_version(), (
        f"new_samples/exclusions.json was screened at values_digest {recorded}, but the "
        f"committed tables now hash {fv.values_version()}. Either the corpus owes a re-screen "
        f"or a value moved after it -- re-run the screen; do not edit the digest."
    )


# ---------------------------------------------------------------------------------------
# dart_literal -- the one place a policy scalar becomes Dart source
# ---------------------------------------------------------------------------------------
#
# Until 2026-09-05 `config/fixture_policy.json` held Dart source directly, so an authored
# string was concatenated into a shipped transplant with nothing between the two and a typo
# surfaced as a compile error three phases downstream. The table now holds inert JSON scalars
# and this renders them.

def test_a_policy_scalar_becomes_the_dart_source_for_it():
    assert fv.dart_literal("") == "''"
    assert fv.dart_literal("abc") == "'abc'"
    assert fv.dart_literal(0) == "0"
    assert fv.dart_literal(0.0) == "0.0"          # never "0": `double x = 0;` does not compile
    assert fv.dart_literal(2.5) == "2.5"


def test_a_bool_renders_dart_not_python():
    """`True` is a Dart compile error, and bool is an int in Python, so order matters here."""
    assert fv.dart_literal(True) == "true"
    assert fv.dart_literal(False) == "false"


def test_a_string_needing_escapes_is_escaped():
    """`$` is interpolation in Dart, so an unescaped one is a compile error at best."""
    assert fv.dart_literal("it's") == r"'it\'s'"
    assert fv.dart_literal("a$b") == r"'a\$b'"
    assert fv.dart_literal("x\ny") == r"'x\ny'"
    assert fv.dart_literal("c:\\p") == r"'c:\\p'"


def test_a_value_that_is_not_a_json_scalar_raises():
    """A policy that has grown a shape this cannot render is one to fix, not to guess at."""
    with pytest.raises(TypeError):
        fv.dart_literal(["SizedBox()"])
    with pytest.raises(TypeError):
        fv.dart_literal(None)


def test_the_committed_policy_holds_no_dart_source():
    """The property the 2026-09-05 trim buys: every value is an inert scalar."""
    types = json.loads(fv.POLICY_PATH.read_text())["types"]
    assert set(types) == {"String", "int", "double", "num", "bool"}
    for name, value in types.items():
        assert isinstance(value, (str, int, float, bool)), name
        assert "(" not in str(value), f"{name} looks like a call, not a value"


# ---------------------------------------------------------------------------------------
# --apply -- a fixture a human has edited is never touched, and never re-indexed
# ---------------------------------------------------------------------------------------
#
# `place()` protects an edited fixture by hash, which is what lets values be filled in by hand
# while the mine and the screen keep running. `--apply` used to undo that from two directions:
# it re-digested EVERY group into `.fixture_index.json`, including files it never wrote, so the
# next export saw a hand-edited fixture as generated and overwrote it -- silently, and far from
# the run that caused it -- and its `--reresolve` pass rewrote the CONTENT of any fixture whose
# stored value had moved. The corpus is only reproducible while the authored/generated line
# holds, so laundering a file across it is worse than either write.

FIXTURE = """// generated
late String fixtureName;  // TODO: value
"""


def _corpus(tmp_path, gid="0001", *, edited: bool):
    """One group on disk, with an index entry that either matches it or does not."""
    from scripts import fixture_skeleton as fs
    root = tmp_path / "corpus"
    (root / gid).mkdir(parents=True)
    (root / gid / "dependencies.dart").write_text(FIXTURE, encoding="utf-8", newline="")
    # An edited fixture is one whose bytes no longer hash to what the index recorded. Recorded
    # against other text rather than by editing the file, so the TODO slot survives and the
    # test can tell "refused to fill" from "had nothing to fill".
    fs.save_index(root, {gid: fs.digest("what the export wrote" if edited else FIXTURE)})
    return root


def _table(gid="0001"):
    return {gid: {"anchor": "abc1234", "repo": "o/r", "bindings": {
        "fixtureName": {"decl": "late String fixtureName;", "expr": "'Order summary'",
                        "origin": "authored", "rule": "protocol_constant"}}}}


def _apply(monkeypatch, tmp_path, root, table):
    _redirect(monkeypatch, tmp_path)
    fv.VALUES_PATH.write_text(json.dumps(table))
    monkeypatch.setattr(fv, "build", lambda *a, **k: {})   # nothing new to resolve
    return fv.run(root, apply=True)


def test_an_edited_fixture_is_not_filled_and_not_re_indexed(monkeypatch, tmp_path):
    from scripts import fixture_skeleton as fs
    root, gid = _corpus(tmp_path, edited=True), "0001"
    before = fs.load_index(root)

    out = _apply(monkeypatch, tmp_path, root, _table())

    assert (root / gid / "dependencies.dart").read_text() == FIXTURE
    assert out["applied"] == 0
    assert fs.load_index(root) == before, "the index must still say this file is not ours"
    assert not fs.is_generated(root, gid, fs.load_index(root))
    assert not (root / gid / fs.PROVENANCE_NAME).is_file()


def test_an_untouched_fixture_is_still_filled_and_re_indexed(monkeypatch, tmp_path):
    """The guard must not cost the case the index refresh was added for: a fixture this
    pipeline wrote is `skeleton(mine) + values(table)` and has to keep reading as generated."""
    from scripts import fixture_skeleton as fs
    root, gid = _corpus(tmp_path, edited=False), "0001"

    out = _apply(monkeypatch, tmp_path, root, _table())

    assert "'Order summary'" in (root / gid / "dependencies.dart").read_text()
    assert out["applied"] == 1
    assert fs.is_generated(root, gid, fs.load_index(root))
    assert (root / gid / fs.PROVENANCE_NAME).is_file()


def test_maximal_branch_leaves_an_edited_fixture_alone(monkeypatch, tmp_path):
    """The override substitutes on the value it read FROM the fixture, so a bool set by hand
    matches its own regex. Without the guard the override lands on the edit and records the
    hand-set value as `replaced_value` -- provenance for something nobody did."""
    from scripts import fixture_skeleton as fs
    gid = "0001"
    root = tmp_path / "corpus"
    (root / gid).mkdir(parents=True)
    fixture = "// generated\nlate bool fixtureShowAll = false;\n"
    (root / gid / "dependencies.dart").write_text(fixture, encoding="utf-8", newline="")
    fs.save_index(root, {gid: fs.digest("what the export wrote")})

    row = dict(_row("fixtureShowAll", "false", "true"),
               rule="branch_gate", replaced_value=None, applied=None, overridden=False)
    monkeypatch.setattr(mb, "TABLE_PATH", tmp_path / "maximal_branch.json")
    monkeypatch.setattr(mb, "analyse", lambda *a, **k: [row])
    monkeypatch.setattr(mb, "merge_table", lambda t, *a, **k: t)
    out = mb.run(root, apply=True)

    assert (root / gid / "dependencies.dart").read_text() == fixture
    assert out["applied"] == 0
    assert not fs.is_generated(root, gid, fs.load_index(root))
