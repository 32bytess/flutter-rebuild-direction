"""CLI: generate gated mutations for samples.

Examples:
    # generate the full directed set for every sample
    python -m scripts.mutation --all
    # one sample, specific directives
    python -m scripts.mutation --sample 01 --directives nest_deeper,all_const
    # one sample, specific canonical mutation slots
    python -m scripts.mutation --sample 09 --slots 5,6,7,8
    # choose backend(s): codex, claude, gemini, or multiple for comparison
    python -m scripts.mutation --sample 01 --backend gemini
    python -m scripts.mutation --all --backend codex,claude,gemini
    # just re-run the gate on an existing mutation file (no LLM)
    python -m scripts.mutation --gate samples/01/mutation_1.dart --base samples/01

Generation uses the local `codex` / `claude` / `gemini` CLIs (headless).

The released arm-1 variants all come from the `claude` backend (Claude Sonnet 5). The lineage
log `mutations.jsonl` also holds `codex` and `gemini` rows from early trials on groups 01-04.
The `gemini` row wrote no file, and every file a `codex` run wrote was later overwritten by a
`claude` run, so none of them is in the corpus. The `--backend` default below was left as it
was; pass `--backend claude` to generate the way the released variants were made.

Mutations are written next to the base as samples/<NN>/mutation_<I>.dart, where <I> is the 1-based slot
index in the directive order of the run (a rejected slot leaves a gap, so numbering is
stable across bases). With multiple backends a __<backend> suffix is added. The
directive behind each file is recorded in the lineage row ("file") appended to
samples/mutations.jsonl (base_id, mutation_id, directive, expect, strategy,
backend, model, accepted, file).
"""

from __future__ import annotations
import argparse
import json
import logging
import os

from . import prompt as _prompt
from .gate import check

ROOT = os.path.join(os.path.dirname(__file__), "..", "..", "samples")
ROOT = os.path.normpath(ROOT)
LINEAGE = os.path.join(ROOT, "mutations.jsonl")


def _samples(arg: str | None) -> list[str]:
    if arg:
        return [s.strip().zfill(2) for s in arg.split(",")]
    return sorted(d for d in os.listdir(ROOT) if d.isdigit())


def _slots(arg: str) -> list[int]:
    return [int(s.strip()) for s in arg.split(",") if s.strip()]


def _log_lineage(row: dict) -> None:
    with open(LINEAGE, "a") as f:
        f.write(json.dumps(row) + "\n")
    logging.info(
        "[%s/%s] appended lineage accepted=%s file=%s",
        row["base_id"],
        row["directive"],
        row["accepted"],
        row["file"],
    )


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--all", action="store_true", help="all samples, all directives")
    ap.add_argument("--sample", help="single sample id, e.g. 01")
    ap.add_argument(
        "--directives", help="comma-separated directive keys (default: all)"
    )
    ap.add_argument(
        "--slots",
        help=(
            "comma-separated 1-based mutation slot numbers in the canonical directive "
            "order, e.g. 5,6,7,8"
        ),
    )
    ap.add_argument(
        "--strategy",
        default="cot_fewshot",
        help="prompt strategy: zero_shot | few_shot | cot | cot_fewshot",
    )
    ap.add_argument(
        "--backend",
        default="codex",
        help="LLM CLI backend(s), comma-separated: codex | claude | gemini | codex,claude,gemini",
    )
    ap.add_argument(
        "--model",
        default="sonnet",
        help="specific model id for the backend (default: sonnet)",
    )
    ap.add_argument(
        "--timeout",
        type=int,
        default=240,
        help="seconds to wait for each LLM CLI call before retrying",
    )
    ap.add_argument(
        "--limit-retry-sleep",
        type=int,
        default=60,
        help=(
            "seconds to wait before retrying when Claude reports a usage/rate limit "
            "before generating output; use 0 to disable"
        ),
    )
    ap.add_argument("--gate", help="dart file to validate against --base (no LLM call)")
    ap.add_argument("--base", help="base sample dir for --gate")
    ap.add_argument(
        "--directive",
        help="directive key for --gate; enables spm validate's expected-feature audit",
    )
    args = ap.parse_args()
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(message)s",
        datefmt="%H:%M:%S",
    )

    # gate-only mode (deterministic, no API key needed)
    if args.gate:
        logging.info(
            "Gate-only validation starting gate=%s base=%s directive=%s",
            args.gate,
            args.base,
            args.directive or "(none)",
        )
        ok, violations = check(
            args.base, open(args.gate).read(), directive=args.directive
        )
        print(("ACCEPTED" if ok else "REJECTED"), args.gate)
        for v in violations:
            print("  -", v)
        return

    from .generate import generate_one  # imported lazily so --gate needs no openai/key

    all_keys = [d["key"] for d in _prompt.DIRECTIVES]
    by_key = {d["key"]: d for d in _prompt.DIRECTIVES}
    if args.slots and args.directives:
        ap.error("--slots and --directives cannot be used together")
    if args.slots:
        try:
            slots = _slots(args.slots)
        except ValueError:
            ap.error("--slots must be comma-separated integers, e.g. 5,6,7,8")
        invalid = [s for s in slots if s < 1 or s > len(all_keys)]
        if invalid:
            ap.error(
                "--slots values must be between 1 and "
                f"{len(all_keys)}; got {','.join(map(str, invalid))}"
            )
        slot_keys = [(slot, all_keys[slot - 1]) for slot in slots]
    else:
        keys = (
            [s.strip() for s in args.directives.split(",") if s.strip()]
            if args.directives
            else all_keys
        )
        unknown = [k for k in keys if k not in by_key]
        if unknown:
            ap.error(f"unknown directive(s): {','.join(unknown)}")
        slot_keys = list(enumerate(keys, start=1))
    samples = _samples(args.sample if not args.all else None)
    backends = [b.strip() for b in args.backend.split(",") if b.strip()]
    total_jobs = len(samples) * len(slot_keys) * len(backends)

    accepted = rejected = 0
    logging.info(
        "Starting mutation generation: samples=%s directives=%s backends=%s jobs=%d timeout=%ss",
        ",".join(samples),
        ",".join(k for _, k in slot_keys),
        ",".join(backends),
        total_jobs,
        args.timeout,
    )
    job_index = 0
    for nn in samples:
        base_dir = os.path.join(ROOT, nn)
        logging.info("[%s] sample starting base_dir=%s", nn, base_dir)
        for slot, k in slot_keys:
            d = by_key[k]
            for backend in backends:
                job_index += 1
                logging.info(
                    "[%s/%s/%s] job %d/%d starting slot=%d expected=%s",
                    nn,
                    k,
                    backend,
                    job_index,
                    total_jobs,
                    slot,
                    d["expect"],
                )
                src, violations = generate_one(
                    base_dir,
                    d["text"],
                    strategy=args.strategy,
                    backend=backend,
                    model=args.model,
                    directive_key=k,
                    timeout=args.timeout,
                    limit_retry_sleep=args.limit_retry_sleep,
                )
                suffix = f"__{backend}" if len(backends) > 1 else ""
                fname = f"mutation_{slot}{suffix}.dart"
                row = {
                    "base_id": nn,
                    "mutation_id": f"{nn}_{k}__{backend}",
                    "directive": k,
                    "expect": d["expect"],
                    "strategy": args.strategy,
                    "backend": backend,
                    "model": args.model,
                    "accepted": src is not None,
                    "file": fname,
                }
                if src:
                    out_path = os.path.join(base_dir, fname)
                    logging.info("[%s/%s/%s] writing mutation to %s", nn, k, backend, out_path)
                    with open(out_path, "w") as f:
                        f.write(src)
                    accepted += 1
                    logging.info(f"[{nn}/{k}/{backend}] ACCEPTED -> {fname}")
                else:
                    rejected += 1
                    row["violations"] = violations
                    logging.warning(
                        f"[{nn}/{k}/{backend}] REJECTED after retries: {violations}"
                    )
                _log_lineage(row)
    print(f"\nDone: {accepted} accepted, {rejected} rejected -> lineage in {LINEAGE}")


if __name__ == "__main__":
    main()
