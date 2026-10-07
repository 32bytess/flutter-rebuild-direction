"""Configuration for the samples measurement runner.

Implements the measurement execution protocol:

  per target (base + each mutation):
    N_EXECUTIONS independent relaunches x N_REBUILDS inner rebuilds
    -> discard WARMUP_DISCARD -> median per execution -> N medians per target
    -> pair base vs mutation -> Mann-Whitney U + Cliff's delta -> label.
"""

import os
import re
from pathlib import Path

from .. import spm
from ..paths import PROJECT_ROOT  # repository root

# ---- Project paths ----
LIB_DIR = PROJECT_ROOT / "lib"
ACTIVE_WIDGET_PATH = LIB_DIR / "generated_widget.dart"
ACTIVE_DEPS_PATH = LIB_DIR / "dependencies.dart"
SAMPLES_ROOT = PROJECT_ROOT / "samples"
STATIC_FILE = PROJECT_ROOT / "static.jsonl"  # spm analyze output (overwritten per target)
# The transplant slot, as the analyzer reports it: repo-relative, forward slashes. This is
# the `filePath` the injector resolves (`p.join(repoRoot, row['filePath'])`), so every row
# handed to `spm run` must carry it — regardless of where the row was actually extracted.
ACTIVE_WIDGET_REL = ACTIVE_WIDGET_PATH.relative_to(PROJECT_ROOT).as_posix()
# The State class every sample transplants into. Sample files may declare MORE than one
# State class (a nested StatefulWidget kept alongside the root), so the extracted row must
# be selected by class name — position in the file is not a safe key.
GENERATED_STATE_CLASS = "_GeneratedWidgetState"
# spm 0.3.0 generalized the analyzer from State classes to every rebuild scope (see its
# `analyze --scope-types`): it renamed `stateClassName` -> `scopeName` and added `scopeType`.
# One sample file can therefore now yield several rows (a nested Obx/Selector alongside the
# root State), which only makes selection by name more necessary, not less. The live corpus is
# fully re-extracted under 0.3.0 — every static_cache/*.jsonl and dataset/*/static.jsonl row
# spells it `scopeName` — but the archived pre-rename corpora under samples_excluded/ do not, so
# reads still go through both spellings; writes always use the current one.
SCOPE_NAME_KEYS = ("scopeName", "stateClassName")
# The one `scopeType` this corpus measures; also the only kind `spm inject` accepts.
STATE_SCOPE_TYPE = spm.STATE_SCOPE_TYPE   # kept as a name; defined once in `spm`


def scope_name(row: dict) -> str | None:
    """The rebuild scope's declaring class, across the 0.3.0 rename."""
    for key in SCOPE_NAME_KEYS:
        if key in row:
            return row[key]
    return None


def set_samples_root(value) -> Path:
    """Point the module at another corpus root — arm 2's `new_samples/`, or a test fixture.

    A REBIND, not a parameter, and deliberately so: `runner.phase1_extract`, the manifest's
    exclusions digest and the fixture gate all read `SAMPLES_ROOT` at call time, so every
    caller has to see the same root the targets were discovered under. Both entry points that
    accept `--samples-root` (`runner.main`, `status.main`) come through here, so the resume
    probe can never count a different corpus than the run measures.

    A relative path resolves against PROJECT_ROOT, matching how BENCH_DATASET_DIR is read.
    """
    global SAMPLES_ROOT
    root = Path(value)
    if not root.is_absolute():
        root = PROJECT_ROOT / root
    root = root.resolve()
    if not root.is_dir():
        raise SystemExit(f"--samples-root {root} is not a directory")
    SAMPLES_ROOT = root
    return root


INTEGRATION_DRIVER = PROJECT_ROOT / "test_driver" / "integration_driver.dart"
INTEGRATION_TEST = PROJECT_ROOT / "integration_test" / "integration_test.dart"

# ---- Runner working dirs (gitignored) ----
RUNNER_DIR = Path(__file__).parent
STATIC_CACHE_DIR = RUNNER_DIR / "static_cache"  # per-target static.jsonl snapshot (for injection)
INPLACE_STATIC_FILE = STATIC_CACHE_DIR / "_inplace.jsonl"  # one whole-corpus in-place analyze

# ---- Dataset outputs (committed; the publishable replication package) ----
# Layout — SAMPLE GROUP first, then DEVICE:
#
#   dataset/_meta/<device>/{manifest,exclusions}.json    corpus-level, per device
#   dataset/<group>/static.jsonl                         DEVICE-INDEPENDENT
#   dataset/<group>/<device>/{performance,rebuilds,pairs}.jsonl
#   dataset/<group>/<device>/raw/<session>/<role>/e<k>.jsonl   VM-service profiler events
#   dataset/<group>/<device>/raw/<session>/<role>/e<k>.log     flutter-drive stdout
#
# `static.jsonl` sits ABOVE the device segment on purpose: static AST features are the only
# artifact that does not depend on the phone, so one copy per group makes that structural
# instead of a convention — a per-device root would store 457 identical rows twice and give
# them two chances to drift.
#
# Everything measured sits BELOW it, because buildSpan is not comparable across SoCs and the
# rooted Redmi 9T runs a different power/DVFS protocol (charge cut + pinned clocks) than the
# default unrooted protocol. Devices share ONE dataset root and are separated by the <device> segment,
# so the two corpora sit side by side per sample instead of in duplicate trees.
#
# BENCH_DATASET_DIR still overrides the root (relative paths resolve against PROJECT_ROOT),
# but it is no longer how devices are kept apart — `device_slug()` is. Keep it for scratch
# roots (tests, dry runs).
_DATASET_OVERRIDE = os.environ.get("BENCH_DATASET_DIR", "").strip()
OUT_DIR = (PROJECT_ROOT / _DATASET_OVERRIDE) if _DATASET_OVERRIDE else (PROJECT_ROOT / "dataset")
META_NAME = "_meta"  # sorts before the numeric group dirs and cannot collide with one


def meta_dir() -> Path:
    """dataset/_meta/<device>/ — manifest + exclusions for THIS device's corpus."""
    return OUT_DIR / META_NAME / device_slug()


def manifest_path() -> Path:
    return meta_dir() / "manifest.json"


def exclusions_path() -> Path:
    return meta_dir() / "exclusions.json"


def group_dir(group: str) -> Path:
    return OUT_DIR / group


def device_dir(group: str) -> Path:
    """dataset/<group>/<device>/ — everything this phone measured for this sample."""
    return group_dir(group) / device_slug()


def raw_dir(group: str) -> Path:
    """Per-execution captures, session-scoped so a re-run never overwrites an earlier one.

    The .jsonl is what `spm run` captures off the Dart VM service (`ext.spm.profiler`) and is
    the measurement of record; the .log carries the preflight header, the failure text
    `_classify()` reads, and the `[SPM:perf]` debugPrint lines kept as a fallback. stdout can
    silently truncate on process teardown — 21/mutation_5 e0 logged `ok=True perf_lines=18`
    while the VM stream had all 30 — so the structured stream leads and stdout backs it up.
    """
    return device_dir(group) / "raw"


def capture_dir(session: str, group: str, role: str) -> Path:
    return raw_dir(group) / session / role


# ---- Telemetry: one flat CSV per session, split per execution alongside it ----
# `devices/lib/measure.sh` samples battery/thermals every SAMPLE_SECS for the whole runner
# session and appends to telemetry-<session>.csv. That file stays the write path and the raw
# record; `python -m scripts.device_runner telemetry` derives the per-execution tree next to
# it, so a buildSpan median can be joined to the thermal trajectory it was measured under
# instead of only to a session-wide average.
#
#   dataset/<group>/<device>/telemetry/telemetry-<session>.csv   flat, written live
#   dataset/<group>/<device>/telemetry/<session>/<role>/e<k>.csv  derived, per execution
#   dataset/<group>/<device>/telemetry/<session>/index.jsonl      derived, one row per execution
#   dataset/<group>/<device>/telemetry/<session>/_unassigned.csv  derived, rows in no window


def telemetry_dir(group: str) -> Path:
    return device_dir(group) / "telemetry"


def session_telemetry_csv(group: str, session: str) -> Path:
    return telemetry_dir(group) / f"telemetry-{session}.csv"


def split_telemetry_dir(group: str, session: str) -> Path:
    return telemetry_dir(group) / session


def run_telemetry_csv(group: str, session: str, role: str, exec_index: int) -> Path:
    return split_telemetry_dir(group, session) / role / f"e{exec_index}.csv"


# ---- Browsable mirror of the VM captures: spm/<device>/<group>/<role>/e<k>.jsonl ----
# A convenience view, not the record: the dataset copy under raw/<session>/ is what `parse`
# reads and what ships in the replication package. The mirror is flat (no session segment),
# so re-measuring a target overwrites its file here while every session stays intact in the
# dataset. `spm/` is the SPM CLI's own default output dir and is NOT per-device, hence the
# <device> segment — without it two phones would write the same paths.
PROFILER_MIRROR_ROOT = PROJECT_ROOT / "spm"


def device_slug() -> str:
    """Path-safe device id for the mirror. `devices/lib/root.sh` exports BENCH_DEVICE_ID
    (e.g. `redmi9t`) after preflight; a bare `python -m scripts.device_runner run`
    has neither var and is labelled rather than allowed to claim a device."""
    raw = os.environ.get("BENCH_DEVICE_ID", "").strip() or os.environ.get(
        "BENCH_DEVICE_LABEL", ""
    ).strip()
    slug = re.sub(r"[^A-Za-z0-9._-]+", "-", raw).strip("-").lower()
    return slug or "unrecorded-device"


def mirror_path(group: str, role: str, exec_index: int) -> Path:
    return PROFILER_MIRROR_ROOT / device_slug() / group / role / f"e{exec_index}.jsonl"

STATIC_NAME = "static.jsonl"  # per TARGET: sample_id + AST features
REBUILDS_NAME = "rebuilds.jsonl"  # per REBUILD (inner): raw buildspan_us
PERFORMANCE_NAME = "performance.jsonl"  # per EXECUTION (outer): median + readings + status


def static_path(group: str) -> Path:
    """Device-INDEPENDENT: one copy per group, above the device segment."""
    return group_dir(group) / STATIC_NAME


def rebuilds_path(group: str) -> Path:
    return device_dir(group) / REBUILDS_NAME


def performance_path(group: str) -> Path:
    return device_dir(group) / PERFORMANCE_NAME


def group_dirs() -> list[Path]:
    """Numeric group dirs present in the dataset root (skips _meta and any stray file)."""
    if not OUT_DIR.exists():
        return []
    return sorted(d for d in OUT_DIR.iterdir() if d.is_dir() and d.name.isdigit())

def _env_int(name: str, default: int) -> int:
    """Per-device protocol override, read from the environment.

    The two reference devices run genuinely different protocols: the default protocol is stock and
    charge-on, the rooted Redmi 9T cuts charge input outright. A constant tuned for one is
    wrong -- sometimes fatally -- on the other. Pause-to-charge is the clearest case: under
    `input_suspend=1` the battery level can never rise, so the wait blocks for
    BATTERY_CHARGE_STALL_S and then aborts every long session. `devices/<id>/run.sh` exports
    only the overrides it needs; every default below stays the default-protocol value, so the unrooted
    path is unchanged.
    """
    raw = os.environ.get(name, "").strip()
    if not raw:
        return default
    try:
        return int(raw)
    except ValueError:
        return default


def _env_bool(name: str, default: bool) -> bool:
    raw = os.environ.get(name, "").strip().lower()
    if not raw:
        return default
    if raw in {"1", "true", "yes", "on"}:
        return True
    if raw in {"0", "false", "no", "off"}:
        return False
    return default


# ---- Measurement protocol constants ----
N_EXECUTIONS = 5  # outer independent relaunches per target (literature floor: Alshoaibi)
N_REBUILDS = 30  # inner rebuilds per execution (Chen PerfJIT)
WARMUP_DISCARD = 10  # first K rebuilds dropped before taking the median (hw/OS steady-state ramp)
SEED = 42  # interleave shuffle seed (logged for reproducibility)
SPM_RUN_TIMEOUT_S = _env_int("BENCH_SPM_RUN_TIMEOUT_S", 0)  # 0 = no per-execution timeout
# A timed-out `spm run` is a device-side hang (app never publishes its VM service URI), not a
# property of the sample: the same execution passes on a retry once the stale toolchain +
# app process are killed. Retry it in place instead of killing a multi-hour session; only a
# target that hangs SPM_RUN_ATTEMPTS times in a row is treated as unmeasurable and aborts.
SPM_RUN_ATTEMPTS = max(1, _env_int("BENCH_SPM_RUN_ATTEMPTS", 3))
# Consecutive executions yielding ZERO readings before the session gives up. The schedule is
# interleaved, so these are consecutive different targets — a run of them is a systematic break
# (integration test not compiling, wrong Flutter, dead adb), never a property of one sample. A
# single weak capture is still tolerated; the point is to not spend hours on a broken build.
WEAK_CAPTURE_ABORT = max(1, _env_int("BENCH_WEAK_CAPTURE_ABORT", 3))
# Failed executions of ONE role before that role is quarantined: its remaining executions are
# dropped and the session carries on with the others. A role that cannot compile or cannot
# mount fails identically every time, and the interleaved schedule hands it back every few
# executions, so without this it eats the WEAK_CAPTURE_ABORT budget and takes the whole
# session — and, through `devices/lib/pipeline.sh`, every group queued behind it — with it.
# 2, not 1: one weak capture is still allowed to be a transient.
ROLE_WEAK_LIMIT = max(1, _env_int("BENCH_ROLE_WEAK_LIMIT", 2))
# App under test — force-stopped between a timeout and its retry so the next `flutter drive`
# attaches to a fresh process instead of a wedged one holding the VM service port.
APP_PACKAGE = os.environ.get("BENCH_PKG", "").strip() or "com.example.benchmark_container"
RECOVER_SETTLE_S = _env_int("BENCH_RECOVER_SETTLE_S", 5)  # quiet time after a device recovery
# Set BENCH_RESOLVE_PUB_PER_EXEC=1 to restore the old per-execution `flutter pub get` (only
# needed if something outside the runner rewrites pubspec.yaml mid-session).
RESOLVE_PUB_PER_EXEC = _env_bool("BENCH_RESOLVE_PUB_PER_EXEC", False)
WAKE_BEFORE_EXEC = _env_bool("BENCH_WAKE_BEFORE_EXEC", False)
SCREEN_OFF_TIMEOUT_MS = _env_int("BENCH_SCREEN_OFF_TIMEOUT_MS", 2147483647)

# ---- Cooldown (thermal gate between executions) ----
THERMAL_ZONE_GLOB = "/sys/class/thermal/thermal_zone*/temp"  # milli-degrees C
# between-exec cooldown gate; raised 45->55 °C (2026-07-19): the earlier pilot phone's measured knee was 78 °C
# (cpu-1-7-usr), so 55 leaves ~23 °C headroom and cuts waiting. Dataset shows no throttling to
# 60 °C (buildSpan is *negatively* correlated with temp). TUNED PER DEVICE — this value belongs
# to that phone's knee and does NOT transfer; the Redmi exports BENCH_COOLDOWN_TEMP_MILLIC from
# its own calibrated knee.
COOLDOWN_TEMP_MILLIC = _env_int("BENCH_COOLDOWN_TEMP_MILLIC", 55000)
COOLDOWN_MAX_WAIT_S = 120  # give up waiting after this (non-root / unreadable zone)
COOLDOWN_POLL_S = 3

# ---- Pre-run device health gates (checked before every execution) ----
BATTERY_BAND_PCT = (30, 85)  # charge-on protocol band (2026-07-19); outside -> warn (does not abort)
# below this -> stop the session: low battery changes DVFS/thermal behaviour. Under a charge
# cut this is the ONLY battery stop, so the Redmi raises it to the protocol band floor (30).
BATTERY_ABORT_PCT = _env_int("BENCH_BATTERY_ABORT_PCT", 25)

# ---- Pause-to-charge (keeps a session in-band instead of aborting) ----
# When the TRUE fuel-gauge level (sysfs, immune to `dumpsys battery unplug`) drops below
# PAUSE, block and let the phone charge (VBUS still flows through the adb cable) until it
# climbs back to RESUME, then cooldown and continue. Hysteresis stops flapping at the edge.
# NOTE: in charge-on mode (weak USB trickle) the battery net-RISES ~+5-9%/session, so this
# rarely triggers — the ceiling is the binding bound. Band widened 60-80 -> 30-85 (2026-07-19).
# Set BENCH_BATTERY_PAUSE_PCT=0 to disable pause-to-charge entirely — mandatory under
# POWER_MODE=suspend, where the level only ever falls and the wait could never succeed.
BATTERY_PAUSE_PCT = _env_int("BENCH_BATTERY_PAUSE_PCT", 30)  # pause the session below this true level
BATTERY_RESUME_PCT = _env_int("BENCH_BATTERY_RESUME_PCT", 85)  # resume once the level climbs back
BATTERY_CHARGE_POLL_S = 30  # poll interval while paused, waiting to charge
BATTERY_CHARGE_STALL_S = 600  # if the level hasn't risen in this long -> not charging, abort
# True fuel-gauge level, read straight from the kernel; unaffected by the unplug override.
BATTERY_CAPACITY_SYSFS = "/sys/class/power_supply/battery/capacity"

# ---- Cliff's delta magnitude thresholds (Romano et al. 2006) ----
CLIFF_SMALL = 0.147
CLIFF_MEDIUM = 0.33
CLIFF_LARGE = 0.474

# The role prefix that identifies the base target inside each samples/<group>/ dir.
BASE_ROLE = "base"
MUTATION_PREFIX = "mutation_"


def spm_analyze_cmd(paths: list[str], output: str) -> list[str]:
    """`spm analyze <paths> -o <output>` — one JSONL row per State class found.

    NOTE on `filePath`: the analyzer relativizes it against the *analysis root it picked*,
    not the repo root. Passing `samples/` yields `01/base.dart`; passing the repo root
    yields `samples/01/base.dart`. `instanceId` is hashed from that same relative path, so
    the root also decides the id. Callers must therefore key off the path TAIL, and must
    not assume an id extracted under one root matches one extracted under another.

    NOTE on `--scope-types`: 0.3.0 emits a row for EVERY rebuild scope by default (nested
    Obx/Selector/BlocBuilder callbacks alongside the root State), and those rows' metrics
    deliberately overlap the enclosing State's. This corpus measures the transplanted
    `_GeneratedWidgetState` and nothing else, so the analyzer is pinned to `State` — which is
    also exactly the pre-0.3.0 output shape.
    """
    return spm.analyze_state_cmd(paths, output)


def spm_extract_cmd() -> list[str]:
    """Whole-project analyze -> STATIC_FILE. Only used to bootstrap the injection identity
    (the `instanceId`/`filePath` of the transplant slot) on a cold checkout; per-target
    feature extraction runs in place against `samples/` instead."""
    return spm_analyze_cmd([str(PROJECT_ROOT)], str(STATIC_FILE))


def shots_dir(group: str) -> Path:
    """Where this group's diagnostic images live, beside its captures and telemetry.

    One image per ROLE, not per execution: the fixture and the transplant are identical
    across a role's executions, so the 2nd through 15th would be the same picture.
    """
    return OUT_DIR / group / device_slug() / "shots"


def spm_run_cmd(output_path: str, shot_name: str | None = None,
                dump_errors: bool = False) -> list[str]:
    """`spm run`: inject SpmState from STATIC_FILE -> flutter drive -> revert.

    `spm run` auto-adds `--profile` (required by the profiler) and the SpmState
    trigger routes through the buildSpan monitor at runtime in profile mode.
    `SPM_REBUILDS` is read by the integration test to size the inner loop.

    `-o` pins the VM-service capture to this execution's own file. Without it `spm run`
    defaults to `spm/profiler_<timestamp>.jsonl` in the cwd — which is why ~1700 of them
    accumulated there carrying no sample_id, unmappable to the target that produced them.
    """
    return [
        *spm.entry("run"),
        "--jsonl",
        str(STATIC_FILE),
        "--repo",
        str(PROJECT_ROOT),
        "--output",
        output_path,
        "--flutter",
        "drive",
        # `flutter drive` re-resolves dependencies on EVERY invocation (~5 s of "Resolving
        # dependencies / Downloading packages" per execution, ~11 min per 135-execution
        # group). pubspec.yaml never changes during a session and the runner does one
        # `flutter pub get` before phase 2, so this is pure repeated work. It happens before
        # the app is built or launched, so it cannot touch the measurement itself.
        *([] if RESOLVE_PUB_PER_EXEC else ["--no-pub"]),
        f"--driver={INTEGRATION_DRIVER}",
        f"--target={INTEGRATION_TEST}",
        "--no-dds",
        f"--dart-define=SPM_REBUILDS={N_REBUILDS}",
        # Diagnostic image, opt-in per execution. `bool.fromEnvironment` is a COMPILE-TIME
        # constant on the Dart side, so omitting these leaves the capture block tree-shaken
        # out of the profile build -- the measured binary is identical to one built before
        # the feature existed. Never pass them for an execution whose numbers are being kept
        # unless you have read the note in `integration_test.dart` about why it is safe.
        *([] if shot_name is None else [
            "--dart-define=SPM_SHOT=true",
            f"--dart-define=SPM_SHOT_NAME={shot_name}",
        ]),
        # Full framework errors, opt-in per execution and compile-time on the Dart side for
        # the same reason. UNLIKE the screenshot this one is NOT safe during a measured
        # span: `FlutterError.onError` runs on the UI thread, so printing from it adds work
        # to the very frames being timed. An execution carrying it is a DIAGNOSTIC and its
        # numbers must not be parsed -- `runner --dump-errors` says so and forces a session
        # name of its own.
        *([] if not dump_errors else ["--dart-define=SPM_DUMP_ERRORS=true"]),
    ]

# Arm 2 (`new_samples/`) roles: `rev_<ordinal>_<sha8>`. The filename suffix IS the commit sha.
REVISION_PREFIX = "rev_"
