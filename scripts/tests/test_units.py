"""Unit tests for the screening logic that has no Dart-side coverage.

`dart_tools/test/` pins how a rule MATCHES. Nothing pinned what the screen then DOES with
the verdicts: endpoint recovery, manifest retargeting, the copy idempotence that makes a
re-export cheap, or the checkpoint-mode rejection that stops a resume crossing a rule edit.
Those are what this file holds, and they are what a refactor is most likely to break
silently -- none of them changes a count, so the totals regression would not catch them.
"""

from __future__ import annotations

import json
import os
from pathlib import Path

import pytest

from scripts import screen_samples as screen


# ---------------------------------------------------------------------------------------
# read_group_ids -- the hand-exclusion input
# ---------------------------------------------------------------------------------------

def test_read_group_exclusions_accepts_bare_comma_and_file_forms(tmp_path):
    listing = tmp_path / "hand_exclusions.txt"
    listing.write_text("0301  # not worth a fixture\n\n# a whole-line comment\n0302\n")
    got = screen.read_group_exclusions(["0224", "0231,0232", f"@{listing}"])
    assert set(got) == {"0224", "0231", "0232", "0301", "0302"}


def test_read_group_exclusions_keeps_the_reason(tmp_path):
    """R0 is the one rule whose justification cannot be re-derived from anything, so the
    rest of the line is the record rather than a comment to strip."""
    listing = tmp_path / "hand_exclusions.txt"
    listing.write_text("0301  # a settings form nobody would refactor\n"
                       "0302     duplicate of 0301 in all but the id\n")
    got = screen.read_group_exclusions([f"@{listing}"])
    assert got["0301"] == "a settings form nobody would refactor"
    assert got["0302"] == "duplicate of 0301 in all but the id"


def test_read_group_exclusions_of_a_whole_line_comment_is_nothing(tmp_path):
    listing = tmp_path / "hand_exclusions.txt"
    listing.write_text("# every id below was adjudicated on 2026-08-28\n")
    assert screen.read_group_exclusions([f"@{listing}"]) == {}


def test_read_group_exclusions_zero_pads_bare_numbers():
    """Group directories are NNNN; `224` and `0224` must name the same group."""
    assert set(screen.read_group_exclusions(["224"])) == {"0224"}


def test_read_group_exclusions_of_nothing_is_empty():
    assert screen.read_group_exclusions(None) == {}


# ---------------------------------------------------------------------------------------
# retarget -- rewriting manifest paths onto the exported tree
# ---------------------------------------------------------------------------------------

def test_retarget_matches_by_shape_not_by_source_prefix():
    """`new_samples/groups.jsonl` records base_dart under probe_v2/samples_v2/, because that
    copy was taken with rsync. A prefix rule would leave it pointing at the frozen tree."""
    row = {"id": "0002", "base_dart": "/elsewhere/samples_v2/0002/base.dart"}
    out = screen.retarget(row, "/src", "/dst", {"0002"})
    assert out["base_dart"] == "/dst/0002/base.dart"


def test_retarget_leaves_a_group_it_is_not_exporting_alone():
    row = {"base_dart": "/elsewhere/samples_v2/0009/base.dart"}
    assert screen.retarget(row, "/src", "/dst", {"0002"}) == row


def test_retarget_falls_back_to_the_source_prefix():
    row = {"manifest": "/src/groups.jsonl"}
    assert screen.retarget(row, "/src", "/dst", set())["manifest"] == "/dst/groups.jsonl"


def test_retarget_leaves_the_repository_clone_path_alone():
    """`source_file_absolute` is what keeps a group traceable to the commit it came from."""
    row = {"source_file_absolute": "/data/clones/foo/lib/main.dart"}
    assert screen.retarget(row, "/src", "/dst", {"0002"}) == row


def test_retarget_recurses_through_lists_and_nested_dicts():
    obj = {"a": [{"f": "/other/samples_v2/0002/rev_003_abc12345.dart"}], "n": 7, "b": None}
    out = screen.retarget(obj, "/src", "/dst", {"0002"})
    assert out["a"][0]["f"] == "/dst/0002/rev_003_abc12345.dart"
    assert out["n"] == 7 and out["b"] is None


# ---------------------------------------------------------------------------------------
# copy_file -- what makes a re-export idempotent
# ---------------------------------------------------------------------------------------

def test_copy_file_skips_a_file_already_there(tmp_path):
    src, dst = tmp_path / "a.dart", tmp_path / "out" / "a.dart"
    src.write_text("void main() {}\n")
    assert screen.copy_file(src, dst, dry_run=False)[0] is True
    assert screen.copy_file(src, dst, dry_run=False)[0] is False, \
        "copy2 preserves size and mtime, so the second call must recognise its own output"


def test_copy_file_compares_a_transformed_file_by_content(tmp_path):
    """A rewritten file never matches its source on size or mtime, so the "already there"
    test becomes a content comparison -- otherwise every re-run rewrites every file."""
    src, dst = tmp_path / "a.dart", tmp_path / "out" / "a.dart"
    src.write_text("ORIGINAL\n")
    rewrite = (lambda _t: ("REWRITTEN\n", {"images": 1}))
    acted, counts = screen.copy_file(src, dst, dry_run=False, transform=rewrite)
    assert acted is True and counts == {"images": 1}
    assert dst.read_text() == "REWRITTEN\n"
    assert screen.copy_file(src, dst, dry_run=False, transform=rewrite)[0] is False


def test_copy_file_preserves_crlf_through_a_rewrite(tmp_path):
    """82 of 0787/rev_005's lines are CRLF. Universal-newline mode would silently rewrite
    them to LF, which is a content change this pass has no business making."""
    src, dst = tmp_path / "a.dart", tmp_path / "out" / "a.dart"
    src.write_bytes(b"one\r\ntwo\r\n")
    screen.copy_file(src, dst, dry_run=False,
                     transform=lambda text: (text, {}))
    assert dst.read_bytes() == b"one\r\ntwo\r\n"


def test_copy_file_dry_run_writes_nothing(tmp_path):
    src, dst = tmp_path / "a.dart", tmp_path / "out" / "a.dart"
    src.write_text("x\n")
    assert screen.copy_file(src, dst, dry_run=True)[0] is True
    assert not dst.exists()


# ---------------------------------------------------------------------------------------
# revisions_by_group
# ---------------------------------------------------------------------------------------

def test_revisions_by_group_sorts_by_ordinal_and_skips_non_group_dirs(tmp_path):
    (tmp_path / "0007").mkdir()
    for name in ("rev_010_dddddddd.dart", "rev_002_bbbbbbbb.dart", "base.dart",
                 "dependencies.dart"):
        (tmp_path / "0007" / name).write_text("//\n")
    (tmp_path / "checkpoints").mkdir()
    (tmp_path / "checkpoints" / "rev_001_aaaaaaaa.dart").write_text("//\n")

    got = screen.revisions_by_group(tmp_path)
    assert list(got) == ["0007"], "only NNNN directories are groups"
    assert [o for o, _, _ in got["0007"]] == [2, 10], \
        "ordinal 10 sorts after 2; a lexical sort would put it first"


# ---------------------------------------------------------------------------------------
# the checkpoint mode -- what stops a resume crossing a rule edit
# ---------------------------------------------------------------------------------------

class FakeBackend:
    """Stands in for `DartBackend` so the mode tests need no Dart toolchain."""

    def __init__(self, name="dart", digest="deadbeef"):
        self.name, self._digest = name, digest

    def fingerprint(self):
        return self._digest


def a_mode(tmp_path, **over):
    kw = dict(strict=False, keep_unpairable=False, screen_revisions=True,
              source=tmp_path / "src", dest=tmp_path / "dst",
              fix_images_on=True, backend=FakeBackend(), prune_imports=True)
    kw.update(over)
    return screen.screen_mode(**kw)


def test_screen_mode_carries_the_rule_digest_and_the_value_digest(tmp_path):
    mode = a_mode(tmp_path)
    assert mode["rules"] == "deadbeef"
    assert mode["values"], "editing config/fixture_values.json must invalidate a checkpoint"


def test_screen_mode_changes_when_a_rule_is_edited(tmp_path):
    assert a_mode(tmp_path) != a_mode(tmp_path, backend=FakeBackend(digest="feedface"))


@pytest.mark.parametrize("over", [
    {"strict": True},
    {"keep_unpairable": True},
    {"screen_revisions": False},
    {"fix_images_on": False},
    {"prune_imports": False},
])
def test_screen_mode_changes_when_any_screening_decision_changes(tmp_path, over):
    assert a_mode(tmp_path) != a_mode(tmp_path, **over)


def test_screen_mode_changes_with_dest(tmp_path):
    assert a_mode(tmp_path) != a_mode(tmp_path, dest=tmp_path / "other")


def write_checkpoint(directory: Path, repo: str, mode: dict, groups: dict) -> None:
    directory.mkdir(parents=True, exist_ok=True)
    (directory / f"{repo}.json").write_text(
        json.dumps({"repo": repo, "mode": mode, "groups": groups}))


def test_load_screen_checkpoints_replays_a_matching_mode(tmp_path):
    mode = a_mode(tmp_path)
    write_checkpoint(tmp_path / "ck", "owner_repo", mode,
                     {"0001": {"files": {}, "rules": [], "norm_hash": "h",
                               "representative": "rev_001_aaaaaaaa.dart"}})
    records, stale = screen.load_screen_checkpoints(tmp_path / "ck", mode)
    assert stale == 0
    assert records["0001"]["repo"] == "owner_repo"


def test_load_screen_checkpoints_rejects_a_checkpoint_from_another_mode(tmp_path):
    """Ignored rather than trusted: resuming across a rule edit is the bug the mode exists
    to prevent, and a silent replay is indistinguishable from a correct one."""
    write_checkpoint(tmp_path / "ck", "owner_repo", a_mode(tmp_path, strict=True), {"0001": {}})
    records, stale = screen.load_screen_checkpoints(tmp_path / "ck", a_mode(tmp_path))
    assert records == {} and stale == 1


def test_load_screen_checkpoints_of_a_missing_directory_is_empty(tmp_path):
    assert screen.load_screen_checkpoints(tmp_path / "nope", a_mode(tmp_path)) == ({}, 0)


# ---------------------------------------------------------------------------------------
# read_json -- a manifest a running mine may be rewriting under us
# ---------------------------------------------------------------------------------------

def test_read_json_returns_the_default_for_a_missing_file(tmp_path):
    assert screen.read_json(tmp_path / "nope.json", {"d": 1}) == {"d": 1}


def test_read_json_returns_the_default_for_a_half_written_file(tmp_path):
    """`mining.checkpoints.write` uses a plain write_text, so a concurrent reader can
    catch a truncated file. Treating it as not-yet-there is what a mid-mine repo IS."""
    p = tmp_path / "half.json"
    p.write_text('{"pairs": [')
    assert screen.read_json(p, {}) == {}


# ---------------------------------------------------------------------------------------
# verification_rules -- R10/R11/R12, read from the manifest and never from the file
# ---------------------------------------------------------------------------------------

def jsonl(path: Path, rows: list[dict]) -> None:
    path.write_text("".join(json.dumps(r) + "\n" for r in rows))


def test_verification_rules_fires_nothing_when_no_row_carries_a_verdict(tmp_path):
    """A corpus mined under spm <= 0.5.1 carries no verdict. Defaulting absent to "unclean"
    would screen every one of them to zero; silence is the honest third answer."""
    jsonl(tmp_path / "code_rows.jsonl", [{"id": "0001", "file": "/x/0001/rev_001_a.dart"}])
    fired, cover = screen.verification_rules(tmp_path)
    assert fired == {}
    assert cover["files_covered"] == 1, "the row was still SEEN, which is what tells the " \
                                        "two silences apart"


def test_verification_rules_fires_r10_on_an_unverified_transplant(tmp_path):
    jsonl(tmp_path / "code_rows.jsonl",
          [{"id": "0001", "file": "/x/0001/rev_001_a.dart", "verified": False}])
    fired, _ = screen.verification_rules(tmp_path)
    assert fired["0001"]["rev_001_a.dart"] == [screen.UNVERIFIED_RULE]


def test_verification_rules_fires_r10_on_a_verified_row_with_errors(tmp_path):
    jsonl(tmp_path / "code_rows.jsonl",
          [{"id": "0001", "file": "/x/0001/rev_001_a.dart",
            "verified": True, "errorCount": 2}])
    fired, _ = screen.verification_rules(tmp_path)
    assert fired["0001"]["rev_001_a.dart"] == [screen.UNVERIFIED_RULE]


def test_verification_rules_fires_r11_and_r12_from_their_own_fields(tmp_path):
    jsonl(tmp_path / "code_rows.jsonl",
          [{"id": "0001", "file": "/x/0001/rev_001_a.dart", "verified": True,
            "sourceDependenciesResolved": False, "thirdPartyInlineReverted": True}])
    fired, _ = screen.verification_rules(tmp_path)
    assert fired["0001"]["rev_001_a.dart"] == [screen.SOURCE_UNRESOLVED_RULE,
                                               screen.INLINE_REVERTED_RULE]


def test_verification_rules_keys_by_file_name_not_by_the_path_the_row_carries(tmp_path):
    """Those paths are absolute and point wherever the mine wrote them, which is not where
    an exported corpus sits."""
    jsonl(tmp_path / "code_rows.jsonl",
          [{"id": "0001", "file": "/wherever/the/mine/put/it/rev_001_a.dart",
            "verified": False}])
    fired, _ = screen.verification_rules(tmp_path)
    assert list(fired["0001"]) == ["rev_001_a.dart"]


def test_verification_rules_lets_a_clean_manifest_row_win_over_a_checkpoint(tmp_path):
    """A checkpoint is a snapshot of one repository's run; the manifest is the whole mine's
    settled output. Where both speak, the settled one is the later word."""
    jsonl(tmp_path / "code_rows.jsonl",
          [{"id": "0001", "file": "/x/0001/rev_001_a.dart", "verified": True}])
    ck = tmp_path / "checkpoints"
    ck.mkdir()
    (ck / "owner_repo.json").write_text(json.dumps({
        "repo_name": "owner/repo",
        "code_rows": [{"id": "0001", "file": "/x/0001/rev_001_a.dart",
                       "status": "isolated", "verified": False}]}))
    fired, cover = screen.verification_rules(tmp_path, ck)
    assert fired == {}, "the manifest already settled this file as clean"
    assert cover["files_from_checkpoints"] == 0


def test_verification_rules_falls_back_to_checkpoints_for_a_file_no_manifest_covers(tmp_path):
    """`mine` writes its manifests when it EXITS, so a corpus whose mine is still running
    carries none and R10 would pass the whole corpus -- transplants spm already rejected
    included. The per-repository checkpoints answer for that part."""
    ck = tmp_path / "checkpoints"
    ck.mkdir()
    (ck / "owner_repo.json").write_text(json.dumps({
        "repo_name": "owner/repo",
        "code_rows": [{"id": "0001", "file": "/x/0001/rev_001_a.dart",
                       "status": "isolated", "verified": False}]}))
    fired, cover = screen.verification_rules(tmp_path, ck)
    assert fired["0001"]["rev_001_a.dart"] == [screen.UNVERIFIED_RULE]
    assert cover["files_from_checkpoints"] == 1


def test_verification_rules_ignores_an_unchanged_row(tmp_path):
    """An `unchanged` row records a commit that left the transplant byte-identical: no file
    of its own, and no verdict of its own."""
    ck = tmp_path / "checkpoints"
    ck.mkdir()
    (ck / "owner_repo.json").write_text(json.dumps({
        "repo_name": "owner/repo",
        "code_rows": [{"id": "0001", "file": "/x/0001/rev_002_b.dart",
                       "status": "unchanged", "verified": False}]}))
    fired, cover = screen.verification_rules(tmp_path, ck)
    assert fired == {} and cover["files_covered"] == 0


# ---------------------------------------------------------------------------------------
# group_index -- scope_key -> claimants, in order of authority
# ---------------------------------------------------------------------------------------

def test_group_index_prefers_the_manifest_over_id_map(tmp_path):
    jsonl(tmp_path / "groups.jsonl",
          [{"id": "0001", "project": "owner/repo", "source_file_relative": "lib/a.dart",
            "scope_name": "_AState"}])
    (tmp_path / "id_map.json").write_text(json.dumps(
        {"other/repo::lib/z.dart::TYPE::_ZState::0": "0001"}))
    ids_by_key, project_by_id = screen.group_index(tmp_path, None)
    assert project_by_id["0001"] == "owner/repo"
    assert ids_by_key["owner/repo::lib/a.dart::_AState"] == ["0001"]


def test_group_index_falls_back_to_id_map_mid_mine(tmp_path):
    """`groups.jsonl` is written only when the whole mine exits cleanly. Without this every
    pair would be `unmapped`, and a group of an in-flight repository would have no project
    to be HELD by."""
    (tmp_path / "id_map.json").write_text(json.dumps(
        {"owner/repo::lib/a.dart::TYPE::_AState::0": "0001"}))
    ids_by_key, project_by_id = screen.group_index(tmp_path, None)
    assert project_by_id["0001"] == "owner/repo"
    assert ids_by_key["owner/repo::lib/a.dart::_AState"] == ["0001"]


def test_group_index_keeps_every_claimant_of_a_shared_scope_key(tmp_path):
    """`mine` keys a pair by (project, file, scope name) WITHOUT the ordinal `isolate` uses,
    and that triple is not unique. Mapping key -> single id silently picked whichever group
    came last, and the choice moved when the manifest was filtered."""
    jsonl(tmp_path / "groups.jsonl", [
        {"id": "0001", "project": "o/r", "source_file_relative": "lib/a.dart",
         "scope_name": "_AState"},
        {"id": "0002", "project": "o/r", "source_file_relative": "lib/a.dart",
         "scope_name": "_AState"},
    ])
    ids_by_key, _ = screen.group_index(tmp_path, None)
    assert ids_by_key["o/r::lib/a.dart::_AState"] == ["0001", "0002"]


# ---------------------------------------------------------------------------------------
# finished_repos -- which part of the corpus is safe to screen mid-mine
# ---------------------------------------------------------------------------------------

def test_finished_repos_reads_repo_name_from_each_checkpoint(tmp_path):
    ck = tmp_path / "checkpoints"
    ck.mkdir()
    (ck / "a.json").write_text(json.dumps({"repo_name": "owner/one"}))
    (ck / "b.json").write_text(json.dumps({"repo_name": "owner/two"}))
    (ck / "c.json").write_text("{")           # being written right now
    assert screen.finished_repos(ck) == {"owner/one", "owner/two"}


def test_finished_repos_of_no_checkpoints_is_empty():
    assert screen.finished_repos(None) == set()


# ---------------------------------------------------------------------------------------
# the rule table itself
# ---------------------------------------------------------------------------------------

def test_every_rule_id_has_a_reason():
    reasons = screen.reasons()
    for rid in [r for r, _ in screen.RULES] + [
            screen.DUPLICATE_RULE, screen.NO_PAIR_RULE, screen.BINDING_RULE,
            screen.UNFINISHED_RULE, screen.MANUAL_RULE, screen.SHORT_VECTOR_RULE,
            screen.ZERO_DELTA_RULE]:
        assert reasons.get(rid), f"{rid} would print with an empty reason column"


def test_soft_rules_are_all_real_rules():
    """A typo in `SOFT_RULES` would silently soften nothing, so the id must be one that
    exists. Checked against `reasons()` rather than against `RULES`: several real rule ids
    live outside that list -- R7, R8, R9, R13, R14, R15, R16 -- because they are not per-file
    constructs, and R16 has been soft since 2026-09-08."""
    reasons = screen.reasons()
    for rid in screen.SOFT_RULES:
        assert reasons.get(rid), f"{rid} is in SOFT_RULES but is not a known rule id"


def test_rule_ids_are_unique():
    ids = [r for r, _ in screen.RULES]
    assert len(ids) == len(set(ids))


def test_verification_rules_separates_rows_seen_from_rows_carrying_a_verdict(tmp_path):
    """`groups.jsonl` names every group's `base_dart` whether or not spm ever recorded a
    verdict for it, so a corpus with NO verdicts anywhere still has full coverage. Conflating
    the two made "R10 fired on nothing" indistinguishable from "nothing was read"."""
    jsonl(tmp_path / "groups.jsonl",
          [{"id": "0001", "base_dart": "/x/0001/base.dart"}])
    jsonl(tmp_path / "code_rows.jsonl",
          [{"id": "0002", "file": "/x/0002/rev_001_a.dart", "verified": True}])
    _, cover = screen.verification_rules(tmp_path)
    assert cover["files_covered"] == 2
    assert cover["files_with_a_verdict"] == 1


# ---------------------------------------------------------------------------------------
# records_reduction -- a re-mine is not a prune
# ---------------------------------------------------------------------------------------
#
# The guard that refuses to replace an `exclusions.json` recording groups the corpus no
# longer has used to compare COUNTS, which cannot tell the two shrinks apart. On
# 2026-08-29 it blocked a legitimate run: `moss-apps/Flick` had been re-mined from 184
# groups to 123, `isolate` had rewritten that repository's manifest rows accordingly, and
# the screen refused because 1549 < 1610. `groups.jsonl` is the discriminator -- and
# `id_map.json` is not, because it is cumulative and never forgets an id.

def corpus(root: Path, ids, *, manifest=None, id_map=()) -> Path:
    """A source tree of numbered group directories, with the manifests named."""
    for gid in ids:
        (root / gid).mkdir(parents=True, exist_ok=True)
        (root / gid / "rev_001_aaaaaaaa.dart").write_text("class A {}\n")
    if manifest is not None:
        jsonl(root / "groups.jsonl",
              [{"id": g, "project": "o/r", "source_file_relative": "lib/a.dart",
                "scope_name": "_AState"} for g in manifest])
    if id_map:
        (root / "id_map.json").write_text(json.dumps(
            {f"o/r::lib/{g}.dart::State::_AState::0": g for g in id_map}))
    return root


def records(path: Path, ids) -> Path:
    path.write_text(json.dumps({"totals": {"groups": len(ids)},
                                "groups": {g: {"eligible": False} for g in ids}}))
    return path


def test_manifest_group_ids_is_none_when_the_mine_has_not_written_one(tmp_path):
    """Mid-mine there is no manifest, and "the corpus claims nothing" must not read as
    "we cannot tell what the corpus claims"."""
    assert screen.manifest_group_ids(corpus(tmp_path, ["0001"])) is None


def test_manifest_group_ids_reads_the_manifest(tmp_path):
    source = corpus(tmp_path, ["0001", "0002"], manifest=["0001", "0002"])
    assert screen.manifest_group_ids(source) == {"0001", "0002"}


def test_manifest_group_ids_ignores_id_map(tmp_path):
    """`id_map.json` is cumulative: it still carries the identities of groups a re-mine
    dropped. Reading it here -- as `group_index` deliberately does -- would make every
    re-mine look like a prune, which is the bug this whole check exists to fix."""
    source = corpus(tmp_path, ["0001"], manifest=["0001"], id_map=["0001", "0002"])
    assert screen.manifest_group_ids(source) == {"0001"}


def test_records_reduction_ok_when_nothing_left_the_corpus(tmp_path):
    source = corpus(tmp_path / "src", ["0001", "0002"], manifest=["0001", "0002"])
    prior = records(tmp_path / "exclusions.json", ["0001", "0002"])
    assert screen.records_reduction(prior, source)[0] == "ok"


def test_records_reduction_allows_a_remine(tmp_path):
    """The manifest dropped `0002` too, so the repository took its own group back."""
    source = corpus(tmp_path / "src", ["0001"], manifest=["0001"], id_map=["0001", "0002"])
    prior = records(tmp_path / "exclusions.json", ["0001", "0002"])
    verdict, ids, before, here = screen.records_reduction(prior, source)
    assert (verdict, ids, before, here) == ("remined", ["0002"], 2, 1)


def test_records_reduction_refuses_a_prune(tmp_path):
    """The directory is gone while the manifest still claims it: deleted, not re-mined."""
    source = corpus(tmp_path / "src", ["0001"], manifest=["0001", "0002"])
    prior = records(tmp_path / "exclusions.json", ["0001", "0002"])
    verdict, ids, _, _ = screen.records_reduction(prior, source)
    assert (verdict, ids) == ("pruned", ["0002"])


def test_records_reduction_refuses_when_there_is_no_manifest_to_ask(tmp_path):
    source = corpus(tmp_path / "src", ["0001"])
    prior = records(tmp_path / "exclusions.json", ["0001", "0002"])
    assert screen.records_reduction(prior, source)[0] == "unknown"


def test_records_reduction_falls_back_to_counts_for_a_record_without_group_rows(tmp_path):
    """A record predating per-group rows can only be compared by count, and a count that
    fell can be reported but never explained -- so it refuses rather than proceeds."""
    source = corpus(tmp_path / "src", ["0001"], manifest=["0001"])
    prior = tmp_path / "exclusions.json"
    prior.write_text(json.dumps({"totals": {"groups": 2}}))
    assert screen.records_reduction(prior, source)[0] == "unknown"
