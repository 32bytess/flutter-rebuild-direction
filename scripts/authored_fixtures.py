"""The store that makes a hand-edited `dependencies.dart` survive a rebuild.

`fixture_skeleton.place()` already refuses to overwrite a fixture whose sha256 has left
`.fixture_index.json`, and `fixture_values --apply` and `maximal_branch --apply` both honour the
same `hands_off` set. That protection is real and it is AMNESIAC: it is inferred by hashing a
file, so it lasts exactly as long as the file does. `screen/export.py` removes a stale group
directory whenever `--prune` is set -- which `--from-nothing` force-sets -- and a group that
falls out of the eligible set in one batch and is re-exported in the next comes back as freshly
generated stubs, carrying a fresh index entry that reads as the pipeline's own work. Between
2026-09-07 02:08 and 04:58 group 0082 lost the same fill three times that way, while 0331 held
because nothing had pruned it yet.

This module answers the same question -- may the generator write here -- from a place a prune
cannot reach:

    config/authored_fixtures/<gid>/dependencies.dart

`config/` is where hand-written inputs live, and `screen/rebuild.teardown` already keeps
`fixture_policy.json` and `license_policy.json` out of the tables it destroys for the same
reason. The store joins them.

ADOPTION IS AUTOMATIC, and that is the point: the first tool to notice that a fixture no longer
hashes to its index entry snapshots it here, so the fact of authorship is recorded at the one
moment it is still knowable. Nothing has to be remembered or run by hand. `--adopt` exists for
the groups that were already clobbered before this module did, and `--release` is the only way
back to a generated fixture.

    python3 -m scripts.authored_fixtures --list
    python3 -m scripts.authored_fixtures --adopt 0082 0254
    python3 -m scripts.authored_fixtures --release 0314

WHAT THIS COSTS, said plainly: a group in the store is no longer a pure function of the mine
plus the committed policy tables. `--from-nothing` byte-identity holds only modulo the store,
and `--list` is what a write-up quotes to say over how many groups.
"""

from __future__ import annotations

import argparse
import json
import shutil
from datetime import datetime, timezone
from pathlib import Path

from . import jsonio
from .paths import PROJECT_ROOT as ROOT, rel

REVISION = __import__("re").compile(r"^rev_\d+_[0-9a-f]+\.dart$")

STORE = ROOT / "config" / "authored_fixtures"
INDEX = STORE / "index.json"
FIXTURE_NAME = "dependencies.dart"


def _index() -> dict:
    """The store's own index, or an empty one. A missing store is not an error.

    Unlike `fixture_values.load()`, an absent file here means "nobody has edited a fixture
    yet", which is the ordinary state of a fresh clone -- not the silent re-derivation that
    module refuses over.
    """
    doc = jsonio.read_json(INDEX, {}) or {}
    return doc.get("groups", {}) if isinstance(doc, dict) else {}


def _write_index(groups: dict) -> None:
    STORE.mkdir(parents=True, exist_ok=True)
    INDEX.write_text(json.dumps({
        "version": 1,
        "_comment": (
            "Groups whose dependencies.dart is authored (drafted with a language model and reviewed; see config/README.md) and must never be regenerated. "
            "Written by scripts/authored_fixtures.py; the Dart itself lives beside this file. "
            "Adding a group here removes it from the set the corpus derives from the mine."),
        "groups": groups,
        "_groups_provenance": (
            "Each entry is stamped when a tool first saw the fixture disagree with "
            "new_samples/.fixture_index.json, or by --adopt. `sha256` is over the stored text."),
    }, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def stored_path(gid: str) -> Path:
    return STORE / gid / FIXTURE_NAME


def roles(dest: Path, gid: str) -> list[str]:
    """The group's role filenames on disk. The identity check a restore turns on.

    `rev_<ordinal>_<sha8>.dart` is content-addressed, so this set names the SCOPE, not just
    the group id. That distinction is doing real work right now: the 2026-09-06 re-harvest
    re-mints group ids from nothing, so a stored `0082` can come back naming a different
    scope entirely, and writing an old hand-written fixture onto it would be silent and
    wrong in a way no later check would catch.
    """
    d = dest / gid
    if not d.is_dir():
        return []
    return sorted(f.name for f in d.iterdir() if f.is_file() and REVISION.match(f.name))


def is_authored(gid: str) -> bool:
    """True when the store owns this group's fixture. The sticky predicate.

    Deliberately reads the file rather than trusting the index alone: an index entry whose
    Dart has gone is a half-store, and the caller must not be told the fixture is safe when
    there is nothing left to restore from.
    """
    return gid in _index() and stored_path(gid).is_file()


def groups() -> list[str]:
    return sorted(g for g in _index() if stored_path(g).is_file())


def adopt(dest: Path, gid: str, *, reason: str = "digest left the index") -> bool:
    """Snapshot `dest/<gid>/dependencies.dart` into the store. True when it was taken.

    Idempotent by content: re-adopting an unchanged fixture rewrites nothing and does not move
    the `adopted` date, so a run over a settled corpus produces no diff.
    """
    src = dest / gid / FIXTURE_NAME
    if not src.is_file():
        return False
    text = src.read_text(encoding="utf-8", errors="replace")
    from . import fixture_skeleton
    digest = fixture_skeleton.digest(text)

    index = _index()
    entry = index.get(gid, {})
    if entry.get("sha256") == digest and stored_path(gid).is_file():
        # Settled -- unless the entry predates the `roles` list, in which case the identity
        # check is silently inert on it. `scope_changed()` reads an empty stored list as
        # "cannot tell" and returns False, so a stored fixture with no roles would be
        # restored onto whatever group now carries its id. The five hand-adopted entries of
        # 2026-09-07 are exactly in that state, and the re-harvest is re-minting ids under
        # them, so this backfills rather than waiting for someone to notice.
        on_disk = roles(dest, gid)
        if entry.get("roles") or not on_disk:
            return False
        index[gid] = {**entry, "roles": on_disk}
        _write_index(index)
        return False

    stored_path(gid).parent.mkdir(parents=True, exist_ok=True)
    stored_path(gid).write_text(text, encoding="utf-8")
    index[gid] = {
        "sha256": digest,
        "adopted": index.get(gid, {}).get(
            "adopted", datetime.now(timezone.utc).date().isoformat()),
        "reason": reason,
        "roles": roles(dest, gid),
    }
    _write_index(index)
    return True


def scope_changed(dest: Path, gid: str) -> bool:
    """True when `dest/<gid>` is no longer the scope the stored fixture was written for.

    An empty role set on either side means "cannot tell" and is NOT a change: the store may
    predate role recording, and the export copies roles before it places the fixture, so an
    empty on-disk set means this is being asked too early rather than that the scope moved.
    """
    stored = _index().get(gid, {}).get("roles") or []
    found = roles(dest, gid)
    return bool(stored and found and stored != found)


_warned: set[str] = set()


def owns(dest: Path, gid: str) -> bool:
    """The single question every writer asks: is this fixture the store's to protect?

    `is_authored` alone is not enough. A stored entry whose scope has moved is stale for this
    id, and treating it as owned would leave the group with no fixture at all -- the store
    refusing to restore and the generator refusing to write.
    """
    return is_authored(gid) and not scope_changed(dest, gid)


def warn_scope(dest: Path, gid: str) -> None:
    """Say once, per group, that a stored fixture was skipped because the scope moved."""
    if gid in _warned:
        return
    _warned.add(gid)
    stored = _index().get(gid, {}).get("roles") or []
    print(f"  authored fixture NOT restored: [{gid}] holds different roles than when it was "
          f"adopted (stored {len(stored)}, found {len(roles(dest, gid))}). The id may have "
          f"been re-minted onto another scope, so the group is being GENERATED instead. "
          f"Re-adopt it deliberately, or `--release {gid}`.")


def differs(dest: Path, gid: str) -> bool:
    """Would `restore` actually write? Read-only, and the same comparison it makes.

    A caller that has to know BEFORE the write -- `screen.freeze`, which refuses a fixture
    change under a measured group -- cannot learn it from `restore`'s return value, because
    by then the file is already on disk.
    """
    if not is_authored(gid) or scope_changed(dest, gid):
        return False
    target = dest / gid / FIXTURE_NAME
    if not target.is_file():
        return True
    return target.read_text(encoding="utf-8", errors="replace") != \
        stored_path(gid).read_text(encoding="utf-8", errors="replace")


def restore(dest: Path, gid: str) -> bool:
    """Put the stored fixture back at `dest/<gid>/dependencies.dart`. True when it was written.

    This is what closes the hole. A prune removed the directory; the re-export is about to
    generate stubs into it; this runs first and the generated text is never written.

    REFUSES on a changed scope, loudly. Restoring there would put a hand-written fill onto
    code it was never read against -- the one failure this store could introduce that the
    thing it replaces could not.
    """
    if not is_authored(gid):
        return False
    if scope_changed(dest, gid):
        warn_scope(dest, gid)
        return False
    target = dest / gid / FIXTURE_NAME
    text = stored_path(gid).read_text(encoding="utf-8", errors="replace")
    if target.is_file() and target.read_text(encoding="utf-8", errors="replace") == text:
        return False
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(text, encoding="utf-8")
    return True


def release(gid: str) -> bool:
    """Hand a group back to the generator. The only way out of the store."""
    index = _index()
    if gid not in index and not stored_path(gid).exists():
        return False
    index.pop(gid, None)
    shutil.rmtree(STORE / gid, ignore_errors=True)
    _write_index(index)
    return True


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--root", type=Path, default=ROOT / "new_samples",
                    help="the corpus to adopt from (default: new_samples/)")
    g = ap.add_mutually_exclusive_group(required=True)
    g.add_argument("--list", action="store_true", help="groups the store owns")
    g.add_argument("--adopt", nargs="+", metavar="GID",
                   help="take these groups' fixtures into the store")
    g.add_argument("--release", nargs="+", metavar="GID",
                   help="hand these back to the generator")
    g.add_argument("--awaiting", action="store_true",
                   help="groups the screen says need a hand-authored fixture, from "
                        "<root>/exclusions.json")
    g.add_argument("--seed", nargs="+", metavar="GID",
                   help="copy these groups' GENERATED fixtures into the store as a starting "
                        "point to hand-author, before any edit is made")
    args = ap.parse_args()

    index = _index()
    if args.list:
        owned = groups()
        print(f"store: {rel(STORE)}")
        print(f"authored fixtures: {len(owned)}")
        for gid in owned:
            e = index[gid]
            print(f"  [{gid}] adopted {e.get('adopted', '?')}  {e.get('reason', '')}")
        orphans = sorted(set(index) - set(owned))
        if orphans:
            print(f"  INDEXED BUT MISSING DART: {', '.join(orphans)} -- the store is half "
                  f"there; re-adopt or --release them")
        return

    if args.awaiting:
        # One interface for the store and for the work it exists to hold. The list comes
        # from the screen's own record, so it cannot drift from what the gate refuses.
        record = args.root / "exclusions.json"
        if not record.is_file():
            print(f"no screen record at {rel(record)} -- run screen_samples first")
            return
        awaiting = json.loads(record.read_text(encoding="utf-8")).get("unfillable") or {}
        owned = set(groups())
        todo = {g: i for g, i in sorted(awaiting.items()) if g not in owned}
        print(f"awaiting a hand-authored fixture: {len(todo)} "
              f"({len(awaiting) - len(todo)} already in the store)")
        for gid, info in todo.items():
            flag = "" if info.get("declared") else "  UNDECLARED -- fix the policy instead"
            print(f"  [{gid}] {', '.join(info.get('bindings') or ())} -- "
                  f"{info.get('reason', '')}{flag}")
        if todo:
            print(f"\n  python3 -m scripts.authored_fixtures --seed "
                  f"{' '.join(sorted(todo))}")
        return

    if args.adopt:
        for gid in args.adopt:
            took = adopt(args.root, gid, reason="adopted by hand")
            src = args.root / gid / FIXTURE_NAME
            if not src.is_file():
                print(f"  [{gid}] no fixture at {rel(src)} -- nothing to adopt")
            else:
                print(f"  [{gid}] {'stored' if took else 'already stored, unchanged'}")
    if args.seed:
        # `--adopt` is for a fixture already edited under the corpus, which is the state that
        # cost `0082` three fills on 2026-09-07 -- the edit was only safe once someone
        # noticed. `--seed` is the other order: take the generated skeleton into the store
        # FIRST, then edit it there, where `screen/export.py --prune` cannot reach it.
        for gid in args.seed:
            src = args.root / gid / FIXTURE_NAME
            if not src.is_file():
                print(f"  [{gid}] no fixture at {rel(src)} -- screen and export it first")
                continue
            if is_authored(gid):
                print(f"  [{gid}] already in the store; edit {rel(stored_path(gid))}")
                continue
            adopt(args.root, gid, reason="seeded for hand authoring")
            print(f"  [{gid}] seeded -> {rel(stored_path(gid))}")
            print(f"           edit THAT file, not the one under {rel(args.root)}")
    if args.release:
        for gid in args.release:
            print(f"  [{gid}] {'released' if release(gid) else 'was not in the store'}")


if __name__ == "__main__":
    main()
