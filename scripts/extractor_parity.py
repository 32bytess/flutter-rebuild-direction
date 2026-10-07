#!/usr/bin/env python3
"""Extractor parity: re-extract every arm-one role under the current `spm` and compare.

Arm one was extracted under `spm` 0.7.0 and arm two under 0.7.1. This re-extracts every
measured arm-one role with the `spm` this repository resolves (one `spm analyze --scope-types
State` over `samples/`, the `_GeneratedWidgetState` row of each file) and compares it field by
field with the row recorded at measurement time in `dataset/<group>/static.jsonl`. It needs the
data repository linked in (see the README) and the Dart toolchain.

    python3 -m scripts.extractor_parity --extract    # runs spm, writes the scratch file
    python3 -m scripts.extractor_parity              # compares, writes the result

The result goes to `analysis/results/extractor_parity.json`. `instanceId` and `filePath` are not
compared: they depend on where the extraction ran, not on the code.
"""

from __future__ import annotations

import argparse
import csv
import json
import subprocess
from pathlib import Path, PurePosixPath

from scripts import spm

ROOT = Path(__file__).resolve().parents[1]
DATASET = ROOT / "dataset"
SAMPLES = ROOT / "samples"
PAIRS = ROOT / "analysis" / "data" / "redmi9t_pairs_labelled.csv"
SCRATCH = ROOT / "build" / "extractor_parity.jsonl"
RESULT = ROOT / "analysis" / "results" / "extractor_parity.json"

# The 14 static metrics, in dataset/static.jsonl key order, plus the scope's identity.
SCHEMA_14 = [
    "treeNonConstWidgetCount", "treeMaxWidgetNestingDepth", "treeListRenderingStrategy",
    "rootBuildReturnsConstWidget", "treeConstWidgetCount", "helperReferenceCount",
    "usesLayoutDependentBuilder", "treeCyclomaticComplexity", "treeIterationCount",
    "treeMaxIterationNestingDepth", "iterationWidgetCount", "valueObjectAllocCount",
    "helperWidgetCount", "helperMaxWidgetNestingDepth",
]
IDENTITY_COMPARED = ["scopeName", "scopeType"]
IDENTITY_NOT_COMPARED = ["instanceId", "filePath"]
GENERATED_STATE_CLASS = "_GeneratedWidgetState"


def extract() -> None:
    SCRATCH.parent.mkdir(parents=True, exist_ok=True)
    cmd = spm.analyze_state_cmd([str(SAMPLES)], str(SCRATCH))
    proc = subprocess.run(cmd, cwd=str(ROOT), capture_output=True, text=True)
    if proc.returncode != 0:
        raise SystemExit(f"spm analyze failed ({proc.returncode}):\n{proc.stderr}")
    print(f"wrote {SCRATCH.relative_to(ROOT)}")


def compare() -> dict:
    with open(PAIRS, newline="") as fh:
        groups = sorted({row["group"] for row in csv.DictReader(fh)})
    new = {}
    for line in SCRATCH.read_text().splitlines():
        if line.strip():
            r = json.loads(line)
            parts = PurePosixPath(r.get("filePath", "")).parts
            name = r.get("scopeName", r.get("stateClassName"))
            if len(parts) >= 2 and name == GENERATED_STATE_CLASS:
                new[f"{parts[-2]}/{parts[-1].removesuffix('.dart')}"] = r
    old = {}
    for g in groups:
        for line in (DATASET / g / "static.jsonl").read_text().splitlines():
            if line.strip():
                r = json.loads(line)
                old[r["sample_id"]] = r

    mismatches, missing = [], []
    for sid in sorted(old):
        n = new.get(sid)
        if n is None:
            missing.append(sid)
            continue
        for key in SCHEMA_14 + IDENTITY_COMPARED:
            if old[sid].get(key) != n.get(key):
                mismatches.append({"sample_id": sid, "field": key,
                                   "recorded": old[sid].get(key), "reextracted": n.get(key)})
    result = {
        "check": "every arm-one role re-extracted under the current spm and compared with the recorded row",
        "spm_build": spm.version(),
        "n_roles_in_dataset": len(old),
        "n_roles_compared": len(old) - len(missing),
        "groups": groups,
        "fields_compared": SCHEMA_14 + IDENTITY_COMPARED,
        "fields_not_compared": IDENTITY_NOT_COMPARED,
        "roles_missing_from_reextract": missing,
        "mismatches": mismatches,
        "n_mismatching_roles": len({m["sample_id"] for m in mismatches}),
        "pass": not mismatches and not missing,
    }
    RESULT.write_text(json.dumps(result, indent=1) + "\n")
    return result


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--extract", action="store_true", help="run spm into the scratch file first")
    if ap.parse_args().extract:
        extract()
    res = compare()
    print(json.dumps({k: res[k] for k in ("pass", "n_roles_compared", "n_mismatching_roles")}))


if __name__ == "__main__":
    main()
