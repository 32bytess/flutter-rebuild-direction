#!/usr/bin/env bash
# lib/telemetry.sh — root-free battery / thermal / current readers.
# The generalised forms honour two device-config knobs so both phones share one path:
#   THERMAL_ZONE   pinned thermal_zone index for the SoC/CPU ("" = hottest zone)
#   CURRENT_UNIT   unit of /sys/.../battery/current_now on this device (uA|mA)

# one field out of `dumpsys battery`
batt_field() { sh dumpsys battery | awk -F': ' -v k="$1" '$1 ~ k {print $2; exit}' | tr -d '\r'; }

# SoC temp in milli-°C — the pinned THERMAL_ZONE if set, else the hottest zone
soc_temp_mC() {
	if [[ -n "${THERMAL_ZONE:-}" ]]; then
		sh "cat /sys/class/thermal/thermal_zone${THERMAL_ZONE}/temp 2>/dev/null" | tr -d '\r'
	else
		sh 'cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null' | sort -n | tail -1 | tr -d '\r'
	fi
}

# SoC temp as an integer °C (used by the knee finder / cooldown loops)
hot_c() {
	local m
	m=$(soc_temp_mC) || true
	[[ "$m" =~ ^[0-9]+$ ]] && echo $((m / 1000)) || echo ""
}

# raw current_now → mA honouring the device's CURRENT_UNIT (uA default)
to_mA() {
	local r="$1"
	[[ "$r" =~ ^-?[0-9]+$ ]] || {
		echo ""
		return
	}
	case "${CURRENT_UNIT:-uA}" in mA) echo "$r" ;; *) echo $((r / 1000)) ;; esac
}

# ── CSV telemetry readers ──────────────────────────────────────────────────
tm_batt_level() { sh dumpsys battery | awk -F': ' '/  level/{print $2; exit}' | tr -d '\r'; }
tm_batt_status() { sh dumpsys battery | awk -F': ' '/  status/{print $2; exit}' | tr -d '\r'; }
tm_batt_temp_c() {
	local t
	t=$(sh dumpsys battery | awk -F': ' '/temperature/{print $2; exit}' | tr -d '\r')
	[[ "$t" =~ ^-?[0-9]+$ ]] && awk -v v="$t" 'BEGIN{printf "%.1f", v/10}'
}
tm_soc_temp_c() {
	local m
	m=$(soc_temp_mC)
	[[ "$m" =~ ^[0-9]+$ ]] && awk -v v="$m" 'BEGIN{printf "%.1f", v/1000}'
}
tm_current_ma() {
	local u
	u=$(sh 'cat /sys/class/power_supply/battery/current_now 2>/dev/null' | tr -d '\r')
	[[ "$u" =~ ^-?[0-9]+$ ]] && to_mA "$u"
}
