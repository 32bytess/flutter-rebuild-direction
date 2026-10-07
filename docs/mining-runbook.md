# Mining runbook

How the arm-2 corpus is mined: find repositories, clone them, prepare them, discover scopes and commits, mine the history,
screen the result. The clones and the mine's working state are not part of this release, so these are the steps as I ran them,
not something you can replay from the data repository alone. `rerun-from-clones.md` covers rerunning from existing clones.
`config/README.md` covers the part that comes after screening (fixtures, branches, the freeze).

```
collector -> clone -> prepare -> discover -> mine -> screen
 GitHub      history   lib/ clean   scopes +   walk      exclusions
 search      graph                  closure    history   applied
```

## The rules that matter most

- Run `prepare`, `discover` and `mine` one at a time, never together. They all call `pub get`, which fights over the shared
  pub cache. The fight shows up as false `unsatisfiable_dependencies` results, which silently throw away repositories that
  would have resolved and corrupt the prepare rate.
- Every phase from `clone` to `mine` writes a checkpoint per repository when it finishes it, so an interrupted run, or a rerun
  after the harvest grew, picks up where it stopped. Use `--resume`. The screen resumes by default. `--retry-failed` also
  reruns repositories whose checkpoint records a failure.
- A checkpoint only says the phase finished, not with which arguments. After changing the extractor build, a phase's limits or
  the screen's rules, delete that phase's checkpoint directory instead of resuming across the change. The same goes for turning
  on `--all-revisions`.
- Always pass `--max-commits` to `mine`. One repository is walked one commit after another whatever `--jobs` says, so a single
  outlier sets the run time. In round 2, `dreautall/waterfly-iii` had 4,102 commits and used 10.8 hours to reach 52% before I
  stopped it.
- Keep `--jobs` at 2. One `spm analyze` on a 29 MB repository peaked at 1.34 GB of RAM on the 14 GB machine, and past about 3
  jobs the compressed-memory swap eats the CPU and the run gets slower.

## Excluding repositories

There are three places, from the earliest and strongest to the weakest:

1. `mining.config.corpus_keys()` always excludes the eight repositories `samples/` was built from. They are read from
   `samples/sources.jsonl` and `map.jsonl` and joined with `config.py:CORPUS_REPOS`, so a missing manifest can only exclude too
   much. Mining them would put the arm-2 stratum back on the repositories the arm-1 groups came from.
2. `data/exclusions.txt` holds standing exclusions, one `owner/name` per line with a `#` reason. The collector checks it before
   cloning anything, and `mining.clone` and `config.selected()` check it too, so one line holds for every phase.
3. `--exclude` on any phase applies to that run only. It accepts `owner/name`, a URL or `@file`. A name that matches nothing
   prints `UNMATCHED`, because an exclusion that excludes nothing is almost always a typo.

`python3 -m scripts.mining pilot-repos --all` prints what a run would act on without cloning or writing anything. Use it
before any long phase.

## The sequence

```bash
cd flutter-rebuild-direction

# 0  nothing else running, enough disk (about 29 MB per repository), token present
pgrep -af "mining|scripts.collector" ; df -h . ; grep -q "GITHUB_TOKEN=..*" .env

# 1  find repositories (network-bound). Dry run first.
python3 -m scripts.collector --discover-only | tee discover.txt
python3 -m scripts.collector --max 400

# 1a check what the next phases will act on
python3 -m scripts.mining pilot-repos --all | wc -l

# 2  clone with full history (blobless)
python3 -m scripts.mining clone --all

# 3  prepare: bring lib/ to zero errors. This is the limiting step.
python3 -m scripts.mining prepare --all --jobs 2 --resume

# 4  discover scopes and the commits that could have changed them
python3 -m scripts.mining discover --all --only-clean --jobs 2 --resume --all-revisions --since dart3

# 5  (optional) isolate a HEAD snapshot of every scope
# python3 -m scripts.mining isolate --all --resume

# 6  mine the history: feature differences and one transplant per commit that changed one
systemd-run --user --scope -p MemoryMax=5G -p MemorySwapMax=1G -p CPUQuota=600% \
  nice -n 10 ionice -c3 \
  python3 -m scripts.mining mine --all --isolate --jobs 2 --resume --max-commits 400 --all-revisions --since dart3

# 6b record whose package code each transplant carries (for rule R17); hours, resumable
python3 -m scripts.mining license-provenance --resume --repos <owner/name ...>

# 7  build the corpus: screen, fill fixtures, override branches, prune
python3 -m scripts.screen_samples --source probe_v2/samples_v2 --dest new_samples \
  --records new_samples --markdown --full --from-nothing
```

## What each step does

**Find repositories.** A GitHub search for repositories with at least 50 stars and 5 forks under MIT, Apache-2.0 or
BSD-3-Clause, then each clone is searched for state-management patterns. Repositories already seen are skipped through
`data/collected_repos.db`, so it can be stopped and restarted. The queries are in `scripts/collector/config.py:REPO_SEARCH_QUERIES`.
A search returns at most 1,000 results per query, sorted by stars, so to go wider add star bands (`stars:50..75`,
`stars:75..150`) instead of raising `--max`.

**Prepare.** Gets each `lib/` to zero error diagnostics. In round 1 only 34% of repositories passed (the rest were
`unsatisfiable_dependencies`, `broken_source`, `no_progress` and `missing_untracked_file`). Failures here are final. Nothing is
patched by hand, because a patched file is no longer the commit it claims to be. `scripts/mining/README.md` lists what
`prepare` fixes and what it drops.

**Discover.** Chooses commits through the closure of files a scope's metrics depend on, not only the file that declares the
scope. About 42% of candidate commits could only be found that way. Use `--only-clean`, because scanning an unresolved
repository finds only some of the scopes and reports a closure that is short by an unknown amount.

**Isolate.** Writes one `base.dart` per scope from the HEAD checkout, in the shape of `samples/`, without a
`dependencies.dart`. It is optional with `--all-revisions`: `mine --isolate` creates a group for every scope it meets, using the
first revision it walked, so such a corpus has no HEAD-anchored base. Pick one anchor and keep it. Running `isolate` after
skipping it overwrites `base.dart` with the HEAD transplant.

**Mine.** One walk that produces both the feature differences and the per-revision transplants.

- `--all-revisions` finds scopes at every revision, not only those at HEAD. Without it, a `BlocBuilder` that was added and
  removed three commits later cannot be seen, and neither can anything before a rename. It must be enabled in `discover` and
  `mine` together, and the checkpoints of both must be deleted before turning it on.
- `mine` writes no `base.dart`. A group is a set of numbered revisions (`rev_<order>_<sha8>.dart`), one for each commit that
  changed the transplant. No revision is the reference for the others, because privileging one commit is what a corpus built to
  compare revisions with each other must not do. `groups.jsonl` records `base_dart: null`.
- Two scopes with the same name in one file collide on `scope_key`. The second is dropped and counted in
  `scopes_ambiguous_skipped`, because interleaving the two would invent differences nobody wrote.
- `--since` limits the commits considered, and it must be given to both `discover` and `mine`. `dart3` is 2023-05-10, when Dart 3
  shipped. From then on null safety is mandatory and the old constructs stop resolving, so no difference straddles a language
  version. `null-safety` (2021-03-03) and any date also work. `mine_summary.json` records the cutoff and how many commits it
  dropped.
- Progress and stopping: `ls probe_v2/checkpoints | wc -l` counts finished repositories, `ls probe_v2/worktrees` shows those being
  walked, and `pkill -f "scripts.mining mine"` is safe. Since 2026-08-28 a repository stopped part-way has a journal at
  `probe_v2/checkpoints/partial/<owner_name>.jsonl`, and `--resume` continues from the commit it stopped on. A journal written
  under different arguments (`--since`, `--max-commits`, `--all-revisions`, `--isolate`) is refused and that repository starts again.

**Screen.** `probe_v2/samples_v2/` is the frozen mined output, and curation happens in `new_samples/`. Give the frozen corpus as
`--source` and the working copy as `--dest`. The screen walks the frozen corpus and copies only what survives, so
`new_samples/` never holds a file the screen rejected.

```bash
python3 -m scripts.screen_samples --source probe_v2/samples_v2 --dest new_samples --markdown --dry-run   # look first
python3 -m scripts.screen_samples --source probe_v2/samples_v2 --dest new_samples --records new_samples --resume --markdown
# audit only: writes exclusions.json and EXCLUSIONS.md, exports nothing
python3 -m scripts.screen_samples --source probe_v2/samples_v2 --records screen-records --report-only --markdown
```

- The rules are matched by parsing, not by regular expressions. R1 to R6, the near-duplicate hash and the normalisation
  rewrites live in `scripts/dart_tools`, a parse-only Dart package. A mined transplant has imports that cannot be resolved, but it
  always parses. Before the switch, every disagreement with the old regexes was checked against the whole mine, and each was the
  regex being wrong: words inside string literals and comments, a commented-out `MaterialApp`, and a plain `Future(() {…})` that
  the regex missed. `dart test` in `scripts/dart_tools` runs the calibration cases.
- The unit of exclusion is the file, not the group. A group ships only the `rev_*.dart` files that pass on their own, and ordinals
  are never renumbered, so the names have gaps. A group where every file is excluded is dropped.
- Export normalisation removes images (spm's `Skeletonizer` writes `Image.asset('assets/placeholder.png')`, an asset this
  project does not have) and removes imports nothing needs. Import pruning is a greedy set cover, widest import first, which keeps
  the import that `samples/` would have used. It uses a table of SDK library exports in `scripts/dart_tools/lib/src/namespaces.g.dart`.
  Regenerate it after a Flutter or SDK upgrade:
  ```bash
  cd scripts/dart_tools
  dart run tool/export_namespaces.dart ../.. > lib/src/namespaces.g.dart
  ```
- The screen resumes per repository from `probe_v2/checkpoints_screen/`. A checkpoint written under a different rule set,
  `--strict`, `--dest` or `--keep-excluded-revisions` is ignored, and the screen says so.
- Never delete `new_samples/` by hand to force a clean screen. A rerun only adds groups, and the export never overwrites or
  prunes an authored file. `--full --from-nothing` is the one sanctioned way to rebuild. It refuses if anything in `--dest`
  cannot be regenerated or has been measured, and it checks the result afterwards (see `config/README.md`).
- `--prune-to-endpoints` runs last. It keeps only the roles that are an endpoint of an eligible contrast.
  `device_runner --eligible-only` is what protects a campaign until then.

## Checking what the mine gained

Diversity is the reason for mining, so check it after each round. Read `exclusions.json` from where the full corpus was last
screened, not from a reduced working copy, which would understate everything.

```bash
python3 - <<'PY'
import json, glob, collections
ex = json.load(open("new_samples/exclusions.json"))
el = [r for r in ex["pairs"] if r["verdict"] == "eligible"]
sc = collections.defaultdict(set)
for r in el: sc[r["scope_key"].split("::")[0]].add(r["scope_key"])
n = sum(len(v) for v in sc.values()); sh = [len(v)/n for v in sc.values()]
print(f"eligible: {len(el)} pairs / {n} scopes / {len(sc)} repos")
print(f"effective repos (inverse Simpson): {1/sum(s*s for s in sh):.2f}")
print(f"largest share: {max(sh)*100:.0f}%")
keys = {r["pair_id"] for r in el}
F12 = ["treeNonConstWidgetCount","treeMaxWidgetNestingDepth","treeListRenderingStrategy",
"rootBuildReturnsConstWidget","treeConstWidgetCount","helperReferenceCount",
"usesLayoutDependentBuilder","treeCyclomaticComplexity","treeIterationCount",
"iterationWidgetCount","valueObjectAllocCount","helperWidgetCount"]
mv = collections.Counter()
for f in glob.glob("probe_v2/checkpoints/*.json"):
    for p in json.load(open(f)).get("pairs") or []:
        if p["pair_id"] in keys:
            for k, v in p.items():
                if k.startswith("d_") and v: mv[k[2:]] += 1
dead = [f for f in F12 if mv[f] == 0]
print(f"features that never move: {len(dead)}/12 {dead}")
PY
```

`usesLayoutDependentBuilder` moves in under 1% of pairs, because it needs a commit that adds or removes a `LayoutBuilder`. More
mining will not fix that. Report it as a limit on feature coverage, never as an absence of effect.

## If the mine is interrupted

`history_pairs.jsonl`, `history_features.jsonl` and `revisions.jsonl` are only written on a clean exit. Checkpoints hold the
whole record of each finished repository, so nothing finished is lost. The simplest recovery is to run
`mine --all --isolate --resume` again, which walks only what has no checkpoint and then writes the aggregate files itself.

If you need the aggregates without walking anything, build them from the checkpoints. The four corpus-wide files belong in
`probe_v2/` (`mining.config` names them as `HISTORY_FEATURES`, `HISTORY_PAIRS` and `MINE_SUMMARY`, with `code_rows.jsonl`
beside them), never in a sample folder. `code_rows.jsonl` and `samples_v2/revisions.jsonl` come from the same source key, and
`code_rows.jsonl` is the complete one. After an `--all-revisions` walk, the groups it created are in the checkpoints under
`new_groups`. If a run was killed, rerun `mine --all-revisions --resume` rather than editing the manifests by hand.

To join the history to a screened corpus, join on `scope_key` instead of copying:

```bash
python3 - <<'PY'
import json
keys = {f'{r["project"]}::{r["source_file_relative"]}::{r["scope_name"]}'
        for r in map(json.loads, open("new_samples/groups.jsonl"))}
rows = [r for r in map(json.loads, open("probe_v2/history_pairs.jsonl")) if r["scope_key"] in keys]
print(len(rows), "pairs for the screened corpus")
PY
```

## Building a second corpus beside the first

`scripts.mining pipeline` runs the same phases one repository at a time, from clone to screened corpus, so the destination
holds a complete corpus after every repository and not only at the end. Each repository gets a verdict in `repo_pipeline` in
`data/collected_repos.db` (the stage it reached, whether it produced an eligible contrast, and the rules, values and extractor
it was decided under), so changing the rules selects the old verdicts again without anyone deleting checkpoints.

```bash
export SPM_FIXTURE_VALUES=config/fixture_values_v3.json
export SPM_MAXIMAL_BRANCH=config/maximal_branch_v3.json
python3 -m scripts.mining pipeline --all --new --dest new_samples_v3
```

The two variables are required. A `--full` screen writes `config/fixture_values.json` and `config/maximal_branch.json`, and the
arm-2 corpus is a pure function of them, so a second corpus filling its own values into the committed tables would break arm 2's
integrity check even with `new_samples/` untouched. The pipeline refuses to start without them. `--new` is the default,
`--eligible` reruns only repositories that produced contrasts, `--ignore-ledger` ignores the ledger, and `--stop-after N` stops
early. To prove that the streamed corpus equals a batch build, run the `--full --from-nothing` screen above once at the end.
Do not run it per repository, which would make the run quadratic.

## Machine limits

Measured on a Ryzen 5 6600H (6 cores, 14 GB RAM, compressed-memory swap, `systemd-oomd` inactive): about 6.7 GB of RAM was free
with a normal desktop session open, so budget about 2 GB per job. `--jobs 2` is comfortable, 3 is fine if you are away, and 4 or
more begins to thrash. The `systemd-run` line in step 6 caps memory so that an overrun kills only the miner. Watch
`free -h`, and drop to `--jobs 1` if free memory falls below about 1.5 GB or zram use passes about 3 GB.

## Other things to know

- `pkill -f "mining mine"` can also match your own shell if the pattern is in its command line. Check with `pgrep` afterwards.
- `rm -rf probe_v2/worktrees` is safe. They are recreated when needed.
- Stage 01 of the old analysis found features by exclusion, so new `analyze` columns would have become features, and two of the
  closure fields are lists and raise `TypeError`. The arm-1 notebooks use a fixed feature list, so this no longer applies there.
- `mining` has nine phases: `clone`, `prepare`, `discover`, `isolate`, `mine`, `license-provenance`, `pipeline`,
  `backfill-checkpoints` and `pilot-repos`. Anything else named in older notes belonged to the earlier `history_probe` tool.
