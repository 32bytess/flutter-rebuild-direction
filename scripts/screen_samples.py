"""Screen a mined sample corpus against the original corpus's exclusion criteria, then
export only the surviving groups -- with their manifests -- into a new directory.

`--full` builds the whole corpus in one command: screen, resolve the fixture values,
re-screen, override the branch-gating bindings, re-screen and prune to the measured roles.
See `_full` for why that order is the only correct one. The five phases are also still
five separate commands, which is how you debug one of them.

WHY THIS EXISTS
---------------
`scripts/mining` applies no measurability exclusion at all: its only filter is
`config.CORPUS_REPOS`, which drops the repositories already in the measured corpus. Every
criterion that shaped `samples/` was applied by hand, in two rounds, and none of them was
ported, so a freshly mined corpus is entirely pre-exclusion. This script re-applies those
criteria mechanically, so the exclusion set is generated rather than hand-curated.

**The rules themselves -- every id, what fires it, where it came from, and why each soft one
is soft -- live in `scripts/screen/rules.py`.** They are not repeated here.

WHAT THE SCREEN IS NOT
----------------------
It is a CONSERVATIVE PRE-FILTER, not the detector. A progress indicator pruned by an
`if`/ternary whose frozen input disables it removes the widget from the tree entirely and is
fine -- that is exactly why old seeds 05 and 16 were KEPT. One kept mounted is not. Telling
those apart needs the fixture, which does not exist until `dependencies.dart` is written, so
`pumpAndSettle`'s timeout stays the operational detector as it was in round 1.

Rules are reported individually and never collapsed, so any of them can be adjudicated or
overridden without re-running the others.

Measurement-time exclusions are not statically decidable and are deliberately absent:
incomplete executions, roles that lost all executions, `base_failed` / `changed_during_load`
integrity flags. Those remain the runner's job.

HOW THE RULES ARE MATCHED
-------------------------
By parsing, not by text -- except R10/R11/R12, which are read from the manifests because they
are provenance rather than content; see `verification_rules`. R1-R6 are evaluated over an AST
in `scripts/dart_tools`, a standalone parse-only Dart package on `package:analyzer` -- the
same arrangement `history_probe/scope_ast` uses, and for the same reason: a mined transplant
carries deep `package:.../src/` imports nothing here declares, so it will not RESOLVE, but it
always PARSES. A name therefore has to appear as a real identifier reference, not merely as
text: `\bawait\b` must not fire inside `Text('please await ...')`.

AUTHORING WHILE THE MINE RUNS
-----------------------------
`--dest` is where `dependencies.dart` and `mutation_*.dart` get written, and that work is not
rebuildable from `--source`, so the export treats it as sacred:

  * a file at `--dest` whose name the corpus does not have is AUTHORED. It is never
    overwritten, and a group holding one is never deleted -- not by `--prune`, not by a later
    run that excludes it. It is reported as KEPT; `--force-prune` is the only way.
  * a re-run as the mine finishes more repositories only ADDS groups.
  * `--exclude-groups` drops groups by id, for the judgement no rule makes -- a transplant
    that is measurable and simply not worth writing a fixture for. It is re-decided every run
    and never recorded in a checkpoint, so removing the id brings the group back.

The export writes the first draft of that authoring. Per exported group it hoists the `late`
seeds, the two stand-in blocks and the `null` constants out of the group's transplants into
one `dependencies.dart` they all share, joined by `library generated_widget;` and
`part 'dependencies.dart';` -- the library-name form, because the URI form would name one
role's file and a fixture that names a role is not shared. Every value is left as
`// TODO: value`: a generated value that changes tree size manufactures the effect the study
measures. The sharing is the point and not a convenience -- one fixture across a pair is what
makes the stubbing symmetric by construction rather than by inspection. A skeleton is
regenerated as long as nobody has touched it, and never overwritten once somebody has;
`scripts/fixture_skeleton` holds the union rules and the hashing. `--no-fixtures` turns it
off, which produces a corpus that will not mount.

THE EXPORT
----------
`--dest` receives the eligible groups only, plus every manifest filtered to them. Nothing is
copied first and screened after: the walk visits `--source` and copies only what survives, so
`--dest` never holds a file the screen rejects and the full corpus is never duplicated.

The unit is the FILE, not the group. A shipped group ships only those `.dart` transplants
that pass on their own content -- a `rev_*.dart` firing a hard rule can never be an endpoint
of an eligible pair, since a pair needs both endpoints clean, so it is left in `--source` and
its `revisions.jsonl` row is dropped with it. `--keep-excluded-revisions` restores the old
all-or-nothing behaviour. Ordinals are never renumbered, so surviving `rev_NNN_*.dart` names
have gaps and keep meaning what the pair records say they mean. A group whose every
transplant screens out is dropped rather than exported empty.

`--dest` is a DERIVED directory: it can be deleted and rebuilt from `--source` at any time,
so nothing should ever be authored there. `dependencies.dart` authoring belongs in `--source`.

Absolute paths inside the manifests that point into `--source` are rewritten to `--dest`, so
the exported index describes the exported tree rather than the one it came from. `id` is
never reassigned -- it lands in result tables and figures, and renumbering silently
invalidates every one of them -- so the exported `number` fields keep their original values
and therefore have gaps. That is intended.

Exported `.dart` is normalised so the corpus references no resource this container cannot
resolve: spm's `Image.asset('assets/placeholder.png')` skeleton becomes the grey box the
curated `samples/` corpus uses, third-party icon-font references become `Icons.circle`, and
custom `fontFamily` arguments, third-party `package:` imports and imports already covered by
another are dropped. Only what it COPIES is rewritten -- `--source` stays byte-faithful to
what `mine` wrote. `--no-normalise` and `--no-prune-unused-imports` turn the two halves off.

A group that was exported by an earlier run but is excluded by this one is reported as STALE
and left in place; `--prune` removes it. Silent deletion is not offered: a stale group usually
means the rule set changed, which is a decision to confirm rather than apply.

RESUMING
--------
Three layers, cheapest first. `--resume` is the one that matters while a mine is running: it
replays whole repositories the screen already finished, so a re-run costs the work the mine
has ADDED since and nothing else.

  * `--resume` reads per-repository checkpoints from `checkpoints_screen/` (beside `mine`'s
    own, or `--screen-checkpoints DIR`). Each records one FINISHED repository -- its groups'
    rules, normalised hashes and per-file verdicts -- and is written only after a successful
    export, so a checkpoint means "screened AND placed". Finished repositories are immutable,
    which is what makes replaying them sound; held ones are never recorded. A checkpoint
    written in a different mode (rule set, `--strict`, `--dest`,
    `--keep-excluded-revisions`) is ignored rather than trusted, and says so.
  * screening reuses a cached verdict for any file whose (size, mtime_ns) is unchanged,
    recorded in `<dest>/.screen_cache.json`. `rsync -a` and `shutil.copy2` both preserve
    mtime, so a re-synced identical file is correctly reused. `--rescreen` forces a full
    re-read.
  * exporting skips any file already at `--dest` with identical size and mtime. Copies use
    `copy2`, so that comparison is exact rather than heuristic -- except for a normalised
    `.dart`, which never matches its source on either and is compared by content instead.

USAGE
-----
    # build the corpus, end to end, from the mine and config/fixture_policy.json alone
    python3 -m scripts.screen_samples --source probe_v2/samples_v2 --dest new_samples \\
            --records new_samples --markdown --full --from-nothing

    # a single screening pass: copy out only what survives
    python3 -m scripts.screen_samples --source probe_v2/samples_v2 --dest new_samples
    python3 -m scripts.screen_samples --source new_samples --dest OUT --markdown
    python3 -m scripts.screen_samples --source new_samples --dest OUT --strict
    python3 -m scripts.screen_samples --source new_samples --dest OUT --dry-run
    python3 -m scripts.screen_samples --source new_samples --report-only

    # while a mine is running: screen only what the mine has finished since last time
    python3 -m scripts.screen_samples --source probe_v2/samples_v2 --dest new_samples \
            --records new_samples --resume --markdown

OUTPUTS
-------
    <source>/exclusions.json   per group and per pair, with the rules that fired
    <source>/EXCLUSIONS.md     generated appendix table (with --markdown)
    <dest>/                    the eligible groups and their filtered manifests
    <dest>/.screen_cache.json  the per-file resume cache
    checkpoints_screen/        per-repository resume records (--resume)
"""

from __future__ import annotations

import argparse
import collections
import dataclasses
import json
import sys
from pathlib import Path

from scripts import fixture_skeleton
from scripts import fixture_values as fixture_values_module
from scripts.screen.backend import CACHE_NAME, DartBackend, Screener
from scripts.screen.bindings import Bindings
from scripts import render_gate
from scripts.screen import freeze, rebuild
from scripts.screen.checkpoints import (SCREEN_CHECKPOINT_DIR, ScreenRun,
                                        load_screen_checkpoints, provenance,
                                        screen_mode, write_screen_checkpoints)
from scripts.screen.contrasts import all_pairwise_rows
from scripts.screen.export import ICON_STANDIN, copy_file, export
from scripts.screen.fixtures import build_fixtures
from scripts.screen.licenses import (PackageLicenceJudge, assert_not_vacuous,
                                     load_policy as load_license_policy, load_provenance,
                                     repo_license_rules)
from scripts.screen.manifests import (find_checkpoints, finished_repos, group_index,
                                      manifest_group_ids, read_json, retarget,
                                      revisions_by_group, verification_rules)
from scripts.screen.report import print_export_summary, report, write_markdown
from scripts.screen import shims
from scripts.screen.rules import (BINDING_RULE, DUPLICATE_RULE, INLINE_REVERTED_RULE,
                                  MANUAL_RULE, MIN_REVISIONS_FOR_A_PAIR, NO_PAIR_RULE,
                                  RULES, SHIM_DROP_RULE, SHIM_FORM_RULE, SHORT_VECTOR_RULE,
                                  SOFT_RULES,
                                  PACKAGE_LICENSE_RULE, REPO_LICENSE_RULE,
                                  SOURCE_UNRESOLVED_RULE, UNFILLABLE_RULE, UNFINISHED_RULE,
                                  UNVERIFIED_RULE, ZERO_DELTA_RULE, hard_set, reasons)


# This module is the documented entry point -- `python3 -m scripts.screen_samples`, and
# `from scripts import screen_samples as screen` in the runbook and the tests -- so every
# name a caller reaches through it stays reachable here even when it is defined in
# `scripts/screen/` and unused in this file. Moving a definition must not move where callers
# find it.
__all__ = [
    "RULES", "SOFT_RULES", "MIN_REVISIONS_FOR_A_PAIR",
    "UNVERIFIED_RULE", "SOURCE_UNRESOLVED_RULE", "INLINE_REVERTED_RULE", "DUPLICATE_RULE",
    "NO_PAIR_RULE", "BINDING_RULE", "SHORT_VECTOR_RULE", "ZERO_DELTA_RULE", "MANUAL_RULE",
    "SHIM_DROP_RULE", "SHIM_FORM_RULE",
    "UNFILLABLE_RULE", "unfillable_groups",
    "PACKAGE_LICENSE_RULE", "REPO_LICENSE_RULE", "PackageLicenceJudge", "repo_license_rules",
    "UNFINISHED_RULE", "reasons", "hard_set",
    "DartBackend", "Screener", "screen_mode", "provenance", "load_screen_checkpoints",
    "write_screen_checkpoints", "find_checkpoints", "finished_repos", "group_index",
    "manifest_group_ids", "verification_rules", "revisions_by_group", "read_json",
    "retarget", "all_pairwise_rows", "Bindings", "copy_file", "export", "build_fixtures",
    "report", "write_markdown", "print_export_summary",
    "read_group_exclusions", "records_reduction", "screen", "main",
    # The reproducibility gate, now in `screen/rebuild.py`. Re-exported under the names it
    # had here, so every caller and test that reached it through this facade still does.
    "require_fixture_pass_done", "write_pruned_stamp", "EXPECTED_CORPUS", "DERIVED_AT_DEST",
]

# `_`-prefixed aliases for the three the test suite reaches by their historical names.
# `inspect.getsource` follows the object, so it reads `screen/rebuild.py` and the assertions
# about what the teardown does and does not do are unchanged.
require_fixture_pass_done = rebuild.require_fixture_pass_done
write_pruned_stamp = rebuild.write_pruned_stamp
EXPECTED_CORPUS = rebuild.EXPECTED_CORPUS
DERIVED_AT_DEST = rebuild.DERIVED_AT_DEST
_authored_under = rebuild.authored_under
_teardown_for_rebuild = rebuild.teardown
_verify_rebuild = rebuild.verify


def read_group_exclusions(values: list[str] | None) -> dict[str, str]:
    """`{group id: reason}` from repeated `--exclude-groups` values.

    Accepts ids, comma-separated lists, or `@file` with one id per line. In a file the rest
    of the line is the REASON, with or without a leading `#`:

        0224  # measurable, but the scope is a settings form nobody would refactor
        0231     duplicate of 0224 in everything but the id

    For the one criterion that is by definition "the judgement no rule makes", the
    justification is the whole content of the record, so the reason is carried through to
    `exclusions.json` and the markdown rather than discarded as a comment.
    """
    out: dict[str, str] = {}
    for value in values or []:
        if value.startswith("@"):
            lines = Path(value[1:]).read_text().splitlines()
        else:
            lines = value.split(",")
        for line in lines:
            item, _, reason = line.strip().partition("#") if "#" in line \
                else line.strip().partition(" ")
            item = item.strip()
            if not item:
                continue                  # a blank line, or a whole-line `# comment`
            out[item.zfill(4) if item.isdigit() else item] = reason.strip()
    return out


def _reset_fixture_values() -> None:
    """Drop the cached table. `--full` writes it between phases; see `_full`."""
    global _FIXTURE_VALUES
    _FIXTURE_VALUES = None


def _fixture_values() -> dict:
    """The committed value table, read once. Absent file means every slot keeps its stamp.

    Through `fixture_values.load()`, which owns the file. This used to re-derive
    `PROJECT_ROOT / "config" / "fixture_values.json"` itself, so `SPM_FIXTURE_VALUES` moved
    the fill's reader and not R16's -- the override could point the two at different tables
    with nothing saying so.
    """
    global _FIXTURE_VALUES
    if _FIXTURE_VALUES is None:
        _FIXTURE_VALUES = fixture_values_module.load()
    return _FIXTURE_VALUES


_FIXTURE_VALUES: dict | None = None


def unfillable_groups(fixture_values: dict, store: Path | None = None) -> dict[str, dict]:
    """Groups R16 excludes, as `{gid: {"reason", "declared", "bindings"}}`.

    A group is unfillable when the values table records `origin: "none"` for one of its
    bindings: `resolve()` reached the slot, refused to guess, and that refusal is a property
    of `config/fixture_policy.json` rather than of how far this run has got. `rules.py`'s
    UNFILLABLE_RULE block says why the table is the right thing to read and the fixture on
    disk is not.

    `declared` separates the two kinds. True means the refusal is one the policy NAMES -- a
    type in its `unrecoverable` block, or a resolution route in `unrecoverable_rules` -- and
    the drop is a recorded decision, carrying the policy's own note as the reason. False means
    the policy simply has no entry -- which is a signal that the policy is short, not that the
    group deserves to go -- and the caller prints it as a warning.

    `store` RELEASES a group whose fixture has since been written. R16 names work owed; once a
    human has done the work the work is not owed, and saying otherwise is not a technicality:
    `device_runner.awaiting_fixture_groups` reads this set out of `exclusions.json` and skips
    every group in it, so before 2026-09-15 someone could author exactly the fixture R16 was
    asking for and the runner would go on refusing to measure the group -- with nothing
    anywhere saying why.

    The release condition is "the fixture carries no real `// TODO: value`", read through
    `fixture_gate.unfilled_slots`, which already strips the banner every generated fixture
    quotes the marker in.

    This does NOT make the rule fixture-derived, and the distinction is the one
    `config/README.md` is emphatic about. The TABLE still decides membership: a group the fill
    has never visited has no `origin: "none"` entry, is not in this set, and cannot be put in
    it by anything on disk -- which is why a fixture-based test would have made the exclusion
    its own cause. The fixture is only the release. With no `store`, or on the empty table
    phase 1 of `--full` runs against, nothing changes.
    """
    from scripts import fixture_gate
    try:
        policy = fixture_values_module.load_policy()
    except Exception:                        # a policy this run cannot read is not this
        policy = {}                          # function's error to raise; resolve() owns that
    unrecoverable = policy.get("unrecoverable") or {}
    # `out_of_scope` names the types the primitives-only table declines to fabricate. Both
    # blocks are DECLARED refusals; a type in neither is the loud case.
    named = {**unrecoverable, **(policy.get("out_of_scope") or {})}
    route_rules = policy.get("unrecoverable_rules") or {}
    out: dict[str, dict] = {}
    for gid, entry in sorted((fixture_values or {}).items()):
        dead = {name: e for name, e in (entry.get("bindings") or {}).items()
                if e.get("origin") == "none"}
        if not dead:
            continue
        if store is not None:
            fixture = store / gid / fixture_skeleton.FIXTURE_NAME
            if fixture.is_file() and not fixture_gate.unfilled_slots(
                    fixture.read_text(encoding="utf-8", errors="replace")):
                continue                      # written by hand; the work is no longer owed
        # `rule_id` is what a verdict keys on; the note is for the reader.
        declared = any(_declared_unrecoverable(e, named, route_rules) for e in dead.values())
        notes = sorted({e.get("note") for e in dead.values() if e.get("note")})
        out[gid] = {
            "declared": declared,
            "bindings": sorted(dead),
            "reason": "; ".join(notes) or
                      ("declared unrecoverable in config/fixture_policy.json" if declared
                       else "no entry in config/fixture_policy.json for this type"),
        }
    return out


def _declared_unrecoverable(entry: dict, named: dict, route_rules: dict) -> bool:
    """Whether this dead binding is a refusal the policy NAMES, rather than merely omits.

    `named` is `unrecoverable` and `out_of_scope` together -- what Dart cannot construct above
    the element tree, and what this table declines to fabricate. Keyed on `rule_id`, which is
    stable under rewording: until 2026-09-05 this compared the stored note against the policy's
    prose by string identity, an English sentence used as a primary key, where editing one
    silently reclassified every table already on disk. The decl-type fallback stays, so a table
    written before ids were carried still classifies.
    """
    rule_id = entry.get("rule_id")
    if rule_id:
        return rule_id in route_rules or any(
            isinstance(v, dict) and v.get("id") == rule_id for v in named.values())
    decl = (entry.get("decl") or "").replace("late ", "", 1).strip()
    head = decl.split("=")[0].strip().split()
    t = head[0].rstrip("?").split("<")[0] if head else ""
    return t in named


def screen(source: Path, screener: Screener, *, strict: bool,
           checkpoints: Path | None, keep_unpairable: bool = False,
           require_finished: bool = True, resume: dict | None = None,
           exclude_groups: dict[str, str] | None = None,
           binding_rule: bool = True,
           shim_form_rule: bool = True,
           allow_unverified: bool = False,
           binding_source: Path | None = None,
           vectors_path: Path | None = None,
           license_provenance: Path | None = None,
           license_candidates: Path | None = None,
           render_exclusions: Path | None = None,
           store: Path | None = None) -> dict:
    """Every group's verdict, plus the per-pair verdicts that actually gate measurement."""
    store = store or source.parent / "fixtures"
    hard = hard_set(strict=strict, keep_unpairable=keep_unpairable,
                    require_finished=require_finished)

    # ---- classify every transplanted file, base and revision alike -------------------
    # A revision can introduce or remove a disqualifying construct, so screening only
    # base.dart would retain pairs whose endpoints are not comparable.
    # A group is a numbered directory of transplants. `mine` writes one file per revision
    # -- `rev_<order>_<sha8>.dart` -- and NO `base.dart`: no revision is the reference the
    # others are read against. The group-level verdict therefore needs a representative,
    # and the earliest revision is the only choice that is defined for every group and
    # does not depend on when the corpus was built. A legacy `base.dart`, if a HEAD
    # `isolate` pass wrote one, is used instead so old corpora screen unchanged.
    # `scope_key` -> claimants and id -> project, read first: which repository a group
    # belongs to decides whether its verdict can be resumed and whether R9 holds it.
    ids_by_key, project_by_id = group_index(source, checkpoints)
    id_by_key = {k: v[0] for k, v in ids_by_key.items()}

    # R10/R11 are read from the manifests rather than from the transplants, and are merged
    # into every rule list below -- including a resumed group's, whose checkpoint records
    # only what the AST backend said. They are re-decided every run for the same reason R0
    # and R8 are: re-mining a repository under a fixed checkout must be able to take the
    # verdict back without anyone deleting a checkpoint.
    # R17 is decided off the same manifest rows, so it rides along with the one walk rather
    # than paying for a second. The policy is read here and not inside the judge so a run
    # with an unreadable policy fails before it screens anything, rather than silently
    # allowing nothing.
    licence_policy = load_license_policy()
    licences = PackageLicenceJudge(licence_policy,
                                   load_provenance(license_provenance))
    from_manifest, verification_cover = verification_rules(source, checkpoints, licences)

    def with_manifest_rules(gid: str, name: str, rules: list[str]) -> list[str]:
        extra = [r for r in from_manifest.get(gid, {}).get(name, ()) if r not in rules]
        return rules + extra if extra else rules

    resume = resume or {}
    groups: dict[str, dict] = {}
    resumed: set[str] = set()
    # One batch for every transplant this run will actually read: a resumed group's files
    # are replayed from its checkpoint and are deliberately not primed.
    screener.prime([
        path
        for group_dir in sorted(source.glob("*/"))
        if group_dir.name.isdigit() and group_dir.name not in resume
        for path in sorted(group_dir.glob("*.dart"))
    ])
    for group_dir in sorted(source.glob("*/")):
        gid = group_dir.name
        if not gid.isdigit():
            continue
        # A checkpointed group is one whose repository FINISHED in an earlier run of this
        # same screen: its files cannot change any more, so its verdict is replayed rather
        # than recomputed and not one of its transplants is opened.
        rec = resume.get(gid)
        if rec and (source / gid / rec["representative"]).is_file():
            groups[gid] = {"base_rules": with_manifest_rules(
                               gid, rec["representative"], list(rec["rules"])),
                           "norm_hash": rec["norm_hash"],
                           "representative": rec["representative"],
                           "resumed": True}
            resumed.add(gid)
            continue
        representative = group_dir / "base.dart"
        if not representative.is_file():
            revisions = sorted(group_dir.glob("rev_*.dart"))
            if not revisions:
                continue
            representative = revisions[0]
        groups[gid] = {
            "base_rules": with_manifest_rules(
                gid, representative.name, screener.rules_for(representative)),
            "norm_hash": screener.norm_hash(representative),
            "representative": representative.name,
            "resumed": False,
        }

    # ---- R10 has to have something to read -------------------------------------------
    # A row with NO verification fires nothing, and that silence is the honest answer for a
    # corpus mined under spm <= 0.5.1. It is the wrong answer for a corpus whose manifests
    # simply have not been flushed yet: every transplant then reads as "no verdict" and R10
    # passes the corpus whole -- including the transplants spm already REJECTED, which yield
    # no metrics at all rather than slightly wrong ones.
    #
    # `report` has warned about this in prose since the rule was added. A warning does not
    # stop the run, and the run it does not stop is the one whose corpus is unscreened on the
    # single rule that fires hardest -- 801 of 1,444 groups on the round-4 corpus. R13 aborts
    # on exactly this shape of vacuity, and R10 is the more consequential of the two, so it
    # aborts too and `--allow-unverified` is how you say you meant it.
    if groups and not allow_unverified and not verification_cover["files_with_a_verdict"]:
        raise SystemExit(
            f"{UNVERIFIED_RULE} has no input: not one of the {len(groups)} groups under "
            f"{source} carries an `spm isolate` verdict, so R10 and R11 fire on nothing -- "
            f"because no manifest and no checkpoint was found, not because the corpus is "
            f"clean. Point --checkpoints at the mine's checkpoint directory, or wait for it "
            f"to write its manifests. A corpus genuinely mined under spm <= 0.5.1 has no "
            f"verdicts to find: pass --allow-unverified and say so in the record.")

    # ---- R17 has to have something to read --------------------------------------------
    # The same abort R10 makes, for the same reason. A row with no inlining count is
    # indistinguishable from a row written by a build too old to report one, so a pool where
    # NOT ONE row carries the field would pass R17 whole -- on the silence of a field that
    # was never emitted, not on the absence of package source.
    assert_not_vacuous(licences, len(groups), source, allow_unverified)

    # ---- R0: hand exclusions --------------------------------------------------------
    # Applied before everything else and never resumed from a checkpoint, so adding an id
    # takes effect on the next run without deleting anything.
    manual = dict(exclude_groups or {})
    for gid in sorted(manual.keys() & groups.keys()):
        groups[gid]["base_rules"] = groups[gid]["base_rules"] + [MANUAL_RULE]
    unmatched = sorted(manual.keys() - groups.keys())

    # ---- R16: the fill declared a binding unresolvable --------------------------------
    # Beside R0 because it is the same shape of verdict -- group-level, decided fresh every
    # run, never checkpointed -- and it is what lets `config/fixture_policy.json` be the only
    # hand-written input. Inert until the fill has written a table; see `unfillable_groups`
    # and `rules.py`'s UNFILLABLE_RULE.
    # `store` is the fixture store this run placed into, so the release below reads the same
    # file the corpus will ship -- not a stale copy at `--dest` from a previous export.
    unfillable = {gid: info
                  for gid, info in unfillable_groups(_fixture_values(), store).items()
                  if gid in groups}
    for gid in sorted(unfillable):
        groups[gid]["base_rules"] = groups[gid]["base_rules"] + [UNFILLABLE_RULE]

    # ---- R18: the repository's own licence --------------------------------------------
    # Beside R16 because it is the same shape of verdict -- group-level, decided fresh every
    # run, never checkpointed -- and unlike every other rule here it re-derives nothing: the
    # collector already refused any repository outside the allowed set, and this only carries
    # that verdict into the corpus, which nothing previously did.
    disallowed_repos = {gid: info for gid, info
                        in repo_license_rules(project_by_id, licence_policy,
                                              license_candidates).items()
                        if gid in groups}
    for gid in sorted(disallowed_repos):
        groups[gid]["base_rules"] = groups[gid]["base_rules"] + [REPO_LICENSE_RULE]

    # ---- R9: the repository is still being mined --------------------------------------
    # Applied BEFORE R8 and the duplicate pass, both of which would otherwise read a
    # half-written group: a repository in flight has as many revisions as the walk has
    # reached, not as many as it has.
    done = finished_repos(checkpoints)
    unfinished: set[str] = set()
    if require_finished:
        for gid, g in groups.items():
            if project_by_id.get(gid) not in done:
                g["base_rules"] = g["base_rules"] + [UNFINISHED_RULE]
                unfinished.add(gid)

    # ---- R8: a group that cannot yield a pair -----------------------------------------
    # Counted from the files on disk rather than from `revisions.jsonl`, which records
    # `unchanged` commits too and is not present in every corpus layout.
    for gid, g in groups.items():
        if gid in unfinished:
            continue                      # its second revision may simply be unwritten
        if len(list((source / gid).glob("rev_*.dart"))) < MIN_REVISIONS_FOR_A_PAIR:
            g["base_rules"] = g["base_rules"] + [NO_PAIR_RULE]

    # ---- stage 1c: duplicates ---------------------------------------------------------
    # Only among finished groups: an in-flight group's representative can still change,
    # and a finished group demoted to duplicate-of-a-moving-target is not recoverable
    # once its directory is gone.
    by_hash = collections.defaultdict(list)
    for gid, g in groups.items():
        if gid not in unfinished:
            by_hash[g["norm_hash"]].append(gid)
    for gids in by_hash.values():
        for dup in sorted(gids)[1:]:            # keep the lowest id, drop the rest
            groups[dup]["base_rules"] = groups[dup]["base_rules"] + [DUPLICATE_RULE]

    # ---- verdicts ---------------------------------------------------------------------
    # A group's verdict reflects its representative file (earliest revision, or a legacy
    # base.dart) only. It is reporting context, not the
    # operative filter: eligibility is decided per pair, on that pair's two endpoint files,
    # because a construct introduced in revision 40 says nothing about a pair at revision 3.
    for g in groups.values():
        fired = set(g["base_rules"])
        g["all_rules"] = sorted(fired)
        # R16 is NOT in this union any more. It is governed by `hard` alone, which since
        # 2026-09-08 means it excludes only under `--strict` -- an unresolved binding names
        # authoring work and is held at `fixture_gate.py`, not dropped from the corpus. The
        # three that remain are excluding verdicts no flag tunes.
        g["excluded_by"] = sorted(fired & (hard | {DUPLICATE_RULE, MANUAL_RULE,
                                                   REPO_LICENSE_RULE}))
        g["flagged_by"] = sorted((fired & SOFT_RULES) - hard)
        g["eligible"] = not g["excluded_by"]

    # ---- pair-level: both endpoints must pass ----------------------------------------
    # `mine` keys a pair by (project, file, scope name) -- WITHOUT the ordinal that
    # `isolate` uses to tell two same-named scopes in one file apart. That triple is not
    # unique: on the round-2 corpus 38 keys are claimed by 2-5 groups, covering 93 of 720.
    # Mapping key -> single id therefore silently picked whichever group came last in the
    # file, and the choice moved when the manifest was filtered -- 6 keys resolved
    # differently, flipping 28 pairs. So every claimant is kept and the disagreement is
    # made explicit below.
    # Per-file rules recorded by an earlier run. A finished repository's transplants are
    # immutable, so replaying them costs no read at all -- which is what makes a resumed
    # run cheap even when the file cache is gone (a fresh --records, a moved corpus).
    resumed_files = {gid: dict(rec.get("files") or {}) for gid, rec in resume.items()}

    def rules_for_file(path: Path) -> list[str]:
        gid = path.parent.name
        recorded = resumed_files.get(gid)
        if recorded is not None and path.name in recorded:
            rules = recorded[path.name]
        else:
            rules = screener.rules_for(path)
        return with_manifest_rules(gid, path.name, rules)

    revs_by_group = revisions_by_group(source)

    # ---- R13's inputs -----------------------------------------------------------------
    # `scripts/screen/bindings` holds the rule and the reasoning. Priming is deferred until
    # the pairs that survived every other rule are known -- ~340 files on the round-4 corpus,
    # against the ~16k a corpus-wide prime would read.
    bindings = Bindings(screener.backend, source=binding_source)

    # ---- fixtures, then vectors -- the phase that dissolves the circle -----------------
    # `scripts/screen/fixtures` holds the phase and the reasoning; it is here rather than at
    # export because the fixture is a screening artefact in everything but where it used to
    # be written, and because the vectors the contrast set is differenced over cannot exist
    # until it has run.
    phase_b = {}
    if vectors_path is None:
        phase_b = build_fixtures(source, store, groups, hard, backend=screener.backend,
                                 rules_for_file=rules_for_file,
                                 fixture_values=_fixture_values())
    fixture_store = phase_b.get("fixture_paths", {})
    fixture_stats = phase_b.get("fixture_stats", {})
    role_text = phase_b.get("role_text", {})
    fixture_dropped = phase_b.get("fixture_dropped", {})
    fixture_clash_kinds = phase_b.get("fixture_clash_kinds", {})
    vectors = phase_b.get("vectors", {})
    vector_funnel = phase_b.get("vector_funnel", {})

    # Every within-scope pair of distinct-code roles -- a-b, a-c, a-d, b-c, ... --
    # differenced over the vectors `extract_features` extracted from the shipped transplants
    # themselves. The adjacent set is the ADJACENT SUBSET of these rows, flagged per row.
    #
    # The vectors come from the transplant rather than from the source scope the mine
    # differenced at mining time, and the two disagree on 53 of 156 checkable rows. Where
    # they differ the transplant wins: it is the thing that gets mounted.
    #
    # Cross-scope contrasts are never formed. Each scope has its own `dependencies.dart`,
    # so a pair drawn across two of them lets the fixture produce the direction.
    # R16 stays listed: it is filtered through `excluded_by`, which carries it only under
    # `--strict`, so naming it here is what makes `--strict` reproduce the pre-2026-09-08
    # corpus exactly rather than approximately.
    group_level = {DUPLICATE_RULE, MANUAL_RULE, UNFINISHED_RULE, UNFILLABLE_RULE,
                   REPO_LICENSE_RULE}
    group_rules = {gid: sorted(group_level & set(d["excluded_by"]))
                   for gid, d in groups.items()
                   if group_level & set(d["excluded_by"])}
    # R21/R22 -- what the device DREW for a role, from `config/render_exclusions.json`.
    # Role-keyed, so it joins the pair rows rather than the group verdicts: a role that drew
    # an error box screened clean on every static rule, which is exactly why this table has
    # to exist. Absent table, empty dict, both rules inert -- the R16 shape.
    drawn = render_gate.load(render_exclusions)
    render_rules = {(gid, role): [row["verdict"]
                                  .replace("renders_error", render_gate.RENDER_ERROR_RULE)
                                  .replace("renders_nothing", render_gate.RENDER_NOTHING_RULE)]
                    for gid, roles in drawn.items()
                    for role, row in roles.items()}
    pair_rows, contrast_funnel = all_pairwise_rows(
        source, revs_by_group, ids_by_key, hard, rules_for_file, vectors_path,
        vectors or None, group_rules, render_rules)
    # Two independently authored namespaces, merged into one funnel. They already carry
    # `roles_without_a_vector` and `roles_without_vector` -- one typo apart, counting
    # different things (13,569 and 17) -- so a future collision would silently overwrite
    # a filter's rate with another's. Refused rather than left to be noticed in a table.
    collision = contrast_funnel.keys() & vector_funnel.keys()
    if collision:
        raise SystemExit(
            f"the contrast funnel and the vector funnel both define "
            f"{', '.join(sorted(collision))}. Merging them would report one filter's "
            f"count as another's; rename one side in `all_pairwise_rows` or "
            f"`extract_features.staged_vectors`.")
    contrast_funnel.update(vector_funnel)
    # ---- R20: the two endpoints must agree about which shims drop their children --------
    # Before R13, because this rule is a property of the transplants themselves -- the drops
    # were computed on the batch that produced the rule verdicts, and nothing is re-read --
    # whereas R13 needs the fixture split. Same order the content-level rules run in
    # everywhere else here. It means R13's rate is reported on the pairs R20 left, which is
    # the convention every conditional rate in this record already follows.
    shim_form_counts = shims.apply(screener, pair_rows, enforce=shim_form_rule)
    # ---- R13: the two endpoints must mount from the same bindings ----------------------
    bindings.apply(pair_rows, enforce=binding_rule)

    # The roles that will actually be MEASURED: the endpoints of the contrasts that survived
    # every rule, R13 included. Captured here because `_endpoints` is dropped from the rows on
    # the next line -- it holds `Path`s, which do not belong in the published record.
    #
    # Keyed off `verdict`, never off the presence of `_endpoints`. `bindings.apply` flips an
    # R13 failure to `excluded` and leaves the field in place, so testing the field alone
    # would keep the roles of contrasts R13 removed.
    endpoint_roles: dict[str, set[str]] = {}
    for r in pair_rows:
        if r["verdict"] == "eligible" and r.get("_endpoints"):
            endpoint_roles.setdefault(r["group"], set()).update(
                q.stem for q in r["_endpoints"])
    for r in pair_rows:
        r.pop("_endpoints", None)
    # ELIGIBLE MOVER SCOPES is counted as the number of distinct `scope_key` among the
    # eligible rows, so a row whose key is None makes every such group count as ONE scope --
    # and the scope count is the denominator every contrast count travels with. It has never
    # fired; that is a reason to assert it, not to rely on it.
    keyless = sorted({r["group"] for r in pair_rows
                      if r["verdict"] == "eligible" and not r["scope_key"]})
    if keyless:
        raise SystemExit(
            f"{len(keyless)} group(s) carry an eligible contrast with no scope_key "
            f"({', '.join(keyless[:10])}). They would collapse into a single counted scope. "
            f"No manifest, checkpoint or id_map.json claims them -- check --checkpoints.")
    pair_verdict = collections.Counter(r["verdict"] for r in pair_rows)

    return {
        "groups": groups,
        "binding_rule": binding_rule,
        "shim_form_rule": shim_form_rule,
        # R20's rate, recorded whether or not it was enforced -- see `scripts/screen/shims`.
        "shim_form": shim_form_counts,
        # Phase B's outputs, so `export` copies fixtures instead of regenerating them and
        # honours the roles the fixture union refused.
        "fixture_store": store,
        "fixture_paths": fixture_store,
        "fixture_stats": fixture_stats,
        "role_text": role_text,
        "fixture_dropped": fixture_dropped,
        "fixture_clash_kinds": fixture_clash_kinds,
        # What screening the contrast set cost before any rule was consulted: roles with no
        # vector, roles R14 refused, and roles that are a duplicate of one already kept.
        # Empty on the adjacent path, which forms no roles of its own.
        "contrast_funnel": contrast_funnel,
        # The JSON publishes this under `pairs` -- the schema `maximal_branch` and
        # `fixture_values` select eligible rows from.
        "pair_rows": pair_rows,
        # The device verdicts this run actually screened against -- the table `report` must
        # publish, rather than re-reading the committed one. `--render-exclusions` exists
        # precisely so the two can differ, and a report that re-read would undo the flag.
        "render": drawn,
        # group -> the `rev_NNN_<sha8>` stems that are an endpoint of an eligible contrast.
        # `export --prune-to-endpoints` ships these and nothing else; `device_runner`'s
        # `--eligible-only` derives the same set independently from `exclusions.json`, and the
        # two agreeing is a check worth having rather than a duplication to remove.
        "endpoint_roles": endpoint_roles,
        "pair_verdict": pair_verdict,
        "id_by_key": id_by_key,
        "project_by_id": project_by_id,
        "unfinished": unfinished,
        "finished_repos": done,
        "resumed": resumed,
        "resume_records": resume,
        "manual": sorted(manual.keys() & groups.keys()),
        # The reason each hand exclusion was made, for the groups that matched. Recorded
        # because R0 is the one rule whose justification cannot be re-derived from anything.
        "manual_reasons": {gid: manual[gid] for gid in sorted(manual.keys() & groups.keys())
                           if manual[gid]},
        "unmatched_exclusions": unmatched,
        # R16, per group: the bindings the fill refused, the policy's own words for why, and
        # whether the type is one the policy NAMES or one it merely omits. The second kind is
        # a hole in `fixture_policy.json` and is printed as a warning, never only recorded.
        "unfillable": unfillable,
        # R18, per group: the repository, what the collector recorded for it, and why that
        # is not an allowed licence. Empty on this corpus, which is the assertion.
        "repo_license": disallowed_repos,
        # R17, per FILE and split by kind. `disallowed` is a policy verdict on a named
        # package; `unattributed` is a file carrying package source this run could not name,
        # which is a gap in the provenance rather than a licence finding. Only the second is
        # fixed by re-running `mining license-provenance`, so they are never pooled.
        "package_license": {
            "disallowed": licences.by_kind("disallowed"),
            "unattributed": licences.by_kind("unattributed"),
            "files_with_inlined_packages": licences.rows_with_a_count,
            # The vacuity guard's own denominator, and NOT the same number: a file whose
            # inlining spm reverted reports inlining and carries none. When the first is 0
            # and this is not, R17 decided nothing because there was nothing to decide --
            # which is a finding, where 0 and 0 together is an abort.
            "files_reporting_inlining": licences.rows_reporting_inlining,
        },
        "resumed_files": resumed_files,
        "hard": hard,
        "strict": strict,
        # Handed to `export`, which screens files a second time on its own: R10/R11 are
        # not in any file's content, so without this an unclean revision would ship inside
        # a group that is otherwise eligible.
        "manifest_rules": from_manifest,
        # How much of the corpus carries spm's verdict at all. Short of the file count
        # means part of it predates spm 0.5.2 and its two halves are not comparable; see
        # `verification_rules`.
        "verification_coverage": {
            "groups_with_flagged_files": len(from_manifest),
            "files_flagged": sum(len(v) for v in from_manifest.values()),
            # Files any verdict at all was found for, and how many of those came from a
            # checkpoint because the mine has not written its manifests yet. A screen whose
            # coverage is short of the corpus is reporting on a corpus it only partly saw.
            **verification_cover,
        },
    }


def records_reduction(prior: Path, source: Path) -> tuple[str, list[str], int, int]:
    """Whether re-screening `source` may replace the records at `prior`, and on what.

    Re-screening a corpus that has LOST groups cannot produce sound pair verdicts: a pair
    is attributed through a `scope_key` that several groups may claim, and the claimants
    that would have disagreed are the ones no longer there. Group verdicts are unaffected
    -- they read only each surviving representative.

    But a corpus shrinks two ways, and only one of them is a loss. `mining.isolate.run`
    keeps the manifest rows of projects a run did not process and REPLACES the rest, so a
    repository re-mined under a fixed checkout takes its own groups back -- the same thing
    `screen` allows a re-mine to do to a verdict. `groups.jsonl` is where that is recorded,
    and comparing counts cannot see it. Comparing ids against the manifest can:

      "ok"       nothing the prior record screened has left the corpus.
      "remined"  groups are gone and `groups.jsonl` has dropped them too: a reduction with
                 an author. Proceed, and say so.
      "pruned"   groups are gone while the manifest still claims them -- deleted out from
                 under the corpus. This is the case the refusal exists for.
      "unknown"  groups are gone and nothing can say which kind: no `groups.jsonl` (the
                 mine has not written it yet), or a prior record that predates per-group
                 ids and carries only a count. Refuse -- the run that would overwrite the
                 good record is exactly the one whose pair verdicts are unsound.

    Returns `(verdict, ids, before, here)`. `ids` is what the verdict is about, sorted:
    the groups that left, or for "pruned" the subset the manifest still claims. It is
    empty when only counts were comparable.
    """
    here_ids = {d.name for d in source.glob("*/")
                if d.name.isdigit() and any(d.glob("*.dart"))}
    record = read_json(prior, {}) or {}
    recorded = record.get("groups")
    before_n = (record.get("totals") or {}).get("groups") or 0

    if not isinstance(recorded, dict):
        # A record from before per-group rows, or a half-written one. Counts are all there
        # is, and a count that fell can only be reported, never explained.
        return (("unknown", [], before_n, len(here_ids)) if len(here_ids) < before_n
                else ("ok", [], before_n, len(here_ids)))

    before_n = before_n or len(recorded)
    vanished = set(recorded) - here_ids
    if not vanished:
        return "ok", [], before_n, len(here_ids)

    listed = manifest_group_ids(source)
    if listed is None:
        return "unknown", sorted(vanished), before_n, len(here_ids)
    still_claimed = vanished & listed
    if still_claimed:
        return "pruned", sorted(still_claimed), before_n, len(here_ids)
    return "remined", sorted(vanished), before_n, len(here_ids)




def _one_pass(run: ScreenRun, argv, source: Path, dest: Path | None,
              records_dir: Path) -> int:
    """One screen-and-export. `main()` runs it once; `--full` runs it three times.

    `run.resume`, `run.rescreen` and `run.prune_to_endpoints` are the three that differ
    BETWEEN the passes of a `--full` run -- the fill moves `values_version()`, so the pass
    after it must not resume across that change, and the prune belongs to the last pass only
    -- so `--full` hands each phase its own `ScreenRun` rather than editing a shared one.

    They reach `provenance()` on that record, which is what makes a `--full` record say
    `prune_to_endpoints: true` about a corpus phase 5 pruned even though the flag was never
    on the command line. A record that describes the invocation rather than the pass is the
    shape of error the values-digest gap was: written down faithfully, about the wrong thing.
    """
    resume, rescreen = run.resume, run.rescreen
    prune_to_endpoints = run.prune_to_endpoints
    checkpoints = find_checkpoints(source, run.checkpoints)
    if checkpoints is None:
        print("WARNING: no `mine` checkpoints found - pair-level verdicts will be empty, "
              "so the export is gated on group verdicts only", file=sys.stderr)

    screen_ckpt = run.screen_checkpoints
    if screen_ckpt is None:
        screen_ckpt = ((checkpoints.parent if checkpoints else records_dir)
                       / SCREEN_CHECKPOINT_DIR)
    backend = DartBackend()
    mode = screen_mode(run.strict, run.keep_unpairable,
                       not run.keep_excluded_revisions, source, dest, run.fix_images,
                       backend, run.prune_imports, run.license_provenance,
                       run.render_exclusions)
    resume_records, stale_ckpt = ({}, 0)
    if resume and not rescreen:
        resume_records, stale_ckpt = load_screen_checkpoints(screen_ckpt, mode)
        if stale_ckpt:
            print(f"ignoring {stale_ckpt} checkpoints written in a different mode "
                  f"(rule set, --strict, --dest or --keep-excluded-revisions changed)",
                  file=sys.stderr)

    cache_path = records_dir / CACHE_NAME
    screener = Screener(source, cache_path, enabled=not rescreen, backend=backend)
    result = screen(source, screener, strict=run.strict, checkpoints=checkpoints,
                    keep_unpairable=run.keep_unpairable,
                    require_finished=not run.include_unfinished,
                    resume=resume_records,
                    exclude_groups=read_group_exclusions(run.exclude_groups),
                    binding_rule=not run.allow_unequal_bindings,
                    shim_form_rule=not run.allow_shim_form_drift,
                    allow_unverified=run.allow_unverified,
                    binding_source=run.binding_source,
                    vectors_path=run.vectors,
                    license_provenance=run.license_provenance,
                    license_candidates=run.license_candidates,
                    render_exclusions=run.render_exclusions,
                    store=run.fixture_store)
    if not result["groups"]:
        print(f"no groups found under {source} "
              f"(expected NNNN/ directories of rev_*.dart)", file=sys.stderr)
        return 1

    if result["unmatched_exclusions"]:
        print(f"UNMATCHED --exclude-groups (no such group): "
              f"{', '.join(result['unmatched_exclusions'])}", file=sys.stderr)
    unfillable = result.get("unfillable") or {}
    if unfillable:
        declared = sorted(g for g, i in unfillable.items() if i["declared"])
        undeclared = sorted(g for g, i in unfillable.items() if not i["declared"])
        # A WORKLIST, not a casualty list, since 2026-09-08. These groups are eligible; they
        # are held off the device by `fixture_gate.py` until someone writes the values.
        print(f"awaiting a hand-authored fixture ({UNFILLABLE_RULE}): "
              f"{len(unfillable)} groups")
        for gid in declared:
            print(f"  [{gid}] {', '.join(unfillable[gid]['bindings'])} -- "
                  f"{unfillable[gid]['reason']}")
        if declared:
            print(f"  author into config/authored_fixtures/<gid>/dependencies.dart "
                  f"(`python3 -m scripts.authored_fixtures --seed <gid>`); a fixture edited "
                  f"under the corpus is deleted by the next --prune")
        if undeclared:
            # Loud on purpose, and MORE so now that R16 does not exclude. A group whose type
            # the policy never mentions is a policy that is short -- possibly a typo that
            # deleted a type -- and authoring a fixture for it would paper over the omission
            # instead of fixing it. The `--from-nothing` gate still refuses on this.
            print(f"  WARNING: {len(undeclared)} group(s) are unfillable because "
                  f"config/fixture_policy.json has NO ENTRY for the type, not because it "
                  f"declares one unrecoverable. Add the type, or record the omission -- do "
                  f"NOT author a fixture around it:")
            for gid in undeclared:
                print(f"    [{gid}] {', '.join(unfillable[gid]['bindings'])}")
    licence = result.get("package_license") or {}
    disallowed, unattributed = (licence.get("disallowed") or {},
                                licence.get("unattributed") or {})
    if licence.get("files_with_inlined_packages"):
        print(f"third-party package source ({PACKAGE_LICENSE_RULE}): "
              f"{licence['files_with_inlined_packages']} file(s) carry it; "
              f"{len(disallowed)} disallowed, {len(unattributed)} unattributed")
    elif licence.get("files_reporting_inlining"):
        # Said out loud rather than left as silence, because this is the shape that used to
        # abort: the extractor looked, reported on every file, and kept package source in
        # none of them.
        print(f"third-party package source ({PACKAGE_LICENSE_RULE}): none retained; "
              f"{licence['files_reporting_inlining']} file(s) reported inlining and spm "
              f"reverted or truncated every one")
    for where, detail in sorted(disallowed.items()):
        print(f"  DISALLOWED [{where}] {detail['why']}")
    if unattributed:
        # Loud for the same reason R16's undeclared branch is: a file dropped because nobody
        # recorded whose code is in it is a provenance gap, not a licence finding, and the
        # fix is a command rather than a policy edit. Left quiet, it would read as though
        # the licence check had been applied and had failed.
        print(f"  WARNING: {len(unattributed)} file(s) carry package source this run "
              f"cannot attribute, so R17 fires on them. Run `python3 -m scripts.mining "
              f"license-provenance` over their repositories:")
        for where, detail in sorted(unattributed.items())[:10]:
            print(f"    [{where}] {detail['why']}")
        if len(unattributed) > 10:
            print(f"    (and {len(unattributed) - 10} more; see exclusions.json)")
    repo_licence = result.get("repo_license") or {}
    if repo_licence:
        print(f"repositories outside the licence policy ({REPO_LICENSE_RULE}): "
              f"{len(repo_licence)} groups")
        for gid, info in sorted(repo_licence.items())[:10]:
            print(f"  [{gid}] {info['reason']}")
    if result["manual"]:
        print(f"hand-excluded: {len(result['manual'])} groups "
              f"({', '.join(result['manual'][:10])}"
              f"{'...' if len(result['manual']) > 10 else ''})")

    out, fired, eligible_scopes = report(result, source,
                                         provenance(mode, run, argv=argv))
    if resume:
        repos_resumed = {r["repo"] for gid, r in resume_records.items()
                         if gid in result["resumed"]}
        print(f"resumed: {len(result['resumed'])} groups from {len(repos_resumed)} "
              f"repositories already screened; {len(result['groups']) - len(result['resumed'])} "
              f"screened now")
    print(f"screen cache: {screener.hits} reused, {screener.misses} read")

    # Written after `export`, because the fixture clashes are decided there and reporting
    # them is the whole point of carrying them: 360 roles left this corpus in the round-4
    # screen with no row anywhere. `--report-only` never reaches the split, so it writes
    # the same records without that section rather than not writing them at all.
    def write_records(clash: dict | None = None) -> None:
        if run.dry_run:
            return
        if clash:
            out["fixture_clashes"] = clash
        (records_dir / "exclusions.json").write_text(json.dumps(out, indent=1))
        print(f"wrote {records_dir / 'exclusions.json'}")
        if run.markdown:
            write_markdown(records_dir / "EXCLUSIONS.md", out, result["groups"], fired,
                           eligible_scopes, len(result["pair_rows"]))
            print(f"wrote {records_dir / 'EXCLUSIONS.md'}")

    if run.dry_run and not run.vectors:
        # Said out loud, because "dry run" otherwise promises more than it delivers and the
        # runbook's canonical step 7 is a dry run followed by the real one.
        print(f"note: --dry-run still populates the fixture store at "
              f"{run.fixture_store or (source.parent / 'fixtures')}; nothing else is "
              f"written", file=sys.stderr)

    if run.report_only:
        write_records()
        if not run.dry_run:
            screener.save()
        return 0

    if prune_to_endpoints:
        rebuild.require_fixture_pass_done(dest, result)

    # A refusal from the measurement pin is a decision for a human, not a stack trace: it
    # says the run would rewrite code that device rows already describe. Records are still
    # written first, so the screening verdicts this run computed are not lost with it.
    try:
        stats = export(source, dest, result, screener=screener,
                       dry_run=run.dry_run, prune=run.prune or run.force_prune,
                       screen_revisions=not run.keep_excluded_revisions,
                       force_prune=run.force_prune, fix_images_on=run.fix_images,
                       prune_imports=run.prune_imports, fixtures_on=run.fixtures,
                       prune_to_endpoints=prune_to_endpoints)
    except freeze.FrozenGroupError as exc:
        write_records()
        raise SystemExit(str(exc)) from None
    write_records({"roles": stats.get("fixture_clashes") or {},
                   "kinds": stats.get("fixture_clash_kinds") or {}})
    print_export_summary(stats, dest, dry_run=run.dry_run)
    if not run.dry_run:
        screener.save()
        # Only finished repositories, and only those whose groups this run actually
        # placed: a checkpoint says "this repository is screened AND exported", so a run
        # that exported nothing must not claim it.
        finished = set(result.get("finished_repos") or ())
        wrote = write_screen_checkpoints(
            screen_ckpt, mode, result["groups"], result["project_by_id"],
            # `rule_shipped`, not `shipped_files`: a checkpoint records what the RULES
            # said about a repository's files, and endpoint membership is a property of
            # the whole corpus that no per-repository record can replay. Falls back for a
            # caller that has not been updated.
            {g: f for g, f in (stats.get("rule_shipped")
                               or stats.get("shipped_files", {})).items()},
            stats.get("dropped_files", {}), finished, screener, prior=resume_records)
        print(f"  checkpoints: {wrote} repositories recorded at {screen_ckpt}")
        if prune_to_endpoints:
            rebuild.write_pruned_stamp(dest, result, mode)
    return 0




def _full(args, run: ScreenRun, argv, source: Path, dest: Path,
          records_dir: Path) -> int:
    """The whole corpus build, in one process.

    Five phases, and the order is the whole point. Each of the two table passes mutates the
    group's `dependencies.dart`, and that fixture decides the feature vectors, which decide
    the contrast set -- so the screen has to run again after each of them or the record
    describes a corpus that no longer exists.

        1  screen + export      fixtures into the store, `dest` exported
        2  fixture_values       resolve every `// TODO: value` into config/fixture_values.json
        3  screen + export      again, so the store agrees with the filled table
        4  maximal_branch       branch-gating bindings to their maximal-render arm
        5  screen + export      + --prune-to-endpoints: ship only the measured roles

    Phase 3 never resumes. `screen_mode` folds `values_version()` into every checkpoint, and
    phase 2 moves that digest, so phase 1's checkpoints describe a different values regime --
    resuming across the fill would mix two of them in one corpus. Phase 5 DOES resume:
    `config/maximal_branch.json` is not in `values_version()`, so phase 3's checkpoints are
    still valid.

    The three refusals that enforce this order by hand -- `require_fixture_pass_done` and
    `refuse_if_pruned` in both table tools -- are left in place and satisfied in sequence.
    They are what makes the phase-by-phase path checkable, and running the phases here must
    not be the only way to get the order right.

    `--from-nothing` wraps the five in a phase 0 that deletes what they are about to
    regenerate and a gate that checks they regenerated it. With it, and with R16 deriving the
    one exclusion that used to be a hand list, the corpus is a pure function of the COMMITTED
    POLICY TABLES plus the mine -- `config/fixture_policy.json` and, since 2026-09-04,
    `config/license_policy.json`. See `screen/rebuild.py`.
    """
    from scripts import fixture_values, maximal_branch

    def phase(n: int, what: str) -> None:
        print(f"\n{'=' * 78}\n== phase {n}/5  {what}\n{'=' * 78}", flush=True)

    snapshot = None
    if args.from_nothing:
        phase(0, "tear down everything the rebuild is about to regenerate")
        snapshot = rebuild.teardown(source, dest, baseline=args.baseline)

    if args.init:
        phase(0, "seed the value table (--init)")
        digest = fixture_values.init_values_table()   # refuses if one already exists
        print(f"seeded {fixture_values.VALUES_PATH.name}: values_version {digest}")

    phase(1, "screen the mine, export the eligible groups")
    rc = _one_pass(dataclasses.replace(
                       run,
                       # --init changes values_version(), so every checkpoint is stale by design.
                       resume=run.resume and not args.init,
                       rescreen=run.rescreen or args.init,
                       prune_to_endpoints=False),
                   argv, source, dest, records_dir)
    if rc:
        return rc

    # Phase 1 has just re-exported the COMPLETE eligible role set -- "the copy loop only
    # ADDS", so every role phase 5 of an earlier run pruned away is back on disk -- which
    # makes any prune stamp left by that run false. It has to go before phase 2, because
    # `fixture_values` and `maximal_branch` both refuse against a stamped tree and would
    # otherwise refuse on an assertion that is no longer true.
    #
    # Without this, `--full` works exactly ONCE against a given `--dest`: phase 5 stamps the
    # corpus, and the next `--full` dies in phase 2. `--from-nothing` never noticed because
    # its teardown deletes the tree, stamp and all. The pipeline screening once per BATCH is
    # what found it -- on 2026-09-06 batch 1 screened clean and every batch after it recorded
    # `screen_refused`, with the mining kept and nothing shipped.
    #
    # The guard itself is untouched and still protects what it was written for: a STANDALONE
    # `fixture_values` or `maximal_branch` run against a tree that really does hold only
    # endpoints, where no phase 1 has restored anything.
    stamp = dest / fixture_skeleton.PRUNED_NAME
    if stamp.is_file():
        stamp.unlink()
        print(f"  cleared the prune stamp: phase 1 re-exported every eligible role",
              flush=True)

    phase(2, "resolve every `// TODO: value` into the values table")
    fixture_values.run(dest, eligible_only=True, apply=True)
    # `_fixture_values()` caches the table in a module global, read once. Phases 3 and 5 must
    # see what phase 2 just wrote, or they rebuild the fixtures from the pre-fill table.
    _reset_fixture_values()

    phase(3, "re-screen, so the fixture store agrees with the filled table")
    rc = _one_pass(dataclasses.replace(run, resume=False, rescreen=True,
                                       prune_to_endpoints=False),
                   argv, source, dest, records_dir)
    if rc:
        return rc

    phase(4, "set branch-gating bindings to their maximal-render arm")
    maximal_branch.run(dest, eligible_only=True, apply=True, init=args.init)

    phase(5, "re-screen and ship only the roles that will be MEASURED")
    rc = _one_pass(dataclasses.replace(run, resume=True, rescreen=False,
                                       prune_to_endpoints=True),
                   argv, source, dest, records_dir)
    if rc or snapshot is None:
        return rc
    rebuild.verify(snapshot, dest, records_dir)
    return 0


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(
        prog="python3 -m scripts.screen_samples",
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--source", required=True, type=Path,
                    help="the mined corpus to screen (a directory of NNNN/ group "
                         "plus its manifests)")
    ap.add_argument("--dest", type=Path,
                    help="where the eligible groups and their filtered manifests go. "
                         "Omit with --report-only to screen without exporting.")
    ap.add_argument("--full", action="store_true",
                    help="build the whole corpus in one command. Runs the five phases the "
                         "runbook documents separately, in order, in this process: screen "
                         "and export; `fixture_values --apply` to resolve every "
                         "`// TODO: value`; re-screen so the fixture store agrees with the "
                         "filled table; `maximal_branch --apply` for the branch-gating "
                         "bindings; then re-screen and --prune-to-endpoints. The order "
                         "matters because each table pass rewrites the fixture and the "
                         "fixture decides the feature vectors. The individual commands still "
                         "work and are still the way to debug one phase.")
    ap.add_argument("--from-nothing", action="store_true",
                    help="with --full, rebuild the corpus from the mine and "
                         "config/fixture_policy.json alone. Deletes --dest and both "
                         "generated tables first -- refusing if anything at --dest was "
                         "authored or measured -- then runs the five phases and CHECKS the "
                         "result against what was committed: the regenerated "
                         "fixture_values.json byte for byte, maximal_branch.json on its "
                         "derived content, and the published corpus counts. Implies --init.")
    ap.add_argument("--no-baseline", dest="baseline", action="store_false",
                    help="with --from-nothing, rebuild without comparing the regenerated "
                         "tables against the committed ones. For a genuine first run, when "
                         "there is nothing to compare against -- never to get past a gate "
                         "that failed.")
    ap.add_argument("--init", action="store_true",
                    help="with --full, a from-scratch rebuild: seed config/fixture_values.json "
                         "and accept a missing config/maximal_branch.json, then screen without "
                         "resuming. Off by default, and refused if either table already "
                         "exists -- a missing table must keep RAISING, because re-deriving "
                         "one degrades quietly (a missing blobless clone sends a binding to a "
                         "policy default with no error anywhere).")
    ap.add_argument("--report-only", action="store_true",
                    help="screen and write exclusions.json, but export nothing")
    ap.add_argument("--exclude-groups", action="append", metavar="IDS",
                    help="group ids this run must exclude whatever the rules say: "
                         "`0224`, `0224,0231`, or `@file` with one id per line. In a "
                         "file the rest of the line is the REASON for the exclusion, with "
                         "or without a leading `#`, and it is recorded in exclusions.json "
                         "against that group -- R0 is the one rule whose justification "
                         "cannot be re-derived from anything. Repeatable. An id matching "
                         "no group prints as UNMATCHED rather than passing silently.")
    ap.add_argument("--no-fixtures", dest="fixtures", action="store_false",
                    default=True,
                    help="do not copy fixtures into --dest. By default the export writes "
                         "one dependencies.dart per group: the seeds, the stand-ins and the "
                         "null constants hoisted out of its transplants, with every value "
                         "left as a TODO. Every role in the group shares the one file, so "
                         "filling it in once makes all of them runnable and keeps the "
                         "stubbing symmetric across a pair; a fixture anyone has edited is "
                         "never overwritten. They are still generated into the store either "
                         "way, because the screen cannot compute vectors without them -- "
                         "this only produces a corpus that will not mount.")
    ap.add_argument("--force-prune", action="store_true",
                    help="also delete stale groups that hold hand-authored files "
                         "(dependencies.dart, mutation_*.dart). Those are kept by default "
                         "because they are not rebuildable from --source.")
    ap.add_argument("--resume", action="store_true",
                    help="replay the verdicts of repositories an earlier run already "
                         "screened, from the per-repository checkpoints, instead of "
                         "re-reading their transplants. Only FINISHED repositories are "
                         "checkpointed, so a resumed run is exactly the work the mine has "
                         "added since. Checkpoints written in a different mode "
                         "(--strict, --dest, rule set) are ignored, not trusted.")
    ap.add_argument("--screen-checkpoints", type=Path, default=None,
                    help="where this screen's per-repository checkpoints live. Defaults "
                         "to `checkpoints_screen/` beside `mine`'s checkpoint directory.")
    ap.add_argument("--include-unfinished", action="store_true",
                    help="screen groups of repositories whose `mine` has not checkpointed "
                         "yet. Off by default: those directories are still gaining "
                         "revisions, so R8 and the duplicate pass would judge a "
                         "half-written group. They are HELD -- never exported, never "
                         "deleted -- until their repository finishes.")
    ap.add_argument("--keep-excluded-revisions", action="store_true",
                    help="ship every file of a group that ships. By default each "
                         "`rev_*.dart` is screened on its own content and the ones that "
                         "fire a hard rule are left behind, since a pair needs both "
                         "endpoints clean.")
    ap.add_argument("--prune-to-endpoints", action="store_true",
                    help="ship only the roles that will be MEASURED: the endpoints of the "
                         "contrasts that survived every rule. A group ships because it "
                         "carries a contrast, and on the current corpus 177 of the 439 "
                         "roles that screen clean are an endpoint of one -- the rest are "
                         "mined, screened and measured by nothing. RUN THIS LAST, after "
                         "`fixture_values --apply` and `maximal_branch --apply`: both read "
                         "the roles off disk (anchor_sha takes the lowest-ordinal revision "
                         "present, constructible() the union of them all), so pruning "
                         "before they have run can move a stored value and therefore "
                         "values_version(). Refused unless the fixture pass is already "
                         "done, and stamps the corpus so those two tools refuse afterwards.")
    ap.add_argument("--keep-unpairable", action="store_true",
                    help="do not apply R8: keep groups with fewer than 2 transplanted "
                         "states. They can never yield a before/after delta, so this is "
                         "only for a static-only use of the corpus.")
    ap.add_argument("--fixture-store", type=Path, default=None,
                    help="where generated fixtures live. Defaults to `fixtures/` beside "
                         "--source. Keyed by group id and independent of any export: the "
                         "screen needs a fixture to resolve a group's vectors, and --dest is "
                         "a derived directory that can be deleted and rebuilt, so the one "
                         "file a human edits must not live there. A value filled in the "
                         "store survives every re-screen and re-export.")
    ap.add_argument("--license-provenance", type=Path, default=None,
                    help="the `license_provenance.jsonl` R17 names inlined packages from. "
                         "Defaults to config/license_provenance.jsonl, written by "
                         "`python3 -m scripts.mining license-provenance`. A separate "
                         "flag because a corpus screened somewhere other than the mine it "
                         "came from -- the golden corpus is one -- carries its own, and "
                         "silently falling back to the real one would attribute a file "
                         "from a table about different files.")
    ap.add_argument("--render-exclusions", type=Path, default=None,
                    help="the `render_exclusions.json` R21/R22 read what the device DREW "
                         "from. Defaults to config/render_exclusions.json, written by "
                         "`python3 -m scripts.render_gate --apply`. Separate for the reason "
                         "--license-provenance is, and the golden corpus is what proved it: "
                         "the table is global while --source and --dest are arguments, so a "
                         "test corpus screened without this flag was judged on the REAL "
                         "corpus's device verdicts. An absent file is an empty table, which "
                         "is what a corpus no campaign has run against should be judged on.")
    ap.add_argument("--license-candidates", type=Path, default=None,
                    help="the collector record R18 reads repository licences from. Defaults "
                         "to data/candidates.jsonl. Separate for the same reason "
                         "--license-provenance is: a corpus screened away from the harvest "
                         "that produced it carries its own, and falling back to the real "
                         "one would judge these repositories by someone else's record.")
    ap.add_argument("--vectors", type=Path, default=None,
                    help="the `static_vectors.jsonl` all-pairwise deltas are taken from. "
                         "Defaults to one beside --source. It is a separate flag because "
                         "the vectors and the screen usually come from DIFFERENT trees: "
                         "`spm analyze` needs the group's dependencies.dart to resolve, so "
                         "vectors can only be extracted from an exported corpus, while the "
                         "fixture split and R13 need the bindings still in the role, so "
                         "they can only be read from the un-hoisted one. `(group, role)` "
                         "is the same key in both.")
    ap.add_argument("--binding-source", type=Path, default=None,
                    help="the tree R13 reads its binding sets from, when that is not "
                         "--source. An exported corpus has had its lifted and seed "
                         "bindings hoisted into each group's dependencies.dart, so "
                         "re-splitting a shipped role finds none and R13 passes every pair "
                         "vacuously; point this at the un-hoisted corpus the roles came "
                         "from. Refused rather than guessed: a run where no surviving pair "
                         "hoists anything aborts.")
    ap.add_argument("--allow-unverified", action="store_true",
                    help="screen a corpus in which nothing carries an `spm isolate` "
                         "verdict, so R10/R11 fire on nothing. Refused by default: that is "
                         "what a corpus whose mine has not written its manifests looks "
                         "like, and screening it passes every transplant spm already "
                         "rejected. A corpus mined under spm <= 0.5.1 genuinely has no "
                         "verdicts, and this is how to say so.")
    ap.add_argument("--allow-unequal-bindings", action="store_true",
                    help="do not apply R13: keep a pair whose two endpoints mount from "
                         "different fixture bindings. `binding_delta` is still recorded on "
                         "every pair, so this is how the rule's cost is measured against "
                         "the same corpus snapshot rather than against an older screen.")
    ap.add_argument("--allow-shim-form-drift", action="store_true",
                    help="do not apply R20: keep a pair whose two endpoints reach shim "
                         "constructors that differ in whether they render the subtree they "
                         "were handed. `shim_drop_delta` is still recorded on every pair, so "
                         "this is how the rule's cost is measured against the same corpus "
                         "snapshot -- the same arrangement --allow-unequal-bindings gives "
                         "R13. Group 0082 is the case the rule exists for.")
    ap.add_argument("--no-normalise", "--no-normalize", "--no-fix-images",
                    dest="fix_images", action="store_false", default=True,
                    help="export verbatim. By default the exported .dart is rewritten so it "
                         "references no resource this container cannot resolve: spm's "
                         "`Image.asset('assets/placeholder.png')` skeleton becomes the grey "
                         "box the curated samples/ corpus uses, third-party icon-font refs "
                         f"become {ICON_STANDIN}, and custom fontFamily arguments and "
                         "third-party package: imports are dropped. Without it the "
                         "placeholders reference an asset that does not exist, those in "
                         "CircleAvatar.backgroundImage do not compile, and FontAwesomeIcons "
                         "/ CarbonIcons are undefined identifiers. Applies to --dest only, "
                         "never --source.")
    ap.add_argument("--no-prune-unused-imports", dest="prune_imports",
                    action="store_false", default=True,
                    help="keep every import spm emitted. By default the export drops each "
                         "import whose contribution is already covered by one that stays -- "
                         "unused and merely-redundant alike, since a mined transplant "
                         "carries the full import list the analyser resolved it through and "
                         "the curated samples/ corpus carries 2.5 imports per file where an "
                         "unpruned mine carries 4.7. Harmless to measurement either way -- "
                         "no static feature counts imports -- but the exported corpus then "
                         "differs from samples/ in a way nothing else explains.")
    ap.add_argument("--records", type=Path, default=None,
                    help="where exclusions.json and EXCLUSIONS.md go. Defaults to "
                         "--source. Point it elsewhere to screen a corpus that must not "
                         "be written to, such as the frozen probe_v2/samples_v2/.")
    ap.add_argument("--overwrite-records", action="store_true",
                    help="allow replacing an exclusions.json whose groups this corpus no "
                         "longer has. Refused by default when groups.jsonl still claims "
                         "them -- deleted, not re-mined -- or when no groups.jsonl exists "
                         "to tell the two apart; a re-mine needs no flag.")
    ap.add_argument("--checkpoints", type=Path, default=None,
                    help="`mine`'s per-repository checkpoint directory. Defaults to "
                         "<source>/checkpoints, then probe_v2/checkpoints.")
    ap.add_argument("--markdown", action="store_true", help="also write EXCLUSIONS.md")
    ap.add_argument("--strict", action="store_true",
                    help="promote every SOFT rule from flagging to excluding: "
                         + ", ".join(sorted(SOFT_RULES)) + ". Not R6 alone -- R12 fires on "
                         "roughly half the corpus, so this removes far more evidence than "
                         "the rule that motivated the flag. The rates are in the report; "
                         "read them before deciding.")
    ap.add_argument("--prune", action="store_true",
                    help="delete groups already at --dest that this run excludes")
    ap.add_argument("--rescreen", action="store_true",
                    help="ignore the resume cache and re-read every file")
    ap.add_argument("--dry-run", action="store_true",
                    help="report what would be copied, and write nothing to --dest, "
                         "--records or the checkpoints. It DOES still populate the fixture "
                         "store: the all-pairwise contrast set is differenced over vectors "
                         "that only exist once each group's dependencies.dart resolves, so "
                         "a dry run that skipped that phase could not report a contrast "
                         "count at all. The store is idempotent and never overwrites a "
                         "fixture anyone has edited.")
    args = ap.parse_args(argv)

    source = args.source.resolve()
    if not source.is_dir():
        ap.error(f"--source is not a directory: {source}")
    if args.from_nothing:
        if not args.full:
            ap.error("--from-nothing is only meaningful with --full: it tears down what the "
                     "five phases regenerate, and one phase alone would rebuild a fragment.")
        args.init = True          # a torn-down tree has no table for phase 0 to preserve
        # And it prunes. R16 is inert in phase 1 -- the table it reads is the one phase 2
        # writes -- so a group it later excludes IS exported first: `0607` ships in phase 1
        # and is excluded in phase 3. Left behind it would be STALE-but-present, and the
        # tree would disagree with `exclusions.json` at exactly the granularity the 2026-09-01
        # `fixture_provenance.json` correction was about. Safe here and nowhere else: every
        # directory at --dest was put there by this same run, moments ago.
        args.prune = True
    elif not args.baseline:
        ap.error("--no-baseline is only meaningful with --from-nothing.")

    if args.full:
        # Each is a real contradiction rather than an unsupported combination, so each says
        # which phase it collides with.
        if args.report_only:
            ap.error("--full exports: phases 1, 3 and 5 each write --dest. Drop "
                     "--report-only, or run the phases separately.")
        if args.vectors:
            ap.error("--full computes its own vectors: the fill and the branch pass both "
                     "rewrite the fixtures the vectors are taken from, so vectors supplied "
                     "from another tree would describe the corpus before phase 2.")
        if args.prune_to_endpoints:
            ap.error("--full already prunes, in phase 5. Drop --prune-to-endpoints.")
        if args.dry_run:
            ap.error("--full writes the values and override tables in phases 2 and 4, which "
                     "a dry run cannot model. Use --dry-run on a single pass instead.")
        if not args.fixtures:
            ap.error("--full fills the fixtures in phase 2 and reads them back in phases 3 "
                     "and 5, so it cannot run with --no-fixtures: there would be nothing at "
                     "--dest to fill, and the corpus it shipped would not mount.")
        if args.dest is None:
            ap.error("--full needs a --dest to build.")
    elif args.init:
        ap.error("--init is only meaningful with --full; the individual tools have their "
                 "own --init.")
    if args.fixtures and args.vectors and not args.report_only:
        # `--vectors` says "the vectors already exist, do not run phase B". Phase B is also
        # where the fixture split and every role's staged text are computed, so skipping it
        # leaves the export with no text to write and it died on a bare KeyError inside
        # `_rewriter`. Refused rather than papered over: falling back to the un-hoisted text
        # would ship a corpus with no `dependencies.dart`, which does not mount -- a silent
        # wrong answer in place of a loud crash.
        ap.error(
            "--vectors cannot be combined with fixture generation on an export.\n"
            "  --vectors skips the phase that BUILDS the fixtures, so there would be "
            "nothing to write.\n"
            "  To export: drop --vectors and let the screen compute its own vectors:\n"
            "    python3 -m scripts.screen_samples --source <corpus> --dest <out> "
            "--markdown\n"
            "  To screen against vectors from another tree, add --report-only, or pass "
            "--no-fixtures.")
    if args.fixtures and not args.fix_images:
        # The split is computed against the normalised text, in one pass, so there is no
        # split that skips normalisation. Refuse rather than silently normalise anyway.
        ap.error("--no-normalise cannot be combined with fixture generation: the split is "
                 "computed against the normalised text, in one pass, so there is no split "
                 "that skips normalisation. Pass --no-fixtures as well.")
    # `--report-only` still builds fixtures: without one a group has no vectors and cannot
    # be screened at all. What it skips is the export.
    if not args.report_only and args.dest is None:
        ap.error("--dest is required unless --report-only is given")

    dest = args.dest.resolve() if args.dest else None
    if dest is not None and dest == source:
        ap.error("--dest must differ from --source: it is a DERIVED directory, "
                 "rebuildable from --source at any time, so nothing may be "
                 "authored there")

    records_dir = (args.records.resolve() if args.records else source)
    # Created rather than refused: on a first run --records is usually --dest, which does
    # not exist yet, and failing there would make the first invocation the awkward one.
    if not records_dir.is_dir():
        if records_dir.exists():
            ap.error(f"--records is not a directory: {records_dir}")
        records_dir.mkdir(parents=True, exist_ok=True)

    # Screening a corpus that has LOST groups cannot produce sound PAIR verdicts: a pair is
    # attributed through a scope_key that several groups may claim, and the groups that
    # would have disagreed are the ones already gone. Group verdicts are unaffected -- they
    # read only each surviving base.dart. `records_reduction` carries the reasoning and the
    # one distinction the check used to miss: a corpus also shrinks when a repository is
    # re-mined, which is a reduction with an author and not a deletion.
    # Refusing, not warning. A warning printed to stderr does not stop the records being
    # overwritten, and the run that overwrites them is exactly the one whose pair verdicts
    # are unsound -- so the good file is replaced by the bad one and nothing fails.
    prior = records_dir / "exclusions.json"
    if prior.is_file() and not args.overwrite_records:
        verdict, ids, before, here = records_reduction(prior, source)
        if verdict == "remined":
            # Said out loud rather than passed over: the corpus is smaller than the record
            # being replaced, and a run that reports a smaller funnel without saying why
            # reads as a corpus that lost something.
            print(f"note: {len(ids)} of the {before} groups {prior.name} screened are gone "
                  f"from {source.name}, and its groups.jsonl has dropped them too -- a "
                  f"re-mine took them back, nothing was deleted. Replacing the record.",
                  file=sys.stderr)
        elif verdict != "ok":
            if verdict == "pruned":
                shown = ", ".join(ids[:10]) + ("..." if len(ids) > 10 else "")
                why = (f"  {len(ids)} of the {before} groups it screened are gone from "
                       f"{source}, and groups.jsonl STILL CLAIMS them,\n"
                       f"  so they were deleted rather than re-mined: {shown}\n")
            else:
                why = (f"  It records a screen of {before} groups; this run screens "
                       f"{here}, and {source} has no groups.jsonl\n"
                       f"  to say whether a re-mine took the difference back.\n")
            print(
                f"REFUSING to overwrite {prior}\n"
                f"{why}"
                f"  Group verdicts would still be right, but PAIR verdicts would not: a "
                f"pair is attributed through a\n"
                f"  scope_key that several groups can claim, and the claimants that would "
                f"have disagreed are gone.\n"
                f"  Restore the missing group directories from the full corpus and re-run, "
                f"or pass --overwrite-records\n"
                f"  if you really mean to replace this record. (--report-only is not a way "
                f"round it: it writes\n"
                f"  exclusions.json too.)",
                file=sys.stderr)
            return 2

    # The flag names are read once, here, and never cross a module seam again.
    run = ScreenRun.from_args(args)
    if args.full:
        return _full(args, run, argv, source, dest, records_dir)
    return _one_pass(run, argv, source, dest, records_dir)


if __name__ == "__main__":
    sys.exit(main())
