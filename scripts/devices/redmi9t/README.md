# devices/redmi9t

Measurement setup for the Xiaomi Redmi 9T (Snapdragon 662 / SM6115, codename `lime`), rooted with Magisk. This is the
reference device for the study. An early pilot on a second, unrooted phone contributes no result.

`run.sh` is a thin wrapper. It sets the Redmi values and then sources `../lib/pipeline.sh`, which runs every stage in order:
find the knee, prep, root prep, preflight, measure with telemetry, parse, label, restore. One command does everything. Run it
from the `scripts/` folder. Set `REDMI_SERIAL` if more than one device is attached.

## What root changes

- **Frequency pin.** `governor=performance` with `scaling_min == scaling_max` on cpu4 to cpu7. The clock cannot ramp up
  during a rebuild burst, so the first rebuilds of an execution run at the same frequency as the last. This was the largest
  single source of variation within a target on this SoC.
- **Cpuset isolation.** `top-app` gets the big cores and every other cpuset the little cores, so background work cannot
  preempt the Flutter UI thread on the pinned cores.
- **A real charge cut.** `input_suspend=1`, not `dumpsys battery unplug`. Charger heat and PMIC current leave the
  measurement, and the battery really drains. Preflight checks for that.
- **Quiet installs.** The verifier and MIUI optimisation settings are turned off, which removes the "Install via USB?" dialog
  that used to block unattended `flutter drive` reinstalls.

All of this is in `../lib/root.sh` and does nothing without root, so the unrooted path is unchanged. Every change is written to
`.rootstate-<serial>` before it is applied and replayed on restore, including after a crashed run.

## Why 15 executions

With 5 medians per side, listing every possible split of 10 values into two groups of 5 (252 of them) shows that two samples
from the same distribution get labelled `Slower` 21.0% of the time under the `δ > 0.33` rule. With 15, that drops to about
6.4%, Cliff's δ moves on a 1/225 grid instead of 1/25, and the Mann-Whitney p-value is usable as supporting evidence (the
smallest two-sided p is 3.1e-6 against 9.0e-3). That noise floor is why the rooted campaign exists.

A group is 9 targets × 15 = 135 executions, about 4.5 hours. Measure one group per session, never a bare `all`. Each named
group is its own runner session, so an aborted run cannot truncate a finished one. To walk the whole corpus one group per
session in a single command, use `--resume all`, which expands to the group ids instead of blending them into one session.

## Dataset folders

`run.sh` does not set `BENCH_DATASET_DIR`. Both phones share one dataset folder and are kept apart one level down by the
`<device>` part that `config.device_slug()` derives from `DEVICE_ID`. `dataset/<group>/static.jsonl` is independent of the
device and `dataset/<group>/redmi9t/…` is this phone's. `parse` only rewrites this device's files. `buildSpan` cannot be
compared across SoCs in any case, and the power and frequency protocol differs too.

The folder does depend on the arm. `pipeline.sh` derives it from the corpus root: `--samples-root samples` (the default)
writes to `dataset/`, `--samples-root new_samples` to `dataset-new_samples/`, and `--dataset-dir DIR` overrides both. Two arms
must not share a folder, because `dataset/_meta/<device>/manifest.json` and its exclusions digest are keyed by device only,
and only the arm that ran last would keep a manifest.

The two devices cannot be measured at the same time from one checkout. `lib/generated_widget.dart`, the `static.jsonl` at the
repository root and `scripts/device_runner/static_cache/` are shared whatever `BENCH_DATASET_DIR` says. Finish one device's
session before starting the other's.

Tools on the analysis side follow the same variable, for example
`BENCH_DATASET_DIR=dataset-new_samples python analysis/exclude_failed_runs.py`.

## Usage

```
CALIBRATE=1 FIND_KNEE=1 ./devices/redmi9t/run.sh 01   # calibration session, do this first
./devices/redmi9t/run.sh 03                           # one group, n=15, rooted protocol
EXECUTIONS=5 ./devices/redmi9t/run.sh 03              # change the number of executions
PIN_FREQ_KHZ=1804800 ./devices/redmi9t/run.sh 03      # pass the pin without editing run.sh
USE_ROOT=0 ./devices/redmi9t/run.sh 03                # deliberately run unrooted
ASSUME_YES=1 ./devices/redmi9t/run.sh 03              # no interactive prompts

# arm 2, the mined-revision corpus. The dataset folder follows the corpus root, and
# --eligible-only turns itself on because new_samples/ has an exclusions.json.
./devices/redmi9t/run.sh --samples-root new_samples 0058
./devices/redmi9t/run.sh --samples-root new_samples --dataset-dir dataset-arm2 0058
./devices/redmi9t/run.sh --samples-root new_samples --no-eligible-only 0058  # every revision

# continue 0058's existing session instead of starting a second one next to it. Only the
# executions it is missing are measured. --fresh forces a new session.
./devices/redmi9t/run.sh --samples-root new_samples --resume 0058

# the whole corpus, one session per group. Groups that owe nothing are skipped before the phone
# is touched, partial ones continue, unmeasured ones start fresh. After a battery stop, run the
# same command again.
EXECUTIONS=15 ./devices/redmi9t/run.sh --samples-root new_samples --resume all
```

## Before the first dataset session

Two values are required and are deliberately left unset in `run.sh`.

1. `PIN_FREQ_KHZ`. Pinning at `cpuinfo_max_freq` on an 11 nm SD662 will throttle. Choose the highest value in
   `scaling_available_frequencies` that stays flat for a whole group and write it into `run.sh`. Once chosen, do not change
   it. Like the Flutter version, the pinned frequency is part of the measurement condition, and changing it starts a new
   condition. A lower pin that is always below the knee is better even if it costs some speed, since it should stop the
   cooldown gate between executions from firing, which is the main thing that stretches a session. `run.sh` refuses to
   measure a dataset group while it is unset (calibration runs are exempt).
2. The CPU thermal sensor name (`REDMI_THERMAL_NAME`). The knee is checked against one named sensor, not the hottest of all
   zones, which would include battery, PMIC and charger sensors. The SD662 sensor name was not confirmed on this unit.
   `run.sh` tries a list of candidates and aborts if none matches, so a cached knee can never guard the wrong sensor. To
   check:
   ```
   adb shell 'for z in /sys/class/thermal/thermal_zone*; do echo "$z $(cat $z/type)"; done'
   ```

The calibration session should also establish the real wall-clock time per execution and the battery drain under the charge
cut. A 4.5 hour group has to fit inside the 85% to 30% band. Otherwise split the group across two charges, or use
`POWER_MODE=charge_on` on the Redmi too, which loses the charge-cut benefit but allows long sessions.

Then run an A–A null test at n=15 and compare the observed `Slower` rate with the theoretical 6.4% floor.

## Checks after each session

- **Frequency.** `scaling_cur_freq` must never drop below the pin during the session. A drop means throttling or a pin that
  did not hold, and the session is discarded.
- **Temperature.** The `soc_temp_c` trace in the telemetry CSV is flat and below the knee.
- **Row count.** `wc -l <dataset folder>/<g>/redmi9t/performance.jsonl` must equal targets × executions for the group (arm 1:
  9 × 15 = 135; an arm-2 scope has as many targets as it has measured revisions) before you move on. By default, a session
  where nothing completed, or one that is already complete, starts a fresh timestamped session and measures from execution 0,
  while `parse` only reads the newest session and truncates. A partial rerun can therefore replace a complete group with
  fewer medians. Rerun with `--resume` to continue the existing session and measure only what is missing.
  `python -m scripts.device_runner status --group <g> --device redmi9t` (with the same `--samples-root` as the run) shows
  the count the runner expects, and `--pick-session` names the session `--resume` would continue. Then run
  `BENCH_DATASET_DIR=<dataset folder> python analysis/exclude_failed_runs.py`.
- **Manifest.** `<dataset folder>/_meta/redmi9t/manifest.json` records the device, serial, pinned frequency, governor, cpuset,
  power mode and `n_executions: 15`, all read back from the phone after preflight. It must contain no `TODO:` strings.
