"""`--resume` must continue a session, not mint a new one beside it.

`devices/lib/measure.sh::resolve_session` only ever reused a session dir that was STRICTLY
partial (`0 < complete < expected`), so two cases silently re-measured everything into a fresh
stamp: a session that was already complete (dataset-new_samples/0348 and /0344 each carry a
duplicate full session because of it) and one where nothing completed at all (0508, 0516).

`--resume` routes the choice through `status.pick_session` instead. These tests pin what it
picks; `capture.capture_complete` still owns what "done" means, and is exercised here only
through `session_progress`, so the two can never drift apart.
"""

from __future__ import annotations

import pytest

from scripts.device_runner import config, status


def _header(group: str, role: str, k: int, *, ok: bool = True, captured: int | None = None) -> str:
    n = config.N_REBUILDS if captured is None else captured
    return (
        f"# sample_id={group}/{role} exec_index={k} ok={ok} perf_lines={n} vm_events={n} "
        f"battery_pct=63 soc_temp_millic=43000 battery_temp_c=32.8 charging=False "
        f"ts=2026-09-10T12:00:0{k % 10}+00:00\n"
    )


@pytest.fixture
def corpus(tmp_path, monkeypatch):
    """A dataset root under tmp_path; returns a `write(session, role, k, ...)` helper."""
    monkeypatch.setattr(config, "OUT_DIR", tmp_path)
    monkeypatch.setattr(config, "device_slug", lambda: "redmi9t")

    def write(session: str, role: str, k: int, *, group: str = "0455", **kw) -> None:
        d = config.capture_dir(session, group, role)
        d.mkdir(parents=True, exist_ok=True)
        (d / f"e{k}.log").write_text(_header(group, role, k, **kw), encoding="utf-8")

    return write


def test_no_sessions_yet(corpus):
    """A group nobody has measured resumes nothing — the caller mints a fresh stamp."""
    assert status.pick_session("0455") == (None, 0, 0)


def test_prefers_the_more_complete_session_over_the_newer_one(corpus):
    """The case that strands progress: a later run died early in a dir of its own.

    Newest-wins would hand the runner the empty dir and re-measure all four.
    """
    for k in range(4):
        corpus("20260910-010000", "rev_002", k)
    corpus("20260910-020000", "rev_002", 0, ok=False, captured=0)

    assert status.pick_session("0455") == ("20260910-010000", 4, 4)


def test_ties_break_on_the_newest_session(corpus):
    """Equal progress -> the newest, which is what a plain re-run of a finished group wants."""
    corpus("20260910-010000", "rev_002", 0)
    corpus("20260910-020000", "rev_002", 0)

    assert status.pick_session("0455") == ("20260910-020000", 1, 1)


def test_a_session_with_nothing_complete_is_still_continued(corpus):
    """0508/0516 on disk: every capture failed. That dir is resumed, not orphaned."""
    corpus("20260910-192307", "rev_002", 3, ok=False, captured=0)
    corpus("20260910-192307", "rev_007", 6, ok=False, captured=0)

    assert status.pick_session("0455") == ("20260910-192307", 0, 2)


def test_scoring_agrees_with_capture_complete(corpus):
    """`ok=False` and a short capture are present-but-not-complete, exactly as the runner reads
    them — a truncated execution is re-measured on resume rather than inherited."""
    corpus("20260910-010000", "rev_002", 0)                                  # complete
    corpus("20260910-010000", "rev_002", 1, ok=False)                        # crashed
    corpus("20260910-010000", "rev_002", 2, captured=config.N_REBUILDS - 1)  # truncated
    corpus("20260910-010000", "rev_003", 0)                                  # complete

    assert status.pick_session("0455") == ("20260910-010000", 2, 4)


def test_a_headerless_log_is_present_but_never_complete(corpus, tmp_path):
    """`spm run` writes e<k>.jsonl mid-flight; the header is what marks the execution done."""
    d = config.capture_dir("20260910-010000", "0455", "rev_002")
    d.mkdir(parents=True)
    (d / "e0.log").write_text("flutter drive output with no header\n", encoding="utf-8")

    assert status.pick_session("0455") == ("20260910-010000", 0, 1)


def test_sessions_of_another_group_are_not_counted(corpus):
    """Sessions are per group AND per device; a pick must never reach across either."""
    corpus("20260910-010000", "rev_002", 0, group="0508")

    assert status.pick_session("0455") == (None, 0, 0)
    assert status.pick_session("0508") == ("20260910-010000", 1, 1)


# ---- --roles, the census selector ---------------------------------------------------------
#
# `--eligible-only` takes the endpoints of eligible contrasts and `--widget-type` takes a whole
# group. The set a pre-campaign validation pass needs is neither: it is the endpoints UNION the
# roles R21 condemned, and 44 of those are not endpoints -- R21 excluding their contrasts is
# what stopped them being endpoints. An endpoints-only pass validated no repair at all in 13 of
# the 19 groups repaired on 2026-09-15.

def _corpus(tmp_path):
    root = tmp_path / "corpus"
    for gid, roles in (("0001", ("rev_001_aaaa", "rev_002_bbbb")),
                       ("0002", ("rev_001_cccc",))):
        (root / gid).mkdir(parents=True)
        for r in roles:
            (root / gid / f"{r}.dart").write_text("// role")
    return root


def test_roles_selects_exactly_the_named_set(tmp_path):
    from scripts.device_runner import runner

    root = _corpus(tmp_path)
    got = runner.discover_targets(None, root=root,
                                  roles={("0001", "rev_002_bbbb"), ("0002", "rev_001_cccc")})
    assert sorted(t["sample_id"] for t in got) == ["0001/rev_002_bbbb", "0002/rev_001_cccc"]


def test_the_role_list_tolerates_comments_and_blanks(tmp_path):
    from scripts.device_runner import runner

    f = tmp_path / "roles.txt"
    f.write_text("# a header\n\n0001/rev_001_aaaa\n0002/rev_001_cccc  # trailing\n")
    assert runner.read_role_list(f) == {("0001", "rev_001_aaaa"), ("0002", "rev_001_cccc")}


def test_a_malformed_line_refuses_rather_than_skipping(tmp_path):
    """A silently dropped line is a role that quietly goes unvalidated, which is the exact
    failure this selector exists to prevent."""
    from scripts.device_runner import runner

    f = tmp_path / "roles.txt"
    f.write_text("0001/rev_001_aaaa\nnot-a-role\n")
    with pytest.raises(SystemExit):
        runner.read_role_list(f)


def test_an_empty_list_refuses(tmp_path):
    from scripts.device_runner import runner

    f = tmp_path / "roles.txt"
    f.write_text("# nothing but comments\n")
    with pytest.raises(SystemExit):
        runner.read_role_list(f)


def test_the_census_is_a_union_not_an_intersection(tmp_path, monkeypatch):
    """The whole point. `2411`'s two repaired roles are not endpoints, so an intersection --
    which is what `--roles` with `--eligible-only` computes -- drops them."""
    import json
    from scripts import census_roles, render_gate

    root = _corpus(tmp_path)
    (root / "exclusions.json").write_text(json.dumps({"pairs": [
        {"group": "0001", "verdict": "eligible", "pair_id": "k@aaaa..bbbb"}]}))
    monkeypatch.setattr(render_gate, "TABLE", tmp_path / "render.json")
    (tmp_path / "render.json").write_text(json.dumps({"groups": {
        "0002": {"rev_001_cccc": {"verdict": "renders_error"}}}}))

    endpoints = census_roles.endpoint_roles(root)
    condemned = census_roles.condemned_roles(root)
    assert ("0002", "rev_001_cccc") not in endpoints, "fixture must model the real case"
    assert ("0002", "rev_001_cccc") in (endpoints | condemned)
    assert ("0002", "rev_001_cccc") not in (endpoints & condemned)


# ---- --best and --all: the plan pass behind `--resume all` ---------------------------------
#
# `devices/lib/pipeline.sh` asks `status --all --best --quiet` ONCE, before the device is
# touched, and drops the groups that owe nothing. Two things have to hold for that to be safe:
# --best must read the session `--resume` will actually continue (not the newest), and --all
# must report every group of the corpus, each counted against its own captures.

def test_best_scores_the_session_resume_will_continue(corpus):
    """Same corpus as the stranded-progress case: newest-wins reads 0/4, --best reads 4/4.

    A caller acting on the newest-wins number would re-measure a finished group.
    """
    for k in range(4):
        corpus("20260910-010000", "rev_002", k)
    corpus("20260910-020000", "rev_002", 0, ok=False, captured=0)

    def targets(group, eligible_only=False):
        return [{"sample_id": f"{group}/rev_002"}]

    best = status.progress_of("0455", executions=4, eligible_only=False, session=None,
                              best=True, discover_targets=targets)
    newest = status.progress_of("0455", executions=4, eligible_only=False, session=None,
                                best=False, discover_targets=targets)
    assert best == ("20260910-010000", 4, 4, 4)
    assert newest == ("20260910-020000", 0, 1, 4)


def test_corpus_groups_lists_group_dirs_only_and_sorts_them(tmp_path, monkeypatch):
    """Sorted, because `--resume all` measures in this order and a rerun must repeat it.

    Everything at a corpus root that is not a numeric directory is bookkeeping -- the
    exclusions record, the maps, the caches -- and must never be taken for a group.
    """
    root = _corpus(tmp_path)
    (root / "0003").mkdir()
    (root / "exclusions.json").write_text("{}")
    (root / "_attic").mkdir()
    monkeypatch.setattr(config, "SAMPLES_ROOT", root)

    assert status.corpus_groups() == ["0001", "0002", "0003"]


def test_all_reports_every_group_against_its_own_captures(corpus, tmp_path, monkeypatch, capsys):
    """One line per group, sorted, `<group> <complete>/<expected>` under --quiet.

    `0001` has two roles and one complete execution; `0002` has one role and no session at
    all -- and must still be listed, because the caller is building a work list and "absent"
    would look the same as "done".
    """
    import sys

    root = _corpus(tmp_path)
    monkeypatch.setattr(config, "SAMPLES_ROOT", root)
    corpus("20260910-010000", "rev_001_aaaa", 0, group="0001")
    monkeypatch.setattr(sys, "argv",
                        ["status", "--all", "--best", "--quiet", "--executions", "2"])

    status.main()

    assert capsys.readouterr().out.splitlines() == ["0001 1/4", "0002 0/2"]


def test_all_refuses_the_single_group_flags(tmp_path, monkeypatch):
    """--all is corpus-wide; --group/--session/--pick-session each name one group.

    Honouring one of them silently would hand the shell a plan for a different set than the
    one it asked about.
    """
    import sys

    monkeypatch.setattr(config, "SAMPLES_ROOT", _corpus(tmp_path))
    for extra in (["--group", "0001"], ["--session", "20260910-010000"], ["--pick-session"]):
        monkeypatch.setattr(sys, "argv", ["status", "--all", *extra])
        with pytest.raises(SystemExit):
            status.main()


def test_neither_group_nor_all_is_refused(monkeypatch):
    """`--group` stopped being argparse-required when `--all` arrived; the refusal did not."""
    import sys

    monkeypatch.setattr(sys, "argv", ["status", "--quiet"])
    with pytest.raises(SystemExit):
        status.main()
