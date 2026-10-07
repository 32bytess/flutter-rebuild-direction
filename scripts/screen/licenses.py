"""R17/R18: whose code is in a transplant, and whether the study may redistribute it.

WHY THIS EXISTS
---------------
`spm isolate` does not only transplant the repository's own code. When a rebuild scope
reaches a widget-producing symbol from a pub.dev package, the crawl carries that package's
SOURCE into the file, recursively, and the export then strips the `package:` imports. A
shipped `rev_*.dart` can therefore contain third-party code with no import, no comment and
no attribution -- and until this module existed, nothing anywhere recorded whose it was.

Licence eligibility was checked ONCE, at repository acquisition
(`scripts/collector/config.py` ALLOWED_LICENSES), and then dropped: no SPDX id reached the
mine, the screen, the export or `provenance/`. Two different gaps follow, and there is one
rule for each:

R17 packages   the licence of the PACKAGE code inlined into a transplant. Never checked
               anywhere, by anything, before this.
R18 repository the licence of the repository the scope came from. Checked at acquisition,
               but the verdict was never written down anywhere the corpus could see, so
               nothing downstream could re-derive it.

WHAT DECIDES R17
----------------
Package identity comes from `spm isolate` itself -- `inlinedThirdPartyPackages` on the
mapping row, name to version, written in the same statement as the declaration count so the
two cannot drift. The mine that built this corpus predates that field, so a separate
provenance-only re-isolation pass repopulates it into `config/license_provenance.jsonl`
under a BYTE-IDENTITY gate: the re-isolated transplant must equal the one the corpus screens,
or the row's package list describes a different file and is refused. See
`scripts/mining/license_provenance.py`.

Four outcomes per file, and the third and fourth are reported APART because they mean
different things:

  pass          the row carries no `inlinedThirdPartyDeclarations`, or the inlining was
                reverted -- `spm` re-extracted with the package stood in for and kept that
                version, so no package source remains in the file
  pass          every package named is under an allowed licence
  DISALLOWED    a package is under a licence the policy does not allow, or one whose text
                matches no id the policy can recognise
  UNATTRIBUTED  the file carries package source that this run cannot name: no provenance
                row, a provenance row whose bytes did not match, a truncated closure (whose
                map may under-report by construction), or a version missing from the pub
                cache

UNATTRIBUTED FIRES. That is the whole design. The alternative -- passing a file whose
contents cannot be attributed -- would make the rule's silence mean two different things,
which is the failure `verification_rules` documents at length for R10. A count without a
name is not evidence of an allowed licence; it is evidence that nobody looked.

WHY THE POLICY IS FAIL-CLOSED
-----------------------------
A LICENSE matching no id, or more than one, is UNRECOGNISED and therefore not allowed. The
three permissive texts quote each other in places, so every marker for an id must appear
before that id is awarded. Measured against the 6,460 package versions in the pub cache
this recognises 5,831 and refuses 625, and the refusals are real notice-style variants
(Apache's short header, a BSD-3 body with no "Neither the name of" clause) rather than
copyleft. Refusing them costs nothing here and would cost one exclusion if it ever bit,
which is the right way round: a false exclusion loses a group, a false retention ships code
the study has no licence to ship.
"""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

from ..paths import PROJECT_ROOT as ROOT
from .rules import PACKAGE_LICENSE_RULE

POLICY_PATH = ROOT / "config" / "license_policy.json"
PROVENANCE_PATH = ROOT / "config" / "license_provenance.jsonl"
CANDIDATES_PATH = ROOT / "data" / "candidates.jsonl"
PUB_CACHE = Path.home() / ".pub-cache"
# Where a dependency's source actually sits, in the order `spm` would have read it. The two
# layouts are the same shape -- `<name>-<ref>` -- which is why a git dependency's commit sha
# arrives in the version field looking like a version: `<name>-8b3e8f20...` parses exactly as
# `<name>-2.2.4` does. Both are searched so the LICENSE is found where it is rather than the
# row being refused for a reason that names the wrong cache.
CACHE_ROOTS = ("hosted/pub.dev", "git")


def load_policy(path: Path | None = None) -> dict:
    return json.loads((path or POLICY_PATH).read_text(encoding="utf-8"))


def license_version(policy: Path | None = None, provenance: Path | None = None) -> str:
    """Digest over the policy and the provenance table, for the checkpoint fingerprint.

    Both, not just the policy. Editing the policy changes which packages are allowed;
    re-running the provenance pass changes which packages a file is KNOWN to carry, and a
    checkpoint written before that pass ran recorded R17 firing `unattributed` on files the
    pass has since named. Resuming across either would replay a verdict its own input no
    longer supports.

    A missing file RAISES rather than hashing `b""`, for the reason `values_version` gives:
    hashing empty bytes answers with a plausible digest that silently invalidates every
    checkpoint, which is the exact failure mode of moving one of these files. The provenance
    table is the one that will legitimately be absent on a first run, and the message says
    which command writes it.
    """
    h = hashlib.sha256()
    for p, how in ((policy or POLICY_PATH, "committed policy table"),
                   (provenance or PROVENANCE_PATH, "provenance table")):
        if not p.is_file():
            raise FileNotFoundError(
                f"licence {how} missing: {p}. "
                + ("Restore it from git -- it is committed, and the digest over it is what "
                   "invalidates stale screening checkpoints."
                   if how.startswith("committed") else
                   "It is COMMITTED, like the fixture tables beside it, because it is the "
                   "evidence R17 rests on rather than scratch: restore it from git, or "
                   "write it with `python3 -m scripts.mining license-provenance --repos "
                   "<the eligible repositories>`. Never create it by hand -- the "
                   "byte-identity gate each row records is the whole of its value."))
        h.update(p.read_bytes())
    return h.hexdigest()[:16]


# --------------------------------------------------------------------------------------
# SPDX resolution, from the pub cache
# --------------------------------------------------------------------------------------

def _marker_match(text: str, sid: str, spec: dict) -> bool:
    """Whether [text] satisfies one id's marker spec.

    `match` is stated in the policy rather than implied by the data's shape, which is what it
    was until 2026-09-05. `all` is the only operator implemented, and an unknown one RAISES:
    a silent default here would wave through a licence nobody read, which is the single
    failure this table exists to prevent.
    """
    how = spec.get("match")
    if how != "all":
        raise ValueError(
            f"config/license_policy.json: spdx_markers[{sid!r}] asks for match={how!r}; "
            "`all` is the only operator implemented")
    return all(n in text for n in spec.get("phrases") or ())


def spdx_of_text(text: str, markers: dict[str, dict]) -> str | None:
    """The one id whose marker spec [text] satisfies, or None.

    None for no match AND for an ambiguous match, deliberately conflated: both mean the
    text was not recognised, and neither is a licence anyone here may act on.
    """
    hits = [sid for sid, spec in markers.items() if _marker_match(text, sid, spec)]
    return hits[0] if len(hits) == 1 else None


def package_spdx(name: str, version: str, policy: dict,
                 cache: Path | None = None) -> tuple[str | None, str, str]:
    """`(spdx id or None, why, kind)` for one hosted package version.

    Read from the package's own LICENSE in the pub cache rather than from pub.dev's
    metadata: the file is what was actually vendored into the transplant, and it is on disk
    beside the source the isolation pass read.

    `kind` separates the two ways this can fail, because R17 owes them different verdicts:

      recognised    the text matched exactly one id the policy knows
      unrecognised  the text was READ and matched no id, or more than one. That is a
                    verdict about the package -- somebody looked and could not place its
                    licence -- so the file is DISALLOWED, not unattributed. Folding it into
                    "unattributed" would suggest re-running the provenance pass fixes it,
                    and nothing about a second isolation would make a licence recognisable.
      unreadable    the version is in neither cache, or ships no LICENSE at all. Nothing was
                    read, so nothing is known, and that IS a provenance gap.
    """
    base = cache or PUB_CACHE
    roots = [base / where / f"{name}-{version}" for where in CACHE_ROOTS]
    # A caller that hands over a flat directory of packages -- the tests do -- gets it
    # searched too, so a stand-in cache does not have to reproduce the real layout.
    roots.append(base / f"{name}-{version}")
    for root in roots:
        if not root.is_dir():
            continue
        for candidate in ("LICENSE", "LICENSE.md", "LICENSE.txt", "LICENCE"):
            path = root / candidate
            if path.is_file():
                sid = spdx_of_text(path.read_text(errors="ignore"),
                                   policy.get("spdx_markers") or {})
                if sid is None:
                    return (None, f"{name}-{version}: {candidate} matches no licence the "
                                  f"policy can recognise", "unrecognised")
                return sid, f"{name}-{version}: {sid}", "recognised"
        return None, f"{name}-{version} ships no LICENSE file", "unreadable"
    return None, f"{name}-{version} is in neither the hosted nor the git pub cache", "unreadable"


# --------------------------------------------------------------------------------------
# R17 -- package licences, per file
# --------------------------------------------------------------------------------------

def load_provenance(path: Path | None = None) -> dict[tuple[str, str], dict]:
    """`{(group id, file name): row}` from the provenance pass.

    Keyed by `(id, file name)` and not by the path the row carries, for the same reason
    `verification_rules` is: those paths are absolute and point wherever the pass wrote
    them, which is not where an exported corpus sits.
    """
    src = path or PROVENANCE_PATH
    if not src.is_file():
        return {}
    out: dict[tuple[str, str], dict] = {}
    for line in src.read_text(errors="ignore").splitlines():
        if not line.strip():
            continue
        try:
            row = json.loads(line)
        except json.JSONDecodeError:
            continue
        gid, name = row.get("id"), row.get("file")
        if gid and name:
            out[(gid, Path(name).name)] = row
    return out


class PackageLicenceJudge:
    """Decides R17 for one manifest row, and remembers why for the report.

    Stateful on purpose: the two things the caller needs afterwards -- how many rows carried
    an inlining count at all (the vacuity guard) and which files fired for which of the two
    reasons (the report) -- are both by-products of judging, and recomputing either would
    mean walking the manifests a second time.
    """

    def __init__(self, policy: dict, provenance: dict[tuple[str, str], dict],
                 cache: Path | None = None):
        self._policy = policy
        self._allowed = set(policy.get("allowed_spdx") or ())
        self._provenance = provenance
        self._cache = cache
        self._spdx: dict[tuple[str, str], tuple[str | None, str, str]] = {}
        # `{(gid, name): {"kind": "disallowed"|"unattributed", "why": str,
        #                 "packages": {name: version}}}`
        self.details: dict[tuple[str, str], dict] = {}
        # Files that still HOLD package source. Reported as `files_with_inlined_packages`.
        self.rows_with_a_count = 0
        # Files whose row SAYS SOMETHING about inlining, in any of the three ways a build
        # that reports it can. Only the vacuity guard reads this, and the distinction is the
        # whole of that guard: a corpus can carry no package source and still prove its
        # extractor would have said so. See `assert_not_vacuous`.
        self.rows_reporting_inlining = 0

    def _spdx_of(self, name: str, version: str) -> tuple[str | None, str, str]:
        key = (name, version)
        if key not in self._spdx:
            self._spdx[key] = package_spdx(name, version, self._policy, self._cache)
        return self._spdx[key]

    def judge(self, row: dict, key: tuple[str, str]) -> list[str]:
        count = row.get("inlinedThirdPartyDeclarations")
        # Counted BEFORE the early return, because a reverted or truncated row proves the
        # build reports inlining exactly as well as a count does -- and unlike a count, it
        # survives spm deciding the inlining was not worth keeping. All three fields are
        # omitted unless they apply and none is emitted below 0.6.0, so their joint absence
        # is the silence the vacuity guard is actually looking for.
        if (count or row.get("thirdPartyInlineReverted")
                or row.get("thirdPartyInlineTruncated")):
            self.rows_reporting_inlining += 1
        if not count:
            # Absent, or zero. Includes every reverted row: `spm` removes the count when it
            # keeps the stood-in version, so the file provably holds no package source.
            return []
        self.rows_with_a_count += 1
        if row.get("thirdPartyInlineReverted"):
            # Belt and braces -- spm removes the count on revert, so this cannot normally
            # be reached. Kept because the two fields disagreeing is a corrupt row, and
            # reading the revert as authoritative is the answer that ships less code.
            return []

        def unattributed(why: str, packages: dict | None = None) -> list[str]:
            self.details[key] = {"kind": "unattributed", "why": why,
                                 "packages": packages or {}}
            return [PACKAGE_LICENSE_RULE]

        if row.get("thirdPartyInlineTruncated"):
            # The budget ran out mid-crawl. Declarations admitted after that point are
            # appended without a successful `take`, and the package map is written inside
            # `take`, so the map may under-report for exactly this row. An under-reporting
            # map read as complete is the one way this rule could wave code through.
            return unattributed("the inline budget was exhausted, so the recorded package "
                                "list may be short of what the file carries")

        record = self._provenance.get(key)
        if record is None:
            return unattributed("no row in config/license_provenance.jsonl for this file")
        if not record.get("bytes_identical"):
            return unattributed("the provenance pass re-isolated a DIFFERENT file, so its "
                                "package list does not describe the transplant screened here")
        packages = dict(record.get("inlinedThirdPartyPackages") or {})
        if not packages:
            return unattributed("the file carries package source from a path or git "
                                "dependency, whose directory carries no version to read",
                                packages)

        bad = []
        for name, version in sorted(packages.items()):
            sid, why, kind = self._spdx_of(name, version)
            if kind == "unreadable":
                # Nothing was read, so nothing is known. A gap, not a verdict.
                return unattributed(why, packages)
            if sid is None or sid not in self._allowed:
                bad.append(why)
        if bad:
            self.details[key] = {"kind": "disallowed", "why": "; ".join(bad),
                                 "packages": packages}
            return [PACKAGE_LICENSE_RULE]
        return []

    def by_kind(self, kind: str) -> dict[str, dict]:
        """The files that fired for one reason, as `{"gid/name": detail}`."""
        return {f"{gid}/{name}": d for (gid, name), d in sorted(self.details.items())
                if d["kind"] == kind}


def assert_not_vacuous(judge: PackageLicenceJudge, groups: int, source,
                       allow_unverified: bool = False) -> None:
    """Refuse a corpus on which R17 could only ever pass.

    The same abort R10 makes, for the same reason -- and behind the same flag, because it is
    the same statement about the same corpus. A row that says NOTHING about inlining is
    indistinguishable from a row a build too old to report it wrote --
    `mining.isolate.VERIFICATION_KEYS` says so in those words -- so if NOT ONE row in the
    pool reports inlining at all, R17's silence means the fields were never emitted, not that
    no package source was carried. Passing the corpus whole on that silence is precisely the
    failure the rule exists to prevent.

    WHAT COUNTS AS A REPORT, and why it is not just the count. This tested
    `rows_with_a_count` until 2026-09-06, and aborted a corpus mined under spm 0.7.1 -- the
    release that ADDED `inlinedThirdPartyPackages` -- whose 173 transplants carried 91
    `thirdPartyInlineReverted` rows and no counts. spm emits the count only when it is
    positive and DELETES it on revert, keeping the stood-in version and saying so in that
    field instead, so a corpus whose every inlining was reverted reports vigorously and
    counts nothing. `thirdPartyInlineReverted` and `thirdPartyInlineTruncated` are therefore
    evidence of the same fact the count is evidence of, and `judge` counts all three.

    The guard is not weakened by this: a corpus mined under spm < 0.6.0 carries none of the
    three and still aborts. What it no longer does is assert a CAUSE it cannot observe -- the
    old message named the extractor build, which was wrong in the one case that ever fired.

    It also fires per REPOSITORY now, not once per corpus: `mining pipeline` screens after
    each repository, and a single dependency-light repository legitimately reports nothing.

    `--allow-unverified` waives it rather than a flag of its own: a corpus with no spm
    verdicts anywhere has no inlining reports either, the two silences have one cause, and
    two flags for one fact would let a run disclaim R10 while implying R17 was applied.
    """
    if groups and not judge.rows_reporting_inlining and not allow_unverified:
        raise SystemExit(
            f"{PACKAGE_LICENSE_RULE} has no input: not one file under {source} reports "
            f"third-party inlining in any form -- no `inlinedThirdPartyDeclarations` count, "
            f"no `thirdPartyInlineReverted`, no `thirdPartyInlineTruncated` -- so R17 fires "
            f"on nothing, and nothing here distinguishes a corpus that carried no package "
            f"source from one whose extractor never looked. A corpus mined under spm < 0.6.0 "
            f"reports none of the three: re-mine it under 0.6.0+, or pass --allow-unverified "
            f"and say so in the record.")


# --------------------------------------------------------------------------------------
# R18 -- repository licences, per group
# --------------------------------------------------------------------------------------

def repo_licences(path: Path | None = None) -> dict[str, str]:
    """`{owner/name: spdx id, lowercased}` as the collector recorded it.

    `data/candidates.jsonl` is the collector's own append-only output and the only place a
    repository's licence was ever written down. It stores GitHub's `license.spdx_id`
    lowercased; the policy's `repo_spdx_aliases` maps that vocabulary onto canonical SPDX
    rather than the policy being lowercased, because the policy is what a human reads.
    """
    src = path or CANDIDATES_PATH
    if not src.is_file():
        return {}
    out: dict[str, str] = {}
    for line in src.read_text(errors="ignore").splitlines():
        if not line.strip():
            continue
        try:
            row = json.loads(line)
        except json.JSONDecodeError:
            continue
        name = row.get("repo_name")
        if name:
            out[name] = (row.get("license") or "").lower()
    return out


def repo_license_rules(project_by_id: dict[str, str], policy: dict,
                       candidates: Path | None = None) -> dict[str, dict]:
    """Groups R18 excludes, as `{gid: {"project", "recorded", "spdx", "reason"}}`.

    Group-level and decided fresh every run, beside R16. Unlike R16 it reads a table nobody
    here writes: the collector's, produced before the mine and never touched since. That is
    the point -- the licence verdict already existed and was simply unreachable from the
    corpus, so this rule re-derives nothing and only carries it forward.
    """
    recorded = repo_licences(candidates)
    aliases = policy.get("repo_spdx_aliases") or {}
    allowed = set(policy.get("allowed_spdx") or ())
    out: dict[str, dict] = {}
    for gid, project in sorted(project_by_id.items()):
        raw = recorded.get(project)
        if raw is None:
            out[gid] = {"project": project, "recorded": None, "spdx": None,
                        "reason": f"{project} has no row in data/candidates.jsonl, so no "
                                  f"licence was ever recorded for it"}
            continue
        sid = aliases.get(raw)
        if sid is None:
            out[gid] = {"project": project, "recorded": raw, "spdx": None,
                        "reason": f"{project}: the collector recorded `{raw or 'none'}`, "
                                  f"which the policy does not map to an SPDX id"}
            continue
        if sid not in allowed:
            out[gid] = {"project": project, "recorded": raw, "spdx": sid,
                        "reason": f"{project}: {sid} is not in the policy's allowed set"}
    return out
