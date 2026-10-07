"""The reproducibility gate: may this tree be deleted, and did it come back the same.

`screen_samples --full --from-nothing` is the one sanctioned alternative to `rm` on the
corpus, and what earns it that exemption is entirely in this module: an audit that refuses if
anything at `--dest` cannot be regenerated from `--source` or has been measured, and a gate
afterwards that checks the regenerated tables and the published counts against what was
committed.

It lived in `screen_samples.py`, ~370 lines of a 1,664-line file, touching no screening rule.
Its only fast-suite coverage was assertions on its own source TEXT -- `"require_fixture_pass_done"
in inspect.getsource(...)` -- because there was no importable interface to call. The interface
here is over paths and digests, so the refusals can be exercised against a tmp tree instead of
grepped for.

`screen_samples` re-exports every name below, so `from scripts import screen_samples as screen`
-- the facade the runbook and the test suite use -- is unchanged.
"""

from __future__ import annotations

import datetime
import json
from pathlib import Path

from scripts import authored_fixtures, fixture_skeleton, jsonio
from scripts.paths import rel
from scripts.screen.backend import CACHE_NAME


def require_fixture_pass_done(root: Path, result: dict) -> None:
    """Refuse `--prune-to-endpoints` on a corpus whose fixtures are not finished.

    The prune is a one-way door, and it is only safe on the far side of the fixture pass:
    `fixture_values.anchor_sha()` takes the group's LOWEST-ORDINAL revision present and
    `constructible()` is fed the union of every `rev_*.dart` in it, so a prune that runs
    first changes what those two see and can move a stored value -- and with it
    `values_version()`, which the screening fingerprint folds in. A prune before the fill
    would therefore invalidate the very screen that decided what to prune.

    The predicate is the FIXTURE GATE over the groups the GENERATED fill was supposed to
    finish: no such group may still carry `// TODO: value`. That is what "the fill has run"
    means operationally, and it is the same gate the runner refuses to measure against.

    Since 2026-09-08 that is not every shipped group. R16 is soft, so a group whose fill
    refused a binding stays eligible and waits for a hand-authored fixture; its slots are
    open BY DESIGN and will stay open until someone writes them. Holding the prune on those
    would mean the prune could never run, and the corpus could never be measured at all. They
    are excluded from this predicate and named in the message instead -- `fixture_gate.py`
    still refuses to measure them, which is where that refusal belongs.

    Their ROLES are not pruned either; see `write_pruned_stamp`. A role that is not an
    endpoint today can become one once the fixture is written, and the prune is a one-way
    door.

    It is deliberately NOT "every group with a fixture has a row in the values table". A
    group whose fixture carries no unfilled slot never gets one -- `build()` visits a group
    only while a slot is open -- so on the live corpus 23 of the 50 shipped groups have a
    `dependencies.dart` and no table entry, and every one of them is finished. Asserting the
    row would refuse a corpus that is ready.
    """
    from scripts.fixture_values import VALUES_PATH
    from scripts import fixture_gate

    shipped = sorted({r["group"] for r in result["pair_rows"]
                      if r["verdict"] == "eligible" and r["group"]})
    if not VALUES_PATH.is_file():
        raise SystemExit(
            f"--prune-to-endpoints needs the fixture pass to have run first, and "
            f"{VALUES_PATH} does not exist.\n"
            f"  Run `python3 -m scripts.fixture_values --root {root} --eligible-only "
            f"--apply --report`, re-screen, then prune.")
    if not root.is_dir():
        raise SystemExit(f"--prune-to-endpoints: no corpus at {root} to prune.")

    awaiting = set(result.get("unfillable") or ())
    unfilled = {gid: v for gid, v in fixture_gate.check_root(root).items()
                if gid in shipped and gid not in awaiting}
    missing_dir = [g for g in shipped if not (root / g).is_dir()]
    if missing_dir:
        raise SystemExit(
            f"--prune-to-endpoints: {len(missing_dir)} group(s) carrying an eligible "
            f"contrast are not at {root} ({', '.join(missing_dir[:10])}). Export the corpus "
            f"before pruning it.")
    if awaiting:
        print(f"  {len(awaiting)} group(s) await a hand-authored fixture and are exempt from "
              f"this check: {', '.join(sorted(awaiting)[:10])}")
    if unfilled:
        raise SystemExit(
            f"--prune-to-endpoints refused: the fixture pass is not finished at {root}.\n"
            f"  {len(unfilled)} shipped group(s) still carry `// TODO: value`: "
            f"{', '.join(sorted(unfilled)[:10])}\n"
            f"  Pruning first would narrow what `anchor_sha()` and `constructible()` see and "
            f"could move a stored value.\n"
            f"  Run `python3 -m scripts.fixture_values --root {root} --eligible-only --apply "
            f"--report` and `python3 -m scripts.fixture_gate --root {root}`, then prune.")


def write_pruned_stamp(root: Path, result: dict, mode: dict) -> None:
    """Record that `root` now holds only the roles that will be measured.

    Read by `fixture_values` and `maximal_branch`, which refuse to run against a pruned
    corpus; see `fixture_skeleton.PRUNED_NAME` for why. The endpoint map is written out in
    full so the stamp is checkable against the tree without re-deriving it from the pairs.
    """
    roles = {gid: sorted(names) for gid, names in
             sorted((result.get("endpoint_roles") or {}).items())}
    (root / fixture_skeleton.PRUNED_NAME).write_text(json.dumps({
        "pruned_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "roles": len(roles),
        "endpoint_roles": roles,
        # The table the surviving roles' values were resolved against. A stamp that cannot
        # say which values regime it belongs to is the four-generations problem again.
        "values_digest": mode["values"],
        "rules_digest": mode["rules"],
    }, indent=1) + "\n")
    print(f"  pruned to endpoints: stamped {root / fixture_skeleton.PRUNED_NAME}")


# The arm-2 corpus, as the frozen screening protocol states it. Asserted by `--from-nothing` when
# the rebuild targets `new_samples`, and skipped for any other `--dest` -- a mini corpus has
# its own counts and would fail these for the wrong reason.
#
# Literals on purpose. Everything else the gate checks is compared against the tree the
# rebuild started from, but these four are the PUBLISHED claim: a rebuild that quietly agrees
# with a corpus that has drifted is exactly what this is meant to catch.
EXPECTED_CORPUS = {
    "new_samples": {
        "eligible_pairs": None,
        "eligible_mover_scopes": None,
        "eligible_repositories": None,
        "eligible_adjacent_pairs": None,
        "measurable_pairs": None,
        "measurable_mover_scopes": None,
        "awaiting_fixture_groups": None,
        "roles": None,
        "fixtures": None,
    },
}
# UNSET ON PURPOSE, 2026-09-08. A `None` here SKIPS the check for that key and says so in the
# run, which is the honest state: the constructor-field lift and R16 going soft both move the
# corpus, and the in-flight re-harvest is re-minting group ids underneath both. The previous
# literals -- 191 / 45 / 20 / 65 with 156 roles and 45 fixtures -- are NOT what a rebuild
# should now agree with, and leaving them here would turn this gate into a check that fails
# for the right reason and gets edited for the wrong one.
#
# They are filled in from a derived run, once, when the counts are published. Deriving is
# `--no-baseline`; the gate is the run after it. Never edit a literal
# here to match a run that failed -- that inverts what the gate is for.
#
# The corpus has TWO sizes and both belong here. `eligible_*` is what the screen admits;
# `measurable_*` is what could be measured today, the rest waiting on hand-authored fixtures.
# The value table holds primitives only, so the groups whose fill needed an object stand-in
# (0269, 0734, 0879, 1656, 1773, beside 0607) are R16 exclusions.

# What a rebuild is allowed to delete from `--dest` without anyone having authored it. A
# sibling of `export.authored_files`, not a call to it: that one is a closure over one
# export's `--source` and index, and it answers "may --prune remove this group", which is a
# question about one group. This answers "may a REBUILD remove the whole tree", and the two
# must be able to disagree without one silently changing the other.
DERIVED_AT_DEST = frozenset({
    fixture_skeleton.FIXTURE_NAME, fixture_skeleton.INDEX_NAME,
    fixture_skeleton.PROVENANCE_NAME, fixture_skeleton.PRUNED_NAME,
    CACHE_NAME, "exclusions.json", "EXCLUSIONS.md",
})


def measured_under(dest: Path) -> list[Path]:
    """Measurement files belonging to the corpus at `dest`, wherever they actually live.

    This used to be `dest.rglob("performance.jsonl")`, and that could never fire. Measurements
    are not written under the corpus: the runner puts them at `device_runner.config.OUT_DIR`
    -- `dataset/` for arm 1, `dataset-new_samples/` for arm 2 via `BENCH_DATASET_DIR`. So the
    refusal that exists to stop a rebuild destroying the first measured row was reading an
    empty directory, and the comment beside it -- "arm 2 is at zero" -- stopped being true on
    2026-09-07 while the guard went on returning nothing.

    The env var is consulted but NOT relied on: a rebuild is usually run without it set, and a
    guard that only works when the caller remembers to export something is not a guard. The
    naming convention is checked directly instead.
    """
    roots = []
    try:
        from scripts.device_runner import config as runner_config
        roots.append(runner_config.OUT_DIR)
    except Exception:                    # the runner is device-side; never block a rebuild on it
        pass
    # `dest` stays a root. Arm 1 wrote measurements beside the corpus and a scratch run
    # still can, so widening to the dataset trees must ADD places to look, never move them.
    roots += [dest, dest.parent / "dataset", dest.parent / f"dataset-{dest.name}"]

    groups = {d.name for d in dest.iterdir() if d.is_dir()} if dest.is_dir() else set()
    found: list[Path] = []
    for root in dict.fromkeys(r.resolve() for r in roots if r.is_dir()):
        for gid in sorted(groups):
            if (root / gid).is_dir():
                found += sorted((root / gid).rglob("performance.jsonl"))
    return found


def capture_sessions(dest: Path) -> dict[str, list[str]]:
    """Group -> raw capture sessions, for groups under `dest`. Warned about, never refused.

    A session that was interrupted leaves `raw/<session>/<role>/e<k>.jsonl` and no
    `performance.jsonl`, so `measured_under` -- which asks whether a COMPLETED measurement
    exists -- rightly says no. Those rows are still rows taken against the fixture that is
    about to be replaced, and on 2026-09-07 exactly that happened to 0082 with nothing said.
    Refusing over them would be wrong: a dry run leaves the same shape. Saying so is not.
    """
    roots = []
    try:
        from scripts.device_runner import config as runner_config
        roots.append(runner_config.OUT_DIR)
    except Exception:
        pass
    roots += [dest.parent / "dataset", dest.parent / f"dataset-{dest.name}"]

    groups = {d.name for d in dest.iterdir() if d.is_dir()} if dest.is_dir() else set()
    out: dict[str, list[str]] = {}
    for root in dict.fromkeys(r.resolve() for r in roots if r.is_dir()):
        for gid in sorted(groups):
            for raw in sorted((root / gid).glob("*/raw")):
                sessions = sorted(d.name for d in raw.iterdir()
                                  if d.is_dir() and any(d.rglob("*.jsonl")))
                if sessions:
                    out.setdefault(gid, []).extend(sessions)
    return out


def warn_captures(dest: Path) -> None:
    """Print what a rebuild is about to orphan. Called before every teardown."""
    sessions = capture_sessions(dest)
    if not sessions:
        return
    n = sum(len(v) for v in sessions.values())
    listed = ", ".join(f"{g} ({len(v)})" for g, v in sorted(sessions.items())[:10])
    print(f"  WARNING: {n} raw capture session(s) exist for {len(sessions)} group(s) under "
          f"{dest.name} -- {listed}.")
    print(f"           They were captured against the fixtures this rebuild replaces. No "
          f"performance.jsonl was written, so nothing is refused; the rows are simply not "
          f"comparable to the rebuilt corpus.")


def authored_under(source: Path, dest: Path, overridden: set[str]) -> dict[str, list[str]]:
    """Files at `--dest` that `--source` cannot regenerate, per group.

    A file whose name `--source` also has is a copy. A generated fixture, index, provenance
    stamp or record is derived by name. What is left is somebody's work, and a rebuild that
    deleted it would be destroying the one thing in the tree that is not a pure function of
    the mine.

    `overridden` is the set of groups `maximal_branch` has written a fixture for. Their
    `dependencies.dart` no longer hashes to its index entry, so `is_generated` correctly
    calls it authored -- but the pipeline authored it, and `--apply` will write it again from
    the table. Today that is `1637` and `1777`.

    A group in `authored_fixtures` is exempt for the mirror-image reason. Its fixture is
    genuinely hand-written and genuinely not derivable from `--source` -- but the store lives
    in `config/`, outside the tree this deletes, and `restore_all` writes it back. Refusing
    here instead would be the strictly wrong call: it would make `--from-nothing` unrunnable
    for the whole corpus the moment one group is edited, and the acceptance gate is the thing
    that has to keep working.
    """
    out: dict[str, list[str]] = {}
    if not dest.is_dir():
        return out
    index = fixture_skeleton.load_index(dest)
    for d in sorted(x for x in dest.iterdir() if x.is_dir()):
        gid = d.name
        have = {f.name for f in (source / gid).iterdir() if f.is_file()} \
            if (source / gid).is_dir() else set()
        have |= DERIVED_AT_DEST if fixture_skeleton.is_generated(dest, gid, index) \
            else DERIVED_AT_DEST - {fixture_skeleton.FIXTURE_NAME}
        if gid in overridden or authored_fixtures.owns(dest, gid):
            have |= {fixture_skeleton.FIXTURE_NAME}
        left = sorted(f.name for f in d.iterdir() if f.is_file() and f.name not in have)
        if left:
            out[gid] = left
    return out


def teardown(source: Path, dest: Path, *, baseline: bool) -> dict:
    """Remove every derived thing `--full --from-nothing` is about to rebuild.

    This is the step that makes the committed POLICY tables the only inputs: without it a
    rebuild needs three `rm`s nobody scripted, and an un-scripted step is the hand-trim the
    reproducibility claim exists to exclude.

    `config/license_policy.json` and `config/license_provenance.jsonl` are inputs, not derived
    state, and are deliberately absent from the teardown. The first is authored. The second is
    generated -- but by `mining license-provenance`, which needs a checkout, a pub cache and
    hours of re-isolation, and whose value is the byte-identity check each row records. A
    screen cannot regenerate it, so tearing it down would not make the rebuild more
    self-contained; it would make R17 fire `unattributed` on every file and silently cost the
    corpus a scope.

    NOTHING here weakens a refusal. `init_values_table` still declines to overwrite a table
    and `refuse_if_pruned` still hard-exits both table tools -- they are simply consulted
    after the state they refuse is gone, so every other caller still meets them intact.

    Returns the baseline snapshot the gate compares the rebuilt tables against.
    """
    from scripts import fixture_values, maximal_branch

    tables = [fixture_values.VALUES_PATH, maximal_branch.TABLE_PATH]
    snapshot: dict[str, str | None] = {}
    missing = [t for t in tables if not t.is_file()]
    if missing and baseline:
        raise SystemExit(
            f"--from-nothing has nothing to check the rebuild against: "
            f"{', '.join(t.name for t in missing)} missing. The gate compares the "
            f"REGENERATED tables against the committed ones, and a rebuild that asserts "
            f"nothing is the hand-trim it exists to replace.\n"
            f"  Restore them with `git checkout -- config/`, or pass --no-baseline to "
            f"rebuild without the comparison and say so in the record.")
    for t in tables:
        snapshot[t.name] = t.read_text(encoding="utf-8") if t.is_file() else None

    # Never over a measurement. Arm 2 stopped being at zero on 2026-09-07, so this is now a
    # live refusal rather than a standing assumption -- see `measured_under` for why the old
    # form could not fire.
    measured = measured_under(dest)
    if measured:
        raise SystemExit(
            f"--from-nothing refused: {len(measured)} measurement file(s) for groups under "
            f"{dest} ({measured[0]} ...). A rebuild deletes the corpus, and a rebuilt fixture "
            f"is not the one those rows were measured against; measured rows are not "
            f"rebuildable from the mine.")

    overridden = set()
    if snapshot.get(maximal_branch.TABLE_PATH.name):
        overridden = {gid for gid, rows in
                      json.loads(snapshot[maximal_branch.TABLE_PATH.name]).items()
                      if any(r.get("overridden") for r in rows)}
    authored = authored_under(source, dest, overridden)
    if authored:
        listed = "; ".join(f"{g}: {', '.join(f)}" for g, f in sorted(authored.items())[:10])
        raise SystemExit(
            f"--from-nothing refused: {sum(len(f) for f in authored.values())} file(s) at "
            f"{dest} are not regenerable from {source} -- {listed}\n"
            f"  A rebuild deletes the tree. Move this work into --source, where the export "
            f"treats it as sacred, or delete it deliberately by hand.")

    warn_captures(dest)

    import shutil
    if dest.is_dir():
        shutil.rmtree(dest)
        print(f"  removed corpus            : {dest}")
    for t in tables:
        if t.is_file():
            t.unlink()
            print(f"  removed table             : {rel(t)}")
    # The store is an INPUT under `config/` and the rmtree above did not touch it. It is
    # deliberately NOT replayed here: `place()` restores per group as the export reaches it,
    # which is the only point where the group's identity can be checked. Replaying the whole
    # store into an empty tree would recreate directories for groups this rebuild never
    # shipped -- and, once ids are re-minted, under names that now mean something else.
    owned = authored_fixtures.groups()
    if owned:
        print(f"  authored fixtures kept    : {len(owned)} group(s) "
              f"({', '.join(owned[:10])}) in {rel(authored_fixtures.STORE)}")
    # `probe_v2/fixtures/` and `checkpoints_screen/` are deliberately KEPT. The vector cache
    # is keyed on sha256(role text || fixture digest) and cannot serve a stale answer, and
    # phase 1 already screens with `rescreen=True` under --init, so every checkpoint is
    # ignored anyway. Deleting either buys nothing and costs a full re-analysis.
    return snapshot


def _diff(name: str, want: str, got: str) -> str:
    import difflib
    return "".join(difflib.unified_diff(want.splitlines(True), got.splitlines(True),
                                        f"{name} (committed)", f"{name} (rebuilt)"))


def verify(snapshot: dict, dest: Path, records_dir: Path) -> None:
    """The gate. Every check reads the artifacts on disk, not this run's memory.

    Assertion 1 is the one that matters: it turns "the corpus is a pure function of
    `config/fixture_policy.json` plus the mine" from an observation recorded once into
    something checked every time.
    """
    from scripts import fixture_gate, fixture_values, maximal_branch

    problems: list[str] = []

    def check(ok: bool, msg: str) -> None:
        print(f"  {'PASS' if ok else 'FAIL'}  {msg}")
        if not ok:
            problems.append(msg)

    print(f"\n{'=' * 78}\n== gate  the rebuild against what was committed\n{'=' * 78}")

    # 1-3: the tables came back the same.
    want = snapshot.get(fixture_values.VALUES_PATH.name)
    if want is None:
        print("  SKIP  no baseline values table (--no-baseline)")
    else:
        got = fixture_values.VALUES_PATH.read_text(encoding="utf-8")
        check(got == want, f"{fixture_values.VALUES_PATH.name} is byte-identical")
        if got != want:
            print(_diff(fixture_values.VALUES_PATH.name, want, got)[:4000])

    live = fixture_values.values_version()
    record = jsonio.require_json(records_dir / "exclusions.json", "--from-nothing verify")
    check(record["provenance"]["values_digest"] == live,
          f"exclusions.json was screened against the filled table ({live})")

    want_mb = snapshot.get(maximal_branch.TABLE_PATH.name)
    if want_mb is None:
        print("  SKIP  no baseline override table (--no-baseline)")
    else:
        got_mb = maximal_branch.TABLE_PATH.read_text(encoding="utf-8")
        want_d = maximal_branch.table_digest(json.loads(want_mb))
        got_d = maximal_branch.table_digest(json.loads(got_mb))
        # By digest, not by bytes: `applied` is the date an override was first written and a
        # rebuild necessarily restamps it with its own. Every other field is derived.
        check(got_d == want_d,
              f"{maximal_branch.TABLE_PATH.name} matches on derived content "
              f"({want_d}, `applied` excluded)")
        if got_d != want_d:
            print(_diff(maximal_branch.TABLE_PATH.name, want_mb, got_mb)[:4000])

    # 4-5: the published counts.
    expect = EXPECTED_CORPUS.get(dest.name)
    if expect is None:
        print(f"  SKIP  no published counts registered for --dest {dest.name}")
    else:
        totals = record["totals"]

        def published(key: str, got, what: str) -> None:
            """Check `got` against the published literal, or say the literal is unset.

            An unset key is not a pass. It is printed as SKIP so a run cannot be read as
            having agreed with a published count that does not exist yet."""
            want = expect.get(key)
            if want is None:
                print(f"  SKIP  {what}: no published count yet (got {got})")
                return
            check(got == want, f"{what} == {want} (got {got})")

        for key in ("eligible_pairs", "eligible_mover_scopes", "eligible_repositories",
                    "eligible_adjacent_pairs", "measurable_pairs",
                    "measurable_mover_scopes", "awaiting_fixture_groups"):
            published(key, totals.get(key), key)
        roles = len(list(dest.rglob("rev_*.dart")))
        fixtures = len(list(dest.rglob(fixture_skeleton.FIXTURE_NAME)))
        published("roles", roles, "roles on disk")
        published("fixtures", fixtures, "fixtures on disk")
        stamp = fixture_skeleton.pruned_stamp(dest) or {}
        published("fixtures", stamp.get("roles"), "groups named by the prune stamp")
        named = sum(len(v) for v in (stamp.get("endpoint_roles") or {}).values())
        published("roles", named, "roles named by the prune stamp")

    # 6: every R16 refusal is one the policy NAMES. Unchanged by R16 going soft on
    # 2026-09-08, and more important because of it: a type the policy never mentions used to
    # cost a group and now costs someone an afternoon writing a fixture around an omission
    # that should have been fixed in `config/fixture_policy.json` instead. This is still the
    # check that catches a typo deleting a type from the table.
    unfillable = record.get("unfillable") or {}
    undeclared = sorted(g for g, i in unfillable.items() if not i.get("declared"))
    check(not undeclared,
          f"every R16 refusal is a type the policy DECLARES unrecoverable or out of scope "
          f"(undeclared: {', '.join(undeclared) or 'none'})")

    # 7: nothing unfilled shipped, and nothing measured was destroyed.
    #
    # "Unfilled" means the GENERATED fill left a slot open in a group it was supposed to
    # finish. A group R16 flagged is not one of those: its slots are open by design and stay
    # open until a fixture is authored, which is a human step a rebuild cannot perform and
    # must not wait on. Scoped rather than dropped -- for every other group an open slot is
    # still a rebuild that did not reproduce the corpus.
    awaiting = set(unfillable)
    unfilled = {g: v for g, v in fixture_gate.check_root(dest).items() if g not in awaiting}
    check(not unfilled,
          f"fixture gate clean on every shipped group the generated fill owns "
          f"(refused: {', '.join(sorted(unfilled)) or 'none'}; "
          f"{len(awaiting)} awaiting a hand-authored fixture)")
    check(not list(dest.rglob("performance.jsonl")), "no measurement rows under the corpus")

    if problems:
        raise SystemExit(
            f"\n--from-nothing gate FAILED on {len(problems)} check(s):\n  - "
            + "\n  - ".join(problems)
            + f"\n\nThe rebuilt corpus is not the committed one. Do not measure against it. "
              f"`git checkout -- config/ {dest.name}` restores what was there.")
    print(f"\n  the rebuild reproduces the committed corpus from "
          f"config/fixture_policy.json.\n")
