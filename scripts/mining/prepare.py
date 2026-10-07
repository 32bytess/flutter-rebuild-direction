"""Phase 2 - drive a checkout to zero error-severity diagnostics under `lib/`.

Why lib-wide, and not just the files holding rebuild scopes:

    A scope's metrics are NOT a function of the file that declares it. `spm
    analyze` follows helpers across libraries and merges every custom child
    widget's `build()` into the totals, so a row depends on a transitive closure
    of files. And an unreadable closure file does not remove the row - it makes
    it WRONG. An unresolvable child contributes nothing and its whole subtree
    vanishes from the counts; one that resolves *with* errors has null types and
    its widgets classify as value objects. Neither is visible in SPM's
    scanned/skipped counts, because those guard only the file being scanned.

    Targeting the closure instead would be circular: the closure is discovered
    BY analyzing, which is the thing that needs resolution first. And it moves as
    history moves, so the guarantee would have to be re-derived at every commit.
    `lib/` clean is one predicate, checkable before any scope is known, constant
    across revisions.

For pairs this is not merely lost data. If commit A resolves and commit B does
not, the delta is manufactured by resolution state rather than by a human edit -
a false positive, which costs far more than a missed pair. So this is a GATE:
what cannot be driven to zero is recorded and dropped, never hand-patched. A
hand-patched file is no longer the commit it claims to be.
"""

from __future__ import annotations

import collections
import json
import re
import subprocess
import threading
import time
from datetime import datetime, timezone
from pathlib import Path

from . import checkpoints, config

# `flutter analyze` separates fields with BULLETS, not dashes, and puts the
# message before the location:
#   "  error • Undefined name 'S' • lib/utils/utils.dart:65:21 • undefined_identifier"
# `dart analyze` uses " - " with the location first. Both are accepted, because
# getting this wrong does not raise - it silently yields zero errors and reports
# a broken repository as clean. `analyze_lib` cross-checks against the summary
# line for exactly that reason.
ANALYZE_BULLET = re.compile(
    r"^\s*(?P<severity>error|warning|info)\s+•\s+(?P<message>.*?)\s+•\s+"
    r"(?P<location>\S+?):(?P<line>\d+):\d+\s+•\s+(?P<code>\S+)\s*$"
)
ANALYZE_DASH = re.compile(
    r"^\s*(?P<severity>error|warning|info)\s+-\s+(?P<location>\S+?):(?P<line>\d+):\d+\s+-\s+"
    r"(?P<message>.*?)\s+-\s+(?P<code>\S+)\s*$"
)
ISSUES_FOUND = re.compile(r"(?P<count>\d+)\s+issues?\s+found")

# pub reports an unsatisfiable constraint in two shapes. `flutter_checkout` handles
# the first, where pub prints the fix itself ("Try upgrading your constraint on
# intl: flutter pub add intl:^0.20.2"). The second gives no such line:
#
#   Because app depends on flutter_localizations from sdk which depends on
#   intl 0.20.2, intl 0.20.2 is required.
#   So, because app depends on intl ^0.17.0, version solving failed.
#
# The SDK's pin is not negotiable, so the required version IS the fix. Without
# this, `wasabeef/flutter-architecture-blueprints` burns every round unchanged.
PUB_REQUIRED = re.compile(
    r"(?P<package>[a-zA-Z0-9_]+)\s+(?P<version>\d+\.\d+\.\d+[^\s,]*)\s+is required"
)

# Attribution of an error to what could fix it. The first two are mechanical and
# re-enter pub get / codegen; the third ends the loop for this repository.
CODEGEN_CODES = {"uri_has_not_been_generated", "undefined_class", "undefined_identifier"}
# Generated-file suffixes, plus the l10n/intl outputs that `intl_utils` and
# `flutter gen-l10n` produce. A repo can need codegen without a single
# freezed/json_serializable dependency - `fluent-reader-lite` generates
# `generated/l10n.dart` and 22 of its 52 lib files will not resolve without it.
CODEGEN_HINT = re.compile(r"\.(g|freezed|config|gr|graphql)\.dart|generated/l10n\.dart|/l10n/")


def _run(command: list[str], cwd: Path, timeout: int) -> tuple[bool, str]:
    try:
        done = subprocess.run(
            command, cwd=str(cwd), capture_output=True, text=True, timeout=timeout
        )
    except subprocess.TimeoutExpired:
        return False, f"timed out after {timeout}s: {' '.join(command)}"
    return done.returncode == 0, (done.stdout + done.stderr)


def analyze_lib(root: Path) -> dict:
    """Every error-severity diagnostic under `lib/`, with an attributed cause.

    `flutter analyze` exits non-zero when it finds anything at all, warnings and
    infos included, so its exit code answers a different question than this one.
    The diagnostics are parsed instead.
    """
    _, output = _run(["flutter", "analyze", "--no-pub"], root, config.FLUTTER_TIMEOUT_S)

    errors = []
    parsed = 0
    for line in output.splitlines():
        match = ANALYZE_BULLET.match(line) or ANALYZE_DASH.match(line)
        if not match:
            continue
        parsed += 1
        if match["severity"] != "error":
            continue
        location = match["location"]
        # Only lib/ matters: test/ and example/ are never part of a rebuild
        # scope's closure, and demanding they compile would drop repositories
        # for reasons that cannot affect a single metric.
        normalised = location.replace("\\", "/")
        if not (normalised.startswith("lib/") or "/lib/" in normalised):
            continue
        errors.append({
            "file": normalised,
            "line": int(match["line"]),
            "code": match["code"],
            "message": match["message"][:200],
        })

    # A parser that silently matches nothing reports every repository as clean,
    # which is the single worst failure this phase could have: the whole point of
    # the gate is that an unresolved file corrupts rows rather than removing them.
    # `flutter analyze` prints its own total, so disagreement is detectable.
    summary = ISSUES_FOUND.search(output)
    if summary and int(summary["count"]) > 0 and parsed == 0:
        raise RuntimeError(
            f"flutter analyze reported {summary['count']} issues but none were parsed - "
            f"its output format changed. Refusing to report a clean repository.\n"
            f"First lines:\n" + "\n".join(output.splitlines()[:8])
        )

    return {
        "error_count": len(errors),
        # Attribution over every error, not the truncated sample below: the
        # sample exists for a human reading the report, the causes decide whether
        # another round is worth running.
        "causes": attribute(errors, root),
        "diagnostics_parsed": parsed,
        "reported_issues": int(summary["count"]) if summary else None,
        "files_affected": sorted({e["file"] for e in errors}),
        "errors": errors[:200],
        "raw_tail": output[-1500:] if errors else "",
    }


# A self-import that names a file the repository never committed. Not codegen
# and not a broken source: `CarGuo/gsy_github_app_flutter` gitignores
# `lib/common/config/ignoreConfig.dart` (its API keys), so NO commit in history
# contains it and no preparation can produce it. Supplying a stub would be
# hand-patching - the checkout would stop being the commit it claims to be - so
# these repositories are dropped, permanently, and counted separately. They are
# a fixed exclusion rather than a "needs more rounds", which matters when
# extrapolating the pilot.
SELF_IMPORT = re.compile(r"'package:(?P<pkg>[a-zA-Z0-9_]+)/(?P<path>[^']+)'")


def _never_committed(root: Path, relative: str) -> bool:
    """True when git has no record of this path, ever."""
    done = subprocess.run(
        ["git", "-C", str(root), "log", "--oneline", "-1", "--", relative],
        capture_output=True, text=True, timeout=120,
    )
    return done.returncode == 0 and not done.stdout.strip()


def attribute(errors: list[dict], root: Path | None = None) -> dict[str, int]:
    """Split errors into what a rerun could fix versus what it cannot.

    `missing_codegen` and `unresolved_dependency` re-enter the loop.
    `missing_untracked_file` and `broken_source` end it - the first because the
    file exists in no commit, the second because one toolchain cannot fix it.
    Attribution is coarse on purpose: it decides whether to spend another round,
    not what to write in a paper.
    """
    causes = {
        "missing_codegen": 0,
        "unresolved_dependency": 0,
        "missing_untracked_file": 0,
        "obsolete_toolchain_api": 0,
        "broken_source": 0,
    }
    untracked_cache: dict[str, bool] = {}

    # An undefined name in a file whose import already failed is a CONSEQUENCE,
    # not an independent problem. Counting the 5 `NetConfig` errors that follow
    # one missing `ignoreConfig.dart` import as "missing codegen" makes a
    # terminally-blocked repository look like it just needs another round.
    poisoned = {
        e["file"]
        for e in errors
        if e["code"] == "uri_does_not_exist"
    }

    for error in errors:
        message, code = error["message"], error["code"]
        # `package:flutter_gen` was the synthetic l10n package. Modern Flutter
        # does not provide it, so sources written against it cannot resolve no
        # matter what is generated - only editing their imports would fix it, and
        # that would stop the checkout being the commit it claims to be.
        if "package:flutter_gen/" in message:
            causes["obsolete_toolchain_api"] += 1
            continue
        if CODEGEN_HINT.search(message) or CODEGEN_HINT.search(error["file"]):
            causes["missing_codegen"] += 1
            continue
        if code != "uri_does_not_exist" and error["file"] in poisoned:
            # Downstream of a failed import in the same file.
            causes["broken_source"] += 0  # counted via its cause, not twice
            continue
        if code == "uri_does_not_exist" and root is not None:
            match = SELF_IMPORT.search(message)
            if match:
                relative = f"lib/{match['path']}"
                if relative not in untracked_cache:
                    untracked_cache[relative] = _never_committed(root, relative)
                if untracked_cache[relative]:
                    causes["missing_untracked_file"] += 1
                    continue
        if code in {"uri_does_not_exist", "depend_on_referenced_packages"}:
            causes["unresolved_dependency"] += 1
        elif code in CODEGEN_CODES:
            causes["missing_codegen"] += 1
        else:
            causes["broken_source"] += 1
    return causes


# Every `pub get` in this process goes through here, one at a time.
#
# `pub get` writes the SHARED cache at ~/.pub-cache, and two resolutions racing on it fail in
# a way that is indistinguishable from a genuinely unsatisfiable pubspec -- which is a settled
# verdict, so the repository is dropped from the corpus and never re-driven. That hazard is
# why the pipeline was strictly serial. Serialising the resolve alone lifts it without giving
# up the parallelism: the expensive work is `spm analyze` and `flutter analyze`, and both stay
# concurrent. `mine.resolve_deps` imports this same function, so one lock covers both phases.
#
# Threads only. Two separate PROCESSES still contend, exactly as before.
_PUB_GET_LOCK = threading.Lock()


def pub_get_with_conflicts(root: Path) -> dict:
    """`flutter pub get`, resolving BOTH shapes of version conflict.

    Delegates to `flutter_checkout.pub_get` first, because its suggestion-parsing is
    what makes this work on a repository nobody has looked at. When that fails
    with no suggestion to apply, the "X Y is required" form is read instead and
    pinned as an override.

    Overrides change what the analyzer sees, so they are recorded on the row
    rather than buried - a caveat the yield inherits.

    Serialised process-wide by `_PUB_GET_LOCK`; see the note above it.
    """
    from scripts.flutter_checkout import apply_overrides, pub_get

    with _PUB_GET_LOCK:
        return _pub_get_with_conflicts(root, apply_overrides, pub_get)


def _pub_get_with_conflicts(root: Path, apply_overrides, pub_get) -> dict:
    """The resolution itself. Called only under `_PUB_GET_LOCK`."""
    result = pub_get(root)
    if result["ok"]:
        return result

    overrides = dict(result.get("overrides", {}))
    for _ in range(3):
        tail = "".join(a.get("tail", "") for a in result.get("attempts", []))
        required = {m["package"]: m["version"] for m in PUB_REQUIRED.finditer(tail)}
        new_pins = {p: v for p, v in required.items() if overrides.get(p) != v}
        if not new_pins:
            break
        overrides.update(new_pins)
        apply_overrides(root, overrides)
        result = pub_get(root)
        result["overrides"] = {**result.get("overrides", {}), **overrides}
        if result["ok"]:
            break

    # A conflict pub cannot resolve ends it. Editing the pubspec by hand - even
    # to remove a dev_dependency that `lib/` can never import - would stop the
    # checkout being the commit it claims to be, and the whole gate exists to
    # keep that true. `wasabeef/flutter-architecture-blueprints` fails here on
    # `mocktail` vs `flutter_test`, and is dropped rather than repaired.
    result["overrides"] = overrides
    return result


def arb_directory(root: Path) -> str | None:
    """Where this project keeps its `.arb` files, if anywhere.

    `flutter gen-l10n` defaults to `lib/l10n`. Projects that put them elsewhere
    and rely on an IDE plugin have no `l10n.yaml` to say so, and the generated
    `package:flutter_gen/gen_l10n/...` import then fails for every localised
    screen - 109 errors in `flutter_social_chat`, whose arb lives in
    `lib/presentation/l10n/`.
    """
    candidates = sorted((root / "lib").rglob("*.arb"))
    if not candidates:
        return None
    return candidates[0].parent.relative_to(root).as_posix()


def run_codegen(root: Path) -> dict:
    """Generate whatever this repository's sources import but do not commit.

    `build_runner` is only half of it. `intl_utils` / `flutter_intl` generate
    `lib/generated/l10n.dart`, which is gitignored by convention and imported by
    every localised screen - in `fluent-reader-lite` its absence is what makes 22
    of 52 lib files unresolvable, with no freezed or json_serializable anywhere in
    the pubspec. Detecting codegen by those packages alone misses it entirely.
    """
    from scripts.flutter_checkout import build_runner, needs_codegen, read_pubspec

    pubspec = read_pubspec(root)
    steps: list[dict] = []

    if "intl_utils" in pubspec or "flutter_intl" in pubspec:
        ok, output = _run(
            ["dart", "run", "intl_utils:generate"], root, config.FLUTTER_TIMEOUT_S
        )
        steps.append({"tool": "intl_utils", "ok": ok, "tail": output[-400:]})

    # `generate: true` is the real signal, not `l10n.yaml` - the yaml is optional
    # and frequently absent in projects that configure l10n through an IDE plugin.
    wants_l10n = "generate: true" in pubspec or (root / "l10n.yaml").is_file()
    if wants_l10n:
        command = ["flutter", "gen-l10n"]
        if not (root / "l10n.yaml").is_file():
            arb = arb_directory(root)
            if arb:
                command += ["--arb-dir", arb]
        ok, output = _run(command, root, config.FLUTTER_TIMEOUT_S)
        steps.append({"tool": "gen-l10n", "ok": ok, "command": command, "tail": output[-400:]})

    if needs_codegen(root):
        steps.append({"tool": "build_runner", **build_runner(root)})

    return {"ran": bool(steps), "steps": steps}


def prepare_repo(repo: dict, *, max_rounds: int = config.PREPARE_MAX_ROUNDS) -> dict:
    """Drive one checkout toward zero errors under lib/, bounded at max_rounds."""
    # `flutter_checkout.pub_get` is reused verbatim - applying the constraint pub
    # itself suggests is what makes this work on a repository nobody has looked
    # at - but codegen is this package's own, because that helper only knows
    # about build_runner.

    name = repo["repo_name"]
    root = config.REPOS_FULL_ROOT / config.repo_dir_name(name)
    record: dict = {
        "repo_name": name,
        "path": str(root),
        "rounds": [],
        "prepared_at": datetime.now(timezone.utc).isoformat(),
    }
    if not root.is_dir():
        record["status"] = "missing_clone"
        return record

    started = time.monotonic()
    for round_index in range(max_rounds):
        print(f"  round {round_index}: pub get ...", flush=True)
        pub = pub_get_with_conflicts(root)
        codegen = run_codegen(root) if pub["ok"] else {"ran": False, "steps": []}
        analysis = analyze_lib(root)
        causes = analysis["causes"]
        record["rounds"].append({
            "round": round_index,
            "pub_get_ok": pub["ok"],
            "overrides": pub.get("overrides", {}),
            "codegen": codegen,
            "lib_errors": analysis["error_count"],
            "causes": causes,
        })
        print(
            f"  round {round_index}: pub_get={pub['ok']} "
            f"codegen={[s['tool'] for s in codegen['steps']]} "
            f"lib_errors={analysis['error_count']} {causes}",
            flush=True,
        )

        if analysis["error_count"] == 0:
            record["status"] = "clean"
            break
        # Another round only helps if something mechanical is still outstanding.
        # Nothing downstream is meaningful while the package graph is missing:
        # with no `pub get`, every import in the project reads as unresolved and
        # the cause counts describe pub, not the source.
        if not pub["ok"]:
            record["status"] = "unsatisfiable_dependencies"
            break

        mechanical = causes["missing_codegen"] + causes["unresolved_dependency"]
        if mechanical == 0:
            record["status"] = (
                "missing_untracked_file"
                if causes["missing_untracked_file"] else "broken_source"
            )
            break
        # A round that changed nothing will not change anything next time either.
        previous = record["rounds"][-2]["lib_errors"] if len(record["rounds"]) > 1 else None
        if previous == analysis["error_count"]:
            record["status"] = "no_progress"
            break
    else:
        record["status"] = "exhausted_rounds"

    final = analyze_lib(root)
    record["lib_errors"] = final["error_count"]
    record["files_affected"] = final["files_affected"][:50]
    record["sample_errors"] = final["errors"][:15]
    record["causes"] = final["causes"]
    record["seconds"] = round(time.monotonic() - started, 1)
    if final["error_count"] == 0:
        record["status"] = "clean"
    return record


def run(repo_names: list[str] | None = None, *, jobs: int = 1,
        resume: bool = False, retry_failed: bool = False) -> dict:
    repos = config.selected(repo_names)
    config.PROBE_DIR.mkdir(parents=True, exist_ok=True)

    # A repository already driven to a verdict is not re-driven. `pub get` plus codegen
    # plus two `flutter analyze` passes is minutes per repository even when it succeeds,
    # and the verdict does not change unless the checkout does.
    #
    # `pub get`, codegen and `flutter analyze` are all subprocess-bound, and each
    # repository is a separate checkout, so this parallelises. Kept modest by
    # default: concurrent `pub get` contends on the shared pub cache, and a
    # download storm is a good way to get rate-limited rather than finished.
    def prepare_and_checkpoint(repo: dict) -> dict:
        record = prepare_repo(repo)
        checkpoints.write("prepare", repo["repo_name"], record)
        return record

    def begin(todo: list[dict], workers: int) -> None:
        if workers > 1:
            print(f"preparing {len(todo)} repositories with {workers} workers", flush=True)

    def started(repo: dict, i: int, total: int) -> None:
        print(f"[{i}/{total}] {repo['repo_name']}", flush=True)

    def finished(repo: dict, record: dict, done: int, total: int, parallel: bool) -> None:
        detail = (f"{record['status']} lib_errors={record.get('lib_errors')} "
                  f"({record.get('seconds')}s)")
        print(f"[{done}/{total}] {repo['repo_name']}: {detail}" if parallel
              else f"  -> {detail}", flush=True)

    # Repositories neither walked nor resumed this run are recovered from their own
    # checkpoints by the sweep. Without that a `--repos`-scoped run rewrites
    # `prepare_report.json` from that subset alone, and `clean_repos` -- which `discover`
    # and `isolate` both gate on -- silently shrinks to it.
    swept = checkpoints.sweep(
        "prepare", repos, prepare_and_checkpoint, jobs=jobs, resume=resume,
        retry_failed=retry_failed, on_begin=begin, on_start=started, on_done=finished)
    records = swept.records

    clean = [r for r in records if r["status"] == "clean"]
    summary = {
        "phase": "prepare",
        "ran_at": datetime.now(timezone.utc).isoformat(),
        "requested": len(records),
        "walked_this_run": swept.this_run,
        "resumed_from_checkpoint": [r["repo_name"] for r in swept.resumed],
        "carried_from_checkpoint": [r["repo_name"] for r in swept.carried],
        "clean": len(clean),
        "clean_repos": [r["repo_name"] for r in clean],
        "dropped": {
            r["repo_name"]: {"status": r["status"], "lib_errors": r.get("lib_errors")}
            for r in records
            if r["status"] != "clean"
        },
        "seconds_total": round(sum(r.get("seconds") or 0 for r in records), 1),
        "workers": swept.workers,
        "status_counts": dict(sorted(
            collections.Counter(r["status"] for r in records).items(),
            key=lambda kv: -kv[1],
        )),
        "repos": records,
    }
    config.PREPARE_REPORT.write_text(json.dumps(summary, indent=2) + "\n")
    print(f"\n{summary['clean']}/{summary['requested']} repositories reached zero lib errors")
    if summary["dropped"]:
        print("dropped:")
        for name, why in summary["dropped"].items():
            print(f"  {name:50s} {why['status']:18s} lib_errors={why['lib_errors']}")
    print(f"wrote {config.PREPARE_REPORT.relative_to(config.PROJECT_ROOT)}")
    return summary
