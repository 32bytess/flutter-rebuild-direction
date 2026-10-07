# Rerunning the pipeline from the clones

How to rebuild `new_samples/` from the existing clones without cloning again: what to keep, what to delete, and the order to run
things. `mining-runbook.md` explains why each phase does what it does. This file only covers the rerun. The clones are not
part of this release, and `probe_v2/` is released only as a trimmed copy (`arm2-mining/` in the data repository), so
this describes the author's working copy. Paths below use the folder names the code expects; the code README shows how to link the
data repository's folders in under those names.

## What to keep

- `../new_data/repos-full/` (next to this repository): the clones themselves (196 repositories, 4.4 GB, about 53,700 commits). Not
  cloning again is the whole point.
- `data/candidates.jsonl` and `.csv`: the harvest manifest. Every phase looks repository names up here.
- `data/collected_repos.db`: the collector's log. Without it the next harvest evaluates everything again.
- `data/exclusions.txt`: the standing exclusions.
- `samples/`: the arm-1 corpus. This pipeline never touches it, and the list of excluded repositories is derived from it.

Check the clones are there first: `ls ../new_data/repos-full/ | wc -l`.

The clones can be reused even though `prepare` changed them. It appends a `dependency_overrides` block to each `pubspec.yaml`
under a marker, and writing it again removes the previous block first, so it is idempotent. Generated sources and `.dart_tool/`
are git-ignored and are reused, which is what makes a rerun much cheaper than the first run. Only if you want provably pristine
checkouts, reset them with `git -C "$d" checkout -- . && git -C "$d" clean -fdx` for each clone, and pay for every `pub get` and
code generation again.

## What to delete

| phase | delete |
|---|---|
| prepare | `probe_v2/prepare_report.json`, `probe_v2/checkpoints_prepare/` |
| discover | `probe_v2/targets.jsonl`, `probe_v2/discover_summary.json`, `probe_v2/checkpoints_discover/` |
| isolate | `probe_v2/samples_v2/`, `probe_v2/isolate_summary.json`, `probe_v2/checkpoints_isolate/`, `probe_v2/isolate_scratch/` |
| mine | `probe_v2/history_features.jsonl`, `probe_v2/history_pairs.jsonl`, `probe_v2/code_rows.jsonl`, `probe_v2/mine_summary.json`, `probe_v2/checkpoints/`, `probe_v2/worktrees/`, `probe_v2/mine_isolate_scratch/` |
| screen | `new_samples/`, but move it aside instead: `mv new_samples new_samples.roundN` |

`new_samples/` is a working copy. Everything in it is derived from `probe_v2/samples_v2/` and the screen. If you keep the
directory, at least delete `new_samples/.screen_cache.json`. The screen reuses a cached verdict for any file whose size and
modification time are unchanged, and a stale cache is how a rule change quietly fails to apply.

Group ids are allocated from `probe_v2/samples_v2/id_map.json`. Keep a copy before deleting `samples_v2/` and put it back
afterwards if you want the numbering to stay the same. If you do not, ids restart at `0001` and anything keyed on the old ids no
longer points at the same scopes.

Do not run `backfill-checkpoints` after a clean wipe. It rebuilds checkpoints from the summaries on disk so that `--resume`
treats old work as done, which is the opposite of what a clean rerun wants. It is for adopting work finished before
checkpointing existed.

## The run

Run the phases one at a time. They all call `pub get`, and contention on the shared pub cache shows up as false
`unsatisfiable_dependencies`.

```bash
cd flutter-rebuild-direction
pgrep -af "mining|scripts.collector"     # must print nothing
df -h /home                                 # about 29 MB per repository

# pin the extractor before anything else, and do not change builds part-way through
grep -A3 '^  spm:' pubspec.lock             # the build the corpus is mined with

python3 -m scripts.mining pilot-repos --all | wc -l      # what the run will act on

python3 -m scripts.mining prepare --all --jobs 2
python3 -m scripts.mining discover --all --only-clean --jobs 2 --all-revisions --since dart3
# optional: python3 -m scripts.mining isolate --all
systemd-run --user --scope -p MemoryMax=5G -p MemorySwapMax=1G -p CPUQuota=600% \
  nice -n 10 ionice -c3 \
  python3 -m scripts.mining mine --all --isolate --jobs 2 --all-revisions --since dart3 --max-commits 400

python3 -m scripts.screen_samples --source probe_v2/samples_v2 --dest new_samples --markdown --dry-run
python3 -m scripts.screen_samples --source probe_v2/samples_v2 --dest new_samples --markdown
```

Notes on the steps:

- **The extractor build.** A corpus half mined with one spm build and half with another cannot be pooled, and nothing in the output
  says which half a row came from. The container pins spm 0.7.2 from pub.dev (see `pubspec.yaml`); the original runs used the same source as a path checkout, `../spm-publish`. Confirm the build in
  `pubspec.lock` before the first phase, and never change it between phases.
- **`prepare` can sometimes be skipped.** It never calls spm. It is `pub get`, code generation and `dart analyze`, so a change of
  extractor does not invalidate its verdicts, and the generated sources in the clones are still there. It is the only phase whose
  old output is safe to adopt after an extractor change. `discover`, `isolate` and `mine` all run spm, and their old output
  came from the old build. There is no `--resume` on the first run, because the checkpoints are gone and this run recreates them.
- **`--since dart3`** is `--since 2023-05-10`, the day Dart 3.0 shipped. Commits before that are effectively a different language,
  and a difference across the boundary records a migration, not a developer's edit. Pass the same value to `discover` and `mine`.
  The cutoff also makes a run affordable, because `git log --since` prunes the walk itself.
- **`--all-revisions`** adds a `history_sweep` row for each repository: commits that touched a `lib/**.dart` file carrying a scope
  marker at that commit, beyond what HEAD's closures select. Without it the corpus only holds scopes that survive to HEAD, which is
  a survivorship filter on the population being measured. Check what it found with `probe_v2/discover_summary.json`
  (`scopes_total`, `candidate_commits`, `sweep_commits_new`).
- **`--max-commits`.** A full-coverage mine, with no cap, takes days: the cost was about 59 seconds per commit at `--jobs 2` under
  the earlier spm build, and one long-history repository sets the minimum run time. Plan an uncapped run as stop-and-resume over
  several days.
- **The screen.** Always `--dry-run` first. The screen copies only what survives, so `new_samples/` never holds a rejected file.
  Do not copy the corpus across and reduce it in place. `--source` must stay byte-faithful to what `mine` wrote, and `--dest` can
  be deleted and rebuilt at any time. While the mine is running, rerun the same command with `--records new_samples --resume` as
  repositories finish, and each rerun costs only what the mine added.
- **If the mine did not exit cleanly,** rebuild the aggregate files first (`mining-runbook.md`, "If the mine is interrupted").

## Did the run use its flags?

Check that the run really used `--all-revisions` and `--since`. A phase that quietly ran without a flag produces a corpus that
looks normal. `mine_summary.json` has `scopes_from_walk` (zero without `--all-revisions`) and `commits_before_cutoff_dropped`,
and each phase summary records `since`. If `scopes_from_walk` is 0, the walk was HEAD-only.

## A fast first batch

If you want something to work on while the long run continues, run `prepare`, `discover` and `mine` on a handful of the cleanest
repositories first (`--repos owner/name ...`), screen them, and start writing fixtures for the groups that survive. The screen
resumes per repository, so the long run adds to the same corpus instead of replacing it. Do not run this batch at the same time as
the long run, since both call `pub get`.

## Then check diversity

Run the diversity check in `mining-runbook.md`. The targets were more than about 6 effective repositories, a largest share under
about 25%, and at most 1 of the 12 features never moving.
