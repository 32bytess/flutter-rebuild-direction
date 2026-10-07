"""The export: which groups ship, which files of them ship, and what is never deleted.

Screening decides eligibility; this decides what lands on disk for the runner to measure, and
the two are not the same set. A group ships when it CARRIES A CONTRAST, not when its own
representative screens clean -- the 2026-08-27 corpus shipped 173 groups of which 85 carried
an eligible pair, and the other 88 were directories, fixtures and `rev_*.dart` that no
contrast could ever use.

Runs with `--no-fixtures`, so the exported corpus here is deliberately one that would not
mount: the fixture phase needs an `spm analyze` pass this suite does not pay for. What is
under test is the placement -- the copying, the manifest filtering, the idempotence, and the
things that must never be removed.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

import pytest

from scripts.tests import mini_corpus
from scripts.tests.regolden import CONTAINER, run, screen_argv

pytestmark = pytest.mark.dart


def export_to(root: Path, extra: list[str] | None = None) -> tuple[Path, Path, str]:
    """Build, screen and export the mini corpus. Returns (source, dest, stdout)."""
    source = mini_corpus.build(root / "corpus")
    dest = root / "dest"
    out = run(screen_argv(source, root / "records",
                          ["--dest", str(dest), "--no-fixtures", *(extra or [])]))
    return source, dest, out.stdout


@pytest.fixture(scope="module")
def exported(tmp_path_factory):
    return export_to(tmp_path_factory.mktemp("export"))


def shipped(dest: Path) -> dict[str, list[str]]:
    return {d.name: sorted(f.name for f in d.iterdir())
            for d in sorted(dest.glob("*/")) if d.name.isdigit()}


# ---------------------------------------------------------------------------------------

def test_only_a_group_carrying_a_contrast_ships(exported):
    """0002, 0004, 0005 and 0009 all screen clean on their representative and carry nothing
    measurable; 0003 has one revision; 0006 is held; 0007 is a duplicate."""
    _, dest, _ = exported
    assert list(shipped(dest)) == ["0001", "0010"]


def test_a_group_that_screens_clean_but_carries_no_contrast_is_reported(exported):
    """The difference between "measurable" and "has something to measure across" is what put
    88 unusable groups in the last corpus, so it is said out loud."""
    _, _, stdout = exported
    assert "NOT shipped:" in stdout
    assert "no eligible contrast" in stdout


def test_every_revision_of_a_shipped_group_lands(exported):
    _, dest, _ = exported
    assert shipped(dest)["0001"] == ["rev_001_aaaa0001.dart", "rev_002_aaaa0002.dart",
                                     "rev_003_aaaa0003.dart"]


def test_ordinals_are_never_renumbered(exported):
    """Surviving `rev_NNN` names keep meaning what the pair records say they mean, gaps and
    all -- the same contract `id` has."""
    source, dest, _ = exported
    assert shipped(dest)["0001"] == sorted(
        f.name for f in (source / "0001").glob("rev_*.dart"))


def test_manifests_are_filtered_to_what_shipped(exported):
    _, dest, _ = exported
    for name in ("groups.jsonl", "code_rows.jsonl"):
        rows = [json.loads(x) for x in (dest / name).read_text().splitlines() if x.strip()]
        assert {r["id"] for r in rows} == {"0001", "0010"}, \
            f"{name} describes a group not at --dest"


def test_manifest_paths_are_rewritten_onto_the_exported_tree(exported):
    """An exported index that points into `--source` describes a directory other than the one
    it ships with."""
    _, dest, _ = exported
    rows = [json.loads(x) for x in (dest / "code_rows.jsonl").read_text().splitlines()
            if x.strip()]
    assert all(r["file"].startswith(str(dest)) for r in rows)


def test_the_repository_clone_path_survives_the_rewrite(exported):
    """`source_file_absolute` is what keeps a group traceable back to the commit it came
    from, and it matches neither rewrite rule."""
    _, dest, _ = exported
    row = json.loads((dest / "groups.jsonl").read_text().splitlines()[0])
    assert row["source_file_absolute"].startswith("/clones/")


def test_id_map_is_filtered_but_ids_are_never_reassigned(exported):
    """An id lands in result tables and figures; renumbering silently invalidates every one."""
    _, dest, _ = exported
    assert set(json.loads((dest / "id_map.json").read_text()).values()) == {"0001", "0010"}


def test_a_re_export_copies_nothing(tmp_path):
    """`copy2` preserves size and mtime, so "already there" is an exact statement rather than
    a heuristic -- which is what makes re-running as the mine finishes repositories cheap."""
    source = mini_corpus.build(tmp_path / "corpus")
    dest, records = tmp_path / "dest", tmp_path / "records"
    argv = screen_argv(source, records, ["--dest", str(dest), "--no-fixtures"])
    first = run(argv).stdout
    second = run(argv).stdout
    assert "6 copied, 0 already current" in first
    assert "0 copied, 6 already current" in second


def test_a_held_group_is_neither_exported_nor_deleted(exported):
    """owner/beta has no checkpoint, so its groups are still gaining revisions."""
    source, dest, stdout = exported
    assert not (dest / "0006").exists()
    assert (source / "0006").is_dir()
    assert "HELD 1 groups" in stdout


# ---------------------------------------------------------------------------------------
# What --prune must not remove
# ---------------------------------------------------------------------------------------

def test_a_stale_group_is_reported_and_left_in_place(tmp_path):
    """A group this run excludes but an earlier one exported usually means the rule set
    changed, which is a decision to confirm rather than to apply."""
    source, dest, _ = export_to(tmp_path)
    assert (dest / "0001").is_dir()
    out = run(screen_argv(source, tmp_path / "records",
                          ["--dest", str(dest), "--no-fixtures",
                           "--exclude-groups", "0001  # adjudicated out"])).stdout
    assert "STALE: 1 groups" in out
    assert (dest / "0001").is_dir(), "silent deletion is not offered"


def test_prune_removes_a_stale_group(tmp_path):
    source, dest, _ = export_to(tmp_path)
    run(screen_argv(source, tmp_path / "records",
                    ["--dest", str(dest), "--no-fixtures", "--prune",
                     "--exclude-groups", "0001"]))
    assert not (dest / "0001").exists()


def test_prune_never_removes_a_group_holding_an_authored_file(tmp_path):
    """`--dest` is derived for everything the screen puts there, but it is where the fixture
    work happens and that work is not rebuildable from `--source`."""
    source, dest, _ = export_to(tmp_path)
    (dest / "0001" / "dependencies.dart").write_text("// hand-filled\nint fixtureCount = 3;\n")
    out = run(screen_argv(source, tmp_path / "records",
                          ["--dest", str(dest), "--no-fixtures", "--prune",
                           "--exclude-groups", "0001"])).stdout
    assert "KEPT 1 excluded groups that hold authored files" in out
    assert (dest / "0001" / "dependencies.dart").is_file()


def test_force_prune_removes_it(tmp_path):
    source, dest, _ = export_to(tmp_path)
    (dest / "0001" / "dependencies.dart").write_text("// hand-filled\n")
    run(screen_argv(source, tmp_path / "records",
                    ["--dest", str(dest), "--no-fixtures", "--force-prune",
                     "--exclude-groups", "0001"]))
    assert not (dest / "0001").exists()


def test_dry_run_writes_no_destination(tmp_path):
    source = mini_corpus.build(tmp_path / "corpus")
    dest = tmp_path / "dest"
    run(screen_argv(source, tmp_path / "records",
                    ["--dest", str(dest), "--no-fixtures", "--dry-run"]))
    assert not (dest / "0001").exists()


# ---------------------------------------------------------------------------------------
# Refusals
# ---------------------------------------------------------------------------------------

def test_vectors_with_a_fixture_export_is_refused(tmp_path):
    """`--vectors` skips the phase that BUILDS the fixtures, so the export has nothing to
    write and dies on a bare KeyError inside `_rewriter`. Refused rather than papered over:
    the fallback would ship a corpus with no `dependencies.dart`, which does not mount."""
    source = mini_corpus.build(tmp_path / "corpus")
    out = run(screen_argv(source, tmp_path / "records",
                          ["--dest", str(tmp_path / "dest")]), expect_failure=True)
    assert "--vectors cannot be combined with fixture generation" in out.stderr


def test_dest_may_not_be_source(tmp_path):
    source = mini_corpus.build(tmp_path / "corpus")
    out = run(screen_argv(source, tmp_path / "records",
                          ["--dest", str(source), "--no-fixtures"]), expect_failure=True)
    assert "--dest must differ from --source" in out.stderr


def test_a_corpus_with_no_spm_verdict_at_all_is_refused(tmp_path):
    """R10 fires hardest of any rule -- 801 of 1,444 groups on the round-4 corpus -- and it
    reads the manifests, which `mine` writes when it EXITS. A corpus whose mine has not
    flushed them reads as "no verdict" everywhere and R10 passes it whole, transplants spm
    already rejected included. R13 aborts on the same shape of vacuity; so does this."""
    source = mini_corpus.build(tmp_path / "corpus")
    (source / "code_rows.jsonl").unlink()
    for f in (source / "checkpoints").glob("*.json"):
        data = json.loads(f.read_text())
        data["code_rows"] = []
        f.write_text(json.dumps(data))
    out = run(screen_argv(source, tmp_path / "records", ["--report-only"]),
              expect_failure=True)
    assert "has no input" in out.stderr and "--allow-unverified" in out.stderr


def test_allow_unverified_is_how_you_say_you_meant_it(tmp_path):
    """A corpus genuinely mined under spm <= 0.5.1 has no verdicts to find."""
    source = mini_corpus.build(tmp_path / "corpus")
    (source / "code_rows.jsonl").unlink()
    for f in (source / "checkpoints").glob("*.json"):
        data = json.loads(f.read_text())
        data["code_rows"] = []
        f.write_text(json.dumps(data))
    records = tmp_path / "records"
    run(screen_argv(source, records, ["--report-only", "--allow-unverified"]))
    out = json.loads((records / "exclusions.json").read_text())
    assert out["provenance"]["flags"]["allow_unverified"] is True, \
        "the record has to say the corpus was screened without R10"


# ---------------------------------------------------------------------------------------
# --prune-to-endpoints: ship only the roles that will be measured
# ---------------------------------------------------------------------------------------

def prune_argv(source: Path, records: Path, dest: Path) -> list[str]:
    return screen_argv(source, records,
                       ["--dest", str(dest), "--no-fixtures", "--prune-to-endpoints"])


def pruned(root: Path) -> tuple[Path, Path, str]:
    """Export, then prune. That order is the contract, not the test's convenience: the prune
    is a final pass over a corpus whose fixture work is done, and it refuses a `--dest` that
    does not exist yet."""
    source, dest, _ = export_to(root)
    out = run(prune_argv(source, root / "records", dest)).stdout
    return source, dest, out


def test_a_role_that_is_an_endpoint_of_nothing_does_not_ship(tmp_path):
    """0010's rev_003 screens clean and its vector duplicates rev_002's, so the duplicate
    filter drops it before any pair exists. It would be measured for nothing."""
    source, dest, _ = pruned(tmp_path)
    assert shipped(dest)["0010"] == ["rev_001_aaab0001.dart", "rev_002_aaab0002.dart"]
    # 0001's three roles are all endpoints of one of its three contrasts; nothing is lost.
    assert len(shipped(dest)["0001"]) == 3


def test_the_prune_leaves_an_ordinal_gap_rather_than_renumbering(tmp_path):
    """The surviving names still mean what the pair records say they mean -- the same
    contract the rule-based drop has."""
    source, dest, _ = pruned(tmp_path)
    assert (source / "0010" / "rev_003_aaab0003.dart").is_file()
    assert not (dest / "0010" / "rev_003_aaab0003.dart").exists()


def test_the_prune_is_reported_apart_from_the_rules(tmp_path):
    """A non-endpoint role fires no rule. Counting it as one would report the prune as a
    rule's cost, which is why the fixture clashes had to be subtracted back out."""
    _, _, out = pruned(tmp_path)
    assert "endpoint of no eligible contrast" in out
    assert "5 roles ship, across 2 groups" in out


def test_the_prune_removes_a_role_an_earlier_run_shipped(tmp_path):
    """The copy loop only ADDS, so pruning has to be a claim about what the directory holds
    and not only about what this run wrote."""
    source, dest, _ = export_to(tmp_path)
    assert (dest / "0010" / "rev_003_aaab0003.dart").is_file()
    out = run(prune_argv(source, tmp_path / "records", dest)).stdout
    assert not (dest / "0010" / "rev_003_aaab0003.dart").exists()
    assert "left by an earlier run" in out


def test_the_prune_never_removes_an_authored_file(tmp_path):
    """The same derived/authored test `--prune` uses for a whole group: a file with no
    counterpart in `--source` is hand-written work and is never removed."""
    source, dest, _ = export_to(tmp_path)
    (dest / "0010" / "rev_003_aaab0003.dart").unlink()
    (dest / "0010" / "notes.md").write_text("hand-written\n")
    run(prune_argv(source, tmp_path / "records", dest))
    assert (dest / "0010" / "notes.md").is_file()


def test_the_manifests_follow_the_prune(tmp_path):
    """A `code_rows.jsonl` row for a role that is not there indexes a missing file."""
    source, dest, _ = pruned(tmp_path)
    rows = [json.loads(x) for x in (dest / "code_rows.jsonl").read_text().splitlines()
            if x.strip()]
    assert not any("rev_003_aaab0003" in r["file"] for r in rows)
    assert all(Path(r["file"]).is_file() for r in rows)


def test_a_dry_run_prune_deletes_nothing(tmp_path):
    source, dest, _ = export_to(tmp_path)
    out = run(screen_argv(source, tmp_path / "records",
                          ["--dest", str(dest), "--no-fixtures", "--prune-to-endpoints",
                           "--dry-run"])).stdout
    assert "would leave behind" in out
    assert (dest / "0010" / "rev_003_aaab0003.dart").is_file()
    assert not (dest / ".roles_pruned.json").exists()


def test_the_prune_is_idempotent(tmp_path):
    source, dest, _ = pruned(tmp_path)
    second = run(prune_argv(source, tmp_path / "records", dest)).stdout
    assert "0 copied, 5 already current" in second
    assert "left by an earlier run" not in second


def test_an_r13_excluded_contrast_contributes_no_endpoint(tmp_path):
    """`bindings.apply` flips an R13 failure to `excluded` and leaves `_endpoints` in place,
    so the endpoint set has to be keyed off the VERDICT. 0008 is the R13 group."""
    source, dest, _ = pruned(tmp_path)
    stamp = json.loads((dest / ".roles_pruned.json").read_text())
    assert "0008" not in stamp["endpoint_roles"]


def test_the_stamp_agrees_with_the_record_the_runner_reads(tmp_path):
    """`device_runner --eligible-only` derives the same set independently, from
    `exclusions.json`'s pairs. The two agreeing is the check; deriving it once and trusting
    it everywhere is what this pipeline does not do."""
    import re

    _, dest, _ = pruned(tmp_path)
    stamp = json.loads((dest / ".roles_pruned.json").read_text())
    doc = json.loads((tmp_path / "records" / "exclusions.json").read_text())

    from_pairs: dict[str, set[str]] = {}
    for pair in doc["pairs"]:
        if pair["verdict"] != "eligible":
            continue
        a, b = re.search(r"@([0-9a-f]{8})\.\.([0-9a-f]{8})$", pair["pair_id"]).groups()
        from_pairs.setdefault(pair["group"], set()).update((a, b))

    on_disk = {gid: {f.name.rsplit("_", 1)[-1][:-5] for f in (dest / gid).glob("rev_*.dart")}
               for gid in from_pairs}
    assert on_disk == from_pairs
    assert {g: len(r) for g, r in stamp["endpoint_roles"].items()} == \
           {g: len(r) for g, r in from_pairs.items()}


def test_the_prune_is_refused_while_a_fixture_is_unfilled(tmp_path):
    """The one-way door only opens on the far side of the fixture pass: `anchor_sha()` takes
    the group's lowest-ordinal revision PRESENT, so pruning first can move a stored value."""
    source, dest, _ = export_to(tmp_path)
    (dest / "0010" / "dependencies.dart").write_text(
        "// generated\nlate int fixtureCount; // TODO: value\n")
    out = run(prune_argv(source, tmp_path / "records", dest), expect_failure=True)
    assert "the fixture pass is not finished" in out.stderr
    assert "still carry `// TODO: value`" in out.stderr
    assert (dest / "0010" / "rev_003_aaab0003.dart").is_file(), "refused, and deleted nothing"


def test_a_pruned_corpus_refuses_the_two_tools_that_read_roles_off_disk(tmp_path):
    source, dest, _ = pruned(tmp_path)
    for tool in ("scripts.fixture_values", "scripts.maximal_branch"):
        out = run([sys.executable, "-m", tool, "--root", str(dest)], expect_failure=True)
        assert "pruned to measured endpoints" in (out.stderr + out.stdout), tool
