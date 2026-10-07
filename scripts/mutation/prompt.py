"""Mutation prompt assembly for the PDP dataset.

A mutation varies ONLY the widget-tree structure of a clean ``State<GeneratedWidget>``
while keeping the external interface and all inputs byte-identical to the base, so the
measured buildSpan delta is attributable solely to the structural change.

Prompt strategy is configurable (``zero_shot`` / ``few_shot`` / ``cot`` / ``cot_fewshot``)
so the best strategy for the deployed model can be chosen *empirically* (acceptance,
uniqueness, and equivalent-mutant rates) rather than assumed — LLM prompt effectiveness is
model- and task-dependent. The default ``cot_fewshot`` reflects the literature's most
balanced strategy for code transformation.
"""

SYSTEM_CORE = """\
You are a Flutter code transformer for a performance-prediction dataset. You produce a
single behaviour-preserving, STRUCTURE-ONLY mutation of a Flutter State class. The
mutation must be the SAME widget/screen as the base - it shows the same content from the
same inputs - but BUILT DIFFERENTLY. The measured cost difference must be attributable
solely to the structural change.

THREE THINGS THAT MUST HOLD (each is checked automatically; violations are rejected):
1. SAME INPUTS & DEPENDENCIES. Reproduce the imports, every State field declaration, and
   the initState / didUpdateWidget / dispose bodies BYTE-FOR-BYTE from the base.
   dependencies.dart is FROZEN and imported as-is: use only the symbols it already
   exports.
2. SAME CONTENT (the same widget). The mutated tree must display the SAME data and the
   SAME leaf widgets as the base: the same Text strings, the same icons, the same number
   of data-driven items, the same callbacks. You change HOW the tree is assembled while
   keeping WHAT it renders identical; every string, icon, and data item in your output
   must already appear in the base. EXCEPTION: when the transformation directive
   explicitly asks you to REPEAT existing content (e.g. duplicate existing siblings), you
   may repeat leaf widgets or subtrees that already appear in the base - still drawing only
   on content the base already renders.
3. REAL STRUCTURAL CHANGE. Apply the requested transformation so the widget-tree structure
   differs from the base: the extracted feature vector of your output must differ from the
   base's. A tree left unchanged, or edited only in formatting or comments, is rejected as
   an equivalent mutant.

YOU MAY CHANGE (structure only): the widget tree returned by build(); widget-returning
helper methods/functions; the build() methods of the custom child-widget classes in this
file; widget count, nesting depth, const-ness, helper-vs-extracted-widget choices,
eager-list-vs-.builder, and conditional/iteration structure. Apply exactly the one
transformation named in the directive below and leave every other structural dimension as
it is in the base (off-target changes are rejected). Make the change the way a real Flutter
developer would: a natural structural realisation of the directive. Structure contrived
only to move a feature number, rather than something a developer would plausibly write, is
rejected.

HARD CONSTRAINTS: draw every symbol from the imported dependencies.dart or the Flutter SDK
(package:flutter/...); keep build() a pure function of the existing state and fixtures; the
result must compile against the unmodified dependencies.dart. Forbidden inside build():
adding a new input, I/O, network, async / await, DateTime.now(), or Random().
"""

# Structured chain-of-thought: reason about the transformation in terms of the widget
# tree before emitting code (structured CoT outperforms free-form CoT for code tasks).
COT_PROCEDURE = """\
PROCEDURE (reason first, then code):
- In 2-4 short sentences, (a) name the leaf content you must keep unchanged (the Text
  strings / icons / data items), (b) describe the structural change you will apply to the
  widget tree and name the static feature(s) it moves (e.g. buildMaxWidgetNestingDepth
  UP), and (c) confirm imports, fields, and initState/dispose are copied verbatim.
- Then output the COMPLETE mutated base.dart inside a single ```dart ... ``` code block.
Output nothing after the code block.
"""

OUTPUT_DIRECT = """\
OUTPUT: the COMPLETE mutated base.dart inside a single ```dart ... ``` code block, and
nothing else.
"""

# Compact few-shot illustration: a structure-only change with verbatim initState/fields
# and identical rendered content, tied to a feature it moves (here, nesting depth).
FEWSHOT = """\
EXAMPLE (illustration only - apply the same discipline to the real file):

Base build():
    Widget build(BuildContext context) =>
        Column(children: [Text(title), Text(subtitle)]);

A VALID "nest_deeper" mutation (same leaf content Text(title)/Text(subtitle); deeper
structure raises buildMaxWidgetNestingDepth; initState/fields/imports untouched):
    Widget build(BuildContext context) => Padding(
          padding: const EdgeInsets.all(0),
          child: Column(children: [
            Padding(padding: const EdgeInsets.all(0), child: Text(title)),
            Padding(padding: const EdgeInsets.all(0), child: Text(subtitle)),
          ]),
        );

INVALID (rejected): changing a field/initState value; importing a new package; replacing
Text(title)/Text(subtitle) with different/new content; or returning the base tree
unchanged or with only formatting/comment edits (an equivalent mutant - the extracted
features must differ from the base).
"""

USER_TEMPLATE = """\
{fewshot}BASE FILE (base.dart):
---
{base_dart}
---

DEPENDENCIES (dependencies.dart) - READ-ONLY, do not modify, only use its symbols:
---
{dependencies_dart}
---

TRANSFORMATION TO APPLY:
{directive}

{closing}
"""

STRATEGIES = ("zero_shot", "few_shot", "cot", "cot_fewshot")

# Directed transformations spanning the 11 features, each with an expected cost
# direction (useful metadata for auditing the Faster/Slower labels).
DIRECTIVES: list[dict] = [
    {
        "key": "nest_deeper",
        "expect": "slower",
        "text": "Increase nesting depth by wrapping the existing leaf widgets in 2-3 "
        "additional Padding/Column/Container layers. Keep the same leaves and the same data.",
    },
    {
        "key": "all_const",
        "expect": "faster",
        "text": "Make every widget that can be const a const (including the root), without "
        "changing the rendered tree or any value.",
    },
    {
        "key": "drop_const",
        "expect": "slower",
        "text": "Remove const from all widget constructors, without changing the rendered tree.",
    },
    {
        "key": "eager_list",
        "expect": "slower",
        "text": "Replace any ListView.builder/GridView.builder with an eager Column/Wrap that "
        "maps the same list to children.",
    },
    {
        "key": "extract_widgets",
        "expect": "faster",
        "text": "Extract each inline subtree into a separate StatelessWidget (const where "
        "possible) instead of helper methods.",
    },
    {
        "key": "inline_helpers",
        "expect": "neutral",
        "text": "Inline all widget-returning helper methods/functions directly into build().",
    },
    {
        "key": "add_siblings",
        "expect": "slower",
        "text": "Add 3-5 sibling widgets of the same kind to the main list/column, reusing the "
        "same data already available.",
    },
    {
        "key": "layout_builder",
        "expect": "slower",
        "text": "Wrap the returned tree in a LayoutBuilder, keeping the same children.",
    },
]


def build_prompt(
    base_dart: str,
    dependencies_dart: str,
    directive: str,
    strategy: str = "cot_fewshot",
) -> str:
    """Single combined prompt string (system + user) for CLI backends that take one prompt."""
    m = build_messages(base_dart, dependencies_dart, directive, strategy)
    return m[0]["content"] + "\n\n" + m[1]["content"]


def build_messages(
    base_dart: str,
    dependencies_dart: str,
    directive: str,
    strategy: str = "cot_fewshot",
) -> list[dict]:
    assert strategy in STRATEGIES, f"strategy must be one of {STRATEGIES}"
    use_cot = "cot" in strategy
    use_fewshot = "few" in strategy or strategy == "cot_fewshot"
    system = SYSTEM_CORE + "\n" + (COT_PROCEDURE if use_cot else OUTPUT_DIRECT)
    closing = (
        "Reason first as instructed, then output the mutated base.dart in a single "
        "```dart code block."
        if use_cot
        else "Output the mutated base.dart in a single ```dart code block."
    )
    user = USER_TEMPLATE.format(
        fewshot=(FEWSHOT + "\n\n") if use_fewshot else "",
        base_dart=base_dart,
        dependencies_dart=dependencies_dart,
        directive=directive,
        closing=closing,
    )
    return [{"role": "system", "content": system}, {"role": "user", "content": user}]
