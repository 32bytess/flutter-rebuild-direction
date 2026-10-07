"""Configuration for the v2 corpus mine: human-written edits from unseen repositories.

The question, and why it differs from `scripts.history_probe`:

    `history_probe` mined the 8 repositories the corpus was BUILT from, and failed twice
    over - on yield (139 pairs, 11 with a nonzero delta, against a gate of 25) and on
    independence (pairs drawn from the same repos that produced the 43 seed groups do not
    test the model against anything new).

    This package mines the repositories harvested 2026-08-17, of which 101 are genuinely
    unseen. Human commits carry no directive identity, so a stratum built from them is the
    direct antidote to the directive confound (directive-only AUC 0.843 vs the 12-feature
    model's 0.784) - but only if the edits exist AND the extractor sees them move.

Everything here is read-only configuration. Phases that touch the clones announce themselves.
"""

from __future__ import annotations

import json
from pathlib import Path

from .. import spm
from ..paths import ACADEMIC_ROOT, PROJECT_ROOT

# ---- Roots -----------------------------------------------------------------------------
# `PROJECT_ROOT` is the repository root and `ACADEMIC_ROOT` its parent, both found by
# marker in `scripts.paths` rather than by counting this file's parents.

# The clones live OUTSIDE the repository: 2.4G of third-party checkouts do not belong in a
# tracked tree, and moving them out is what `data/candidates.jsonl` now points at. This is
# the single definition; `scripts.collector.config` and `scripts.clone_repos` read it rather
# than each rebuilding the path and drifting apart.
REPOS_ROOT = ACADEMIC_ROOT / "new_data" / "repos"          # depth-1 clones (the collector's)
REPOS_FULL_ROOT = ACADEMIC_ROOT / "new_data" / "repos-full"  # blobless clones, full history

# The manifests stay in the repository - they are small, and they are the collector's own
# state.
DATA_DIR = PROJECT_ROOT / "data"
CANDIDATES_FILE = DATA_DIR / "candidates.jsonl"
CANDIDATES_CSV = DATA_DIR / "candidates.csv"

# ---- Outputs ---------------------------------------------------------------------------
PROBE_DIR = PROJECT_ROOT / "probe_v2"
CLONE_REPORT = PROBE_DIR / "clone_report.json"
PREPARE_REPORT = PROBE_DIR / "prepare_report.json"
TARGETS = PROBE_DIR / "targets.jsonl"
HISTORY_FEATURES = PROBE_DIR / "history_features.jsonl"
HISTORY_PAIRS = PROBE_DIR / "history_pairs.jsonl"
MINE_SUMMARY = PROBE_DIR / "mine_summary.json"
STATE_FILE = PROBE_DIR / "state.json"

# What the mine writes and the screen reads. Named here rather than spelled as a literal in
# each caller, because `screen_samples --source` and `pipeline --dest` are the two ends of
# the same arrow and a typo in either builds a corpus from the wrong tree without saying so.
SAMPLES_V2 = PROBE_DIR / "samples_v2"

# The default destination for a NEW corpus. Not `new_samples/`: that holds the frozen arm-2
# corpus, and a pipeline that grew it would change what was measured. Building elsewhere
# keeps arm 2 measurable while a second corpus is under construction.
DEFAULT_PIPELINE_DEST = PROJECT_ROOT / "new_samples_v3"

# ---- The extractor ---------------------------------------------------------------------
# The container's own dependency, and there is exactly one. Every module in this repository
# runs it, so `dart run spm:spm` from PROJECT_ROOT is the single entry point and there is no
# local-checkout drift to reason about.
#
# SINCE 2026-09-05 THAT DEPENDENCY IS 0.7.1, BY PATH: `spm: {path: ../spm-publish}` rather
# than `spm: ^0.7.0` from pub.dev. 0.7.1 is the first build to emit `inlinedThirdPartyPackages`,
# which `R17_package_license` needs, and it is not published, so a path is the only way to have
# it. The build is commit `0c174f7` in that repository; a path dependency records no
# sha256 in `pubspec.lock`, so the commit is what names it. It also means the dependency follows
# whatever branch `spm-publish` is on, which the hosted pin did not.
#
# FOR THE RELEASE THE DEPENDENCY IS `spm: 0.7.2` FROM PUB.DEV. 0.7.1 and 0.7.2 have since been
# published; their pub.dev archives are file-for-file identical to commits `0c174f7` and
# `0d749b5`, and 0.7.2 is 0.7.1 plus the `spm inject` fix arm 2 already ran from source.
#
# TWO BUILDS ARE THEREFORE IN PLAY, DELIBERATELY. `probe_v2/samples_v2` and `dataset/` were
# written by 0.7.0 from pub.dev; the dependency is now 0.7.1, whose transplant emitter differs
# (`AppConstants.builderScopeWidgets` in the walk-out from a builder callback, and the shared
# `elementOf` probe order). Nothing re-mines. The one pass that runs spm against those commits
# again is `license_provenance`, and its byte-identity gate is what connects the two: a row
# counts only where 0.7.1 reproduces 0.7.0's transplant byte for byte.
#
# It reaches the MEASUREMENT side too, which is easy to miss: `integration_test/` imports
# `package:spm/spm.dart`, and 0.7.1 removed a `print` that `SpmState.setState` ran on every
# measured rebuild under 0.7.0. The print ran before the measured span opened.
#
# The pooling condition this comment used to state as pending HAS BEEN MET: dataset/*/static.jsonl
# was re-extracted under 0.7.0 on 2026-08-25 11:07 (commit 8c36f0900, "0.7.0 dataset"), minutes
# before the exports behind the reported figures were written from it. The pre-0.7.0 vectors are
# not in this release and are not an input.
# Rows produced here are therefore poolable with the 1,454 contrasts as far as extractor build
# goes - every other reason not to pool them (different corpus, no device measurements) stands.
#
# 0.5.2 is a HARD BREAK for `isolate` output specifically, on top of the 0.5.0 one. Its
# changelog is explicit that files written by 0.5.1 and earlier "carry imports of packages
# that were never meant to be there and references to names nothing declares", so a corpus
# may not mix the two. The two upgrades that matter downstream:
#
#   * every third-party import is now stood in for rather than emitted, because the gate
#     deciding what may be imported tested `package:flutter` without its trailing slash and
#     so let `flutter_bloc`, `flutter_riverpod`, `fluttertoast` and friends through. Import
#     prefixes, `show` and `hide` now survive the transplant too.
#   * `isolate` ANALYSES what it wrote before reporting, and puts the verdict on each
#     mapping row (`verified`, `errorCount`, `warningCount`, `topCodes`,
#     `unresolvedImports`, `unresolvedNames`, and `sourceDependenciesResolved` when the
#     source project's own dependencies never resolved). `mining.isolate.verification`
#     carries those through to `groups.jsonl` and `code_rows.jsonl`, and
#     `scripts.screen_samples` R10 excludes on them. That verdict is authoritative: a file
#     carrying an error is SKIPPED by `spm analyze`, so an unclean transplant contributes
#     no metrics rather than slightly wrong ones.
#
# 0.6.0 is a HARD BREAK for `isolate` output again, on top of 0.5.2's. Its changelog is
# explicit that output from 0.6.0 cannot be pooled with 0.5.2's: the same scope produces a
# different file and, where a package widget is involved, different metrics. What changed:
#
#   * the gate now asks "is this the SDK" rather than "is this project-local". The SDK is
#     imported, anything that can PRODUCE UI is carried as source whether it is repo-local
#     or third-party, and everything else becomes a declaration-only stand-in. A
#     third-party StatefulWidget arrives with its companion State, which is the half that
#     matters, since that is where the build body lives. Carrying is bounded at 200
#     declarations / 200,000 characters per scope and is REVERTED per scope when the file
#     analyses worse than the stood-in version would have, so no row ends up worse than
#     `--no-inline-third-party` gives. Three new mapping fields report all of that:
#     `inlinedThirdPartyDeclarations`, `thirdPartyInlineTruncated`,
#     `thirdPartyInlineReverted` - carried through by `isolate.VERIFICATION_KEYS`. 0.7.1 adds
#     a fourth, `inlinedThirdPartyPackages`, naming the packages rather than counting them;
#     it is carried through too, but no row on disk has one, since the mine ran 0.7.0.
#   * `sourceDependenciesResolved` could previously only ever be false ONCE per checkout,
#     because an existing `package_config.json` was taken as proof of resolution and the
#     minimal one spm writes on a failed `pub get` satisfied that check. In a history walk
#     a worktree keeps its `.dart_tool` across checkouts, so that was every revision after
#     the first. Expect this flag to fire far more often than in earlier rounds; counts
#     taken from 0.5.2 output are FLOORS.
#   * the verifier reported a file it could not analyse as a file with no errors. Every
#     failure to fetch diagnostics was swallowed into an empty diagnostic list, which is
#     indistinguishable from a clean run. Expect more `verified: false`, not fewer.
#   * a builder given a tear-off rather than an inline closure was a scope to `isolate`
#     and not to `analyze`, so it minted a group and a file that could never analyse clean
#     for a scope `analyze` never reports. Both commands take the rule from one place now,
#     so group counts come out LOWER and the two commands finally agree.
#   * `isolate` over a path that does not exist is now an error rather than success over
#     zero scopes, and unused imports are no longer pruned from the output (a warning,
#     never an error; `screen_samples --prune-unused-imports` still removes them on export).
#
# Neither `analyze` nor `isolate` is passed an inlining flag here, so the run gets the
# default, `--inline-third-party`.
#
# The output directory now also receives a `pubspec.yaml` and a `.dart_tool/` that spm
# writes so the isolated files resolve `package:flutter` where they sit. Anything walking
# an isolate output directory must therefore select `.dart` files rather than assume the
# directory holds only transplants.
# Defined once in `scripts.spm`, which owns the subprocess and can say WHICH BUILD it is.
# Kept as names here because every phase in this package reaches them through `config`.
SPM_CWD = spm.CWD               # the cwd `dart run spm:spm` resolves the package from --
                                # which, with a path dependency, is what pins the build
SPM_ENTRY = spm.ENTRY

# ---- Repository selection --------------------------------------------------------------
# Already in the measured corpus. Mining these would reintroduce exactly the dependence the
# v2 stratum exists to remove, so they are excluded from it by name rather than by hope.
#
# Kept as a literal for the reader and as a floor, but NOT as the operative set: what is
# actually enforced is `corpus_keys()`, derived from the sample manifests. A literal cannot
# notice that `samples/` changed, and the failure it produces is silent - a repository that
# contributed seed groups gets mined as though it were unseen, and nothing in the output
# says so.
CORPUS_REPOS = {
    "DompetApp/Dompet.flutter",
    "Hash-Studios/Prism",
    "SatoshiPortal/bullbitcoin-mobile",
    "WheretoSleepinNJU/NJU-Class-Shedule-Flutter",
    "amugofjava/anytime_podcast_player",
    "deckerst/aves",
    "fluttercandies/wechat_flutter",
    "nknorg/nMobile",
}

# The 5-repo pilot. Each buys a different failure mode, and between them they cover the scope
# types that are scarce across the harvest (13 BlocBuilder, 6 Obx, 5 GetBuilder, 2
# BlocSelector out of 105). None is in CORPUS_REPOS.
PILOT_REPOS = [
    "yang991178/fluent-reader-lite",            # no codegen, State+Consumer - the floor cost
    "alperefesahin/flutter_social_chat",        # Bloc family, build_runner only
    "KyleKun/one_second_diary",                 # Obx/GetX, no codegen
    "wasabeef/flutter-architecture-blueprints", # freezed+auto_route+retrofit - hardest prepare
    "CarGuo/gsy_github_app_flutter",            # 15.5k stars, 284 dart files - the scale case
]

# ---- Rebuild-scope markers -------------------------------------------------------------
# Mirrors AppConstants.rebuildScopeTypes plus the State declaration form. Used ONLY as a
# cheap git-level seed filter; SPM decides what is really a rebuild scope.
SCOPE_MARKERS = (
    "extends State<",
    "BlocBuilder", "BlocConsumer", "BlocSelector",
    "Consumer", "ConsumerWidget", "HookConsumerWidget",
    "Obx", "GetX", "GetBuilder",
    "Selector", "Observer",
)

# ---- History cutoff --------------------------------------------------------------------
# Dart 2.12 shipped sound null safety on 2021-03-03. Commits before it are a different
# language: the analyzer this study runs cannot resolve them against a modern SDK, so their
# scopes come back unresolved or shallow, and a delta measured across that boundary records
# the migration rather than a human's rebuild-scope edit.
#
# The collector already requires null-safety opt-in AT HEAD, which says nothing about the
# history behind it. This is the same requirement applied to the commits actually walked.
NULL_SAFETY_DATE = "2021-03-03"

# Dart 3.0 shipped on 2023-05-10 (with Flutter 3.10): sound null safety became mandatory,
# records/patterns/sealed classes arrived, and the 2.x-only constructs the analyzer still
# tolerated stopped resolving. A corpus bounded here is uniformly Dart 3 code, so no delta
# straddles a language-version boundary.
DART3_DATE = "2023-05-10"


def parse_since(value: str | None) -> int | None:
    """`--since` -> a UTC epoch second, or None for no cutoff.

    Accepts `YYYY-MM-DD`, the alias `null-safety` for the Dart 2.12 release date, or
    `dart3` for the Dart 3.0 release date.
    """
    if not value:
        return None
    import datetime as _dt

    aliases = {
        "null-safety": NULL_SAFETY_DATE, "nullsafety": NULL_SAFETY_DATE,
        "dart3": DART3_DATE, "dart-3": DART3_DATE, "dart3.0": DART3_DATE,
    }
    text = aliases.get(value.lower(), value)
    try:
        day = _dt.datetime.strptime(text, "%Y-%m-%d").replace(tzinfo=_dt.timezone.utc)
    except ValueError:
        raise SystemExit(f"--since: expected YYYY-MM-DD, 'null-safety' or 'dart3', got {value!r}")
    return int(day.timestamp())


# ---- Gates and runtime -----------------------------------------------------------------
PREPARE_MAX_ROUNDS = 3      # rounds of pub-get/codegen before a repo is dropped at HEAD
SPM_TIMEOUT_S = 900
GIT_TIMEOUT_S = 3600
FLUTTER_TIMEOUT_S = 1800


SAMPLES_DIR = PROJECT_ROOT / "samples"
# Manifests that name the repositories `samples/` was built from. `project` is written in
# the on-disk `owner_name` form, which is why every comparison happens in normalized space
# rather than on raw strings.
SAMPLES_MANIFESTS = (
    SAMPLES_DIR / "sources.jsonl",
    SAMPLES_DIR / "map.jsonl",
)

# The standing exclusion list: repositories that must never enter the stratum, for reasons
# that outlive any one run. One `owner/name` per line, `#` starts a comment - so each entry
# can carry WHY, which a `--exclude` flag on a command line can never do.
EXCLUSIONS_FILE = DATA_DIR / "exclusions.txt"


def corpus_keys() -> set[str]:
    """Normalized keys of every repository the measured corpus was built from.

    Read from `samples/` rather than trusted to `CORPUS_REPOS`, and UNIONED with it: a
    manifest that is missing, truncated or renamed can then only ever exclude too much,
    never too little. The one direction that must not be possible is the quiet one.
    """
    keys = {normalize_repo_name(name) for name in CORPUS_REPOS}
    for path in SAMPLES_MANIFESTS:
        if not path.is_file():
            continue
        for line in path.read_text(errors="replace").splitlines():
            if not line.strip():
                continue
            try:
                row = json.loads(line)
            except json.JSONDecodeError:
                continue
            project = row.get("project")
            if project:
                keys.add(normalize_repo_name(project))
    return keys


def file_exclusions() -> set[str]:
    """The standing exclusions from `data/exclusions.txt`, as normalized keys.

    Applied by `selected()`, so it reaches every phase without any of them opting in -
    including `clone`, which is where excluding a repository first saves something real.
    """
    if not EXCLUSIONS_FILE.is_file():
        return set()
    keys = set()
    for line in EXCLUSIONS_FILE.read_text(errors="replace").splitlines():
        entry = line.split("#", 1)[0].strip()
        if entry:
            keys.add(normalize_repo_name(entry))
    return keys


def candidates() -> list[dict]:
    """Every harvested repository, as the collector recorded it."""
    return [
        json.loads(line)
        for line in CANDIDATES_FILE.read_text().splitlines()
        if line.strip()
    ]


def barred() -> set[str]:
    """Every normalized key a phase must refuse: the corpus repos plus the standing list."""
    return corpus_keys() | file_exclusions()


def eligible() -> list[dict]:
    """Every harvested repository that may enter the v2 stratum.

    The whole harvest minus the repositories the measured corpus was built from, minus
    `data/exclusions.txt`. Mining the former would reintroduce exactly the dependence this
    stratum exists to remove.
    """
    barred_keys = barred()
    return [
        r for r in candidates()
        if normalize_repo_name(r["repo_name"]) not in barred_keys
    ]


def selected(names: list[str] | None = None) -> list[dict]:
    """The repositories a phase should act on, with the barred set removed unconditionally.

    `names` defaults to the pilot. Passing an explicit list is how the full run reuses this
    same code - the pilot is a parameter, not a fork.

    This is the backstop, not the first line of defence: `collector.discovery` refuses the
    same names before it clones anything, which is where refusing one first costs nothing.
    Both check, because a repository already in `data/candidates.jsonl` from an earlier
    harvest never passes through discovery again.
    """
    wanted = {normalize_repo_name(n) for n in (names if names is not None else PILOT_REPOS)}
    barred_keys = barred()
    return [
        r for r in candidates()
        if normalize_repo_name(r["repo_name"]) in wanted
        and normalize_repo_name(r["repo_name"]) not in barred_keys
    ]


def features_14() -> list[str]:
    """Every metric `spm analyze` emits, in AnalysisResultModel.toJson order."""
    return [
        "treeNonConstWidgetCount",
        "treeMaxWidgetNestingDepth",
        "treeListRenderingStrategy",
        "rootBuildReturnsConstWidget",
        "treeConstWidgetCount",
        "helperReferenceCount",
        "usesLayoutDependentBuilder",
        "treeCyclomaticComplexity",
        "treeIterationCount",
        "treeMaxIterationNestingDepth",
        "iterationWidgetCount",
        "valueObjectAllocCount",
        "helperWidgetCount",
        "helperMaxWidgetNestingDepth",
    ]


def features_12() -> list[str]:
    """The model's features: the 14 minus the two pruned for redundancy in stage 02."""
    pruned = {"treeMaxIterationNestingDepth", "helperMaxWidgetNestingDepth"}
    return [f for f in features_14() if f not in pruned]


def scope_key(project: str, source_file_relative: str, name: str) -> str:
    """Stable scope identity across commits and across analysis roots.

    Never SPM's `instanceId`: that is hashed from the path relative to whatever root the
    invocation was given, so it changes when the root changes.
    """
    return f"{project}::{source_file_relative}::{name}"


def repo_dir_name(repo_name: str) -> str:
    """`owner/repo` -> the on-disk clone directory name the collector used."""
    return repo_name.replace("/", "_")


# ---- Explicit exclusions ----------------------------------------------------------------
# `CORPUS_REPOS` is the unconditional floor: those 8 repositories built the measured
# corpus (`samples/`) and can never enter the v2 stratum. `--exclude` is the operator's
# lever on top of it -- a repository that is fine in principle but unwanted in this run
# (an outlier that owns the whole schedule, a fork of one already mined, a repo whose
# history is being re-walked separately).
#
# Three spellings are accepted, so an exclusion list can be typed, kept in a file, or
# named by the thing it means:
#
#   --exclude dreautall/waterfly-iii        an `owner/name` (or on-disk `owner_name`)
#   --exclude @drop.txt                     one name per line, `#` comments allowed
#   --exclude samples                       the 8 repositories `samples/` was built from
#
# `samples` is a convenience, not a requirement: those 8 are already excluded by every
# phase through `selected()`, and naming them again changes nothing.
EXCLUSION_ALIASES = ("samples", "corpus")


def normalize_repo_name(name: str) -> str:
    """`Owner/Repo`, `owner_repo` and a clone path all collapse to one key.

    The collector writes `owner/name`; the clones on disk are `owner_name`; a shell
    completion hands you a trailing slash. Comparing raw strings would silently accept
    an exclusion that excludes nothing, which is the one failure mode that must not be
    quiet -- a repository the operator believed was dropped, mined anyway.
    """
    text = name.strip().strip("/").replace("\\", "/")
    if "/" in text:
        text = "/".join(text.split("/")[-2:])
    return text.replace("/", "_").lower()


def resolve_exclusions(values: list[str] | None) -> set[str]:
    """`--exclude` arguments -> a set of normalized repository keys."""
    if not values:
        return set()
    out: set[str] = set()
    for value in values:
        token = value.strip()
        if not token:
            continue
        if token.startswith("@"):
            path = Path(token[1:]).expanduser()
            if not path.is_file():
                raise SystemExit(f"--exclude {token}: no such file: {path}")
            for line in path.read_text().splitlines():
                line = line.split("#", 1)[0].strip()
                if line:
                    out.add(normalize_repo_name(line))
            continue
        if token.lower() in EXCLUSION_ALIASES:
            out.update(corpus_keys())
            continue
        out.add(normalize_repo_name(token))
    return out


def apply_exclusions(names: list[str], excluded: set[str]) -> tuple[list[str], list[str]]:
    """Split a repository list into (kept, dropped), reporting what actually matched.

    Returns the dropped names too, because an exclusion that matched nothing is worth
    printing: it is almost always a typo in the name rather than a repository that was
    never in the harvest.
    """
    if not excluded:
        return list(names), []
    kept, dropped = [], []
    for name in names:
        (dropped if normalize_repo_name(name) in excluded else kept).append(name)
    return kept, dropped
