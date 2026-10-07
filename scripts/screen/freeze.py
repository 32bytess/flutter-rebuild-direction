"""The pin that keeps an already-measured group byte-identical across a re-screen.

A measured row is a claim about a specific tree: `dataset-new_samples/<gid>/<device>/
performance.jsonl` says how long THOSE bytes took to rebuild, and `static.jsonl` says what
features THOSE bytes have. Change either file afterwards and the row survives, silently
describing code that is no longer there. Nothing stopped that. `export.copy_file` compares
content and re-exports nothing, so in practice a re-screen was already a no-op -- but that
is an observed property of the current flags, not an enforced one, and the three things that
would break it are all ordinary: editing `config/fixture_policy.json` moves `values_version()`
and every generated fixture with it; `--prune` removes a group that left the eligible set for
one batch; a normalisation change rewrites every role.

This module turns the observation into a refusal. It is the measurement-side twin of
`scripts/authored_fixtures.py`: same store-in-`config/` reasoning -- `screen/export.py` and
`screen/rebuild.teardown` can both reach `--dest`, and neither can reach here.

    python3 -m scripts.screen.freeze --seed          # pin every group that has been measured
    python3 -m scripts.screen.freeze --verify        # report drift, change nothing
    python3 -m scripts.screen.freeze --list
    python3 -m scripts.screen.freeze --release 0508 --reason "renders RenderErrorBox"

WHAT IT IS NOT. It is not a claim that a frozen group is correct, and `--release` is not an
admission that it was wrong. A group is released whenever its fixture must change -- to
repair a grey screen, to fill a slot the policy declined -- and releasing it is exactly the
statement "the rows under this group no longer describe what is on disk, re-measure it". The
release is dated and carries a reason so that statement is in the record rather than in
somebody's memory.

WHAT IT PINS. Every file of the group at `--dest`: the roles and the fixture. Not the
manifests, which are filtered per run and carry no per-group measurement claim.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
from datetime import datetime, timezone
from pathlib import Path

from scripts import jsonio
from scripts.paths import PROJECT_ROOT as ROOT, rel

# Overridable for the same reason `fixture_values.VALUES_PATH` is: the gate has to be
# exercisable against a throwaway corpus without the test's pins reaching the real store --
# and the screen runs in a SUBPROCESS, so monkeypatching the module global is not enough.
# A relative value resolves against ROOT, so the variable reads the same from any cwd.
_override = os.environ.get("SPM_MEASURED_FREEZE")
STORE = (Path(_override) if _override and Path(_override).is_absolute()
         else ROOT / _override if _override
         else ROOT / "config" / "measured_freeze.json")


class FrozenGroupError(RuntimeError):
    """A write or delete that would change a measured group's bytes."""


def _doc() -> dict:
    """The store, or an empty one. A missing file is not an error.

    Same reasoning as `authored_fixtures._index`: an absent store means "nothing measured
    yet", which is the ordinary state of a fresh clone, not the silent re-derivation
    `fixture_values.load()` refuses over.
    """
    doc = jsonio.read_json(STORE, {}) or {}
    return doc if isinstance(doc, dict) else {}


def load() -> dict:
    """gid -> entry, for the groups the pin is LIVE on. Released entries are left out.

    A released entry stays in the file -- it is the record of what was let go and why -- but
    it must not gate anything, or a repair would have to delete its own audit trail to
    proceed.
    """
    groups = _doc().get("groups", {})
    if not isinstance(groups, dict):
        return {}
    return {gid: e for gid, e in groups.items() if not e.get("released")}


def _write(groups: dict) -> None:
    STORE.parent.mkdir(parents=True, exist_ok=True)
    STORE.write_text(json.dumps({
        "version": 1,
        "_comment": (
            "Groups with device measurements on disk. Their files at the corpus root are "
            "pinned: `scripts/screen/export.py` refuses any write or delete that would "
            "change one. Written by scripts/screen/freeze.py. An entry with `released` set "
            "is history -- the pin is off and the group's existing rows describe code that "
            "has since changed."),
        "groups": groups,
        "_groups_provenance": (
            "`files` is sha256 per filename at the moment of seeding. `devices` and "
            "`exclusions_sha256` say what the rows were taken under; `exclusions_sha256` is "
            "the digest the measurement manifest recorded, so a row can be tied back to the "
            "screening record that selected it."),
    }, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def digests(group_dir: Path) -> dict[str, str]:
    """sha256 per file of one group directory, names only -- never paths.

    Names, because the store is compared against a corpus root the caller chooses and an
    absolute path would pin the checkout as well as the bytes.
    """
    if not group_dir.is_dir():
        return {}
    return {f.name: hashlib.sha256(f.read_bytes()).hexdigest()
            for f in sorted(group_dir.iterdir()) if f.is_file()}


def measured_groups(dest: Path) -> dict[str, list[str]]:
    """gid -> devices, for every group under `dest` that has a `performance.jsonl`.

    Built on `rebuild.measured_under`, which already knows the four roots a measurement can
    land in and why the obvious `dest.rglob` could never fire. The device is the parent
    directory of the file, per `device_runner/config.py`'s `<group>/<device>/` layout.
    """
    from scripts.screen import rebuild

    out: dict[str, list[str]] = {}
    for path in rebuild.measured_under(dest):
        device = path.parent.name
        gid = path.parent.parent.name
        out.setdefault(gid, [])
        if device not in out[gid]:
            out[gid].append(device)
    return {gid: sorted(devs) for gid, devs in sorted(out.items())}


def _exclusions_digest(dest: Path) -> str | None:
    record = dest / "exclusions.json"
    if not record.is_file():
        return None
    return hashlib.sha256(record.read_bytes()).hexdigest()


def seed(dest: Path, *, dry_run: bool = False) -> dict:
    """Pin every measured group that is not pinned yet. Never re-pins an existing entry.

    Not re-pinning matters: a group whose files have already drifted from what was measured
    must be REPORTED by `verify`, and re-seeding it would launder that drift into the store
    as though the current bytes were the measured ones.
    """
    groups = _doc().get("groups", {})
    if not isinstance(groups, dict):
        groups = {}
    today = datetime.now(timezone.utc).date().isoformat()
    digest = _exclusions_digest(dest)
    added = {}
    for gid, devices in measured_groups(dest).items():
        if gid in groups and not groups[gid].get("released"):
            continue
        files = digests(dest / gid)
        if not files:
            continue                    # measured, but no longer at this corpus root
        added[gid] = {"frozen": today, "devices": devices, "files": files,
                      "exclusions_sha256": digest, "released": None}
    if added and not dry_run:
        groups.update(added)
        _write(groups)
    return added


def verify(dest: Path) -> dict[str, dict[str, str]]:
    """gid -> {filename: what happened}, for every live entry whose bytes have moved.

    Reports three kinds by name -- `changed`, `missing`, `added` -- rather than a bare
    boolean, because they mean different things: a changed role is a measurement that now
    describes other code, a missing one is a prune that got through, and an added one is
    usually a role the mine grew later and is not by itself a defect.
    """
    out: dict[str, dict[str, str]] = {}
    for gid, entry in load().items():
        want = entry.get("files", {})
        have = digests(dest / gid)
        drift = {}
        for name, sha in want.items():
            if name not in have:
                drift[name] = "missing"
            elif have[name] != sha:
                drift[name] = "changed"
        for name in have:
            if name not in want:
                drift[name] = "added"
        if drift:
            out[gid] = dict(sorted(drift.items()))
    return out


def release(gid: str, reason: str) -> dict:
    """Lift the pin on one group, with the reason on the record. The only way past the gate."""
    groups = _doc().get("groups", {})
    if gid not in groups:
        raise SystemExit(f"{gid} is not in {rel(STORE)}; nothing to release.")
    if groups[gid].get("released"):
        raise SystemExit(f"{gid} was already released on {groups[gid]['released']['at']}.")
    groups[gid]["released"] = {
        "at": datetime.now(timezone.utc).date().isoformat(), "reason": reason}
    _write(groups)
    return groups[gid]


# ---- the gate -------------------------------------------------------------------------
#
# Called from `screen/export.py` at the four places that can change a group's bytes: the
# role/manifest copy loop, the fixture placement, the endpoint prune and the stale rmtree.
# The test is "would this ACT", not "is this group frozen" -- `copy_file` already answers the
# first, and a re-export that writes identical bytes must stay a no-op or the gate would
# refuse every ordinary re-screen.

def refuse(gid: str, what: str, frozen: dict | None = None) -> None:
    """Raise if `gid` is pinned. `what` names the file or the action, for the message."""
    entry = (load() if frozen is None else frozen).get(gid)
    if not entry:
        return
    raise FrozenGroupError(
        f"group {gid} is frozen: it has device measurements on "
        f"{', '.join(entry.get('devices') or ['an unrecorded device'])} taken against the "
        f"files pinned in {rel(STORE)}, and this run would change {what}. Changing it makes "
        f"every row under that group describe code that is no longer on disk. If that is "
        f"what you mean to do, say so:\n"
        f"    python3 -m scripts.screen.freeze --release {gid} --reason '...'\n"
        f"and re-measure the group afterwards.")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Pin the corpus files of groups that have been measured.")
    parser.add_argument("--dest", default="new_samples", help="Corpus root (default: new_samples).")
    parser.add_argument("--seed", action="store_true", help="Pin every measured group not yet pinned.")
    parser.add_argument("--verify", action="store_true", help="Report drift; change nothing.")
    parser.add_argument("--list", action="store_true", help="What is pinned, and what was released.")
    parser.add_argument("--release", metavar="GID", help="Lift the pin on one group.")
    parser.add_argument("--reason", help="Why, required with --release.")
    parser.add_argument("--dry-run", action="store_true", help="With --seed: report, write nothing.")
    args = parser.parse_args()

    dest = Path(args.dest)
    if not dest.is_absolute():
        dest = ROOT / dest

    if args.release:
        if not args.reason:
            raise SystemExit("--release needs --reason: the record is the point of the store.")
        entry = release(args.release, args.reason)
        print(f"released {args.release} on {entry['released']['at']}: {args.reason}")
        print("Its existing rows now describe code that may change. Re-measure the group.")
        return

    if args.seed:
        added = seed(dest, dry_run=args.dry_run)
        verb = "would pin" if args.dry_run else "pinned"
        print(f"{verb} {len(added)} group(s): {', '.join(sorted(added)) or '-'}")

    if args.verify or not (args.seed or args.list):
        drift = verify(dest)
        for gid in sorted(drift):
            print(f"[{gid}]")
            for name, kind in drift[gid].items():
                print(f"    {kind:8} {name}")
        print(f"{len(drift)} frozen group(s) have drifted from what was measured."
              if drift else
              f"{len(load())} frozen group(s); every pinned file is byte-identical.")
        if drift:
            raise SystemExit(1)

    if args.list:
        groups = _doc().get("groups", {})
        for gid in sorted(groups):
            e = groups[gid]
            state = f"RELEASED {e['released']['at']} -- {e['released']['reason']}" \
                if e.get("released") else f"frozen {e.get('frozen')}"
            print(f"{gid}  {len(e.get('files', {})):3} file(s)  "
                  f"{','.join(e.get('devices') or []) or '-':10} {state}")


if __name__ == "__main__":
    main()
