# scripts

A short guide to what is in here. Flags and output paths are in `docs/measurement-commands.md` and `docs/mining-runbook.md`, and each package's
`__main__.py` docstring says how to run it, so they are not repeated here.

## Packages

- `collector`: finds candidate Flutter repositories on GitHub, clones them and records their metadata.
- `device_runner`: replays samples on the phone and aggregates the results (`run`, `parse`, `telemetry`, `status`,
  `gate`). `gate.py` holds the battery and temperature checks, `transplant.py` the staging rule.
- `mutation`: generates the directed mutations for a sample.
- `screen`: the exclusion screen, split into modules. `../screen_samples.py` is still the entry point, and
  `screen/rebuild.py` is the `--from-nothing` check.
- `mining`: the arm-2 mine over unseen repositories. Each phase can be rerun on its own.
- `tests`: the golden-corpus suite and unit tests (`pytest scripts/tests`).
- `dart_tools`: Dart, not Python. Four commands: `screen`, `normalise`, `fixture`, `branches`.
- `devices`: a runbook and `run.sh` for each phone.

The earlier generation and probe tools (the arm-1 LLM `pipeline`, `history_probe`, `isolate_quality`, `isolate_replay`,
`split_equivalence`) are not in this release. Comments and runbooks that name them describe the working repository.

## Top-level modules

- `screen_samples.py`: entry point of the exclusion screen. Its docstring on rules R1 to R10 is the only written record of
  where each rule came from, so leave it as it is.
- `ast_tools.py`: runs the Dart tools as a subprocess (batching, the AOT build, error collection). It contains no rule.
- `spm.py`: runs spm as a subprocess and reports which build of the extractor this checkout uses.
- `jsonio.py`: reads a JSON file that another process may be writing.
- `paths.py`: `PROJECT_ROOT`, `ACADEMIC_ROOT` and `rel()`, found by looking for marker files instead of counting parent
  folders.
- `extract_features.py`: analysis over the mined rows.
- `fixture_gate.py`, `fixture_skeleton.py`, `fixture_values.py`: the arm-2 fixture path: the gate, hoisting into a shared
  `dependencies.dart`, and seeding values.
- `maximal_branch.py`: picks the maximal branch of a scope. Branch counts come from the Dart AST, not a regex.
- `clone_repos.py`: clones the candidates in `data/candidates.jsonl` into `../new_data/`.
- `record_source_commits.py`: run once. The clones are `--depth 1`, so it recorded which commit each transplanted widget
  came from in `samples/source_commits.jsonl`. Rerun only if the corpus gets new seeds.
- `export_executions.py`: writes the per-execution tables the analysis notebooks read (`analysis/data/*_executions.csv`,
  `execution_start_readings.csv`) from the measurement folders.
- `extractor_parity.py`: re-extracts every arm-1 role under the current `spm` and compares it with the recorded row;
  writes `analysis/results/extractor_parity.json`.

## Paths worth knowing

- `PROJECT_ROOT` is the repository root and `ACADEMIC_ROOT` is its parent. `paths.py` finds them by walking up to a folder
  with `pubspec.yaml`, `scripts/` and `analysis/`, and raises if it cannot. The repository cannot be moved on its own,
  because `ACADEMIC_ROOT` is where the clones live.
- The third-party clones are outside the repository, in `../new_data/repos{,-full}/`. They are 2.4 GB and do not belong in
  git.
- `dataset/`, `dataset-new_samples/`, `samples/`, `new_samples/`, `samples_excluded/`, `probe_v2/` and `data/` are
  relative symlinks into `../flutter-rebuild-direction-data/`, whose folders have clearer names (the
  top-level README maps them). That repository has to stay next to this one.
- `probe_v2/` is the mine's working state (2.7 GB) and is git-ignored. A mine can be stopped part-way through, so check the
  runbook before restarting one.
