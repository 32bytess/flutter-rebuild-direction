"""R17/R18: whether the study may redistribute what is inside a transplant.

`spm isolate` carries a third-party widget's own SOURCE into the file, recursively, and the
export then strips the `package:` imports -- so a shipped `rev_*.dart` can hold package code
with no import, no comment and no attribution. The repository allow-list in
`scripts/collector` never saw any of it: it gates the HOST repository at acquisition and
says nothing about that repository's dependencies.

Four properties are load-bearing and are what this file pins:

  * a file that carries no package source, or whose inlining was REVERTED, passes without
    consulting anything -- there is nothing in it to license;
  * a file that carries package source and cannot be ATTRIBUTED fires. Passing it would make
    R17's silence mean two different things, which is the failure `verification_rules`
    documents for R10: a count with no name is evidence that nobody looked, not evidence of
    an allowed licence;
  * the policy is FAIL-CLOSED. A LICENSE matching no id, or more than one, is unrecognised
    and therefore not allowed;
  * a pool where NOT ONE row carries an inlining count ABORTS, because the field is omitted
    by builds older than spm 0.6.0 and silence there means "not reported", never "none".
"""

from __future__ import annotations

import json
from pathlib import Path

import pytest

from scripts.screen import licenses
from scripts.screen.rules import PACKAGE_LICENSE_RULE, REPO_LICENSE_RULE

POLICY = {
    "allowed_spdx": ["MIT", "Apache-2.0", "BSD-3-Clause"],
    "spdx_markers": {
        "MIT": {"match": "all",
                "phrases": ["MIT License", "Permission is hereby granted, free of charge"]},
        "Apache-2.0": {"match": "all",
                       "phrases": ["Apache License", "Version 2.0, January 2004"]},
        "BSD-3-Clause": {"match": "all",
                         "phrases": ["Redistributions in binary form", "Neither the name of"]},
    },
    "repo_spdx_aliases": {"mit": "MIT", "apache-2.0": "Apache-2.0",
                          "bsd-3-clause": "BSD-3-Clause"},
}

MIT_TEXT = ("MIT License\n\nCopyright (c) 2020 Someone\n\n"
            "Permission is hereby granted, free of charge, to any person obtaining a copy")
GPL_TEXT = ("GNU GENERAL PUBLIC LICENSE\nVersion 3, 29 June 2007\n\n"
            "Everyone is permitted to copy and distribute verbatim copies")


def cache_with(tmp_path: Path, packages: dict[str, str]) -> Path:
    """A stand-in pub cache: `{"<name>-<version>": "<LICENSE text>"}`."""
    root = tmp_path / "pub_cache"
    for directory, text in packages.items():
        target = root / directory
        target.mkdir(parents=True, exist_ok=True)
        (target / "LICENSE").write_text(text, encoding="utf-8")
    root.mkdir(parents=True, exist_ok=True)
    return root


def judge_for(tmp_path: Path, *, packages: dict[str, str],
              provenance: dict[tuple[str, str], dict]) -> licenses.PackageLicenceJudge:
    return licenses.PackageLicenceJudge(POLICY, provenance, cache_with(tmp_path, packages))


# ---------------------------------------------------------------------------------------
# Recognising a licence
# ---------------------------------------------------------------------------------------

def test_every_marker_must_appear_before_an_id_is_awarded():
    """The three permissive texts quote each other, so one phrase is not enough."""
    markers = POLICY["spdx_markers"]
    assert licenses.spdx_of_text(MIT_TEXT, markers) == "MIT"
    assert licenses.spdx_of_text("MIT License\n\nand nothing else", markers) is None


def test_an_unrecognised_licence_is_not_an_allowed_one():
    assert licenses.spdx_of_text(GPL_TEXT, POLICY["spdx_markers"]) is None


def test_an_ambiguous_text_is_refused_rather_than_picked_from():
    """Two ids matching is not a licence anyone here may act on."""
    both = MIT_TEXT + "\n\nApache License\nVersion 2.0, January 2004\n"
    assert licenses.spdx_of_text(both, POLICY["spdx_markers"]) is None


def test_an_operator_the_matcher_does_not_implement_raises():
    """`match` is stated in the policy, and an unknown one is refused rather than defaulted.

    Defaulting to `all` -- or to anything -- would let a policy edit nobody implemented decide
    which licences are recognised, which is the waving-through this table exists to prevent.
    """
    markers = {"MIT": {"match": "any", "phrases": ["MIT License"]}}
    with pytest.raises(ValueError, match="only operator implemented"):
        licenses.spdx_of_text(MIT_TEXT, markers)


def test_a_marker_spec_missing_its_operator_raises_rather_than_matching_nothing():
    """The pre-2026-09-05 bare-list shape is refused, not silently read as an empty spec."""
    with pytest.raises(ValueError):
        licenses.spdx_of_text(MIT_TEXT, {"MIT": {"phrases": ["MIT License"]}})


def test_a_package_missing_from_the_cache_has_no_licence_to_read(tmp_path):
    sid, why, kind = licenses.package_spdx("gap", "3.0.1", POLICY, cache_with(tmp_path, {}))
    assert sid is None
    assert kind == "unreadable"
    assert "neither the hosted nor the git pub cache" in why


# ---------------------------------------------------------------------------------------
# R17, per file
# ---------------------------------------------------------------------------------------

def test_a_file_carrying_no_package_source_passes_untouched(tmp_path):
    judge = judge_for(tmp_path, packages={}, provenance={})
    assert judge.judge({"verified": True}, ("0001", "rev_001_aaaa.dart")) == []
    # And it is not even counted: the vacuity guard asks how many files carry an inlining
    # count, and a file with none says nothing about whether the build reports them.
    assert judge.rows_with_a_count == 0


def test_a_reverted_file_passes_because_the_source_was_stood_in_for(tmp_path):
    judge = judge_for(tmp_path, packages={}, provenance={})
    row = {"inlinedThirdPartyDeclarations": 2, "thirdPartyInlineReverted": True}
    assert judge.judge(row, ("0001", "rev_001_aaaa.dart")) == []


def test_an_allowed_package_passes(tmp_path):
    key = ("1793", "rev_002_23caef43.dart")
    judge = judge_for(
        tmp_path,
        packages={"auto_size_text_field-2.2.3": MIT_TEXT},
        provenance={key: {"bytes_identical": True,
                          "inlinedThirdPartyPackages": {"auto_size_text_field": "2.2.3"}}})
    assert judge.judge({"inlinedThirdPartyDeclarations": 2}, key) == []
    assert judge.rows_with_a_count == 1


def test_a_disallowed_package_fires_and_is_reported_as_such(tmp_path):
    key = ("0001", "rev_001_aaaa.dart")
    judge = judge_for(tmp_path, packages={"copyleft_widgets-1.0.0": GPL_TEXT},
                      provenance={key: {"bytes_identical": True,
                                        "inlinedThirdPartyPackages":
                                            {"copyleft_widgets": "1.0.0"}}})
    assert judge.judge({"inlinedThirdPartyDeclarations": 1}, key) == [PACKAGE_LICENSE_RULE]
    assert list(judge.by_kind("disallowed")) == ["0001/rev_001_aaaa.dart"]
    assert judge.by_kind("unattributed") == {}


def test_an_unrecognised_licence_is_a_policy_verdict_not_a_provenance_gap(tmp_path):
    """Somebody looked and could not place it. No second isolation makes a licence
    recognisable, so calling it `unattributed` would point at the wrong remedy."""
    key = ("0001", "rev_001_aaaa.dart")
    judge = judge_for(tmp_path, packages={"mystery-1.0.0": "All rights reserved."},
                      provenance={key: {"bytes_identical": True,
                                        "inlinedThirdPartyPackages": {"mystery": "1.0.0"}}})
    assert judge.judge({"inlinedThirdPartyDeclarations": 1}, key) == [PACKAGE_LICENSE_RULE]
    assert list(judge.by_kind("disallowed")) == ["0001/rev_001_aaaa.dart"]


def test_a_package_absent_from_the_cache_is_unattributed_not_disallowed(tmp_path):
    """Nothing was read, so nothing is known -- and re-running the pass may well fix it."""
    key = ("0001", "rev_001_aaaa.dart")
    judge = judge_for(tmp_path, packages={},
                      provenance={key: {"bytes_identical": True,
                                        "inlinedThirdPartyPackages": {"gone": "9.9.9"}}})
    assert judge.judge({"inlinedThirdPartyDeclarations": 1}, key) == [PACKAGE_LICENSE_RULE]
    assert list(judge.by_kind("unattributed")) == ["0001/rev_001_aaaa.dart"]


def test_a_file_with_no_provenance_row_is_unattributed(tmp_path):
    """The gap R17 must not paper over: a count with no name is nobody having looked."""
    judge = judge_for(tmp_path, packages={}, provenance={})
    key = ("0001", "rev_001_aaaa.dart")
    assert judge.judge({"inlinedThirdPartyDeclarations": 3}, key) == [PACKAGE_LICENSE_RULE]
    assert judge.by_kind("unattributed")["0001/rev_001_aaaa.dart"]["kind"] == "unattributed"
    assert judge.by_kind("disallowed") == {}


def test_a_provenance_row_whose_bytes_did_not_match_is_unattributed(tmp_path):
    """It describes a different file, so its package list is about something else."""
    key = ("0001", "rev_001_aaaa.dart")
    judge = judge_for(tmp_path, packages={"gap-3.0.1": MIT_TEXT},
                      provenance={key: {"bytes_identical": False,
                                        "inlinedThirdPartyPackages": {"gap": "3.0.1"}}})
    assert judge.judge({"inlinedThirdPartyDeclarations": 1}, key) == [PACKAGE_LICENSE_RULE]
    assert "DIFFERENT file" in judge.by_kind("unattributed")["0001/rev_001_aaaa.dart"]["why"]


def test_a_truncated_closure_is_unattributed_however_good_its_packages_look(tmp_path):
    """Past the budget a declaration is appended without a successful `take`, and the map is
    written inside `take` -- so this row's package list may be short of what is in the file,
    and a short list read as complete is the one way this rule waves code through."""
    key = ("0001", "rev_001_aaaa.dart")
    judge = judge_for(tmp_path, packages={"gap-3.0.1": MIT_TEXT},
                      provenance={key: {"bytes_identical": True,
                                        "inlinedThirdPartyPackages": {"gap": "3.0.1"}}})
    row = {"inlinedThirdPartyDeclarations": 9, "thirdPartyInlineTruncated": True}
    assert judge.judge(row, key) == [PACKAGE_LICENSE_RULE]
    assert "budget" in judge.by_kind("unattributed")["0001/rev_001_aaaa.dart"]["why"]


def test_one_disallowed_package_condemns_a_file_of_otherwise_allowed_ones(tmp_path):
    key = ("0001", "rev_001_aaaa.dart")
    judge = judge_for(tmp_path,
                      packages={"gap-3.0.1": MIT_TEXT, "copyleft-1.0.0": GPL_TEXT},
                      provenance={key: {"bytes_identical": True,
                                        "inlinedThirdPartyPackages":
                                            {"gap": "3.0.1", "copyleft": "1.0.0"}}})
    assert judge.judge({"inlinedThirdPartyDeclarations": 2}, key) == [PACKAGE_LICENSE_RULE]


# ---------------------------------------------------------------------------------------
# The vacuity guard
# ---------------------------------------------------------------------------------------

def test_a_pool_where_nothing_reports_inlining_aborts(tmp_path):
    judge = judge_for(tmp_path, packages={}, provenance={})
    judge.judge({"verified": True}, ("0001", "rev_001_aaaa.dart"))
    with pytest.raises(SystemExit) as excinfo:
        licenses.assert_not_vacuous(judge, 1549, tmp_path)
    assert "has no input" in str(excinfo.value)
    # `--allow-unverified` is the same statement about the same corpus, so it waives this
    # abort too rather than R17 growing a second flag for one fact.
    licenses.assert_not_vacuous(judge, 1549, tmp_path, allow_unverified=True)


def test_an_empty_corpus_does_not_abort(tmp_path):
    """Nothing to screen is not a corpus screened on silence."""
    judge = judge_for(tmp_path, packages={}, provenance={})
    licenses.assert_not_vacuous(judge, 0, tmp_path)


def test_one_row_carrying_a_count_is_enough_to_prove_the_build_reports_them(tmp_path):
    judge = judge_for(tmp_path, packages={}, provenance={})
    judge.judge({"inlinedThirdPartyDeclarations": 1}, ("0001", "rev_001_aaaa.dart"))
    licenses.assert_not_vacuous(judge, 1549, tmp_path)


def test_a_reverted_row_alone_proves_it_too(tmp_path):
    """The case that aborted the 2026-09-06 pipeline on its first screened repository.

    spm emits the count only when positive and DELETES it on revert, keeping the stood-in
    version and saying so in `thirdPartyInlineReverted`. A corpus whose every inlining was
    reverted -- 91 of 173 transplants on that run -- reports vigorously and counts nothing,
    and testing the count alone read that as an extractor too old to look.
    """
    judge = judge_for(tmp_path, packages={}, provenance={})
    judge.judge({"verified": True, "thirdPartyInlineReverted": True},
                ("0001", "rev_001_aaaa.dart"))
    licenses.assert_not_vacuous(judge, 1549, tmp_path)
    assert judge.rows_with_a_count == 0, \
        "no package source is retained, so the reported count must stay 0"
    assert judge.rows_reporting_inlining == 1


def test_a_truncated_row_alone_proves_it_too(tmp_path):
    """`thirdPartyInlineTruncated` is emitted on the same terms and by the same builds."""
    judge = judge_for(tmp_path, packages={}, provenance={})
    judge.judge({"verified": True, "thirdPartyInlineTruncated": True},
                ("0001", "rev_001_aaaa.dart"))
    licenses.assert_not_vacuous(judge, 1549, tmp_path)
    assert judge.rows_with_a_count == 0
    assert judge.rows_reporting_inlining == 1


def test_a_row_reporting_nothing_still_aborts(tmp_path):
    """The guard is not weakened. A corpus mined under spm < 0.6.0 carries none of the three
    fields, which is the silence that has always been indistinguishable from a clean corpus."""
    judge = judge_for(tmp_path, packages={}, provenance={})
    judge.judge({"verified": True, "errorCount": 0}, ("0001", "rev_001_aaaa.dart"))
    assert judge.rows_reporting_inlining == 0
    with pytest.raises(SystemExit) as excinfo:
        licenses.assert_not_vacuous(judge, 1549, tmp_path)
    assert "reports third-party inlining in any form" in str(excinfo.value)


# ---------------------------------------------------------------------------------------
# R18, per group
# ---------------------------------------------------------------------------------------

def candidates(tmp_path: Path, rows: list[dict]) -> Path:
    path = tmp_path / "candidates.jsonl"
    path.write_text("".join(json.dumps(r) + "\n" for r in rows), encoding="utf-8")
    return path


def test_an_allowed_repository_fires_nothing(tmp_path):
    path = candidates(tmp_path, [{"repo_name": "o/r", "license": "apache-2.0"}])
    assert licenses.repo_license_rules({"0001": "o/r"}, POLICY, path) == {}


def test_a_repository_the_collector_never_recorded_fires(tmp_path):
    """Not a licence finding -- a provenance one. The verdict existed and was never kept."""
    path = candidates(tmp_path, [])
    fired = licenses.repo_license_rules({"0001": "o/r"}, POLICY, path)
    assert list(fired) == ["0001"]
    assert "no row in data/candidates.jsonl" in fired["0001"]["reason"]


def test_a_disallowed_repository_licence_fires(tmp_path):
    path = candidates(tmp_path, [{"repo_name": "o/r", "license": "gpl-3.0"}])
    fired = licenses.repo_license_rules({"0001": "o/r"}, POLICY, path)
    assert fired["0001"]["recorded"] == "gpl-3.0"
    assert fired["0001"]["spdx"] is None


def test_the_collectors_lowercase_vocabulary_is_reconciled_not_lowercased(tmp_path):
    """`candidates.jsonl` stores GitHub's spdx_id lowercased; the policy is what a human
    reads, so the mapping lives in the policy rather than in a `.lower()` call."""
    path = candidates(tmp_path, [{"repo_name": "o/r", "license": "MIT"}])
    assert licenses.repo_license_rules({"0001": "o/r"}, POLICY, path) == {}


# ---------------------------------------------------------------------------------------
# The digest that invalidates a checkpoint
# ---------------------------------------------------------------------------------------

def test_the_digest_moves_when_either_input_moves(tmp_path):
    policy, provenance = tmp_path / "p.json", tmp_path / "v.jsonl"
    policy.write_text(json.dumps(POLICY), encoding="utf-8")
    provenance.write_text("", encoding="utf-8")
    first = licenses.license_version(policy, provenance)
    provenance.write_text('{"id": "0001", "file": "a.dart"}\n', encoding="utf-8")
    assert licenses.license_version(policy, provenance) != first


def test_a_missing_table_raises_rather_than_hashing_nothing(tmp_path):
    """Hashing `b""` answers with a plausible digest that silently invalidates every
    checkpoint, which is the exact failure mode of moving one of these files."""
    policy = tmp_path / "p.json"
    policy.write_text(json.dumps(POLICY), encoding="utf-8")
    with pytest.raises(FileNotFoundError):
        licenses.license_version(policy, tmp_path / "absent.jsonl")


# ---------------------------------------------------------------------------------------
# The real policy, against the real corpus
# ---------------------------------------------------------------------------------------

def test_a_git_dependency_resolves_from_the_git_cache(tmp_path):
    """A git dependency caches as `<name>-<commit sha>`, which parses exactly as a version
    does -- `flutter_wechat_assets_picker-8b3e8f20...` looks like `foo-2.2.4`. Searching only
    the hosted cache would refuse it for a reason that names the wrong cache."""
    root = tmp_path / "cache" / "git" / "some_pkg-8b3e8f20f47b1eb3acb4365fabad907d74dafe61"
    root.mkdir(parents=True)
    (root / "LICENSE").write_text(MIT_TEXT, encoding="utf-8")
    sid, _, kind = licenses.package_spdx(
        "some_pkg", "8b3e8f20f47b1eb3acb4365fabad907d74dafe61", POLICY, tmp_path / "cache")
    assert (sid, kind) == ("MIT", "recognised")


def test_the_shipped_policy_recognises_the_one_package_this_corpus_inlines():
    """`auto_size_text_field` 2.2.3 is the only package whose source reaches a shipped arm-2
    role -- the version resolved at the commits behind `1793`, not the one HEAD's pubspec.lock
    pins -- and it is MIT. If this ever fails the corpus has changed, not the policy."""
    policy = licenses.load_policy()
    if not (licenses.PUB_CACHE / "hosted" / "pub.dev"
            / "auto_size_text_field-2.2.3").is_dir():
        pytest.skip("pub cache does not hold auto_size_text_field-2.2.3")
    sid, _, _ = licenses.package_spdx("auto_size_text_field", "2.2.3", policy)
    assert sid == "MIT"
    assert sid in policy["allowed_spdx"]


def test_every_arm2_repository_is_under_an_allowed_licence():
    """R18 asserts what the collector already enforced. It fires on nothing here, and that
    is the finding: 14 MIT and 6 Apache-2.0 across the 20 eligible repositories."""
    groups = Path(__file__).resolve().parents[2] / "new_samples" / "groups.jsonl"
    if not groups.is_file():
        pytest.skip("no exported corpus to check")
    project_by_id = {}
    for line in groups.read_text().splitlines():
        if line.strip():
            row = json.loads(line)
            project_by_id[row["id"]] = row["project"]
    assert licenses.repo_license_rules(project_by_id, licenses.load_policy()) == {}
