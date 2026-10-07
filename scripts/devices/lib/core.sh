#!/usr/bin/env bash
# lib/core.sh — UI helpers + adb wrappers shared by every device pipeline.
# Sourced (never executed) by devices/lib/pipeline.sh. Relies on the global $SER
# (device serial, resolved in pipeline.sh) at call time.

# ── pretty output ──────────────────────────────────────────────────────────
banner() { printf '\n\033[1m======== %s ========\033[0m\n' "$*"; }
log() { printf '  %s\n' "$*"; }
ok() { printf '  \033[32m✓\033[0m %s\n' "$*"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$*"; }
bad() { printf '  \033[31m✗\033[0m %s\n' "$*"; }
die() {
	printf '\n\033[31m✗ %s\033[0m\n' "$*" >&2
	exit 1
}

# ── adb, scoped to the selected device ─────────────────────────────────────
adbx() { adb ${SER:+-s "$SER"} "$@"; }
sh() { adbx shell "$@"; }
