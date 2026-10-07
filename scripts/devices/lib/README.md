# devices/lib

The shared measurement pipeline for the phones. It used to be a roughly 550-line script copied into each device's `run.sh`
(one per phone), and the two copies were about 85% identical. The logic now lives here once. Each
`devices/<id>/run.sh` only sets its device-specific values and then sources `pipeline.sh`.

## Files

Each file is one stage. They are sourced, never run directly.

- `core.sh`: output helpers (`banner`, `log`, `ok`, `warn`, `bad`, `die`) and the adb wrappers (`adbx`, `sh`).
- `telemetry.sh`: battery, temperature and current readers that need no root. Uses `THERMAL_ZONE` and `CURRENT_UNIT`.
- `knee.sh`: stage 0. Finds the temperature knee and cools the phone down (`find_knee`, `resolve_knee`,
  `fan_flip_cooldown`, `stop_load`).
- `prep.sh`: stage 1. `prep_device` turns on airplane mode, turns off animations, sets the screen, kills background
  apps and bloat, and optionally pins 60 Hz.
- `root.sh`: stage 1b. `root_probe`, `root_prep`, `root_restore`, `root_preflight`: pin the CPU frequency, isolate cpusets,
  cut charging with `input_suspend`, and quiet the install prompts. Does nothing without root.
- `preflight.sh`: stage 2. The hard power check (charge-on or charge-cut, depending on `POWER_MODE`) and the root checks.
- `measure.sh`: stage 3. Runs `device_runner run` with telemetry, pausing on temperature or low battery.
- `report.sh`: stages 4 and 5. `parse_captures` and the closing `acceptance_gates`.
- `pipeline.sh`: runs the stages in order. It holds the shared settings, resolves the serial, and restores the phone on exit.

## What a device's `run.sh` has to set

These go before `source "$DEVICE_DIR/../lib/pipeline.sh" "$@"`:

- identity: `DEVICE_ID`, `DEVICE_MODEL_LABEL`, `MODEL_PROP`, `DEVICE_DIR`
- serial: `SERIAL_ENVS[]` (environment variable names, first non-empty wins) and `SERIAL_HINT`
- knee: `KNEE_DEFAULT` (empty means a measured knee is required), `SOC_ABORT_C`, `CLUSTER_LABEL`
- sensors: `CURRENT_UNIT` (`uA` or `mA`), `THERMAL_ZONE` (an index, or empty for the hottest), `PIN_60HZ` (0 or 1)
- bloat: `BLOAT_LABEL`, `BLOAT_PKGS[]`
- notes for manual steps: `PREP_MANUAL[]`, `PREFLIGHT_MANUAL[]`, and optionally `ACCEPTANCE_EXTRA`
- `BENCH_DATASET_DIR` (export it). Normally leave it unset, see below.

To add a device, copy an existing `run.sh`, change this block, and add a matching `README.md`.

## Choosing the corpus and the output folder

Positional arguments are sample groups. These flags can come before them and work on every device:

- `--samples-root DIR`: the corpus to measure, relative to the repository root. The default is `samples` (arm 1).
  `new_samples` is arm 2.
- `--dataset-dir DIR`: where results go. By default it is derived from the corpus: `samples` gives `dataset`, and any other
  root `X` gives `dataset-X`.
- `--eligible-only` / `--no-eligible-only`: measure only revisions that are an endpoint of an eligible contrast, according
  to `<corpus>/exclusions.json`. On by default exactly when that file exists.
- `--resume`: continue the group's existing `raw/<session>/` and measure only the executions it is missing. With `all` it
  runs the whole campaign (see below).
- `--fresh` / `--no-resume`: always start a new session. Same as `BENCH_RESUME=0`.

### Which session a run writes into

`measure.sh::resolve_session` decides, in this order:

1. `BENCH_RAW_SESSION=<stamp>` uses exactly that directory.
2. `--fresh` or `BENCH_RESUME=0` always makes a new stamp.
3. `--resume` asks `device_runner status --pick-session` for the group's most complete session, newest name breaking a
   tie. It continues a session that is already complete (the runner skips everything and exits without touching the phone)
   and one where nothing has completed. Rule 4 does neither of those.
4. With no flag, the old heuristic: resume a session only if it is partly complete (`0 < complete < expected`), otherwise
   make a new stamp.

### `--resume all`

Plain `all` gives the runner one session name for the whole walk, so every group goes into that session, and
`resolve_session` (which only looks at `ACTIVE_SAMPLE_GROUP`, empty in this mode) always makes a fresh stamp. A complete group
would be measured again from zero. `--resume all` means something different: `pipeline.sh` expands it to the sorted list of
group directories under the corpus root and takes the normal named-group path, one session per group.

Before touching the phone, a planning pass asks `device_runner status --all --best --quiet` once for the whole corpus and
prints a row per group:

```
  0455       34/30  skip — complete
  0452         2/0  skip — no targets under this selection
  2283        8/45  RESUME
  0352        0/30  FRESH
```

Groups that owe nothing (`complete >= expected`, or `expected == 0` under the current `--eligible-only` selection) are left
out of the work list and listed again at the end under `SKIPPED`. If nothing is left, the run exits 0 without preparing the
phone. It is a single Python process for the whole corpus because `discover_targets` rereads `exclusions.json` on each call.
A group name that the report never mentions is a fatal error, so a typo is not silently skipped.

A whole campaign can be resumed after a battery stop by running the same command again:

```sh
EXECUTIONS=15 ./devices/redmi9t/run.sh --samples-root new_samples --resume all
```

Resuming means reusing the directory. The runner skips an execution only if `capture.capture_complete` is true for the
`e<k>.log` it finds inside the session it was given, and it deletes and remeasures an incomplete or orphaned capture. A new
stamp therefore remeasures everything. Raising `EXECUTIONS` and rerunning with `--resume` tops up the same session.

The derived dataset folder keeps the arms apart. `_meta/<device>/manifest.json` is keyed by device only, so two arms in one
folder would leave just the last arm's manifest. Both Python calls, `device_runner run` and the `status` check used to
resume, get the same `RUNNER_CORPUS_ARGS`, so the expected number of executions is never computed against a different corpus
than the one being measured.

The shared environment settings (`KNEE_C`, `FIND_KNEE`, `ASSUME_YES`, `EXECUTIONS`, `SEED`, `WARMUP`, `KNEE_MARGIN_C`,
`RUN_FLOOR`, `BENCH_PKG`, `BRIGHTNESS`, `MAX_CHARGE_MA`, `BAND_LO/HI`, `COOLDOWN_MAX`, `BENCH_REPO`) have defaults in
`pipeline.sh`.

## Root options (`root.sh`)

All of them default to the unrooted behaviour, so a device that sets none is unaffected.

- `USE_ROOT` (`auto`): `auto` uses root if present, `1` requires it and dies without it, `0` turns it off.
- `POWER_MODE` (`charge_on`): `suspend` cuts charging with `input_suspend`. It needs root and falls back without it.
- `GOV_PIN` and `PIN_FREQ_KHZ` (`1` and `cpuinfo_max_freq`): set the `performance` governor with
  `scaling_min == scaling_max` on the big cluster.
- `BIG_CORES` (the cores at the highest frequency): for example `"4 5 6 7"`.
- `CPUSET_ISOLATE` (`1`): `top-app` goes to the big cores and every other cpuset to the little cores.
- `QUIET_INSTALL` (`1`): turns off the verifier and the MIUI optimisation settings that cause the "Install via USB?" dialog.

`POWER_MODE` also changes the charging check in preflight. `charge_on` requires a weak, non-fast USB trickle. `suspend`
requires the opposite: not charging, with `current_now <= 0`. The check is never switched off, only pointed somewhere else.
The root settings are then read back from the phone, and one that did not take counts as a hard failure in the same tally
`preflight` dies on.

## Where results go

Devices are separated inside one dataset folder, by the `<device>` part that `config.device_slug()` derives from `DEVICE_ID`.
`dataset/<group>/static.jsonl` does not depend on the device, while `dataset/<group>/<device>/…` holds what
each phone measured (this release has `redmi9t`). `parse` only rewrites the files of the device that is running, so the two cannot overwrite each other.
That matters because `buildSpan` cannot be compared across SoCs, and the rooted Redmi uses a different power and frequency
protocol.

The arms are kept apart by folder, not by device. `pipeline.sh` exports `BENCH_DATASET_DIR` derived from the corpus root
(`samples` gives `dataset`, `new_samples` gives `dataset-new_samples`, and `--dataset-dir` overrides it), and
`scripts/device_runner/config.py` puts every output path under it.

Per-device constants go through the same route: `BENCH_COOLDOWN_TEMP_MILLIC`, `BENCH_BATTERY_PAUSE_PCT` (`0` turns off
pausing to charge, which is required with a charge cut), `BENCH_BATTERY_RESUME_PCT` and `BENCH_BATTERY_ABORT_PCT`. If unset,
they use the default (unrooted) values.
