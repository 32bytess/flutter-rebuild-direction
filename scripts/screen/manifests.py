"""Reading what `mine` wrote, and rewriting it for an exported tree.

Every function here answers one question about a corpus from its manifests or from the
per-repository checkpoints, in that order of authority, and none of them makes a screening
decision. The recurring problem they exist to solve: `mine` writes its manifests when it
EXITS, so a corpus whose mine is still running carries none of them, and the checkpoints are
the only durable record until it does.
"""

from __future__ import annotations

import collections
import glob
import json
import re
from pathlib import Path

from scripts import jsonio
from scripts.paths import PROJECT_ROOT
from scripts.screen.rules import (INLINE_REVERTED_RULE, SOURCE_UNRESOLVED_RULE,
                                  UNVERIFIED_RULE)

# Moved to `scripts/jsonio.py` so every reader of a concurrently-written file can have it,
# not just this module. Re-exported under its original name: `screen_samples.__all__`
# publishes it and `tests/test_units.py` reaches it through that facade.
read_json = jsonio.read_json

# The repository root -- the same directory `screen_samples.PROJECT_ROOT` names, and the
# last-resort place `find_checkpoints` looks for the mine's checkpoints.

# Manifests carrying one row per group, keyed by `id`.
#
# `mine`'s own outputs -- `history_pairs.jsonl`, `history_features.jsonl`,
# `code_rows.jsonl`, `mine_summary.json` -- are corpus-wide and live once at `probe_v2/`,
# the location `mining.config` names. They are NOT copied into a screened corpus: a
# filtered second copy beside the full one is what made `probe_v2/history_pairs.jsonl`
# sit at a stale 2,246 rows while the real 23,333 lived somewhere else. Join them to a
# screened corpus on `scope_key` (history) or `id` (code rows) instead of duplicating.
#
# They stay listed so that a `--source` which DOES carry them is still filtered rather
# than silently exporting corpus-wide rows into a per-group directory; a name that is
# absent is skipped.
ID_KEYED_JSONL = ("groups.jsonl", "sources.jsonl", "map.jsonl",
                  "revisions.jsonl", "code_rows.jsonl")
# Manifests keyed by `scope_key` instead; `mine` writes them before ids are assigned.
SCOPE_KEYED_JSONL = ("history_pairs.jsonl", "history_features.jsonl")
# Whole-file JSON objects keyed by group id.
ID_KEYED_JSON = ("_markers.json",)
# Copied verbatim: run-level provenance that describes the mine, not any one group.
VERBATIM = ("mine_summary.json", "exclusions.json", "EXCLUSIONS.md")
# One transplanted revision of a scope -- a ROLE, and the runner's unit of measurement.
# Named once so that anything deciding whether a file is a role agrees with everything else.
REVISION_NAME = re.compile(r"^rev_\d+_[0-9a-f]+\.dart$")


def revisions_by_group(source: Path) -> dict[str, list[tuple[int, str, Path]]]:
    """Per group, every `rev_NNN_<sha8>.dart` sorted by ordinal."""
    out: dict[str, list[tuple[int, str, Path]]] = {}
    for d in sorted(source.glob("*/")):
        if not d.name.isdigit():
            continue
        lst = []
        for f in d.glob("rev_*.dart"):
            m = re.match(r"rev_(\d+)_([0-9a-f]+)\.dart$", f.name)
            if m:
                lst.append((int(m.group(1)), m.group(2), f))
        out[d.name] = sorted(lst)
    return out


def find_checkpoints(source: Path, explicit: Path | None) -> Path | None:
    """Where `mine` left its per-repository checkpoints.

    They are read rather than `history_pairs.jsonl` because that file is written only when
    the whole mine exits cleanly; until then the checkpoints are the durable record.
    """
    if explicit is not None:
        return explicit if explicit.is_dir() else None
    for candidate in (source / "checkpoints",
                      source.parent / "probe_v2" / "checkpoints",
                      PROJECT_ROOT / "probe_v2" / "checkpoints"):
        if candidate.is_dir():
            return candidate
    return None


def load_code_rows(checkpoints: Path | None) -> list[dict]:
    """Every transplanted file's row from the per-repository checkpoints.

    `code_rows.jsonl` is written only when the whole mine exits cleanly; until then the
    checkpoints are the durable record. A screen run against a corpus whose mine is still going therefore sees no
    manifest at all, and R10 fires on nothing -- silently, because a row carrying no
    verification is *supposed* to fire nothing (see `verification_rules`). That silence is
    right for a corpus mined under spm <= 0.5.1 and wrong for one whose verdicts simply
    have not been flushed yet, and these rows are what tells the two apart.

    Only `isolated` rows are returned. An `unchanged` row records that a commit left the
    transplant byte-identical and carries no file and no verdict of its own.
    """
    if checkpoints is None:
        return []
    rows = []
    for f in sorted(glob.glob(str(checkpoints / "*.json"))):
        for row in (read_json(f, {}) or {}).get("code_rows") or []:
            if row.get("status") == "isolated" and row.get("id") and row.get("file"):
                rows.append(row)
    return rows


def finished_repos(checkpoints: Path | None) -> set[str]:
    """Repositories whose `mine` has written a checkpoint, i.e. whose groups are complete.

    The checkpoint is written the moment a repository finishes, so this set is exactly the
    part of the corpus that is safe to screen while the mine is still running.
    """
    out: set[str] = set()
    for f in sorted(glob.glob(str(checkpoints / "*.json"))) if checkpoints else []:
        name = (read_json(f, {}) or {}).get("repo_name")
        if name:
            out.add(name)                 # a checkpoint being written right now is skipped
    return out


def group_index(source: Path, checkpoints: Path | None) -> tuple[dict[str, list[str]],
                                                                 dict[str, str]]:
    """(scope_key -> claimant group ids, group id -> project), from whichever record exists.

    `groups.jsonl` is written only when the whole mine exits cleanly, so mid-run it is
    absent and every pair would be `unmapped`. The same two facts are therefore read, in
    order of authority, from:

      1. `groups.jsonl`            -- the manifest, when the mine finished
      2. the per-repository checkpoints (`new_groups`) -- durable from the moment a
         repository finishes, which is what makes a mid-run screen possible at all
      3. `id_map.json`             -- identity `project::file::TYPE::scope::ordinal`, the
         scope_key plus the two fields the pair record drops. Written continuously, so it
         also covers groups of a repository still in flight -- which is how they get a
         project to be HELD by, rather than silently screened as if finished.
    """
    ids_by_key: dict[str, list[str]] = {}
    project_by_id: dict[str, str] = {}

    def add(project: str, rel: str, scope: str, gid: str) -> None:
        if gid in project_by_id:
            return                        # a higher-authority record already claimed it
        project_by_id[gid] = project
        claimants = ids_by_key.setdefault(f"{project}::{rel}::{scope}", [])
        if gid not in claimants:
            claimants.append(gid)

    gj = source / "groups.jsonl"
    if gj.is_file():
        for line in gj.read_text().splitlines():
            if line.strip():
                r = json.loads(line)
                add(r["project"], r["source_file_relative"], r["scope_name"], r["id"])

    for f in sorted(glob.glob(str(checkpoints / "*.json"))) if checkpoints else []:
        d = read_json(f, {}) or {}
        for g in d.get("new_groups") or []:
            if g.get("id"):
                add(g["project"], g["source_file_relative"], g["scope_name"], g["id"])

    im = source / "id_map.json"
    if im.is_file():
        for identity, gid in (read_json(im, {}) or {}).items():
            parts = identity.split("::")
            if len(parts) >= 5:
                add(parts[0], parts[1], parts[3], gid)

    return ids_by_key, project_by_id


def manifest_group_ids(source: Path) -> set[str] | None:
    """Ids `groups.jsonl` still claims, or None when the mine has not written it.

    Deliberately NOT `group_index`, which falls back to `id_map.json`. That map is
    cumulative and never forgets an id -- it still carries all 184 of `moss-apps/Flick`'s
    identities after a re-mine materialised 123 -- so every group a re-mine dropped would
    read as still claimed, and every re-mine as a prune. Only the manifest is rewritten
    per repository (`mining.isolate.run` keeps the rows of projects it did not process
    and replaces the rest), so only the manifest can say that a group has LEFT the corpus.

    `None`, not the empty set, when the file is absent: mid-mine there is no manifest, and
    "the corpus claims nothing" and "we cannot tell what the corpus claims" are the two
    answers a caller has to separate.
    """
    path = source / "groups.jsonl"
    if not path.is_file():
        return None
    ids = set()
    for line in path.read_text().splitlines():
        if line.strip():
            gid = json.loads(line).get("id")
            if gid:
                ids.add(gid)
    return ids


VERIFIED_MANIFESTS = (
    ("groups.jsonl", "base_dart"),
    ("code_rows.jsonl", "file"),
    ("revisions.jsonl", "file"),
)


def verification_rules(source: Path, checkpoints: Path | None = None, licences=None
                       ) -> tuple[dict[str, dict[str, list[str]]], dict[str, int]]:
    """R10/R11 per file -- `({group id: {file name: [rules]}}, coverage counts)`.

    [licences] is an optional `licenses.PackageLicenceJudge`, which decides R17 off the same
    rows. Passed in rather than read here so the manifests are walked once: R17 keys on
    `inlinedThirdPartyDeclarations`, which sits on the row beside the fields R10/R11/R12
    already read, and a second walk would parse ~16,000 lines to answer a question this one
    is already holding the answer to.

    These two rules are the only ones here that a file cannot answer for itself. Whether
    `spm isolate` could analyse a transplant without an error depends on the package
    resolution it was written under, which is gone by the time the screen runs; spm 0.5.2
    records the verdict on the mapping row instead, and `mining.isolate.verification`
    carries it into these manifests. Recomputing it here with a local `dart analyze` would
    answer a different question and disagree -- that is exactly the trap
    `mining.isolate.check_self_containment` documents.

    Why R10 is fatal rather than cosmetic: `spm analyze` SKIPS any file carrying an
    error-severity diagnostic, so an unclean transplant is not a slightly wrong row, it is
    no row. A pair needs both endpoints clean, which the per-file granularity here gives
    for free -- the rules join the AST rules and go through the same endpoint check.

    **A row with no verification fires nothing.** Any corpus mined under spm <= 0.5.1 has
    none, and defaulting absent to "unclean" would screen every one of them to zero while
    defaulting it to "clean" would wave through the broken output 0.5.2's changelog
    describes. Silence is the honest third answer; the export summary says how many files
    it covered so a corpus part-mined across the upgrade is visible rather than pooled.

    That silence has one failure mode the manifests cannot distinguish, and `checkpoints`
    is what fixes it. `mine` writes the manifests when it EXITS; a corpus whose mine is
    still running carries none, so every transplant in it reads as "no verdict" and R10
    passes the corpus whole -- including the transplants spm already rejected. The
    per-repository checkpoints carry the same `verified` / `errorCount` on every
    `code_rows` entry, from the moment each repository finishes, so they answer for the
    part of the corpus the manifests have not been written for yet.

    Manifests win where both speak. A checkpoint is a snapshot of one repository's run and
    the manifest is the whole mine's settled output; where they disagree the settled one is
    the later word. A file a manifest covered and found CLEAN is therefore not re-flagged
    from a checkpoint, which is why coverage is tracked per file rather than inferred from
    what fired.

    Keyed by `(id, file name)` rather than by the path the row carries: those paths are
    absolute and point wherever the mine wrote them, which is not where an exported corpus
    sits, and `--dest` rewriting them would make this depend on export order.
    """
    out: dict[str, dict[str, list[str]]] = collections.defaultdict(dict)
    # Every `(gid, file name)` a manifest spoke about, whether or not anything fired.
    # Without this a clean manifest row is indistinguishable from an absent one, and the
    # checkpoint merge below would re-flag files the mine has already settled as clean.
    covered: set[tuple[str, str]] = set()

    # Rows that carried an spm verdict at all, as opposed to rows a manifest merely
    # mentioned. `covered` is the second: `groups.jsonl` names every group's `base_dart`
    # whether or not spm ever recorded a verdict for it, so a corpus with no verdicts
    # anywhere still has full `covered`. Telling the two apart is what lets the caller refuse
    # a corpus on which R10 would fire vacuously.
    with_verdict: set[tuple[str, str]] = set()

    def judge(row: dict, where: str, key: tuple[str, str]) -> list[str]:
        if "verified" in row:
            with_verdict.add(key)
        fired = []
        # `verified: false` means spm could not analyse the file at all, which is at
        # least as disqualifying as analysing it and finding errors.
        if "verified" in row and (not row["verified"] or row.get("errorCount", 0)):
            fired.append(UNVERIFIED_RULE)
        if row.get("sourceDependenciesResolved") is False:
            fired.append(SOURCE_UNRESOLVED_RULE)
        # Both are OMITTED unless they apply, so a truthy test is the whole check and a
        # corpus mined before 0.6.0 fires neither -- the same silence R10/R11 rely on.
        if row.get("thirdPartyInlineReverted") or row.get("thirdPartyInlineTruncated"):
            fired.append(INLINE_REVERTED_RULE)
        # R17 asks a different question of the same row -- not whether the transplant is
        # measurable, but whether the study may redistribute what is in it -- so it is
        # decided here and kept out of `judge`'s own conditions.
        if licences is not None:
            fired.extend(licences.judge(row, key))
        return fired

    for name, path_key in VERIFIED_MANIFESTS:
        manifest = source / name
        if not manifest.is_file():
            continue
        for line in manifest.read_text(errors="ignore").splitlines():
            if not line.strip():
                continue
            try:
                row = json.loads(line)
            except json.JSONDecodeError:
                continue                  # a manifest a running mine is mid-write
            gid, where = row.get("id"), row.get(path_key)
            if not gid or not where:
                continue
            covered.add((gid, Path(where).name))
            fired = judge(row, where, (gid, Path(where).name))
            if fired:
                out[gid][Path(where).name] = fired

    from_checkpoints = 0
    for row in load_code_rows(checkpoints):
        gid, where = row["id"], Path(row["file"]).name
        if (gid, where) in covered:
            continue                      # the manifest already settled this file
        covered.add((gid, where))
        from_checkpoints += 1
        fired = judge(row, where, (gid, where))
        if fired:
            out[gid][where] = fired

    return dict(out), {
        "files_covered": len(covered),
        # The subset that carries an spm verdict. Zero means R10/R11 fire on nothing
        # because nothing was READ, which is not the same as nothing being wrong.
        "files_with_a_verdict": len(with_verdict),
        "files_from_checkpoints": from_checkpoints,
    }
# --------------------------------------------------------------------------------------
# Export
# --------------------------------------------------------------------------------------

# A transplanted file inside some corpus root, e.g. ".../samples_v2/0002/base.dart".
GROUP_FILE = re.compile(
    r"^(?P<root>.*)/(?P<gid>\d{4})/(?P<name>base\.dart|rev_\d+_[0-9a-f]+\.dart)$")


def retarget(obj, source: str, dest: str, ids: set[str]):
    """Rewrite the manifests' absolute paths so they describe the exported tree.

    Matched by SHAPE -- "<root>/<gid>/<base|rev_*>.dart" for a gid being exported -- rather
    than by a `--source` prefix. The prefix is not reliable: `new_samples/groups.jsonl`
    records `base_dart` under `probe_v2/samples_v2/`, because that copy was taken with
    `rsync` and the manifests still name the tree they were generated in. A prefix rule
    would silently leave those pointing at the frozen artifact, so the exported index would
    describe a directory other than the one it ships with. The `--source` prefix is still
    applied as a fallback for any other path that does live under it.

    `source_file_absolute` points into the repository clone and matches neither rule, so it
    is left alone -- which is what keeps a group traceable back to the commit it came from.
    """
    if isinstance(obj, str):
        m = GROUP_FILE.match(obj)
        if m and m["gid"] in ids:
            return f'{dest}/{m["gid"]}/{m["name"]}'
        return dest + obj[len(source):] if obj.startswith(source) else obj
    if isinstance(obj, list):
        return [retarget(v, source, dest, ids) for v in obj]
    if isinstance(obj, dict):
        return {k: retarget(v, source, dest, ids) for k, v in obj.items()}
    return obj
