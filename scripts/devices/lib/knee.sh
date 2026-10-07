#!/usr/bin/env bash
# lib/knee.sh — throttle-knee calibration and resolution (stage 0).
#   stop_load           kill the synthetic CPU load started by the knee finder
#   find_knee           drive the chip to throttling (FAN OFF) and read the knee °C
#   resolve_knee        env > opt-in auto-find > cache > device default (or die)
#   fan_flip_cooldown   after a fresh calibration, wait for the phone to cool
# Device knobs: KNEE_DEFAULT ("" = require a measured knee), CLUSTER_LABEL, SOC_ABORT_C.

stop_load() { ((LOAD_ON == 1)) && {
	sh "pkill -f $KNEE_MARKER" >/dev/null 2>&1 || true
	LOAD_ON=0
}; }

# ── the automatic throttle-knee finder (fan OFF) ───────────────────────────
# The cluster it watches = cpus whose cpuinfo_max_freq equals the global max — those
# throttle first (on a phone with a single prime core this isolates that core). No index
# is hard-coded, so the same routine works across SoCs.
find_knee() {
	local nproc big_nodes global_max c mx
	warn "The phone must reach throttling — make sure the FAN IS OFF. Start temp: $(hot_c)°C"
	if [[ "${ASSUME_YES:-0}" != "1" ]]; then
		read -r -p "  Fan off and ready? [y/N] " ans
		[[ "$ans" == y || "$ans" == Y ]] || die "aborted — turn the fan off, then re-run (or ASSUME_YES=1)"
	fi

	nproc=$(sh 'cat /sys/devices/system/cpu/present 2>/dev/null' | tr -d '\r' | awk -F- '{print ($2?$2:$1)+1}')
	[[ "$nproc" =~ ^[0-9]+$ ]] || nproc=8
	echo "  starting load on $nproc cores…"
	local loadcmd="" i
	for ((i = 0; i < nproc; i++)); do
		loadcmd+="nohup sh -c 'while :; do :; done' $KNEE_MARKER >/dev/null 2>&1 </dev/null & "
	done
	sh "$loadcmd" >/dev/null 2>&1 || true
	LOAD_ON=1
	sleep 3

	# big/top cluster = cpus whose cpuinfo_max_freq equals the global max (throttle first)
	big_nodes=""
	global_max=$(sh 'cat /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_max_freq 2>/dev/null' | tr -d '\r' | sort -n | tail -1)
	if [[ "$global_max" =~ ^[0-9]+$ ]]; then
		for c in $(sh 'ls -d /sys/devices/system/cpu/cpu[0-9]*/cpufreq 2>/dev/null' | tr -d '\r'); do
			mx=$(sh "cat $c/cpuinfo_max_freq 2>/dev/null" | tr -d '\r')
			[[ "$mx" == "$global_max" ]] && big_nodes+="$c/scaling_cur_freq "
		done
	fi
	[[ -n "$big_nodes" ]] && ok "${CLUSTER_LABEL:-top cluster}: $(wc -w <<<"$big_nodes") core(s)" ||
		warn "could not isolate the top cluster — sampling max freq across all cores"
	local freq_nodes="${big_nodes:-/sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq}"

	local start_epoch peak=0 hits=0 knee="" last_peak_temp="" now el f t pct
	start_epoch=$(date +%s)
	printf '  %-6s %-8s %-9s %-6s %s\n' "t(s)" "freq" "%peak" "temp" "state"
	while :; do
		now=$(date +%s)
		el=$((now - start_epoch))
		f=$(sh "cat $freq_nodes 2>/dev/null" | tr -d '\r' | sort -n | tail -1)
		t=$(hot_c)
		[[ "$f" =~ ^[0-9]+$ ]] || {
			sleep "$KNEE_SAMPLE_SECS"
			continue
		}

		if ((el < WARM_SECS)); then
			((f > peak)) && peak=$f
			[[ "$t" =~ ^[0-9]+$ ]] && last_peak_temp="$t"
			printf '  %-6s %-8s %-9s %-6s %s\n' "$el" "$f" "—" "${t:-?}°C" "warming (peak=$peak)"
		else
			((f > peak)) && peak=$f
			pct=$((peak > 0 ? f * 100 / peak : 100))
			if ((pct < THRESH_PCT)); then
				# knee = temp on the LAST full-clock sample: the hottest-zone reading collapses in the
				# same sample the freq drops (bookkeeping artifact), so $t here under-reports the onset.
				((hits++))
				[[ -z "$knee" ]] && knee="${last_peak_temp:-$t}"
				printf '  %-6s %-8s %-9s %-6s %s\n' "$el" "$f" "${pct}%" "${t:-?}°C" "throttle? ($hits/$CONSEC)"
			else
				hits=0
				knee=""
				[[ "$t" =~ ^[0-9]+$ ]] && last_peak_temp="$t"
				printf '  %-6s %-8s %-9s %-6s %s\n' "$el" "$f" "${pct}%" "${t:-?}°C" "at peak"
			fi
			((hits >= CONSEC)) && break
		fi

		if [[ "$t" =~ ^[0-9]+$ ]] && ((t >= SOC_ABORT_C)); then
			stop_load
			die "SAFETY ABORT: hottest zone ${t}°C ≥ ${SOC_ABORT_C}°C before a clear knee — protecting the device.
         If the freq column was still near peak, this chip's knee is higher: raise SOC_ABORT_C and re-run."
		fi
		if ((el >= MAX_SECS)); then
			stop_load
			die "TIMED OUT after ${MAX_SECS}s with no throttle. Almost always the fan was ON — turn it OFF."
		fi
		sleep "$KNEE_SAMPLE_SECS"
	done
	stop_load
	[[ "$knee" =~ ^[0-9]+$ ]] || die "detected throttling but could not read a temperature at the knee — re-run"
	ok "THROTTLE KNEE FOUND: KNEE_C=${knee} (freq fell below ${THRESH_PCT}% of peak ${peak} kHz)"
	printf '%s\n' "$knee" >"$CACHE" && ok "cached → $CACHE"
	KNEE_C="$knee"
}

# ── stage 0: resolve the knee, then derive the thermal ceiling / resume points ──
resolve_knee() {
	banner "RESOLVE KNEE"
	calibrated=0
	if [[ -n "${KNEE_C:-}" && "${KNEE_C}" =~ ^[0-9]+$ ]]; then
		ok "using KNEE_C=$KNEE_C (from environment)"
	elif [[ "${FIND_KNEE:-0}" == "1" || "${RECALIBRATE:-0}" == "1" ]]; then
		warn "CALIBRATE — finding the throttle knee (FAN OFF)"
		find_knee
		calibrated=1
	elif [[ -f "$CACHE" ]] && KNEE_C=$(cat "$CACHE" 2>/dev/null) && [[ "$KNEE_C" =~ ^[0-9]+$ ]]; then
		ok "using KNEE_C=$KNEE_C (cached from a previous calibration; FIND_KNEE=1 to re-find)"
	elif [[ -n "${KNEE_DEFAULT:-}" && "${KNEE_DEFAULT}" =~ ^[0-9]+$ ]]; then
		KNEE_C="$KNEE_DEFAULT"
		ok "using KNEE_C=$KNEE_C (built-in conservative default — set KNEE_C=<n> or FIND_KNEE=1 to override)"
	else
		die "no knee available — this device has NO safe default (its top core throttles early). Calibrate once, FAN OFF:
         FIND_KNEE=1 ./devices/${DEVICE_ID}/run.sh $SAMPLE
       or pass a measured value:
         KNEE_C=<n> ./devices/${DEVICE_ID}/run.sh $SAMPLE"
	fi
	[[ "${KNEE_C}" =~ ^[0-9]+$ ]] || die "KNEE_C must be an integer °C (got '$KNEE_C')"
	TCEIL=$((KNEE_C - KNEE_MARGIN_C))
	TRESUME=$((KNEE_C - 10))
}

# ── fan flip + cooldown (only right after a fresh calibration) ─────────────
fan_flip_cooldown() {
	((calibrated == 1)) || return 0
	banner "FAN FLIP — turn the fan ON now"
	warn "Calibration heated the phone. TURN THE FAN ON, phone flat / screen up / back uncovered."
	[[ "${ASSUME_YES:-0}" != "1" ]] && read -r -p "  Fan is ON? press Enter to start the cooldown wait… " _
	banner "COOLDOWN — waiting for SoC < ${TRESUME}°C"
	local cstart t el
	cstart=$(date +%s)
	while :; do
		t=$(hot_c)
		el=$(($(date +%s) - cstart))
		if [[ "$t" =~ ^[0-9]+$ ]] && ((t < TRESUME)); then
			ok "cooled to ${t}°C — proceeding"
			break
		fi
		((el >= COOLDOWN_MAX)) && die "still ${t:-?}°C after ${COOLDOWN_MAX}s — is the fan on? aborting before measuring hot"
		printf '\r  waiting… SoC=%s°C (target <%s°C, %ss)   ' "${t:-?}" "$TRESUME" "$el"
		sleep 5
	done
}
