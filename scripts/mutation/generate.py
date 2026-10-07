"""Mutation generation via a local LLM CLI (`claude`, `codex` or `gemini`), gated by scripts.mutation.gate.

The released arm-1 variants all come from the `claude` backend; see `__main__.py`.

Each mutation is produced by one headless CLI call; on rejection the gate's reasons are
appended to the prompt and the call is retried so the model can self-correct.
"""

from __future__ import annotations
import logging
import os
import re

from . import cli
from . import prompt as _prompt
from .gate import check


def _strip_fences(text: str) -> str:
    text = text.strip()
    m = re.search(r"```(?:dart)?\s*(.*?)```", text, re.S)
    return (m.group(1) if m else text).strip()


def generate_one(
    base_dir: str,
    directive: str,
    retries: int = 2,
    strategy: str = "cot_fewshot",
    backend: str = "codex",
    model: str | None = None,
    directive_key: str | None = None,
    timeout: int = 240,
    limit_retry_sleep: int = 60,
) -> tuple[str | None, list[str]]:
    """Generate one gated mutation for the sample at base_dir using the chosen CLI backend.
    Returns (accepted_src or None, violations)."""
    sample_id = os.path.basename(base_dir)
    logging.info("[%s %s] reading base.dart and dependencies.dart", sample_id, backend)
    base = open(os.path.join(base_dir, "base.dart")).read()
    deps = open(os.path.join(base_dir, "dependencies.dart")).read()
    logging.info(
        "[%s %s] building prompt strategy=%s directive=%s base_chars=%d deps_chars=%d",
        sample_id,
        backend,
        strategy,
        directive_key or "(none)",
        len(base),
        len(deps),
    )
    prompt_text = _prompt.build_prompt(base, deps, directive, strategy=strategy)
    logging.info("[%s %s] prompt ready chars=%d", sample_id, backend, len(prompt_text))
    last: list[str] = ["no output"]
    for attempt in range(1, retries + 2):
        logging.info(
            "[%s %s] attempt %d/%d starting",
            sample_id,
            backend,
            attempt,
            retries + 1,
        )
        raw = cli.run(
            backend,
            prompt_text,
            model=model,
            timeout=timeout,
            limit_retry_sleep=limit_retry_sleep,
        )
        if not raw:
            last = ["CLI returned no output"]
            continue
        src = _strip_fences(raw)
        logging.info(
            "[%s %s] model output received raw_chars=%d dart_chars=%d",
            sample_id,
            backend,
            len(raw),
            len(src),
        )
        logging.info("[%s %s] validating attempt %d", sample_id, backend, attempt)
        ok, violations = check(base_dir, src, directive=directive_key)
        if ok:
            logging.info("[%s %s] validation accepted attempt %d", sample_id, backend, attempt)
            return src, []
        last = violations
        logging.info("[%s %s] attempt %d rejected: %s", sample_id, backend, attempt, violations)
        logging.info("[%s %s] appending rejection feedback and retrying", sample_id, backend)
        prompt_text = (
            prompt_text
            + "\n\nThe previous attempt was REJECTED for these reasons:\n- "
            + "\n- ".join(violations)
            + "\nFix them. Keep imports, State fields, and initState/dispose IDENTICAL to "
            "the base; change ONLY the widget-tree structure. Output only the complete "
            "base.dart in a single ```dart code block."
        )
        logging.info("[%s %s] retry prompt chars=%d", sample_id, backend, len(prompt_text))
    return None, last
