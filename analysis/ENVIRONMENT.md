# Environment

CPython 3.14.7, scikit-learn 1.9.0, lightgbm 4.7.0, numpy 2.5.3, pandas 3.0.6, scipy 1.18.1, joblib 1.6.0,
matplotlib 3.11.2 (figures only).

Measurement device, both arms: Xiaomi Redmi 9T; Flutter 3.44.0 stable with Dart 3.12.0
(the Dart version that ships with that Flutter release).

`requirements.lock` has the exact set. To recreate it:

```bash
uv venv --python "$(which python3)" .venv
uv pip install --python .venv/bin/python -r analysis/requirements.lock ipykernel nbconvert
```

Seeds are fixed (20260803) and the estimators run on one thread, so a rerun gives the same figures. A different
scikit-learn or lightgbm version can change a fitted model a little and make a check fail.
