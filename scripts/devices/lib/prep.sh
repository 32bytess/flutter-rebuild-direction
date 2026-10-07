#!/usr/bin/env bash
# lib/prep.sh — stage 1: put the device in a measurement-clean state.
# Device knobs: BLOAT_LABEL + BLOAT_PKGS (reversible per-user disables), BENCH_PKG,
# BRIGHTNESS, PIN_60HZ (adaptive-refresh guard), PREP_MANUAL (on-device notes).

prep_device() {
	local extras="${BLOAT_LABEL:-bloat}"
	((${PIN_60HZ:-0} == 1)) && extras+=", 60 Hz"
	banner "PREP (airplane, animations, screen, bg-kill, ${extras}, Doze whitelist)"

	log "[1] charging: expecting a weak PC-port trickle (charge-on) — preflight gates it below."
	log "[2] background: kill all, neutralise ${BLOAT_LABEL:-bloat}, whitelist benchmark app"
	sh am kill-all >/dev/null 2>&1 || true
	for p in "${BLOAT_PKGS[@]}"; do sh pm disable-user --user 0 "$p" >/dev/null 2>&1 && log "disabled $p"; done
	sh dumpsys deviceidle whitelist "+$BENCH_PKG" >/dev/null 2>&1 || warn "could not whitelist $BENCH_PKG"
	log "[3] radios off (airplane mode)"
	sh cmd connectivity airplane-mode enable >/dev/null 2>&1
	log "[4] animations off"
	sh settings put global window_animation_scale 0
	sh settings put global transition_animation_scale 0
	sh settings put global animator_duration_scale 0
	log "[5] screen: auto-brightness off, fixed low, stay awake"
	sh settings put system screen_brightness_mode 0
	sh settings put system screen_brightness "$BRIGHTNESS"
	ORIGINAL_SCREEN_OFF_TIMEOUT="$(sh settings get system screen_off_timeout 2>/dev/null | tr -d '\r' || true)"
	sh settings put system screen_off_timeout "$SCREEN_OFF_TIMEOUT_MS" 2>/dev/null ||
		warn "could not set screen_off_timeout=$SCREEN_OFF_TIMEOUT_MS"
	sh svc power stayon true
	sh input keyevent KEYCODE_WAKEUP >/dev/null 2>&1 || sh input keyevent 224 >/dev/null 2>&1 || true
	sh wm dismiss-keyguard >/dev/null 2>&1 || true
	log "[6] quiet installs: disable Play-Protect adb-install scanning"
	sh settings put global verifier_verify_adb_installs 0 2>/dev/null || true
	sh settings put global package_verifier_enable 0 2>/dev/null || true
	sh settings put global upload_apk_enable 0 2>/dev/null || true
	if ((${PIN_60HZ:-0} == 1)); then
		log "[7] refresh rate: pin 60 Hz so adaptive-refresh frame work can't contaminate buildSpan"
		sh settings put system peak_refresh_rate 60 2>/dev/null || true
		sh settings put system min_refresh_rate 60 2>/dev/null || true
	fi
	PREPPED=1

	# Device-specific steps that have no adb equivalent (must be set on the phone once).
	local line
	for line in "${PREP_MANUAL[@]}"; do warn "$line"; done
	ok "prep done"
}
