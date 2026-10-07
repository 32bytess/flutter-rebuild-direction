"""Drive local LLM CLIs in headless mode to generate mutations.

Both CLIs are invoked non-interactively and return plain text:
  - codex  : prompt on STDIN,  `codex exec -p research [-m <id>] -`
  - claude : prompt on STDIN,  `claude -p [--model <id>]`
  - gemini : prompt as arg,    `gemini -p "<prompt>" [-m <id>] -o text`

No API keys are needed here — each CLI uses its own configured auth.
"""
from __future__ import annotations
import logging
import re
import subprocess
import tempfile
import time
from pathlib import Path

BACKENDS = ("codex", "claude", "gemini")
CODEX_PROFILE = "research"


_LIMIT_PATTERNS = [
    re.compile(r"\busage limit\b", re.I),
    re.compile(r"\brate limit\b", re.I),
    re.compile(r"\blimit (?:reached|exceeded)\b", re.I),
    re.compile(r"\b5[- ]?hour\b", re.I),
    re.compile(r"\btry again\b", re.I),
]


def _looks_like_limit(output: str) -> bool:
    return any(p.search(output) for p in _LIMIT_PATTERNS)


def _run_codex(prompt: str, model: str | None, timeout: int) -> subprocess.CompletedProcess:
    with tempfile.NamedTemporaryFile(prefix="codex_mutation_", suffix=".txt") as out:
        cmd = [
            "codex",
            "exec",
            "-p",
            CODEX_PROFILE,
            "--sandbox",
            "read-only",
            "--output-last-message",
            out.name,
        ] + (["-m", model] if model else []) + ["-"]
        started = time.monotonic()
        logging.info(
            "[codex] running profile=%s model=%s timeout=%ss output=%s",
            CODEX_PROFILE,
            model or "(profile default)",
            timeout,
            out.name,
        )
        r = subprocess.run(
            cmd, input=prompt, capture_output=True, text=True, timeout=timeout
        )
        logging.info(
            "[codex] finished exit=%s elapsed=%.1fs",
            r.returncode,
            time.monotonic() - started,
        )
        if r.returncode == 0:
            r.stdout = Path(out.name).read_text()
        return r


def _run_gemini(prompt: str, model: str | None, timeout: int) -> subprocess.CompletedProcess:
    cmd = ["gemini", "-p", prompt, "-o", "text"] + (["-m", model] if model else [])
    started = time.monotonic()
    logging.info(
        "[gemini] running model=%s timeout=%ss",
        model or "(cli default)",
        timeout,
    )
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
    logging.info(
        "[gemini] finished exit=%s elapsed=%.1fs",
        r.returncode,
        time.monotonic() - started,
    )
    return r


def _run_claude(prompt: str, model: str | None, timeout: int) -> subprocess.CompletedProcess:
    cmd = ["claude", "-p"] + (["--model", model] if model else [])
    started = time.monotonic()
    logging.info(
        "[claude] running model=%s timeout=%ss",
        model or "(cli default)",
        timeout,
    )
    r = subprocess.run(cmd, input=prompt, capture_output=True, text=True, timeout=timeout)
    logging.info(
        "[claude] finished exit=%s elapsed=%.1fs",
        r.returncode,
        time.monotonic() - started,
    )
    return r


_DISPATCH = {"codex": _run_codex, "claude": _run_claude, "gemini": _run_gemini}


def run(
    backend: str,
    prompt: str,
    model: str | None = None,
    timeout: int = 240,
    limit_retry_sleep: int = 60,
) -> str | None:
    """Return the model's raw text output, or None on failure."""
    fn = _DISPATCH.get(backend)
    if fn is None:
        raise ValueError(f"backend must be one of {BACKENDS}, got {backend!r}")
    while True:
        try:
            r = fn(prompt, model, timeout)
        except subprocess.TimeoutExpired:
            if backend == "claude" and limit_retry_sleep > 0:
                logging.warning(
                    "[%s] timed out before usable output; retrying in %ss",
                    backend,
                    limit_retry_sleep,
                )
                time.sleep(limit_retry_sleep)
                continue
            logging.error(f"[{backend}] timed out after {timeout}s")
            return None
        except FileNotFoundError:
            logging.error(f"[{backend}] CLI not found on PATH")
            return None

        diagnostic = "\n".join((r.stdout or "", r.stderr or "")).strip()
        if (
            backend == "claude"
            and limit_retry_sleep > 0
            and _looks_like_limit(diagnostic)
        ):
            logging.warning(
                "[%s] usage/rate limit detected before generation; retrying in %ss",
                backend,
                limit_retry_sleep,
            )
            time.sleep(limit_retry_sleep)
            continue

        if backend == "claude" and limit_retry_sleep > 0 and r.returncode != 0:
            logging.warning(
                "[%s] exited %s before usable output; retrying in %ss",
                backend,
                r.returncode,
                limit_retry_sleep,
            )
            if diagnostic:
                logging.warning("[%s] diagnostic: %s", backend, diagnostic[:300])
            time.sleep(limit_retry_sleep)
            continue

        if r.returncode != 0:
            logging.error(f"[{backend}] exit {r.returncode}: {(r.stderr or '').strip()[:300]}")
            return None
        out = (r.stdout or "").strip()
        if backend == "claude" and limit_retry_sleep > 0 and not out:
            logging.warning(
                "[%s] returned no generated output; retrying in %ss",
                backend,
                limit_retry_sleep,
            )
            if diagnostic:
                logging.warning("[%s] diagnostic: %s", backend, diagnostic[:300])
            time.sleep(limit_retry_sleep)
            continue
        logging.info("[%s] produced %d chars", backend, len(out))
        if not out:
            logging.error(f"[{backend}] returned no output")
        return out or None
