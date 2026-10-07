"""The rule table: every id, its prose, where it came from, and which of them are soft.

Only the ids and the reasons live here. The MATCHING lives in `scripts/dart_tools` --
`lib/src/rules.dart` holds the vocabulary and `lib/src/facts.dart` the AST pass that feeds
it -- because a rule has to be evaluated over a parsed program and this side never parses
one. What this module owns is the vocabulary the REPORT speaks: the ids, the human reasons
the appendix table prints, and the hard/soft partition that `--strict` moves.

WHERE EACH RULE COMES FROM
--------------------------
R1  animation      stage 1b. Core rebuild driven by animation. Also the round-1 rule that
                   removed old seeds 17/19/25/27/28: an indeterminate progress indicator
                   kept MOUNTED animates forever, so `pumpAndSettle` never settles.
R2  async          stage 1b. Core rebuild driven by async/await or a Stream/Future builder.
R3  io_network     stage 1b. I/O- or network-driven rebuild.
R4  keepalive      stage 1b. Scrolling / keep-alive lifecycle mixins tie the unit to lazy
                   list and RenderSliver mechanics.
R5  nested_app     round 2 (units 09, 31). The transplanted scope must not contain
                   MaterialApp / WidgetsApp / CupertinoApp: the harness supplies one, and a
                   nested root puts framework re-initialisation inside the measured span.
R6  nondeterminism stage 4. `DateTime.now()` / `Random()` were REPAIRED to fixed values in
                   the original corpus. That repair is not available here -- editing a
                   transplant would make it stop being the code the commit contained -- so
                   what was a repair there is an exclusion here.
R7  duplicate      stage 1c. Each retained sample must be a distinct widget-tree structure.
R8  no_pair        NOT a measurability rule -- a YIELD rule, and the only one here. A group
                   needs two distinct transplanted states to yield a delta, and `mine`
                   writes a `rev_*.dart` only when the transplant CHANGED. Such a group is
                   measurable and simply has nothing to measure across, which is why it is
                   kept separate from R1-R7; `--keep-unpairable` turns it off for a
                   static-only use of the corpus.
R9  repo_unfinished  NOT a verdict at all -- a HOLD. `mine` checkpoints a repository when it
                   finishes, so a group whose project has no checkpoint is still being
                   written: R8 would exclude it for a missing second revision that is merely
                   unwritten. Held groups are never exported and never deleted.
                   `--include-unfinished` screens them.
R10 unverified     read from the manifest, not the file: the package resolution the
                   transplant was verified under is gone by the time the screen runs, so a
                   local re-analysis would answer a different question. Hard, and per file,
                   so a pair needs both endpoints clean. A file with NO verification fires
                   nothing, which is every file in a corpus mined under spm <= 0.5.1.
R11 source_unresolved  read from the manifest. What fires is a FLOOR: before spm 0.6.0 the
                   flag could only reach the first revision of a broken pubspec window, so a
                   corpus mined earlier carries unflagged revisions that belong here.
R12 inline_reverted  read from the manifest. Nothing re-mines it away: the revert is spm
                   picking the better of two bad transplants.
R19 shim_dropped_children  role-level. `spm isolate` replaces a widget it will not carry
                   with a SHIM whose `build` renders exactly ONE pass-through parameter,
                   chosen over the union of the class's constructors. Any constructor that
                   does not declare that parameter renders NOTHING while still accepting the
                   `itemBuilder`/`children` the call site passed. Soft, for R12's reason and
                   with R12's consequence: the file describes a smaller tree than the code it
                   came from builds. See SHIM_DROP_RULE below.
R20 shim_child_form  pair-level and HARD. The endpoints disagree about which shim
                   constructors drop their children, so the delta between them is the shim's
                   constructor coverage rather than the edit. Group 0082 is the case.
                   See SHIM_FORM_RULE below.
R13 binding_set    pair-level; see BINDING_RULE below.
R14 short_vector   role-level; see SHORT_VECTOR_RULE below.
R15 zero_delta     pair-level; see ZERO_DELTA_RULE below.
R0  manual         `--exclude-groups`; see MANUAL_RULE below.
R16 unfillable_fixture  group-level. The fill declared one of the group's bindings
                   unresolvable, so its fixture can never lose its `// TODO: value`. Derived
                   from `config/fixture_policy.json`; see UNFILLABLE_RULE below.
R17 package_license  file-level, from the manifest. The transplant carries source from a
                   hosted package the licence policy does not allow -- or carries package
                   source this run cannot attribute to any package at all. See
                   PACKAGE_LICENSE_RULE below and `scripts/screen/licenses.py`.
R18 repo_license   group-level. The repository the scope came from is not under an allowed
                   licence, according to the collector's own record of what it admitted.
                   See REPO_LICENSE_RULE below.
"""

from __future__ import annotations

# --------------------------------------------------------------------------------------
# The rules. Each is (id, human reason). The MATCHING lives in `scripts/dart_tools` --
# `lib/src/rules.dart` holds the vocabulary and `lib/src/facts.dart` the AST pass that
# feeds it. Only the ids and the prose stay here, because the report, the JSON rule table
# and the `hard`/`flagged_by` sets are all written on this side.
#
# The rules are deliberately over-broad: a false exclusion costs one group, a false
# retention costs a measurement that silently violates the research scope.
# --------------------------------------------------------------------------------------

# R10/R11 come from the MANIFEST, not from the file. See `verification_rules`.
UNVERIFIED_RULE = "R10_unverified"
UNVERIFIED_REASON = ("`spm isolate` could not analyse the transplant without an error, so "
                     "`spm analyze` skips it and it yields no metrics (spm 0.5.2+)")
SOURCE_UNRESOLVED_RULE = "R11_source_unresolved"
SOURCE_UNRESOLVED_REASON = ("the source project's own dependencies never resolved, so the "
                            "transplant is shallower than the code it claims to be "
                            "(spm 0.5.2+; what fires is a floor, see this module's "
                            "docstring)")
INLINE_REVERTED_RULE = "R12_inline_reverted"
INLINE_REVERTED_REASON = ("carrying the third-party source analysed WORSE than standing it "
                          "in, so spm kept the stood-in version: the file describes a "
                          "smaller tree than the code it came from builds (spm 0.6.0+; "
                          "`thirdPartyInlineTruncated` says the same thing about a scope "
                          "that hit the inline budget)")

SHIM_DROP_RULE = "R19_shim_dropped_children"
SHIM_DROP_REASON = ("a shim `spm isolate` generated renders none of the subtree the "
                    "transplanted code handed it -- its `build` passes through one "
                    "parameter, and the constructor the call site used does not declare "
                    "that one -- so the file describes a smaller tree than the code it came "
                    "from builds")
# Role-level and SOFT; matched in `scripts/dart_tools/lib/src/shims.dart`, which also carries
# the long explanation of how the emitter arrives at it. Fires on 2,327 of 15,304 roles in the
# 2026-09-09 mine, across 157 groups, 5 of them otherwise eligible.
#
# The severest cases are not grids. `GetBuilder` -- the GetX rebuild widget itself -- shims to
# `const SizedBox.shrink()` because none of its parameters is `child`/`body`/`children`, so a
# transplant returning `GetBuilder<C>(builder: ...)` renders an EMPTY tree and its metrics
# describe nothing. Groups 0046-0053 are that shape. This is the rate to read before deciding
# whether soft is still the right default after the re-mine.

RULES: list[tuple[str, str]] = [
    ("R1_animation", "animation-driven rebuild (stage 1b; round-1 settle hang)"),
    ("R2_async", "async/await- or Future/Stream-driven rebuild (stage 1b)"),
    ("R3_io_network", "I/O- or network-driven rebuild (stage 1b)"),
    ("R4_keepalive", "scrolling / keep-alive lifecycle mixin (stage 1b)"),
    ("R5_nested_app", "nested application root (round 2; units 09 and 31)"),
    ("R6_nondeterminism", "non-deterministic input, unrepairable here (stage 4)"),
    (UNVERIFIED_RULE, UNVERIFIED_REASON),
    (SOURCE_UNRESOLVED_RULE, SOURCE_UNRESOLVED_REASON),
    (INLINE_REVERTED_RULE, INLINE_REVERTED_REASON),
    (SHIM_DROP_RULE, SHIM_DROP_REASON),
]
# R6 was a REPAIR in the original corpus, not an exclusion. Default to flagging it so the
# decision stays visible; --strict promotes it to an exclusion.
# R11 is soft for the same reason R6 is: the answer is to re-mine that revision with its
# dependencies resolved, not to discard the scope, so the default is to make the condition
# visible and let `--strict` decide it. R10 is NOT soft -- a transplant `spm analyze` skips
# produces no row at all, so there is nothing to be lenient about.
# R12 is soft for a third reason, and it is a judgement rather than a repair. spm 0.7.0's
# own words are that such a row is "one to exclude rather than to compare", and taken
# literally that is most of the corpus: it fires on 243 of the 422 isolated rows the mine has
# checkpointed so far. A rule that removes 58% of the evidence is a decision to make with the
# rate in front of you, not one to have applied silently by the screen, so the default is to
# make it visible and let `--strict` decide it. Unlike R6 and R11 there is no re-mine that
# fixes it -- the revert is spm choosing the better of two bad transplants.
# R16 joins this set below, where it is defined -- see there for why it is soft for a reason
# unlike these three.
# R19 is soft for R12's reason, arrived at from the other side of the same defect: a shim
# that renders none of the subtree it was handed makes the transplant describe a smaller tree
# than the source built. Where the drop is present at BOTH endpoints of a contrast it
# understates the delta's magnitude without misattributing it, which is a rate to see rather
# than a verdict to apply silently -- and the pair-level half, where they DISAGREE and the
# delta becomes the shim's, is R20 and is hard.
SOFT_RULES = {"R6_nondeterminism", SOURCE_UNRESOLVED_RULE, INLINE_REVERTED_RULE,
              SHIM_DROP_RULE}

DUPLICATE_RULE = "R7_duplicate"
DUPLICATE_REASON = "duplicate / near-duplicate transplant (stage 1c)"
NO_PAIR_RULE = "R8_no_pair"
NO_PAIR_REASON = "fewer than 2 transplanted states, so no delta is derivable"
# Two distinct states are the minimum for a before/after pair: a lone revision has nothing
# to be contrasted against.
MIN_REVISIONS_FOR_A_PAIR = 2

SHIM_FORM_RULE = "R20_shim_child_form"
SHIM_FORM_REASON = ("the endpoints reach shim constructors that differ in whether they render "
                    "the subtree they were handed, so the delta is the shim's constructor "
                    "coverage and not the edit")
# Pair-level and HARD, on exactly R13's footing: it says nothing about whether either
# transplant is measurable alone, only that the two cannot be compared to each other. R19 is
# the role-level half and is soft, because a drop at BOTH endpoints is symmetric scaffolding
# in the sense the fixture rules use that word.
#
# GROUP 0082 IS THE CASE, and it is why this rule exists rather than being a strictness knob
# on R19. Its two revisions differ by exactly `StaggeredGridView.countBuilder(itemBuilder:,
# itemCount:)` -> `StaggeredGrid.count(children: [...])`. The first shim renders an empty
# `Stack` -- the builder is accepted as `dynamic` and discarded -- and the second renders all
# three items, so the measured delta is three blog cards that the edit did not add. R13 cannot
# see it: both endpoints mount from an identical binding set, and the asymmetry is in what the
# shim DOES with them. The group was measured on 2026-09-07 before this was known.
#
# WHAT IS COMPARED is the set of `class.constructor` keys that drop, not the discarded
# argument names: two endpoints reaching the same dropping constructor erase the same subtree,
# and which arguments they passed to it is the edit talking. Measured on the 2026-09-09 mine:
# of 468 nonzero-delta contrasts, exactly 1 disagrees -- 0082's, which is ADJACENT and so was
# in the adjacent set -- and 0 agree while dropping, because the other flagged eligible
# groups form no pair at all.

BINDING_RULE = "R13_binding_set"
BINDING_REASON = ("the two endpoints mount from different sets of fixture bindings, so the "
                  "contrast is not a change against identical initial state")
# Pair-level and HARD, and unlike every rule above it says nothing about whether either
# transplant is measurable on its own -- only that the two cannot be compared to each other.
#
# It reads the `lifted` and `seed` sections of the fixture split and NOTHING else. Those two
# are the scope's initial state; `declaration` and `unresolved` hold the reconstructed
# stand-ins, and two roles routinely disagree about a stand-in without contradicting each
# other -- one reaches `AsyncValue.requireValue`, its sibling reaches the plain constructor.
# `fixture_skeleton` absorbs that by merging member-by-member, so a rule that fired on it
# would be re-excluding what the fixture already reconciled. Measured on the round-4 corpus:
# 142 of 172 otherwise-eligible pairs pass, 27 differ, 3 have no recoverable endpoint.
#
# NOT soft, and deliberately NOT wired into `--strict`. R6/R11/R12 are soft because their
# rate has to be seen before the exclusion can be judged; `binding_delta` below records that
# rate on every pair this is computed for, so the cost stays recoverable from the JSON
# without a second pass. `--strict` also promotes R12, which fires on 704 groups, so sharing
# the flag would hide this decision inside a much larger one.
BINDING_SECTIONS = ("lifted", "seed")

SHORT_VECTOR_RULE = "R14_short_vector"
SHORT_VECTOR_REASON = ("`spm analyze` reported closureResolved == 0, so the walker never "
                       "descended and the feature vector describes less than the tree")
# Role-level and HARD, and it exists because all-pairwise screening differences vectors the
# adjacent path never had to compute. `unresolvedDependencies` non-empty means the analyzer
# stopped at the root `build` body: the row is not slightly wrong, it is SHORT, and the
# direction of the shortfall is unknown. Differencing two short vectors gives a delta that
# can be zero because nothing was walked rather than because nothing changed -- measured on
# `0730`, whose three revisions rewrite a `TaskTile` constructor and whose vectors are
# identical on all twelve features with `walkedWidgetClasses` empty on every one.
#
# The precedent is arm 1's own equivalence check, which reports `closureResolved == 1` on
# 469/469 roles alongside the 14-metric identity: that flag was already the corpus's
# statement that no vector is silently short. Here it fires on 305 of 1,334 analysed roles.

ZERO_DELTA_RULE = "R15_zero_delta"
ZERO_DELTA_REASON = ("the two endpoints' feature vectors are identical, so the contrast "
                     "carries nothing for the model to learn from")
# Pair-level and HARD. `mining/mine` applied a nonzero-delta filter of its own, but on
# deltas taken over the SOURCE scope at each commit -- not over the transplant that will be
# measured. The two disagree often: 905 of 1,179 ordinal-adjacent shipped roles are
# byte-identical to their neighbour despite distinct source hashes, and a byte-identical
# pair cannot produce a delta whatever the commit did. This rule is that filter re-applied
# to what is actually on disk.

# `spm analyze` is not re-run per screen; the vectors R14 and R15 read come from
# `extract_features`, which writes them beside the corpus. A corpus without them cannot be
# screened at all, and saying so is better than screening a corpus whose deltas describe
# something else.

MANUAL_RULE = "R0_manual"
MANUAL_REASON = "excluded by hand (--exclude-groups)"
# The screen's own equivalent of `data/exclusions.txt`, at the granularity the screen works
# at: a group id, not a repository. For the judgement a rule cannot make -- a transplant
# that is measurable and simply not worth writing `dependencies.dart` for.

UNFILLABLE_RULE = "R16_unfillable_fixture"
UNFILLABLE_REASON = ("a binding in this group's fixture cannot be resolved by the GENERATED "
                     "fill, so `dependencies.dart` keeps its `// TODO: value` until the "
                     "fixture is authored by hand; the group is held at the fixture gate, "
                     "not excluded from the corpus")
# Group-level and SOFT since 2026-09-08. It NAMES WORK, it does not drop a group.
#
# It was hard from 2026-09-02, and correctly so while nobody was authoring fixtures: a slot the
# generated fill would not resolve was a slot that would never be filled, so the group could
# never mount and carrying it was pretending. `config/authored_fixtures/` changed the premise.
# A hand-authored fixture is now a named, countable, protected input (2026-09-07), and the type
# a hard R16 refuses is exactly the type an author fills -- `0082`'s own fixture carries
# `TextEditingController fixtureTextEditingController = ...`, the very type the policy names in
# `out_of_scope`. A hard rule was throwing away groups the author was willing to fill.
#
# WHAT DID NOT CHANGE, and must not be read as having changed:
#
#   * The POLICY still refuses. `config/fixture_policy.json` stays primitives-only: no stand-in
#     whose construction has cost is fabricated by a table, which is the 2026-09-05 argument and
#     it is untouched. R16 going soft moves the refusal's CONSEQUENCE, never the refusal.
#   * `fixture_gate.py` is still a HARD REFUSAL, and it is now the only one. A group carrying
#     `// TODO: value` cannot reach the device; it simply is not deleted from the screen first.
#   * The DECLARED / undeclared split below is unchanged and still checked by the
#     `--from-nothing` gate. A type named nowhere is still loud. R16 no longer excluding does
#     not make the policy's completeness optional -- it makes it more important, because a
#     short policy now shows up as work nobody was told to do rather than as a missing group.
#
# The cost, stated rather than absorbed: the corpus now has TWO sizes -- screened-eligible, and
# measurable-today -- and they must always be reported together. Writing the first alone would
# be the same failure as quoting a largest-contributor share without its denominator.
#
# It replaces the hand list that carried `0607`: the reason that group was dropped -- `late
# TabController`, whose type the policy DECLARES unrecoverable because a `TickerProvider vsync`
# cannot exist above the element tree -- was already a consequence of the policy, and the hand
# list only re-stated it. That group is now awaiting a fixture rather than gone.
#
# READ FROM THE VALUES TABLE, not from the fixture on disk, and the difference is the whole
# design. `fixture_values.resolve()` records `origin: "none"` for a slot it will not guess, and
# that verdict is durable and pass-independent. Testing the FIXTURE for a surviving stamp
# instead would fire on every candidate group before the fill has run and, worse, on any group
# the fill legitimately skipped (`--apply --eligible-only` visits only groups already carrying
# an eligible contrast) -- so a group that had no eligible contrast on pass one would be
# EXCLUDED on pass three for not having been filled, and the exclusion would be its own cause.
# An entry exists only where the fill actually looked and actually gave up.
#
# It is therefore inert on an empty table, which is what makes it correct in phase 1 of
# `--full` and decided in phases 3 and 5.
#
# TWO KINDS, reported apart. `resolve()` returns `origin: "none"` both for a refusal the policy
# NAMES and for one it simply says nothing about. The first is a recorded decision. The second
# means the policy needs an entry, and dropping a group silently because nobody wrote a type
# into the map is the failure this rule could otherwise introduce, so it is counted separately
# and printed as a warning. See `unfillable_groups`.
#
# Named refusals live in three blocks, because they answer different questions (2026-09-05):
# `unrecoverable` is what Dart cannot construct above the element tree; `out_of_scope` is what
# the primitives-only value table declines to fabricate, constructible or not; and
# `unrecoverable_rules` carries ids for refusals belonging to a resolution ROUTE rather than a
# type -- an unrecovered `const dynamic X = null;` stand-in has type `dynamic`, so no type-keyed
# lookup can place it. The classification keys on the stored `rule_id`, never on the note: the
# note is prose, and until 2026-09-05 it WAS the key, so rewording a sentence silently
# reclassified every values table already on disk.

# Soft for a reason unlike the other three in that set: not because the verdict is arguable,
# but because its consequence moved. The binding really is unresolved by the generated fill;
# what that now earns is a place on the authoring worklist and a refusal at `fixture_gate.py`,
# rather than removal from the corpus. `--strict` promotes it back to the pre-2026-09-08
# behaviour, which is how the old corpus stays reproducible.
SOFT_RULES.add(UNFILLABLE_RULE)

# Annotates unless `--strict`. See RENDER_NOTHING_RULE's comment for why this one is
# soft where R21 is hard.
SOFT_RULES.add("R22_renders_nothing")

PACKAGE_LICENSE_RULE = "R17_package_license"
PACKAGE_LICENSE_REASON = ("the transplant carries source from a hosted package whose licence "
                          "the policy does not allow, or carries package source this run "
                          "cannot attribute to any package")
# File-level and HARD, on the same footing as R10/R11/R12: read from the manifest, decided per
# file, so a pair needs BOTH endpoints clean. Never promoted or demoted by a flag, for the
# reason UNFILLABLE_RULE is not: a file the study may not redistribute is not a judgement
# anyone tunes.
#
# WHAT IT IS ABOUT. `spm isolate` carries a third-party widget's own SOURCE into the
# transplant, recursively, and the export then strips the `package:` imports -- so a shipped
# `rev_*.dart` can hold package code with no import, no comment and no attribution. The
# repository allow-list in `scripts/collector` never saw any of it: it gates the HOST
# repository at acquisition and says nothing about the packages that repository depends on.
#
# UNATTRIBUTED FIRES, and that is the design rather than a limitation. A row whose count says
# package source was carried but whose packages cannot be named is not evidence of an allowed
# licence; it is evidence that nobody looked. Passing it would make this rule's silence mean
# two different things, which is the failure `verification_rules` documents for R10. The two
# kinds are counted and reported apart -- `disallowed` is a policy verdict, `unattributed` is
# a gap in the provenance -- because only the second is fixed by re-running a pass.
#
# The package names come from `inlinedThirdPartyPackages`, which `spm` writes in the same
# statement as the declaration count, and which for this corpus is repopulated by
# `mining.license_provenance` under a byte-identity gate. See `scripts/screen/licenses.py`.

REPO_LICENSE_RULE = "R18_repo_license"
REPO_LICENSE_REASON = ("the repository this scope was mined from is not under a licence the "
                       "policy allows, or none was ever recorded for it")
# Group-level and HARD, beside R16, and the only rule here that re-derives nothing. The
# licence verdict already existed -- `scripts/collector` refused any repository outside
# {mit, apache-2.0, bsd-3-clause} before it was ever cloned -- but it was written only into
# `data/candidates.jsonl` and never carried into the mine, the screen, the export or
# `provenance/`. So an exported group had no machine-readable record of the licence of the
# code in it, and the claim rested on a gate no artifact could show.
#
# It fires on nothing in this corpus, which is the point: all 20 eligible repositories are
# MIT (14) or Apache-2.0 (6). A rule that asserts what is already true is worth having when
# what it asserts is otherwise unreachable, and it stops being free the moment the corpus
# grows.

RENDER_ERROR_RULE = "R21_renders_error"
RENDER_ERROR_REASON = ("the device drew Flutter's error box for this role: its `build` threw, "
                       "so the buildSpan measured is the error box and not the tree the "
                       "feature vector describes")
RENDER_NOTHING_RULE = "R22_renders_nothing"
RENDER_NOTHING_REASON = ("the role mounted and painted one flat colour over the whole body: "
                         "it rendered nothing, so its buildSpan describes an empty tree")
# Role-level, and the first two rules here whose evidence comes from the DEVICE rather than
# from the source. `scripts/render_gate.py` reads them back off the screenshots and raw logs a
# campaign already wrote and commits them to `config/render_exclusions.json`; nothing in the
# screen looks at an image.
#
# WHY THEY CANNOT BE STATIC. The failure they catch is `_Stub` reaching a statically typed
# slot -- `type '_Stub' is not a subtype of type 'String'` -- and every step of that flow is
# `dynamic`. `spm analyze` reports no diagnostic, so R10 passes it; the walker descends, so
# R14 passes it; the vector is a perfectly ordinary vector, so R15 passes it. The only thing
# that knows is the device, and until 2026-09-15 the one artifact that recorded it -- the
# per-role screenshot -- was written and never read.
#
# R21 IS HARD. A measured error box is not a noisy measurement of the role; it is an exact
# measurement of a different widget. There is no threshold at which averaging more of them
# helps, which is what separates this from every soft rule here.
#
# R22 IS SOFT, and the asymmetry is deliberate. "One flat colour" is decisive about the
# PIXELS and not about the cause: an empty collection driving `itemCount: 0` and a shim that
# renders none of its subtree are already named by R16, R19 and R20, so R22 is usually the
# same finding seen from the other end -- and a transplant whose honest output is one filled
# rectangle would be condemned by it. It annotates, and `--strict` promotes it.
#
# NEITHER IS A CLAIM ABOUT AN UNMEASURED ROLE. The table carries only roles a campaign
# actually drew; `render_gate`'s `unknown` bucket is the coverage gap and it fires nothing.
# A corpus screened before any device run has an absent table, `render_version()` says so,
# and both rules are inert -- the same shape as R16 against an empty values table.

UNFINISHED_RULE = "R9_repo_unfinished"
UNFINISHED_REASON = ("the repository's mine has not checkpointed yet, so its groups are "
                     "still being written")


def reasons() -> dict[str, str]:
    """Every rule id mapped to the prose the report and the appendix table print."""
    r = {rid: txt for rid, txt in RULES}
    r[DUPLICATE_RULE] = DUPLICATE_REASON
    r[NO_PAIR_RULE] = NO_PAIR_REASON
    r[BINDING_RULE] = BINDING_REASON
    r[UNFINISHED_RULE] = UNFINISHED_REASON
    r[MANUAL_RULE] = MANUAL_REASON
    r[UNFILLABLE_RULE] = UNFILLABLE_REASON
    r[PACKAGE_LICENSE_RULE] = PACKAGE_LICENSE_REASON
    r[REPO_LICENSE_RULE] = REPO_LICENSE_REASON
    r[SHORT_VECTOR_RULE] = SHORT_VECTOR_REASON
    r[ZERO_DELTA_RULE] = ZERO_DELTA_REASON
    r[SHIM_FORM_RULE] = SHIM_FORM_REASON
    r[RENDER_ERROR_RULE] = RENDER_ERROR_REASON
    r[RENDER_NOTHING_RULE] = RENDER_NOTHING_REASON
    return r


def hard_set(*, strict: bool, keep_unpairable: bool, require_finished: bool) -> set[str]:
    """The rules that EXCLUDE, for one run's flags.

    Soft rules flag rather than exclude unless `--strict` promotes them; R8 and R9 are added
    rather than listed in `RULES` because neither says anything about whether a transplant is
    measurable -- R8 is a yield rule and R9 is a hold.
    """
    hard = {rid for rid, _ in RULES}
    # Added, then removed again below by `hard -= SOFT_RULES` unless `--strict` -- the same
    # mechanism the other soft rules go through, rather than a second one beside it. Since
    # 2026-09-08 an unresolved binding names authoring work and is held at `fixture_gate.py`;
    # it does not remove the group. Under `--strict` it excludes, which is what reproduces the
    # pre-2026-09-08 corpus.
    hard.add(UNFILLABLE_RULE)
    # Hard for a reason that is not about measurability at all: a transplant
    # the study has no licence to redistribute cannot be shipped whatever it would measure.
    hard.add(PACKAGE_LICENSE_RULE)
    hard.add(REPO_LICENSE_RULE)
    # Hard for the reason the licence rules are, and not the one the soft rules are: a role
    # the device drew an error box for was measured, and what was measured was not it.
    hard.add(RENDER_ERROR_RULE)
    # Added here and taken straight back out by `hard -= SOFT_RULES` below -- the same path
    # UNFILLABLE_RULE takes, so `--strict` is the single switch for every soft rule rather
    # than a list this one is missing from.
    hard.add(RENDER_NOTHING_RULE)
    if not strict:
        hard -= SOFT_RULES
    if not keep_unpairable:
        hard.add(NO_PAIR_RULE)
    if require_finished:
        hard.add(UNFINISHED_RULE)
    return hard
