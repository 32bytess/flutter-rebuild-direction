#!/usr/bin/env bash
# lib/report.sh — stage 4 (parse → medians) and the closing manual acceptance gates.
# Device knob: ACCEPTANCE_EXTRA (optional extra note under gate 1).
#
# Labelling is deliberately NOT a stage here: contrasts are decided in the analysis path
# (analysis/01_data_and_labels.ipynb), so this script stops at normalized measurements.

parse_captures() {
	banner "PARSE (warmup=$WARMUP) → medians"
	local parse_args=(--warmup "$WARMUP")
	[[ -n "${ACTIVE_RAW_SESSION:-}" ]] && parse_args+=(--session "$ACTIVE_RAW_SESSION")
	# Returns rather than dies: a group whose measurement failed may have no complete capture
	# to parse, and that must not take the groups queued behind it down. The caller decides —
	# pipeline.sh still dies on a parse failure for a group that measured cleanly.
	python -m scripts.device_runner parse "${parse_args[@]}" || {
		bad "parse failed"
		return 1
	}
	# Per-execution telemetry: slice the flat session CSV into one CSV per measured execution
	# so a buildSpan median can be joined to the thermal trajectory it was measured under.
	# Derived and re-runnable — a failure here must not cost us the measurements.
	if [[ -n "${ACTIVE_SAMPLE_GROUP:-}" && -n "${ACTIVE_RAW_SESSION:-}" ]]; then
		banner "TELEMETRY → per-execution CSVs"
		python -m scripts.device_runner telemetry --group "$ACTIVE_SAMPLE_GROUP" \
			--session "$ACTIVE_RAW_SESSION" --check ||
			warn "telemetry split failed — measurements are unaffected; re-run: python -m scripts.device_runner telemetry --group $ACTIVE_SAMPLE_GROUP --session $ACTIVE_RAW_SESSION"
	fi
	ok "parse done → $BENCH_REPO/${BENCH_DATASET_DIR:-dataset}/"
	return 0
}

acceptance_gates() {
	banner "DONE — run the two acceptance gates BEFORE trusting these measurements"
	printf '  1. THERMAL-DRIFT GATE: plot soc_temp_c vs elapsed_s from the newest\n'
	if [[ -n "${ACTIVE_TELEMETRY_PATH:-}" ]]; then
		printf '     %s/%s\n' "$BENCH_REPO" "$ACTIVE_TELEMETRY_PATH"
	else
		printf '     %s/%s/<group>/%s/telemetry/telemetry-*.csv\n' \
			"$BENCH_REPO" "${BENCH_DATASET_DIR:-dataset}" "$DEVICE_ID"
	fi
	printf '     → must be FLAT and entirely below %s°C. A monotonic climb ⇒ discard this session.\n' "$KNEE_C"
	if [[ -n "${ACTIVE_SAMPLE_GROUP:-}" && -n "${ACTIVE_RAW_SESSION:-}" ]]; then
		printf '     per-execution view (soc_min/soc_mean/soc_max per run, one row per execution):\n'
		printf '     %s/%s/%s/%s/telemetry/%s/index.jsonl\n' \
			"$BENCH_REPO" "${BENCH_DATASET_DIR:-dataset}" "$ACTIVE_SAMPLE_GROUP" "$DEVICE_ID" "$ACTIVE_RAW_SESSION"
	fi
	[[ -n "${ACCEPTANCE_EXTRA:-}" ]] && printf '     %s\n' "$ACCEPTANCE_EXTRA"
	printf '  2. A-A NULL TEST: measure base vs itself under this setup; labelling it in\n'
	printf '     analysis/01_data_and_labels.ipynb MUST come out Stable (0).\n'
	printf '     If it drifts, the charge-on noise is too high — improve cooling or use a taped-VBUS cable.\n\n'
	printf '  outputs (per sample group): %s/%s/<group>/{static,rebuilds,performance}.jsonl\n' \
		"$BENCH_REPO" "${BENCH_DATASET_DIR:-dataset}"
	printf '  NOTE: performance.jsonl carries every execution, including status=failed ones.\n'
	printf '        Filter status == "ok" before aggregating. Labelling happens in analysis/notebooks/.\n'
	# cleanup() runs on EXIT → device restored automatically
}
