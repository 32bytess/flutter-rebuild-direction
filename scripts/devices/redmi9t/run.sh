#!/usr/bin/env bash
#
# redmi9t/run.sh — ROOTED (Magisk) buildSpan pipeline for the Xiaomi Redmi 9T
#                  (Snapdragon 662 / SM6115, codename "lime"). PRIMARY measurement device.
#
# This is a THIN device-config wrapper: it sets the Redmi-specific knobs, then hands off to
# the shared engine in ../lib/pipeline.sh, which runs every methodology stage in order
# (resolve knee → prep → ROOT PREP → preflight → telemetry-wrapped measure → parse → label
# → restore). All stage logic lives once under ../lib/; the root controls live in ../lib/root.sh.
#
# ─ How this differs from the unrooted pilot phone's setup ─
#   • PHYSICAL DVFS control, not statistical: governor=performance with scaling_min==scaling_max
#     pinned on the big cluster, so clocks cannot ramp *during* a rebuild burst.
#   • cpuset isolation: top-app gets ONLY the big cores; every other cpuset is pushed onto the
#     little cores, so background work cannot preempt the Flutter UI thread.
#   • A REAL charge cut (input_suspend=1), not the report-only `dumpsys battery unplug` fake —
#     charger heat and PMIC current leave the measurement entirely. The battery genuinely
#     drains, and PREFLIGHT gates on that (see POWER_MODE=suspend in ../lib/preflight.sh).
#   • EXECUTIONS defaults to 15, not 5. At n=5 an A–A null pair is mislabelled "Slower" 21.0 %
#     of the time under the |δ|>0.33 rule (exact enumeration over all C(10,5)=252 splits);
#     at n=15 that floor drops to ~6.4 %. This is the whole point of the rooted campaign.
#   • Its own dataset root, `dataset-redmi9t/` — see BENCH_DATASET_DIR below.
#
# ─ THE TWO DEVICES CANNOT BE MEASURED CONCURRENTLY FROM ONE CHECKOUT ─
# `lib/generated_widget.dart`, the repo-root `static.jsonl` and `scripts/device_runner/
# static_cache/` are shared regardless of BENCH_DATASET_DIR. Finish one device's session
# before starting the other's.
#
# Usage (run from anywhere; paths self-resolve):
#   CALIBRATE=1 FIND_KNEE=1 ./devices/redmi9t/run.sh 01   # calibration session (do this FIRST)
#   ./devices/redmi9t/run.sh 03                           # one group, n=15, rooted protocol
#   EXECUTIONS=5 ./devices/redmi9t/run.sh 03              # override the execution count
#   USE_ROOT=0 ./devices/redmi9t/run.sh 03                # deliberately fall back to unrooted
#   ASSUME_YES=1 ./devices/redmi9t/run.sh 03              # no interactive prompts
#   SCREENSHOTS=1 ./devices/redmi9t/run.sh 03             # + one diagnostic PNG per role
#   ./devices/redmi9t/run.sh --resume 03                  # CONTINUE 03's existing session
#
# --resume is what to reach for after an interrupted (or a finished-but-short) group: it keeps
# writing into that group's existing raw/<session>/ and measures ONLY the executions missing from
# it. Without it a group whose session is already complete — or one where nothing completed at
# all — starts a new session dir and re-measures every execution from zero. `--fresh` forces that
# new dir; BENCH_RAW_SESSION=<stamp> still pins one exact session by hand.
#
# SCREENSHOTS=1 writes dataset*/<group>/redmi9t/shots/<group>__<role>.png, one image per
# ROLE (not per execution), captured strictly after the measured span. It is the only
# check that catches a fixture which mounts but renders nothing -- 0792's empty map, or
# 1860's Color where the revisions index a List. Off by default because the one execution
# carrying the shot is compiled with SPM_SHOT=true and the other 14 are not;
# integration_test.dart says why that cannot move a buildSpan.
#
# ─ WHICH CORPUS (arm 1 vs arm 2) ─
#   ./devices/redmi9t/run.sh --samples-root new_samples 0058   # arm 2, one scope
#   ./devices/redmi9t/run.sh --samples-root new_samples --dataset-dir dataset-arm2 0058
#   ./devices/redmi9t/run.sh --samples-root new_samples --resume 0058   # continue arm 2's session
# The dataset root DERIVES from the corpus unless --dataset-dir overrides it: `samples` ->
# `dataset/`, `new_samples` -> `dataset-new_samples/`. Do not point two corpora at one root —
# `_meta/<device>/manifest.json` is keyed by device alone, so the second arm measured would
# overwrite the first's manifest. `--eligible-only` turns itself on for any corpus carrying an
# `exclusions.json`, so an arm-2 run measures the endpoints of the eligible contrasts and not
# the revisions that were screened but never selected; `--no-eligible-only` opts out.
#
# Measure ONE GROUP PER SESSION — never `all`. A group at n=15 is 9 targets × 15 = 135
# executions (~4.5 h), and each non-`all` group is its own runner session, which bounds the
# blast radius of an abort (a partial rerun would otherwise truncate a complete group).
#
# Device-specific env: REDMI_SERIAL (serial if >1 device); PIN_FREQ_KHZ (the frozen pinned
# frequency — REQUIRED outside calibration, see below); REDMI_THERMAL_NAME (CPU sensor name);
# KNEE_C (measured throttle knee). Shared knobs are documented in ../lib/pipeline.sh.

DEVICE_ID="redmi9t"
DEVICE_MODEL_LABEL="Xiaomi Redmi 9T (Snapdragon 662 / SM6115, rooted with Magisk)"
MODEL_PROP="ro.product.device"
DEVICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SERIAL_ENVS=(REDMI_SERIAL DEVICE_SERIAL)
SERIAL_HINT="set REDMI_SERIAL"

# ── dataset namespacing ────────────────────────────────────────────────────
# The rooted Redmi corpus is a DIFFERENT EXPERIMENT from an unrooted-phone corpus: different SoC
# (buildSpan is not comparable across SoCs), different power/DVFS protocol, different n. They
# must never share a FILE — but they now share the dataset ROOT and are separated one level
# down, by the <device> segment that `device_slug()` derives from DEVICE_ID:
#
#   dataset/<group>/static.jsonl          shared (static features are device-independent)
#   dataset/<group>/redmi9t/...           this phone's measurements
#
# So BENCH_DATASET_DIR is deliberately NOT set here: both corpora live under `dataset/`, side
# by side per sample, and `parse` only ever rewrites this device's files. Set it only for a
# scratch root (a dry run you intend to throw away).

# ── root protocol (see ../lib/root.sh) ─────────────────────────────────────
USE_ROOT="${USE_ROOT:-1}"           # 1 = REQUIRE root; die rather than silently degrade to the unrooted path
POWER_MODE="${POWER_MODE:-suspend}" # real input_suspend charge cut, not `dumpsys battery unplug`
BIG_CORES="${BIG_CORES:-4 5 6 7}"   # SD662: cpu0-3 silver A53, cpu4-7 gold A73
GOV_PIN="${GOV_PIN:-1}"
CPUSET_ISOLATE="${CPUSET_ISOLATE:-1}"
QUIET_INSTALL="${QUIET_INSTALL:-1}" # MIUI 'Install via USB?' dialog blocks unattended reinstalls

# Vendor DVFS daemons stopped for the duration of the session (restarted on restore).
# MEASURED on this unit: with perf-hal-2-2 running, a pin at 1804800 was overwritten back to
# the cluster max within seconds AND the release was re-asserted back to pinned — the phone
# ended up silently stuck at a fixed frequency. With both stopped the pin held exactly, and
# released cleanly. Independently of that, these daemons ARE uncontrolled DVFS: boosting
# clocks because "an app looks busy" is the confound this whole protocol exists to remove.
# thermal-engine / mi_thermald are deliberately NOT in this list — the throttle knee must stay
# the device's natural behaviour.
PERF_DAEMONS="${PERF_DAEMONS:-perf-hal-2-2 miuibooster}"

# THE PINNED FREQUENCY IS PART OF THE MEASUREMENT CONDITION — FROZEN, do not change it
# mid-corpus (like the Flutter version, changing it starts a new condition).
#
# MEASURED on this unit (2026-07-27, fanless, 4 busy loops pinned to cpu4-7):
#   gold scaling_available_frequencies = 300000 652800 902400 1056000 1401600 1536000
#                                        1612800 1804800 2016000
#   at 2016000: 81.9 -> 86.2 °C over 50 s, then the SoC throttled itself to 1804800.
#   at 1804800: PLATEAUED at 77.0-77.3 °C from t=80s to t=120s — a genuine steady state,
#               ~9 °C under the knee, with no further step-down.
# So 2016000 is unsustainable by ~1 minute and 1804800 is the highest frequency that holds
# flat. A permanently sub-knee pin is also what keeps the between-execution cooldown gate
# from firing, the main lever on session wall clock (4.5 h/group at n=15).
PIN_FREQ_KHZ="${PIN_FREQ_KHZ:-1804800}"

# ── measurement protocol ───────────────────────────────────────────────────
# 15 executions per target: drops the A–A false-"Slower" floor from 21.0 % (n=5) to ~6.4 %,
# gives Cliff's δ a 1/225 grid instead of 1/25, and makes the Mann-Whitney p-value usable as
# real corroboration (min two-sided p 3.1e-6 vs 9.0e-3 at n=5).
EXECUTIONS="${EXECUTIONS:-15}"

# Under a charge cut the battery only ever falls, so pause-to-charge can never succeed: it
# would block for BATTERY_CHARGE_STALL_S (10 min) and then abort every long session. Disable
# it and let the hard abort floor be the only battery stop. (Read by scripts/device_runner/
# config.py; the default unrooted path keeps the defaults because it does not export these.)
# (Skipped under USE_ROOT=0: root.sh will downgrade POWER_MODE to charge_on, and on a charging
# phone pause-to-charge is useful again.)
if [[ "$POWER_MODE" == "suspend" && "$USE_ROOT" != "0" ]]; then
	export BENCH_BATTERY_PAUSE_PCT="${BENCH_BATTERY_PAUSE_PCT:-0}" # 0 = never pause to charge
	export BENCH_BATTERY_ABORT_PCT="${BENCH_BATTERY_ABORT_PCT:-30}"
fi
# Between-execution cooldown gate. The default gate is tuned to another phone's knee and is not
# transferable. For this device the gate is set below its calibrated knee, which is stored in
# the .knee-<serial> file next to this script (the only record of the value).
# Lower = more waiting; at 4.5 h/group this gate is the main wall-clock lever, so re-tune it
# after the first full session if it fires often (the fanless 100 %-duty plateau was 77 °C,
# and a rebuild benchmark with cooldowns is far lighter than that).
export BENCH_COOLDOWN_TEMP_MILLIC="${BENCH_COOLDOWN_TEMP_MILLIC:-63000}"

# MIUI can still blank/lock the display during a real charge cut because the phone reports
# discharging, even with `svc power stayon true`. Wake/dismiss keyguard before every profiled
# execution, keep the screen timeout effectively infinite for the session, and abort one
# stuck `spm run` instead of letting the whole group sit forever. Completed executions remain
# resumable; the timed-out one is marked incomplete and retried on the next run.
export BENCH_WAKE_BEFORE_EXEC="${BENCH_WAKE_BEFORE_EXEC:-1}"
export BENCH_SPM_RUN_TIMEOUT_S="${BENCH_SPM_RUN_TIMEOUT_S:-300}"
SCREEN_OFF_TIMEOUT_MS="${SCREEN_OFF_TIMEOUT_MS:-2147483647}"

# ── thermal / knee ─────────────────────────────────────────────────────────
# NO conservative default knee (the old KNEE_DEFAULT=85 was paired with the engine's "hottest
# of ALL zones" fallback, which mixes in battery/PMIC/charger sensors). The knee is gated
# against ONE named CPU sensor, so it must be MEASURED against that same sensor.
#
# The knee is measured on hepta-cpu-max-step by the knee finder (FIND_KNEE=1, fan off), which
# caches it in .knee-<serial> next to this script. That file is the only record of the value;
# the engine then gates at KNEE_C minus KNEE_MARGIN_C.
# Re-measure with the app workload any time via:  FIND_KNEE=1 ./devices/redmi9t/run.sh 01
KNEE_DEFAULT="${KNEE_DEFAULT:-}"
SOC_ABORT_C="${SOC_ABORT_C:-95}"
CLUSTER_LABEL="big cluster (4× Kryo 260 Gold / A73, cpu4-7 @ 2.016 GHz)"

# CONFIRMED µA on this unit (2026-07-27): ~600000 = 600 mA while discharging.
# NB current_now here is UNSIGNED — positive both while charging (~95-141 mA) and while
# discharging (~590-724 mA) — so it carries NO direction information and preflight only
# reports it. The charge cut is gated on `status` and on the input_suspend read-back instead.
CURRENT_UNIT="${CURRENT_UNIT:-uA}"
PIN_60HZ=0 # 60 Hz panel, no adaptive refresh to pin

# ── MIUI bloat / background-wakeup sources to neutralise (reversible, per-user) ──
BLOAT_LABEL="MIUI bloat"
BLOAT_PKGS=(
	com.miui.msa.global   # MIUI System Ads
	com.xiaomi.mipicks    # GetApps store
	com.miui.analytics    # analytics
	com.miui.cloudservice # Mi Cloud sync
)

PREP_MANUAL=(
	"ON-DEVICE, once (no adb equivalent) — the FIRST three stop the MIUI 'Install via USB?' popup:"
	"  Developer options → USB debugging (Security settings) ON · Install via USB ON · MIUI optimization OFF (reboot)"
	"  Background process limit = No background processes · Memory extension (virtual RAM) OFF · app Battery = No restrictions"
	"  Magisk → Superuser → grant 'Shell' (run 'adb shell su -c id' once and ACCEPT the dialog)"
)
PREFLIGHT_MANUAL=(
	"CANNOT auto-check — confirm by hand: fan ON, phone flat/back-uncovered; cable in a PC USB data port."
	"  Under POWER_MODE=suspend the cable carries DATA ONLY — the battery is meant to fall through the session."
)
ACCEPTANCE_EXTRA="FREQUENCY AUDIT: scaling_cur_freq must equal the pin for the WHOLE session — any drop means throttling or a pin that did not hold, and the session is DISCARDED."

# ── gate: the pinned frequency must be frozen before any dataset session ───
# Without this, root.sh silently falls back to cpuinfo_max_freq, which throttles on this SoC —
# and a corpus measured at a drifting pin is not comparable with itself. Calibration sessions
# (CALIBRATE=1 / FIND_KNEE=1 / RECALIBRATE=1) are exempt: finding the sustainable pin is
# precisely what they are for.
if [[ -z "${PIN_FREQ_KHZ:-}" && "${GOV_PIN:-1}" == "1" && "${USE_ROOT:-1}" != "0" &&
	"${CALIBRATE:-0}" != "1" && "${FIND_KNEE:-0}" != "1" && "${RECALIBRATE:-0}" != "1" ]]; then
	printf '\n\033[31m✗ PIN_FREQ_KHZ is not set — refusing to measure a dataset group.\033[0m\n' >&2
	printf '  The pinned frequency is part of the measurement condition and must be FROZEN for\n' >&2
	printf '  the whole corpus. Falling back to cpuinfo_max_freq would throttle on the SD662.\n' >&2
	printf '  Do ONE of:\n' >&2
	printf '    • run the calibration session first:  CALIBRATE=1 FIND_KNEE=1 ./devices/redmi9t/run.sh 01\n' >&2
	printf '      then read  adb shell cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_available_frequencies\n' >&2
	printf '      and hardcode the chosen value as PIN_FREQ_KHZ in this file, or\n' >&2
	printf '    • pass it explicitly:  PIN_FREQ_KHZ=1804800 ./devices/redmi9t/run.sh %s\n\n' "${1:-01}" >&2
	exit 1
fi

# ── pin the CPU thermal zone by NAME, not by index (the same rule as the default unrooted path) ──
# The shared engine's fallback reads the hottest of ALL zones, which on this SoC catches
# battery / PMIC / charger sensors and false-aborts the knee finder. KNEE_C and THERMAL_ZONE
# are a MATCHED PAIR: the cached knee (.knee-<serial>) is the temperature THIS sensor reads at
# throttle onset, and is meaningless gated against any other. So: resolve by name, and
# HARD-ABORT if the selected index does not read that name — a cached knee must never silently
# guard the wrong sensor. Skipped while (re)calibrating or when KNEE_C was passed explicitly,
# since then you own the pairing.
#
# SENSOR CHOICE (measured 2026-07-27 under a 4-core soak on cpu4-7). Unlike an earlier phone's lone
# prime core, the gold cluster here is FOUR SYMMETRIC A73s and the UI thread may land on any
# of them, so no single core sensor is the right gate. `hepta-cpu-max-step` is the SoC's own
# CPU-max aggregate: it read >= every one of cpu-1-{0..3}-usr and cpuss-{0..2}-usr at EVERY
# sample (peak 86.2 vs 85.9 on the hottest core), and being a CPU-only aggregate it cannot
# pick up the battery/PMIC/charger zones the "hottest of all zones" fallback would.
# Fallbacks, in order, are the two hottest gold-core sensors observed. Re-list with:
#   adb shell 'for z in /sys/class/thermal/thermal_zone*; do echo "$z $(cat $z/type)"; done'
# (core.sh isn't sourced yet here, so this uses printf/exit directly.)
_r9t_ser="${REDMI_SERIAL:-${DEVICE_SERIAL:-}}"
_r9t_adb() { adb ${_r9t_ser:+-s "$_r9t_ser"} "$@"; }
_r9t_names="${REDMI_THERMAL_NAME:-hepta-cpu-max-step cpu-1-2-usr cpu-1-3-usr}"
if [[ -z "${THERMAL_ZONE:-}" ]]; then
	for _r9t_n in $_r9t_names; do
		THERMAL_ZONE="$(_r9t_adb shell "
			for z in /sys/class/thermal/thermal_zone*; do
				[ \"\$(cat \"\$z/type\" 2>/dev/null)\" = $_r9t_n ] && echo \"\${z##*thermal_zone}\" && break
			done" 2>/dev/null | tr -d '\r')"
		[[ -n "$THERMAL_ZONE" ]] && REDMI_THERMAL_NAME="$_r9t_n" && break
	done
fi
_r9t_got="$(_r9t_adb shell "cat /sys/class/thermal/thermal_zone${THERMAL_ZONE:--1}/type 2>/dev/null" 2>/dev/null | tr -d '\r')"
if [[ -z "${KNEE_C:-}" && "${FIND_KNEE:-0}" != "1" && "${RECALIBRATE:-0}" != "1" ]]; then
	if [[ -z "$THERMAL_ZONE" ]]; then
		printf '\n\033[31m✗ Could not resolve a CPU thermal zone by name (tried: %s).\033[0m\n' "$_r9t_names" >&2
		printf '  The knee would then be gated against the hottest of ALL zones — including\n' >&2
		printf '  battery/PMIC/charger sensors, which false-abort the run. List the real names with:\n' >&2
		printf '    adb shell '\''for z in /sys/class/thermal/thermal_zone*; do echo "$z $(cat $z/type)"; done'\''\n' >&2
		printf '  then re-run with REDMI_THERMAL_NAME=<name> (and record it in this file).\n\n' >&2
		exit 1
	elif [[ -n "$_r9t_got" && "$_r9t_got" != "${REDMI_THERMAL_NAME:-}" ]]; then
		printf '\n\033[31m✗ SENSOR MISMATCH: THERMAL_ZONE=%s reads "%s", not the expected %s.\033[0m\n' \
			"$THERMAL_ZONE" "$_r9t_got" "${REDMI_THERMAL_NAME:-<unset>}" >&2
		printf '  The cached knee (.knee-%s) was measured on %s and would gate the WRONG sensor.\n' \
			"${_r9t_ser:-<serial>}" "${REDMI_THERMAL_NAME:-<unset>}" >&2
		printf '  Do ONE of:\n' >&2
		printf '    • unset THERMAL_ZONE so it auto-resolves by name, or\n' >&2
		printf '    • recalibrate for THIS sensor:  FIND_KNEE=1 ./devices/redmi9t/run.sh %s, or\n' "${1:-01}" >&2
		printf '    • pass a KNEE_C you measured on zone%s explicitly.\n\n' "$THERMAL_ZONE" >&2
		exit 1
	fi
fi

source "$DEVICE_DIR/../lib/pipeline.sh" "$@"
