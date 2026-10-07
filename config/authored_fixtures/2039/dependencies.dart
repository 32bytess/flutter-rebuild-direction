// GENERATED FIXTURE SKELETON -- spm-fixture-v2
//
// Declarations lifted out of this group's transplants so that ONE fixture serves every role in
// it. That is the point of the file: the same values mount for both endpoints of every
// contrast, so a measured difference is attributable to the edit and not to the scaffolding.
//
// HOW THE VALUES GOT HERE. They are not authored by hand and not invented by the generator.
// Each one is resolved by a pre-registered hierarchy and the rule that fired is recorded, per
// binding, in this group's `fixture_provenance.json`:
//
//   relocated        the value really was in the application; `spm isolate` moved it here
//                    verbatim. Do not "tidy" one -- it is a measurement input.
//   upstream_literal not relocated, but the repository declares it at this group's anchor
//                    commit; taken verbatim, with `file@sha` recorded.
//   protocol_constant neither of the above; the committed table in `config/fixture_policy.json`.
//                    Collection cardinality is one declared constant, corpus-wide.
//   maximal_branch   a bool/enum/nullability that decides WHICH subtree renders takes the arm
//                    that renders more. This one OVERRIDES a relocated value, and says so.
//
// WHAT REMAINS TRUE REGARDLESS OF WHO OR WHAT FILLS A SLOT:
//
//   * The same values serve every role in the group. That is what makes the stubbing
//     symmetric across a pair, which is what makes a measured difference attributable to
//     the edit rather than to the scaffolding.
//   * Fixed collection cardinality. A list of 3 in one place and 10 in another is a change
//     in tree size, and tree size is the dependent variable.
//   * Deterministic values only: no `Random`, no `DateTime.now()`, no I/O, no network, no
//     animation controllers left ticking.
//   * Keep `extends` and `implements` clauses exactly as they are. `spm analyze` decides
//     widget versus value object by walking the supertype chain, so a stand-in that stops
//     extending its widget base silently moves allocations into `valueObjectAllocCount`.
//   * Fill before measuring, then freeze. A fixture edited after seeing a result is a
//     fixture the result cannot be defended against.
//
// A slot the hierarchy cannot resolve keeps its `// TODO: value` and is NOT guessed.
// `scripts/fixture_gate.py` then refuses the group, so an unfilled fixture cannot reach the
// device.
//
// This file is a pure function of the mine plus two committed tables, and is regenerated as
// long as it is untouched. The first HAND edit makes it yours: the screen sees the file no
// longer matches the hash it recorded, copies it into config/authored_fixtures/, and never
// generates over it again -- including after a prune deletes this directory, which is how
// the hash alone used to lose an edit. `scripts/authored_fixtures.py --list` says which
// groups the corpus no longer derives from the mine; `--release <group>` hands one back.
// ignore_for_file: unused_import, unused_element, unused_field
part of generated_widget;


// SEEDS -- the values the generated `initState` reads, for which `spm isolate`
// could build none. It declares each of these `late` and leaves it unassigned on
// purpose: a fabricated default would be measured as though it were the value that
// was really there. Assign one below and every role in this group gets it.

// Three lines: the line count is tree size (`buildCodeWithLinesCount` emits one
// RichText per line), so it takes the corpus-wide cardinality constant, not a
// length chosen from the snippet.
late String fixtureCode =
    'void main() {\n  runApp(const MyApp());\n}';

late Syntax fixtureSyntax = Syntax.DART;

bool fixtureWithZoom = false;

bool fixtureWithLinesCount = false;

late SyntaxTheme? fixtureSyntaxTheme = SyntaxTheme.dracula();

late double fixtureFontSize = 12.0;

bool fixtureExpanded = false;

bool fixtureSelectable = false;

late String fixtureFont = 'monospace';

late ScrollController fixtureVerticalScrollController = ScrollController();

// LIFTED BINDINGS -- the scope's initial state, which `spm isolate` 0.7.0 moves out
// of the application and into a fixture block of its own. Most of these carry the
// value that was really there, relocated rather than invented, and are reproduced
// here verbatim: do not "tidy" one, it is a measurement input.
//
// The ones marked TODO are the exception. Where the binding came from the
// application and no value existed to move, the block gets an empty collection or a
// null, and how many elements you put in one IS tree size -- the dependent variable.
// That is a decision, and it is why they are hoisted: filled in once here, the whole
// group mounts from identical values, so a measured difference is attributable to
// the edit rather than to the scaffolding.

double fixtureFontScaleFactor = 1.0;

// DECLARATION-ONLY STAND-INS -- repo-local declarations that build no UI, and
// third-party ones the transplant does not inline. Supertypes are mirrored so a
// widget still reads as a widget; everything else is `dynamic`, because none of it
// is measured.

class SyntaxTheme {
  SyntaxTheme({
    dynamic baseStyle,
    dynamic numberStyle,
    dynamic commentStyle,
    dynamic keywordStyle,
    dynamic stringStyle,
    dynamic punctuationStyle,
    dynamic classStyle,
    dynamic constantStyle,
    dynamic linesCountColor,
    dynamic backgroundColor,
    dynamic zoomIconColor,
  });
  dynamic get baseStyle => null;
  set baseStyle(dynamic _) {}
  dynamic get numberStyle => null;
  set numberStyle(dynamic _) {}
  dynamic get commentStyle => null;
  set commentStyle(dynamic _) {}
  dynamic get keywordStyle => null;
  set keywordStyle(dynamic _) {}
  dynamic get stringStyle => null;
  set stringStyle(dynamic _) {}
  dynamic get punctuationStyle => null;
  set punctuationStyle(dynamic _) {}
  dynamic get classStyle => null;
  set classStyle(dynamic _) {}
  dynamic get constantStyle => null;
  set constantStyle(dynamic _) {}
  dynamic get linesCountColor => null;
  set linesCountColor(dynamic _) {}
  dynamic get backgroundColor => null;
  set backgroundColor(dynamic _) {}
  dynamic get zoomIconColor => null;
  set zoomIconColor(dynamic _) {}
  static dynamic standard() => SyntaxTheme();
  static dynamic dracula() => SyntaxTheme();
  static dynamic ayuLight() => SyntaxTheme();
  static dynamic ayuDark() => SyntaxTheme();
  static dynamic gravityLight() => SyntaxTheme();
  static dynamic gravityDark() => SyntaxTheme();
  static dynamic monokaiSublime() => SyntaxTheme();
  static dynamic obsidian() => SyntaxTheme();
  static dynamic oceanSunset() => SyntaxTheme();
  static dynamic vscodeDark() => SyntaxTheme();
  static dynamic vscodeLight() => SyntaxTheme();
  dynamic copyWith({
    dynamic baseStyle,
    dynamic numberStyle,
    dynamic commentStyle,
    dynamic keywordStyle,
    dynamic stringStyle,
    dynamic punctuationStyle,
    dynamic classStyle,
    dynamic constantStyle,
    dynamic linesCountColor,
    dynamic backgroundColor,
    dynamic zoomIconColor,
  }) => SyntaxTheme();
}

// HAND-AUTHORED 2026-09-15 (typed stand-in return). Was `=> const _Stub()`. Every role calls
// `getSyntax(syntax, syntaxTheme).format(code)` into a `children: <TextSpan>[...]`, so the
// element type is checked on the way in: the `_Stub` threw inside `build` and the device drew
// Flutter's error box.
//
// WHY ONE FLAT SPAN AND NOT A HIGHLIGHTED TREE. What the real `format` returns is a `TextSpan`
// whose `children` are one span per lexical token, and that count is TREE SIZE -- the quantity
// this study measures. Reconstructing it would mean writing a Dart lexer here and having the
// span count come out of it, which is inventing tree shape from a stand-in. One span carrying
// the code verbatim is the minimum that satisfies the slot: `fixtureCode` is a relocated
// value, already in this file, and it is rendered whole, so the glyphs laid out are exactly
// the glyphs the application laid out. What is lost is the per-token colouring, which is paint
// and not structure.
//
// `TextSpan` is in neither of `config/fixture_policy.json`'s refusal tables. `out_of_scope`
// names `Widget` -- "a widget stand-in is a subtree, and subtree size is what the study
// measures" -- and a `TextSpan` is not a `Widget`; it is an `InlineSpan`. The note above is
// this edit honouring the spirit of that sentence anyway, since a span's children are as much
// tree as a widget's.
class _SyntaxStandIn {
  const _SyntaxStandIn();
  TextSpan format(dynamic code) => TextSpan(text: '$code');
}

dynamic getSyntax(dynamic syntax, dynamic theme) => const _SyntaxStandIn();

class _Stub {
  const _Stub();

  int get length => 0;
  bool get isEmpty => true;
  bool get isNotEmpty => false;
  Iterator<dynamic> get iterator => const Iterable<dynamic>.empty().iterator;

  dynamic operator [](Object? key) => const _Stub();
  dynamic operator +(Object? other) => const _Stub();
  bool operator <(Object? other) => false;
  bool operator >(Object? other) => false;
  bool operator <=(Object? other) => false;
  bool operator >=(Object? other) => false;

  @override
  bool operator ==(Object other) => other is _Stub;

  @override
  int get hashCode => 0;

  @override
  dynamic noSuchMethod(Invocation invocation) => const _Stub();

  @override
  String toString() => '';
}
