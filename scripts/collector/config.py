import os

from dotenv import load_dotenv

from scripts.mining.config import REPOS_ROOT as CORPUS_V2_REPOS_ROOT
from scripts.paths import PROJECT_ROOT

load_dotenv(PROJECT_ROOT / ".env")

GITHUB_TOKEN: str = os.environ.get("GITHUB_TOKEN", "")
GITHUB_API = "https://api.github.com"

ALLOWED_LICENSES = {"mit", "apache-2.0", "bsd-3-clause"}

# Repo-level discovery queries. GitHub code search has no `android`/`mobile`
# qualifiers — free-text terms there are matched against file *content* — so
# discovery runs against /search/repositories instead and the state-management
# patterns below are detected locally in the clone.
REPO_SEARCH_QUERIES = [
    # -- round 4 (2026-09-09): an EXHAUSTIVE partition, replacing rounds 1-3 -----------
    # Rounds 1-3 each opened a slice and each was exhausted by the 1000-result cap, so by
    # 2026-09-06 a harvest scanned 19 new repositories and accepted 2. The problem was never
    # paging: MAX_REPO_SEARCH_PAGES * per_page is exactly 1000, so the collector already
    # walked every page GitHub will serve, and every query's tail past result 1000 was
    # unreachable. Adding another narrow query could not fix that -- a subset of an exhausted
    # query returns nothing new.
    #
    # Measured against the live API on 2026-09-09, the whole population at these thresholds
    # is 6,391 repositories (`language:Dart stars:>=50 forks:>=5`). The `created:` bands below
    # partition it: each is under the cap, and their counts SUM TO EXACTLY 6,391, so no
    # repository in the population is unreachable. That is the property rounds 1-3 lacked, and
    # it is why this block replaces them rather than being appended to them.
    #
    # Measured band counts, in order: 241, 140, 313, 477, 686, 630, 721, 549, 436, 339, 632,
    # 489, 329, 409. Re-measure before trusting them: a band that grows past 1000 is silently
    # truncated again, and page 10 coming back full is the tell.
    #
    # `stars:>=50 forks:>=5` is NOT written here -- `discovery.discover_candidates` appends
    # MIN_STARS/MIN_FORKS to every query, and repeating them would double the qualifier.
    "language:Dart created:<2017",
    "language:Dart created:2017-01-01..2017-12-31",
    "language:Dart created:2018-01-01..2018-06-30",
    "language:Dart created:2018-07-01..2018-12-31",
    "language:Dart created:2019-01-01..2019-06-30",
    "language:Dart created:2019-07-01..2019-12-31",
    "language:Dart created:2020-01-01..2020-06-30",
    "language:Dart created:2020-07-01..2020-12-31",
    "language:Dart created:2021-01-01..2021-06-30",
    "language:Dart created:2021-07-01..2021-12-31",
    "language:Dart created:2022-01-01..2022-12-31",
    "language:Dart created:2023-01-01..2023-12-31",
    "language:Dart created:2024-01-01..2024-12-31",
    "language:Dart created:>2025-01-01",
    # The one slice that is INSIDE the declared population and outside every query rounds 1-3
    # ever ran: a Flutter app whose primary language GitHub does not call Dart. Linguist
    # counts bytes, so an app carrying large native `ios/`/`android/` trees is labelled C++,
    # Swift or Kotlin and no `language:Dart` query can see it -- and every query in rounds 1-3
    # carried one. 597 repositories at these thresholds, under the cap, so no partition.
    #
    # Nothing downstream needs to change to admit them: the accept criteria are all content
    # checks against the clone -- an `android/` folder, null safety, app-not-package, and the
    # SEARCH_PATTERNS grep over `lib/**/*.dart` -- so these are judged on exactly the same
    # evidence as every other candidate, by the same code.
    "topic:flutter -language:Dart",
    "topic:flutter-app -language:Dart",
    # -- rounds 1-3, kept as provenance -------------------------------------------------
    # Superseded by the partition above, which reaches everything these did and everything
    # they could not. Left in place as a record of the searches that built the candidate list.
    #
    # -- round 1 (2026-08-17): produced 105 accepted of 1,299 scanned ------------------
    # "language:Dart topic:flutter",
    # "language:Dart flutter app",
    # "language:Dart flutter_bloc OR provider OR getx OR riverpod",
    # -- round 2 (2026-08-19) ----------------------------------------------------------
    # Search returns at most 1000 results per query, sorted by stars descending, so the
    # three queries above are exhausted: their tails are unreachable. The additions below
    # each open a different slice, and target the three deficits measured on the v2
    # eligible pool.
    #
    # (a) VOLUME: partition the core query by star band. Each band returns under the
    #     1000 cap, so together they reach repositories the unpartitioned query cannot.
    # "language:Dart topic:flutter stars:50..75",
    # "language:Dart topic:flutter stars:75..150",
    # "language:Dart topic:flutter stars:150..400",
    # "language:Dart topic:flutter stars:400..1500",
    # "language:Dart topic:flutter stars:>1500",
    # (b) DIVERSITY: the eligible pool is 92% State + BlocSelector, with Obx and Consumer
    #     contributing one scope each. These target the under-represented families
    #     directly, since scope type follows from the state-management library in use.
    # "language:Dart getx",
    # "language:Dart riverpod",
    # "language:Dart mobx",
    # "language:Dart provider state management",
    # (c) PREPARE RATE: only 34% of harvested repos reach a clean lib/, and the dominant
    #     causes are unsatisfiable_dependencies (30) and broken_source (24) -- both
    #     toolchain drift. Recently-pushed repositories resolve against a current Flutter
    #     SDK far more often, so recency is a direct lever on the binding constraint.
    # "language:Dart flutter pushed:>2025-06-01",
    # "language:Dart topic:flutter-app pushed:>2025-01-01",
    # "language:Dart topic:flutter-ui",
    # "language:Dart topic:flutter-examples",
    # -- round 3 (2026-09-06) ----------------------------------------------------------
    # Measured exhaustion, not a guess: the 2026-09-06 additive harvest scanned 19 new
    # repositories and accepted 2 (candidates 202 -> 204). Round 2 star-partitioned
    # `topic:flutter` and so exhausted it, but left SEVEN queries unpartitioned and
    # therefore still capped at the 1000-result ceiling -- `flutter app`, the four-way
    # state-management disjunction, `getx`, `riverpod`, `mobx`,
    # `provider state management` and `flutter pushed:>2025-06-01`. Their tails have
    # never been reachable. The blocks below open slices, never thresholds:
    # MIN_STARS/MIN_FORKS are deliberately untouched, because lowering them would
    # redefine the population the corpus is drawn from rather than sample more of it.
    #
    # (d) VOLUME: the same partition round 2 applied to `topic:flutter`, applied to the
    #     queries it left whole. Each band returns under the cap, so together they reach
    #     what the unpartitioned query cannot.
    # "language:Dart flutter app stars:50..150",
    # "language:Dart flutter app stars:150..500",
    # "language:Dart flutter app stars:>500",
    # "language:Dart getx stars:50..150",
    # "language:Dart getx stars:>150",
    # "language:Dart riverpod stars:50..150",
    # "language:Dart riverpod stars:>150",
    # "language:Dart provider state management stars:50..150",
    # "language:Dart provider state management stars:>150",
    # (e) VOLUME: topic slices no round has queried. Repositories that never set
    #     `topic:flutter` are invisible to every query above, whatever their star count.
    # "language:Dart topic:flutter-widgets",
    # "language:Dart topic:flutter-package",
    # "language:Dart topic:flutter-demo",
    # "language:Dart topic:dart-flutter",
    # "language:Dart topic:flutter-application",
    # (f) PREPARE RATE, still the binding constraint: 84 of 196 harvested repositories
    #     reached a clean lib/ (43%), and the two dominant refusals are toolchain drift
    #     -- broken_source 44, unsatisfiable_dependencies 38. Recency windows partition
    #     the same population by how likely it is to resolve against a current SDK.
    #     Overlap with (d) is intended: `seen` dedupes within a run and
    #     `already_scanned_repo` across runs, so overlap costs API calls, never rows.
    # "language:Dart topic:flutter pushed:>2026-01-01",
    # "language:Dart topic:flutter pushed:2025-01-01..2025-12-31",
    # "language:Dart flutter app pushed:>2026-01-01",
    # (g) DIVERSITY: state-management families no query names. The eligible pool is 92%
    #     State + BlocSelector, and scope type follows from the library in use.
    #     NOTE: SEARCH_PATTERNS still gates these at the grep -- `stacked`'s
    #     ViewModelBuilder and `flutter_hooks`' HookWidget are not in that vocabulary, so
    #     such a repository is accepted only if it also carries one of the eight patterns
    #     (in practice `extends State<`, which almost every app has somewhere). Widening
    #     SEARCH_PATTERNS is the complementary lever and is a separate decision.
    # "language:Dart stacked",
    # "language:Dart flutter_hooks",
    # "language:Dart state_notifier",
    # "language:Dart get_it",
]

MAX_REPO_SEARCH_PAGES = 10  # repo search caps out at 1000 results

# Grep vocabulary applied to lib/**/*.dart of each clone.
SEARCH_PATTERNS = [
    "extends State<",
    "Consumer",
    "ConsumerWidget",
    "BlocBuilder",
    "BlocSelector",
    "BlocConsumer",
    "Obx",
    "GetBuilder",
]

# Our own repos must never enter the candidate set.
OWNER_BLACKLIST = {"32bytess"}

# Repository-level exclusions, shared with `mining`. Checked in `discovery` -- BEFORE
# the candidate is cloned and grepped -- because that is the first point in the pipeline
# where admitting a repository costs anything: a depth-1 clone, then a blobless clone,
# then `prepare` at minutes and ~1.3 GB apiece with a 34% pass rate. Excluding at
# selection time, as a flag does, pays all of that first and discards it after.
def barred_repo_keys() -> set:
    """`data/exclusions.txt` plus the repositories `samples/` was built from."""
    from scripts.mining.config import barred

    return barred()

MIN_STARS = 50
MIN_FORKS = 5

_DATA_DIR = PROJECT_ROOT / "data"
OUTPUT_DIR = _DATA_DIR / "candidates"
# The clones live outside the repository - 2.4G of third-party checkouts do not belong in a
# tracked tree. Defined once in mining.config so this and `scripts.clone_repos` cannot
# drift apart; the manifests below stay here, next to the collector's own state.
REPOS_DIR = CORPUS_V2_REPOS_ROOT
DB_PATH = _DATA_DIR / "collected_repos.db"
CANDIDATES_FILE = _DATA_DIR / "candidates.jsonl"
CANDIDATES_CSV = _DATA_DIR / "candidates.csv"

MAX_CANDIDATES = 100

REPO_SEARCH_DELAY = 2.5  # search API allows 30 req/min when authenticated
API_DELAY = 0.5
