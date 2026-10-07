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

late StreamSubscription fixtureIntentDataStreamSubscription =
    const Stream<dynamic>.empty().listen(null);

late String fixtureTitle = 'Markdownr';

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

SettingsRepository fixtureSettingsRepository = SettingsRepository();

Url2MdConverter? fixtureUrl2MdConverter = Url2MdConverter();

MarkdownArticle? fixtureArticle = const MarkdownArticle();

TextEditingController fixtureController = TextEditingController();

String fixtureUrl = "https://en.wikipedia.org/wiki/Markdown";

String fixtureMarkdown = """---
title: "Markdown"
author: "Wikipedia contributors"
date: "2023-11-09"
source: "https://en.wikipedia.org/wiki/Markdown"
---

# Markdown

Markdown is a lightweight markup language for creating formatted text using a
plain-text editor. John Gruber created Markdown in 2004 as an easy-to-read
markup language, in collaboration with Aaron Swartz on the syntax.

## Design goals

The overriding design goal is readability: the language should be publishable
as-is, without looking like it has been marked up with tags or instructions.

- Emphasis is written with asterisks or underscores.
- Headings are written with leading hash marks.
- Lists are written with hyphens or numbers.
- Links are written as an inline pair of brackets and parentheses.

## Variants

Because the original specification left many cases ambiguous, several variants
appeared: CommonMark, GitHub Flavored Markdown, MultiMarkdown and Markdown
Extra among them. They add tables, footnotes, definition lists and fenced code
blocks to the original syntax.

[Read the original article](https://en.wikipedia.org/wiki/Markdown)
""";

String fixtureMarkdownPreview = fixtureMarkdown;

bool fixtureIncludeSourceLink = false;

bool fixtureIncludeFrontMatter = false;

bool fixtureIncludeExcerpt = false;

bool fixtureIncludeBody = true;

bool fixtureShowPreview = false;

// DECLARATION-ONLY STAND-INS -- repo-local declarations that build no UI, and
// third-party ones the transplant does not inline. Supertypes are mirrored so a
// widget still reads as a widget; everything else is `dynamic`, because none of it
// is measured.

class MarkdownArticle {
  const MarkdownArticle({
    dynamic url,
    dynamic content,
    dynamic title,
    dynamic author,
    dynamic excerpt,
    dynamic creationDate,
  });
  dynamic get url => 'https://en.wikipedia.org/wiki/Markdown';
  dynamic get content =>
      'Markdown is a lightweight markup language for creating formatted text '
      'using a plain-text editor. John Gruber created Markdown in 2004 as an '
      'easy-to-read markup language, in collaboration with Aaron Swartz on '
      'the syntax.';
  dynamic get title => 'Markdown';
  dynamic get author => 'Wikipedia contributors';
  dynamic get excerpt =>
      'A lightweight markup language for creating formatted text using a '
      'plain-text editor.';
  dynamic get creationDate => '2023-11-09';
  dynamic get frontMatter =>
      '---\ntitle: "Markdown"\nauthor: "Wikipedia contributors"\n'
      'date: "2023-11-09"\nsource: "https://en.wikipedia.org/wiki/Markdown"\n---\n';
  dynamic get sourceLinkSection =>
      '\n[Read the original article](https://en.wikipedia.org/wiki/Markdown)\n';
  dynamic get excerptSection =>
      '> A lightweight markup language for creating formatted text using a '
      'plain-text editor.\n';
}

class MarkdownBody extends StatelessWidget {
  const MarkdownBody({
    super.key,
    dynamic data,
    dynamic selectable,
    dynamic styleSheet,
    dynamic styleSheetTheme,
    dynamic syntaxHighlighter,
    dynamic onSelectionChanged,
    dynamic onTapLink,
    dynamic onTapText,
    dynamic imageDirectory,
    dynamic blockSyntaxes,
    dynamic inlineSyntaxes,
    dynamic extensionSet,
    dynamic imageBuilder,
    dynamic checkboxBuilder,
    dynamic bulletBuilder,
    dynamic builders,
    dynamic paddingBuilders,
    dynamic listItemCrossAxisAlignment,
    dynamic shrinkWrap,
    dynamic fitContent,
    dynamic softLineBreak,
  });
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
  dynamic get shrinkWrap => false;
}

class SettingsRepository {
  SettingsRepository();
  dynamic getBool(dynamic name, {dynamic defaultValue}) => false;
  dynamic setBool(dynamic name, dynamic value) => const _Stub();
}

class Share {
  Share();
  static dynamic share(
    dynamic text, {
    dynamic subject,
    dynamic sharePositionOrigin,
  }) => const _Stub();
  static dynamic shareFiles(
    dynamic paths, {
    dynamic mimeTypes,
    dynamic subject,
    dynamic text,
    dynamic sharePositionOrigin,
  }) => const _Stub();
  static dynamic shareWithResult(
    dynamic text, {
    dynamic subject,
    dynamic sharePositionOrigin,
  }) => const _Stub();
  static dynamic shareFilesWithResult(
    dynamic paths, {
    dynamic mimeTypes,
    dynamic subject,
    dynamic text,
    dynamic sharePositionOrigin,
  }) => const _Stub();
  static dynamic shareXFiles(
    dynamic files, {
    dynamic subject,
    dynamic text,
    dynamic sharePositionOrigin,
    dynamic fileNameOverrides,
  }) => const _Stub();
  static dynamic get downloadFallbackEnabled => false;
  static set downloadFallbackEnabled(dynamic _) {}
  static dynamic shareUri(dynamic uri, {dynamic sharePositionOrigin}) =>
      const _Stub();
}

class Url2MdConverter {
  Url2MdConverter({
    dynamic httpClient,
    dynamic settingsRepository,
    dynamic notificationService,
    dynamic readabilityService,
  });
  dynamic convertPage({dynamic url}) =>
      Future<MarkdownArticle>.value(MarkdownArticle());
  dynamic convert({dynamic url}) => Future<String>.value('');
  dynamic get jeckyllRule => const _Stub();
  set jeckyllRule(dynamic _) {}
}

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

class ShareParams {
  ShareParams({
    dynamic text,
    dynamic subject,
    dynamic title,
    dynamic previewThumbnail,
    dynamic sharePositionOrigin,
    dynamic uri,
    dynamic files,
    dynamic fileNameOverrides,
    dynamic downloadFallbackEnabled,
    dynamic mailToFallbackEnabled,
  });
  dynamic get text => null;
  dynamic get title => null;
  dynamic get subject => null;
  dynamic get previewThumbnail => null;
  dynamic get sharePositionOrigin => null;
  dynamic get uri => null;
  dynamic get files => null;
  dynamic get fileNameOverrides => null;
  dynamic get downloadFallbackEnabled => false;
  dynamic get mailToFallbackEnabled => false;
}

class SharePlus {
  SharePlus._(dynamic p0);
  SharePlus.custom(dynamic platform);
  static dynamic get instance => const _Stub();
  dynamic share(dynamic params) => const _Stub();
}
