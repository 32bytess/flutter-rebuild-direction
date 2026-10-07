"""R13: the two endpoints of a contrast must mount from the same fixture bindings.

Pair-level and HARD, and unlike every other rule it says nothing about whether either
transplant is measurable on its own -- only that the two cannot be compared to each other.

It is a class rather than five closures because all five share one cache. The splits are
expensive (a `dart` batch per call if primed badly) and the whole design of this pass is to
defer priming until the pairs that survived every OTHER rule are known: ~340 files on the
round-4 corpus, against the ~16k a corpus-wide prime would read.
"""

from __future__ import annotations

from pathlib import Path

from scripts.screen.rules import BINDING_RULE, BINDING_SECTIONS


class Bindings:
    """The binding set of each role, and the delta between the two ends of a pair.

    The binding set comes from the Dart fixture pass, not from a regex over the generated
    `initState`: `lib/src/fixture.dart` already names what it hoists and which section it
    belongs to, matching has lived in `dart_tools` since 2026-08-20, and a text scan would
    miss a binding whose declaration spans lines.

    `source` is where the bindings are READ from, which is not always the tree being
    screened. R13 is defined on the `lifted` and `seed` sections of the `spm isolate` split
    -- the scope's relocated initial state -- and an EXPORTED corpus has already had exactly
    those moved out into the group's shared `dependencies.dart`. Re-splitting a shipped role
    therefore finds nothing to hoist and every pair compares empty-to-empty, reports as
    `identical`, and passes the whole corpus.

    That is not hypothetical: on `new_samples` all 318 surviving contrasts came back
    `identical`, while the same pairs read from `probe_v2/samples_v2` differ --
    `0776/rev_003` hoists {fixtureSelectedType} and `rev_004` hoists that plus {fixtureRef},
    which is precisely the added-`State`-field case R13 exists to exclude. So the read is
    routed to `--binding-source` when the screened tree is not the one that still carries the
    bindings, and `apply`'s vacuity guard makes the mistake impossible to make silently.
    """

    def __init__(self, backend, *, source: Path | None = None):
        self.backend = backend
        self.source = source
        self.rows: dict[Path, dict] = {}

    def prime(self, paths: list[Path]) -> None:
        fresh = sorted({p for p in paths if p not in self.rows})
        if fresh:
            self.rows.update(self.backend.splits(fresh))

    def path(self, path: Path) -> Path:
        """Where to read `path`'s bindings from, given `--binding-source`."""
        if self.source is None:
            return path
        candidate = self.source / path.parent.name / path.name
        return candidate if candidate.is_file() else path

    def _row(self, path: Path) -> dict:
        if path not in self.rows:
            self.prime([path])
        return self.rows[path]

    def of(self, path: Path) -> frozenset[str]:
        # `Hoisted.name` joins a multi-name declaration with commas -- `int a, b;` is one
        # hoisted record naming two bindings, and the pair differs if either moved.
        return frozenset(n for h in self._row(path)["hoisted"]
                         if h["section"] in BINDING_SECTIONS
                         for n in h["name"].split(","))

    def reaches_build(self, path: Path, names: list[str]) -> set[str]:
        """Diagnostic only, never a verdict: which of `names` this role's `build` reads.

        Separates the two kinds of difference R13 removes, which mean opposite things. A
        binding `build` reads is part of the edit -- the widget it feeds is already in the
        pair's delta vector, and excluding it discards a human edit. One `build` never reads
        is assigned once at mount, outside the `setState` that `buildSpan` times, so it
        cannot reach the dependent variable at all. On the round-4 corpus that split the 27
        excluded pairs 16 / 11.

        Read from the split rather than recomputed here. `dart_tools`' `_Reach` answers it on
        the AST the split was already computed against: `Region.rebuild` names, propagated
        through the helper methods `build` delegates to, plus the generated mount assignment
        that maps a fixture name onto the field `build` actually mentions -- because the
        binding R13 compares on is NOT the name `build` reads.

        Three regexes used to do this, and they were wrong on 74 of the 535 bindings R13
        runs on -- 72 of them inert -> reaching. `build` to end of file only covers the
        helpers `build` calls when those are declared BELOW it, and Dart style puts `build`
        last. Correcting it moved the split this function feeds from 16 / 11 to 24 / 3 on the
        adjacent set and from 71 / 33 to 84 / 20 all-pairwise: R13 discards substantially
        more real contrasts than the record said. No verdict moved. See `_Reach`.
        """
        if not names:
            return set()
        return set(names) & {n for h in self._row(path)["hoisted"]
                             for n in h.get("reaching", ())}

    def delta(self, before_path: Path, after_path: Path) -> dict:
        before, after = self.of(before_path), self.of(after_path)
        added, removed = sorted(after - before), sorted(before - after)
        relation = ("identical" if not added and not removed else
                    "added" if not removed else "removed" if not added else "both")
        return {"relation": relation, "added": added, "removed": removed,
                "reaches_build": sorted(self.reaches_build(after_path, added)
                                        | self.reaches_build(before_path, removed))}

    def apply(self, pair_rows: list[dict], *, enforce: bool = True) -> None:
        """Record `binding_delta` on every surviving pair, and exclude the ones that differ.

        A second pass rather than a test inside the per-pair verdict, so every endpoint that
        survived the other rules is primed in ONE batch: running it per pair would be a
        `dart` start-up per file, and the start-up is what that pass costs.

        The delta is recorded whether or not `enforce` is set, because the rule's whole
        justification is its rate -- `--allow-unequal-bindings` is how that rate gets measured
        against the same corpus snapshot rather than against an older screen.
        """
        survivors = [r for r in pair_rows
                     if r["verdict"] == "eligible" and r["_endpoints"]]
        endpoints = {r["pair_id"]: tuple(self.path(q) for q in r["_endpoints"])
                     for r in survivors}
        self.prime([q for pair in endpoints.values() for q in pair])

        empty = 0
        for r in survivors:
            b, a = endpoints[r["pair_id"]]
            if not self.of(b) and not self.of(a):
                empty += 1
            r["binding_delta"] = delta = self.delta(b, a)
            if enforce and delta["relation"] != "identical":
                r["verdict"], r["rules"] = "excluded", [BINDING_RULE]

        # A rule that silently passes everything is worse than no rule, so the vacuous case
        # is refused rather than reported.
        if enforce and survivors and empty == len(survivors):
            raise SystemExit(
                f"{BINDING_RULE} has no input: all {len(survivors)} surviving contrasts "
                f"hoist NO lifted or seed binding at either endpoint, so every one of them "
                f"compares empty to empty and passes vacuously. That is what an already-"
                f"exported corpus looks like -- its bindings are in each group's "
                f"dependencies.dart. Point --binding-source at the tree the roles were "
                f"exported FROM (probe_v2/samples_v2), or pass --allow-unequal-bindings to "
                f"screen without R13 and say so in the record.")
