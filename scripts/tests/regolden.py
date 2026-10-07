"""Run the mini corpus through the screen, and regenerate the golden record.

    python3 -m scripts.tests.regolden          # rewrite the golden
    python3 -m scripts.tests.regolden --diff   # show what would change, write nothing

The golden is `exclusions.json` with the volatile fields normalised away -- the only one is
`source`, which is a per-run temporary directory. Everything else is a screening decision and
is supposed to be stable; that is what makes a diff here meaningful rather than noisy.
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
from pathlib import Path

CONTAINER = Path(__file__).resolve().parents[2]
GOLDEN = Path(__file__).resolve().parent / "data" / "mini_corpus_exclusions.json"


# Fields that describe the RUN rather than a screening decision: a temporary directory, a
# timestamp, the digests of whatever rule set and value table happened to be current. They
# are asserted for shape in `test_golden_corpus.py` instead, so that editing a rule does not
# fail a golden whose subject is what the rules DECIDED.
VOLATILE = ("source", "provenance")


def stable(out: dict) -> dict:
    return {k: v for k, v in out.items() if k not in VOLATILE}


def screen_argv(source: Path, records: Path, extra: list[str] | None = None) -> list[str]:
    """The command every test here runs. `--vectors` because the mini corpus supplies its own
    feature vectors, which is what lets a whole screen run without an `spm analyze` pass.

    `--render-exclusions` points at a file the mini corpus does not have, which is the point:
    R21/R22's table is GLOBAL, and without the flag this corpus would be judged on the real
    one's device verdicts. The golden record is what caught it -- 40 groups of the live corpus
    appeared in a nine-group fixture's `render` block."""
    return [sys.executable, "-m", "scripts.screen_samples",
            "--source", str(source), "--records", str(records),
            "--vectors", str(source / "static_vectors.jsonl"),
            "--license-provenance", str(source / "license_provenance.jsonl"),
            "--license-candidates", str(source / "candidates.jsonl"),
            "--render-exclusions", str(source / "render_exclusions.json"),
            *(extra or [])]


def run(argv: list[str], *, expect_failure: bool = False,
        env: dict[str, str] | None = None) -> subprocess.CompletedProcess:
    """Run the screen as a subprocess. `env` overlays the parent environment.

    `env` exists for the two table paths. `--dest` and `--records` are arguments, but
    `config/fixture_values.json` and `config/maximal_branch.json` are GLOBAL -- a subprocess
    test that touches them writes into the live tree whatever tmp dir it was given. That is
    not theoretical: `test_init_refuses_to_overwrite_a_committed_table` seeded a `{}` table
    over the real one whenever the real one was absent, which is exactly the state a
    from-scratch rebuild is in, and a `{}` table present at pipeline start silently flips its
    first screen from `--init` to `--resume`.
    """
    completed = subprocess.run(argv, cwd=str(CONTAINER), capture_output=True, text=True,
                               env={**os.environ, **env} if env else None)
    if expect_failure:
        assert completed.returncode != 0, "expected a refusal, got a clean exit"
    elif completed.returncode != 0:
        raise RuntimeError(f"screen failed ({completed.returncode}):\n"
                           f"{completed.stdout}\n{completed.stderr}")
    return completed


def run_screen(root: Path, extra: list[str] | None = None) -> dict:
    """Build the mini corpus under `root`, screen it, and return the record it wrote.

    `--report-only` because this exercises the screen, not the export, and `--vectors`
    because the mini corpus supplies its own feature vectors -- which is what lets a whole
    screen run without an `spm analyze` pass.
    """
    from scripts.tests import mini_corpus

    source = mini_corpus.build(root / "corpus")
    records = root / "records"
    run(screen_argv(source, records, ["--report-only", *(extra or [])]))
    return json.loads((records / "exclusions.json").read_text())


def main(argv: list[str]) -> int:
    import tempfile

    with tempfile.TemporaryDirectory() as tmp:
        got = stable(run_screen(Path(tmp)))
    text = json.dumps(got, indent=1, sort_keys=True) + "\n"

    if "--diff" in argv:
        old = GOLDEN.read_text() if GOLDEN.is_file() else ""
        if old == text:
            print("golden is current")
            return 0
        print("golden would change; run without --diff to rewrite it")
        return 1

    GOLDEN.parent.mkdir(parents=True, exist_ok=True)
    GOLDEN.write_text(text)
    print(f"wrote {GOLDEN} "
          f"({got['totals']['eligible_pairs']} eligible contrasts across "
          f"{got['totals']['eligible_mover_scopes']} mover scopes)")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
