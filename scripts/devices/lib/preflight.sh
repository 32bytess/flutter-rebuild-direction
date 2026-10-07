#!/usr/bin/env bash
# lib/preflight.sh — stage 2: the hard power gate. Every check must pass (or it dies):
# charge state (mode-dependent, see below) · battery in band · SoC below the knee · airplane
# mode · animations off · benchmark app installed · every root control actually applied.
# Device knobs: POWER_MODE, CURRENT_UNIT, THERMAL_ZONE, MAX_CHARGE_MA, BAND_LO/HI +
# HARD_LO/HI, BENCH_PKG, PREFLIGHT_MANUAL.
#
# The charge gate is INVERTED by POWER_MODE, because the two protocols require opposite states:
#   charge_on (unrooted phone): a weak USB trickle MUST be present and MUST NOT be fast —
#                                 unchanged behaviour, this is the historical gate.
#   suspend   (rooted Redmi 9T):  charging MUST be cut (input_suspend=1) — so the phone must
#                                 read NOT charging with current_now <= 0, and the fast-charge
#                                 check is meaningless and skipped.
# Note the gate is never *disabled*, only re-pointed: an unmet charge cut is as much a protocol
# violation as an unmet trickle.

preflight() {
	local mode="${POWER_MODE:-charge_on}"
	banner "PREFLIGHT (confirm-all ${mode} gate)"
	local fail=0
	local status ac usb cur_raw amps_mA level charging=0

	status=$(batt_field 'status')
	ac=$(batt_field 'AC powered')
	usb=$(batt_field 'USB powered')
	if [[ "$status" == "2" || "$status" == "5" || "$status" == "Charging" || "$status" == "Full" ||
		"$ac" == "true" || "$usb" == "true" ]]; then charging=1; fi

	cur_raw=$(sh 'cat /sys/class/power_supply/battery/current_now 2>/dev/null' | tr -d '\r') || true

	if [[ "$mode" == "suspend" ]]; then
		# Charge cut protocol: the battery must genuinely be draining.
		if ((charging == 0)); then
			ok "charging cut (status=$status, AC=$ac USB=$usb) — battery is on its own"
		else
			bad "still CHARGING (status=$status, AC=$ac USB=$usb) but POWER_MODE=suspend — input_suspend did not take"
			fail=$((fail + 1))
		fi
		# current_now is REPORTED, NOT GATED. Its sign convention is device-specific and on
		# some kernels carries no direction at all: measured on lime/Redmi 9T (bengal, A12),
		# current_now is UNSIGNED — ~95-141 mA while Charging and ~590-724 mA while
		# Discharging, i.e. positive in both states and *larger* when draining. A
		# "current <= 0 means discharging" gate would therefore fail 100 % of sessions here.
		# The direction is already hard-gated twice and unambiguously: `status` above, and
		# the input_suspend node read back in root_preflight.
		if [[ "$cur_raw" =~ ^-?[0-9]+$ ]]; then
			amps_mA=$(to_mA "$cur_raw")
			log "battery current ${amps_mA} mA [unit=${CURRENT_UNIT:-uA}, magnitude only — not a direction signal]"
		else warn "could not read current_now (informational only)"; fi
	else
		if ((charging == 1)); then
			ok "charging present (status=$status, USB=$usb)"
		else
			bad "NOT charging (status=$status) — this is the charge-on path; connect the cable"
			fail=$((fail + 1))
		fi
		_preflight_fast_charge_gate || fail=$((fail + 1))
	fi

	level=$(batt_field 'level')
	_preflight_common
	((fail == 0)) || die "$fail hard gate(s) FAILED — fix before measuring"
	ok "ALL HARD GATES PASSED — safe to measure (HANDS OFF the screen)"
}

# charge-on only: reject QC/PD step-up and anything above MAX_CHARGE_MA. Returns non-zero on
# a hard failure so the caller can count it. ($cur_raw is read by the caller.)
_preflight_fast_charge_gate() {
	local mv_uV mc_uA amps_mA mag fast

	mv_uV=$(batt_field 'Max charging voltage')
	mc_uA=$(batt_field 'Max charging current')
	# Max charging current from dumpsys is always µA; current_now uses CURRENT_UNIT.
	amps_mA=""
	if [[ "$mc_uA" =~ ^[0-9]+$ && "$mc_uA" != "0" ]]; then
		amps_mA=$((mc_uA / 1000))
	elif [[ "$cur_raw" =~ ^-?[0-9]+$ ]]; then amps_mA=$(to_mA "$cur_raw"); fi
	fast=""
	[[ "$mv_uV" =~ ^[0-9]+$ ]] && ((mv_uV > 5500000)) && fast="voltage $((mv_uV / 1000000)) V > 5 V (QC/PD step-up)"
	if [[ -z "$fast" && "$amps_mA" =~ ^-?[0-9]+$ ]]; then
		mag=${amps_mA#-}
		((mag > MAX_CHARGE_MA)) && fast="current ${amps_mA} mA > ${MAX_CHARGE_MA} mA"
	fi
	if [[ -n "$fast" ]]; then
		bad "FAST CHARGING detected ($fast) — use a plain USB data port, not a wall/QC charger"
		return 1
	elif [[ "$mv_uV" =~ ^[0-9]+$ || "$amps_mA" =~ ^-?[0-9]+$ ]]; then
		ok "not fast-charging (Vmax=${mv_uV:-?}µV, I=${amps_mA:-?} mA [unit=${CURRENT_UNIT:-uA}]; within ${MAX_CHARGE_MA} mA)"
	else warn "could not read charge current/voltage; confirm by hand it's a PC USB port (5 V)"; fi
	return 0
}

# Every gate that is identical in both power modes. Bash locals are dynamically scoped, so
# `fail` / `level` here are the caller's — this counts into the same tally preflight() dies on.
_preflight_common() {
	local temp_mC temp_C zlabel air anim_bad s v bm line

	if [[ "$level" =~ ^[0-9]+$ ]]; then
		if ((level >= HARD_LO && level <= HARD_HI)); then
			((level >= BAND_LO && level <= BAND_HI)) && ok "battery ${level}% (ideal ${BAND_LO}-${BAND_HI}%)" ||
				warn "battery ${level}% inside hard band but outside ideal ${BAND_LO}-${BAND_HI}%"
		else
			bad "battery ${level}% outside ${HARD_LO}-${HARD_HI}% — heat rises at both extremes"
			fail=$((fail + 1))
		fi
	else warn "could not read battery level"; fi

	temp_mC=$(soc_temp_mC) || true
	if [[ -z "${KNEE_C:-}" ]]; then
		bad "KNEE_C not set — cannot gate temperature. MEASURE it: FIND_KNEE=1 ./devices/${DEVICE_ID}/run.sh"
		fail=$((fail + 1))
	elif [[ "$temp_mC" =~ ^[0-9]+$ ]]; then
		temp_C=$((temp_mC / 1000))
		zlabel=${THERMAL_ZONE:+zone$THERMAL_ZONE }
		((temp_C < TCEIL)) && ok "SoC ${zlabel}${temp_C}°C < ${TCEIL}°C (knee ${KNEE_C} − ${KNEE_MARGIN_C}) — sub-throttle" ||
			{
				bad "SoC ${zlabel}${temp_C}°C >= ${TCEIL}°C — too hot to start; cool down / check the fan"
				fail=$((fail + 1))
			}
	else warn "could not read thermal zones; verify SoC temp manually"; fi

	air=$(sh settings get global airplane_mode_on | tr -d '\r')
	[[ "$air" == "1" ]] && ok "airplane mode on" || {
		bad "airplane mode OFF"
		fail=$((fail + 1))
	}

	anim_bad=""
	for s in window_animation_scale transition_animation_scale animator_duration_scale; do
		v=$(sh settings get global "$s" | tr -d '\r')
		[[ "$v" == "0" || "$v" == "0.0" ]] || anim_bad+="${s%%_*}=$v "
	done
	[[ -z "$anim_bad" ]] && ok "animations off (all scales)" || {
		bad "animations on ($anim_bad)"
		fail=$((fail + 1))
	}

	bm=$(sh settings get system screen_brightness_mode | tr -d '\r')
	[[ "$bm" == "0" ]] && ok "auto-brightness off" || warn "auto-brightness on"

	if [[ "$(sh pm list packages | tr -d '\r' | grep -Fc "package:$BENCH_PKG" || true)" -gt 0 ]]; then
		ok "benchmark app installed ($BENCH_PKG)"
		[[ "$(sh dumpsys deviceidle whitelist | tr -d '\r' | grep -Fc "$BENCH_PKG" || true)" -gt 0 ]] &&
			ok "app is Doze-whitelisted" || warn "app NOT in Doze whitelist"
	else
		bad "benchmark app $BENCH_PKG not installed"
		fail=$((fail + 1))
	fi

	# Root controls (no-op without root): the governor pin, the cpuset isolation and the charge
	# cut are HARD gates — a pin that silently did not stick invalidates the whole session, so
	# its failures are counted here rather than left as a warning nobody reads.
	local rootfails=0
	root_preflight || rootfails=$?
	((rootfails > 0)) && fail=$((fail + rootfails))

	for line in "${PREFLIGHT_MANUAL[@]}"; do warn "$line"; done
}
