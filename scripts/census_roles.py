"""The role list a pre-campaign validation pass should cover.

    python3 -m scripts.census_roles > validate-roles.txt
    python -m scripts.device_runner run --roles validate-roles.txt ...

THE SET IS A UNION, and neither half is optional:

  eligible endpoints   what the campaign will actually measure. A role that draws an error
                       box here costs 15 executions before anyone notices.
  condemned roles      every role already in `config/render_exclusions.json`. These are NOT
                       all endpoints -- 44 of the 106 recorded on 2026-09-15 are not, because
                       R21 excluded their contrasts and that is what stopped them being
                       endpoints. An endpoints-only pass would therefore have validated no
                       repair at all in 13 of the 19 groups repaired that day, `2411`
                       included, and the only evidence any fixture repair works is a device
                       run that looks at the role that was broken.

Both halves are filtered to roles that exist on disk, so a stale record cannot ask the runner
for a file the corpus does not have.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

from scripts import render_gate
from scripts.paths import PROJECT_ROOT as ROOT

ENDPOINTS = re.compile(r"@([0-9a-f]{8})\.\.([0-9a-f]{8})$")


def endpoint_roles(corpus: Path) -> set[tuple[str, str]]:
    """(group, role) for every endpoint of an eligible contrast, resolved to a file on disk.

    `exclusions.json` names endpoints by sha8, not by filename, so the ordinal comes from the
    corpus. `device_runner.eligible_endpoints` does the same join for the runner; this one
    returns role NAMES because the role list is what `--roles` reads.
    """
    record = json.loads((corpus / "exclusions.json").read_text(encoding="utf-8"))
    shas: dict[str, set[str]] = {}
    for pair in record.get("pairs", []):
        if pair.get("verdict") != "eligible":
            continue
        m = ENDPOINTS.search(pair["pair_id"])
        if m:
            shas.setdefault(pair["group"], set()).update(m.groups())
    out = set()
    for gid, wanted in shas.items():
        for f in (corpus / gid).glob("rev_*.dart"):
            if f.stem.rsplit("_", 1)[-1] in wanted:
                out.add((gid, f.stem))
    return out


def condemned_roles(corpus: Path) -> set[tuple[str, str]]:
    """(group, role) for every row in the render table whose file is still on disk."""
    return {(gid, role)
            for gid, roles in render_gate.load().items()
            for role in roles
            if (corpus / gid / f"{role}.dart").is_file()}


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--corpus", default="new_samples", help="Corpus root (default: new_samples).")
    ap.add_argument("--out", help="Write here instead of stdout.")
    args = ap.parse_args()

    corpus = Path(args.corpus)
    if not corpus.is_absolute():
        corpus = ROOT / corpus

    endpoints = endpoint_roles(corpus)
    condemned = condemned_roles(corpus)
    both = endpoints | condemned

    lines = [
        "# Roles for a pre-campaign validation pass, from scripts/census_roles.py.",
        f"# {len(endpoints)} eligible endpoint(s) + {len(condemned)} condemned role(s) "
        f"= {len(both)} ({len(condemned - endpoints)} condemned are NOT endpoints).",
        "# `python -m scripts.device_runner run --roles <this file>` -- NOT with "
        "--eligible-only,",
        "# which would narrow to the intersection and drop exactly the repairs worth checking.",
    ] + [f"{gid}/{role}" for gid, role in sorted(both)]
    text = "\n".join(lines) + "\n"

    if args.out:
        Path(args.out).write_text(text, encoding="utf-8")
        print(f"wrote {args.out}: {len(both)} role(s)", file=sys.stderr)
    else:
        sys.stdout.write(text)


if __name__ == "__main__":
    main()
