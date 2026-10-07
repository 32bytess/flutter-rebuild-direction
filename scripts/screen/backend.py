"""The Dart subprocess boundary, and the per-file verdict cache in front of it."""

from __future__ import annotations

import json
from pathlib import Path

from scripts import ast_tools

# The resume cache, written beside the records rather than beside the corpus: `--source` is
# often a frozen tree that must not be written to.
CACHE_NAME = ".screen_cache.json"

# The rules and the rewrites are evaluated in `scripts/dart_tools`, on `package:analyzer`,
# where an identifier is an identifier and a comment is not part of the program. There is one
# backend, and `DartBackend` is it.


class DartBackend:
    """`scripts/dart_tools`, over one subprocess per batch.

    Paths are primed in bulk because a `dart run` costs more to start than to run: priming
    the whole corpus in one call is what keeps a full screen to one subprocess.
    A path that was never primed still works -- it falls back to a batch of one -- so no
    call site has to know whether priming happened.
    """

    name = "dart"

    def __init__(self):
        self._primed: dict[str, dict] = {}

    def fingerprint(self) -> str:
        """Deferred to the Dart tool: the vocabulary lives there now, so hashing anything
        on this side would leave a rule edit invisible to the checkpoint mode."""
        return ast_tools.rules_version()

    def prime(self, paths: list[Path]) -> None:
        fresh = [p for p in paths if str(p.resolve()) not in self._primed]
        if fresh:
            self._primed.update(ast_tools.screen(fresh))

    def analyse(self, path: Path) -> tuple[list[str], str, list[dict]]:
        key = str(path.resolve())
        row = self._primed.get(key)
        if row is None:
            self.prime([path])
            row = self._primed[key]
        # The drops ride along rather than being fetched separately: R19 is already decided
        # from them on the Dart side, and R20 needs the detail a rule id cannot carry. A row
        # from a build without them reads as no drops, which is the pre-R19 verdict.
        return row["rules"], row["normHash"], row.get("shimDrops") or []

    def rewrites(self, paths: list[Path], *,
                 prune_imports: bool = True) -> dict[Path, tuple[str, dict[str, int]]]:
        rows = ast_tools.normalise(paths, prune_imports=prune_imports)
        return {p: (rows[str(p.resolve())]["text"], rows[str(p.resolve())]["counts"])
                for p in paths}

    def splits(self, paths: list[Path], *,
               prune_imports: bool = True) -> dict[Path, dict]:
        """The fixture split for each path, normalisation included.

        Replaces `rewrites` rather than following it: the split is computed against the
        normalised text, so the one pass returns both the finished transplant and the
        substitution counts the report prints. `scripts/fixture_skeleton` turns these rows
        into one `dependencies.dart` per group.
        """
        rows = ast_tools.fixture(paths, prune_imports=prune_imports)
        return {p: rows[str(p.resolve())] for p in paths}


class Screener:
    """Rule verdicts per file, memoised across runs by (size, mtime_ns).

    Classification is a pure function of file content, so the only reason to re-read a
    file is that it changed. `rsync -a` and `copy2` both preserve mtime, which is what
    makes a stat comparison sufficient here rather than merely fast.
    """

    # WHAT `backend` IS FOR, since it reads like a substitution seam and is not one.
    # There is one backend in production and `DartBackend` is it. The parameter exists so a
    # single INSTANCE can be shared: `screen_samples._one_pass` builds one, hands the same
    # object to `screen_mode` for the rule digest, to this class, and on to `build_fixtures`
    # via `screener.backend`. `DartBackend.prime` memoises a whole corpus into one subprocess
    # call, and a second instance would throw that away and re-run `dart` per batch.
    #
    # It is nonetheless a real seam, because the tests substitute across it: see
    # `tests/test_screener_cache.py`, which drives the cache with a stub that counts calls.
    # What must NOT go behind it is a recorded set of Dart verdicts -- that would be a second
    # golden corpus needing regeneration on every rule edit, which is the one thing
    # the project rules say must never be done to make a test pass. The rule verdicts belong to
    # `test_golden_corpus.py` and `test_calibration.py`, and both keep the real backend.
    def __init__(self, source: Path, cache_path: Path, *, enabled: bool = True,
                 backend=None):
        self.source = source
        self.cache_path = cache_path
        self.enabled = enabled
        self.backend = backend or DartBackend()
        self.cache: dict[str, list] = {}
        self.hits = self.misses = 0
        # The cache is stamped with the rule digest of the backend that filled it. It was
        # added when there were two backends and a `dart` run silently reused verdicts the
        # regexes had written; it earns its place now on rule EDITS, which move the digest
        # the same way. Same reason the checkpoint mode carries it.
        self.stamp = f"{self.backend.name}:{self.backend.fingerprint()}"
        if enabled and cache_path.is_file():
            try:
                stored = json.loads(cache_path.read_text())
            except json.JSONDecodeError:
                stored = {}              # a truncated cache costs a re-screen, not a wrong answer
            if isinstance(stored, dict) and stored.get("stamp") == self.stamp:
                self.cache = stored.get("files") or {}
        self.fresh: dict[str, list] = {}

    def rules_for(self, path: Path) -> list[str]:
        key = path.relative_to(self.source).as_posix()
        stat = path.stat()
        cached = self.cache.get(key)
        if cached and cached[0] == stat.st_size and cached[1] == stat.st_mtime_ns:
            self.hits += 1
            self.fresh[key] = cached
            return cached[2]
        self.misses += 1
        rules, norm_hash, drops = self.backend.analyse(path)
        entry = [stat.st_size, stat.st_mtime_ns, rules, norm_hash, drops]
        self.fresh[key] = entry
        return rules

    def prime(self, paths: list[Path]) -> None:
        """Hand the backend every path whose cached verdict is stale, in one batch.

        Cache hits are decided by `stat` alone, so priming reads nothing it would not have
        read anyway -- which is what keeps `--resume` mid-mine as cheap as it was when the
        rules were a local regex call.
        """
        self.backend.prime([p for p in paths if not self._cached(p)])

    def _cached(self, path: Path) -> bool:
        if not self.enabled or not path.is_file():
            return False
        cached = self.cache.get(path.relative_to(self.source).as_posix())
        if not cached:
            return False
        stat = path.stat()
        return cached[0] == stat.st_size and cached[1] == stat.st_mtime_ns

    def norm_hash(self, path: Path) -> str:
        key = path.relative_to(self.source).as_posix()
        if key not in self.fresh:
            self.rules_for(path)
        return self.fresh[key][3]

    def shim_drops(self, path: Path) -> list[dict]:
        """What R20 compares, per role. See `scripts/screen/shims.py`.

        A cache entry written before R19 existed has no fifth slot; it cannot be read here
        anyway, because the stamp carries the rule digest and adding R19 moved it. The
        `len` guard is for a hand-truncated cache, not for a migration.
        """
        key = path.relative_to(self.source).as_posix()
        if key not in self.fresh:
            self.rules_for(path)
        entry = self.fresh[key]
        return entry[4] if len(entry) > 4 else []

    def save(self) -> None:
        if not self.enabled:
            return
        self.cache_path.parent.mkdir(parents=True, exist_ok=True)
        self.cache_path.write_text(
            json.dumps({"stamp": self.stamp, "files": self.fresh}))
