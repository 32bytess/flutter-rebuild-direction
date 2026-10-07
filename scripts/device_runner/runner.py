"""Measurement collector: run every sample (base + mutations) under the default (unrooted) protocol.

Phase 1 (static): ONE `spm analyze` over samples/ in place, indexed per target — no
transplant needed, the features are identical either way.
Phase 2 (runtime), per target: assemble (transplant target + its dependencies into lib/)
-> `spm run` (inject SpmState from the cached row, drive in profile mode, N_REBUILDS
profiled rebuilds, revert). Executions are interleaved across targets and gated by a
thermal cooldown. Raw stdout is captured per execution for off-device parsing.

    python -m scripts.device_runner run [--widget-type NN] [--executions 5] [--seed 42]

This only COLLECTS raw captures + static features. `parse.py` turns raw -> performance.jsonl.
Labelling (base vs mutation contrasts) is not part of this package — see
`analysis/01_data_and_labels.ipynb`. See MEASUREMENT_RUNNER_PLAN.md.
"""

import argparse
import collections
import hashlib
import json
import logging
import os
import random
import re
import shutil
import signal
import subprocess
import time
from datetime import datetime, timezone
from pathlib import Path, PurePosixPath

from .. import fixture_gate, spm
from . import capture, config, gate, transplant

_FAILURE_PATTERNS: list[tuple[str, str]] = [
    (r"pumpAndSettle timed out", "pump_timeout"),
    # Before the generic compile bucket: `flutter analyze` refusing the staged code is a
    # STAGING verdict, not a runtime one, and naming it is what tells a reader the role
    # never reached the device.
    (r"FlutterAnalyzeFailure", "analyze_error"),
    (r"ProviderNotFoundException|ProviderNotFound", "provider_missing"),
    (r"RenderFlex overflowed|unbounded|BoxConstraints forces an infinite", "layout_error"),
    (
        r"Error:.*generated_widget\.dart|Undefined name|not a subtype of type|Couldn't resolve the package",
        "compile_error",
    ),
]
_PERF_LINE = re.compile(r"\[SPM:perf\]\s+\S+\s+buildSpan:\s+\d+")
_TIMEOUT_MARKER = "[runner] command timed out"
_WAKE_WARNED = False


def _classify(output: str) -> str:
    for pattern, label in _FAILURE_PATTERNS:
        if re.search(pattern, output, re.IGNORECASE):
            return label
    return "runtime_error"


# ----------------------------------------------------------------------------- io helpers
def _read_jsonl(path: Path) -> list[dict]:
    if not path.exists():
        return []
    out = []
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if line:
            out.append(json.loads(line))
    return out


def _append_jsonl(record: dict, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "a", encoding="utf-8") as f:
        f.write(json.dumps(record, ensure_ascii=False) + "\n")


# ----------------------------------------------------------------------------- discovery
_PAIR_ENDPOINTS = re.compile(r"@([0-9a-f]{8})\.\.([0-9a-f]{8})$")


def awaiting_fixture_groups(root: Path) -> set[str]:
    """The groups R16 flagged as awaiting a hand-authored fixture, per the root's own record.

    Empty when there is no `exclusions.json` -- arm 1's `samples/` has no screening record, and
    a corpus that never screened has nothing awaiting. That is the one difference from
    `eligible_endpoints`, which RAISES on a missing file: there, absence means the caller asked
    for a filter the corpus cannot supply; here it means there is nothing to skip.
    """
    path = root / "exclusions.json"
    if not path.is_file():
        return set()
    doc = json.loads(path.read_text(encoding="utf-8"))
    return set(doc.get("unfillable") or {})


def eligible_endpoints(root: Path) -> dict[str, set[str]]:
    """group -> the revision sha8s that are an endpoint of some ELIGIBLE contrast.

    Derived from the pairs, never from `groups[gid]["eligible"]`. The two disagree: `1793` is
    `eligible: false` at group level yet carries one eligible pair -- it is the sole entry in
    `carried_for_pairs` -- so filtering on the group flag drops a real contrast and silently
    lands the corpus at 214/50. Deriving from pairs reproduces the 51 on-disk directories
    exactly, in both directions.

    Every failure here is fatal rather than a warning. The alternative to raising is measuring
    a quietly smaller corpus, which is the failure this whole filter exists to prevent.
    """
    path = root / "exclusions.json"
    if not path.is_file():
        raise SystemExit(
            f"--eligible-only needs {path}, which does not exist. Arm 1's samples/ has no "
            f"screening record; run without the flag to measure every role under {root}.")
    doc = json.loads(path.read_text(encoding="utf-8"))
    pairs = [p for p in doc.get("pairs", []) if p.get("verdict") == "eligible"]

    out: dict[str, set[str]] = {}
    for pair in pairs:
        m = _PAIR_ENDPOINTS.search(pair["pair_id"])
        if not m:
            raise SystemExit(
                f"cannot read revision endpoints from pair_id {pair['pair_id']!r}. The filter "
                "couples that suffix to the rev_NNN_<sha8>.dart filename; if the id format "
                "changed, this filter must be updated, not bypassed.")
        out.setdefault(pair["group"], set()).update(m.groups())

    # Cross-check against the file's own totals. `test_real_corpus.py` caught corpus drift once
    # by failing on unmodified code; this gets the same property rather than trusting a count.
    totals = doc.get("totals", {})
    for key, got in (("eligible_pairs", len(pairs)), ("eligible_mover_scopes", len(out))):
        want = totals.get(key)
        if want is not None and want != got:
            raise SystemExit(
                f"{path}: derived {got} for {key}, but its own totals say {want}. The screening "
                "record disagrees with itself -- re-screen before measuring.")
    return out


def read_role_list(path: Path) -> set[tuple[str, str]]:
    """`<group>/<role>` per line -> the exact set of targets to measure. `#` comments allowed.

    A role-level selector, because the two selectors that already exist cannot express the set
    a VALIDATION pass needs. `--eligible-only` takes the endpoints of eligible contrasts, and
    `--widget-type` takes a whole group; the roles worth photographing before a campaign are
    neither. 44 of the 106 roles R21 condemned on 2026-09-15 are not endpoints -- they stopped
    being endpoints BECAUSE R21 excluded their contrasts -- so an endpoints-only pass would
    have validated none of the repairs in 13 of the 19 repaired groups, `2411` included.

    Not a measurement selector. A campaign measures what the screening record names; this is
    for a census, where the set is "what I need to look at" and comes from a script.
    """
    out: set[tuple[str, str]] = set()
    for n, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        line = line.split("#", 1)[0].strip()
        if not line:
            continue
        if line.count("/") != 1:
            raise SystemExit(f"{path}:{n}: expected `<group>/<role>`, got {line!r}")
        gid, role = line.split("/")
        out.add((gid, role))
    if not out:
        raise SystemExit(f"{path} names no roles.")
    return out


def discover_targets(widget_type: str | None, root: Path | None = None,
                     eligible_only: bool = False,
                     roles: set[tuple[str, str]] | None = None) -> list[dict]:
    """Every base, mutation or revision .dart under <root>/<group>/ is one target.

    sample_id = "<group>/<role>", e.g. "01/base", "01/mutation_3", "0041/rev_002_5f5e7e41".
    This is the dataset's primary key: `instanceId` cannot be (all targets transplant to the
    same class/file, so they hash to the same id).

    Arm 1 (`samples/`) ships `base` + `mutation_*`; arm 2 (`new_samples/`) ships `rev_NNN_<sha8>`
    and no base -- each revision is screened on its own content and the pair records name which
    two are contrasted. `root` defaults to `config.SAMPLES_ROOT` so existing callers are
    unaffected.
    """
    root = root or config.SAMPLES_ROOT
    if widget_type:
        dirs = [root / widget_type]
    else:
        dirs = sorted(d for d in root.iterdir() if d.is_dir())

    # Opt-in: `discover_targets` globs every rev_*.dart, and on an unpruned corpus 262 of the
    # 439 are an endpoint of no eligible contrast -- mined and screened, never measured.
    # Measuring them costs ~3,930 executions and produces rows nothing consumes. On a corpus
    # `screen_samples --prune-to-endpoints` has narrowed this filter finds nothing left to
    # remove, which is the point: the two derive the same set from the same pairs, and the
    # cheap one agreeing with the expensive one is a check worth keeping.
    keep = eligible_endpoints(root) if eligible_only else None

    targets: list[dict] = []
    for d in dirs:
        deps = d / "dependencies.dart"
        for f in sorted(d.glob("*.dart")):
            role = f.stem
            if role == "dependencies":
                continue
            if (
                role != config.BASE_ROLE
                and not role.startswith(config.MUTATION_PREFIX)
                and not role.startswith(config.REVISION_PREFIX)
            ):
                continue
            if keep is not None and role.startswith(config.REVISION_PREFIX):
                if role.rsplit("_", 1)[-1] not in keep.get(d.name, set()):
                    continue
            # Applied after the endpoint filter, so passing both narrows to the intersection.
            # The census set is the UNION of the endpoints and the roles R21 condemned, which
            # no intersection can express -- so a validation pass passes `--roles` ALONE and
            # the file is the whole selector. That is safe because the file is explicit and
            # written by a script whose criterion is in the run log, not inferred here.
            if roles is not None and (d.name, role) not in roles:
                continue
            targets.append(
                {
                    "group": d.name,
                    "role": role,
                    "sample_id": f"{d.name}/{role}",
                    "target_path": f,
                    "deps_path": deps if deps.exists() else None,
                    "safe": f"{d.name}__{role}",
                }
            )

    if keep is not None and not widget_type and roles is None:
        # Every endpoint the screening record names must have produced a target.
        # Skipped under `--roles`: narrowing to a named set is the request, so an endpoint
        # left out of the file is not a divergence between the corpus and the record. A missing file
        # means the corpus and the record have diverged, and the contrast it belongs to cannot
        # be formed -- measuring the rest would silently drop it. Whole-root runs only: a
        # `--widget-type` run is scoped to one group on purpose, so the other 50 groups'
        # endpoints being absent from `targets` is the request, not a divergence.
        found = {(t["group"], t["role"].rsplit("_", 1)[-1]) for t in targets}
        missing = sorted(
            f"{gid}/{sha}" for gid, shas in keep.items() for sha in shas
            if (gid, sha) not in found
        )
        if missing:
            raise SystemExit(
                f"{len(missing)} eligible endpoint(s) have no rev_*.dart under {root}: "
                f"{', '.join(missing[:8])}{' ...' if len(missing) > 8 else ''}")
    return targets


# ----------------------------------------------------------------------------- assembly
def assemble(target: dict) -> bool:
    """Transplant target + dependencies into lib/ so the app compiles. Returns whether the
    group fixture was staged -- see `transplant.write_transplant` for the one role it is not.

    target.dart -> lib/generated_widget.dart (keeps `import 'dependencies.dart'`)
    dependencies.dart -> lib/dependencies.dart.

    What staging means -- which import is rewritten, and when a part file exempts itself --
    lives in `transplant`, because `scripts/reset_lib.sh` stages the same files by hand and
    the two answers must not drift.
    """
    return transplant.write_transplant(
        target["target_path"],
        target["deps_path"] or None,
        config.ACTIVE_WIDGET_PATH,
        config.ACTIVE_DEPS_PATH,
    )


def restore_active(original_widget: str) -> None:
    config.ACTIVE_WIDGET_PATH.write_text(original_widget, encoding="utf-8")
    if config.ACTIVE_DEPS_PATH.exists():
        config.ACTIVE_DEPS_PATH.unlink()


# ----------------------------------------------------------------------------- spm calls
def _stream_text(value: str | bytes | None) -> str:
    if value is None:
        return ""
    if isinstance(value, bytes):
        return value.decode(errors="replace")
    return value


def _run(cmd: list[str], timeout_s: int | None = None,
         env: dict[str, str] | None = None) -> tuple[bool, str]:
    """Run a subprocess, killing its WHOLE process tree if it overruns `timeout_s`.

    `dart run spm:spm run` is only the root of a tree: it spawns `flutter drive`, which spawns
    gradle/adb children. Killing the root alone (what subprocess.run's timeout does) orphans
    that tree — an abandoned `flutter drive` keeps the device port forwarded and the app
    process alive, so EVERY later execution hangs the same way and the next resume dies at the
    same point. Running the child in its own session and signalling the process GROUP is what
    makes a timeout recoverable.
    """
    timeout = timeout_s if timeout_s and timeout_s > 0 else None
    try:
        proc = subprocess.Popen(
            cmd,
            cwd=config.PROJECT_ROOT,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            start_new_session=True,  # child becomes its own process-group leader
            # An OVERLAY, never a replacement: `flutter drive` needs PATH, HOME, ANDROID_*
            # and the pub cache from the ambient environment.
            env=None if env is None else {**os.environ, **env},
        )
    except Exception as e:  # noqa: BLE001
        return False, str(e)

    try:
        stdout, stderr = proc.communicate(timeout=timeout)
        return proc.returncode == 0, (stdout + stderr).strip()
    except subprocess.TimeoutExpired:
        out = _kill_tree_and_drain(proc)
        msg = f"{_TIMEOUT_MARKER} after {timeout_s}s: {' '.join(cmd)}"
        return False, f"{out}\n{msg}".strip()
    except Exception as e:  # noqa: BLE001
        _kill_tree_and_drain(proc)
        return False, str(e)


def _kill_tree_and_drain(proc: subprocess.Popen) -> str:
    """SIGTERM then SIGKILL the child's process group; return whatever it had printed."""
    for sig in (signal.SIGTERM, signal.SIGKILL):
        try:
            os.killpg(os.getpgid(proc.pid), sig)
        except (ProcessLookupError, PermissionError):
            break
        try:
            proc.wait(timeout=10)
            break
        except subprocess.TimeoutExpired:
            continue
    try:
        stdout, stderr = proc.communicate(timeout=10)
    except Exception:  # noqa: BLE001
        return ""
    return (_stream_text(stdout) + _stream_text(stderr)).strip()


def recover_device(reason: str) -> None:
    """Put the phone back in a launchable state after a hung/killed execution.

    A `flutter drive` that we killed mid-flight usually leaves the benchmark app running (and
    sometimes paused at an isolate start), plus a half-open adb forward. Force-stopping the app
    and bouncing the adb connection is enough for the retry to get a clean launch; the DVFS pin
    and cpuset isolation live in sysfs and survive untouched.
    """
    logging.warning("recovering device after %s", reason)
    _adb_shell_quiet("am", "force-stop", config.APP_PACKAGE)
    try:
        subprocess.run(["adb", "forward", "--remove-all"], capture_output=True, timeout=10)
        subprocess.run(["adb", "reconnect", "offline"], capture_output=True, timeout=15)
        subprocess.run(["adb", "wait-for-device"], capture_output=True, timeout=60)
    except Exception as e:  # noqa: BLE001
        logging.warning("adb recovery incomplete: %s", e)
    keep_device_awake()
    time.sleep(config.RECOVER_SETTLE_S)


def resolve_packages() -> None:
    """One `flutter pub get` for the whole session.

    `spm run`'s `flutter drive` is invoked with `--no-pub` (see config.spm_run_cmd), so the
    package config has to be current before the first execution — otherwise every drive fails
    fast on an unresolved `.dart_tool/package_config.json`. Nothing the runner does between
    executions touches pubspec.yaml, so once is enough.
    """
    if config.RESOLVE_PUB_PER_EXEC:
        return
    ok, out = _run(["flutter", "pub", "get"], timeout_s=300)
    if not ok:
        raise SessionAbort(f"`flutter pub get` failed — cannot run with --no-pub:\n{out}")
    logging.info("dependencies resolved once for the session (drives run with --no-pub)")


def flutter_version() -> str:
    try:
        r = subprocess.run(["flutter", "--version"], capture_output=True, text=True)
        return r.stdout.strip().splitlines()[0] if r.stdout else "unknown"
    except Exception:  # noqa: BLE001
        return "unknown"


def _adb_shell_quiet(*args: str, timeout_s: int = 8) -> bool:
    try:
        r = subprocess.run(
            ["adb", "shell", *args],
            capture_output=True,
            text=True,
            timeout=timeout_s,
        )
    except Exception:  # noqa: BLE001
        return False
    return r.returncode == 0


def keep_device_awake() -> None:
    """Best-effort UI nudge before a profiled run.

    Redmi runs cut charge input, so Android may treat the phone as unplugged even though the
    USB data cable is present. On some MIUI builds that defeats `svc power stayon true`; waking
    and dismissing keyguard immediately before `flutter drive` prevents a locked display from
    making the driver hang.
    """
    global _WAKE_WARNED
    if not config.WAKE_BEFORE_EXEC:
        return

    ok = _adb_shell_quiet("input", "keyevent", "KEYCODE_WAKEUP") or _adb_shell_quiet(
        "input", "keyevent", "224"
    )
    ok = _adb_shell_quiet("svc", "power", "stayon", "true") and ok
    ok = _adb_shell_quiet(
        "settings", "put", "system", "screen_off_timeout", str(config.SCREEN_OFF_TIMEOUT_MS)
    ) and ok
    # This cannot unlock a secure PIN/password keyguard; the runbook still requires disabling
    # secure lock for unattended sessions.
    _adb_shell_quiet("wm", "dismiss-keyguard")

    if not ok and not _WAKE_WARNED:
        logging.warning("wake-before-exec adb nudge failed; keep the phone unlocked by hand")
        _WAKE_WARNED = True


# ----------------------------------------------------------------------------- cooldown
def cooldown(policy: gate.Policy | None = None) -> None:
    """Thermal-gated cooldown: wait until the hottest zone drops below threshold.

    The loop is here because it talks to a phone; the threshold it waits on belongs to
    `gate.Policy`, with the rest of the ladder.
    """
    policy = policy or gate.Policy.from_config()
    deadline = time.time() + policy.cooldown_max_wait_s
    while time.time() < deadline:
        temp = _hottest_zone_millic()
        if temp is None:  # non-root / unreadable -> fixed fallback sleep
            time.sleep(policy.cooldown_poll_s)
            return
        decision = gate.decide(gate.Snapshot(soc_millic=temp), policy)
        if decision.verdict != "cool":
            return
        logging.info("cooldown: %s, waiting", decision.reason)
        time.sleep(policy.cooldown_poll_s)


def _hottest_zone_millic() -> int | None:
    try:
        r = subprocess.run(
            ["adb", "shell", "cat", config.THERMAL_ZONE_GLOB],
            capture_output=True,
            text=True,
        )
        temps = [int(x) for x in r.stdout.split() if x.strip().lstrip("-").isdigit()]
        return max(temps) if temps else None
    except Exception:  # noqa: BLE001
        return None


# --------------------------------------------------------------------------- preflight
class SessionAbort(Exception):
    """Raised when a pre-run gate fails hard enough to stop the whole session."""


def _true_capacity_pct() -> int | None:
    """Real fuel-gauge level (%) straight from the kernel via sysfs.

    Unlike `dumpsys battery`, this is NOT frozen by `dumpsys battery unplug` — the unplug
    override only fakes the framework-reported status, while the sysfs node reflects the
    actual charge. This is the value the gates should trust while the device is 'unplugged'.
    """
    try:
        r = subprocess.run(
            ["adb", "shell", "cat", config.BATTERY_CAPACITY_SYSFS],
            capture_output=True, text=True,
        )
    except Exception:  # noqa: BLE001
        return None
    s = r.stdout.strip()
    return int(s) if s.isdigit() else None


def _battery_state() -> dict:
    """Battery snapshot -> {pct, temp_c, charging}.

    `pct` prefers the true sysfs fuel gauge (immune to the `dumpsys battery unplug` freeze),
    falling back to the dumpsys level/scale only if sysfs is unreadable. `charging` reflects
    the OS-reported state — after `unplug` the *powered* flags read false regardless of real
    VBUS current, so it catches a forgotten unplug / a re-plug, not actual current flow.
    """
    try:
        r = subprocess.run(["adb", "shell", "dumpsys", "battery"], capture_output=True, text=True)
    except Exception:  # noqa: BLE001
        return {}
    level = scale = None
    out: dict = {"charging": False}
    for raw in r.stdout.splitlines():
        line = raw.strip()
        if line.startswith("level:"):
            level = int(line.split(":", 1)[1])
        elif line.startswith("scale:"):
            scale = int(line.split(":", 1)[1])
        elif line.startswith("temperature:"):
            out["temp_c"] = int(line.split(":", 1)[1]) / 10.0  # tenths of degC
        elif line.lower().startswith(("ac powered", "usb powered", "wireless powered")):
            if line.split(":", 1)[1].strip().lower() == "true":
                out["charging"] = True
    true_pct = _true_capacity_pct()
    if true_pct is not None:
        out["pct"] = true_pct  # sysfs fuel gauge: real level even while 'unplugged'
    elif level is not None and scale:
        out["pct"] = round(100 * level / scale)  # fallback if sysfs unreadable
    return out


def _wait_for_charge(pct: int, policy: gate.Policy | None = None) -> None:
    """Block until the TRUE battery level climbs back into band, then return.

    Called when the true fuel gauge drops below BATTERY_PAUSE_PCT. Polls the sysfs level
    (VBUS still charges through the adb cable even while 'unplugged') and resumes at
    BATTERY_RESUME_PCT. Aborts the session if the level is not rising — i.e. the device is
    not actually charging — so it can't spin forever.
    """
    policy = policy or gate.Policy.from_config()
    logging.warning(
        "battery %s%% below pause floor %d%% — PAUSING to charge; ensure the phone is "
        "plugged in. Will resume at %d%%.",
        pct, policy.pause_pct, policy.resume_pct,
    )
    best = pct
    stalled_s = 0
    while True:
        time.sleep(policy.charge_poll_s)
        cur = _true_capacity_pct()
        if cur is None:
            continue  # transient adb read failure; keep waiting
        if cur >= policy.resume_pct:
            logging.info("battery recovered to %d%% — resuming.", cur)
            return
        if gate.charge_stalled(best, cur, stalled_s + policy.charge_poll_s, policy):
            raise SessionAbort(
                f"battery stuck at {cur}% for {stalled_s + policy.charge_poll_s}s — device is "
                f"not charging; plug it in and rerun (completed executions are kept)."
            )
        if cur > best:
            best, stalled_s = cur, 0  # made progress
        else:
            stalled_s += policy.charge_poll_s
        logging.info("charging… %d%% (resume at %d%%)", cur, policy.resume_pct)


def preflight(idx: int, total: int) -> dict:
    """Gate + snapshot device health BEFORE an execution.

    Order: thermal cooldown (wait until the SoC is cool) -> read battery/thermal -> log
    -> abort the session on critically low battery, warn on out-of-band / charging.
    Returns the snapshot so it can be stamped into the raw capture for provenance.
    """
    policy = gate.Policy.from_config()
    cooldown(policy)  # thermal gate: block until the hottest zone is below threshold
    batt = _battery_state()
    pct = batt.get("pct")
    # Pause-to-charge: below the band floor, wait (charging through the cable) until back
    # in band, then re-cool — charging heats the SoC — and refresh the snapshot.
    if gate.decide(gate.Snapshot(battery_pct=pct), policy).verdict == "pause":
        _wait_for_charge(pct, policy)
        cooldown(policy)
        batt = _battery_state()
        pct = batt.get("pct")
    soc = _hottest_zone_millic()
    soc_c = f"{soc / 1000:.1f}C" if soc is not None else "n/a"
    logging.info(
        "[%d/%d] preflight: battery=%s%% soc=%s batttemp=%sC charging=%s",
        idx, total, pct, soc_c, batt.get("temp_c"), batt.get("charging"),
    )
    # The thermal rung is already satisfied by `cooldown` above, so this reading is about the
    # battery ladder and the advisories. `decide` is consulted rather than restated, so the
    # in-process gate and the policy the manifest publishes cannot say different things.
    decision = gate.decide(
        gate.Snapshot(battery_pct=pct, battery_temp_c=batt.get("temp_c"),
                      charging=bool(batt.get("charging"))),
        policy)
    if decision.verdict == "abort":
        raise SessionAbort(decision.reason)
    for warning in decision.warnings:
        logging.warning("  %s", warning)
    keep_device_awake()
    return {
        "battery_pct": pct,
        "battery_temp_c": batt.get("temp_c"),
        "soc_temp_millic": soc,
        "charging": batt.get("charging"),
    }


# ----------------------------------------------------------------------------- phase 1
def index_samples() -> dict[str, dict]:
    """One `spm analyze` over samples/ -> {sample_id: static feature row}.

    Targets are analyzed WHERE THEY LIVE. Transplanting into lib/ first is unnecessary for
    feature extraction: the samples sit inside the package root, so `package:flutter` and
    their sibling `dependencies.dart` resolve in place, and the `import 'base.dart'` ->
    `import 'generated_widget.dart'` rewrite that `assemble()` performs changes no feature
    (verified byte-for-byte against every transplant-extracted row in static_cache/).

    That turns phase 1 from one whole-project analyze PER TARGET (~27 s x ~450 = hours)
    into a single pass over the corpus.

    Rows are keyed by the path TAIL (`<group>/<role>`) because the analyzer relativizes
    `filePath` against whichever root it picked — see `config.spm_analyze_cmd`. Selection
    within a file is by class name: 97 of 457 sample files declare a second State class
    alongside the root one, and "first row wins" would be a coin flip on declaration order.
    """
    config.STATIC_CACHE_DIR.mkdir(parents=True, exist_ok=True)
    logging.info("[extract] analyzing %s in place…", config.SAMPLES_ROOT.name)
    success, out = _run(
        config.spm_analyze_cmd([str(config.SAMPLES_ROOT)], str(config.INPLACE_STATIC_FILE))
    )
    if not success:
        raise SessionAbort(f"in-place `spm analyze` failed: {_classify(out)}")

    by_sid: dict[str, list[dict]] = {}
    for r in _read_jsonl(config.INPLACE_STATIC_FILE):
        parts = PurePosixPath(r.get("filePath", "")).parts
        if len(parts) < 2:
            continue
        sid = f"{parts[-2]}/{parts[-1].removesuffix('.dart')}"
        by_sid.setdefault(sid, []).append(r)

    index: dict[str, dict] = {}
    for sid, rows in by_sid.items():
        rec = next(
            (r for r in rows if config.scope_name(r) == config.GENERATED_STATE_CLASS), None
        )
        if rec is None:
            logging.warning(
                "[extract] %s declares no %s (found: %s) — skipped",
                sid, config.GENERATED_STATE_CLASS, [config.scope_name(r) for r in rows],
            )
            continue
        index[sid] = rec
    logging.info("[extract] indexed %d targets from one analyze pass", len(index))
    return index


def _ident_of(row: dict) -> dict:
    """The three identity fields, normalized onto the analyzer's current spelling.

    Always emits `scopeName`, even when read out of a pre-0.3.0 cached row that spells it
    `stateClassName` — the row this gets stamped onto is handed to `spm run`, and 0.3.0's
    injector reads the new key.
    """
    return {
        "instanceId": row["instanceId"],
        "filePath": row["filePath"],
        config.SCOPE_NAME_KEYS[0]: config.scope_name(row),
    }


def injection_identity(bootstrap: dict, original_widget: str) -> dict:
    """The `instanceId` / `filePath` / `scopeName` the INJECTOR must see.

    Features come from the sample in place, but injection still rewrites the transplant slot
    (`lib/generated_widget.dart`), and `instanceId` is hashed from the analyzed path — so an
    in-place row carries the wrong one. These three fields are identical for every target
    (same slot, same class name), so they are resolved once per session and stamped onto
    each row, keeping the emitted records byte-identical to the per-target-transplant era.

    Resolution order: reuse an existing cached row, else a row already emitted into the
    dataset, else bootstrap by assembling one target and doing a single whole-project
    analyze. SPM stays the only thing that computes the hash — it is not reimplemented here;
    every branch reads a value SPM produced.

    THE DATASET BRANCH IS NOT A CONVENIENCE. `spm_extract_cmd` analyses PROJECT_ROOT, and
    since the 2026-08-28 restructure PROJECT_ROOT contains `probe_v2/` — 1,549 mined groups,
    on which `spm analyze` dies with "Null check operator used on a null value". So the
    bootstrap cannot run at all here, and narrowing it is not available either: SPM roots
    `filePath` at the FIRST path it is given, so `analyze lib` returns
    `generated_widget.dart` and a different `instanceId` than `analyze .` returns for the
    same file. Only PROJECT_ROOT yields `lib/generated_widget.dart`.

    Reading it back from the dataset is exact rather than approximate: these three fields
    are a property of the SLOT, not of the target, and 471 rows across arm 1 agree on one
    triple. A disagreement would mean the slot itself moved, so it is asserted rather than
    assumed.
    """
    for cached in sorted(config.STATIC_CACHE_DIR.glob("*.jsonl")):
        if cached == config.INPLACE_STATIC_FILE:
            continue
        rows = _read_jsonl(cached)
        if rows and rows[0].get("filePath") == config.ACTIVE_WIDGET_REL:
            ident = _ident_of(rows[0])
            logging.info("[extract] injection identity from cache: %s", ident["instanceId"])
            return ident

    seen = {
        (r["instanceId"], r["filePath"], config.scope_name(r))
        for sp in sorted(config.OUT_DIR.glob(f"*/{config.STATIC_NAME}"))
        for r in _read_jsonl(sp)
        if r.get("filePath") == config.ACTIVE_WIDGET_REL
        and config.scope_name(r) == config.GENERATED_STATE_CLASS
    }
    if len(seen) > 1:
        raise SessionAbort(
            f"the transplant slot has {len(seen)} identities in {config.OUT_DIR}: {sorted(seen)}. "
            f"It must have exactly one — the slot is the same file and the same class for every "
            f"target. Do not pick one; find out which analysis root produced the other."
        )
    if seen:
        iid, fp, scope = seen.pop()
        ident = {"instanceId": iid, "filePath": fp, config.SCOPE_NAME_KEYS[0]: scope}
        logging.info("[extract] injection identity from dataset: %s", iid)
        return ident

    logging.info("[extract] cold start — bootstrapping injection identity via %s", bootstrap["sample_id"])
    assemble(bootstrap)
    try:
        success, out = _run(config.spm_extract_cmd())
        if not success:
            raise SessionAbort(f"bootstrap analyze failed: {_classify(out)}")
        rec = next(
            (
                r
                for r in _read_jsonl(config.STATIC_FILE)
                if r.get("filePath") == config.ACTIVE_WIDGET_REL
                and config.scope_name(r) == config.GENERATED_STATE_CLASS
            ),
            None,
        )
        if rec is None:
            raise SessionAbort(
                f"bootstrap analyze produced no {config.GENERATED_STATE_CLASS} row for "
                f"{config.ACTIVE_WIDGET_REL}"
            )
        return _ident_of(rec)
    finally:
        restore_active(original_widget)


def phase1_extract(targets: list[dict], original_widget: str) -> list[dict]:
    """Extract every target's static features in ONE in-place analyze pass; snapshot each
    row for injection reuse and append it (keyed by sample_id) to the dataset."""
    config.STATIC_CACHE_DIR.mkdir(parents=True, exist_ok=True)
    config.OUT_DIR.mkdir(parents=True, exist_ok=True)
    # Already-extracted targets across every per-sample static.jsonl (dedup across sessions).
    done = {
        r["sample_id"]
        for sp in config.OUT_DIR.glob(f"*/{config.STATIC_NAME}")
        for r in _read_jsonl(sp)
    }

    def cache_of(t: dict) -> Path:
        return config.STATIC_CACHE_DIR / f"{t['safe']}.jsonl"

    todo = [t for t in targets if not (t["sample_id"] in done and cache_of(t).exists())]
    pending = {t["sample_id"] for t in todo}
    ok = [t for t in targets if t["sample_id"] not in pending]
    logging.info("phase 1: %d cached, %d to extract", len(ok), len(todo))
    if not todo:
        return ok

    index = index_samples()
    ident = injection_identity(todo[0], original_widget)

    for i, t in enumerate(todo, 1):
        rec = index.get(t["sample_id"])
        if rec is None:
            logging.warning("[extract %d/%d] no in-place row for %s", i, len(todo), t["sample_id"])
            continue

        # Features from the sample where it lives; identity from the transplant slot, so the
        # row is exactly what a per-target transplant would have produced.
        row = dict(rec)
        row.update(ident)  # overwrites in place — key order is preserved

        cache_of(t).write_text(json.dumps(row) + "\n", encoding="utf-8")  # exact injection input
        if t["sample_id"] not in done:
            sp = config.static_path(t["group"])
            sp.parent.mkdir(parents=True, exist_ok=True)
            _append_jsonl({"sample_id": t["sample_id"], **row}, sp)
            done.add(t["sample_id"])
        ok.append(t)
        logging.info("[extract %d/%d] %s", i, len(todo), t["sample_id"])

    logging.info("phase 1: %d/%d targets extracted", len(ok), len(targets))
    return ok


def _mirror_capture(vm_path: Path, target: dict, exec_index: int) -> None:
    """Copy an execution's VM capture to spm/<device>/<group>/<role>/e<k>.jsonl.

    Browsable convenience view only — `parse` never reads it. Empty captures (VM service
    never connected) are skipped so the mirror shows what was actually measured, and a
    failed copy is logged rather than raised: it must not cost a completed execution.
    """
    if not vm_path.exists() or vm_path.stat().st_size == 0:
        return
    dest = config.mirror_path(target["group"], target["role"], exec_index)
    try:
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(vm_path, dest)
    except OSError as e:
        logging.warning("mirror failed for %s e%d: %s", target["sample_id"], exec_index, e)


# ----------------------------------------------------------------------------- phase 2
def phase2_measure(
    targets: list[dict], n_exec: int, seed: int, original_widget: str, session_arg: str | None,
    screenshots: bool = False, dump_errors: bool = False,
) -> tuple[bool, dict[str, str]]:
    """Interleaved measurement: shuffle (target, exec_index) so thermal drift is random
    noise, not a per-target confound.

    Captures live in a timestamped session dir (raw/<YYYYmmdd-HHMMSS>/) and `parse` reads the
    newest by default. Resuming means REUSING a session name — `devices/lib/measure.sh`
    resolves the newest incomplete session and passes it back via BENCH_RAW_SESSION (or
    --session). Within that dir, an execution is skipped only if its capture is complete
    (`capture.capture_complete`); an incomplete one is discarded and re-measured. Without a
    session name a fresh one is minted, which keeps past captures intact but skips nothing.

    Returns `(completed, quarantined)`. A role that fails on its own -- it will not compile,
    or it never mounts -- is QUARANTINED after `config.ROLE_WEAK_LIMIT` failures: its
    remaining executions are dropped and the rest of the group is measured. The session is
    still reported incomplete, and the quarantine list reaches the manifest, so a corpus can
    never read as measured when roles were dropped from it."""
    requested_session = (session_arg or os.environ.get("BENCH_RAW_SESSION", "")).strip()
    if requested_session:
        if not re.fullmatch(r"[A-Za-z0-9._-]+", requested_session):
            raise SessionAbort(f"invalid raw session name: {requested_session!r}")
        session = requested_session
    else:
        session = datetime.now().strftime("%Y%m%d-%H%M%S")
    # Sessions are per group now (dataset/<group>/<device>/raw/<session>/), created lazily by
    # capture_dir() as each target is measured — a run touching one group leaves the others,
    # and the other device's rows for the same group, untouched.
    logging.info("session %s -> %s/<group>/%s/raw/%s/", session, config.OUT_DIR.name,
                 config.device_slug(), session)
    schedule = [(t, k) for t in targets for k in range(n_exec)]
    random.Random(seed).shuffle(schedule)

    by_sid = {t["sample_id"]: t for t in targets}
    total = len(schedule)
    aborted = False
    # A weak capture (no readings at all) is target-specific at most once. A run of them means
    # something systematic is broken for EVERY target — the integration test not compiling
    # against the installed spm, a wrong Flutter version, a dead adb link — and the schedule is
    # interleaved, so consecutive weak captures are consecutive DIFFERENT targets. Stop instead
    # of burning the session: spm 0.3.0 removed the profiler compat imports and the resulting
    # compile error produced 0 readings on every execution with nothing but a per-execution
    # warning to show for it.
    consecutive_weak = 0
    # Which roles the current streak spans. The abort exists for a break that is systematic,
    # and the schedule is interleaved, so a streak confined to ONE role says the opposite: it
    # is that role that is broken, and `quarantined` is the answer to it.
    streak_roles: set[str] = set()
    weak_by_role: collections.Counter[str] = collections.Counter()
    quarantined: dict[str, str] = {}
    fixtureless: set[str] = set()   # roles whose group fixture is deliberately not staged
    try:
        for i, (t, k) in enumerate(schedule, 1):
            if t["sample_id"] in quarantined:
                logging.info("[%d/%d] skip (quarantined: %s) %s e%d", i, total,
                             quarantined[t["sample_id"]], t["sample_id"], k)
                continue
            cap_dir = config.capture_dir(session, t["group"], t["role"])
            raw_path = cap_dir / f"e{k}.log"
            vm_path = cap_dir / f"e{k}.jsonl"
            if capture.capture_complete(raw_path):
                logging.info("[%d/%d] skip (done) %s e%d", i, total, t["sample_id"], k)
                continue
            if raw_path.exists():
                # A log that exists but is incomplete is a crashed or truncated attempt
                # (ok=False, or fewer than N_REBUILDS captured). Treating it as done is how
                # executions with missing values used to survive a resume; drop it and
                # re-measure so the session converges on a full corpus.
                h = capture.read_header(raw_path)
                logging.info(
                    "[%d/%d] redo (incomplete) %s e%d (ok=%s captured=%s)",
                    i, total, t["sample_id"], k,
                    h.ok if h else "?", h.n_captured if h else "?",
                )
                raw_path.unlink()
                vm_path.unlink(missing_ok=True)
            elif vm_path.exists():
                logging.info(
                    "[%d/%d] redo (orphan VM capture) %s e%d",
                    i, total, t["sample_id"], k,
                )
                vm_path.unlink()
            cap_dir.mkdir(parents=True, exist_ok=True)

            # Pre-run gate + health snapshot: cools the SoC, checks battery, and stops the
            # session if the battery is critically low. Runs before EVERY execution.
            preflight_started = _now()
            state = preflight(i, total)

            logging.info("[%d/%d] measure %s exec %d", i, total, t["sample_id"], k)
            target = by_sid[t["sample_id"]]
            if not assemble(target) and target["deps_path"] \
                    and t["sample_id"] not in fixtureless:
                fixtureless.add(t["sample_id"])
                logging.info(
                    "%s declares no `part 'dependencies.dart';` and its group fixture is a "
                    "part file, so the fixture is NOT staged: it hoisted nothing and stands "
                    "on its own. Staging it would orphan the part and fail `flutter analyze`.",
                    t["sample_id"])
            # Restore this target's cached static.jsonl so injection matches the assembled code.
            cache = config.STATIC_CACHE_DIR / f"{t['safe']}.jsonl"
            config.STATIC_FILE.write_text(cache.read_text(encoding="utf-8"), encoding="utf-8")

            # A hang is transient device state, so retry the execution in place (killing the
            # tree + force-stopping the app first) rather than losing the session to it. Only
            # `started` of the LAST attempt is stamped, so the telemetry slice covers the
            # window that actually produced the capture.
            for attempt in range(1, config.SPM_RUN_ATTEMPTS + 1):
                vm_path.unlink(missing_ok=True)  # never let a partial retry-over-retry merge
                started = _now()
                # One image per ROLE, decided by whether the file is already there. Keyed on
                # existence rather than on `k == 0` because the schedule is shuffled and a
                # resume skips completed executions, so no particular index is guaranteed to
                # run. The capture happens AFTER the measured span inside the test, so the
                # execution that carries it is a normal execution and its numbers are kept --
                # see the note in `integration_test.dart`.
                shot_name = shot_env = None
                if screenshots:
                    shot_dir = config.shots_dir(t["group"])
                    shot_name = f"{t['group']}__{t['role']}"
                    if not (shot_dir / f"{shot_name}.png").exists():
                        shot_dir.mkdir(parents=True, exist_ok=True)
                        shot_env = {"SPM_SHOT_DIR": str(shot_dir)}
                    else:
                        shot_name = None
                success, out = _run(
                    config.spm_run_cmd(str(vm_path), shot_name, dump_errors=dump_errors),
                    timeout_s=config.SPM_RUN_TIMEOUT_S,
                    env=shot_env,
                )
                if shot_name and "[SPM:shot] FAILED" in out:
                    logging.warning("[%d/%d] screenshot failed for %s (measurement kept)",
                                    i, total, t["sample_id"])
                timed_out = _TIMEOUT_MARKER in out
                if not timed_out:
                    break
                if attempt < config.SPM_RUN_ATTEMPTS:
                    logging.warning(
                        "[%d/%d] `spm run` hung after %ss on %s e%d — attempt %d/%d, retrying",
                        i, total, config.SPM_RUN_TIMEOUT_S, t["sample_id"], k,
                        attempt, config.SPM_RUN_ATTEMPTS,
                    )
                    recover_device(f"hung execution {t['sample_id']} e{k}")
                    state = preflight(i, total)  # re-cool + refresh the health snapshot
            n_perf = len(_PERF_LINE.findall(out))
            n_vm = len(_read_jsonl(vm_path))
            # preflight_started/started/ts bound this execution on the HOST clock — the same
            # clock devices/lib/measure.sh stamps into the telemetry CSV's `epoch` column — so
            # `device_runner telemetry` can slice the session CSV per execution exactly,
            # with no clock-skew correction and no separate IPC. [preflight_started, started)
            # is the cooldown/assemble setup phase; [started, ts] is the measured window.
            header = (
                f"# sample_id={t['sample_id']} exec_index={k} ok={success} "
                f"perf_lines={n_perf} vm_events={n_vm} battery_pct={state['battery_pct']} "
                f"soc_temp_millic={state['soc_temp_millic']} "
                f"battery_temp_c={state['battery_temp_c']} charging={state['charging']} "
                f"preflight_started={preflight_started} started={started} "
                f"ts={_now()}\n"
            )
            raw_path.write_text(header + out, encoding="utf-8")
            _mirror_capture(vm_path, t, k)
            # The VM stream is the measurement of record; stdout is the fallback. Flag when
            # either is short of the expected count — a truncated stdout used to pass silently
            # because only the all-zero case warned.
            best = max(n_vm, n_perf)
            if not success or best == 0:
                # A hang is NOT counted here: the `timed_out` branch below owns that case and
                # tears the device down (`recover_device`) before aborting. Counting it would
                # abort first and leave the phone wedged for the next session.
                cause = _classify(out)
                if not timed_out:
                    consecutive_weak += 1
                    streak_roles.add(t["sample_id"])
                    weak_by_role[t["sample_id"]] += 1
                logging.warning(
                    "[%d/%d] weak capture %s e%d (ok=%s vm=%d perf=%d cause=%s)%s",
                    i, total, t["sample_id"], k, success, n_vm, n_perf, cause,
                    f" [{consecutive_weak} in a row]" if consecutive_weak > 1 else "",
                )
                # Systematic only when the streak spans more than one role. One role failing
                # the same way every time is that role's problem, and quarantine handles it.
                if (not timed_out and consecutive_weak >= config.WEAK_CAPTURE_ABORT
                        and len(streak_roles) > 1):
                    raise SessionAbort(
                        f"{consecutive_weak} consecutive weak captures (0 readings) across "
                        f"{len(streak_roles)} targets, last {t['sample_id']} e{k}: {cause}. "
                        f"This is not target-specific — check that `flutter analyze` passes "
                        f"and the device is reachable. Full output: {raw_path}"
                    )
                if not timed_out and weak_by_role[t["sample_id"]] >= config.ROLE_WEAK_LIMIT:
                    quarantined[t["sample_id"]] = cause
                    logging.error(
                        "QUARANTINED %s after %d failed execution(s) (%s): its remaining "
                        "executions are dropped and the rest of the session continues. "
                        "Full output: %s",
                        t["sample_id"], weak_by_role[t["sample_id"]], cause, raw_path,
                    )
            elif best < config.N_REBUILDS:
                consecutive_weak = 0
                streak_roles.clear()
                logging.warning(
                    "[%d/%d] short capture %s e%d (vm=%d perf=%d, expected %d)",
                    i, total, t["sample_id"], k, n_vm, n_perf, config.N_REBUILDS,
                )
            else:
                consecutive_weak = 0
                streak_roles.clear()
                if n_vm != n_perf:
                    logging.info(
                        "[%d/%d] %s e%d: vm=%d perf=%d (stdout lost %d)",
                        i, total, t["sample_id"], k, n_vm, n_perf, n_vm - n_perf,
                    )
            if timed_out:
                # Every attempt hung: this is no longer transient device state (dead adb link,
                # wedged phone, or a genuinely non-launchable target). Stop — progress is on
                # disk and the incomplete capture is re-measured on resume.
                recover_device(f"exhausted retries on {t['sample_id']} e{k}")
                raise SessionAbort(
                    f"`spm run` timed out after {config.SPM_RUN_TIMEOUT_S}s on "
                    f"{t['sample_id']} e{k} in all {config.SPM_RUN_ATTEMPTS} attempts; "
                    f"the incomplete capture will be retried on resume."
                )
    except SessionAbort as e:
        logging.error("Session aborted: %s. Progress is saved — resume when resolved.", e)
        aborted = True
    finally:
        restore_active(original_widget)
    if quarantined:
        logging.error("%d role(s) quarantined this session:", len(quarantined))
        for sid in sorted(quarantined):
            logging.error("  %s: %s", sid, quarantined[sid])
    return not aborted, quarantined


# ----------------------------------------------------------------------------- manifest
def _now() -> str:
    return datetime.now(timezone.utc).isoformat()


def _provenance() -> dict:
    """Which device, under which controls, produced this dataset root.

    `devices/lib/root.sh::root_export_provenance` exports these AFTER preflight, reading the
    controls back off the phone, so what lands here is what was actually applied — not what
    was requested. With two reference devices writing two dataset roots, `device` is the field
    that says which corpus a row belongs to, so it must never be a hardcoded guess. The
    fallbacks keep a bare `python -m scripts.device_runner run` (no device wrapper) honest by
    labelling itself unrecorded rather than claiming a device.
    """
    env = os.environ.get
    label = env("BENCH_DEVICE_LABEL", "").strip()
    power = env("BENCH_POWER_MODE", "").strip()
    pin = env("BENCH_PIN_FREQ_KHZ", "").strip()
    cpuset = env("BENCH_CPUSET_TOP_APP", "").strip()
    knee = env("BENCH_KNEE_C", "").strip()

    if power == "suspend":
        battery = f"charge input SUSPENDED (input_suspend=1); abort floor {config.BATTERY_ABORT_PCT}%"
    elif power == "charge_on":
        battery = "30-85% charge-on (weak USB trickle, fast-charge blocked)"
    else:
        battery = "not recorded (run outside devices/<id>/run.sh)"

    return {
        "device": label or "not recorded — run via devices/<id>/run.sh to capture this",
        "device_id": env("BENCH_DEVICE_ID", "") or None,
        "device_serial": env("BENCH_DEVICE_SERIAL", "") or None,
        "dataset_root": config.OUT_DIR.name,
        "governor": env("BENCH_GOVERNOR", "") or "not recorded",
        "pinned_freq_khz": int(pin) if pin.isdigit() else None,
        "cpuset_top_app": cpuset or None,
        "root_mode": env("BENCH_ROOT_MODE", "") or None,
        "power_mode": power or None,
        "knee_c": int(knee) if knee.isdigit() else None,
        "battery_band": battery,
    }


def _exclusions_digest() -> dict:
    """The screening record the target list was selected from, so the measured set is
    reproducible from the artifact rather than from a flag someone remembers passing."""
    path = config.SAMPLES_ROOT / "exclusions.json"
    if not path.is_file():
        return {}
    raw = path.read_bytes()
    return {"exclusions_sha256": hashlib.sha256(raw).hexdigest(),
            "exclusions_path": str(path)}


def write_manifest(targets: list[dict], n_exec: int, seed: int,
                   eligible_only: bool = False,
                   quarantined: dict[str, str] | None = None) -> None:
    config.manifest_path().parent.mkdir(parents=True, exist_ok=True)
    manifest = {
        "generated": _now(),
        "flutter_version": flutter_version(),
        # The extractor build these rows were measured under. `spm 0.7.1` removed a print
        # that `SpmState.setState` ran on every measured rebuild, so this reaches the device
        # side and is not merely provenance -- arm 1 was measured with it, arm 2 has not been
        # measured at all. A dataset that cannot say which build it ran cannot be pooled.
        "spm_build": spm.version(),
        "n_executions": n_exec,
        "n_rebuilds": config.N_REBUILDS,
        "warmup_discard": config.WARMUP_DISCARD,
        "seed": seed,
        "profile_mode": True,
        "trigger": "setState -> markNeedsBuild via injected SpmState",
        "cooldown_temp_millic": config.COOLDOWN_TEMP_MILLIC,
        # The whole gate ladder, from the one object that holds it. The individual key above
        # is kept because existing manifests carry it and a reader should not have to know
        # which vintage it is looking at.
        "gate_policy": gate.as_dict(gate.Policy.from_config()),
        "spm_run_timeout_s": config.SPM_RUN_TIMEOUT_S or None,
        "spm_run_attempts": config.SPM_RUN_ATTEMPTS,
        "wake_before_exec": config.WAKE_BEFORE_EXEC,
        "screen_off_timeout_ms": config.SCREEN_OFF_TIMEOUT_MS if config.WAKE_BEFORE_EXEC else None,
        "n_targets": len(targets),
        "n_groups": len({t["group"] for t in targets}),
        # Roles dropped mid-session because they failed on their own (see `phase2_measure`).
        # On the manifest rather than in a log, because a dataset whose roles were dropped
        # must not read as a complete measurement of `n_targets`.
        "quarantined": dict(sorted((quarantined or {}).items())),
        "eligible_only": eligible_only,
        **(_exclusions_digest() if eligible_only else {}),
        "note": (
            "Device prep (governor pin/cpuset/charge control, battery band, airplane mode, "
            "cooling) is applied by scripts/devices/<id>/run.sh; the fields below are read back "
            "off the phone after preflight, so they record what was actually in force."
        ),
        **_provenance(),
    }
    config.manifest_path().write_text(json.dumps(manifest, indent=2), encoding="utf-8")


# ----------------------------------------------------------------------------- entrypoint
def main() -> None:
    parser = argparse.ArgumentParser(description="Collect buildSpan measurements for all samples.")
    parser.add_argument("--widget-type", metavar="GROUP", help="Only samples/<GROUP>/ (e.g. 01).")
    parser.add_argument(
        "--samples-root",
        metavar="DIR",
        help="Corpus root to measure (default: samples/). Use new_samples/ for arm 2.",
    )
    parser.add_argument(
        "--eligible-only", action="store_true",
        help="Measure only revisions that are an endpoint of an eligible contrast, per the "
             "root's exclusions.json. 177 of arm 2's roles are endpoints of its 214 eligible "
             "contrasts; the rest were screened, not selected. Belt and braces on a corpus "
             "`screen_samples --prune-to-endpoints` has already narrowed -- it holds only the "
             "177 -- and the thing standing between a campaign and ~3,900 wasted executions "
             "on one it has not. Off by default and unavailable for arm 1, whose samples/ has "
             "no screening record.")
    parser.add_argument(
        "--roles", metavar="FILE",
        help="Measure exactly the `<group>/<role>` lines in FILE. A role-level selector, for "
             "the census a validation pass needs: the roles worth photographing before a "
             "campaign are the eligible endpoints UNION the roles R21 condemned, and 44 of "
             "the condemned ones are not endpoints -- they stopped being endpoints because "
             "R21 excluded their contrasts. Neither --eligible-only nor --widget-type can "
             "name that set. Passing it with --eligible-only narrows to the intersection, "
             "which is not the census: pass it alone.")
    parser.add_argument("--executions", type=int, default=config.N_EXECUTIONS)
    parser.add_argument(
        "--screenshots", action="store_true",
        help="Capture one PNG per role into dataset/<group>/<device>/shots/. The image is "
             "taken AFTER the measured span and the capture code is compiled out when this "
             "is off, so it cannot move a buildSpan. Off by default all the same: it is a "
             "diagnostic, and the measured binary should differ from the frozen one only "
             "when asked.")
    parser.add_argument(
        "--dump-errors", action="store_true",
        help="Print every framework error in full (`[SPM:err]` lines) so `render_gate` can "
             "name what a role threw. DIAGNOSTIC ONLY: unlike --screenshots this runs DURING "
             "the measured span, because the errors worth naming are thrown by the first "
             "build -- so it adds work to the frames being timed and its numbers must never "
             "be parsed. It therefore requires --session, and refuses a name that does not "
             "start with `diag-`, so a diagnostic capture cannot be mistaken for a "
             "measurement or resumed into a real one.")
    parser.add_argument("--seed", type=int, default=config.SEED)
    parser.add_argument(
        "--extract-only", action="store_true", help="Run phase 1 (static extract) only."
    )
    parser.add_argument(
        "--session",
        help="Use this raw/<SESSION> directory; existing e*.log captures are skipped.",
    )
    args = parser.parse_args()

    logging.basicConfig(level=logging.INFO, format="%(levelname)s - %(message)s")

    # A diagnostic capture must be impossible to mistake for a measurement, and impossible to
    # RESUME INTO one -- `status.pick_session` picks the most complete session, so a diagnostic
    # session sitting beside a real one could be the winner. The name is the guard, because it
    # is what the session directory is called on disk and what `parse` and `pick_session` both
    # see. `--dump-errors` prints from `FlutterError.onError` during the measured span, so its
    # buildSpans are not the role's.
    if args.dump_errors:
        if not args.session or not args.session.startswith("diag-"):
            raise SystemExit(
                "--dump-errors requires --session diag-<something>. It prints from the UI "
                "thread DURING the measured span, so its buildSpans are not measurements; "
                "the name is what keeps `parse` and `status.pick_session` from treating them "
                "as one. Delete the session directory when you have read the errors.")
        logging.warning(
            "DIAGNOSTIC RUN: --dump-errors adds UI-thread work to the measured frames. "
            "Session %s must not be parsed into performance.jsonl.", args.session)

    # Rebind the module constant rather than threading a parameter: the static-extract pass
    # and the manifest both read `config.SAMPLES_ROOT` at call time, so they must see the
    # same root the targets were discovered under.
    if args.samples_root:
        config.set_samples_root(args.samples_root)

    targets = discover_targets(args.widget_type, eligible_only=args.eligible_only,
                               roles=read_role_list(Path(args.roles)) if args.roles else None)
    if not targets:
        logging.error("No targets found under %s", config.SAMPLES_ROOT)
        return

    # A group R16 flagged is AWAITING A HAND-AUTHORED FIXTURE, not broken: its slots are open
    # by design and stay open until someone writes them, which is a human step no run can
    # perform and none should wait on. Skip it and measure the rest.
    #
    # Before 2026-09-08 the gate below was root-wide with no exemption, which was right while
    # R16 was HARD -- a flagged group never shipped, so the gate never met one. R16 went soft
    # that day and the corpus began shipping them, so one flagged group aborted the whole
    # campaign before a single role was measured. `screen.rebuild` already carries exactly
    # this exemption; this is the other half of it.
    awaiting = awaiting_fixture_groups(config.SAMPLES_ROOT)
    skipped = sorted(awaiting & {t["group"] for t in targets})
    if skipped:
        targets = [t for t in targets if t["group"] not in awaiting]
        logging.warning(
            "Skipping %d group(s) awaiting a hand-authored fixture: %s. Author with "
            "`python3 -m scripts.authored_fixtures --seed <gid>`, then re-run.",
            len(skipped), ", ".join(skipped))
    if not targets:
        logging.error("Every discovered target is awaiting a hand-authored fixture.")
        return
    logging.info("Discovered %d targets across %d group(s)%s", len(targets),
                 len({t["group"] for t in targets}),
                 " (eligible endpoints only)" if args.eligible_only else "")

    # Hard refusal, per the fixture value-fill protocol, 6. An unfilled
    # `// TODO: value` either throws at mount or renders a tree the feature vector does not
    # describe; either way the row is worthless and the device time is spent. A warning in a
    # batch run is a value that gets measured, so this aborts.
    #
    # Scoped to the groups actually being measured, so a slot left open on a group nobody is
    # measuring cannot stop the ones that are. Nothing unfilled is measured either way: a
    # skipped group left `targets` above.
    unfinished = {g: v for g, v in fixture_gate.check_root(
        config.SAMPLES_ROOT, args.widget_type).items() if g not in awaiting}
    if unfinished:
        for gid in sorted(unfinished):
            for message in unfinished[gid]:
                logging.error("[%s] %s", gid, message)
        raise SystemExit(
            f"fixture gate refused {len(unfinished)} group(s) under {config.SAMPLES_ROOT}. "
            "Fill and freeze their fixtures before measuring."
        )

    original_widget = config.ACTIVE_WIDGET_PATH.read_text(encoding="utf-8")

    extracted = phase1_extract(targets, original_widget)
    if args.extract_only:
        write_manifest(extracted, args.executions, args.seed, args.eligible_only)
        return
    resolve_packages()
    complete, quarantined = phase2_measure(extracted, args.executions, args.seed,
                                           original_widget, args.session,
                                           screenshots=args.screenshots,
                                           dump_errors=args.dump_errors)
    write_manifest(extracted, args.executions, args.seed, args.eligible_only, quarantined)
    if not complete or quarantined:
        # Exit 2 is the data-side verdict `devices/lib/measure.sh` reads: this group is not
        # measured, but the device is healthy and the groups queued behind it still are.
        raise SystemExit(2)
    logging.info(
        "Done. Raw captures in %s/<group>/%s/raw/%s; run `parse` next.",
        config.OUT_DIR.name, config.device_slug(), "<session>",
    )
