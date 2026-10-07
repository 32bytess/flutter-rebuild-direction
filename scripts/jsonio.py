"""Reading a JSON file that another process may be writing. One definition.

`mining.checkpoints.write` and `isolate`'s `id_map.json` both use a plain `write_text`,
so a reader can catch a half-written file while a mine is still running. This reader retries
rather than crashing, and treats an unreadable file as not-yet-there -- which is exactly what
a repository still being mined IS.

It lived in `screen/manifests.py` and was used only there, while `exclusions.json`,
`id_map.json` and the two committed tables -- every one of them written by a process that may
still be running -- were read elsewhere with a bare `json.loads(path.read_text())`. The
hardening was real and its reach was an accident of where it happened to be written, so it
moved out to where every reader can have it. `manifests.read_json` is still a name; it now
points here.
"""

from __future__ import annotations

import json
import time
from pathlib import Path

RETRIES = 3
BACKOFF_S = 0.2


def read_json(path: Path | str, default=None):
    """Read a JSON file that a running `mine` may be rewriting under us.

    Truncation is transient -- the writer finishes in milliseconds -- so a short retry
    recovers it, and the fallback is `default`.
    """
    for attempt in range(RETRIES):
        try:
            return json.loads(Path(path).read_text())
        except FileNotFoundError:
            return default
        except (json.JSONDecodeError, UnicodeDecodeError):
            if attempt == RETRIES - 1:
                return default
            time.sleep(BACKOFF_S)
    return default


def require_json(path: Path | str, what: str) -> dict:
    """`read_json`, but a missing or unreadable file is fatal rather than empty.

    For the readers where absence is not a state the pipeline can be in -- a rebuild gate
    checking the record it just wrote, a fill reading the screen that selected its groups.
    Returning `{}` there turns a missing artifact into a silently smaller run, which is the
    failure mode this project spends the most effort refusing elsewhere.
    """
    doc = read_json(path)
    if doc is None:
        raise SystemExit(f"{what}: cannot read {path} -- expected it to exist and be JSON")
    return doc
