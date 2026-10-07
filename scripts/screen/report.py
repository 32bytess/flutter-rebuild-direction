"""What the screen says on stdout, in `exclusions.json`, and in `EXCLUSIONS.md`.

`exclusions.json` is the artifact that leaves this machine: `maximal_branch.py` and
`fixture_values.py` read it, and the
report appendix quotes the markdown generated beside it. So the rule of this module is that
every number it prints is also written down, and every number it writes down carries the
denominator it is a fraction of -- contrasts beside the scopes and repositories they are
spread across, R13's cost beside the pairs it was computed on.
"""

from __future__ import annotations

import collections
from pathlib import Path

from scripts.screen.export import ICON_STANDIN
from scripts.screen.manifests import REVISION_NAME
from scripts.screen.rules import (BINDING_REASON, BINDING_RULE, BINDING_SECTIONS,
                                  SHIM_FORM_REASON, SHIM_FORM_RULE,
                                  DUPLICATE_REASON, DUPLICATE_RULE, NO_PAIR_REASON,
                                  NO_PAIR_RULE, PACKAGE_LICENSE_REASON,
                                  PACKAGE_LICENSE_RULE, RENDER_ERROR_REASON,
                                  RENDER_ERROR_RULE, RENDER_NOTHING_REASON,
                                  RENDER_NOTHING_RULE, REPO_LICENSE_REASON,
                                  REPO_LICENSE_RULE, RULES, SHORT_VECTOR_REASON,
                                  SHORT_VECTOR_RULE, SOFT_RULES, UNFILLABLE_REASON,
                                  UNFILLABLE_RULE, UNFINISHED_REASON,
                                  UNFINISHED_RULE, ZERO_DELTA_REASON, ZERO_DELTA_RULE,
                                  reasons)

# --------------------------------------------------------------------------------------
# Reporting
# --------------------------------------------------------------------------------------
def report(result: dict, source: Path, prov: dict | None = None
           ) -> tuple[dict, collections.Counter, set]:
    groups, pair_verdict = result["groups"], result["pair_verdict"]
    n = len(groups)
    elig = [g for g in groups.values() if g["eligible"]]
    fired = collections.Counter(r for g in groups.values() for r in g["all_rules"])
    reason = reasons()

    print(f"groups screened: {n}")
    if n:
        print(f"  eligible: {len(elig)} ({100*len(elig)/n:.1f}%)")
        print(f"  excluded: {n-len(elig)} ({100*(n-len(elig))/n:.1f}%)")
    promoted = ", ".join(sorted(SOFT_RULES))
    print(f"  mode: {f'strict ({promoted} exclude)' if result['strict'] else f'default ({promoted} flag only)'}"
          f"{'' if result.get('binding_rule', True) else ', R13 OFF (--allow-unequal-bindings)'}")
    cover = result.get("verification_coverage") or {}
    if cover.get("files_flagged"):
        print(f"  spm verification: {cover['files_flagged']} transplants in "
              f"{cover['groups_with_flagged_files']} groups flagged by R10/R11")
    elif cover.get("files_with_a_verdict"):
        print(f"  spm verification: {cover['files_with_a_verdict']} transplants carry a "
              f"verdict and every one of them analyses clean "
              f"({cover['files_covered']} rows seen in all)")
    else:
        print("  spm verification: NOTHING CARRIES A VERDICT -- R10/R11 fired on nothing "
              "because no manifest and no checkpoint was found, not because the corpus is "
              "clean. Point --checkpoints at the mine's checkpoint directory, or wait for "
              "it to write its manifests, before reading this screen as an R10 result.")
    if cover.get("files_from_checkpoints"):
        print(f"    of which {cover['files_from_checkpoints']} came from per-repository "
              f"checkpoints -- this mine has not written its manifests yet")
    print("\nrule firings (a group may fire several):")
    for rid, c in sorted(fired.items(), key=lambda kv: -kv[1]):
        print(f"  {c:4d}  {rid:18s} {reason.get(rid,'')}")

    cf = result.get("contrast_funnel") or {}
    if cf:
        # The role funnel comes first because the pair count is a FUNCTION of it: three
        # filters decide which roles exist to be paired, and a reader who sees only the
        # contrast total cannot tell a small corpus from a heavily filtered one.
        print("\nroles -> contrasts:")
        for k in ("roles_without_a_vector", "roles_excluded_R14_short_vector",
                  "roles_dropped_duplicate_content", "distinct_code_roles",
                  "scopes_with_a_contrast"):
            if k in cf:
                print(f"  {cf[k]:5d}  {k}")
    print(f"\ncontrasts (all-pairwise): {len(result['pair_rows'])}")
    for v, c in pair_verdict.most_common():
        print(f"  {c:5d}  {v}")
    # The adjacent subset, reported beside the wider set it is drawn from. Both
    # denominators, always: quoting only the first invites the independence attack and
    # only the second undersells the training set.
    adjacent = [r for r in result["pair_rows"] if r.get("adjacent")]
    elig_adj = sum(1 for r in adjacent if r["verdict"] == "eligible")
    print(f"  of which ADJACENT (the adjacent subset): {len(adjacent)}, "
          f"{elig_adj} eligible")
    # R13's cost, on stdout and not only in the markdown: it is the one rule whose whole
    # justification is the rate, and a `--dry-run` writes no markdown to read it from.
    rows = result["pair_rows"]
    deltas = collections.Counter(r["binding_delta"]["relation"]
                                 for r in rows if r.get("binding_delta"))
    if deltas:
        blocked = [r for r in rows
                   if (r.get("binding_delta") or {}).get("relation") not in (None, "identical")]
        reach = sum(1 for r in blocked if r["binding_delta"]["reaches_build"])
        on = result.get("binding_rule", True)
        print(f"\n{BINDING_RULE} ({'applied' if on else 'NOT applied'}), computed on the "
              f"{sum(deltas.values())} pairs that survived every other rule:")
        for k, c in deltas.most_common():
            print(f"  {c:5d}  {k}")
        print(f"  {len(blocked)} {'excluded' if on else 'would be excluded'}: "
              f"{reach} turn on a binding `build` reads (part of the edit), "
              f"{len(blocked) - reach} on one it never reads")
    # R20's cost, for R13's reason: the rate is the justification, and a `--dry-run` writes
    # no markdown to read it from.
    shim = result.get("shim_form") or {}
    if shim.get("pairs_compared"):
        on = result.get("shim_form_rule", True)
        print(f"\n{SHIM_FORM_RULE} ({'applied' if on else 'NOT applied'}), computed on the "
              f"{shim['pairs_compared']} pairs that survived every content rule:")
        print(f"  {shim['pairs_disagreeing']:5d}  "
              f"{'excluded' if on else 'would be excluded'} -- endpoints disagree, so the "
              f"delta is the shim's constructor coverage")
        print(f"  {shim['pairs_dropping_at_both']:5d}  kept -- both endpoints erase the same "
              f"subtree, which understates magnitude only (R19, soft)")

    eligible_scopes = {r["scope_key"] for r in result["pair_rows"] if r["verdict"] == "eligible"}
    # The groups R16 flagged: eligible, but not measurable until someone writes the fixture.
    # Read from the same block the worklist is published from, so the counters and the list
    # can never disagree.
    awaiting = result.get("unfillable") or {}
    print(f"\nELIGIBLE MOVER SCOPES: {len(eligible_scopes)}  "
          f"(carrying {pair_verdict['eligible']} eligible contrasts)")
    if awaiting:
        # Both sizes, together, every time. The screen is where this number is first said
        # out loud, and saying only the first would overstate what can be measured.
        measurable = sum(1 for r in result["pair_rows"]
                         if r["verdict"] == "eligible" and r["group"] not in awaiting)
        scopes = {r["scope_key"] for r in result["pair_rows"]
                  if r["verdict"] == "eligible" and r["group"] not in awaiting}
        print(f"MEASURABLE TODAY:     {len(scopes)} scopes, {measurable} contrasts  "
              f"({len(awaiting)} group(s) awaiting a hand-authored fixture)")
    held = result.get("unfinished") or set()
    if held:
        print(f"\nheld: {len(held)} groups from repositories still being mined "
              f"({len(result.get('finished_repos') or ())} repositories have checkpointed)")

    # Per-scope and per-repository spread. Quoted in the decisions record -- "26.0% largest
    # repository share", the per-scope contrast counts -- and until now recomputable from
    # nothing here: no group row carried its project, so both had to be derived elsewhere and
    # neither could be checked against the screen that produced them.
    project_by_id = result.get("project_by_id") or {}
    per_scope = collections.Counter(
        r["scope_key"] for r in result["pair_rows"] if r["verdict"] == "eligible")
    per_repo = collections.Counter(
        project_by_id.get(r["group"]) for r in result["pair_rows"]
        if r["verdict"] == "eligible" and r["group"])
    scopes_per_repo = collections.Counter(
        project_by_id.get(gid) for gid in
        {r["group"] for r in result["pair_rows"]
         if r["verdict"] == "eligible" and r["group"]})
    largest = max(per_repo.values()) if per_repo else 0

    out = {
        "generated": "scripts/screen_samples.py",
        "source": str(source),
        "provenance": prov or {},
        "mode": "strict" if result["strict"] else "default",
        "binding_rule": result.get("binding_rule", True),
        "shim_form_rule": result.get("shim_form_rule", True),
        "shim_form": result.get("shim_form") or {},
        "rules": [{"id": rid, "reason": txt, "soft": rid in SOFT_RULES} for rid, txt in RULES]
                 + [{"id": DUPLICATE_RULE, "reason": DUPLICATE_REASON, "soft": False},
                    {"id": NO_PAIR_RULE, "reason": NO_PAIR_REASON, "soft": False,
                     "kind": "yield, not measurability"},
                    {"id": UNFINISHED_RULE, "reason": UNFINISHED_REASON, "soft": False,
                     "kind": "held, not excluded"},
                    {"id": BINDING_RULE, "reason": BINDING_REASON, "soft": False,
                     "kind": "comparability, not measurability",
                     "sections": list(BINDING_SECTIONS)},
                    {"id": SHIM_FORM_RULE, "reason": SHIM_FORM_REASON, "soft": False,
                     "kind": "comparability, not measurability"},
                    {"id": SHORT_VECTOR_RULE, "reason": SHORT_VECTOR_REASON, "soft": False,
                     "kind": "role-level, not pair-level"},
                    {"id": ZERO_DELTA_RULE, "reason": ZERO_DELTA_REASON, "soft": False,
                     "kind": "yield, not measurability"},
                    {"id": UNFILLABLE_RULE, "reason": UNFILLABLE_REASON, "soft": True,
                     "kind": "authoring worklist, not exclusion (soft since 2026-09-08)"},
                    {"id": PACKAGE_LICENSE_RULE, "reason": PACKAGE_LICENSE_REASON,
                     "soft": False,
                     "kind": "redistribution, not measurability"},
                    {"id": REPO_LICENSE_RULE, "reason": REPO_LICENSE_REASON, "soft": False,
                     "kind": "redistribution, not measurability"},
                    {"id": RENDER_ERROR_RULE, "reason": RENDER_ERROR_REASON, "soft": False,
                     "kind": "role-level, and the evidence is the DEVICE not the source"},
                    {"id": RENDER_NOTHING_RULE, "reason": RENDER_NOTHING_REASON, "soft": True,
                     "kind": "role-level, and the evidence is the DEVICE not the source"}],
        "contrasts": "all_pairwise",
        "contrast_funnel": result.get("contrast_funnel") or {},
        "totals": {"groups": n, "eligible": len(elig), "excluded": n - len(elig),
                   # `nonzero_pairs` is the older name for the same count, kept beside it
                   # rather than renamed: it is published schema.
                   "contrasts_screened": len(result["pair_rows"]),
                   "nonzero_pairs": len(result["pair_rows"]),
                   "eligible_pairs": pair_verdict["eligible"],
                   "eligible_adjacent_pairs": sum(
                       1 for r in result["pair_rows"]
                       if r["verdict"] == "eligible" and r.get("adjacent")),
                   "eligible_mover_scopes": len(eligible_scopes),
                   # THE CORPUS HAS TWO SIZES SINCE 2026-09-08, and they must always be
                   # reported together. R16 no longer excludes: a group whose GENERATED fill
                   # left a binding unresolved stays eligible and waits for a hand-authored
                   # fixture, held off the device by `fixture_gate.py`. So `eligible_pairs`
                   # is what the screen admits and `measurable_pairs` is what could be
                   # measured today. Quoting the first alone would be the same failure as
                   # quoting a largest-contributor share without its denominator.
                   "awaiting_fixture_groups": len(awaiting),
                   "awaiting_fixture_bindings": sum(
                       len(i.get("bindings") or ()) for i in awaiting.values()),
                   "measurable_pairs": sum(
                       1 for r in result["pair_rows"]
                       if r["verdict"] == "eligible" and r["group"] not in awaiting),
                   "measurable_mover_scopes": len(
                       {r["scope_key"] for r in result["pair_rows"]
                        if r["verdict"] == "eligible" and r["group"] not in awaiting}),
                   "held_unfinished": len(result.get("unfinished") or ()),
                   "finished_repos": len(result.get("finished_repos") or ()),
                   "eligible_repositories": len(scopes_per_repo),
                   # The independence threat, in the artifact rather than beside it. A
                   # contrast count means nothing without the scopes and repositories it is
                   # spread across.
                   "largest_repository_share": round(
                       largest / sum(per_repo.values()), 4) if per_repo else 0.0},
        "by_repository": {repo: {"eligible_contrasts": per_repo[repo],
                                 "eligible_mover_scopes": scopes_per_repo[repo]}
                          for repo in sorted(per_repo, key=lambda r: (r is None, r))},
        "contrasts_per_scope": {k: per_scope[k]
                                for k in sorted(per_scope, key=lambda k: (k is None, k))},
        # Why each hand exclusion was made. Empty unless --exclude-groups named a reason.
        "manual_reasons": result.get("manual_reasons") or {},
        # THE AUTHORING WORKLIST. Why each R16 group's generated fill gave up, in the
        # policy's own words. Unlike R0's reasons these ARE re-derivable -- from
        # `fixture_policy.json` -- but recording them keeps the appendix table readable
        # without a second file open beside it, and since 2026-09-08 this block is a list of
        # work to do rather than a list of groups that are gone.
        "unfillable": result.get("unfillable") or {},
        # R18, per group: the repository, what the collector recorded, and why it is not
        # allowed. Empty on this corpus, and published anyway -- a rule that fires on nothing
        # has to be visible in the record, or a reader cannot tell it from a rule that was
        # never applied.
        "repo_license": result.get("repo_license") or {},
        # R17, per FILE and split by kind. `disallowed` is a policy verdict on a named
        # package; `unattributed` is a file carrying package source this run could not name.
        # Never pooled: only the second is fixed by re-running `mining license-provenance`.
        "package_license": result.get("package_license") or {},
        # R21/R22, per role: WHAT THE DEVICE DREW. The only block here whose evidence is not
        # in the source tree -- `scripts/render_gate.py` reads it back off a campaign's
        # screenshots and raw logs. Published verdict-regardless, including the soft R22 rows
        # that annotate rather than exclude, because a reader cannot otherwise tell a corpus
        # that was checked from one where no campaign has run. Empty before the first one.
        "render": result.get("render") or {},
        "groups": {g: {**d, "project": project_by_id.get(g)} for g, d in groups.items()},
        # Groups whose own base.dart is excluded but which a shipped corpus still carries,
        # because a pair of their revisions is eligible. Use their rev_*.dart, not base.
        "carried_for_pairs": sorted(
            {r["group"] for r in result["pair_rows"]
             if r["verdict"] == "eligible" and r["group"]}
            - {g for g, d in groups.items() if d["eligible"]}),
        "pairs": result["pair_rows"],
    }
    return out, fired, eligible_scopes


def _worklist(awaiting: dict) -> list[str]:
    """The authoring worklist: which group, which binding, and why the fill would not guess.

    R16 no longer excludes, so this is the artifact that says what is left to author. Declared and undeclared refusals are kept APART and in that order, because
    they call for different work: a declared one is a fixture to write, an undeclared one is
    a policy that is short -- possibly a typo that deleted a type -- and writing a fixture for
    it would paper over the omission rather than fix it.
    """
    declared = {g: i for g, i in sorted(awaiting.items()) if i.get("declared")}
    undeclared = {g: i for g, i in sorted(awaiting.items()) if not i.get("declared")}
    lines = ["## Awaiting a hand-authored fixture", "",
             "These groups are ELIGIBLE. They are not measurable until every binding below "
             "carries a value, which `scripts/fixture_gate.py` enforces. Author into "
             "`config/authored_fixtures/<gid>/dependencies.dart` -- a fixture edited under "
             "the corpus is deleted by the next `--prune`.", "",
             "| group | bindings | why the generated fill refused |", "|---|---|---|"]
    for gid, info in declared.items():
        lines.append(f"| `{gid}` | {', '.join(info.get('bindings') or ())} | "
                     f"{info.get('reason', '')} |")
    if undeclared:
        lines += ["", "### Undeclared — fix the policy, not the fixture", "",
                  "`config/fixture_policy.json` says nothing about these types. That is a "
                  "short policy, not a group that needs authoring, and the "
                  "`--from-nothing` gate refuses on it.", "",
                  "| group | bindings |", "|---|---|"]
        for gid, info in undeclared.items():
            lines.append(f"| `{gid}` | {', '.join(info.get('bindings') or ())} |")
    return lines + [""]


def write_markdown(path: Path, out: dict, groups: dict, fired: collections.Counter,
                   eligible_scopes: set, npairs: int) -> None:
    reason = reasons()
    n = out["totals"]["groups"]
    lines = ["# v2 exclusions — generated, never hand-edited", "",
             f"Produced by `scripts/screen_samples.py` in **{out['mode']}** mode. "
             f"Criteria and their provenance are documented in that file's docstring.", "",
             "| rule | groups | reason |", "|---|---|---|"]
    for rid, c in sorted(fired.items(), key=lambda kv: -kv[1]):
        lines.append(f"| `{rid}` | {c} | {reason.get(rid,'')} |")
    t = out["totals"]
    lines += ["", f"**{t['eligible']} of {n} groups eligible.** "
                  f"{len(eligible_scopes)} mover scopes survive, carrying "
                  f"{t['eligible_pairs']} of {npairs} nonzero-delta pairs.", ""]

    # The corpus has two sizes, and this file is where a reader meets them. Never print the
    # first without the second: an eligible group whose fixture is unwritten cannot be
    # measured, and a table that says only "eligible" would overstate what exists.
    awaiting = out.get("unfillable") or {}
    if awaiting:
        lines += [f"**{t['measurable_pairs']} of those {t['eligible_pairs']} pairs are "
                  f"measurable today**, across {t['measurable_mover_scopes']} scopes. The "
                  f"remainder belong to the {t['awaiting_fixture_groups']} group(s) below, "
                  f"whose `dependencies.dart` needs "
                  f"{t['awaiting_fixture_bindings']} binding(s) written by hand.", ""]
        lines += _worklist(awaiting)

    # What the device drew. Two verdicts, deliberately not pooled: R21 is a throw and it
    # excludes; R22 is a flat screen and it annotates. Printed together because a reader
    # weighing the corpus needs both numbers, and separately because only one is a refusal.
    drawn = out.get("render") or {}
    if drawn:
        rows_by_verdict = collections.Counter(
            row["verdict"] for roles in drawn.values() for row in roles.values())
        lines += ["## What the device drew", "",
                  f"`{RENDER_ERROR_RULE}` — {RENDER_ERROR_REASON}. **Excludes.**", "",
                  f"`{RENDER_NOTHING_RULE}` — {RENDER_NOTHING_REASON}. "
                  f"**Annotates** (`--strict` excludes).", "",
                  "| group | role | verdict | evidence |", "|---|---|---|---|"]
        for gid in sorted(drawn):
            for role in sorted(drawn[gid]):
                row = drawn[gid][role]
                shot = row.get("evidence", {}).get("shot_evidence") or {}
                why = row.get("evidence", {}).get("exception") \
                    or f"flat {shot.get('dominant')}"
                lines.append(f"| `{gid}` | `{role}` | `{row['verdict']}` | {why} |")
        lines += ["", f"{rows_by_verdict.get('renders_error', 0)} role(s) threw; "
                      f"{rows_by_verdict.get('renders_nothing', 0)} rendered nothing, "
                      f"across {len(drawn)} group(s). A role with no screenshot and no raw "
                      f"log is not in this table and was not cleared by it -- the census is "
                      f"a floor.", ""]

    # Pair-level verdicts. R13 appears ONLY here: it is a property of a contrast, not of a
    # group, so it never reaches the rule table above and a reader looking for it there
    # would conclude it had not fired.
    rows = out.get("pairs") or []
    verdicts = collections.Counter(r["verdict"] for r in rows)
    lines += ["## Pair verdicts", "", "| verdict | pairs |", "|---|---|"]
    lines += [f"| `{v}` | {c} |" for v, c in verdicts.most_common()]
    deltas = collections.Counter(r["binding_delta"]["relation"]
                                 for r in rows if r.get("binding_delta"))
    if deltas:
        # Counted from the recorded relation, not from the firing, so the line reads the
        # same under `--allow-unequal-bindings` -- which is the whole point of recording it.
        blocked = [r for r in rows
                   if (r.get("binding_delta") or {}).get("relation") not in (None, "identical")]
        reach = sum(1 for r in blocked if r["binding_delta"]["reaches_build"])
        on = out.get("binding_rule", True)
        lines += ["", f"`{BINDING_RULE}` — {BINDING_REASON}. "
                      f"**{'Applied' if on else 'NOT applied (--allow-unequal-bindings)'}.** "
                      f"Computed on the {sum(deltas.values())} pairs that survived every "
                      f"other rule: "
                  + ", ".join(f"**{c}** {k}" for k, c in deltas.most_common()) + ".", "",
                  f"Of the {len(blocked)} it {'excludes' if on else 'would exclude'}, "
                  f"**{reach}** turn on a binding `build` actually reads — part of the "
                  f"edit, not scaffolding — and **{len(blocked) - reach}** on one `build` "
                  f"never reads, which is assigned at mount and cannot enter "
                  f"`buildSpan`.", ""]

    shim = out.get("shim_form") or {}
    if shim.get("pairs_compared"):
        # Counted from the recorded relation, not from the firing, so the paragraph reads the
        # same under `--allow-shim-form-drift`.
        on = out.get("shim_form_rule", True)
        lines += ["", f"`{SHIM_FORM_RULE}` — {SHIM_FORM_REASON}. "
                      f"**{'Applied' if on else 'NOT applied (--allow-shim-form-drift)'}.** "
                      f"Computed on the {shim['pairs_compared']} pairs that survived every "
                      f"content rule: **{shim['pairs_disagreeing']}** disagree and are "
                      f"{'excluded' if on else 'kept'}, **{shim['pairs_dropping_at_both']}** "
                      f"erase the same subtree at both endpoints and are kept — that is "
                      f"symmetric scaffolding, which understates the delta's magnitude "
                      f"without misattributing it, and is R19's soft finding rather than "
                      f"this rule's.", ""]

    # Roles the fixture split dropped. Reported apart from the rules on purpose: without
    # this section 17% of role files vanish from the record with no row anywhere.
    clash = out.get("fixture_clashes") or {}
    if clash.get("roles"):
        kinds = collections.Counter(clash.get("kinds", {}).values())
        dropped = sum(len(v) for v in clash["roles"].values())
        lines += ["## Roles dropped by a fixture clash", "",
                  "Not a rule firing: every revision below screens clean on its own "
                  "content. They were dropped because they could not share their group's "
                  "`dependencies.dart`, and the fixture must not fork. A `lifted_value` "
                  "clash is a finding — two revisions carrying different values for one "
                  "binding would mount from different initial state. A `stand_in` clash is "
                  "a reconstruction artefact and says nothing about the scope.", "",
                  f"**{dropped} roles across {len(clash['roles'])} groups** — "
                  + ", ".join(f"{c} `{k}`" for k, c in kinds.most_common()) + ".", "",
                  "| group | role | could not reconcile | kind |", "|---|---|---|---|"]
        for gid, drops in sorted(clash["roles"].items()):
            for name, decl in sorted(drops.items()):
                lines.append(f"| `{gid}` | `{name}` | `{decl}` | "
                             f"`{clash.get('kinds', {}).get(name, '?')}` |")
        lines.append("")

    lines += ["## Excluded groups", "", "| group | rules |", "|---|---|"]
    for gid, g in sorted(groups.items()):
        if g["excluded_by"]:
            lines.append(f"| `{gid}` | {', '.join(g['excluded_by'])} |")
    path.write_text("\n".join(lines) + "\n")


def print_export_summary(stats: dict, dest, *, dry_run: bool) -> None:
    """The export half of what the screen says on stdout.

    Every line of it is a number that also has to appear in `exclusions.json`, which is this
    module's job rather than the entry point's.
    """
    print(f"\n{'would export' if dry_run else 'exported'} {stats['eligible']} "
          f"groups -> {dest}")
    print(f"  files: {stats['files_copied']} copied, "
          f"{stats['files_skipped']} already current")
    for kind, label in (("images", "placeholders replaced with the samples/ grey box"),
                        ("icons", f"foreign icon refs replaced with {ICON_STANDIN}"),
                        ("fonts", "custom fontFamily arguments dropped"),
                        ("imports", "third-party package imports dropped"),
                        ("unused", "imports dropped as already covered by another")):
        if stats["normalised"].get(kind):
            print(f"  {kind}: {stats['normalised'][kind]} {label}, across "
                  f"{stats['files_normalised'][kind]} files")
    if stats["files_screened_out"]:
        what = "would drop" if dry_run else "left behind"
        print(f"  revisions: {what} {stats['files_screened_out']} that fire a hard rule, "
              f"across {len(stats['dropped_files'])} shipped groups")
    if stats.get("pruned_to_endpoints"):
        n = sum(len(v) for v in stats.get("unmeasured_files", {}).values())
        what = "would leave behind" if dry_run else "not shipped"
        print(f"  endpoints: {what} {n} role(s) across "
              f"{len(stats.get('unmeasured_files', {}))} groups that screen clean and are an "
              f"endpoint of no eligible contrast")
        gone = sum(len(v) for v in stats.get("removed_at_dest", {}).values())
        if gone:
            verb = "would remove" if dry_run else "removed"
            print(f"             {verb} {gone} of them already at {dest}, left by an "
                  f"earlier run")
        shipped = sum(1 for f in stats["shipped_files"].values()
                      for name in f if REVISION_NAME.match(name))
        print(f"             {shipped} roles ship, across {len(stats['shipped_files'])} groups")
    if stats["emptied"]:
        print(f"  {len(stats['emptied'])} groups dropped: every transplant screened out "
              f"({', '.join(stats['emptied'][:10])}"
              f"{'...' if len(stats['emptied']) > 10 else ''})")
    if stats["held"]:
        print(f"  HELD {len(stats['held'])} groups of repositories the mine has not "
              f"checkpointed yet - neither exported nor deleted; re-run when they finish "
              f"(--include-unfinished screens them anyway)")
    # The fixture worklist: what is placed, and what still needs dependencies.dart.
    with_deps = sorted(g for g, files in stats["authored"].items()
                       if "dependencies.dart" in files)
    todo = [g for g in sorted(stats["shipped_files"]) if g not in with_deps]
    if stats["shipped_files"]:
        print(f"  fixtures: {len(with_deps)} groups have dependencies.dart, "
              f"{len(todo)} still need one")
    if stats.get("fixtures"):
        placed = stats["fixtures_placed"]
        values = sum(f["needs_value"] for f in stats["fixtures"].values())
        print(f"  skeletons: {len(stats['fixtures'])} groups, "
              f"{sum(f['entries'] for f in stats['fixtures'].values())} declarations "
              f"hoisted, {values} awaiting a value")
        written = "would write" if dry_run else "written"
        print("             " + ", ".join(
            f"{n} {written if label == 'written' else label}"
            for label, n in sorted(placed.items()) if n))
    if stats.get("fixture_clashes"):
        dropped = sum(len(v) for v in stats["fixture_clashes"].values())
        kinds = stats.get("fixture_clash_kinds") or {}
        values = sum(1 for k in kinds.values() if k == "lifted_value")
        example = sorted(stats["fixture_clashes"].items())[0]
        print(f"  {dropped} revisions dropped across {len(stats['fixture_clashes'])} groups: "
              f"a declaration contradicts the group's fixture "
              f"(e.g. {example[0]} {sorted(example[1])[0]})")
        if values:
            # Reported apart from the rest on purpose; see `fixture_skeleton.clash_kinds`.
            print(f"    of which {values} are LIFTED VALUES -- two revisions of one scope "
                  f"disagree about the initial state they mount from, which is the "
                  f"asymmetry the shared fixture exists to catch")
    if stats["protected"]:
        print(f"  KEPT {len(stats['protected'])} excluded groups that hold authored files "
              f"({', '.join(sorted(stats['protected'])[:10])}"
              f"{'...' if len(stats['protected']) > 10 else ''}); --force-prune removes them")
    if stats["carried_for_pairs"]:
        print(f"  {stats['self_eligible']} eligible on their own base.dart, plus "
              f"{len(stats['carried_for_pairs'])} carried FOR THEIR REVISIONS "
              f"(base.dart excluded): {', '.join(stats['carried_for_pairs'])}")
    if stats.get("no_contrast"):
        # The count this export exists to stop shipping. Loud, because it is the difference
        # between "measurable" and "has something to measure across", and reading the first
        # as the second is what put 88 unusable groups in the last corpus.
        print(f"  NOT shipped: {len(stats['no_contrast'])} groups screen clean but carry "
              f"no eligible contrast -- measurable, nothing to measure across")
    for name, count in sorted(stats["manifest_rows"].items()):
        print(f"  {name:26s} {count} rows")
    if stats["stale"]:
        if stats["pruned"]:
            label = "would prune" if dry_run else "pruned"
            print(f"  {label} {len(stats['stale'])} excluded group directories")
        else:
            print(f"  STALE: {len(stats['stale'])} groups at --dest are excluded by this run "
                  f"and were left in place ({', '.join(stats['stale'][:10])}"
                  f"{'...' if len(stats['stale']) > 10 else ''}); --prune removes them")

