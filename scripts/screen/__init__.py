"""The exclusion screen, as modules.

`scripts/screen_samples.py` was one 2,700-line file, of which three functions -- `screen`,
`export` and `main` -- were nearly half. It is still the entry point and still the place the
criteria are documented; what moved here is everything those three call.

    rules        the rule ids, their prose, and the hard/soft partition `--strict` moves
    backend      the Dart subprocess boundary and the per-file verdict cache
    manifests    reading what `mine` wrote, and rewriting it for an exported tree
    checkpoints  the screen's own resume records, the mode they must agree with, provenance
    contrasts    forming the pair set, adjacent or all-pairwise
    export       placing the eligible groups and the manifests filtered to them
    report       stdout, exclusions.json, EXCLUSIONS.md

Nothing about what the screen DECIDES changed in the split; `scripts/tests/` is what says so.
"""
