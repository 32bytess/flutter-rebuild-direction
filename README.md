# flutter-rebuild-direction

Code for a study of whether a controlled structural change to a Flutter widget makes its rebuild slower or faster, predicted from static features of the code only. This repository has the code. The data is in the sibling repository [`flutter-rebuild-direction-data`](https://github.com/32bytess/flutter-rebuild-direction-data). The extractor and profiler are the [`spm`](https://github.com/32bytess/spm) package.

The Dart package and the Android app inside are still named `benchmark_container`, because the recorded device logs refer to that name.

If you only want to check the reported numbers, you do not need the data repository. Go to `analysis/`.

## What is where

- `analysis/`: the four notebooks that reproduce the reported results, with the data and frozen results they read. Start with `analysis/README.md`.
- `scripts/`: everything that built the corpus and ran the measurements: candidate collection, mining and transplanting, the exclusion screen, the on-device runner, and the tests. `scripts/README.md` lists the packages: `collector/` (candidate repositories), `mining/` (the arm-2 mine), `screen/` with `screen_samples.py` (the exclusion screen), `device_runner/` (the on-device campaign), `devices/` (one runbook per phone), `mutation/` (the arm-1 variants), `dart_tools/` and `tests/`.
- `lib/`, `integration_test/`, `test_driver/`, `android/`: the Flutter app the runner drives on the phone.
- `config/`: the policy files the corpus is built from (fixture values, licence policy, render exclusions, authored fixtures).
- `docs/`: command notes. `measurement-commands.md` covers one on-device measurement session, `mining-runbook.md` the arm-2 mine, and `rerun-from-clones.md` how to rebuild the arm-2 corpus from existing clones.

## Data

The data is in a separate repository, [`flutter-rebuild-direction-data`](https://github.com/32bytess/flutter-rebuild-direction-data) (about 490 MB: the raw device logs, the two widget corpora and the candidate lists). Clone it next to this one:

```bash
git clone https://github.com/32bytess/flutter-rebuild-direction-data.git ../flutter-rebuild-direction-data
```

The notebooks in `analysis/` do not need it. Rebuilding anything from the raw measurements does.

## Reproducing the figures

```bash
uv venv --python "$(which python3)" .venv
uv pip install --python .venv/bin/python -r analysis/requirements.lock ipykernel nbconvert
cd analysis/notebooks
../../.venv/bin/jupyter-nbconvert --to notebook --execute --inplace 0*.ipynb
```

This takes about two minutes. Each notebook compares what it computes with the number reported and stops with an error if they differ. The models are retrained inside the notebooks.

The labels of both arms are recomputed from per-execution tables in `analysis/data/`, which `scripts/export_executions.py` writes from the data repository. Which arm-2 pairs are evaluated (`analysis/data/arm2_population.json`) is read, not rebuilt: building it needs the clones of the mined repositories, which are not part of this release. Notebook 4 recomputes everything after that.

## Getting `spm`

The Flutter app and the scripts depend on `spm`, the static extractor, from version **0.7.1** on. `pubspec.yaml` pins **0.7.2** from pub.dev ([pub.dev/packages/spm](https://pub.dev/packages/spm/versions/0.7.2)), and `pubspec.lock` records its sha256. Nothing else needs to be cloned:

```bash
flutter pub get
dart run spm:spm help    # check that the extractor resolves
```

The pub.dev archives of 0.7.1 and 0.7.2 are file-for-file identical to commits `0c174f7` and `0d749b5` of [github.com/32bytess/spm](https://github.com/32bytess/spm). During the measurements the dependency was a checkout of that repository next to this one (`path: ../spm-publish`), and the run records (for example `analysis/results/extractor_parity.json`) still name it that way.

`spm` is archived on Zenodo, DOI [10.5281/zenodo.23171328](https://doi.org/10.5281/zenodo.23171328). Arm 1 was measured with spm 0.7.0 from pub.dev and arm 2 with 0.7.1. The one difference that touches measurement, a `print` in `SpmState.setState` that 0.7.0 runs on every rebuild, executes before the measured span opens.

Arm-2 sessions from 2026-09-09 on used the 0.7.1 source plus one fix in `spm inject`, released later as 0.7.2. It moves the `SpmState` import below a `library` directive, because a file that declares one did not compile once it was instrumented. The measured manifests still say 0.7.1. `analyze`, `isolate` and the profiler are unchanged from 0.7.1 to 0.8.0, so any release in that range gives the same features and timings.

## Using it with the data repository

Clone [`flutter-rebuild-direction-data`](https://github.com/32bytess/flutter-rebuild-direction-data) next to this repository (`git clone https://github.com/32bytess/flutter-rebuild-direction-data.git ../flutter-rebuild-direction-data`) and link its folders in. The code still uses the folder names it was written with, so each link gets the old name:

```bash
D=../flutter-rebuild-direction-data
ln -s $D/arm1-measurements  dataset
ln -s $D/arm2-measurements  dataset-new_samples
ln -s $D/arm1-widgets       samples
ln -s $D/arm2-widgets       new_samples
ln -s $D/excluded-widgets   samples_excluded
ln -s $D/arm2-mining        probe_v2
ln -s $D/repo-candidates    data
```

Paths recorded inside the data files are written as `<ROOT>` (see the data README). The scripts that need the mine's clones cannot be run, because the clones are not included.

## Tests

```bash
uv pip install --python .venv/bin/python --group dev --group mine   # pytest, requests, python-dotenv
.venv/bin/python -m pytest scripts/tests
```

On this repository alone this gives 470 passed and 22 skipped. With the data repository linked in as above it gives 476 passed and 16 skipped: the six extra tests check the corpus files themselves.

The 16 tests that are always skipped are marked `slow`. They rerun the exclusion screen over the arm-2 mine and need the mine's clones and worktrees, which are not released, so they cannot pass from a copy of these two repositories.

Do not run `scripts/tests/regolden.py` to make a failing test pass. It rewrites the golden corpus, and a change that needs that is a change to the method, not a refactor.

## Things to know

- All measurements come from one phone, a Redmi 9T. Nothing here supports a claim about other devices. An earlier pilot on a second phone contributes no result; its runbook and data are not released.
- Arm 2 is an external evaluation of a model fitted on arm 1.
- The data repository's `SOURCES.md` links every project that was mined or used, with its licence and what it contributed.
- The data repository contains third-party package and repository code. The screen only lets through MIT, Apache-2.0 and BSD-3-Clause code (`config/license_policy.json`). The data repository's `THIRD_PARTY_NOTICES.md` lists every source with its licence and copyright notice. The authored fixtures in `config/authored_fixtures/` are written for widgets from those same repositories.

**Authored fixtures and the use of a language model.** Where the generated `dependencies.dart` of an arm-2 group would not mount or left display values empty, it was completed by an *authored* fixture. These files were drafted with a large language model assistant, Claude Sonnet 5, under instructions given in the prompt rather than a written protocol: realistic literals for display strings and dates; no added widget, logic or function body; no change to a value that selects the larger branch or to an extracted feature. The instructions were not applied identically to every group, and the author reviewed and accepted every file. The comment header at the top of each `dependencies.dart` is template text written by the skeleton generator; for an authored group its account of where the values came from (and the `fixture_provenance.json` it refers to) does not apply. The headers are left as they are because these files are the exact bytes that were measured, pinned by hash in `config/measured_freeze.json`. `python3 -m scripts.authored_fixtures --list` lists the authored groups.


**Use of a language model.** The code in this repository, including the analysis code, was written with Claude Sonnet 5 under the author's direction. The author designed what is extracted and measured and the measurement protocol, and reviewed and tested the code. The arm-1 variants were also generated by Claude Sonnet 5; see the data repository's README.

## Licence

The code is under the MIT licence (`LICENSE`). The data repository is under CC BY 4.0, apart from the third-party code named in its `THIRD_PARTY_NOTICES.md`. To cite, see `CITATION.cff`. By AMOURA Ammar Abderafik, maintained on GitHub as [32bytess](https://github.com/32bytess).
