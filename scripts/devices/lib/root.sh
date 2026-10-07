#!/usr/bin/env bash
# lib/root.sh — OPTIONAL root-only device controls. Everything here is a no-op when the
# device has no usable root, so the existing non-rooted path (a stock phone) is
# byte-for-byte unchanged.
#
# What root buys us, and why each one matters for buildSpan:
#   1. DVFS PIN        governor=performance + scaling_min==scaling_max on the big cluster.
#                      Without it the SD662 ramps clocks *during* a rebuild burst, so the
#                      first rebuilds of an execution are measured at a different frequency
#                      than the last — the single largest source of within-target variance.
#   2. CPUSET ISOLATE  the app (top-app) gets ONLY the big cores; every other cpuset is
#                      pushed onto the little cores, so background work cannot preempt the
#                      Flutter UI thread on the core we pinned.
#   3. CHARGE CONTROL  a real `input_suspend` cut (POWER_MODE=suspend) instead of the
#                      report-only `dumpsys battery unplug` fake — removes charger heat and
#                      PMIC current from the measurement. Battery then genuinely drains.
#   4. QUIET INSTALLS  MIUI's "Install via USB?" dialog blocks unattended `flutter drive`
#                      reinstalls; root can flip the MIUI-optimization knobs that suppress it.
#
# Every mutation is recorded in $DEVICE_DIR/.rootstate-<serial> BEFORE it is applied, so
# root_restore() is exact and survives a crashed run (the file is replayed on the next run).
#
# Device knobs (set in the device run.sh, all optional):
#   USE_ROOT=auto|1|0   auto = use root if present; 1 = require it (die if absent); 0 = off
#   POWER_MODE=charge_on|suspend
#   BIG_CORES="4 5 6 7" (default: cores whose cpuinfo_max_freq == the global max)
#   GOV_PIN=1|0, PIN_FREQ_KHZ=<khz> (default: cpuinfo_max_freq)
#   CPUSET_ISOLATE=1|0, QUIET_INSTALL=1|0

_ROOT_MODE="none" # none | adbroot | su
ROOT_PREPPED=0
ROOT_STATE=""

# ── root plumbing ──────────────────────────────────────────────────────────
have_root() { [[ "$_ROOT_MODE" != "none" ]]; }

# Run a command string as root on the device. The `su` form feeds the script on STDIN
# rather than as an argument, so quoting inside $* is never re-interpreted by adb.
rsh() {
	local cmd="$*"
	case "$_ROOT_MODE" in
	adbroot) sh "$cmd" ;;
	su) printf '%s\n' "$cmd" | adbx shell su ;;
	*) return 127 ;;
	esac
}

# strip CR + whitespace from a device read
_dev() { sh "$@" 2>/dev/null | tr -d '\r' | tr -d ' '; }

# Same, but as ROOT when we have it. Some nodes we write via `rsh` live under a directory
# the `shell` user cannot traverse — /sys/class/power_supply/battery/input_suspend is 0777
# itself, yet a plain `adb shell cat` on it returns "Permission denied" (verified on
# lime/Redmi 9T). Reading those back with `_dev` yields an EMPTY string, which reads as
# "the write did not take" and hard-fails preflight even though charging is really cut.
# Falls back to the unprivileged read when there is no root, so it is safe everywhere.
_rdev() {
	local out=""
	have_root && out=$(rsh "$*" 2>/dev/null | tr -d '\r' | tr -d ' ')
	[[ -n "$out" ]] && printf '%s' "$out" || _dev "$@"
}

# `cat` a device file as root, stripping only CR — unlike _rdev, spaces are KEPT, so
# multi-token values (the "0:x 1:x …" msm_performance limit strings) survive intact.
_rcat() {
	local out=""
	have_root && out=$(rsh "cat $1" 2>/dev/null | tr -d '\r')
	[[ -n "$out" ]] && printf '%s' "$out" || sh "cat $1" 2>/dev/null | tr -d '\r'
}

# Does the msm_performance module expose its limit parameters?
#
# MUST be probed AS ROOT. On lime/Redmi 9T the module directory is world-traversable but
# /sys/module/msm_performance/parameters is not readable by the `shell` user ("Permission
# denied" on ls), so an unprivileged `[ -e ]` answers "no" on a phone that plainly has the
# module. That false negative is not a cosmetic one: it silently selects the cpufreq_sysfs
# pin path, whose writes MIUI mirrors into this very module clamped to each cluster's own
# maximum — so asking for 1804800 yields a 2016000 pin, preflight fails the exact-equality
# gate, and the restore (which probed the same way) never writes the release sentinels, so
# the phone is left pinned. Same class of bug as _rdev, same fix: read it with root.
_have_msmperf() {
	[[ "$(_rdev "[ -e /sys/module/msm_performance/parameters/cpu_min_freq ] && echo yes")" == "yes" ]]
}

root_probe() {
	_ROOT_MODE="none"
	if [[ "${USE_ROOT:-auto}" == "0" ]]; then
		log "root: disabled (USE_ROOT=0)"
		_power_mode_downgrade # must still run: charge cutting needs root
		return 0
	fi

	# 1. already root (userdebug/eng, or a previous `adb root`)
	if [[ "$(_dev id -u)" == "0" ]]; then
		_ROOT_MODE="adbroot"
	# 2. Magisk-style su on a production build — try this BEFORE `adb root`, it doesn't
	#    bounce adbd. First invocation may raise a grant dialog on the phone.
	elif [[ "$(printf 'id -u\n' | adbx shell su 2>/dev/null | tr -d '\r' | head -1)" == "0" ]]; then
		_ROOT_MODE="su"
	# 3. last resort: adbd as root (production builds refuse; harmless if it fails)
	elif adbx root >/dev/null 2>&1 && adbx wait-for-device >/dev/null 2>&1 &&
		[[ "$(_dev id -u)" == "0" ]]; then
		_ROOT_MODE="adbroot"
	fi

	if have_root; then
		ok "root available (mode=$_ROOT_MODE) — DVFS pin, cpuset isolation and real charge control are ON"
	elif [[ "${USE_ROOT:-auto}" == "1" ]]; then
		die "USE_ROOT=1 but no root on $SER.
         Magisk: open Magisk → Superuser → grant 'Shell' (run 'adb shell su -c id' once and ACCEPT the dialog).
         Or set USE_ROOT=0 to fall back to the unrooted charge-on path."
	else
		warn "no root — running the unrooted path (no DVFS pin, no cpuset isolation, no charge cut)"
	fi

	_power_mode_downgrade
}

# A charge CUT is only possible with root. Downgrade rather than fail the preflight on a
# gate ("must be discharging") that nothing could ever have satisfied. Reachable from BOTH
# root_probe exits — including the USE_ROOT=0 early return.
_power_mode_downgrade() {
	if ! have_root && [[ "${POWER_MODE:-charge_on}" == "suspend" ]]; then
		warn "POWER_MODE=suspend needs root — falling back to the charge-on protocol"
		POWER_MODE="charge_on"
	fi
}

# ── cluster topology ───────────────────────────────────────────────────────
_resolve_cores() {
	local gmax c mx idx present
	if [[ -z "${BIG_CORES:-}" ]]; then
		gmax=$(_dev 'cat /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_max_freq 2>/dev/null' | sort -n | tail -1)
		BIG_CORES=""
		if [[ "$gmax" =~ ^[0-9]+$ ]]; then
			for c in $(sh 'ls -d /sys/devices/system/cpu/cpu[0-9]*/cpufreq 2>/dev/null' | tr -d '\r'); do
				mx=$(_dev "cat $c/cpuinfo_max_freq 2>/dev/null")
				# $c is /sys/devices/system/cpu/cpuN/cpufreq. Strip the trailing /cpufreq
				# FIRST, then take everything after the last "/cpu" — the path contains an
				# earlier "/cpu" segment, so a leading-prefix strip yields an empty index.
				idx="${c%/cpufreq}"
				idx="${idx##*/cpu}"
				[[ "$mx" == "$gmax" ]] && BIG_CORES+="$idx "
			done
		fi
		BIG_CORES="${BIG_CORES% }"
	fi
	[[ -n "$BIG_CORES" ]] || die "could not resolve the big cluster — set BIG_CORES=\"4 5 6 7\" explicitly"

	present=$(_dev 'cat /sys/devices/system/cpu/present' | awk -F- '{print ($2?$2:$1)}')
	[[ "$present" =~ ^[0-9]+$ ]] || present=7
	LITTLE_CORES=""
	for ((c = 0; c <= present; c++)); do
		[[ " $BIG_CORES " == *" $c "* ]] || LITTLE_CORES+="$c "
	done
	LITTLE_CORES="${LITTLE_CORES% }"
	BIG_CPUS="${BIG_CORES// /,}"
	LITTLE_CPUS="${LITTLE_CORES// /,}"
	# If every core is "big" (symmetric SoC) there is nothing to isolate against.
	[[ -z "$LITTLE_CPUS" ]] && CPUSET_ISOLATE=0
}

# ── state journal (host-side, replayed on restore) ─────────────────────────
_state_put() { printf '%s\n' "$*" >>"$ROOT_STATE"; }

# ── stage 1b: root prep (called right after prep_device) ───────────────────
root_prep() {
	have_root || return 0
	_resolve_cores
	banner "ROOT PREP (DVFS pin, cpuset isolation, charge control)"
	ROOT_STATE="$DEVICE_DIR/.rootstate-$SER"

	# A stale journal means a previous run died before restoring — replay it first.
	if [[ -s "$ROOT_STATE" ]]; then
		warn "stale root state from a crashed run — restoring it before re-prepping"
		root_restore quiet
	fi
	: >"$ROOT_STATE"
	ROOT_PREPPED=1

	log "big cluster: cpu[$BIG_CPUS]   little: cpu[${LITTLE_CPUS:-none}]"

	# ── 0. stop the vendor DVFS daemons that would fight the pin ───────────
	# These are userspace agents that dynamically boost/clamp CPU frequency (QTI's perf HAL
	# and Xiaomi's booster). Two reasons to stop them for the session, in order of importance:
	#
	#   1. THEY ARE THE UNCONTROLLED DVFS the rooted protocol exists to eliminate. A daemon
	#      raising clocks when it detects "an app is busy" is precisely the confound that makes
	#      one rebuild burst incomparable with the next.
	#   2. They RACE the pin, in both directions. Measured on lime/Redmi 9T: with perf-hal
	#      running, the pin lands and is then overwritten back to the cluster max within
	#      seconds, and the release is re-asserted back to pinned. With both stopped, the pin
	#      held exactly at 1804800 indefinitely and released cleanly.
	#
	# Thermal daemons (thermal-engine, mi_thermald) are deliberately LEFT RUNNING: the throttle
	# knee must stay the device's natural behaviour, and disabling thermal protection on a
	# phone running 4.5 h sessions is not something to do for a measurement.
	# Empty by default, so the unrooted path is untouched.
	local svc state
	for svc in ${PERF_DAEMONS:-}; do
		state=$(_dev "getprop init.svc.$svc")
		if [[ "$state" == "running" ]]; then
			_state_put "svc $svc"
			rsh "stop $svc" >/dev/null 2>&1
		fi
	done
	if [[ -n "${PERF_DAEMONS:-}" ]]; then
		sleep 1
		ok "vendor DVFS daemons stopped for the session: ${PERF_DAEMONS// /, } (restarted on restore)"
	fi

	# ── 1. DVFS pin ────────────────────────────────────────────────────────
	# TWO MECHANISMS, because writing scaling_min/max_freq is NOT universally effective.
	#
	# On MIUI (measured on lime/Redmi 9T, bengal, A12) a perf daemon MIRRORS any scaling_*
	# write into the msm_performance kernel module — and mirrors it WRONG, clamping each
	# cluster to its own maximum instead of the frequency you asked for. The module then
	# enforces that clamp over every later scaling_* write, and it SURVIVES reverting the
	# governor. Net effect if we used the sysfs path here: asking for 1804800 silently yields
	# a 2016000 max-pin, the "restore" cannot undo it, and the phone is left permanently
	# pinned at max — contaminating every subsequent session on that device.
	#
	# So: when msm_performance exists, drive it directly. It honours the exact requested
	# frequency (verified: cpu4-7 held 1804800 flat under load) and releases cleanly with the
	# documented sentinels (min 0, max UINT_MAX). Only fall back to scaling_* without it.
	if ((${GOV_PIN:-1} == 1)); then
		local c d gov mn mx target spec i
		local PRE_PINNED=0
		target="${PIN_FREQ_KHZ:-}"
		[[ -z "$target" ]] && target=$(_dev "cat /sys/devices/system/cpu/cpu${BIG_CORES%% *}/cpufreq/cpuinfo_max_freq")
		[[ "$target" =~ ^[0-9]+$ ]] || die "could not read a target frequency — set PIN_FREQ_KHZ explicitly"

		# A big core already at min == max means a PREVIOUS run died without releasing the
		# pin. Journalling that as "original" would make the contamination permanent — every
		# restore from here on would faithfully put the phone back into a pinned state. Say
		# so, and record the hardware range as the thing to restore to instead.
		for c in $BIG_CORES; do
			d="/sys/devices/system/cpu/cpu$c/cpufreq"
			mn=$(_dev "cat $d/scaling_min_freq")
			mx=$(_dev "cat $d/scaling_max_freq")
			if [[ -n "$mn" && "$mn" == "$mx" ]]; then
				warn "cpu$c was ALREADY pinned at ${mn} kHz before this run — a previous session"
				log "    did not release it. Restoring to the hardware range instead of that state."
				PRE_PINNED=1
			fi
		done

		MSMPERF="/sys/module/msm_performance/parameters"
		if _have_msmperf; then
			PIN_MODE="msm_performance"
			# Journal the module's CURRENT limit strings verbatim, then pin only the big
			# cores. MAX is journalled first so the restore replays max before min.
			# If we arrived already pinned, journal the RELEASE sentinels instead — the
			# current values are a previous run's leftovers, not this phone's stock state.
			if ((${PRE_PINNED:-0} == 1)); then
				_state_put "msmperfmax 0:4294967295 1:4294967295 2:4294967295 3:4294967295 4:4294967295 5:4294967295 6:4294967295 7:4294967295"
				_state_put "msmperfmin 0:0 1:0 2:0 3:0 4:0 5:0 6:0 7:0"
			else
				# root read, and space-PRESERVING: these are "0:x 1:x …" limit strings,
				# which _rdev's space stripping would fuse into one unusable token.
				_state_put "msmperfmax $(_rcat "$MSMPERF/cpu_max_freq")"
				_state_put "msmperfmin $(_rcat "$MSMPERF/cpu_min_freq")"
			fi
			spec=""
			for i in $BIG_CORES; do spec+="$i:$target "; done
			rsh "echo '${spec% }' > $MSMPERF/cpu_max_freq 2>/dev/null;
			     echo '${spec% }' > $MSMPERF/cpu_min_freq 2>/dev/null" >/dev/null 2>&1
		else
			PIN_MODE="cpufreq_sysfs"
			for c in $BIG_CORES; do
				d="/sys/devices/system/cpu/cpu$c/cpufreq"
				gov=$(_dev "cat $d/scaling_governor")
				mn=$(_dev "cat $d/scaling_min_freq")
				mx=$(_dev "cat $d/scaling_max_freq")
				[[ -n "$gov" ]] && _state_put "cpu $c $gov $mn $mx"
			done
			# Order matters: governor first, then max, then min (min>max is rejected by the kernel).
			rsh "for i in $BIG_CORES; do p=/sys/devices/system/cpu/cpu\$i/cpufreq;
			       echo performance > \$p/scaling_governor 2>/dev/null;
			       echo $target > \$p/scaling_max_freq 2>/dev/null;
			       echo $target > \$p/scaling_min_freq 2>/dev/null; done" >/dev/null 2>&1
		fi

		export PIN_FREQ_APPLIED="$target"
		ok "DVFS pinned: cpu[$BIG_CPUS] min=max=${target} kHz (via $PIN_MODE)"
		[[ -z "${PIN_FREQ_KHZ:-}" ]] &&
			log "    (pinned at the hardware max; if the thermal-drift gate fails, re-run with a"
		[[ -z "${PIN_FREQ_KHZ:-}" ]] &&
			log "     sustainable pin, e.g. PIN_FREQ_KHZ=1_800_000-style value from scaling_available_frequencies)"
	fi

	# ── 2. cpuset: app alone on the big cores, everything else on the little ──
	if ((${CPUSET_ISOLATE:-1} == 1)); then
		local set cur
		for set in top-app foreground background system-background restricted; do
			cur=$(_dev "cat /dev/cpuset/$set/cpus 2>/dev/null")
			[[ -n "$cur" ]] && _state_put "cpuset $set $cur"
		done
		rsh "echo $BIG_CPUS > /dev/cpuset/top-app/cpus 2>/dev/null;
		     for s in foreground background system-background restricted; do
		       echo $LITTLE_CPUS > /dev/cpuset/\$s/cpus 2>/dev/null; done" >/dev/null 2>&1
		ok "cpuset isolated: top-app=[$BIG_CPUS], everything else=[$LITTLE_CPUS]"
	fi

	# ── 3. charge control ──────────────────────────────────────────────────
	if [[ "${POWER_MODE:-charge_on}" == "suspend" ]]; then
		# Probe the known paths FIRST: everything under /sys/class/power_supply is a symlink,
		# and toybox `find` does not follow symlinks without -L, so a plain find here finds
		# nothing even on devices that do have the node (verified on lime/Redmi 9T).
		# Probe the known paths FIRST and `exit` on the first hit. Everything under
		# /sys/class/power_supply is a symlink, so a plain `find` misses the node entirely
		# (toybox does not follow symlinks without -L) — while `find -L` walks symlinked
		# sysfs trees and HANGS for minutes. Both were observed on lime/Redmi 9T, hence:
		# direct probe, and the -L walk only as a last resort on unknown hardware.
		SUSPEND_NODE="${SUSPEND_NODE:-$(rsh 'for n in /sys/class/power_supply/battery/input_suspend \
		                                        /sys/class/power_supply/main/input_suspend \
		                                        /sys/class/power_supply/usb/input_suspend; do
		                                   [ -e "$n" ] && echo "$n" && exit 0; done
		                                 timeout 20 find -L /sys/class/power_supply -name input_suspend 2>/dev/null | head -1' |
			tr -d '\r' | head -1)}"
		if [[ -n "$SUSPEND_NODE" ]]; then
			_state_put "suspend $SUSPEND_NODE $(_rdev cat "$SUSPEND_NODE")"
			rsh "echo 1 > $SUSPEND_NODE" >/dev/null 2>&1
			ok "charging SUSPENDED at $SUSPEND_NODE (battery will now genuinely drain — that is correct)"
		else
			warn "POWER_MODE=suspend but no input_suspend node found — falling back to charge-on"
			POWER_MODE="charge_on"
		fi
	else
		log "charge-on mode: leaving the weak USB trickle connected (preflight gates it)"
	fi

	# ── 4. quiet installs (MIUI 'Install via USB?' dialog) ─────────────────
	if ((${QUIET_INSTALL:-1} == 1)); then
		rsh "settings put secure install_non_market_apps 1 2>/dev/null;
		     settings put global verifier_verify_adb_installs 0 2>/dev/null;
		     settings put global package_verifier_enable 0 2>/dev/null;
		     settings put global miui_optimization 0 2>/dev/null;
		     setprop persist.sys.miui_optimization false 2>/dev/null" >/dev/null 2>&1
		ok "quiet-install knobs set (verifier off, MIUI optimization off)"
	fi
}

# ── restore (called from the EXIT trap; also replays a stale journal) ──────
root_restore() {
	local quiet="${1:-}"
	[[ -n "$ROOT_STATE" && -s "$ROOT_STATE" ]] || return 0
	[[ "$quiet" == "quiet" ]] || banner "ROOT RESTORE"

	# Read whole lines: the msm_performance entries carry a multi-token "0:x 1:x …" limit
	# string that a fixed-field `read` would split across variables.
	local line kind rest a b c d svcs="" M="/sys/module/msm_performance/parameters"
	while IFS= read -r line; do
		kind="${line%% *}"
		rest="${line#* }"
		case "$kind" in
		# Collected, NOT restarted here: the perf daemons must come back only after the pin
		# has been released and verified, or they re-assert the pin we are trying to drop.
		svc) svcs+="$rest " ;;
		cpu)
			# a=index b=governor c=scaling_min d=scaling_max. Widen max BEFORE lowering min
			# (the kernel rejects min > max), and restore the governor last.
			set -- $rest
			a="$1" b="$2" c="$3" d="$4"
			rsh "p=/sys/devices/system/cpu/cpu$a/cpufreq;
			     echo $d > \$p/scaling_max_freq 2>/dev/null;
			     echo $c > \$p/scaling_min_freq 2>/dev/null;
			     echo $b > \$p/scaling_governor 2>/dev/null" >/dev/null 2>&1
			;;
		# Restore the module's limit strings verbatim. Widen max first, then min, for the
		# same min>max reason. A stock phone journals the release sentinels (min 0, max
		# UINT_MAX), so replaying them is exactly "unpinned".
		msmperfmax) rsh "echo '$rest' > $M/cpu_max_freq 2>/dev/null" >/dev/null 2>&1 ;;
		msmperfmin) rsh "echo '$rest' > $M/cpu_min_freq 2>/dev/null" >/dev/null 2>&1 ;;
		cpuset)
			set -- $rest
			rsh "echo $2 > /dev/cpuset/$1/cpus 2>/dev/null" >/dev/null 2>&1
			;;
		suspend)
			set -- $rest
			rsh "echo ${2:-0} > $1" >/dev/null 2>&1
			;;
		esac
	done <"$ROOT_STATE"

	# Restart the vendor daemons BEFORE the final unpin check, not after.
	#
	# perf-hal-2-2 re-applies the limits it had cached WHEN IT STARTS: measured on this unit,
	# a restore that released the pin, restarted the daemons and then stopped left the phone
	# clamped at each cluster's max (0-3 @1804800, 4-7 @2016000) — the mirror signature —
	# reported as a clean restore. Verifying only before the restart checks a state the daemon
	# is about to overwrite. So: bring them back, give them a moment to re-assert, and only
	# then verify and re-release until it sticks.
	if [[ -n "$svcs" ]]; then
		for kind in $svcs; do rsh "start $kind" >/dev/null 2>&1; done
		sleep 2
		[[ "$quiet" == "quiet" ]] || ok "vendor DVFS daemons restarted: ${svcs% }"
	fi

	_root_verify_unpinned "$quiet"

	: >"$ROOT_STATE"
	ROOT_PREPPED=0
	[[ "$quiet" == "quiet" ]] || ok "root state restored (DVFS unlocked, cpusets reset, charging resumed)"
}

# Confirm the big cores are actually back under governor control, and re-release if not.
#
# WHY THIS EXISTS: on MIUI the perf daemon caches the limits it mirrored when we pinned and
# RE-ASSERTS them shortly after the release write — the later cpuset restores are enough to
# trigger it. Measured on lime/Redmi 9T: cores 0-3 (never pinned) stayed released while 4-7
# came straight back to the pinned value, and the run reported a clean restore. A phone left
# pinned at a fixed frequency silently changes the measurement condition of EVERY later
# session on that device, including ones that think they are stock — which is exactly how
# this unit sat pinned for two days before it was noticed. So: verify, retry, and if it still
# will not let go, say so LOUDLY rather than returning a green tick.
_root_verify_unpinned() {
	local quiet="${1:-}" attempt c mn mx stuck M="/sys/module/msm_performance/parameters"
	local has_mod=""
	_have_msmperf && has_mod="yes"

	for attempt in 1 2 3; do
		stuck=""
		for c in $BIG_CORES; do
			mn=$(_dev "cat /sys/devices/system/cpu/cpu$c/cpufreq/scaling_min_freq")
			mx=$(_dev "cat /sys/devices/system/cpu/cpu$c/cpufreq/scaling_max_freq")
			[[ -n "$mn" && "$mn" == "$mx" ]] && stuck+="$c "
		done
		[[ -z "$stuck" ]] && return 0

		((attempt == 1)) && [[ "$quiet" != "quiet" ]] &&
			warn "cpu[${stuck% }] still pinned after restore (perf daemon re-asserted it) — re-releasing"
		if [[ "$has_mod" == "yes" ]]; then
			rsh "echo '0:4294967295 1:4294967295 2:4294967295 3:4294967295 4:4294967295 5:4294967295 6:4294967295 7:4294967295' > $M/cpu_max_freq 2>/dev/null;
			     echo '0:0 1:0 2:0 3:0 4:0 5:0 6:0 7:0' > $M/cpu_min_freq 2>/dev/null" >/dev/null 2>&1
		fi
		# Also widen the per-core policy back to the hardware range, in case the module is
		# absent and it was the sysfs path that stuck.
		rsh "for i in $BIG_CORES; do p=/sys/devices/system/cpu/cpu\$i/cpufreq;
		       echo \$(cat \$p/cpuinfo_max_freq) > \$p/scaling_max_freq 2>/dev/null;
		       echo \$(cat \$p/cpuinfo_min_freq) > \$p/scaling_min_freq 2>/dev/null; done" >/dev/null 2>&1
		sleep 1
	done

	bad "cpu[${stuck% }] are STILL pinned (scaling_min == scaling_max) after 3 release attempts."
	log "    The phone is NOT in its stock DVFS state. Every later session on it — including"
	log "    unrooted ones — would run at a locked frequency. Release it by hand and re-check:"
	log "      adb shell su -c \"echo '0:0 1:0 2:0 3:0 4:0 5:0 6:0 7:0' > $M/cpu_min_freq\""
	log "      adb shell su -c \"echo '0:4294967295 1:4294967295 2:4294967295 3:4294967295 4:4294967295 5:4294967295 6:4294967295 7:4294967295' > $M/cpu_max_freq\""
	log "    (a reboot also clears it). Data collected before this is fine; do not start a new"
	log "    session until the cores read scaling_min < scaling_max again."
	return 1
}

# ── preflight verification: returns the number of FAILED root gates ────────
root_preflight() {
	have_root || return 0
	local fails=0 c gov cur want set cs susp mn mx
	if ((${GOV_PIN:-1} == 1)); then
		want="${PIN_FREQ_APPLIED:-}"
		# The governor only has to read `performance` when we pinned THROUGH the governor.
		# The msm_performance path clamps min==max at the module level and deliberately
		# leaves the governor alone (touching it is what triggers MIUI's bad mirror).
		if [[ "${PIN_MODE:-cpufreq_sysfs}" == "cpufreq_sysfs" ]]; then
			for c in $BIG_CORES; do
				gov=$(_dev "cat /sys/devices/system/cpu/cpu$c/cpufreq/scaling_governor")
				[[ "$gov" == "performance" ]] || {
					bad "cpu$c governor is '$gov', not performance — DVFS pin did not stick"
					fails=$((fails + 1))
				}
			done
		fi
		# Verify the pin by EXACT EQUALITY per big core: scaling_min == scaling_max == want.
		# A `cur >= want` check is a false green — when MIUI's mirror clamps the cluster to
		# its hardware max, cur (2016000) trivially exceeds the requested pin (1804800) and
		# the gate would pass while the measurement condition is silently wrong.
		if [[ "$want" =~ ^[0-9]+$ ]]; then
			for c in $BIG_CORES; do
				mn=$(_dev "cat /sys/devices/system/cpu/cpu$c/cpufreq/scaling_min_freq")
				mx=$(_dev "cat /sys/devices/system/cpu/cpu$c/cpufreq/scaling_max_freq")
				[[ "$mn" == "$want" && "$mx" == "$want" ]] || {
					bad "cpu$c is min=${mn:-?}/max=${mx:-?}, not pinned at ${want} kHz — the pin did not take (mode=${PIN_MODE:-?})"
					fails=$((fails + 1))
				}
			done
			cur=$(_dev "cat /sys/devices/system/cpu/cpu${BIG_CORES%% *}/cpufreq/scaling_cur_freq")
			((fails == 0)) && ok "DVFS pin verified: cpu[$BIG_CPUS] min=max=${want} kHz (cur=${cur:-?}, mode=${PIN_MODE:-?})"
		fi
	fi
	local svc state
	for svc in ${PERF_DAEMONS:-}; do
		state=$(_dev "getprop init.svc.$svc")
		[[ "$state" == "running" ]] && {
			bad "$svc is still running — it will fight the DVFS pin and re-boost clocks mid-measurement"
			fails=$((fails + 1))
		}
	done

	if ((${CPUSET_ISOLATE:-1} == 1)); then
		cs=$(_dev 'cat /dev/cpuset/top-app/cpus 2>/dev/null')
		[[ -n "$cs" ]] && ok "top-app cpuset = [$cs]" ||
			warn "could not read /dev/cpuset/top-app/cpus — isolation unverified"
	fi
	if [[ "${POWER_MODE:-charge_on}" == "suspend" && -n "${SUSPEND_NODE:-}" ]]; then
		susp=$(_rdev cat "$SUSPEND_NODE")
		[[ "$susp" == "1" ]] && ok "charge input suspended ($SUSPEND_NODE=1)" || {
			bad "charge input NOT suspended ($SUSPEND_NODE=${susp:-unreadable}) — charger heat/current would contaminate the run"
			fails=$((fails + 1))
		}
	fi
	return "$fails"
}

# ── provenance: what the runner should stamp into dataset/manifest.json ────
# Exported right before MEASURE so `runner.py` records the controls that were ACTUALLY
# applied this session (read back from the device), instead of a hardcoded TODO string.
root_export_provenance() {
	local gov=""
	if have_root && ((${GOV_PIN:-1} == 1)); then
		gov=$(_dev "cat /sys/devices/system/cpu/cpu${BIG_CORES%% *}/cpufreq/scaling_governor")
	fi
	[[ -z "$gov" ]] && gov=$(_dev 'cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor')

	export BENCH_DEVICE_LABEL="${DEVICE_MODEL_LABEL:-$DEVICE_ID}"
	export BENCH_DEVICE_ID="$DEVICE_ID"
	export BENCH_DEVICE_SERIAL="$SER"
	export BENCH_POWER_MODE="${POWER_MODE:-charge_on}"
	export BENCH_ROOT_MODE="$_ROOT_MODE"
	export BENCH_KNEE_C="${KNEE_C:-}"
	export BENCH_CPUSET_TOP_APP=""
	if have_root; then
		export BENCH_PIN_FREQ_KHZ="${PIN_FREQ_APPLIED:-}"
		((${CPUSET_ISOLATE:-1} == 1)) &&
			BENCH_CPUSET_TOP_APP=$(_dev 'cat /dev/cpuset/top-app/cpus 2>/dev/null')
	else
		export BENCH_PIN_FREQ_KHZ=""
	fi

	if have_root && [[ -n "${PIN_FREQ_APPLIED:-}" ]]; then
		export BENCH_GOVERNOR="${gov:-unknown}, pinned min==max=${PIN_FREQ_APPLIED} kHz on cpu[$BIG_CPUS] via ${PIN_MODE:-cpufreq_sysfs}"
	else
		export BENCH_GOVERNOR="${gov:-unknown} (not pinned — thermal + statistical control only)"
	fi
}
