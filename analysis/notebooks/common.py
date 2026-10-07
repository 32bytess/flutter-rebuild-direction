"""Shared helpers for the four analysis notebooks.

Nothing here fits a model that is not described in a notebook. The frozen result files are read-only
and every figure a notebook quotes goes through ``check()``: a mismatch stops the notebook.
"""
import json
import warnings
from pathlib import Path

import numpy as np
import pandas as pd

warnings.filterwarnings("ignore", category=UserWarning)
# scikit-learn deprecation notices; they print the library's install path into the outputs
warnings.filterwarnings("ignore", category=FutureWarning)

SEED = 20260803
CUT = 0.33  # small/medium boundary of the Romano scale: label 1 (slower) iff Cliff's delta > 0.33


def find_analysis() -> Path:
    here = Path.cwd().resolve()
    for p in (here, *here.parents):
        if (p / "data").is_dir() and (p / "results").is_dir() and (p / "notebooks").is_dir():
            return p
    raise FileNotFoundError("run from inside analysis/notebooks")


ANALYSIS = find_analysis()
DATA = ANALYSIS / "data"        # inputs: labelled contrasts, stored medians, splits, training set, arm-2 population
RES = ANALYSIS / "results"      # frozen result files the notebooks check against
FIGURES = ANALYSIS / "figures"  # outputs: the report figures, written by the notebooks


def load(path):
    return json.loads(Path(path).read_text())


CHECKS = []


def check(name, got, want, tol=0.0):
    """Compare a recomputed or frozen value with the number the report quotes."""
    ok = abs(float(got) - float(want)) <= tol
    CHECKS.append({"claim": name, "value": got, "reported": want, "ok": ok})
    assert ok, f"{name}: {got!r} != {want!r}"


def report():
    df = pd.DataFrame(CHECKS)
    print(f"{int(df.ok.sum())} / {len(df)} reported figures reproduced")
    assert df.ok.all()
    return df


def load_pairs():
    """The 1,454 arm-1 contrasts with the project of each seed group."""
    pairs = pd.read_csv(DATA / "redmi9t_pairs_labelled.csv", dtype={"group": str})
    src = pd.read_csv(DATA / "sources.csv", dtype=str).set_index("group")["project"]
    pairs["project"] = pairs["group"].map(src)
    assert (pairs["label"] == (pairs["cliffs_delta"] > CUT).astype(int)).all(), "label must follow the 0.33 rule"
    return pairs


def cliffs_delta(right, left):
    """P(right > left) - P(right < left) over all pairs of executions; positive = right slower."""
    d = np.sign(np.asarray(right, float)[:, None] - np.asarray(left, float)[None, :])
    return float(d.mean())


def drift_adjusted(executions):
    """Remove each session's drift with schedule position from the per-execution medians.

    Per group (one measured session each): OLS log(median_us) = a_role + beta * pos over the ok
    executions. Returns ({group: beta}, {(group, role): log(median_us) - beta * pos, by exec_index}).
    """
    ok = executions[executions.status == "ok"].sort_values(["group", "role", "exec_index"], kind="mergesort")
    betas = {}
    for g, sub in ok.groupby("group", sort=True):
        roles = sorted(sub.role.unique())
        X = np.column_stack([(sub.role.to_numpy() == r).astype(float) for r in roles] + [sub.pos.to_numpy()])
        betas[g] = float(np.linalg.lstsq(X, np.log(sub.median_us.to_numpy()), rcond=None)[0][-1])
    values = {(g, r): np.log(sub.median_us.to_numpy()) - betas[g] * sub.pos.to_numpy()
              for (g, r), sub in ok.groupby(["group", "role"], sort=True)}
    return betas, values


def load_executions(name):
    """Per-execution medians and schedule positions (written by scripts/export_executions.py)."""
    return pd.read_csv(DATA / name, dtype={"group": str})


def clopper_pearson(k, n):
    from scipy.stats import binomtest
    ci = binomtest(int(k), int(n), 0.5).proportion_ci(0.95, method="exact")
    return float(ci.low), float(ci.high)


# Report figures: greyscale, no titles or notes inside the image (the caption carries the explanation).
DARK, MID, LIGHT = "#2b2b2b", "#7a7a7a", "#c8c8c8"


def figure_style():
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 9, "axes.spines.top": False,
                         "axes.spines.right": False, "svg.hashsalt": str(SEED), "pdf.fonttype": 42})
    return plt


def save_figure(fig, name):
    """Write manuscript-ready PNG (300 dpi) and SVG into analysis/figures/."""
    import matplotlib.pyplot as plt
    FIGURES.mkdir(exist_ok=True)
    for ext, extra in (("png", {"dpi": 300}), ("svg", {"metadata": {"Date": None}})):
        fig.savefig(FIGURES / f"{name}.{ext}", bbox_inches="tight", facecolor="white", **extra)
    plt.close(fig)
    print("wrote", f"figures/{name}.png", "and .svg")
