#!/usr/bin/env bash
# lib/measure.sh — stage 3: run the Python pipeline under a telemetry watchdog.
# Samples battery/thermal to a CSV while `device_runner run` drives the profiled build;
# SIGSTOP/CONT-pauses the runner above the thermal ceiling (TCEIL) and resumes below
# TRESUME; SIGINTs it (gracefully, resumable) if the battery hits RUN_FLOOR.

# append one telemetry row tagged with $1 (event); needs the globals CSV + MSTART
tm_sample() {
	local now el
	now=$(date +%s)
	el=$((now - MSTART))
	printf '%s,%s,%s,%s,%s,%s,%s,%s,%s\n' "$(date -Iseconds)" "$now" "$el" \
		"$(tm_batt_level)" "$(tm_batt_status)" "$(tm_batt_temp_c)" "$(tm_soc_temp_c)" "$(tm_current_ma)" "$1" >>"$CSV"
}

# Decide which raw session this invocation writes into: resume an existing one, or start a fresh
# one. Echoes the session name; the reason goes to stderr so it stays visible.
#
# Resuming means REUSING the session dir — the runner only skips executions it finds already
# complete inside the session it is given (scripts/device_runner/runner.py), so a fresh stamp
# would silently re-measure everything. Completeness is decided by `device_runner status`, not
# here, so "done" has exactly one definition (scripts/device_runner/capture.py).
#
# Precedence:
#   1. BENCH_RAW_SESSION=<stamp>   the surgical override — this exact dir, no questions asked
#   2. --fresh / BENCH_RESUME=0    always a new stamp
#   3. --resume                    `status --pick-session`: the group's MOST COMPLETE session dir,
#                                  newest breaking a tie. Continues a session that is already
#                                  complete (nothing left to measure, so the runner skips
#                                  everything and exits) and one where nothing completed at all —
#                                  the two cases 4. deliberately does not.
#   4. no flag                     the historical heuristic, unchanged: resume ONLY a session that
#                                  is partly complete (0 < complete < expected).
resolve_session() {
	local fresh group progress complete present expected picked
	fresh=$(date +%Y%m%d-%H%M%S)
	group="${ACTIVE_SAMPLE_GROUP:-}"

	# explicit override wins, unchanged
	if [[ -n "${BENCH_RAW_SESSION:-}" ]]; then
		echo >&2 "raw session ← BENCH_RAW_SESSION=${BENCH_RAW_SESSION}"
		echo "$BENCH_RAW_SESSION"
		return
	fi
	# `all` has no single group dir to inspect; opt-out via --fresh or BENCH_RESUME=0
	# (pipeline.sh refuses --resume with `all` outright, so this cannot silence that flag.)
	if [[ -z "$group" || "${RESUME_OPT:-}" == "0" || "${BENCH_RESUME:-1}" == "0" ]]; then
		echo >&2 "raw session → $fresh (new)"
		echo "$fresh"
		return
	fi

	# --resume: Python picks WHICH dir, for the same reason it decides what "complete" means.
	# RUNNER_CORPUS_ARGS is passed for the same reason the probe below passes it — without
	# --samples-root the pick would be made against arm 1's raw/ tree.
	if [[ "${RESUME_OPT:-}" == "1" ]]; then
		picked=$(python -m scripts.device_runner status --group "$group" --device "$DEVICE_ID" \
			"${RUNNER_CORPUS_ARGS[@]}" --executions "$EXECUTIONS" --pick-session) || picked=""
		if [[ -n "$picked" ]]; then
			echo >&2 "raw session ← $picked (--resume; only the executions missing from it are measured)"
			echo "$picked"
			return
		fi
		echo >&2 "raw session → $fresh (new — --resume found no session to continue)"
		echo "$fresh"
		return
	fi

	# `status --quiet` -> "<complete>/<expected>"; it owns both the completeness rule and the
	# target count, so this stays a pure yes/no on reusing the newest session dir.
	# --device is passed explicitly rather than relying on BENCH_DEVICE_ID: the shell resolves
	# raw/ paths from $DEVICE_ID, so handing Python the same value keeps the two from ever
	# inspecting different devices' corpora.
	# RUNNER_CORPUS_ARGS carries --samples-root (and --eligible-only when the corpus has a
	# screening record). Without it `status` would count arm 1's targets — for an arm-2 group
	# it would find no samples/<group> at all, report nothing, and every session would restart
	# from zero instead of resuming.
	progress=$(python -m scripts.device_runner status --group "$group" --device "$DEVICE_ID" \
		"${RUNNER_CORPUS_ARGS[@]}" --executions "$EXECUTIONS" --quiet 2>/dev/null) || progress=""
	complete="${progress%%/*}"
	expected="${progress##*/}"
	[[ "$complete" =~ ^[0-9]+$ ]] || complete=0
	[[ "$expected" =~ ^[0-9]+$ ]] || expected=0

	if ((expected > 0 && complete > 0 && complete < expected)); then
		local prev
		prev=$(ls -1 "${BENCH_DATASET_DIR:-dataset}/${group}/${DEVICE_ID}/raw" 2>/dev/null | sort | tail -1)
		if [[ -n "$prev" ]]; then
			echo >&2 "raw session ← $prev (RESUMING — ${complete}/${expected} complete; the rest, plus any incomplete capture, will be measured)"
			echo "$prev"
			return
		fi
	fi
	((expected > 0 && complete >= expected)) &&
		echo >&2 "previous session is complete (${complete}/${expected}) — starting a new one"
	echo >&2 "raw session → $fresh (new)"
	echo "$fresh"
}

measure() {
	banner "MEASURE $SCOPE (HANDS OFF the screen)"
	cd "$BENCH_REPO" || die "cannot cd to $BENCH_REPO"
	local RAW_SESSION TELEMETRY_DIR
	RAW_SESSION=$(resolve_session)
	ACTIVE_RAW_SESSION="$RAW_SESSION"
	if [[ -n "${ACTIVE_SAMPLE_GROUP:-}" ]]; then
		TELEMETRY_DIR="${BENCH_DATASET_DIR:-dataset}/${ACTIVE_SAMPLE_GROUP}/${DEVICE_ID}/telemetry"
	else
		TELEMETRY_DIR="${BENCH_DATASET_DIR:-dataset}/_meta/${DEVICE_ID}/telemetry"
	fi
	mkdir -p "$TELEMETRY_DIR"
	CSV="${TELEMETRY_DIR}/telemetry-${RAW_SESSION}.csv"
	ACTIVE_TELEMETRY_PATH="$CSV"
	# APPEND on resume. Truncating here is what split one redmi9t session's telemetry across
	# two files: the resumed half overwrote the first, and the earlier rows only survived
	# because the pre-fix code happened to write them under a different path.
	if [[ -s "$CSV" ]]; then
		echo "telemetry ← appending to existing $CSV ($(($(wc -l <"$CSV") - 1)) rows)"
	else
		echo "iso_ts,epoch,elapsed_s,batt_level,batt_status,batt_temp_c,soc_temp_c,current_ma,event" >"$CSV"
	fi
	echo "telemetry → $BENCH_REPO/$CSV"
	echo "raw session → $RAW_SESSION"

	set -m # job control: give the runner its own process group so we can SIGSTOP/CONT it
	# RUNNER_RUN_ARGS is `run`-only (--screenshots today) and is deliberately NOT passed to
	# the `status` call above, which shares RUNNER_CORPUS_ARGS but has no such flag. The
	# `${a[@]+"${a[@]}"}` form keeps an empty array from tripping `set -u`.
	BENCH_RAW_SESSION="$RAW_SESSION" python -m scripts.device_runner run "${WT[@]}" \
		"${RUNNER_CORPUS_ARGS[@]}" ${RUNNER_RUN_ARGS[@]+"${RUNNER_RUN_ARGS[@]}"} \
		--executions "$EXECUTIONS" --seed "$SEED" </dev/null &
	RUNNER_PID=$!
	# elapsed_s stays continuous across a resume: re-anchor on the first row already in the
	# CSV, so the column keeps meaning "seconds since this session began" instead of restarting
	# at 0 mid-file. (epoch is absolute either way and is what the splitter joins on.)
	MSTART=$(awk -F, 'NR==2{print $2; exit}' "$CSV")
	[[ "$MSTART" =~ ^[0-9]+$ ]] || MSTART=$(date +%s)
	local paused=0 lvl soc hot cool
	STOP_REASON=""
	while kill -0 "$RUNNER_PID" 2>/dev/null; do
		tm_sample "run"
		lvl=$(tm_batt_level)
		soc=$(tm_soc_temp_c)
		# battery floor → graceful stop (runner is resumable; won't trip while charging)
		if [[ "$lvl" =~ ^[0-9]+$ ]] && ((lvl <= RUN_FLOOR)); then
			echo
			echo "!! battery ${lvl}% hit floor ${RUN_FLOOR}% — stopping the run (resumable)."
			tm_sample "battery_floor_stop"
			STOP_REASON="battery_floor"
			kill -INT -- -"$RUNNER_PID" 2>/dev/null
			break
		fi
		# thermal ceiling → pause (SIGSTOP); resume when cooled below TRESUME
		if [[ -n "$soc" ]]; then
			hot=$(awk -v s="$soc" -v c="$TCEIL" 'BEGIN{print (s>=c)?1:0}')
			cool=$(awk -v s="$soc" -v r="$TRESUME" 'BEGIN{print (s<=r)?1:0}')
			if ((paused == 0)) && ((hot == 1)); then
				echo
				echo "~~ SoC ${soc}°C ≥ ${TCEIL}°C — pausing to cool."
				tm_sample "thermal_pause"
				kill -STOP -- -"$RUNNER_PID" 2>/dev/null
				paused=1
			elif ((paused == 1)) && ((cool == 1)); then
				echo "~~ SoC ${soc}°C ≤ ${TRESUME}°C — resuming."
				tm_sample "thermal_resume"
				kill -CONT -- -"$RUNNER_PID" 2>/dev/null
				paused=0
			fi
		fi
		sleep "$SAMPLE_SECS"
	done
	((paused == 1)) && kill -CONT -- -"$RUNNER_PID" 2>/dev/null # never leave it stopped
	wait "$RUNNER_PID" 2>/dev/null
	RC=$?
	tm_sample "end"
	set +m

	echo
	echo "== telemetry summary =="
	awk -F, 'NR>1 && $4!=""{if(b0=="")b0=$4; b1=$4}
	         NR>1 && $7!=""{if($7>tmax)tmax=$7; if(tmin==""||$7<tmin)tmin=$7}
	         END{printf "  battery: %s%% → %s%%\n  SoC temp: min %.1f°C  max %.1f°C\n", b0,b1,tmin,tmax}' "$CSV"
	[[ -n "$STOP_REASON" ]] && echo "  stopped early: $STOP_REASON → recharge and re-run the SAME command (resumable)."
	# rc 2 is the runner's DATA-side verdict (`SessionAbort`, or roles quarantined): this group
	# is not measured, but the phone is healthy and the groups queued behind it still can be.
	# Return, and let pipeline.sh record the group and move on. Everything else — a battery
	# floor stop, which SIGINTs the runner and comes back 130, a crash, a dead adb link — is
	# still fatal on the spot, because continuing would measure under conditions we did not
	# check or on a device we no longer control.
	MEASURE_FAILED_REASON=""
	if ((RC == 2)); then
		MEASURE_FAILED_REASON="${STOP_REASON:-session abort or quarantined role(s) — see the runner log above}"
		bad "group not measured (rc=2): $MEASURE_FAILED_REASON"
		return 1
	fi
	((RC == 0)) || die "measurement run failed (rc=$RC). Runner is resumable — re-run to continue."
	ok "measurement complete"
	return 0
}
