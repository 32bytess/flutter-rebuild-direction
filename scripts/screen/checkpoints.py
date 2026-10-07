"""The screen's own per-repository resume records, and the mode they have to agree with.

A checkpoint means "this repository was screened AND placed". What makes replaying one sound
is that `mine` only checkpoints a repository when it FINISHES, so its transplants cannot
change any more -- and what makes it safe is `screen_mode`, the fingerprint every screening
decision folds into, so that a checkpoint written under a different rule set, value table or
layout is ignored rather than trusted.

`provenance` is the same idea pointed outward: the digests that invalidate a checkpoint are
exactly the ones a published record has to carry.
"""

from __future__ import annotations

import collections
import dataclasses
import datetime
import glob
import json
import sys
from pathlib import Path

from scripts import spm
from scripts.screen.backend import DartBackend, Screener
from scripts.screen.manifests import read_json
from scripts.screen.rules import (DUPLICATE_RULE, MANUAL_RULE, NO_PAIR_RULE,
                                  REPO_LICENSE_RULE, SOFT_RULES, UNFILLABLE_RULE,
                                  UNFINISHED_RULE)

# Per-repository resume records, the same convention every `mining` phase follows:
# written when a repository is done, matched by repository name, and only ever written for
# repositories `mine` itself has finished.
SCREEN_CHECKPOINT_DIR = "checkpoints_screen"


@dataclasses.dataclass(frozen=True)
class ScreenRun:
    """Everything one screening pass needs to know, decided once by `main()`.

    This used to be the argparse `Namespace`, passed whole from `screen_samples._one_pass`
    into `provenance` here -- so this module was coupled to the CLI's flag NAMES, and
    `getattr(args, "prune_to_endpoints", False)` existed to paper over the one flag that a
    `--full` phase set and a plain run did not. Worse, `_full` wrote `resume`, `rescreen` and
    `prune_to_endpoints` back onto the shared Namespace so that `provenance`, three frames
    away, could read what the current phase had decided: a mutable side-channel between call
    frames, on an object whose shape nothing declared.

    Frozen, so a phase cannot edit the record another phase is holding. `--full` derives its
    per-phase variants with `dataclasses.replace`, which is the same intent said out loud.
    `screen_mode` already took explicit values rather than the Namespace; this extends that
    convention to the rest of the seam.
    """

    # What is being screened, and where the records go.
    checkpoints: Path | None
    screen_checkpoints: Path | None
    binding_source: Path | None
    vectors: Path | None
    license_provenance: Path | None
    render_exclusions: Path | None
    license_candidates: Path | None
    fixture_store: Path | None
    exclude_groups: tuple[str, ...]

    # Verdict-changing flags. Every one of these is in `screen_mode`'s fingerprint.
    strict: bool
    keep_unpairable: bool
    keep_excluded_revisions: bool
    include_unfinished: bool
    allow_unequal_bindings: bool
    allow_shim_form_drift: bool
    allow_unverified: bool
    fix_images: bool
    prune_imports: bool

    # What the pass DOES, which changes the corpus without changing a verdict.
    resume: bool
    rescreen: bool
    prune_to_endpoints: bool
    dry_run: bool
    report_only: bool
    markdown: bool
    prune: bool
    force_prune: bool
    fixtures: bool

    @classmethod
    def from_args(cls, args) -> "ScreenRun":
        """Build one from the parsed CLI. The only place flag names are read.

        Paths are resolved here rather than at each use: `_one_pass` resolved
        `--license-provenance` twice, once for the mode and once for the screen, and two
        resolutions of one flag are two chances to disagree.
        """
        def maybe(path):
            return path.resolve() if path else None

        return cls(
            checkpoints=args.checkpoints,
            screen_checkpoints=args.screen_checkpoints,
            binding_source=maybe(args.binding_source),
            vectors=maybe(args.vectors),
            license_provenance=maybe(args.license_provenance),
            render_exclusions=maybe(args.render_exclusions),
            license_candidates=maybe(args.license_candidates),
            fixture_store=maybe(args.fixture_store),
            exclude_groups=tuple(args.exclude_groups or ()),
            strict=args.strict,
            keep_unpairable=args.keep_unpairable,
            keep_excluded_revisions=args.keep_excluded_revisions,
            include_unfinished=args.include_unfinished,
            allow_unequal_bindings=args.allow_unequal_bindings,
            allow_shim_form_drift=args.allow_shim_form_drift,
            allow_unverified=args.allow_unverified,
            fix_images=args.fix_images,
            prune_imports=args.prune_imports,
            resume=args.resume,
            rescreen=args.rescreen,
            prune_to_endpoints=getattr(args, "prune_to_endpoints", False),
            dry_run=args.dry_run,
            report_only=args.report_only,
            markdown=args.markdown,
            prune=args.prune,
            force_prune=args.force_prune,
            fixtures=args.fixtures,
        )
def screen_mode(strict: bool, keep_unpairable: bool, screen_revisions: bool,
                source: Path, dest: Path | None, fix_images_on: bool = True,
                backend=None, prune_imports: bool = True,
                license_provenance: Path | None = None,
                render_exclusions: Path | None = None) -> dict:
    """What a checkpoint has to agree with to be reusable.

    Rule-set and layout changes are not detectable from a repository name, and the runbook's
    standing instruction after a rule change is to delete the phase's checkpoints. Recording
    the mode makes the common cases -- a `--strict` run after a default one, a different
    `--dest` -- self-invalidating instead of silently resuming across the change.

    The rule digest comes from whichever backend is screening, so switching backends -- or
    editing a rule inside `scripts/dart_tools` -- invalidates every checkpoint, exactly as
    editing a regex used to.
    """
    # Imported here, not at module scope: `screen_samples` must stay offline and parse-only,
    # and `fixture_values` reaches git in its recovery pass. Only the digest is used, which
    # hashes two committed files and touches nothing else.
    from scripts.fixture_values import values_version
    from scripts.render_gate import version as render_version
    from scripts.screen.licenses import license_version

    return {"strict": strict, "keep_unpairable": keep_unpairable,
            "screen_revisions": screen_revisions, "source": str(source),
            "dest": str(dest) if dest else None,
            "rules": (backend or DartBackend()).fingerprint(),
            "backend": (backend or DartBackend()).name,
            # Fixture VALUES are as load-bearing as screening RULES: editing the policy table
            # changes what gets measured, so a checkpoint written under the old table must not
            # silently resume under the new one.
            "values": values_version(),
            # Licence POLICY and licence PROVENANCE, for the reason the fixture tables are
            # here: both decide what gets screened out. A checkpoint written before the
            # provenance pass ran recorded R17 firing `unattributed` on files that pass has
            # since named, and resuming across that would replay a verdict its own input no
            # longer supports.
            "licenses": license_version(provenance=license_provenance),
            # What the DEVICE drew, for the reason the two above are here: R21 excludes a
            # contrast and R22 annotates one, both off a table a measurement campaign
            # writes. A checkpoint taken before that campaign ran recorded both as inert,
            # and resuming across the table's arrival would replay verdicts whose input did
            # not exist yet. An absent table hashes as absent, so writing it the first time
            # moves this digest -- which is the invalidation.
            "render": render_version(render_exclusions),
            "fix_images": fix_images_on, "prune_imports": prune_imports}


def load_screen_checkpoints(directory: Path | None, mode: dict) -> tuple[dict, int]:
    """Per-group records from repositories this screen already finished, plus the count of
    checkpoints rejected because they were written in a different mode."""
    if directory is None or not directory.is_dir():
        return {}, 0
    records, stale = {}, 0
    for f in sorted(glob.glob(str(directory / "*.json"))):
        d = read_json(f)
        if not d:
            continue
        if d.get("mode") != mode:
            stale += 1
            continue
        for gid, rec in (d.get("groups") or {}).items():
            rec = dict(rec)
            rec["repo"] = d.get("repo")
            records[gid] = rec
    return records, stale


def write_screen_checkpoints(directory: Path, mode: dict, groups: dict,
                             project_by_id: dict, shipped: dict, dropped: dict,
                             repos: set[str], screener: Screener,
                             prior: dict | None = None) -> int:
    """One record per repository whose groups this run screened to completion.

    Only FINISHED repositories are written: a held repository's groups are still being
    added to, so a record of them would resume a screen of half a repository.
    """
    directory.mkdir(parents=True, exist_ok=True)
    # Per-file rules accumulate: what an earlier run recorded, plus whatever this run had
    # reason to read. Nothing is read here just to fill the record -- a group excluded on
    # its representative never needs the rest of its files classified, and paying for that
    # would undo the saving the checkpoint exists to make.
    read_this_run: dict[str, dict[str, list[str]]] = collections.defaultdict(dict)
    for key, entry in screener.fresh.items():
        gid, _, name = key.partition("/")
        if gid.isdigit() and name.endswith(".dart"):
            read_this_run[gid][name] = entry[2]

    prior = prior or {}
    by_repo: dict[str, dict] = collections.defaultdict(dict)
    for gid, g in groups.items():
        repo = project_by_id.get(gid)
        if repo in repos:
            files = dict((prior.get(gid) or {}).get("files") or {})
            files.update(read_this_run.get(gid, {}))
            by_repo[repo][gid] = {
                "files": files,
                # Only rules a FILE fired. The group-level ones -- duplicate, no-pair,
                # unfinished, the hand exclusion and R16 -- are decided fresh every run
                # against the corpus as it then is, so recording them would freeze a
                # judgement that `--exclude-groups` is meant to be able to take back. R16 is
                # here for a sharper reason: it is decided from a table a LATER phase writes,
                # so a checkpoint carrying it would replay phase 5's verdict into phase 1.
                # R18 joins them because it is read from the collector's record rather than
                # from the corpus, and that record can be corrected without any file here
                # changing -- a frozen verdict would outlive its own input.
                "rules": [r for r in g["base_rules"] if r not in
                          (DUPLICATE_RULE, NO_PAIR_RULE, UNFINISHED_RULE, MANUAL_RULE,
                           UNFILLABLE_RULE, REPO_LICENSE_RULE)],
                "norm_hash": g["norm_hash"],
                "representative": g["representative"],
                "shipped": sorted(shipped.get(gid, ())),
                "dropped": sorted(dropped.get(gid, ())),
            }
    for repo, recs in by_repo.items():
        (directory / f"{repo.replace('/', '_')}.json").write_text(json.dumps(
            {"repo": repo, "screened_at": datetime.datetime.now(datetime.timezone.utc)
                                                  .isoformat(),
             "mode": mode, "groups": recs}, indent=1) + "\n")
    return len(by_repo)
def provenance(mode: dict, run: ScreenRun, argv: list[str] | None = None) -> dict:
    """What produced this record, in the record.

    `screen_mode` already assembles every digest a resume has to agree with -- the Dart rule
    vocabulary, the committed fixture-value table, the backend, and each flag that changes a
    verdict -- and stamps them into the checkpoints and the file cache, where nothing reads
    them. `exclusions.json` is the artifact that leaves this machine: `maximal_branch`,
    `fixture_values` and the diversity notebook all read it, and the report appendix quotes
    the markdown generated beside it. Without the digests, two records produced under
    different rule generations are indistinguishable -- which is this project's four-
    generations-of-numbers problem one layer down, and the reason nothing else here is
    allowed to be unstamped.

    There is no script or CI entry for this tool: every documented invocation is prose in
    docs/mining-runbook.md. So the command line is recorded too, because otherwise the corpus arm
    2 measures has no machine-readable statement of how it was produced.
    """
    return {
        "screened_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "argv": list(argv if argv is not None else sys.argv[1:]),
        # The rule vocabulary lives in `scripts/dart_tools`; editing one moves this digest,
        # which is what invalidates every checkpoint written under the old one.
        "rules_digest": mode["rules"],
        "backend": mode["backend"],
        # WHICH BUILD of the extractor. A path dependency records no sha256 -- the lock says
        # `source: path` and a version, and follows whatever branch the checkout is on -- so
        # this is the only statement a record carries about the emitter that produced its
        # rows, and 0.7.0's and 0.7.1's must never be pooled. Deliberately NOT in
        # `screen_mode`: the screen reads no spm output, so this must not invalidate a
        # checkpoint. It changes what the corpus WAS BUILT BY, which a record has to say.
        "spm_build": spm.version(),
        # Fixture VALUES are as load-bearing as screening RULES: the table decides what the
        # roles mount from, and therefore what `spm analyze` can resolve.
        "values_digest": mode["values"],
        # Licence policy and licence provenance, digested together. A record that cannot say
        # which allowed set it screened under, or which provenance pass named its packages,
        # cannot answer whether R17's silence was a verdict or a gap.
        "licenses_digest": mode["licenses"],
        "flags": {
            "strict": mode["strict"],
            "promoted_by_strict": sorted(SOFT_RULES) if mode["strict"] else [],
            "keep_unpairable": mode["keep_unpairable"],
            "screen_revisions": mode["screen_revisions"],
            # NOT in `screen_mode`: it changes no verdict, so it must not invalidate a
            # checkpoint. It does change what the corpus HOLDS, so a record that cannot
            # say whether its corpus was pruned is not reproducible.
            "prune_to_endpoints": run.prune_to_endpoints,
            "normalise": mode["fix_images"],
            "prune_unused_imports": mode["prune_imports"],
            "contrasts": "all_pairwise",
            "binding_rule": not run.allow_unequal_bindings,
            "shim_form_rule": not run.allow_shim_form_drift,
            "allow_unverified": run.allow_unverified,
            "include_unfinished": run.include_unfinished,
            # Both name a tree OTHER than --source, and each silently changes what is
            # screened, so a record that does not name them cannot be reproduced.
            "vectors": str(run.vectors) if run.vectors else None,
            "binding_source": str(run.binding_source) if run.binding_source else None,
            "fixture_store": str(run.fixture_store) if run.fixture_store else None,
        },
    }
