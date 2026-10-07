# analysis

The analysis behind the reported results. Four notebooks, run in order, plus the data they read and the saved results they check against.

```
notebooks/   the four notebooks and a small common.py
data/        inputs: labelled contrasts, execution medians, folds, training set, arm-2 population
results/     saved result files the notebooks compare against
figures/     the report figures, written by the notebooks (PNG at 300 dpi, and SVG)
spm_export/  the arm-2 forest as plain arrays, for the screening tool in the spm package (written by notebook 4)
```

1. `01_data_and_labels`: the corpus, how the label is defined, how much it depends on the rule, drift, measurement quality.
2. `02_arm1_models`: the four learners and their AUC range, the baselines, feature importance, ablations, the screening numbers for RQ2. About two minutes.
3. `03_arm1_robustness`: holding out whole applications, the directive confound, the variant-to-variant stratum.
4. `04_arm2_evaluation`: the labels of both arms from the executions, the training set, the test set, the one test, the comparisons with simple rules, the other learners, and the forest exported for `spm screen`.

Every notebook checks each figure it prints against the reported number and stops with an error if they differ.

Each notebook ends with a *Figures* section that draws the figures for its sections from values it has already checked, and writes them to `figures/`. The images have no title or note; the report captions explain them. The three post-hoc figures of notebook 2 are drawn from its out-of-fold scores and need `RUN_HEAVY = True`.

| file | notebook | figure |
|---|---|---|
| `corpus_composition` | 01 | arm-one contrasts per application and slower share per directive |
| `cliffs_delta` | 01 | Cliff's δ over all arm-one contrasts, with the 0.33 threshold |
| `learner_range` | 02 | AUC of the four learners and the reference points |
| `feature_importance` | 02 | permutation importance, balanced logistic regression |
| `roc_four_learners` | 02 | ROC curves of the four learners, with the directive oracle as reference (post-hoc) |
| `errors_by_effect` | 02 | agreement with the label at 0.5, by where the measured δ lies (post-hoc) |
| `screening_gain` | 02 | share of slower contrasts caught when reviewing the highest scores first (post-hoc) |
| `leave_one_project_out` | 03 | AUC per held-out application |
| `arm2_agreement` | 04 | the forest against the count rule on both arms |

## Running

```bash
uv venv --python "$(which python3)" .venv
uv pip install --python .venv/bin/python -r requirements.lock ipykernel nbconvert
cd notebooks
../.venv/bin/jupyter-nbconvert --to notebook --execute --inplace 0*.ipynb
```

Nothing outside this folder is needed. The raw measurements these tables come from are in [`flutter-rebuild-direction-data`](https://github.com/32bytess/flutter-rebuild-direction-data). The environment is in `ENVIRONMENT.md`.

## Data files

- `redmi9t_pairs_labelled.csv`: the 1,454 arm-1 contrasts with Cliff's δ, the label and the feature differences.
- `redmi9t_role_medians.csv`: the 375 roles with their 15 execution medians. The notebooks recompute every label from these.
- `redmi9t_base_mut_stratified_group_kfold.json`: the outer folds, with whole seed groups held out.
- `redmi9t_feature_contract.json`: the twelve features, and the columns that must never be used as features.
- `redmi9t_snapshot_manifest.json`: written when the arm-1 data was exported. It has the sha256 of the two exports above, the role counts (387 nominal, 377 generated, 375 analysed), and the check of every execution against the raw device logs (0 mismatches). Notebook 1 checks the hashes. The medians file is listed in it under its earlier name, `redmi9t_medians_ds.csv`.
- `sources.csv`: which repository each seed group came from.
- `redmi9t_executions.csv`, `arm2_executions.csv`: one row per execution (group, role, execution index, schedule position, status, median rebuild time), for arm 1 and for the arm-2 groups with a labelled pair. The position-adjusted labels of both arms are computed from these.
- `execution_start_readings.csv`: for every measured execution of both arms, the hottest thermal zone and the battery level the runner recorded as the execution started.
- `mut_mut_training_set.csv`: the 819 variant-to-variant contrasts the arm-2 models are trained on. Notebook 4 rebuilds it from the files above and checks that it is identical.
- `arm2_population.json`: the arm-2 pairs of revisions with their feature differences.

The execution tables are written by `scripts/export_executions.py` from the data repository.

## Result files

These are frozen outputs. The notebooks read them and check them; they do not recompute them. The one exception is `posthoc_result_figures.json`, which notebook 2 writes.

- `model_results.json`: the arm-1 run of the four learners, including the 200-refit permutation test.
- `repo_level_results.json`: arm 1 with whole repositories held out (leave-one-project-out).
- `confound_restricted_results.json`: the restricted-design run, reported as a bound.
- `arm2_evaluation.json`: the arm-2 labels and the one evaluation pass. Notebook 4 recomputes both.
- `extractor_parity.json`: every arm-1 role re-extracted under `spm` 0.7.1 and compared with the recorded row, written by `scripts/extractor_parity.py`.
- `posthoc_sensitivity_checks.json`, `posthoc_followup_checks.json`, `posthoc_oracle.json`: post-hoc descriptive analyses, written after all results were seen. They decide nothing.
- `posthoc_result_figures.json`: the values behind the three post-hoc figures of notebook 2 (agreement by measured δ, the screening gain, the ROC AUCs). Written by notebook 2 from its out-of-fold scores; post-hoc and descriptive, and nothing is chosen from it.

## What is recomputed and what is only read

Recomputed: every label of both arms (raw and position-adjusted), the label sensitivity checks, the corpus counts, the four learners under the nested group-disjoint scheme, the baselines, leave-one-project-out and leave-one-directive-out, the training set and the arm-2 models retrained from it, the test set, the one test with its two robustness checks, the comparisons with the count rule on both arms and the thirteen further rules, and the per-pair intervals on arm 2.

Read from `results/` and checked: the permutation test (200 full refits), the restricted-design run, the extractor parity, and the remaining post-hoc analyses. The cell that uses each one says where it comes from.

Which arm-2 pairs enter the evaluation (`arm2_population.json`) is read, not rebuilt: building it needs the mined repositories, which are not part of the release.
