"""Putting the eligible groups, and the manifests filtered to them, at `--dest`.

Nothing is copied first and screened after: the walk visits `--source` and copies only what
survives, so `--dest` never holds a file the screen rejects and the full corpus is never
duplicated. It is a DERIVED directory -- it can be deleted and rebuilt from `--source` at any
time -- with one exception this module is built around: a file at `--dest` whose name the
corpus does not have is AUTHORED, and is never overwritten and never pruned.
"""

from __future__ import annotations

import collections
import json
import shutil
from pathlib import Path

from scripts import fixture_skeleton
from scripts.screen import freeze
from scripts.screen.backend import Screener
from scripts.screen.manifests import (ID_KEYED_JSON, ID_KEYED_JSONL, REVISION_NAME,
                                      SCOPE_KEYED_JSONL, VERBATIM, retarget)
from scripts.screen.rules import DUPLICATE_RULE, NO_PAIR_RULE, UNFINISHED_RULE

# Quoted in `--normalise`'s help and in the export summary. The substitution itself is
# `kIconStandIn` in `scripts/dart_tools/lib/src/normalise.dart`; this copy is display text
# only, and the calibration test there pins the real value.
ICON_STANDIN = "Icons.circle"
def _rewriter(rewrites: dict, path: Path):
    """`copy_file`'s `transform` for one already-computed rewrite.

    The text argument is ignored: the rewrite came from the backend, which read the file
    itself. Keeping the callable signature is what leaves `copy_file` -- and its content
    comparison, the thing that makes a re-export idempotent -- untouched.
    """
    return lambda _text: rewrites[path]


def _read_verbatim(path: Path) -> str:
    """Read without newline translation, so line endings survive a rewrite unchanged."""
    with open(path, encoding="utf-8", errors="replace", newline="") as fh:
        return fh.read()


def copy_file(src: Path, dst: Path, *, dry_run: bool,
              transform=None, guard=None) -> tuple[bool, dict]:
    """Copy one file unless an identical one is already there.

    Returns (acted, substitutions). `copy2` preserves size and mtime, so "same size and same
    mtime" is an exact statement that this file was already copied, not a heuristic.

    With `transform`, the destination is the REWRITTEN source, which never matches its
    source on size or mtime -- so the "already there" test becomes a content comparison
    instead. That is what keeps a re-run idempotent rather than re-writing every file.

    `guard` is called only on the paths that reach a write, and after every "already there"
    test has said no. That ordering is the whole contract for `screen.freeze`: a re-export
    of a measured group writes nothing and must not raise, and one that would change its
    bytes must. Passing the check to the write site rather than testing the group up front
    is what keeps those two apart.
    """
    if transform is not None:
        # newline="" throughout: universal-newline mode would silently rewrite a CRLF file
        # to LF, which is a content change this pass has no business making. 82 of
        # 0787/rev_005's lines are CRLF and stayed that way once this was fixed.
        text, counts = transform(_read_verbatim(src))
        if dst.is_file() and _read_verbatim(dst) == text:
            return False, counts
        if guard is not None:
            guard()
        if dry_run:
            return True, counts
        dst.parent.mkdir(parents=True, exist_ok=True)
        with open(dst, "w", encoding="utf-8", newline="") as fh:
            fh.write(text)
        return True, counts
    if dst.is_file():
        s, d = src.stat(), dst.stat()
        if s.st_size == d.st_size and s.st_mtime_ns == d.st_mtime_ns:
            return False, {}
        # Size and mtime differ, which for an untransformed copy is usually a re-clone
        # rather than a content change. Ask the bytes before waking the guard, so a
        # `copy2` that would land identical content stays the no-op it has always been.
        if src.read_bytes() == dst.read_bytes():
            return False, {}
    if guard is not None:
        guard()
    if dry_run:
        return True, {}
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, dst)
    return True, {}


def export(source: Path, dest: Path, result: dict, *, screener: Screener,
           dry_run: bool, prune: bool,
           screen_revisions: bool = True, force_prune: bool = False,
           prune_to_endpoints: bool = False,
           fix_images_on: bool = True, prune_imports: bool = True,
           fixtures_on: bool = False) -> dict:
    """Put the eligible groups, and manifests filtered to them, at `dest`.

    `dest` is a DERIVED directory: it can be deleted and rebuilt from `source` at any time,
    so nothing should ever be authored there.
    """
    # One read of the pin for the whole export. `freeze.load()` leaves released entries out,
    # so a group whose fixture is being repaired on purpose passes straight through.
    #
    # The guard rides the WRITE sites, not the group: an ordinary re-screen of a measured
    # group reaches `copy_file`'s content comparison and `place`'s `current`, writes nothing
    # and never wakes it. Only a run that would actually change the bytes a measurement was
    # taken against gets refused, and it is refused BEFORE the first byte lands rather than
    # reported after the directory has already moved.
    frozen = freeze.load()

    def _guard(gid: str, name: str):
        return (lambda: freeze.refuse(gid, name, frozen)) if gid in frozen else None

    # A group ships if it is eligible ITSELF, or if it carries a pair that is -- the two
    # are decided on different files and do not have to agree. A group's verdict reads its
    # `base.dart`, the HEAD transplant; a pair's reads that pair's own two endpoint
    # revisions. So a scope whose HEAD grew an AnimationController is rightly excluded as a
    # standalone sample while the revisions of it from before that change remain perfectly
    # measurable. Filtering on the group verdict alone deleted the endpoint files of 28 of
    # 64 eligible pairs on the round-2 corpus -- shipping a pair with no files to measure.
    # Such a group is carried FOR ITS REVISIONS; its own `base.dart` stays excluded, which
    # `exclusions.json` still records against it.
    #
    # And the group is not the unit of exclusion for its FILES. With `screen_revisions`
    # every `.dart` in a shipped group is screened on its own content: a revision that
    # fires a hard rule is left behind even when the group ships, because it can never be
    # an endpoint of an eligible pair (a pair needs BOTH endpoints clean). Ordinals are
    # never renumbered, so the surviving files keep the names the pair records name them
    # by, with gaps -- the same contract `id` has.
    #
    # A group ships when it CARRIES A CONTRAST, not when its own representative screens
    # clean. Those are different sets and the difference is not small: group-level
    # eligibility is R1-R12 over one file, while R13, the zero-delta rule and the role
    # filters behind them are properties of a PAIR, and none of them could ever reduce the
    # shipped set. On the 2026-08-27 corpus that shipped 173 groups of which 85 carried an
    # eligible pair -- 88 directories, 85 generated fixtures and 605 rev_*.dart that no
    # contrast could ever use, each one a `// TODO: value` someone would have had to
    # author and a role the runner would have had to measure.
    #
    # `self_eligible` is still computed, and still reported, because the two counts
    # together are the funnel: how many groups are measurable at all, and how many of those
    # have something to measure ACROSS.
    self_eligible = {g for g, d in result["groups"].items() if d["eligible"]}
    carries_pair = {r["group"] for r in result["pair_rows"]
                    if r["verdict"] == "eligible" and r["group"]}
    # HELD, not shipped and not deleted: the mine is still writing these.
    held = result.get("unfinished") or set()
    # Shipping only contrast-carrying groups is safe ONLY because fixtures do not come
    # from here. While they did, this set decided which groups ever got a `dependencies.dart`,
    # which decided which could be analysed, which decided which could carry a contrast --
    # a ratchet that narrowed the corpus every pass and cost `0307`, all-pairwise eligible
    # with no eligible ADJACENT pair. Fixtures are now built in the screen's own phase B,
    # over every group that survives its per-file rules, so the two questions are separate:
    # "can this group be analysed" and "does it carry anything to measure".
    eligible_set = carries_pair - held
    eligible = sorted(eligible_set)

    # Group-level rules say nothing about any single file, so they never screen one out.
    hard_files = set(result["hard"]) - {DUPLICATE_RULE, NO_PAIR_RULE, UNFINISHED_RULE}

    replay = result.get("resumed_files") or {}

    from_manifest = result.get("manifest_rules") or {}

    def file_rules(path: Path) -> list[str]:
        if not screen_revisions or path.suffix != ".dart":
            return []
        gid = path.parent.name
        recorded = replay.get(gid)
        rules = (recorded[path.name] if recorded and path.name in recorded
                 else screener.rules_for(path))
        # R10/R11 come from the manifest rather than the file; see `verification_rules`.
        rules = set(rules) | set(from_manifest.get(gid, {}).get(path.name, ()))
        return sorted(rules & hard_files)
    src_prefix, dst_prefix = str(source.resolve()), str(dest.resolve())

    # A group exported by an earlier run that this run excludes. Reported, never removed
    # without --prune: it usually means the rule set changed, which is a decision to
    # confirm rather than to apply.
    stale = sorted(
        d.name for d in dest.glob("*/")
        if d.name.isdigit() and d.name not in eligible_set and d.name not in held
    ) if dest.is_dir() else []

    # AUTHORED files: anything at `dest` whose name the corpus does not have -- a
    # hand-written `dependencies.dart` or `mutation_*.dart`. `dest` is a derived directory
    # for everything the screen puts there, but it is where the fixture work happens, and
    # that work is not rebuildable from `--source`. So a group holding authored files is
    # never deleted, whatever verdict this run gives it: the verdict is reported, the
    # directory is kept, and `--force-prune` is the only way to remove it.
    fixture_index = fixture_skeleton.load_index(dest)

    def authored_files(gid: str) -> list[str]:
        d = dest / gid
        if not d.is_dir():
            return []
        have = {f.name for f in (source / gid).iterdir() if f.is_file()} \
            if (source / gid).is_dir() else set()
        # An untouched skeleton is derived, not authored: it was generated from `--source`
        # and can be generated again, so it must not protect its group from `--prune` the
        # way a hand-written fixture does. The first edit to it flips this.
        if fixture_skeleton.is_generated(dest, gid, fixture_index):
            have = have | {fixture_skeleton.FIXTURE_NAME}
        # `fixture_provenance.json` is written by `fixture_values --apply` and
        # `maximal_branch --apply`, so it is as derived as the fixture -- but it has no
        # counterpart in `--source` and is not FIXTURE_NAME, so it used to read as authored
        # and made its group unprunable. Measured on 2026-09-01: `0607` was excluded by
        # `--exclude-groups`, its verdict was recorded, and the directory survived anyway --
        # which matters because `fixture_gate` walks DIRECTORIES, so the group excluded on
        # the record still failed the gate. 29 of the 51 groups carried one, so any of them
        # would have done the same.
        have = have | {fixture_skeleton.PROVENANCE_NAME}
        return sorted(f.name for f in d.iterdir() if f.is_file() and f.name not in have)

    protected = {} if force_prune else {gid: a for gid in stale if (a := authored_files(gid))}
    stale = [gid for gid in stale if gid not in protected]

    # Which files of a shipped group survive their own screening. Recorded per group so the
    # manifests can be filtered to them and so an emptied group is caught rather than
    # exported as a directory with nothing measurable in it.
    dropped_files: dict[str, list[str]] = {}
    kept_files: dict[str, set[str]] = {}
    for gid in eligible:
        kept, dropped = set(), []
        for src in sorted((source / gid).iterdir()):
            if not src.is_file():
                continue
            if file_rules(src):
                dropped.append(src.name)
            else:
                kept.add(src.name)
        kept_files[gid] = kept
        if dropped:
            dropped_files[gid] = dropped
    # ---- the fixture split ---------------------------------------------------------
    # Before `emptied`, because a role dropped for contradicting its group's fixture leaves
    # the group with one fewer transplant and possibly with none.
    # Built in phase B, against the fixture STORE, and only copied here. `--dest` is a
    # derived directory -- its own docstring says nothing should ever be authored in it --
    # and generating the one file a human has to edit into a tree that can be deleted and
    # rebuilt was the reason a hand-filled value survived only by the sentinel-hash trap
    # inside one particular dest. In the store it survives every re-screen and re-export.
    fixtures: dict[str, fixture_skeleton.GroupFixture] = {}
    clashes: dict[str, dict[str, str]] = {gid: dict(v)
                                          for gid, v in (result.get("fixture_dropped") or {}).items()
                                          if gid in eligible_set}
    clash_kinds: dict[str, str] = dict(result.get("fixture_clash_kinds") or {})
    store_paths: dict[str, Path] = result.get("fixture_paths") or {}
    if fixtures_on:
        for gid, names in clashes.items():
            for name in names:
                kept_files[gid].discard(name)
                dropped_files.setdefault(gid, []).append(name)

    # A group whose every transplant screened out ships nothing; drop the group itself
    # rather than create an empty directory the manifests still point into.
    emptied = sorted(g for g in eligible
                     if not any(f.endswith(".dart") for f in kept_files[g]))
    if emptied:
        eligible_set -= set(emptied)
        eligible = sorted(eligible_set)
        for g in emptied:
            kept_files.pop(g, None)
            dropped_files.pop(g, None)
            fixtures.pop(g, None)

    # ---- ships only the roles that will be MEASURED --------------------------------
    # The scope-level narrowing above has a role-level twin, left to the
    # runner. A group ships because it CARRIES A CONTRAST; the roles that contrast is
    # actually taken between are its endpoints, and on the 2026-09-01 corpus that is 177
    # of the 439 that screen clean. The other 262 are mined, screened, and measured by
    # nothing -- `device_runner --eligible-only` skips them at a cost of ~3,900 executions
    # if it is forgotten, and `fixture_gate` walks DIRECTORIES rather than the record, which
    # is the same class of tree-disagrees-with-ledger failure the `0607` drop turned up.
    #
    # OFF by default, and the caller guards it, because two tools read the roles off disk
    # rather than from the record: `fixture_values.anchor_sha()` takes the group's
    # LOWEST-ORDINAL revision present, and `constructible()` is fed the union of every
    # `rev_*.dart` in the group. Pruning before they have run would move a recovered value
    # and therefore `values_version()`, which folds into the screening fingerprint -- the
    # prune would invalidate the screen that decided it. See `--prune-to-endpoints`.
    #
    # `rule_shipped` is the pre-prune snapshot. The checkpoints get THAT, not what survives
    # here: a checkpoint records what the rules said about a repository's files, and
    # endpoint membership is a property of the whole corpus that no per-repository record
    # can replay.
    rule_shipped = {gid: set(names) for gid, names in kept_files.items()}
    unmeasured_files: dict[str, list[str]] = {}
    if prune_to_endpoints:
        endpoint_roles: dict[str, set[str]] = result.get("endpoint_roles") or {}
        # A group awaiting a hand-authored fixture keeps ALL its roles. The prune is a
        # one-way door and its endpoint set was computed against vectors extracted from a
        # fixture whose slots are still open; a role that is not an endpoint today can
        # become one once the values are written. Pruning them would silently decide the
        # shape of a contrast set nobody has finished building. R16 is soft, so these groups
        # are eligible and reach this loop -- before 2026-09-08 they were excluded and the
        # question did not arise.
        awaiting = set(result.get("unfillable") or ())
        for gid in eligible:
            if gid in awaiting:
                continue
            keep = set(endpoint_roles.get(gid, ()))
            # Only roles are ever pruned. The fixture, its provenance and anything else in
            # the directory are not contrast endpoints and are not this filter's business.
            gone = sorted(n for n in kept_files[gid]
                          if REVISION_NAME.match(n) and Path(n).stem not in keep)
            # An endpoint the pair record names but this export is not shipping. The live
            # way to reach it is a fixture clash discarding a role that is an endpoint of an
            # eligible contrast -- a pair with nothing to measure, which is precisely what
            # shipping a group for its revisions exists to prevent. Refused rather than
            # quietly measured short.
            missing = sorted(keep - {Path(n).stem for n in kept_files[gid]})
            if missing:
                raise RuntimeError(
                    f"group {gid}: {len(missing)} endpoint(s) of an eligible contrast are "
                    f"not being shipped ({', '.join(missing)}). The pair record and the "
                    f"export disagree about what exists; re-screen rather than prune.")
            if gone:
                unmeasured_files[gid] = gone
                kept_files[gid] -= set(gone)
            left = sum(1 for n in kept_files[gid] if REVISION_NAME.match(n))
            if left < 2:
                raise RuntimeError(
                    f"group {gid} would ship {left} role(s) after pruning to endpoints, and "
                    f"a contrast needs two. It is in the eligible set, so it carries a pair; "
                    f"that pair's endpoints are unaccounted for.")

    copied = skipped = 0
    fixed = collections.Counter()
    files_fixed = collections.Counter()
    # Clash drops are not rule firings and must not be reported as any: a role dropped for
    # contradicting its group's fixture screens perfectly well on its own content.
    screened_out = sum(len(v) for g, v in dropped_files.items() if g in eligible_set) \
        - sum(len(v) for g, v in clashes.items() if g in eligible_set)
    # Every rewrite this export needs, in one batch, before any file is copied. Rewriting
    # lazily per file would be one subprocess per file; the eligible set is small, so
    # holding all of it in memory is cheaper than starting the tool hundreds of times.
    rewrites: dict[Path, tuple[str, dict[str, int]]] = {}
    if fixtures_on:
        # The split already carries normalisation, so it replaces the `rewrites` call rather
        # than running after it. A group with no fixture keeps `plainText`, which is exactly
        # what `rewrites` would have produced for it.
        staged_text = result.get("role_text") or {}
        for gid in eligible:
            for name in sorted(kept_files[gid]):
                if not name.endswith(".dart"):
                    continue
                got = staged_text.get((gid, Path(name).stem))
                if got is not None:
                    rewrites[source / gid / name] = got
    elif fix_images_on:
        rewrites = screener.backend.rewrites(
            [source / gid / name
             for gid in eligible
             for name in sorted(kept_files[gid])
             if name.endswith(".dart")],
            prune_imports=prune_imports)
    for gid in eligible:
        for name in sorted(kept_files[gid]):
            # Only `.dart` is rewritten; a manifest or a hand-authored fixture is copied
            # byte for byte.
            tf = _rewriter(rewrites, source / gid / name) \
                if ((fix_images_on or fixtures_on) and name.endswith(".dart")) else None
            acted, counts = copy_file(source / gid / name, dest / gid / name,
                                      dry_run=dry_run, transform=tf,
                                      guard=_guard(gid, name))
            for kind, n in counts.items():
                if n:
                    fixed[kind] += n
                    files_fixed[kind] += 1
            if acted:
                copied += 1
            else:
                skipped += 1

    if not dry_run:
        dest.mkdir(parents=True, exist_ok=True)

    # ---- the fixtures themselves -------------------------------------------------------
    # After the transplants, so a group is never left with a `part` directive pointing at a
    # file that is not there yet.
    placed = collections.Counter()
    for gid in sorted(g for g in store_paths if g in eligible_set):
        src_fixture = store_paths[gid]
        if not src_fixture.is_file():
            continue
        placed[fixture_skeleton.place(dest, gid, src_fixture.read_text(), fixture_index,
                                      dry_run=dry_run,
                                      guard=_guard(gid, fixture_skeleton.FIXTURE_NAME))] += 1
    if store_paths and not dry_run:
        fixture_skeleton.save_index(dest, fixture_index)

    # ---- manifests, filtered to what is at `dest` --------------------------------------
    keep_ids = eligible_set
    scope_keys = {k for k, v in result["id_by_key"].items() if v in keep_ids}
    written: dict[str, int] = {}

    def write_jsonl(name: str, keep) -> None:
        src = source / name
        if not src.is_file():
            return
        rows = []
        for line in src.read_text().splitlines():
            if not line.strip():
                continue
            row = json.loads(line)
            if keep(row):
                rows.append(retarget(row, src_prefix, dst_prefix, eligible_set))
        written[name] = len(rows)
        if not dry_run:
            (dest / name).write_text("".join(json.dumps(r) + "\n" for r in rows))

    def kept_row(r: dict) -> bool:
        """A row survives if its group ships AND, when it names a transplant file, that
        file survived its own screening. `revisions.jsonl` is one row per written revision,
        so a row for a screened-out revision would index a file that is not there."""
        gid = r.get("id")
        if gid not in keep_ids:
            return False
        if gid not in kept_files:
            return True                   # held: not screened, so nothing was dropped
        for key in ("file", "revision", "filename", "path", "rev_file"):
            name = r.get(key)
            if isinstance(name, str) and name.endswith(".dart"):
                return Path(name).name in kept_files[gid]
        return True

    for name in ID_KEYED_JSONL:
        write_jsonl(name, kept_row)
    for name in SCOPE_KEYED_JSONL:
        write_jsonl(name, lambda r: r.get("scope_key") in scope_keys)

    for name in ID_KEYED_JSON:
        src = source / name
        if src.is_file():
            data = json.loads(src.read_text())
            kept = {k: v for k, v in data.items() if k in keep_ids}
            written[name] = len(kept)
            if not dry_run:
                (dest / name).write_text(json.dumps(retarget(kept, src_prefix, dst_prefix, eligible_set),
                                                    indent=0))

    # id_map.json is identity -> id. Filtering it to the exported ids keeps the promise that
    # an id, once allocated, always means the same scope.
    src = source / "id_map.json"
    if src.is_file():
        data = json.loads(src.read_text())
        kept = {k: v for k, v in data.items() if v in keep_ids}
        written["id_map.json"] = len(kept)
        if not dry_run:
            (dest / "id_map.json").write_text(json.dumps(kept, indent=2, sort_keys=True) + "\n")

    for name in VERBATIM:
        src = source / name
        if src.is_file() and not dry_run:
            shutil.copy2(src, dest / name)

    # The copy loop only ADDS, so a role this run stopped shipping is still sitting at
    # `dest` from the run that did ship it. Pruning to endpoints is a claim about what the
    # directory holds, not just about what was written this time, so the leftovers go --
    # under the same derived/authored test `--prune` uses for a whole group. A file with no
    # counterpart in `--source` is hand-authored and is never removed.
    removed_at_dest: dict[str, list[str]] = {}
    if prune_to_endpoints:
        for gid in eligible:
            d = dest / gid
            if not d.is_dir():
                continue
            derived = {f.name for f in (source / gid).iterdir() if f.is_file()} \
                if (source / gid).is_dir() else set()
            gone = sorted(f.name for f in d.iterdir()
                          if f.is_file() and REVISION_NAME.match(f.name)
                          and f.name not in kept_files[gid] and f.name in derived)
            if not gone:
                continue
            removed_at_dest[gid] = gone
            freeze.refuse(gid, f"{len(gone)} role file(s): {', '.join(gone)}", frozen)
            if not dry_run:
                for name in gone:
                    (d / name).unlink(missing_ok=True)
    for gid in sorted(stale) if prune else []:
        freeze.refuse(gid, "the whole group directory (it is stale for this run)", frozen)
    if prune and stale and not dry_run:
        for gid in stale:
            shutil.rmtree(dest / gid, ignore_errors=True)

    return {"eligible": len(eligible), "files_copied": copied, "files_skipped": skipped,
            "stale": stale, "pruned": bool(prune and stale), "manifest_rows": written,
            "self_eligible": len(self_eligible - held),
            # Groups that screen clean on their own but carry no eligible contrast, so they
            # are measurable and have nothing to measure across. Reported, not shipped.
            "no_contrast": sorted(self_eligible - carries_pair - held),
            "carried_for_pairs": sorted(carries_pair - self_eligible - held),
            "files_screened_out": screened_out, "dropped_files": dropped_files,
            # Roles that screen clean and are an endpoint of no eligible contrast. A
            # separate bucket from `dropped_files` on purpose: nothing here fired a rule,
            # and folding it in would report the prune as a rule's cost.
            "unmeasured_files": unmeasured_files,
            "removed_at_dest": removed_at_dest,
            "pruned_to_endpoints": prune_to_endpoints,
            # What the RULES shipped, before the endpoint prune. The checkpoints record
            # this; see the prune block for why.
            "rule_shipped": {g: sorted(f) for g, f in rule_shipped.items()},
            "protected": protected,
            "normalised": dict(fixed), "files_normalised": dict(files_fixed),
            "authored": {gid: a for gid in eligible if (a := authored_files(gid))},
            "fixtures": {gid: s for gid, s in (result.get("fixture_stats") or {}).items()
                         if gid in eligible_set},
            "fixtures_placed": dict(placed), "fixture_clashes": clashes,
            "fixture_clash_kinds": clash_kinds,
            "shipped_files": {g: sorted(f) for g, f in kept_files.items()},
            "emptied": emptied, "held": sorted(held)}
