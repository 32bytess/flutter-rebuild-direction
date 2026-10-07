#!/usr/bin/env python3
"""Write the per-execution tables the analysis notebooks read, from the measurement folders.

Needs the data repository linked in (see the README): `dataset/` (arm one) and
`dataset-new_samples/` (arm two). Writes three files into `analysis/data/`:

  redmi9t_executions.csv     arm one, every execution of each group's measured session
  arm2_executions.csv        arm two, every execution of the session used for each labelled group
  execution_start_readings.csv
                             both arms, every measured execution: the hottest thermal zone and the
                             battery level the runner recorded as the execution started

The first two have one row per execution: group, role, exec_index, pos, status, median_us.
`pos` is the execution's 0-based rank in its session, in start order, divided by the number of
executions the session ran (failed ones included). `median_us` is the median of the kept
rebuilds of an ok execution, as `scripts.device_runner.parse` wrote it to `performance.jsonl`.
Arm one ranks by the header's `ts`, arm two by its `started`.

    python3 -m scripts.export_executions
"""

from __future__ import annotations

import csv
import json
import re
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ARM1 = ROOT / "dataset"
ARM2 = ROOT / "dataset-new_samples"
OUT = ROOT / "analysis" / "data"
DEVICE = "redmi9t"
COLUMNS = ["group", "role", "exec_index", "pos", "status", "median_us"]


def header(log: Path) -> dict:
    with open(log, encoding="utf-8", errors="replace") as fh:
        return dict(re.findall(r"(\w+)=(\S+)", fh.readline()))


def performance(group_dir: Path) -> dict:
    rows = {}
    for line in (group_dir / "performance.jsonl").read_text().splitlines():
        if line.strip():
            r = json.loads(line)
            rows[(r["session"], r["role"], int(r["exec_index"]))] = r
    return rows


def session_rows(group: str, root: Path, session: str, order_by: str) -> list[dict]:
    group_dir = root / group / DEVICE
    perf = performance(group_dir)
    heads = []
    for log in sorted((group_dir / "raw" / session).glob("*/e*.log")):
        h = header(log)
        k = int(log.stem[1:])
        assert int(h["exec_index"]) == k and h["sample_id"] == f"{group}/{log.parent.name}", log
        heads.append((datetime.fromisoformat(h[order_by]), log.parent.name, k, h["ok"] == "True"))
    heads.sort()
    rows = []
    for rank, (_, role, k, ok_header) in enumerate(heads):
        p = perf.get((session, role, k))
        ok = ok_header and p is not None and p["status"] == "ok"
        rows.append({"group": group, "role": role, "exec_index": k, "pos": rank / len(heads),
                     "status": "ok" if ok else (p["status"] if p else "failed"),
                     "median_us": float(p["median_us"]) if ok else float("nan")})
    return sorted(rows, key=lambda r: (r["role"], r["exec_index"]))


def write(name: str, rows: list[dict], columns: list[str]) -> None:
    with open(OUT / name, "w", newline="") as fh:
        w = csv.DictWriter(fh, columns, lineterminator="\n")
        w.writeheader()
        for r in rows:
            w.writerow({c: (repr(r[c]) if isinstance(r[c], float) and r[c] == r[c] else
                            ("" if isinstance(r[c], float) else r[c])) for c in columns})
    print(f"wrote analysis/data/{name}: {len(rows)} rows")


def arm1() -> list[dict]:
    with open(OUT / "redmi9t_pairs_labelled.csv", newline="") as fh:
        groups = sorted({r["group"] for r in csv.DictReader(fh)})
    rows = []
    for g in groups:
        sessions = sorted({s for s, _, _ in performance(ARM1 / g / DEVICE)})
        assert len(sessions) == 1, f"{g}: {len(sessions)} measured sessions"
        rows += session_rows(g, ARM1, sessions[0], "ts")
    return rows


def arm2() -> list[dict]:
    population = json.loads((OUT / "arm2_population.json").read_text())
    evaluation = json.loads((ROOT / "analysis" / "results" / "arm2_evaluation.json").read_text())
    pairs = {p["pair_key"]: p for p in population["population_pairs"] + population["p6_sensitivity_pairs"]}
    groups = sorted({pairs[r["pair_key"]]["group"] for r in evaluation["labels"]["per_pair"]})
    rows = []
    for g in groups:
        rows += session_rows(g, ARM2, population["p9_session_by_group"][g], "started")
    return rows


def start_readings() -> list[dict]:
    rows = []
    for arm, root in (("arm1", ARM1), ("arm2", ARM2)):
        for log in sorted(root.glob(f"*/{DEVICE}/raw/*/*/e*.log")):
            h = header(log)
            rows.append({"arm": arm, "group": log.parents[3].name, "session": log.parents[1].name,
                         "role": log.parent.name, "exec_index": int(log.stem[1:]),
                         "soc_temp_c": int(h["soc_temp_millic"]) / 1000,
                         "battery_pct": int(h["battery_pct"])})
    return rows


def main() -> None:
    for path in (ARM1, ARM2):
        if not path.is_dir():
            raise SystemExit(f"{path.name}/ is missing: link the data repository in first (README)")
    write("redmi9t_executions.csv", arm1(), COLUMNS)
    write("arm2_executions.csv", arm2(), COLUMNS)
    write("execution_start_readings.csv", start_readings(),
          ["arm", "group", "session", "role", "exec_index", "soc_temp_c", "battery_pct"])


if __name__ == "__main__":
    main()
