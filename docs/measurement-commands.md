# Measurement commands

The commands for collecting `buildSpan` data for one or more `State<>` samples. Run everything from the repository
root. All measurements were taken on one phone, the Redmi 9T, through `scripts/devices/redmi9t/run.sh`. It prepares the
phone for the session (airplane mode, animations off, background apps stopped, plus the root controls),
runs the commands below, and restores the phone afterwards. See `scripts/devices/redmi9t/README.md`. This file lists
the parts it is built from, for checking or debugging one step by hand.

`[phone]` means the step acts on the device and `[host]` that it runs on the workstation. `<SERIAL>` is the phone's adb
serial number.

## 0. Once per device, by hand

Set these in the phone's Settings app. They cannot be scripted reliably.

- Battery: power saving off, adaptive battery off.
- Display: auto-brightness off, brightness fixed low, motion smoothness on Standard (60 Hz), adaptive refresh off.
- Developer options: stay awake on.
- Remove or disable vendor apps that run in the background, and turn off any game-boost mode for the app.

Record the toolchain and never mix versions within a dataset:

```sh
flutter --version          # [host] paste into the run log or manifest
```

## 1. Check the phone is connected

```sh
adb devices                # [host] the phone should show as "device"
flutter devices            # [host] the phone should be listed (android-arm64)
```

If two devices are listed (the phone and the Linux desktop), the drive commands below name the phone with `-d <SERIAL>`.

## 2. Check the phone's health (optional)

The runner does this before every execution. To look by hand:

```sh
# battery level, temperature (tenths of a degree C) and whether it reports charging
adb shell dumpsys battery | grep -iE "level|temperature|powered"

# hottest thermal zone, in milli-degrees C (44000 means 44.0 °C)
adb shell "cat /sys/class/thermal/thermal_zone*/temp" | sort -n | tail -1
```

## 3. Measuring

### Option A: the full run

The runner does static extraction, injection, the profile drive, N interleaved executions per target, temperature and
battery gating, and raw capture. It has two subcommands for this:

```sh
# Measure (on the phone, slow). Static extraction, then N_EXECUTIONS x N_REBUILDS profiled rebuilds per target, randomly
# interleaved and gated. Writes raw/ and dataset/.
python -m scripts.device_runner run --widget-type 01 --executions 5 --seed 42
#   --widget-type 01   only samples/01/ (leave out to run every group)
#   --executions 5     independent relaunches per target
#   --seed 42          seed for the interleaving order (logged)
#   --extract-only     only the static analysis, no device drive

# Parse (off the phone, can be rerun on the stored raw/). Takes the buildSpan lines, drops timeouts, discards the warm-up
# rebuilds and takes the median of each execution. Writes rebuilds.jsonl and performance.jsonl.
python -m scripts.device_runner parse --warmup 10
#   --warmup 10   drop the first 10 rebuilds of each execution before the median
```

The runner does not do the labelling. `analysis/notebooks/01_data_and_labels.ipynb` shows how execution medians become
base-versus-variant contrasts.

Results go to `dataset/`: `static.jsonl` (AST features per target), `rebuilds.jsonl` (every rebuild), `performance.jsonl`
(per-execution medians, raw arrays and `status`) and `manifest.json` (provenance). Raw drive logs go to
`dataset/<group>/<device>/raw/<session>/<role>/`. `run` can be resumed: an interrupted session skips executions already captured in `raw/`.

To walk a whole corpus in one command, use the device wrapper instead:
`./scripts/devices/<device>/run.sh --samples-root <corpus> --resume all`. It runs every group as its own session, skips groups
that are done (a planning pass prints a table before the phone is touched), and continues where it stopped if you run the
same command again. To see what is still outstanding without measuring anything:

```sh
BENCH_DATASET_DIR=dataset-new_samples python -m scripts.device_runner status \
  --all --best --quiet --samples-root new_samples --eligible-only --executions 15 \
  --device redmi9t        # one "<group> <complete>/<expected>" line per group
```

`performance.jsonl` holds every execution, including ones `flutter drive` reported as failed. `status` is `"ok"` or
`"failed"`, and a failure that captured nothing still gets a row with `median_us: null`. Nothing is dropped when parsing, so
filter on `status == "ok"` before aggregating.

### Option B: the two `spm` commands the runner calls

Useful for debugging one target by hand.

```sh
# Static analysis: the AST features for every State class in the project.
dart run spm:spm analyze --output ./static.jsonl .
#   Writes one JSONL row per State class. The row for lib/generated_widget.dart is the active target.

# Inject and profile: one execution of the active widget.
dart run spm:spm run \
  --jsonl static.jsonl --repo . \
  --flutter drive \
    --driver=test_driver/integration_driver.dart \
    --target=integration_test/integration_test.dart \
    --no-dds \
    -d <SERIAL> \
    --dart-define=SPM_REBUILDS=30
#   `spm run` injects SpmState (from static.jsonl), adds `--profile`, runs the integration test that fires SPM_REBUILDS
#   profiled setState rebuilds (each prints one `[SPM:perf] <id> buildSpan: <µs>` line), then reverts the injection.
#   -d <SERIAL>                    names the phone (needed when the Linux desktop also counts as a device).
#   --dart-define=SPM_REBUILDS=N   size of the inner rebuild loop (default 30).
```

To put a sample into the active slot by hand, the way the runner does:

```sh
cp samples/01/base.dart lib/generated_widget.dart
sed "s/import 'base.dart';/import 'generated_widget.dart';/" \
  samples/01/dependencies.dart > lib/dependencies.dart
```

## Notes

- Profile mode only. `spm run` always adds `--profile`, and the profiler throws outside profile mode. Never measure in debug
  or on an emulator.
- Do not touch the screen during a drive. A touch posts input to the UI thread and corrupts `buildSpan`.
- Each rebuild is serialised. The integration test waits for a rebuild's measurement (`SpmProfiler.current`) before it fires
  the next `setState`, so no reading is lost to an overlapping monitor.
- The warm-up, rebuild and execution counts are in `scripts/device_runner/config.py` (`N_REBUILDS`, `N_EXECUTIONS`,
  `WARMUP_DISCARD`, `COOLDOWN_TEMP_MILLIC`, `SEED`).
