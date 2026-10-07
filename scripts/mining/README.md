# mining

This package builds the arm-2 corpus: pairs of real revisions of the same Flutter widget, taken from repositories that arm 1
never used.

## Why

The main objection to arm 1 is that its variants were produced by eight fixed directives. A model that only knows which
directive was applied already does about as well as the feature model, so the features may mostly be recognising the edit.
Developer-written changes have no directive to recognise.

An earlier probe tried this on the eight repositories arm 1 was built from. It failed twice. The yield was too low (139
pairs, only 11 with a nonzero delta, against a gate of 25), and pairs from the same repositories say nothing new. This package
mines the repositories harvested on 2026-08-17 instead. Four of the 105 are arm-1 repositories and are excluded by name in
`config.CORPUS_REPOS`, which leaves 101 unseen ones.

## Why commits are chosen by closure

The 14 metrics of a scope do not depend only on the file that declares it. `tree_extractor.dart` follows helpers into any
library and walks the custom child widgets, adding each one's `build()` to the totals, then its helpers, then its own
children. Editing a `MyCard` two files away changes `treeNonConstWidgetCount`, `helperWidgetCount` and the depth metrics
while the scope's own file stays the same.

Choosing commits by "touched the declaring file" would therefore miss real edits, and miss them unevenly, mostly in
well-factored code where the child trees are deepest. On the pilot, 21.4% of candidate commits could only be found through
the closure. For this study, `spm analyze` was extended to emit `dependencyFiles`, `unresolvedDependencies` and
`closureResolved`.

## Why all of `lib/` must analyse cleanly

If a file in the closure does not resolve, the row is wrong, not missing. If it cannot be found, `_aggregateChildMetrics`
skips that child and its whole subtree disappears. If it resolves with errors, types come back null and its widgets are
counted as value objects. Neither shows up in spm's scanned and skipped counts, because those only cover the file being
scanned. `test/features/analysis/closure_reporting_test.dart` in `spm-publish` shows a local error in a closure file leaving
the declaring file clean and its row emitted, with the widget count and the depth each one short.

For pairs this is worse than losing data. If commit A resolves and commit B does not, the difference between them comes
from the resolution state and not from a human edit. A revision whose row is not `closureResolved` is recorded and never
paired. Targeting only the closure would be circular, because the closure is found by analysing, and it moves as history
moves. A single rule for the whole of `lib/` can be checked before any scope is known.

## Phases

```bash
cd flutter-rebuild-direction
python -m scripts.mining <phase> [--repos owner/name ...]
```

- `clone`: a `--filter=blob:none` clone, so full history with blobs fetched on demand.
- `prepare`: gets `lib/` to zero error-level diagnostics, within 3 rounds.
- `discover`: finds the scopes and the commits that could have changed them, over the closure.
- `mine`: walks those commits, pairs consecutive revisions and writes the 12-feature differences.
- `isolate`: transplants each scope into a self-contained `base.dart`, laid out like `samples/`.
- `pilot-repos`: prints the selection and exits without changing anything.
- `backfill-checkpoints`: rebuilds checkpoints from the phase summaries already on disk.

`--repos owner/name ...` acts on the named repositories and `--all` on every eligible one (the 105 harvested minus the 4 arm-1
repositories). `--all` is expanded to an explicit list, so the selection appears in the logs. With neither, a phase runs on the
five-repository pilot in `config.PILOT_REPOS`.

### Resuming

`prepare`, `discover`, `isolate` and `mine` write a checkpoint per repository under `probe_v2/checkpoints_<phase>/` as soon
as that repository is done, and `--resume` skips repositories that have one. `--retry-failed` also reruns those whose
checkpoint records a failure. It is opt-in because only you know whether the failure was temporary (a `pub get` network
error) or final (`broken_source`).

A checkpoint says the phase finished, not that it finished with the same arguments. I considered matching on arguments and
decided against it: it would invalidate a checkpoint after any cosmetic flag change, and people would learn to delete the
directory instead of trusting it. If you change the extractor build or a phase's own limits, delete that phase's checkpoint
directory rather than resuming across the change.

Checkpoints also fixed a bug where every phase rewrote its whole output file. A run limited with `--repos` used to rewrite
`prepare_report.json`, `targets.jsonl` or the three history files from that subset alone and drop every other repository. The
repositories a run does not touch are now read back from their own checkpoints and listed under `carried_from_checkpoint`, and
rows are sorted by repository, so the output does not depend on thread timing or on which repositories were resumed.
`backfill-checkpoints` builds checkpoints for work done before they existed. It never overwrites one.

### Parallelism

`prepare`, `discover` and `mine` take `--jobs N`. The work is mostly `git`, `pub` and `dart` subprocesses, so it scales well,
with two limits. Concurrent `pub get` fights over the shared pub cache, so keep `prepare --jobs` low (the full run used 4).
`mine` walks each repository one commit after another in a single worktree, so one repository with a long history sets the
minimum run time however many jobs there are.

`discover --only-clean` limits the run to repositories `prepare` marked clean. Scanning an unresolved repository finds only
some of its scopes and reports a closure that is short by an unknown amount, so this should normally be on.

## What `prepare` fixes and what it drops

It fixes, and retries, a version conflict where pub prints the fix; the kind that prints no fix but names the required
version (`intl 0.20.2 is required`); missing `build_runner` output; and missing `intl_utils` or `gen-l10n` output, including
projects with `generate: true` and no `l10n.yaml`.

It drops, and records the reason for, the following:

- `missing_untracked_file`: a self-import of a file no commit ever contained (gitignored API keys, `firebase_options.dart`).
- `obsolete_toolchain_api`: sources importing `package:flutter_gen/...`, the synthetic l10n package that current Flutter no
  longer provides.
- `unsatisfiable_dependencies`: `pub get` cannot resolve.
- `broken_source` and `no_progress`: errors one toolchain cannot fix.

Nothing is patched by hand, because a patched file is no longer the commit it claims to be. That is why the dev-dependency
conflict in `wasabeef/flutter-architecture-blueprints` is a drop and not a repair.

These gates favour recent code, because older commits fail more often, so the mined stratum leans recent. That should be
reported as a caveat. It is not something to fix.

## isolate

```
probe_v2/samples_v2/
  0001/base.dart        one group per rebuild scope
  sources.jsonl         id, project, trigger, commit_sha, source file
  map.jsonl             id, nodeType, project, commit_sha, blob_sha, scope name
  groups.jsonl          everything, including provenance and undefined names
  id_map.json           identity -> id, so later runs never renumber
```

`spm isolate` writes the same shape as `samples/*/base.dart`: a `GeneratedWidget` wrapper, the transplanted
`_GeneratedWidgetState`, and the child widget classes and enums it could inline, with package imports and nothing else. It
does not write a `dependencies.dart`.

Each group records its project, scope type and commit sha. Without them a transplanted widget cannot be attributed, because
the same path holds different code at different revisions and the scope type decides which harness trigger applies. Two more
fingerprints let any group be re-derived or disproved: `blob_sha` (git's hash of the source at that commit) and
`source_sha256` (independent of git). `dirty_lib` flags a checkout with uncommitted changes in `lib/`, whose transplant would
match no commit.

Ids are given once per identity (`project::file::type::name::ordinal`) and kept in `id_map.json`, so adding repositories
never renumbers a group. That matters because ids appear in tables and figures.

### `--history`

Without it you get one snapshot per scope, which cannot give a before and after pair. With it, each group also gets its
earlier revisions next to `base.dart`:

```
0001/
  base.dart               the scope at HEAD
  rev_001_8eac29ec.dart   the same scope at an earlier commit
  rev_002_58e4fbbf.dart
```

and `samples_v2/revisions.jsonl` gets one row per walked commit with `id`, `commit_sha`, `blob_sha`, `content_sha256`, author,
subject and `touched_declaring_file`. A False there means the change reached the scope only through its closure.

A revision file is only written if the transplant changed. The walk visits every commit that touched any tracked scope in the
repository, so most commits leave a given scope identical (on `fluent-reader-lite`, 4 of 5 consecutive revisions of one scope
were the same file). Writing them all would fill the corpus with duplicates, and every pair built from them would have zero
difference by construction. Unchanged commits are still recorded, with status `unchanged`, so "nothing happened" can be told
apart from "never looked at".

Scopes are matched across revisions by `(source file, node type, scope name, ordinal)`, recomputed at each revision. A renamed
or moved scope stops matching and its history ends there. That is recorded and never guessed at, since pairing two different
scopes would invent a difference.

If `mine` has run, its result is used as a gate and only revisions whose closure resolved are written. Otherwise every
candidate commit is isolated and the summary says so (`resolution_gate: NONE`). One `spm isolate` run per revision covers every
scope in that repository, and `pub get` and code generation rerun only when the pubspec changes. `--max-commits` caps the walk,
and any cap is printed and recorded.

### What leaving out `dependencies.dart` costs

The `isolate` phase measures this itself and stores it in `isolate_summary.json`. On the first 73 groups, none analysed clean,
there were 211 distinct undefined names, and the median group had 27 errors. The best case was a group short of only
`MyColors`.

That is expected. The transplant inlines widget classes and enums, while every model, service, theme and controller type stays
undefined. In `samples/` the hand-written `dependencies.dart` supplied exactly those. A corpus without it is faithful to the
commit but cannot run as it is. To make a group runnable you either write that file again or extend `spm isolate` to inline
more, and that should be decided before spending any device time. The count is of distinct names, since the analyzer reports
one diagnostic per use. `--no-check` skips the check.

## Outputs

Everything goes into `probe_v2/`: `clone_report.json`, `prepare_report.json`, `targets.jsonl`,
`discover_summary.json`, `history_features.jsonl`, `history_pairs.jsonl` and `mine_summary.json`. Pair rows carry
`all_zero_delta`, both endpoint commits and `touched_declaring_file`. A nonzero difference with that False is a change a
file-level filter could not have found.

## Which spm build

The container ran spm 0.7.1 by path (`../spm-publish`) and now pins 0.7.2 from pub.dev, as `pubspec.yaml` explains. Arm 1 was measured with an earlier
build, which affects what can be pooled across the two arms, and the write-up discusses that under threats to validity.
