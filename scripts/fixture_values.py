"""Resolve every `// TODO: value` in a fixture into a committed table.

Implements the value hierarchy of the fixture value-fill protocol, 3.3.
Standalone by design: `screen_samples.py` must stay offline, parse-only and deterministic or
`rules_version()` stops meaning anything, and `mining/isolate.py` is the provenance artifact
carrying the pooling invariants. This reads the corpus plus the clones and writes tables; it
mutates no mined artifact.

    python -m scripts.fixture_values --report
    python -m scripts.fixture_values --apply
    python -m scripts.fixture_values --init      # first run only: seed an empty table

A missing table RAISES, on a first run as much as on a stale path. `--init` is the only way
past it, because seeding changes `values_version()` and that invalidates every screening
checkpoint -- which must never happen as a side effect of a screen.

Every entry carries a mandatory `origin`, so the write-up can say how many values were recovered
rather than blending recovered and defaulted ones silently:

    recovered  -- the repository's own literal at the group's anchor commit
    default    -- the committed policy table in config/fixture_policy.json
    none       -- unrecoverable; reported, never guessed, and the role is dropped
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import subprocess
from pathlib import Path

from . import fixture_gate, fixture_skeleton, jsonio
from .paths import PROJECT_ROOT as ROOT, rel


# Both tables are overridable by environment variable, and the defaults are the committed
# arm-2 pair. The override exists for ONE reason: `values_version()` is a digest over these
# two files, and `new_samples/exclusions.json` records the digest that was current when the
# arm-2 corpus was screened -- a test asserts the two are equal. A second corpus built from
# the same mine fills its own slots, so writing them back into the shared table would move
# `values_version()` and break that assertion without touching a single file in
# `new_samples/`. A corpus that is not the arm-2 corpus therefore carries its own table:
#
#     SPM_FIXTURE_VALUES=config/fixture_values_v3.json python3 -m scripts.mining pipeline
#
# A relative value resolves against ROOT, so the variable reads the same from any cwd.
def table_path(env_var: str, default: Path) -> Path:
    override = os.environ.get(env_var)
    if not override:
        return default
    path = Path(override)
    return path if path.is_absolute() else ROOT / path


POLICY_PATH = table_path("SPM_FIXTURE_POLICY", ROOT / "config" / "fixture_policy.json")
VALUES_PATH = table_path("SPM_FIXTURE_VALUES", ROOT / "config" / "fixture_values.json")


def load() -> dict:
    """The committed value table, or `{}` when it has not been built yet.

    The one way to read this file. `screen_samples` used to re-derive the path from
    PROJECT_ROOT and read it directly, which meant `SPM_FIXTURE_VALUES` moved this module's
    reader and not that one -- an override could point the fill at one table while R16 judged
    against another, with nothing anywhere saying so.
    """
    return jsonio.read_json(VALUES_PATH, {}) or {}


CLONE_DIRS = [ROOT.parent / "new_data" / "repos-full", ROOT.parent / "new_data" / "repos"]

DECL = re.compile(r"^(?P<decl>.*?)\s*//\s*TODO: value\s*$")
# The type character classes admit `(` and `)` so a FUNCTION TYPE parses -- `bool
# Function(CardBean)`, `void Function(bool, CardBean)`, `Function(double)`. Without them the
# declaration matched no pattern at all and fell through to the "genuinely unparsed" return,
# which is deliberately undeclared: the `--from-nothing` gate then reported a hole in the
# policy for a refusal the policy had already made, since `Function` is named out of scope.
LATE = re.compile(r"^late\s+(?P<type>[\w<>,?()\s]+?)\s+(?P<name>\w+);$")
CONST_STANDIN = re.compile(r"^const\s+dynamic\s+(?P<name>\w+)\s*=\s*null;$")
TYPED = re.compile(r"^(?:const\s+|final\s+)?(?P<type>[\w<>,?()\s]+?)\s+(?P<name>\w+)\s*=\s*(?P<init>.+);$")
COLLECTION = re.compile(r"^(?P<kind>List|Set)<(?P<elem>[\w<>,?\s]+)>$")
MAPPY = re.compile(r"^Map<")


def load_policy() -> dict:
    return json.loads(POLICY_PATH.read_text(encoding="utf-8"))


def dart_literal(value) -> str:
    """A JSON scalar from the policy table -> the Dart source for it.

    The single place a policy value becomes an expression. Until 2026-09-05 the table held
    Dart source directly -- `"const Color(0xFF000000)"`, `"() {}"` -- so an authored file was
    compiled into a shipped transplant with nothing between the two, and a typo surfaced as a
    Dart compile error three phases downstream. The table now holds inert scalars and this
    renders them, which is also why `bool` cannot leak Python's `True`.

    Anything that is not a JSON scalar raises: a policy that has grown a shape this cannot
    render is a policy to fix, not one to guess at.
    """
    if isinstance(value, bool):                 # before int: bool IS an int in Python
        return "true" if value else "false"
    if isinstance(value, str):
        body = (value.replace("\\", r"\\").replace("'", r"\'").replace("$", r"\$")
                     .replace("\n", r"\n").replace("\r", r"\r").replace("\t", r"\t"))
        return f"'{body}'"
    if isinstance(value, int):
        return str(value)
    if isinstance(value, float):
        return repr(value)                      # 0.0 -> "0.0", never "0"
    raise TypeError(
        f"policy value {value!r} ({type(value).__name__}) is not a JSON scalar; "
        "config/fixture_policy.json holds inert scalars only")


# Moved to `scripts.paths.rel`: `screen.rebuild` needed the same guard and was calling
# `relative_to` bare, which threw after it had already removed the corpus.
_rel = rel


def _is_tracked(path: Path) -> bool:
    """Whether git has this path in the index. Used only to word an error message.

    Any failure answers True, so the message defaults to the louder of the two readings: a
    guard that gets weaker when git is unavailable would be the wrong way round.
    """
    try:
        r = subprocess.run(["git", "ls-files", "--error-unmatch", str(path)], cwd=ROOT,
                           capture_output=True, text=True, timeout=30)
        return r.returncode == 0
    except Exception:
        return True


def values_version() -> str:
    """Digest over both committed tables, for the checkpoint fingerprint.

    Without it, editing the policy leaves every generated fixture stale with no signal --
    exactly the failure `ast_tools.rules_version()` exists to prevent for screening rules.

    A missing file RAISES rather than hashing `b""` -- ALWAYS, including on a genuine first
    run. Hashing empty bytes would answer with a plausible digest that silently invalidates
    every checkpoint, which is the exact failure mode of moving these files, and auto-creating
    the table would be worse: re-derivation degrades QUIETLY. `recover_literal` needs the
    blobless clones to still hold each group's anchor sha, and a missing clone sends the
    binding to a policy default with no error anywhere -- the `f627e20` bug class, which hid
    for exactly that reason.

    Git only decides how the refusal is WORDED. A tracked-but-absent table is a deletion or a
    stale path constant; an untracked one is a first run and wants `--init`. Neither is
    recoverable here, so both raise.
    """
    h = hashlib.sha256()
    for p in (POLICY_PATH, VALUES_PATH):
        if not p.is_file():
            if _is_tracked(p):
                raise FileNotFoundError(
                    f"committed fixture table missing: {p}. It is tracked in git, so this is "
                    f"a stale path constant or a deletion, not a first run. Restore it with "
                    f"`git checkout -- {_rel(p)}`.")
            raise FileNotFoundError(
                f"fixture table missing and untracked: {p}. If this is a first run, seed it "
                f"with `python -m scripts.fixture_values --init`; the fill pass writes the "
                f"real table. Never create it by hand -- the digest is what invalidates "
                f"stale checkpoints.")
        h.update(p.read_bytes())
    return h.hexdigest()[:16]


def init_values_table() -> str:
    """Seed an empty values table for a from-scratch rebuild, and return the new digest.

    Deliberately a separate flag rather than a side effect of `--apply`: a bootstrap changes
    `values_version()`, which invalidates every screening checkpoint, and that must never
    happen implicitly. Refuses to overwrite -- the table is the durable artifact and the
    corpus is derived from it, not the other way round.

    An EMPTY table is the exception, and it is not a weakening: `{}` is the exact byte string
    this function writes, so seeding onto it is a no-op that cannot move `values_version()`
    and cannot discard a stored value, because there is none. Refusing it is what turned one
    transient failure into a permanent one on 2026-09-06 -- phase 0 seeded the table, a later
    phase of the SAME pass refused, and every retry after that died here on the seed's own
    output. A table holding bindings still refuses, which is the case the guard is about.
    """
    if VALUES_PATH.is_file():
        if load():
            raise SystemExit(
                f"refusing to overwrite {VALUES_PATH}. --init seeds a FIRST run only; to "
                f"correct stored values re-run with --reresolve, which reports what moves "
                f"before writing.")
        print(f"--init: {rel(VALUES_PATH)} is already the empty seed; left as it is")
        return values_version()
    VALUES_PATH.parent.mkdir(parents=True, exist_ok=True)
    VALUES_PATH.write_text("{}\n", encoding="utf-8")
    return values_version()


def anchor_sha(group_dir: Path) -> str | None:
    """The group's lowest-ordinal revision. One anchor per group, applied to every role --
    otherwise the fixture forks and the pair stops being comparable."""
    revs = []
    for f in group_dir.glob("rev_*.dart"):
        m = re.match(r"rev_(\d+)_([0-9a-f]+)\.dart$", f.name)
        if m:
            revs.append((int(m.group(1)), m.group(2)))
    return min(revs)[1] if revs else None


def clone_for(owner_repo: str) -> Path | None:
    slug = owner_repo.replace("/", "_")
    for base in CLONE_DIRS:
        if (base / slug / ".git").exists() or (base / slug).is_dir():
            return base / slug
    return None


def _git(cwd: Path, *args: str) -> str:
    try:
        r = subprocess.run(["git", *args], cwd=cwd, capture_output=True, text=True, timeout=60)
        return r.stdout if r.returncode == 0 else ""
    except Exception:
        return ""


# Declaration HEADS only -- everything up to and including the `=`. The initializer itself is
# taken by `_scan_initializer`, because a regex cannot tell a `;` inside a string or a nested
# collection from the one that ends the declaration, and `[^;]+` could not cross a line at all.
_DECL_HEADS = (
    # A declaration may or may not carry a type between the keyword and the name:
    # `const white = Color(...)` and `const double eqMaxDb = 12.0` are both real. The
    # first form only ever matched when the type happened to be `Color`, so every
    # typed non-colour const fell through to the colour default and was filled with a
    # `Color` -- `fontNormal` ('Rubik') and `eqMinDb` (-12.0) among them, both of which
    # throw at mount. The type is optional and non-greedy so the name still anchors it.
    r"(?:(?:static\s+)?(?:const|final|var))\s+(?:[\w<>,\?\s\[\]]+?\s+)?{name}\s*=\s*",
    # No keyword at all: a plain typed top-level, `Color white = Color(...);`.
    r"^[ \t]*(?:[\w<>,\?\s\[\]]+\s+){name}\s*=\s*",
)


def _scan_initializer(text: str, start: int) -> str | None:
    """`text[start:]` begins just after a declaration's `=`. Return the initializer up to its
    own terminating `;`, or None if the text runs out before one is found.

    Depth-tracked over `()`, `[]` and `{}`, with string literals and comments skipped, so a
    `;` or an unbalanced bracket inside either cannot end the scan or corrupt the count. This
    is what lets a list that spans lines be recovered: `git grep` is line-oriented and hands
    back only the declaration's first line, and the old `=\\s*(?P<init>[^;]+);` required the
    initializer to close on it. `layout_title` in `maheshj01/awesome_flutter_layouts` is a
    `const List` of eight strings written over nine lines; it matched as a declaration, failed
    as an initializer, and fell through to the `Color` policy default -- which the four
    revisions then index with `.length`, so the role throws at mount.

    Whitespace runs OUTSIDE strings collapse to one space and comments are dropped, so a
    nine-line literal comes back as one line. Inside a string, and inside a `${...}`
    interpolation, every byte is preserved.
    """
    out: list[str] = []
    depth = 0
    i, n = start, len(text)
    while i < n:
        c = text[i]
        # comments -- dropped entirely
        if c == "/" and i + 1 < n and text[i + 1] == "/":
            i = text.find("\n", i)
            if i < 0:
                return None
            continue
        if c == "/" and i + 1 < n and text[i + 1] == "*":
            j = text.find("*/", i + 2)
            if j < 0:
                return None
            i = j + 2
            continue
        # string literals -- copied verbatim, including any `;` or bracket inside
        if c in "'\"":
            j = _skip_string(text, i)
            if j is None:
                return None
            out.append(text[i:j])
            i = j
            continue
        if c in "([{":
            depth += 1
        elif c in ")]}":
            depth -= 1
            if depth < 0:
                return None          # the declaration was never ours to read
        elif c == ";" and depth == 0:
            init = "".join(out).strip()
            return init or None
        if c.isspace():
            if out and not out[-1].isspace():
                out.append(" ")
            i += 1
            continue
        out.append(c)
        i += 1
    return None                       # ran off the end of the file: not self-contained


def _skip_string(text: str, i: int) -> int | None:
    """Index just past the string literal starting at `text[i]`, or None if it is unterminated.

    Handles `'`/`"`, their triple-quoted forms, `r`-prefixed raw strings (where `\\` is not an
    escape) and `${...}` interpolation, whose braces may themselves contain strings.
    """
    raw = i > 0 and text[i - 1] == "r"
    q = text[i]
    quote = q * 3 if text[i:i + 3] == q * 3 else q
    i += len(quote)
    n = len(text)
    while i < n:
        c = text[i]
        if c == "\\" and not raw:
            i += 2
            continue
        if not raw and c == "$" and i + 1 < n and text[i + 1] == "{":
            d, i = 1, i + 2
            while i < n and d:
                if text[i] in "'\"":
                    j = _skip_string(text, i)
                    if j is None:
                        return None
                    i = j
                    continue
                d += (text[i] == "{") - (text[i] == "}")
                i += 1
            continue
        if text.startswith(quote, i):
            return i + len(quote)
        i += 1
    return None


def recover_literal(clone: Path, sha: str, name: str) -> tuple[str, str] | None:
    """The repository's own initializer for `name` at `sha`, verbatim, plus its provenance.

    Only self-contained initializers are taken. `Color(0xFF18191F)` is usable as-is;
    `AppColors.primary` names another symbol this pass does not close over, so it is refused
    rather than emitted broken. Self-contained is a property of the EXPRESSION, not of the
    line it starts on -- see `_scan_initializer`.
    """
    hits = _git(clone, "grep", "-n", f"\\b{name}\\s*=", sha, "--", "*.dart")
    blobs: dict[str, str] = {}
    for line in hits.splitlines():
        parts = line.split(":", 3)
        if len(parts) < 4:
            continue
        _, path, lineno, text = parts
        init = None
        for pat in _DECL_HEADS:
            head = pat.format(name=re.escape(name))
            m = re.search(head, text, re.M)
            if not m:
                continue
            init = _scan_initializer(text, m.end())
            if init is None:
                # The declaration is here but its initializer spans lines. `git grep` handed
                # back one line; read the blob and continue the scan from the same offset.
                if path not in blobs:
                    blobs[path] = _git(clone, "show", f"{sha}:{path}")
                blob = blobs[path]
                if not blob:
                    continue
                lines = blob.split("\n")
                k = int(lineno) - 1
                if not (0 <= k < len(lines)):
                    continue
                off = sum(len(x) + 1 for x in lines[:k])
                m2 = re.search(head, blob[off:], re.M)
                if not m2 or m2.start() > len(lines[k]):
                    continue          # a different declaration further down the file
                init = _scan_initializer(blob, off + m2.end())
            if init is not None:
                break
        if init is None:
            continue
        if re.fullmatch(r"[\w.]+", init) and not re.fullmatch(r"-?[\d.]+", init):
            continue  # bare identifier: needs closure this pass does not do
        if any(bad in init for bad in ("Random", "DateTime.now", "await ", "()..")):
            continue  # non-deterministic, forbidden by the fixture doctrine
        return init, f"{path}@{sha[:8]}"
    return None


def _split_generics(inner: str) -> list[str]:
    """Split a generic argument list on TOP-LEVEL commas only.

    `MAPPY` matches by prefix and the old map branch sliced `t[4:-1]` without splitting at all,
    so a two-argument map was never taken apart. A plain `split(",")` is not enough either: the
    value type is routinely itself generic (`Map<String, List<Conversation>>`), and splitting
    inside its brackets yields two halves that are not types.
    """
    parts: list[str] = []
    depth = 0
    buf: list[str] = []
    for ch in inner:
        if ch == "<":
            depth += 1
        elif ch == ">":
            depth -= 1
        if ch == "," and depth == 0:
            parts.append("".join(buf).strip())
            buf = []
        else:
            buf.append(ch)
    parts.append("".join(buf).strip())
    return [p for p in parts if p]


def _map_keys(key_type: str, card: int) -> list[str] | None:
    """`card` DISTINCT key literals, or None when the key type is not one we can enumerate.

    Returning None (-> `none`, reported) rather than inventing keys for an arbitrary type is
    the protocol's rule: unrecoverable values are reported, never guessed.
    """
    t = key_type.strip().rstrip("?")
    if t == "String":
        return [f"'k{i}'" for i in range(card)]
    if t == "int":
        return [str(i) for i in range(card)]
    return None


def _collection_expr(kind: str, elem: str, e: str, card: int) -> str:
    """The committed shape for a `List`/`Set` literal, shared by the top-level branch and the
    recursive element resolver so both emit identical code.

    `Set` deliberately keeps its value-equal collapse: `{e, e, e}` is one element for any
    value-equal type, so the declared N = 3 is not delivered for sets. Making a set hold three
    DISTINCT primitives means inventing values, which is a rule decision rather than a bug fix.
    Recorded as a limitation; the only set in this corpus feeds `contains()` on fixed chips.
    """
    if kind == "Set":
        return f"<{elem}>{{{', '.join([e] * card)}}}"
    return f"List<{elem}>.generate({card}, (_) => {e})"


def _map_expr(t: str, elem_expr, card: int) -> str | None:
    """`Map<K, V>` -> a literal with `card` distinct keys, or None.

    The empty map this replaces was noted "keys are identity, not cardinality". That is wrong
    exactly when the keys drive an `itemCount`: `0792` shipped `<String, List<Conversation>>{}`,
    rendered nothing, and carried 34 contrasts. The value-fill protocol 3.4
    already declared N = 3 and N > 0 corpus-wide, so this branch was never implementing the
    declared rule.
    """
    try:
        inner = t[t.index("<") + 1 : t.rindex(">")]
    except ValueError:
        return None
    args = _split_generics(inner)
    if len(args) != 2:
        return None
    key_t, val_t = args
    keys = _map_keys(key_t, card)
    if keys is None:
        return None
    ve = elem_expr(val_t)
    if ve is None:
        return None
    body = ", ".join(f"{k}: {ve}" for k in keys)
    return f"<{key_t}, {val_t}>{{{body}}}"


def resolve(decl: str, policy: dict, standins: dict[str, str], clone, sha,
            classes: set[str] | None = None) -> dict:
    """One slot -> {expr, origin, rule, rule_id, note}.

    `standins` and `classes` are `declared_types()`'s two returns: the enums this may stand in
    for, and the class names it deliberately will not. Since 2026-09-08 the generated layer
    emits only what the protocol FORCES -- the render-maximising arm of a gating condition
    (`maximal_branch`), a collection's cardinality, and inert leaf scalars. Every value that is
    a CHOICE is authored under `config/authored_fixtures/`.
    """
    card = policy["cardinality"]
    types = policy["types"]
    unrecoverable = policy["unrecoverable"]
    out_of_scope = policy["out_of_scope"]
    route_rules = policy["unrecoverable_rules"]
    classes = classes or set()

    def refuse(rule_id: str, note: str | None = None) -> dict:
        """A `none` entry carrying the id a verdict keys on.

        `rule_id` is stable and is what `_declared_unrecoverable` classifies R16 on; `note` is
        the sentence a reader sees and may be reworded freely. Before 2026-09-05 there was no
        id and the classification compared the note against the policy's prose by string
        identity, so an editorial reword silently changed a verdict.
        """
        return {"expr": None, "origin": "none", "rule": "unrecoverable", "rule_id": rule_id,
                "note": route_rules[rule_id] if note is None else note}

    def refuse_type(t: str) -> dict:
        """A `none` entry for a declaration whose type this will not stand in for.

        Declared when the refusal is one the policy NAMES -- `unrecoverable` for what Dart
        cannot build above the element tree, `out_of_scope` for what the table declines to
        fabricate, `class_standin_authored` for a class the transplant declares -- and
        UNDECLARED otherwise, which is the loud case: a type named nowhere means the policy is
        short, not that the group deserves to go, and the `--from-nothing` gate refuses on it.
        """
        t = t.strip().rstrip("?")
        # A function type is a closure whatever its signature, and the policy names `Function`
        # out of scope. The lookup below is exact, so `Function(double)` and
        # `bool Function(CardBean)` used to miss it and refuse UNDECLARED -- the same refusal
        # the policy had already made, reported as a hole in the policy. Normalise first.
        if FUNCTION_TYPE.search(t):
            t = "Function"
        # A collection refuses for its ELEMENT's reason, never its own. `List<DateTime>` is not
        # a type any block names, and reporting it as one sends the reader looking for a
        # `List<DateTime>` entry rather than at `DateTime`, which the policy does name. The
        # typed-initialiser branch already decomposed; the `late` branch did not, so a bare
        # `late List<DateTime> x;` refused UNDECLARED while `List<DateTime> x = ...;` did not.
        c = COLLECTION.match(t)
        if c:
            return refuse_type(c.group("elem"))
        if MAPPY.match(t):
            args = _split_generics(t[t.index("<") + 1:t.rindex(">")]) if "<" in t else []
            if len(args) == 2:
                return refuse_type(args[1])
        for block in (unrecoverable, out_of_scope):
            if t in block:
                return refuse(block[t]["id"], block[t]["reason"])
        if t in classes:
            return refuse("class_standin_authored",
                          f"`{t}` is a class declared in the transplant; constructing one has "
                          f"cost, which is what this study measures")
        return {"expr": None, "origin": "none", "rule": "unrecoverable",
                "note": f"no policy entry and no stand-in class for `{t}`"}

    def elem_expr(t: str) -> str | None:
        """An expression for `t`, or None.

        Recursive: a collection's element type may itself be a collection or a map. Flat
        lookups reported those unconstructible, which is why `List<Conversation>` inside a map
        fell through to `none`.
        """
        t = t.strip().rstrip("?")
        if t in types:
            return dart_literal(types[t])
        if t in standins:
            return standins[t]
        c = COLLECTION.match(t)
        if c:
            e = elem_expr(c.group("elem"))
            return None if e is None else _collection_expr(
                c.group("kind"), c.group("elem"), e, card)
        if MAPPY.match(t):
            return _map_expr(t, elem_expr, card)
        return None

    m = CONST_STANDIN.match(decl)
    if m:
        name = m.group("name")
        if clone and sha:
            got = recover_literal(clone, sha, name)
            if got:
                return {"expr": got[0], "origin": "recovered", "rule": "upstream_literal",
                        "source": got[1]}
        # Recovery failed. It used to default to `types["Color"]`, on the ground that const
        # stand-ins are dominated by colours -- which meant the documented way recovery fails,
        # a missing blobless clone, produced a plausible value and no error anywhere. A const
        # declaration takes no primitive stand-in, so this refuses instead. 3.3: reported,
        # never guessed.
        return refuse("const_standin_unrecovered")

    m = LATE.match(decl)
    if m:
        t = m.group("type").strip()
        if t.rstrip("?") in unrecoverable:
            return refuse_type(t)
        e = elem_expr(t)
        if e:
            return {"expr": e, "origin": "default", "rule": "protocol_constant"}
        return refuse_type(t)

    m = TYPED.match(decl)
    if m:
        t, init = m.group("type").strip(), m.group("init").strip()
        if init == "null":
            return {"expr": "null", "origin": "default", "rule": "protocol_constant",
                    "note": "nullable kept null: flipping it changes which branch build takes"}
        c = COLLECTION.match(t)
        if c:
            e = elem_expr(c.group("elem"))
            if e is None:
                return refuse_type(c.group("elem"))
            return {"expr": _collection_expr(c.group("kind"), c.group("elem"), e, card),
                    "origin": "default", "rule": "protocol_constant"}
        if MAPPY.match(t):
            e = _map_expr(t, elem_expr, card)
            if e is None:
                # Either the key type is not enumerable or the value type has no constructor.
                # Ask the value type first, since that is the case the policy can name; a key
                # type it cannot enumerate is a gap, and stays undeclared and loud.
                args = _split_generics(t[t.index("<") + 1:t.rindex(">")]) if "<" in t else []
                if len(args) == 2:
                    inner = refuse_type(args[1])
                    if inner.get("rule_id"):
                        return inner
                return {"expr": None, "origin": "none", "rule": "unrecoverable",
                        "note": f"no enumerable key type or no value constructor for `{t}`"}
            return {"expr": e, "origin": "default", "rule": "protocol_constant",
                    "note": f"{card} distinct keys: an empty map renders nothing wherever the "
                            "keys drive an itemCount"}
        if t.rstrip("?") in unrecoverable:
            return refuse_type(t)
        e = elem_expr(t)
        if e:
            return {"expr": e, "origin": "default", "rule": "protocol_constant"}
        # A parsed declaration whose type resolves to nothing. It used to fall through to the
        # unparsed-declaration return below, which named the wrong failure and left the
        # exclusion undeclared even when the policy did name the type; nothing reached it while
        # the table carried an entry for every object type, and the 2026-09-05 trim exposed it.
        return refuse_type(t)
    # Genuinely unparsed: not a `late`, not a const stand-in, not a typed initialiser. This is
    # a gap in the patterns above, so it stays UNDECLARED on purpose -- a bug to fix, never a
    # refusal the policy sanctions.
    return {"expr": None, "origin": "none", "rule": "unrecoverable",
            "note": f"unparsed declaration: {decl}"}


CLASS_BLOCK = re.compile(r"^(?:abstract\s+|final\s+|sealed\s+|base\s+)*class\s+(\w+)", re.M)
ENUM_BLOCK = re.compile(r"^enum\s+(\w+)", re.M)
# `Function`, `Function(double)`, `void Function(bool, CardBean)`, `bool Function(X)`: every
# spelling of a closure type. `refuse_type` normalises to `Function`, which the policy names.
FUNCTION_TYPE = re.compile(r"\bFunction\b")


def _class_body(text: str, start: int) -> str:
    """The braced body of the class beginning at `start`, by brace matching."""
    i = text.find("{", start)
    if i < 0:
        return ""
    depth, j = 0, i
    while j < len(text):
        if text[j] == "{":
            depth += 1
        elif text[j] == "}":
            depth -= 1
            if depth == 0:
                return text[i + 1:j]
        j += 1
    return text[i + 1:]


def declared_types(texts: list[str]) -> tuple[dict[str, str], set[str]]:
    """`(enum stand-ins, class names)` for the types declared in the staged unit.

    The fixture is `part of generated_widget`, so a type declared in the transplant shares the
    library namespace with the fixture: element types are routinely declared in the `rev_*` file
    rather than in `dependencies.dart`. Scanning the fixture alone misses them.

    UNTIL 2026-09-08 THIS BUILT A CONSTRUCTOR CALL FOR EVERY CLASS IT FOUND, and that is how
    `Translations.build()`, `CardBean()` and `AppInfo(name: '', packageName: '')` reached the
    compiler as fixture values. A stand-in whose CONSTRUCTION has cost is a confound in a study
    that measures what building a subtree costs -- the same objection the 2026-09-05
    primitives-only trim raised against `ThemeData()` and `TextEditingController()`. That trim
    closed the authored door, the policy's `types` table, and left this derived one wide open.
    A class-typed binding is now an authored slot.

    An enum stays, and is the one thing here that is genuinely inert: a `const` instance, no
    allocation, and its legal values are readable from the source rather than invented. The
    first declared value is taken. An enum that GATES a branch never reaches this table --
    `maximal_branch.decide()` claims it under "enum equality" and picks the arm that renders
    more -- so a gating value obeys one rule whatever type it wears.

    The class names come back so `refuse_type` can report `class_standin_authored`, a refusal
    the policy NAMES. Without them a class would land in the undeclared "no policy entry and no
    stand-in class" branch, and the `--from-nothing` gate could no longer tell a deliberate
    hand-off to the author from a typo that emptied the table.
    """
    enums: dict[str, str] = {}
    classes: set[str] = set()
    for text in texts:
        for m in CLASS_BLOCK.finditer(text):
            cls = m.group(1)
            if not cls.startswith("_"):
                classes.add(cls)
        for m in ENUM_BLOCK.finditer(text):
            name = m.group(1)
            if name in enums or name.startswith("_"):
                continue
            # `enum X { a, b, c }` and the enhanced form `enum X { a, b; const X(); }` alike:
            # the constant list is everything up to the first `;` in the body, and a constant
            # may carry an argument list (`a(1)`), so take the identifier that begins each.
            body = _class_body(text, m.end()).split(";")[0]
            values = [v for v in (p.strip() for p in _split_generics(body)) if v]
            first = re.match(r"(\w+)", values[0]) if values else None
            if first:
                enums[name] = f"{name}.{first.group(1)}"
    return enums, classes


def build(root: Path, groups: list[str] | None = None) -> dict:
    policy = load_policy()
    id_map = jsonio.read_json(root / "id_map.json", {})
    by_group = {v: k for k, v in id_map.items()} if isinstance(id_map, dict) else {}

    out: dict[str, dict] = {}
    dirs = [root / g for g in groups] if groups else sorted(d for d in root.iterdir() if d.is_dir())
    for d in dirs:
        fixture = d / "dependencies.dart"
        if not fixture.exists():
            continue
        text = fixture.read_text(encoding="utf-8", errors="replace")
        slots = fixture_gate.unfilled_slots(text)
        if not slots:
            continue
        key = by_group.get(d.name, "")
        # `id_map` keys are `owner/repo::path::Node::Class::idx` -- the repo token is the whole
        # of the first field. An earlier `.split("-", 1)[-1]` here truncated at the first hyphen,
        # so every hyphenated owner or name (`moss-apps/Flick` -> `apps/Flick`,
        # `traccar/traccar-client` -> `client`) resolved to no clone at all: 13 of the 51
        # eligible groups silently skipped `upstream_literal` recovery and took the default.
        owner_repo = key.split("::")[0] if key else ""
        clone = clone_for(owner_repo) if owner_repo else None
        sha = anchor_sha(d)
        unit = [text] + [f.read_text(encoding="utf-8", errors="replace")
                         for f in sorted(d.glob("rev_*.dart"))]
        standins, classes = declared_types(unit)

        entries = {}
        for slot in slots:
            m = DECL.match(slot)
            decl = (m.group("decl") if m else slot).strip()
            name_m = re.search(r"\b(\w+)\s*(?:=|;)", decl)
            name = name_m.group(1) if name_m else decl
            entries[name] = {"decl": decl,
                             **resolve(decl, policy, standins, clone, sha, classes)}
        out[d.name] = {"anchor": sha, "repo": owner_repo, "bindings": entries}
    return out


def reresolve(root: Path, table: dict, groups: list[str] | None) -> dict[str, dict]:
    """Re-run the hierarchy over ALREADY-STORED entries and return only what moved.

    `build()` visits a group only while its fixture still carries an unfilled slot, which is
    right for filling and wrong for correcting: a fix to the hierarchy can never reach a group
    that was filled under the old one, and the stale value is frozen in both the table and the
    corpus. Every stored binding keeps the `decl` the split produced, so resolution can simply
    be run again against it.

    Returns `{group: {name: entry}}` for bindings whose expression changed. Reporting the drift
    is the point: a value that moves under a corrected rule is exactly what an audit needs to
    see, and applying it is a separate decision.
    """
    policy = load_policy()
    id_map = jsonio.read_json(root / "id_map.json", {})
    by_group = {v: k for k, v in id_map.items()} if isinstance(id_map, dict) else {}

    drift: dict[str, dict] = {}
    for gid in sorted(groups or table):
        entry = table.get(gid)
        d = root / gid
        if not entry or not d.is_dir():
            continue
        key = by_group.get(gid, "")
        owner_repo = key.split("::")[0] if key else ""
        clone = clone_for(owner_repo) if owner_repo else None
        sha = anchor_sha(d)
        unit = [(d / "dependencies.dart").read_text(encoding="utf-8", errors="replace")]
        unit += [f.read_text(encoding="utf-8", errors="replace") for f in sorted(d.glob("rev_*.dart"))]
        standins, classes = declared_types(unit)

        for name, was in entry["bindings"].items():
            decl = was.get("decl")
            if not decl:
                continue
            now = {"decl": decl, **resolve(decl, policy, standins, clone, sha, classes)}
            if now.get("expr") != was.get("expr"):
                drift.setdefault(gid, {})[name] = {"was": was, "now": now}
    return drift


def rewrite_filled(text: str, fixes: dict) -> tuple[str, int]:
    """Replace an already-substituted declaration with the one the corrected value gives.

    `apply_to_fixture` keys off the `// TODO: value` stamp, which a filled line no longer has.
    This keys off the binding name instead and rebuilds the line from the stored `decl`, so the
    result is byte-identical to what a regeneration from the corrected table would emit.
    """
    lines = text.splitlines()
    body_start = len(lines) - len(fixture_gate.fixture_body(text).splitlines())
    changed = 0
    for i in range(body_start, len(lines)):
        stripped = lines[i].strip()
        if not stripped or stripped.startswith("//"):
            continue
        name_m = re.search(r"\b(\w+)\s*(?:=|;)", lines[i].split("//")[0])
        if not name_m:
            continue
        fix = fixes.get(name_m.group(1))
        if not fix or fix["now"].get("expr") is None:
            continue
        rebuilt = fixture_skeleton.apply_value(fix["now"]["decl"], fix["now"])
        if rebuilt is not None and rebuilt != lines[i]:
            lines[i] = rebuilt
            changed += 1
    return "\n".join(lines) + "\n", changed


def apply_to_fixture(text: str, entries: dict) -> tuple[str, int]:
    """Substitute resolved values for their TODO stamps. Unresolved slots keep the stamp,
    so the gate still refuses the group and nothing silently reaches the device."""
    lines = text.splitlines()
    body_start = len(lines) - len(fixture_gate.fixture_body(text).splitlines())
    filled = 0
    for i in range(body_start, len(lines)):
        if fixture_gate.TODO_MARKER not in lines[i]:
            continue
        decl = lines[i].split("//")[0].rstrip()
        name_m = re.search(r"\b(\w+)\s*(?:=|;)", decl)
        if not name_m:
            continue
        e = entries.get(name_m.group(1))
        if not e or e.get("expr") is None:
            continue
        filled_decl = fixture_skeleton.apply_value(decl, e)
        if filled_decl is not None:
            lines[i] = filled_decl
            filled += 1
    return "\n".join(lines) + "\n", filled


def main() -> None:
    ap = argparse.ArgumentParser(description="Resolve fixture TODO slots into a committed table.")
    ap.add_argument("--root", default="new_samples")
    ap.add_argument("--group", action="append", help="Limit to these groups (repeatable).")
    ap.add_argument("--eligible-only", action="store_true",
                    help="Only groups carrying an eligible pair, per exclusions.json.")
    ap.add_argument("--apply", action="store_true", help="Write filled fixtures + provenance.")
    ap.add_argument("--report", action="store_true", help="Print the coverage table.")
    ap.add_argument("--reresolve", action="store_true",
                    help="Re-run the hierarchy over already-stored values and report what moves. "
                         "Needed after any correction to resolution: a filled group is invisible "
                         "to the fill pass, so a fix cannot otherwise reach it.")
    ap.add_argument("--init", action="store_true",
                    help="Seed an EMPTY values table for a from-scratch rebuild, then exit. "
                         "Refuses if the table already exists. Changes values_version(), which "
                         "invalidates every screening checkpoint -- which is why it is a flag "
                         "and never a side effect.")
    args = ap.parse_args()

    # Before anything reads the table: --init is the only path that may run without one.
    if args.init:
        digest = init_values_table()          # refuses, and prints nothing, if one exists
        print(f"seeded            : {_rel(VALUES_PATH)} (empty)")
        print(f"values_version    : {digest}")
        print("next              : run the screen, then re-run this with "
              "--eligible-only --apply, then screen again")
        return
    run(ROOT / args.root, groups=args.group, eligible_only=args.eligible_only,
        apply=args.apply, report=args.report, reresolve_stored=args.reresolve)


def run(root: Path, *, groups: list[str] | None = None, eligible_only: bool = False,
        apply: bool = False, report: bool = False, reresolve_stored: bool = False) -> dict:
    """The fill pass, callable without argparse. `main()` and `screen_samples --full` share it.

    `reresolve_stored` is `--reresolve`; it is not spelled `reresolve` because that is the
    module-level function this calls, and shadowing it here would be a silent recursion.

    Returns the counts it prints, so a caller that is one phase of a longer run can report
    them in its own summary rather than only on stdout.
    """
    # Refused on a corpus pruned to measured endpoints: `anchor_sha()` and `declared_types()`
    # below both read the roles off disk, so they would resolve against a narrower union
    # than the stored values were resolved against. See `fixture_skeleton.PRUNED_NAME`.
    fixture_skeleton.refuse_if_pruned(root, "fixture_values")
    if eligible_only:
        ex = jsonio.require_json(root / "exclusions.json", "fixture_values --eligible-only")
        groups = sorted({p["group"] for p in ex["pairs"] if p["verdict"] == "eligible"})

    table = build(root, groups)
    # MERGE, never replace. `build()` only sees groups that still carry an unfilled slot, so a
    # second run over an already-filled corpus legitimately returns almost nothing. Writing that
    # straight out would discard every value the first run resolved -- the table is the durable
    # artifact and the corpus is derived from it, not the other way round.
    if VALUES_PATH.is_file():
        merged = load()
        for gid, entry in table.items():
            merged.setdefault(gid, {"anchor": entry["anchor"], "repo": entry["repo"],
                                    "bindings": {}})
            merged[gid]["bindings"].update(entry["bindings"])
        table = merged
    # AUTHORED FIXTURES ARE NOT OURS TO TOUCH. `place()` already refuses to overwrite a fixture
    # whose hash has left the index -- that is what lets values be filled in by hand while the
    # mine and the screen keep running. Both write paths below used to ignore that. The index
    # refresh re-digested EVERY group, including files this pass never wrote, handing a
    # hand-edited fixture back as `generated` so the next export overwrote it silently, far
    # from the run that caused it; `1777`'s `fixtureShowAllApps` went that way. The drift pass
    # is worse -- it rewrites the CONTENT of a fixture whose stored value moved. Classified
    # here, before either can run, because the write is what would destroy the evidence.
    # No index at all means no export has run and nothing can be classified, so keep the
    # historical behaviour there and treat every group as this pipeline's own.
    index_path = root / fixture_skeleton.INDEX_NAME
    index = fixture_skeleton.load_index(root) if index_path.is_file() else None
    authored = sorted(
        gid for gid in table
        if index is not None
        and (root / gid / "dependencies.dart").is_file()
        and not fixture_skeleton.is_generated(root, gid, index))
    hands_off = set(authored)
    drift = reresolve(root, table, groups) if reresolve_stored else {}
    if drift:
        n_drift = sum(len(v) for v in drift.values())
        print(f"drift             : {n_drift} stored value(s) move under the current hierarchy")
        for gid in sorted(drift):
            for name, f in sorted(drift[gid].items()):
                was, now = str(f["was"]["expr"]), str(f["now"]["expr"])
                src = f["now"].get("source") or f["now"].get("note", "")
                print(f"  [{gid}] {name:<24} {was[:28]:<30} -> {now[:28]:<30} {src[:38]}")
        if apply:
            for gid, fixes in drift.items():
                for name, f in fixes.items():
                    table[gid]["bindings"][name] = f["now"]
                path = root / gid / "dependencies.dart"
                if not path.is_file() or gid in hands_off:
                    continue        # in the table, not in this corpus; see the apply loop
                new, n = rewrite_filled(path.read_text(encoding="utf-8", errors="replace"), fixes)
                if n:
                    path.write_text(new, encoding="utf-8")
        else:
            print("                    (not written; re-run with --apply)")

    VALUES_PATH.write_text(json.dumps(table, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    from collections import Counter
    origins = Counter(e["origin"] for g in table.values() for e in g["bindings"].values())
    rules = Counter(e["rule"] for g in table.values() for e in g["bindings"].values())
    total = sum(origins.values())
    print(f"groups with slots : {len(table)}")
    print(f"slots resolved    : {total}")
    for k in ("recovered", "default", "none"):
        print(f"  origin {k:<10}: {origins.get(k, 0)}")
    print(f"  rules           : {dict(rules)}")
    print(f"values_version    : {values_version()}")

    if report:
        for gid in sorted(table):
            for name, e in sorted(table[gid]["bindings"].items()):
                src = e.get("source") or e.get("note", "")
                print(f"  [{gid}] {name:<28} {e['origin']:<10} {str(e['expr'])[:44]:<46} {src[:44]}")

    applied = 0
    if apply:
        # Only groups this corpus actually HAS. The table is the durable artifact and the
        # corpus is derived from it, so it legitimately outlives a group the export dropped:
        # `0607` is hand-excluded and has no directory, and iterating the table blind died on
        # its missing fixture. Skipped rather than pruned from the table -- removing the
        # entry would lose the resolution, and putting the group back must not require
        # re-deriving it (see `--reresolve`, and `config/README.md` on quiet degradation).
        absent = sorted(gid for gid in table if not (root / gid / "dependencies.dart").is_file())
        if absent:
            print(f"not at {_rel(root)}    : {len(absent)} table group(s) this corpus does "
                  f"not ship ({', '.join(absent[:10])}); their stored values are kept")
        if authored:
            print(f"authored, skipped : {len(authored)} group(s) edited by hand "
                  f"({', '.join(authored[:10])}); their fixture, provenance and index "
                  f"entry are left exactly as they are")
        for gid, g in table.items():
            f = root / gid / "dependencies.dart"
            if not f.is_file() or gid in hands_off:
                continue
            new, n = apply_to_fixture(f.read_text(encoding="utf-8", errors="replace"), g["bindings"])
            if n:
                f.write_text(new, encoding="utf-8")
                applied += n
            # MERGE, never overwrite. This table owns the `// TODO: value` slots and nothing
            # else, but the provenance file is shared: the maximal-branch rule records its own
            # bindings here from `config/maximal_branch.json`. A wholesale rewrite silently
            # deleted them -- `1777`'s `fixtureShowAllApps` override vanished on an unrelated
            # `--apply` -- leaving the fixture claiming an override its provenance no longer
            # documents. Entries this table owns still win; foreign ones are carried through.
            prov_path = root / gid / fixture_skeleton.PROVENANCE_NAME
            bindings = dict(g["bindings"])
            if prov_path.is_file():
                was = (jsonio.read_json(prov_path, {}) or {}).get("bindings", {})
                bindings = {**was, **bindings}
            prov_path.write_text(
                json.dumps({"anchor": g["anchor"], "repo": g["repo"],
                            "values_version": values_version(),
                            "bindings": bindings}, indent=2, sort_keys=True) + "\n",
                encoding="utf-8")
        # Refresh the generated-fixture index. A filled fixture is still this pipeline's own
        # output -- it is `skeleton(mine) + values(table)` -- so it must keep reading as
        # generated. Left stale, `place()` would classify every filled group as `authored` and
        # refuse to regenerate it, which is the opposite of the reproducibility this buys.
        # Through `fixture_skeleton`, which owns this file: the hand-rolled read/write that
        # used to sit here wrote `indent=2` where `save_index` writes `indent=0`, so the same
        # index came out with different bytes depending on which tool touched it last.
        if index is not None:                   # absent means no export has run; do not seed one
            refreshed = 0
            for gid in table:
                if gid in hands_off:            # never re-index a file a human owns
                    continue
                f = root / gid / "dependencies.dart"
                if f.is_file():
                    with open(f, encoding="utf-8", newline="") as fh:
                        index[gid] = fixture_skeleton.digest(fh.read())
                    refreshed += 1
            fixture_skeleton.save_index(root, index)
            print(f"index refreshed   : {refreshed} group(s) in {index_path.name}")
        print(f"applied           : {applied} value(s) written into fixtures")
    return {"groups": len(table), "slots": total, "origins": dict(origins),
            "applied": applied, "values_version": values_version()}


if __name__ == "__main__":
    main()
