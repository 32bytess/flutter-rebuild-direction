"""Validation gate for generated mutations.

A mutation is accepted only if it is a *clean structural change* of its base: same
imports, same State fields, byte-identical initState/dispose (so inputs cannot drift),
no out-of-scope/non-deterministic constructs, and it compiles against the unmodified
frozen dependencies.dart. Anything else is a tangled change and is rejected.

Usage:
    from scripts.mutation.gate import check
    ok, violations = check(base_dir="samples/01", mutation_src=<dart source>)
"""

from __future__ import annotations
import logging
import os
import re
import shutil
import subprocess
import tempfile
import time

from .. import spm

# Allow `with <mixins>` / `implements <ifaces>` between `State<...>` and the body `{`.
_STATE_RE = re.compile(r"class\s+_GeneratedWidgetState\s+extends\s+State<\w+>[^{]*\{")
_FORBIDDEN = {
    "DateTime.now": r"DateTime\.now\s*\(",
    "Random": r"\bRandom\s*\(",
    "async": r"\basync\b",
    "await": r"\bawait\b",
    "Future": r"\bFuture<",
    "Stream": r"\bStream<",
    "dart:io": r"dart:io",
    "network": r"HttpClient|http\.|NetworkImage|Image\.network|package:dio|Socket\(",
    "animation": r"AnimationController|TickerProvider|\bTween\b|CurvedAnimation|\.animate\(|vsync",
}


_TEXT_RE = re.compile(
    r"(?:Text|SelectableText|Tooltip)\s*(?:\.rich)?\s*\(\s*"
    r"(?:const\s+)?(?:message\s*:\s*)?(['\"])(.*?)\1",
    re.S,
)
_ICON_RE = re.compile(r"\bIcons\.\w+")


def _norm(s: str) -> str:
    return re.sub(r"\s+", " ", s).strip()


def _strip_strings(src: str) -> str:
    """Blank comments + string bodies so _FORBIDDEN can't match inside display text
    (e.g. Text('please await ...') must not trip the `await` rule)."""
    src = re.sub(r"/\*.*?\*/", " ", src, flags=re.S)
    src = re.sub(r"//[^\n]*", " ", src)
    src = re.sub(r"'(?:\\.|[^'\\])*'", "''", src)
    src = re.sub(r'"(?:\\.|[^"\\])*"', '""', src)
    return src


def _content_sig(src: str) -> tuple[frozenset, frozenset]:
    """Distinct rendered-leaf vocabulary: (Text/Tooltip strings, icon names). The content
    guard — the mutation must render the same leaves as the base, so these sets must match
    (directives that REPEAT existing content reuse the same distinct values, so set
    equality still holds)."""
    texts = frozenset(m.group(2) for m in _TEXT_RE.finditer(src))
    icons = frozenset(_ICON_RE.findall(src))
    return texts, icons


def _imports(src: str) -> list[str]:
    return sorted(_norm(x) for x in re.findall(r"^import\s+'[^']+';", src, re.M))


def _brace_block(src: str, open_idx: int) -> str | None:
    """Return text from the '{' at/after open_idx through its matching '}'."""
    i = src.find("{", open_idx)
    if i < 0:
        return None
    depth = 0
    for j in range(i, len(src)):
        if src[j] == "{":
            depth += 1
        elif src[j] == "}":
            depth -= 1
            if depth == 0:
                return src[i : j + 1]
    return None


def _state_block(src: str) -> str | None:
    m = _STATE_RE.search(src)
    return _brace_block(src, m.end() - 1) if m else None


def _method_body(block: str, name: str) -> str | None:
    m = re.search(r"\b" + re.escape(name) + r"\s*\([^)]*\)\s*\{", block)
    return _norm(_brace_block(block, m.end() - 1)) if m else None


def _field_region(block: str) -> str:
    """Normalized text of the State class's field-declaration region: everything in the
    body before the first method/getter (`@override` or initState/dispose/build/...).
    Region-based comparison is robust to multi-line field initializers."""
    cut = re.search(
        r"@override\b|\b(?:initState|dispose|didUpdateWidget|build)\s*\(", block
    )
    head = block[1 : cut.start()] if cut else block[1:-1]  # drop the leading '{'
    return _norm(head)


def _frozen_members(src: str) -> dict:
    block = _state_block(src) or ""
    return {
        "imports": _imports(src),
        "fields": _field_region(block),
        "initState": _method_body(block, "initState"),
        "dispose": _method_body(block, "dispose"),
        "didUpdateWidget": _method_body(block, "didUpdateWidget"),
    }


def _compiles(base_dir: str, mutation_src: str) -> tuple[bool, str]:
    """Analyze the mutation against the sample's frozen dependencies.dart, in-place
    (inside the project so package resolution works), in a throwaway subdir."""
    tmp = tempfile.mkdtemp(prefix=".gate_", dir=base_dir)
    try:
        shutil.copyfile(
            os.path.join(base_dir, "dependencies.dart"),
            os.path.join(tmp, "dependencies.dart"),
        )
        with open(os.path.join(tmp, "base.dart"), "w") as f:
            f.write(mutation_src)
        started = time.monotonic()
        logging.info("[%s gate] running dart analyze", os.path.basename(base_dir))
        r = subprocess.run(["dart", "analyze", tmp], capture_output=True, text=True)
        logging.info(
            "[%s gate] dart analyze finished exit=%s elapsed=%.1fs",
            os.path.basename(base_dir),
            r.returncode,
            time.monotonic() - started,
        )
        errs = [
            ln
            for ln in (r.stdout + r.stderr).splitlines()
            if re.match(r"\s*error ", ln)
        ]
        return (len(errs) == 0), "\n".join(errs[:8])
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def _spm_validates(
    base_dir: str, mutation_src: str, directive: str | None = None
) -> tuple[bool, str]:
    tmp = tempfile.NamedTemporaryFile(
        "w", prefix=".spm_validate_", suffix=".dart", dir=base_dir, delete=False
    )
    mutation_path = tmp.name
    try:
        tmp.write(mutation_src)
        tmp.close()
        cmd = [
            *spm.entry("validate"),
            "--base",
            os.path.abspath(os.path.join(base_dir, "base.dart")),
            "--mutation",
            os.path.abspath(mutation_path),
            "--deps",
            os.path.abspath(os.path.join(base_dir, "dependencies.dart")),
            "--strict",
        ]
        if directive:
            cmd.extend(["--directive", directive])
        started = time.monotonic()
        logging.info(
            "[%s gate] running spm validate directive=%s",
            os.path.basename(base_dir),
            directive or "(none)",
        )
        r = subprocess.run(cmd, capture_output=True, text=True)
        logging.info(
            "[%s gate] spm validate finished exit=%s elapsed=%.1fs",
            os.path.basename(base_dir),
            r.returncode,
            time.monotonic() - started,
        )
        details = "\n".join(
            ln for ln in (r.stdout + r.stderr).splitlines() if ln.strip()
        )
        return r.returncode == 0, details[:2000]
    finally:
        tmp.close()
        try:
            os.unlink(mutation_path)
        except FileNotFoundError:
            pass


def check(
    base_dir: str, mutation_src: str, directive: str | None = None
) -> tuple[bool, list[str]]:
    """Return (accepted, [violation messages])."""
    sample_id = os.path.basename(base_dir)
    logging.info("[%s gate] starting validation directive=%s", sample_id, directive or "(none)")
    base_src = open(os.path.join(base_dir, "base.dart")).read()
    v: list[str] = []

    # 1. no out-of-scope / non-deterministic constructs (scan with strings/comments
    #    stripped so display text like Text('await later') cannot false-trigger)
    logging.info("[%s gate] checking forbidden constructs", sample_id)
    scan = _strip_strings(mutation_src)
    for label, pat in _FORBIDDEN.items():
        if re.search(pat, scan):
            v.append(f"forbidden construct: {label}")

    # 2. frozen members must match the base verbatim (inputs cannot drift)
    logging.info("[%s gate] checking frozen imports, fields, and lifecycle methods", sample_id)
    b, m = _frozen_members(base_src), _frozen_members(mutation_src)
    if m["imports"] != b["imports"]:
        v.append(
            f"imports changed: +{sorted(set(m['imports'])-set(b['imports']))} "
            f"-{sorted(set(b['imports'])-set(m['imports']))}"
        )
    if m["fields"] != b["fields"]:
        v.append("State field declarations/initializers changed (must be identical)")
    for meth in ("initState", "dispose", "didUpdateWidget"):
        if m[meth] != b[meth]:
            v.append(f"{meth}() body changed (inputs must be identical)")

    # 3. reject a no-op copy (a real structural change is required)
    logging.info("[%s gate] checking mutation is not identical to base", sample_id)
    if _norm(mutation_src) == _norm(base_src):
        v.append("no structural change (identical to base)")

    # 4. same content: the rendered Text/Tooltip strings and icon set must match the base
    logging.info("[%s gate] checking rendered text/icon content", sample_id)
    bt, bi = _content_sig(base_src)
    mt, mi = _content_sig(mutation_src)
    if mt != bt:
        v.append(f"content drift - Text differs: +{sorted(mt - bt)} -{sorted(bt - mt)}")
    if mi != bi:
        v.append(f"content drift - icons differ: +{sorted(mi - bi)} -{sorted(bi - mi)}")

    # 5. must compile against the frozen dependencies.dart
    ok, errs = _compiles(base_dir, mutation_src)
    if not ok:
        v.append("does not compile:\n" + errs)

    # 6. SPM's own mutation validator must also accept the structural variant.
    ok, details = _spm_validates(base_dir, mutation_src, directive=directive)
    if not ok:
        v.append("spm validate failed:\n" + details)

    logging.info("[%s gate] validation complete accepted=%s violations=%d", sample_id, not v, len(v))
    return (len(v) == 0), v
