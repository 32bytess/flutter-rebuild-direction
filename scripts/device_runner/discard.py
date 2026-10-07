"""Retire a group's measurements so a repaired fixture can actually be re-measured.

WHY THIS IS A COMMAND AND NOT AN `rm`. `run` is resumable, and `status.pick_session` picks
the MOST COMPLETE session rather than the newest. A group whose fixture has just been
repaired therefore still has a complete session on disk, so a re-run skips every execution,
reports the group done, and changes nothing. Clearing the way is a required step, and a
required step that only exists as a remembered shell command is one that gets skipped or
mistyped -- against a tree where a mistyped group id destroys a good group's rows.

TWO HALVES OF ONE DECISION. `scripts/screen/freeze.py --release` is the statement "the rows
under this group no longer describe what is on disk"; this is what acts on it. Discarding
REFUSES unless the group has been released, so neither half can happen quietly, and the
freeze store already carries the dated reason the release was made for.

NOTHING IS DELETED. The device session that produced these rows cost hours and cannot be
re-derived, so the tree is MOVED to `<dataset>/_attic/<date>/<group>/<device>/` with a
`discarded.json` beside it. Recovering a discard is `mv` and nothing else.

    python -m scripts.device_runner discard --group 0508 --reason "fixture repaired"
    python -m scripts.device_runner discard --group 0508 --list      # what is in the attic
"""

from __future__ import annotations

import argparse
import json
import shutil
from datetime import datetime, timezone
from pathlib import Path

from . import config

ATTIC_NAME = "_attic"
STAMP_NAME = "discarded.json"


def attic_dir(group: str, when: str) -> Path:
    """Where a discard lands. Dated, so two discards of one group do not collide."""
    return config.OUT_DIR / ATTIC_NAME / when / group / config.device_slug()


def released(group: str) -> tuple[bool, str]:
    """(is the freeze pin lifted, why the store says so).

    A group that was never pinned counts as released: the pin exists to protect MEASURED
    code, and an unmeasured group has nothing to protect. The import is local because
    `device_runner` is the device-side package and `screen` is not on its critical path.
    """
    from scripts.screen import freeze

    doc = freeze._doc().get("groups", {})
    entry = doc.get(group)
    if entry is None:
        return True, "never pinned"
    if entry.get("released"):
        return True, f"released {entry['released']['at']}: {entry['released']['reason']}"
    return False, f"frozen {entry.get('frozen')} on {', '.join(entry.get('devices') or [])}"


def _exclusions_digest() -> str | None:
    """The screening record the manifest says these rows were measured against, if any.

    Carried into the stamp rather than recomputed at recovery time: the live
    `exclusions.json` has moved on by the time anyone reads an attic entry, and the whole
    value of the field is saying which one was current when the rows were taken.
    """
    manifest = config.manifest_path()
    if not manifest.is_file():
        return None
    try:
        return json.loads(manifest.read_text(encoding="utf-8")).get("exclusions_sha256")
    except (OSError, ValueError):
        return None


def discard(group: str, reason: str, *, dry_run: bool = False) -> dict:
    """Move this group's measurements for THIS device into the attic. Returns the stamp."""
    source = config.device_dir(group)
    if not source.is_dir():
        raise SystemExit(
            f"nothing to discard: {source} does not exist. The group has no measurements on "
            f"{config.device_slug()}, so a re-run will measure it from scratch already.")

    ok, why = released(group)
    if not ok:
        raise SystemExit(
            f"{group} is {why}, so its rows still describe the code on disk and discarding "
            f"them would throw away a measurement nothing has superseded. If the fixture "
            f"really has changed, say so first:\n"
            f"    python3 -m scripts.screen.freeze --release {group} --reason '...'")

    when = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
    target = attic_dir(group, when)
    stamp = {
        "group": group,
        "device": config.device_slug(),
        "discarded": datetime.now(timezone.utc).isoformat(),
        "reason": reason,
        "freeze": why,
        "exclusions_sha256": _exclusions_digest(),
        "from": str(source),
        # What is being retired, so a reader can tell a full session from a stub without
        # walking the tree.
        "performance_rows": sum(
            1 for _ in (source / "performance.jsonl").read_text(encoding="utf-8").splitlines()
            if _.strip()) if (source / "performance.jsonl").is_file() else 0,
        "sessions": sorted(d.name for d in (source / "raw").glob("*")
                           if d.is_dir()) if (source / "raw").is_dir() else [],
    }
    if dry_run:
        return stamp
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.move(str(source), str(target))
    (target / STAMP_NAME).write_text(json.dumps(stamp, indent=2, sort_keys=True) + "\n",
                                     encoding="utf-8")
    return stamp


def listing() -> list[dict]:
    """Every stamp in the attic, newest first."""
    root = config.OUT_DIR / ATTIC_NAME
    if not root.is_dir():
        return []
    out = []
    for stamp in sorted(root.glob("*/*/*/" + STAMP_NAME), reverse=True):
        try:
            out.append(json.loads(stamp.read_text(encoding="utf-8")))
        except (OSError, ValueError):
            continue
    return out


def main() -> None:
    ap = argparse.ArgumentParser(
        description="Retire a group's measurements so a repaired fixture can be re-measured.")
    ap.add_argument("--group", help="Group id, e.g. 0508.")
    ap.add_argument("--reason", help="Why. Required unless --list.")
    ap.add_argument("--list", action="store_true", help="What is in the attic.")
    ap.add_argument("--dry-run", action="store_true", help="Report, move nothing.")
    ap.add_argument("--device", help="Device slug override (default: $BENCH_DEVICE_ID).")
    args = ap.parse_args()

    if args.device:
        import os
        os.environ["BENCH_DEVICE_ID"] = args.device

    if args.list:
        rows = listing()
        for row in rows:
            print(f"{row['discarded'][:19]}  {row['group']}/{row['device']:10} "
                  f"{row['performance_rows']:5} rows  {row['reason']}")
        print(f"{len(rows)} discard(s) in {config.OUT_DIR / ATTIC_NAME}")
        return

    if not args.group or not args.reason:
        raise SystemExit("--group and --reason are both required (or use --list).")

    stamp = discard(args.group, args.reason, dry_run=args.dry_run)
    verb = "would retire" if args.dry_run else "retired"
    print(f"{verb} {stamp['group']}/{stamp['device']}: {stamp['performance_rows']} "
          f"performance rows, {len(stamp['sessions'])} raw session(s)")
    if not args.dry_run:
        print(f"  -> {attic_dir(stamp['group'], '<stamp>').parent.parent}")
        print(f"  re-measure with: python -m scripts.device_runner run "
              f"--samples-root new_samples --widget-type {stamp['group']} --eligible-only")


if __name__ == "__main__":
    main()
