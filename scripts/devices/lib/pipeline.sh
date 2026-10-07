#!/usr/bin/env bash
# lib/pipeline.sh — the shared charge-on buildSpan pipeline, sourced by each device's
# thin run.sh AFTER it has set its device-config variables. One command, every stage:
#
#   0. RESOLVE KNEE   env > opt-in auto-find (fan off) > cache > device default (or die)
#   1. PREP           airplane, animations, brightness, stay-awake, bg-kill, bloat, [60 Hz], wl
#   1b. ROOT PREP     (rooted devices only, no-op otherwise) DVFS pin, cpuset isolation,
#                     real input_suspend charge cut, quiet-install knobs — see lib/root.sh
#   2. PREFLIGHT      hard gate: charge state (mode-aware) + battery band + SoC < knee−margin +
#                     app installed + [governor pin / cpuset / charge cut actually applied] …
#   3. MEASURE        telemetry-wrapped `device_runner run` (SPM extract → inject → profile drive)
#   4. PARSE          drop warmups/misses → median buildSpan → performance.jsonl (every
#                     execution, `status` marking the ones flutter drive reported failed)
#   5. RESTORE        (always, via EXIT trap) + prints the two manual acceptance gates
#
# Labelling is NOT a stage: base-vs-mutation contrasts are decided in the analysis path
# (analysis/01_data_and_labels.ipynb), not on the device.
#
# The Python engine (`python -m scripts.device_runner`) is unchanged — this only folds the
# device-side bash stages around it. Each phone differs ONLY in the config block its run.sh
# sets before sourcing this file; the stage logic lives once in the sibling lib/*.sh files.
#
# Required from the device run.sh:  DEVICE_ID DEVICE_MODEL_LABEL MODEL_PROP DEVICE_DIR
#   SERIAL_ENVS[] SERIAL_HINT  KNEE_DEFAULT SOC_ABORT_C CLUSTER_LABEL  CURRENT_UNIT THERMAL_ZONE
#   PIN_60HZ  BLOAT_LABEL BLOAT_PKGS[]  PREP_MANUAL[] PREFLIGHT_MANUAL[]  ACCEPTANCE_EXTRA(opt)
#
# Optional root/dataset knobs a run.sh may also set (defaults keep the unrooted path exactly
# as it was):  USE_ROOT(auto) POWER_MODE(charge_on) GOV_PIN PIN_FREQ_KHZ BIG_CORES
#   CPUSET_ISOLATE QUIET_INSTALL  BENCH_DATASET_DIR(dataset)
#
# ─ WHICH CORPUS, AND WHERE IT LANDS (flags, not env — see the parser below) ─
#   --samples-root DIR   corpus to measure, relative to the repo root. Default `samples`
#                        (arm 1). `new_samples` is arm 2, whose roles are rev_<n>_<sha8>.
#   --dataset-dir DIR    where measurements are written. Default is DERIVED from the corpus:
#                        `samples` -> `dataset`, any other root X -> `dataset-X`. The two arms
#                        must not share a root: dataset/_meta/<device>/manifest.json is keyed
#                        by device only, so a second arm would overwrite the first's manifest.
#   --eligible-only / --no-eligible-only
#                        measure only the revisions that are an endpoint of an eligible
#                        contrast, per <corpus>/exclusions.json. Defaults to ON exactly when
#                        that file exists, so arm 1 (which has no screening record) is
#                        unaffected and arm 2 does not spend device time on the revisions
#                        that were screened but never selected.
#   --resume             CONTINUE this group's existing raw/<session>/ instead of minting a new
#                        stamp: completed executions are skipped and only the missing ones are
#                        measured. Without it a session that is already COMPLETE, or one where
#                        nothing completed at all, starts a fresh dir and re-measures everything
#                        (that is the default, unchanged). The session continued is the group's
#                        MOST COMPLETE one, newest breaking a tie — `device_runner status
#                        --pick-session` decides, so "done" keeps one definition.
#                        Raising EXECUTIONS and re-running with --resume tops the SAME session up
#                        (n=15 -> n=20 measures e15..e19 only).
#                        `--resume all` is the CAMPAIGN form: it expands to every group id under
#                        the corpus, sorted, and runs them one session each -- NOT the blended
#                        single session bare `all` means. A plan pass (stage 0a) asks
#                        `device_runner status --all --best` once, before the device is touched,
#                        and drops the groups that are already complete, so re-running the same
#                        command after a battery-floor stop continues where it left off.
#   --fresh / --no-resume
#                        the opposite: always mint a new session, never resume. The flag form of
#                        BENCH_RESUME=0. BENCH_RAW_SESSION=<stamp> still overrides both.
#
# Shared env knobs (all optional): KNEE_C FIND_KNEE ASSUME_YES BENCH_REPO EXECUTIONS SEED WARMUP
#   KNEE_MARGIN_C RUN_FLOOR BENCH_PKG BRIGHTNESS SCREEN_OFF_TIMEOUT_MS
#   MAX_CHARGE_MA BAND_LO BAND_HI COOLDOWN_MAX.

set -uo pipefail

# ── locate self + the benchmark repo ───────────────────────────────────────
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# lib/ lives at <repo>/scripts/devices/lib → the repo root is three up.
BENCH_REPO="${BENCH_REPO:-$(cd "$LIB_DIR/../../.." && pwd)}"

# ── corpus / dataset selection (flags; everything else stays positional) ───
# Parsed before anything else so the positional array still holds ONLY group ids. core.sh is
# not sourced yet, so errors print and exit directly (same idiom as devices/redmi9t/run.sh).
_pre_die() {
	printf '\n\033[31m✗ %s\033[0m\n\n' "$*" >&2
	exit 1
}
CORPUS_ROOT_OPT=""
DATASET_DIR_OPT=""
ELIGIBLE_ONLY_OPT="" # "" = derive from the corpus, 0/1 = the caller said so
RESUME_OPT=""        # "" = the historical heuristic, 1 = --resume, 0 = --fresh
_positional=()
while (($#)); do
	case "$1" in
	--samples-root | --corpus-root)
		[[ $# -ge 2 ]] || _pre_die "$1 needs a directory"
		CORPUS_ROOT_OPT="$2"
		shift 2
		;;
	--samples-root=* | --corpus-root=*)
		CORPUS_ROOT_OPT="${1#*=}"
		shift
		;;
	--dataset-dir)
		[[ $# -ge 2 ]] || _pre_die "$1 needs a directory"
		DATASET_DIR_OPT="$2"
		shift 2
		;;
	--dataset-dir=*)
		DATASET_DIR_OPT="${1#*=}"
		shift
		;;
	--eligible-only)
		ELIGIBLE_ONLY_OPT=1
		shift
		;;
	--no-eligible-only)
		ELIGIBLE_ONLY_OPT=0
		shift
		;;
	--resume | --continue)
		RESUME_OPT=1
		shift
		;;
	--fresh | --no-resume)
		RESUME_OPT=0
		shift
		;;
	--)
		shift
		_positional+=("$@")
		break
		;;
	-*) _pre_die "unknown flag: $1 (known: --samples-root --dataset-dir --eligible-only --no-eligible-only --resume --fresh)" ;;
	*)
		_positional+=("$1")
		shift
		;;
	esac
done
set -- ${_positional[@]+"${_positional[@]}"}

# Corpus root, resolved against the repo root (an absolute path is taken as given).
CORPUS_ROOT="${CORPUS_ROOT_OPT:-samples}"
[[ "$CORPUS_ROOT" == /* ]] || CORPUS_ROOT="$BENCH_REPO/$CORPUS_ROOT"
CORPUS_ROOT="${CORPUS_ROOT%/}"
[[ -d "$CORPUS_ROOT" ]] || _pre_die "corpus root not found: $CORPUS_ROOT (--samples-root is relative to $BENCH_REPO)"
CORPUS_NAME="$(basename "$CORPUS_ROOT")"

# Eligible-only: the flag wins; otherwise a corpus that carries a screening record is measured
# at its eligible endpoints, and one that does not is measured whole.
if [[ -n "$ELIGIBLE_ONLY_OPT" ]]; then
	ELIGIBLE_ONLY="$ELIGIBLE_ONLY_OPT"
elif [[ -f "$CORPUS_ROOT/exclusions.json" ]]; then
	ELIGIBLE_ONLY=1
else
	ELIGIBLE_ONLY=0
fi
if ((ELIGIBLE_ONLY == 1)) && [[ ! -f "$CORPUS_ROOT/exclusions.json" ]]; then
	_pre_die "--eligible-only needs $CORPUS_ROOT/exclusions.json, which does not exist"
fi

# The two Python call sites in measure.sh (run + status) must see the SAME corpus, or the
# resume math counts one corpus's targets against the other's captures. One array, both calls.
RUNNER_CORPUS_ARGS=(--samples-root "$CORPUS_ROOT")
ELIGIBLE_LABEL="no"
if ((ELIGIBLE_ONLY == 1)); then
	RUNNER_CORPUS_ARGS+=(--eligible-only)
	ELIGIBLE_LABEL="yes"
fi

# Diagnostic images, off unless SCREENSHOTS=1. `run` ONLY: `status` shares
# RUNNER_CORPUS_ARGS above and has no such flag, so this cannot live in that array. One PNG
# per role into dataset/<group>/<device>/shots/, captured after the measured span -- see the
# note in integration_test.dart on why it cannot perturb a buildSpan. It does mean the
# shot-carrying execution is built with SPM_SHOT=true and the others are not, which is why
# it stays opt-in rather than always on.
RUNNER_RUN_ARGS=()
if [[ "${SCREENSHOTS:-0}" == "1" ]]; then
	RUNNER_RUN_ARGS+=(--screenshots)
	SCREENSHOTS_LABEL="yes"
else
	SCREENSHOTS_LABEL="no"
fi

# ── shared runner / protocol / gate tunables ───────────────────────────────
# Positional args = one or more sample group(s) to measure, or "all"; default 01. Multiple
# groups run in ONE interleaved session and share a single restore (the EXIT trap fires once,
# after every group's measurements finish).
# NB: do NOT name this array `GROUPS` — that is a read-only special bash variable (the
# current user's group IDs); assigning to it is silently ignored, so the loop would walk
# your GIDs instead of the requested samples (e.g. GID 10 -> it ran samples/10).
SAMPLE_GROUPS=("$@")
# `01` is a default only for arm 1, where it names a real group. Under any other corpus root
# it would point the runner at a directory that does not exist, so ask instead of guessing.
if ((${#SAMPLE_GROUPS[@]} == 0)); then
	[[ "$CORPUS_NAME" == "samples" ]] ||
		_pre_die "no sample group given, and $CORPUS_NAME/ has no default group — name one (e.g. $(basename "$(find "$CORPUS_ROOT" -mindepth 1 -maxdepth 1 -type d | sort | head -1)")) or 'all'."
	SAMPLE_GROUPS=("01")
fi
# `--resume all` is the CAMPAIGN form: expand it into the corpus's group ids and take the
# ordinary named-group path below, one session per group. That is the documented protocol
# ("measure one group per session, never `all`") — bare `all`, which hands the runner ONE
# session name for the whole walk and so blends every group into it, is deliberately left
# exactly as it was.
#
# Sorted, so a campaign interrupted by the battery floor walks the same order when the same
# command is re-run. Group dirs are named by numeric id; everything else at a corpus root
# (exclusions.json, map.jsonl, .screen_cache.json) is bookkeeping, so the name is the filter.
if [[ "${RESUME_OPT:-}" == "1" && " ${SAMPLE_GROUPS[*]} " == *" all "* ]]; then
	mapfile -t SAMPLE_GROUPS < <(
		find "$CORPUS_ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' |
			grep -E '^[0-9]+$' | sort
	)
	((${#SAMPLE_GROUPS[@]} > 0)) || _pre_die "no group directories under $CORPUS_ROOT"
	echo "--resume all → ${#SAMPLE_GROUPS[@]} group(s) under $CORPUS_NAME/, one session each"
fi
SAMPLE="${SAMPLE_GROUPS[*]}" # display/label only
EXECUTIONS="${EXECUTIONS:-5}"
SEED="${SEED:-42}"
WARMUP="${WARMUP:-10}"
KNEE_MARGIN_C="${KNEE_MARGIN_C:-4}" # thermal ceiling = KNEE_C − this
# The battery/thermal ladder these belong to is owned by scripts/device_runner/gate.py, and
# `python3 -m scripts.device_runner gate --json` prints it. The watchdog keeps its own control
# flow on purpose -- stopping a HUNG runner is exactly what an outside process is for, and it
# cannot ask a process that is not responding -- but the numbers below must stay consistent with
# that ladder: RUN_FLOOR sits BELOW the Python abort floor so the in-process stop, which keeps
# completed executions, gets to happen first. `gate` exits non-zero if the rungs are misordered.
RUN_FLOOR="${RUN_FLOOR:-20}"        # battery floor for the watchdog
COOLDOWN_MAX="${COOLDOWN_MAX:-420}"
BENCH_PKG="${BENCH_PKG:-com.example.benchmark_container}"
BRIGHTNESS="${BRIGHTNESS:-40}"
SCREEN_OFF_TIMEOUT_MS="${SCREEN_OFF_TIMEOUT_MS:-${BENCH_SCREEN_OFF_TIMEOUT_MS:-2147483647}}"
MAX_CHARGE_MA="${MAX_CHARGE_MA:-1200}"
BAND_LO="${BAND_LO:-30}"
BAND_HI="${BAND_HI:-85}"
HARD_LO=30
HARD_HI=85
SAMPLE_SECS="${SAMPLE_SECS:-5}" # telemetry poll interval

# knee-finder tunables
THRESH_PCT="${THRESH_PCT:-92}"
CONSEC="${CONSEC:-3}"
WARM_SECS="${WARM_SECS:-12}"
KNEE_SAMPLE_SECS="${KNEE_SAMPLE_SECS:-1}"
MAX_SECS="${MAX_SECS:-300}"
KNEE_MARKER="SPSM_KNEE_LOAD"

# device-config fallbacks (a device run.sh may override any of these)
CURRENT_UNIT="${CURRENT_UNIT:-uA}"
THERMAL_ZONE="${THERMAL_ZONE:-}"
PIN_60HZ="${PIN_60HZ:-0}"
SOC_ABORT_C="${SOC_ABORT_C:-90}"

# ── load the stage library ─────────────────────────────────────────────────
source "$LIB_DIR/core.sh"
source "$LIB_DIR/telemetry.sh"
source "$LIB_DIR/knee.sh"
source "$LIB_DIR/prep.sh"
source "$LIB_DIR/preflight.sh"
source "$LIB_DIR/measure.sh"
source "$LIB_DIR/report.sh"
source "$LIB_DIR/root.sh"

# ── dataset namespacing ────────────────────────────────────────────────────
# One dataset root PER REFERENCE DEVICE. buildSpan is not comparable across SoCs, and the
# rooted Redmi additionally runs a different power/DVFS protocol, so a shared directory would
# silently blend two experiments (and `parse` rewrites a group's files in place, so the second
# device would overwrite the first). A device run.sh sets this before sourcing us; the default
# below keeps the default unrooted path, so nothing existing changes.
#
# The root is per CORPUS for the same reason it is per device: `_meta/<device>/manifest.json`
# and its exclusions digest are keyed by device alone, so two arms sharing a root would leave
# only the last one's manifest standing. Precedence: --dataset-dir, then an inherited
# BENCH_DATASET_DIR (scratch roots), then derived from the corpus name.
if [[ -n "$DATASET_DIR_OPT" ]]; then
	BENCH_DATASET_DIR="$DATASET_DIR_OPT"
elif [[ -z "${BENCH_DATASET_DIR:-}" ]]; then
	[[ "$CORPUS_NAME" == "samples" ]] && BENCH_DATASET_DIR="dataset" || BENCH_DATASET_DIR="dataset-$CORPUS_NAME"
fi
export BENCH_DATASET_DIR

# Printed HERE, before the serial gate, so a run that dies on "no device attached" has still
# said which corpus it was aimed at and where it would have written.
case "${RESUME_OPT:-}" in
1) SESSION_MODE_LABEL="resume (continue this group's existing session)" ;;
0) SESSION_MODE_LABEL="fresh (--fresh: always a new session)" ;;
*) SESSION_MODE_LABEL="auto (resume only a partly-complete session)" ;;
esac
echo "corpus root:  $CORPUS_ROOT   eligible-only: $ELIGIBLE_LABEL   screenshots: $SCREENSHOTS_LABEL"
echo "session mode: $SESSION_MODE_LABEL"
echo "dataset root: $BENCH_REPO/$BENCH_DATASET_DIR"

# ── lifecycle: EXIT trap stops any CPU load and restores the device ────────
PREPPED=0
LOAD_ON=0
ORIGINAL_SCREEN_OFF_TIMEOUT=""
cleanup() {
	stop_load
	# FIRST: unpin DVFS, reset cpusets and resume charging. Ordered before the unrooted
	# restore so that even a crashed run leaves the phone off the performance governor.
	root_restore
	if ((PREPPED == 1)); then
		banner "RESTORE"
		[[ "${CHARGE_FAKE:-0}" == "1" ]] && sh dumpsys battery reset >/dev/null 2>&1
		sh cmd connectivity airplane-mode disable >/dev/null 2>&1
		sh settings put global window_animation_scale 1 2>/dev/null
		sh settings put global transition_animation_scale 1 2>/dev/null
		sh settings put global animator_duration_scale 1 2>/dev/null
		sh settings put system screen_brightness_mode 1 2>/dev/null
		if [[ -n "${ORIGINAL_SCREEN_OFF_TIMEOUT:-}" ]]; then
			if [[ "$ORIGINAL_SCREEN_OFF_TIMEOUT" == "null" ]]; then
				sh settings delete system screen_off_timeout >/dev/null 2>&1 || true
			else
				sh settings put system screen_off_timeout "$ORIGINAL_SCREEN_OFF_TIMEOUT" >/dev/null 2>&1 || true
			fi
		fi
		sh svc power stayon false 2>/dev/null
		for p in "${BLOAT_PKGS[@]}"; do sh pm enable "$p" >/dev/null 2>&1 || true; done
		ok "device restored (radios on, animations on, bloat re-enabled)"
	fi
}
trap cleanup EXIT

# ── resolve serial + reachability ──────────────────────────────────────────
[[ -d "$BENCH_REPO" ]] || die "BENCH_REPO not found: $BENCH_REPO (set BENCH_REPO=/path/to/flutter-rebuild-direction)"
[[ -d "$BENCH_REPO/scripts" ]] || die "no 'scripts/' under $BENCH_REPO — is this the benchmark repo root?"

SER=""
for e in "${SERIAL_ENVS[@]}"; do
	v="${!e:-}"
	[[ -n "$v" ]] && SER="$v" && break
done
if [[ -z "$SER" ]]; then
	n=$(adb devices | awk 'NR>1 && $2=="device"{print $1}')
	[[ $(wc -w <<<"$n") -eq 1 ]] && SER="$n" || die "$SERIAL_HINT — 0 or >1 devices attached"
fi
sh true >/dev/null 2>&1 || die "device $SER not reachable over adb"
for e in "${SERIAL_ENVS[@]}"; do export "$e"="$SER"; done
# runner.py calls bare `adb` (no -s) in its thermal/battery gates; with two phones attached
# those would read whichever device adb picks. `adb` honours ANDROID_SERIAL, so exporting it
# here pins the Python side to the same device as the bash side, for BOTH devices.
export ANDROID_SERIAL="$SER"
export BENCH_SCREEN_OFF_TIMEOUT_MS="$SCREEN_OFF_TIMEOUT_MS"
CACHE="$DEVICE_DIR/.knee-$SER"

echo "== ${DEVICE_ID}/run.sh  $SER ($(sh getprop "$MODEL_PROP" | tr -d '\r'))  sample=$SAMPLE =="

# ── stage 0b: probe root BEFORE any gate reads POWER_MODE ──────────────────
# (root_probe also downgrades POWER_MODE=suspend -> charge_on when there is no root, so the
# preflight never gates on a charge cut that could not have been applied.)
root_probe

# ── stage 0a: campaign plan — which groups still owe executions (--resume only) ─────
# Asked BEFORE the knee finder and before prep, so a campaign with nothing left to do costs
# no device time at all. One Python process for the whole corpus: `discover_targets` re-reads
# the root's exclusions.json on every call, so per-group probes would be minutes of prelude.
#
# RUNNER_CORPUS_ARGS for the same reason measure.sh passes it — without --samples-root the
# counts come from arm 1's tree. --best, not the newest session, because a run that minted a
# fresh dir beside a partial one strands the progress in the older dir, and that is exactly
# the session --resume will continue.
#
# Only under --resume: without it a complete group is MEANT to be re-measured into a fresh
# session (that is what the default does), so skipping it here would change what no flag means.
SKIPPED_GROUPS=()
if [[ "${RESUME_OPT:-}" == "1" ]]; then
	banner "PLAN — ${#SAMPLE_GROUPS[@]} group(s), n=$EXECUTIONS, corpus $CORPUS_NAME"
	declare -A _PROGRESS=()
	while read -r _g _p; do [[ -n "$_g" ]] && _PROGRESS["$_g"]="$_p"; done < <(
		cd "$BENCH_REPO" && python -m scripts.device_runner status --all --best --quiet \
			"${RUNNER_CORPUS_ARGS[@]}" --executions "$EXECUTIONS" --device "$DEVICE_ID"
	)
	((${#_PROGRESS[@]} > 0)) || die "could not read the corpus status (see the error above)"
	_todo=()
	for g in "${SAMPLE_GROUPS[@]}"; do
		prog="${_PROGRESS[$g]:-}"
		# A named group the corpus-wide report never mentioned does not exist under this root.
		# Failing beats skipping: a typo'd id would otherwise look like "already done".
		[[ -n "$prog" ]] || die "group '$g' is not a directory under $CORPUS_ROOT"
		complete="${prog%%/*}"
		expected="${prog##*/}"
		[[ "$complete" =~ ^[0-9]+$ ]] || complete=0
		[[ "$expected" =~ ^[0-9]+$ ]] || expected=0
		if ((expected == 0)); then
			# Nothing this corpus + selection asks for. `run` would discover no targets and
			# return without measuring; saying so here keeps it out of the work list.
			printf '  %-6s %9s  skip — no targets under this selection\n' "$g" "$complete/$expected"
			SKIPPED_GROUPS+=("$g (no targets)")
		elif ((complete >= expected)); then
			printf '  %-6s %9s  skip — complete\n' "$g" "$complete/$expected"
			SKIPPED_GROUPS+=("$g (complete)")
		elif ((complete > 0)); then
			printf '  %-6s %9s  RESUME\n' "$g" "$complete/$expected"
			_todo+=("$g")
		else
			printf '  %-6s %9s  FRESH\n' "$g" "$complete/$expected"
			_todo+=("$g")
		fi
	done
	SAMPLE_GROUPS=(${_todo[@]+"${_todo[@]}"})
	SAMPLE="${SAMPLE_GROUPS[*]}"
	printf '\n  %d skipped, %d to measure\n' "${#SKIPPED_GROUPS[@]}" "${#SAMPLE_GROUPS[@]}"
	if ((${#SAMPLE_GROUPS[@]} == 0)); then
		ok "nothing left to measure — the device was not prepped and is untouched"
		exit 0
	fi
fi

# ── stage 0 ────────────────────────────────────────────────────────────────
resolve_knee
fan_flip_cooldown

echo "scope=$CORPUS_NAME ${SAMPLE_GROUPS[*]}  KNEE_C=${KNEE_C}°C  thermal ceil/resume=${TCEIL}/${TRESUME}°C"
echo "runner: executions=$EXECUTIONS seed=$SEED warmup=$WARMUP   repo=$BENCH_REPO"

# ── stages 1–2: prep + preflight ONCE for the whole session ────────────────
prep_device
root_prep # no-op without root: DVFS pin, cpuset isolation, charge cut, quiet installs
preflight
root_export_provenance

# ── stages 3–5: measure+parse each group in turn (sample by sample) ────────
# Each group is its OWN runner session, so base+mutations interleave within the group but
# groups never blend. Restore is deferred to the single EXIT trap, so the device is only
# restored after the LAST group finishes — one run.sh 01 02 03 = one restore at the end.
# A group the runner refuses (rc 2 — SessionAbort, or roles quarantined) no longer ends the
# command line. It is recorded here, whatever it did capture is still parsed, and the next
# group is measured: on 2026-09-09 one group with an orphan `part` fixture took 0334, 0331 and
# 0314 down with it, none of which had anything wrong. Every other failure still dies on the
# spot — see the rc test in measure.sh.
FAILED_GROUPS=()
if [[ " ${SAMPLE_GROUPS[*]} " == *" all "* ]]; then
	# "all" → let the runner walk every group itself, in one session (unchanged behavior).
	WT=()
	SCOPE="ALL groups"
	ACTIVE_SAMPLE_GROUP=""
	if measure; then
		parse_captures || die "parse failed"
	else
		FAILED_GROUPS+=("all: $MEASURE_FAILED_REASON")
		parse_captures || warn "parse skipped — no complete captures to parse"
	fi
else
	for g in "${SAMPLE_GROUPS[@]}"; do
		WT=(--widget-type "$g")
		SCOPE="sample $g"
		ACTIVE_SAMPLE_GROUP="$g"
		if measure; then
			parse_captures || die "parse failed for $g"
		else
			FAILED_GROUPS+=("$g: $MEASURE_FAILED_REASON")
			# Partial captures are still worth parsing, and `parse_captures` dies on failure —
			# which must not cost the groups still queued behind this one.
			parse_captures || warn "parse skipped for $g — no complete captures to parse"
		fi
	done
fi

# ── stage 5: acceptance gates (device restored by the EXIT trap after this) ─
acceptance_gates

if ((${#SKIPPED_GROUPS[@]} > 0)); then
	printf '\n======== SKIPPED (already complete / nothing to measure) ========\n'
	printf '  %s\n' "${SKIPPED_GROUPS[*]}"
fi

if ((${#FAILED_GROUPS[@]} > 0)); then
	printf '\n\033[31m======== FAILED GROUPS ========\033[0m\n'
	for f in "${FAILED_GROUPS[@]}"; do printf '  \033[31m✗\033[0m %s\n' "$f"; done
	printf '  The rest of the command line was measured. Fix these and re-run the SAME command:\n'
	printf '  completed executions are skipped on resume, so only the missing ones are measured.\n\n'
	exit 1
fi
