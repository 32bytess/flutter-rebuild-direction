"""Phase B: build each candidate group's fixture, then extract the vectors from it.

This is the phase that dissolves the circle. All-pairwise contrasts are differenced over
absolute feature vectors; `spm analyze` only produces one where the group's
`dependencies.dart` resolves; and a fixture written at EXPORT would only reach a group that
already ships. So a corpus screened from scratch had no vectors, and a screen that ships only
contrast-carrying groups could never grow one for anything it had not already shipped -- a
ratchet that silently narrowed the corpus every pass. Building the fixture HERE, before the
contrast set is formed, is what breaks it.
"""

from __future__ import annotations

import collections
from pathlib import Path

from scripts import extract_features, fixture_skeleton
# The repository root, the root `spm analyze` is run from.
from scripts.paths import PROJECT_ROOT
from scripts.screen.rules import (DUPLICATE_RULE, MANUAL_RULE, MIN_REVISIONS_FOR_A_PAIR,
                                  NO_PAIR_RULE, REPO_LICENSE_RULE, UNFILLABLE_RULE,
                                  UNFINISHED_RULE)



def build_fixtures(source: Path, store: Path, groups: dict, hard: set[str], *,
                   backend, rules_for_file, fixture_values: dict,
                   log=print) -> dict:
    # All-pairwise contrasts are differenced over absolute feature vectors; `spm analyze`
    # only produces one where the group's `dependencies.dart` resolves; and a fixture used to
    # be written at EXPORT, for a group that already ships. So a corpus screened from scratch
    # had no vectors, and a screen that ships only contrast-carrying groups could never grow
    # one for anything it had not already shipped -- a ratchet that silently narrowed the
    # corpus every pass. It cost `0307`, which is all-pairwise eligible and has no eligible
    # ADJACENT pair, so no adjacent-based bootstrap reached it.
    #
    # Breaking it needs nothing new: the fixture is a union over the very splits `prime_splits`
    # already primes for R13, and `screen_mode` already folds `values_version()` into the
    # screen's own fingerprint because "fixture VALUES are as load-bearing as screening RULES".
    # The fixture was a screening artefact in everything but where it was written.
    #
    # Generated WIDE and gated NARROW: every group that survives its own per-file rules gets a
    # fixture, because `spm analyze` needs one to resolve, but `fixture_gate` still runs on the
    # exported corpus. 282 `// TODO: value` across the candidate groups against 59 across the
    # 50 that ship -- reporting the wide number as work owed would be wrong.
    fixture_store: dict[str, Path] = {}
    fixture_stats: dict[str, dict] = {}
    builds: dict[str, fixture_skeleton.GroupFixture] = {}
    role_text: dict[tuple[str, str], tuple[str, dict]] = {}
    fixture_dropped: dict[str, dict[str, str]] = {}
    fixture_clash_kinds: dict[str, str] = {}
    vectors: dict[tuple[str, str], dict] = {}
    vector_funnel: dict = {}
    store.mkdir(parents=True, exist_ok=True)
    index = fixture_skeleton.load_index(store)
    # NOT `d["eligible"]`. A group's verdict reflects its REPRESENTATIVE file only, and
    # this module says so itself: "reporting context, not the operative filter:
    # eligibility is decided per pair, on that pair's two endpoint files, because a
    # construct introduced in revision 40 says nothing about a pair at revision 3."
    # Gating candidates on it drops exactly the groups `carried_for_pairs` exists to
    # rescue -- `1793`, whose earliest revision fires a hard rule and whose later ones do
    # not. Only the three verdicts that really are about the WHOLE group disqualify here;
    # the per-file rules are applied per file, immediately below.
    # R16 is listed but, since 2026-09-08, normally absent from `excluded_by`: an unresolved
    # binding names authoring work rather than removing the group, so such a group DOES get
    # its `spm analyze` pass and DOES form contrasts -- without which R14 and R15 would never
    # see it and it could not be measured once its fixture was written. Under `--strict` R16
    # is excluding again and this line drops the group as it did before. R18 is here for a
    # blunter reason -- a group from a repository the study may not redistribute is out
    # whatever any of its files contain.
    group_level = {DUPLICATE_RULE, MANUAL_RULE, UNFINISHED_RULE, UNFILLABLE_RULE,
                   REPO_LICENSE_RULE}
    candidates = sorted(g for g, d in groups.items()
                        if not (group_level & set(d["excluded_by"])))
    hard_files = hard - group_level - {NO_PAIR_RULE}

    surviving: dict[str, list[Path]] = {}
    for gid in candidates:
        keep = [q for q in sorted((source / gid).glob("*.dart"))
                if q.name != fixture_skeleton.FIXTURE_NAME
                and not (set(rules_for_file(q)) & hard_files)]
        if len(keep) >= MIN_REVISIONS_FOR_A_PAIR:
            surviving[gid] = keep

    rows = backend.splits(
        [q for paths in surviving.values() for q in paths], prune_imports=True)
    placed = collections.Counter()
    for gid, paths in surviving.items():
        built = fixture_skeleton.build(
            {q.name: rows[q] for q in paths},
            fixture_values.get(gid, {}).get("bindings"))
        if built is None:
            continue            # nothing to hoist: the transplants stand on their own
        placed[fixture_skeleton.place(store, gid, built.text, index,
                                      dry_run=False)] += 1
        fixture_store[gid] = store / gid / fixture_skeleton.FIXTURE_NAME
        fixture_stats[gid] = {"entries": built.entries,
                              "needs_value": built.needs_value}
        builds[gid] = built
        if built.dropped:
            # A role whose declarations contradict the group's fixture cannot mount from
            # it. Recorded here rather than at export because it is a screening verdict:
            # the role is out of the corpus, not merely out of this shipment.
            fixture_dropped[gid] = dict(built.dropped)
            fixture_clash_kinds.update(built.clash_kinds)
            surviving[gid] = [q for q in paths if q.name not in built.dropped]

    # The exact bytes each role will ship as: its share hoisted into the group fixture,
    # or -- for a group with nothing to hoist -- the normalised file unchanged. Computed
    # once, here, and used for BOTH the analysis and the export, because a vector taken
    # over anything else describes a file that never mounts.
    for gid, paths in surviving.items():
        built = builds.get(gid)
        for q in paths:
            text = built.residuals[q.name] if built and q.name in built.residuals \
                else rows[q]["plainText"]
            role_text[(gid, q.stem)] = (text, rows[q]["counts"])
    fixture_skeleton.save_index(store, index)
    wide = sum(s["needs_value"] for s in fixture_stats.values())
    log(f"\nfixtures -> {store}")
    for kind, n in sorted(placed.items()):
        log(f"  {n:5d}  {kind}")
    # WIDE. What the shipped corpus owes is smaller and is what `fixture_gate` reports
    # against `--dest`; quoting this number as work owed would overstate it several-fold.
    log(f"  {wide:5d}  values awaited across {len(fixture_stats)} candidate groups "
        f"(the SHIPPED subset is what fixture_gate enforces)")

    # The split's `text`, not the source bytes: that is the file the export writes and
    # the device mounts. See `staged_vectors`.
    staged = {gid: [(q.stem, role_text[(gid, q.stem)][0]) for q in paths]
              for gid, paths in surviving.items()}
    vectors, vector_funnel = extract_features.staged_vectors(
        staged, fixture_store, project_root=PROJECT_ROOT, store=store,
        log=lambda fmt, *a: log(fmt % a))

    return {"fixture_paths": fixture_store, "fixture_stats": fixture_stats,
            "role_text": role_text, "fixture_dropped": fixture_dropped,
            "fixture_clash_kinds": fixture_clash_kinds,
            "vectors": vectors, "vector_funnel": vector_funnel}
