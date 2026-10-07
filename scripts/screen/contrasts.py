"""Forming the contrast set: which pairs of roles exist to be screened at all.

Every within-scope pair of distinct-code roles, differenced over vectors extracted from the
shipped transplants themselves. The adjacent set is the ADJACENT SUBSET of these rows --
flagged per row rather than screened separately, so the primary test can never drift from
what was screened.
"""

from __future__ import annotations

import collections
import itertools
from pathlib import Path

from scripts import extract_features
from scripts.screen.rules import MIN_REVISIONS_FOR_A_PAIR, ZERO_DELTA_RULE


def all_pairwise_rows(source: Path, revs_by_group: dict, ids_by_key: dict[str, list[str]],
                      hard: set[str], rules_for_file,
                      vectors_path: Path | None = None,
                      vectors: dict | None = None,
                      group_rules: dict[str, list[str]] | None = None,
                      render_rules: dict[tuple[str, str], list[str]] | None = None
                      ) -> tuple[list[dict], dict]:
    """Every within-scope pair of distinct-code roles, differenced over the shipped files.

    Three filters run before a pair exists at all, and each is reported rather than applied
    silently, because each shrinks the corpus by an amount nothing else records:

      1. **no vector.** `spm analyze` skips a file carrying an error-severity diagnostic.
         The dominant cause is not the transplant but the group's own generated fixture:
         `dependencies.dart` is a `part of` the role's library, so one `duplicate_definition`
         in the union fixture errors EVERY role of that group at once. Group `1440` loses
         17 of 19 roles to a single `assistant_error` declared twice.
      2. **R14, short vector.** `closureResolved == 0`; see the rule's own comment.
      3. **duplicate content.** `mine` writes a `rev_*.dart` only when the transplant's
         sha256 changed, but that hash is taken over the SOURCE scope: 905 of 1,179
         ordinal-adjacent shipped roles are byte-identical to their neighbour anyway. Two
         identical files are one role, and pairing them would manufacture a contrast whose
         delta is zero by construction.

    Ordinals are never renumbered, here as everywhere else: the surviving roles keep the
    `rev_NNN` names the pair records refer to, so the deduped sequence has gaps.

    `group_rules` carries the verdicts that are properties of the GROUP -- R7 duplicate, R0
    hand exclusion, R9 hold -- because no endpoint file can fire them and the rule
    intersection below would therefore never see them. On a normal run phase B builds a
    fixture only for a group with none of the three, so an excluded group has no vector and
    forms no pair; supply `--vectors` and that protection is gone -- a duplicate group forms
    eligible contrasts, `export` gates on `carries_pair`, and the group ships.

    `render_rules` carries R21/R22 -- what the DEVICE drew for one role, from
    `config/render_exclusions.json`. Role-level like R14, but applied here rather than in the
    usable-role filter above, because unlike a short vector it must appear on the pair row:
    R14 describes a file `spm analyze` could not read, while a role that drew an error box
    was screened, shipped and MEASURED, and the ledger has to say which contrast that cost.

    Reported, never silently omitted: an excluded row is a ledger entry saying which rule
    removed the contrast, which is the same contract every other rule here has.
    """
    if vectors is None:
        vectors = extract_features.load(source, vectors_path)
    if not vectors:
        raise SystemExit(
            "all-pairwise screening produced no feature vectors. It differences absolute "
            "vectors, and the mine's checkpoints carry only adjacent `d_<feature>` deltas, "
            "so there is nothing to difference between two non-adjacent revisions. The run "
            "normally builds them itself; check the fixture phase above for why it could "
            "not.")

    key_by_id = {gid: key for key, gids in ids_by_key.items() for gid in gids}
    group_rules = group_rules or {}
    render_rules = render_rules or {}
    keys = extract_features.DELTA_FEATURE_KEYS
    rows: list[dict] = []
    funnel = collections.Counter()
    seen_sha: dict[str, set[str]] = {}

    for gid, revs in sorted(revs_by_group.items()):
        usable: list[tuple[int, str, Path]] = []
        by_sha: dict[str, str] = {}
        for ordinal, sha8, path in revs:
            vec = vectors.get((gid, path.stem))
            if vec is None:
                funnel["roles_without_a_vector"] += 1
                continue
            if vec.get("_resolved") != 1:
                funnel["roles_excluded_R14_short_vector"] += 1
                continue
            if vec["_sha"] in by_sha:
                funnel["roles_dropped_duplicate_content"] += 1
                continue
            by_sha[vec["_sha"]] = path.stem
            usable.append((ordinal, sha8, path))
        funnel["distinct_code_roles"] += len(usable)
        if len(usable) >= MIN_REVISIONS_FOR_A_PAIR:
            funnel["scopes_with_a_contrast"] += 1
        seen_sha[gid] = set(by_sha)

        scope_key = key_by_id.get(gid)
        adjacent = {(a[0], b[0]) for a, b in zip(usable, usable[1:])}
        for (oa, sha_a, pa), (ob, sha_b, pb) in itertools.combinations(usable, 2):
            va, vb = vectors[(gid, pa.stem)], vectors[(gid, pb.stem)]
            delta = {k: vb[k] - va[k] for k in keys}
            fired = ((set(rules_for_file(pa)) | set(rules_for_file(pb))
                      | set(render_rules.get((gid, pa.stem), ()))
                      | set(render_rules.get((gid, pb.stem), ()))) & hard) \
                | set(group_rules.get(gid, ()))
            if fired:
                verdict, why, endpoints = "excluded", sorted(fired), None
            elif not any(delta.values()):
                verdict, why, endpoints = "excluded", [ZERO_DELTA_RULE], None
            else:
                verdict, why, endpoints = "eligible", [], (pa, pb)
            rows.append({"pair_id": f"{scope_key}@{sha_a}..{sha_b}", "group": gid,
                         "scope_key": scope_key, "claimants": None,
                         "verdict": verdict, "rules": why,
                         # The adjacent set is the adjacent subset of these same rows,
                         # so it is flagged rather than screened separately -- one funnel,
                         # and the primary test can never drift from what was screened.
                         "adjacent": (oa, ob) in adjacent,
                         # Recorded on every row, verdict regardless: R15's rate is the
                         # whole of its justification, and a zero-delta row is the evidence.
                         "delta": delta,
                         "binding_delta": None, "_endpoints": endpoints})
    return rows, dict(funnel)
