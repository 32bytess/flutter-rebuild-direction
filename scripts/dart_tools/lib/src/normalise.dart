/// The export-time rewrites, AST-anchored.
///
/// Every pass exists for one reason: the exported corpus should reference nothing
/// `benchmark_container` can resolve. See `scripts/screen_samples.py`'s `normalise`
/// docstring for the provenance of each -- this file changes how they are FOUND, not what
/// they do.
///
/// What the AST buys, concretely:
///
///   * `_code_spans` / `_commented` are gone. They existed only to stop a rewrite firing
///     inside a comment or a string, which the AST cannot do in the first place.
///   * `_enclosing_call`, a hand-written paren balancer, becomes `node.parent`.
///   * a placeholder is recognised by being a call to `Image.asset` whose positional source
///     argument is the placeholder asset, not by matching the exact spelling the regex
///     expected -- and not by the argument count, which spm 0.7.0 no longer fixes at one.
///
/// `_dropArgument`'s comma-and-line swallowing is ported verbatim, because the existing
/// corpus was written by it and the port is verified by byte-diff against that corpus.
library;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'namespaces.g.dart';

const kPlaceholderAsset = 'assets/placeholder.png';
const kGreyBox = 'Container(color: Colors.grey.shade300, width: 80, height: 80)';
const kGrey = 'Colors.grey.shade300';
const kIconStandIn = 'Icons.circle';

/// Material ships `Icons` and `cupertino_icons` IS a dependency, so neither is foreign.
/// `samples/` uses `CupertinoIcons` 43 times.
const kNativeIconFonts = <String>{'Icons', 'CupertinoIcons'};

/// Not asset references -- every platform resolves them -- so they stay.
const kGenericFontFamilies = <String>{'monospace', 'serif', 'sans-serif'};

class Rewrite {
  final String text;
  final Map<String, int> counts;

  /// Import URIs this file uses that `namespaces.g.dart` does not know. They are never
  /// dropped and never count as covering another import, so an incomplete table only makes
  /// the rule more conservative -- but the caller should surface them so the table can be
  /// regenerated with them included.
  final List<String> unknownImports;

  Rewrite(this.text, this.counts, this.unknownImports);
}

class _Edit {
  final int start;
  final int end;
  final String replacement;
  final String kind;
  _Edit(this.start, this.end, this.replacement, this.kind);
}

Rewrite normalise(String text, CompilationUnit unit, {bool pruneImports = true}) {
  final collector = _EditCollector(text);
  unit.accept(collector);
  collector.collectImports(unit);
  if (pruneImports) collector.collectCoveredImports(unit);

  final edits = collector.edits..sort((a, b) => a.start.compareTo(b.start));
  final counts = <String, int>{
    'images': 0,
    'icons': 0,
    'fonts': 0,
    'imports': 0,
    'unused': 0,
  };
  for (final e in edits) {
    counts[e.kind] = counts[e.kind]! + 1;
  }

  // Right-to-left, so an earlier edit's offsets stay valid while a later one is applied.
  var out = text;
  var previousStart = text.length + 1;
  for (final e in edits.reversed) {
    if (e.end > previousStart) {
      throw StateError('overlapping rewrites at ${e.start}..${e.end}');
    }
    previousStart = e.start;
    out = out.substring(0, e.start) + e.replacement + out.substring(e.end);
  }
  return Rewrite(out, counts, collector.unknownImports.toList()..sort());
}

class _EditCollector extends RecursiveAstVisitor<void> {
  final String text;
  final edits = <_Edit>[];
  final unknownImports = <String>{};

  _EditCollector(this.text);

  // ---- placeholder images ------------------------------------------------------------

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final target = node.target;
    if (target is SimpleIdentifier &&
        target.name == 'Image' &&
        node.methodName.name == 'asset' &&
        _isPlaceholderArgs(node.argumentList)) {
      _placeholder(node, node.offset, node.argumentList);
      return;   // see `_placeholder`: the whole node goes, so nothing inside it may.
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final ctor = node.constructorName;
    if (ctor.type.name.lexeme == 'Image' &&
        ctor.name?.name == 'asset' &&
        _isPlaceholderArgs(node.argumentList)) {
      // Start at `Image`, not at a leading `const`: the regex span began there too, and
      // `const Container(...)` stays valid.
      _placeholder(node, ctor.offset, node.argumentList);
      return;
    }
    super.visitInstanceCreationExpression(node);
  }

  /// A placeholder is the skeletonizer's rewritten image: its POSITIONAL source argument is
  /// `kPlaceholderAsset`.
  ///
  /// The argument COUNT is deliberately not part of the signature. spm <= 0.6.0 dropped
  /// every other argument, so a placeholder was always a one-argument call and this method
  /// tested for that; 0.7.0 rewrites only the source and keeps the named arguments it can.
  /// Matching on the count therefore stopped recognising every sized placeholder in the v2
  /// corpus -- 25 files across 5 groups -- and left a live `Image.asset` in an export whose
  /// package declares no assets.
  bool _isPlaceholderArgs(ArgumentList args) {
    for (final a in args.arguments) {
      if (a is NamedArgument) continue;
      return a is SimpleStringLiteral && a.value == kPlaceholderAsset;
    }
    return false;
  }

  /// One placeholder, in whichever of the two slots it occupies.
  ///
  /// In a Widget slot it becomes the grey box. In `CircleAvatar.backgroundImage` -- an
  /// `ImageProvider` slot, where a Widget is a hard compile error -- the KEY is rewritten
  /// instead, exactly as the hand pass did, unless the avatar already sets
  /// `backgroundColor:`, in which case naming it twice would not compile and the argument
  /// is dropped instead.
  ///
  /// Both branches emit an edit spanning the node, so the caller must NOT descend into it:
  /// a `fontFamily` or a foreign icon font inside a surviving `errorBuilder` would collect
  /// a second edit within that span and trip `normalise`'s overlap check.
  void _placeholder(Expression node, int start, ArgumentList args) {
    final named = node.parent;
    if (named is! NamedArgument || named.name.lexeme != 'backgroundImage') {
      edits.add(_Edit(start, node.end, _greyBoxFor(args), 'images'));
      return;
    }
    if (_siblingArguments(named).any(
        (a) => a is NamedArgument && a.name.lexeme == 'backgroundColor')) {
      final span = _dropArgument(named.offset, named.end);
      edits.add(_Edit(span.$1, span.$2, '', 'images'));
    } else {
      edits.add(_Edit(named.offset, named.end, 'backgroundColor: $kGrey', 'images'));
    }
  }

  /// The grey box, carrying the image's own dimensions where the call states them.
  ///
  /// The skeletonizer replaces the asset path and nothing else, so a `width:` / `height:`
  /// on the call is the one the commit wrote. Reproducing it keeps the stand-in the size of
  /// the image it stands in for, which is the tree geometry the transplant exists to
  /// preserve -- an 80x80 box where the source drew 24x24 is a layout the commit never had.
  ///
  /// Both dimensions must be plain numeric literals, and it is both or neither. Anything
  /// computed reaches for something an isolated file does not have, and a box sized on one
  /// axis only is a different shape again; in either case the fixed fallback is the honest
  /// answer rather than a reconstructed one.
  String _greyBoxFor(ArgumentList args) {
    final width = _numericArgument(args, 'width');
    final height = _numericArgument(args, 'height');
    if (width == null || height == null) return kGreyBox;
    return 'Container(color: $kGrey, width: $width, height: $height)';
  }

  /// `name:`'s value, verbatim, when it is a numeric literal -- null for anything else.
  ///
  /// Verbatim so `50.0` stays a double and `48` stays an int: `Container` takes `double?`
  /// and Dart promotes the int literal, but rewriting the spelling would make the exported
  /// file differ from the commit in a second way for no gain.
  String? _numericArgument(ArgumentList args, String name) {
    for (final a in args.arguments) {
      if (a is! NamedArgument || a.name.lexeme != name) continue;
      final value = a.argumentExpression;
      if (value is IntegerLiteral || value is DoubleLiteral) return value.toSource();
      return null;
    }
    return null;
  }

  /// The argument list `named` belongs to. Replaces `_enclosing_call`'s paren counting.
  List<Argument> _siblingArguments(NamedArgument named) {
    final list = named.parent;
    return list is ArgumentList ? list.arguments : const [];
  }

  // ---- foreign icon fonts ------------------------------------------------------------

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (_isForeignIconFont(node.prefix.name)) {
      edits.add(_Edit(node.offset, node.end, kIconStandIn, 'icons'));
    }
    super.visitPrefixedIdentifier(node);
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    final target = node.target;
    if (target is SimpleIdentifier && _isForeignIconFont(target.name)) {
      edits.add(_Edit(node.offset, node.end, kIconStandIn, 'icons'));
    }
    super.visitPropertyAccess(node);
  }

  /// Third-party icon fonts -- FontAwesomeIcons, CarbonIcons, MdiIcons -- are bare
  /// undefined identifiers here: their packages are not in `pubspec.yaml` and no transplant
  /// imports them. One neutral stand-in for all of them, on the grey box's logic: the
  /// corpus measures rebuild structure, not which glyph appeared.
  bool _isForeignIconFont(String name) =>
      name.length > 5 &&
      name.endsWith('Icons') &&
      !kNativeIconFonts.contains(name) &&
      name.codeUnitAt(0) >= 0x41 &&
      name.codeUnitAt(0) <= 0x5A;

  // ---- custom fonts ------------------------------------------------------------------

  @override
  void visitNamedArgument(NamedArgument node) {
    if (node.name.lexeme == 'fontFamily') {
      final value = node.argumentExpression;
      if (value is SimpleStringLiteral &&
          !kGenericFontFamilies.contains(value.value)) {
        // `pubspec.yaml` has no `fonts:` section, so a custom family resolves to nothing.
        final span = _dropArgument(node.offset, node.end);
        edits.add(_Edit(span.$1, span.$2, '', 'fonts'));
      }
    }
    super.visitNamedArgument(node);
  }

  // ---- foreign imports ---------------------------------------------------------------

  /// Across `samples/`'s 535 files not one third-party package is imported: every foreign
  /// symbol is declared in the hand-authored `dependencies.dart` instead. A mined
  /// transplant carries the deep `src/` paths the analyser resolved it through, which are
  /// private and would not resolve even with the package declared.
  ///
  /// Line-oriented like the regex it replaces, and for the same reason: the whole line goes,
  /// terminator included. A directive that does not occupy its line alone is left, which is
  /// what the old `^import ... ;[ \t]*\r?\n?$` match did too.
  void collectImports(CompilationUnit unit) {
    for (final directive in unit.directives) {
      if (directive is! ImportDirective) continue;
      final uri = directive.uri.stringValue;
      if (uri == null ||
          !uri.startsWith('package:') ||
          uri.startsWith('package:flutter/')) {
        continue;
      }
      final span = _wholeLine(directive);
      if (span == null) continue;
      edits.add(_Edit(span.$1, span.$2, '', 'imports'));
    }
  }

  // ---- covered imports ---------------------------------------------------------------

  /// Drop every import whose contribution is already covered by another import that stays.
  ///
  /// This subsumes both "unused" and "unnecessary": an import is droppable when every name
  /// it provides THAT THIS FILE REFERENCES is also provided by one of the others. An import
  /// nothing references at all is the degenerate case, where that set is empty.
  ///
  /// Why not just ask the analyzer, which has `unused_import` and `unnecessary_import` for
  /// exactly this: it suppresses both on any file carrying an error-severity diagnostic,
  /// and a mined transplant has no `dependencies.dart` yet, so it is full of undefined
  /// names. Measured on 20 real transplants that import both `dart:ui` and `material.dart`:
  /// 19 had errors and produced no import diagnostic at all.
  ///
  /// Referenced names come from the token stream, so a name appearing only inside a string
  /// literal or a comment does not keep an import alive. The comparison is deliberately
  /// name-based rather than resolved, which errs toward KEEPING an import: an unrelated
  /// local called `Size` will hold `dart:ui` in. Safe direction.
  void collectCoveredImports(CompilationUnit unit) {
    final referenced = _identifiers(unit);

    // Untouchable directives -- `as` / `show` / `hide`, and any URI the table does not
    // know. They are never dropped; the question here is only how much coverage to credit
    // them with, and crediting too much would drop an import that IS needed.
    final covered = <String>{};
    final candidates = <ImportDirective>[];
    for (final directive in unit.directives.whereType<ImportDirective>()) {
      final uri = directive.uri.stringValue;
      if (uri == null) continue;
      final names = exportedNames[uri];
      if (names == null) {
        // `dependencies.dart` and any surviving relative import land here by design.
        if (uri.startsWith('package:') || uri.startsWith('dart:')) {
          unknownImports.add(uri);
        }
        continue;
      }
      if (directive.prefix != null || directive.combinators.isNotEmpty) {
        covered.addAll(_contributed(directive, names));
        continue;
      }
      candidates.add(directive);
    }

    // Greedy set cover, WIDEST FIRST: keep an import only if it is the first to supply
    // something the file actually references.
    //
    // Widest first is what makes the survivor the idiomatic one. Narrowest first also
    // produces a compiling file, but on `material` + `dart:ui` where the file uses `Color`
    // and `PathMetric` it keeps `dart:ui` and drops `material` -- backwards from every one
    // of `samples/`'s 535 hand-curated files, all of which import `material`.
    candidates.sort((a, b) => _size(b).compareTo(_size(a)));
    for (final directive in candidates) {
      final names = exportedNames[directive.uri.stringValue]!;
      final contributes = names.any((n) => referenced.contains(n) && !covered.contains(n));
      if (contributes) {
        covered.addAll(names);
        continue;
      }
      final span = _wholeLine(directive);
      if (span == null) continue;
      edits.add(_Edit(span.$1, span.$2, '', 'unused'));
    }
  }

  /// What a non-plain import actually puts in scope unprefixed.
  ///
  /// A PREFIXED import contributes nothing: its names are reachable only as `p.Name`, so it
  /// can never cover a bare reference. `show` contributes only the shown names, `hide`
  /// everything but the hidden ones. Crediting the full namespace here -- which an earlier
  /// draft did -- would let `import 'package:flutter/widgets.dart' show Text;` stand in for
  /// a `material` import the file still needs.
  Set<String> _contributed(ImportDirective directive, Set<String> names) {
    if (directive.prefix != null) return const {};
    var out = names;
    for (final combinator in directive.combinators) {
      if (combinator is ShowCombinator) {
        final shown = combinator.shownNames.map((n) => n.name).toSet();
        out = out.intersection(shown);
      } else if (combinator is HideCombinator) {
        final hidden = combinator.hiddenNames.map((n) => n.name).toSet();
        out = out.difference(hidden);
      }
    }
    return out;
  }

  int _size(ImportDirective d) =>
      exportedNames[d.uri.stringValue]?.length ?? 0;

  /// Every identifier token in the unit. Tokens, not AST nodes, for the reason
  /// `FactCollector.collectNames` documents: analyzer 14 hides many names in bare `Token`s.
  Set<String> _identifiers(CompilationUnit unit) {
    final names = <String>{};
    var token = unit.beginToken;
    while (!token.isEof) {
      if (token.isIdentifier) names.add(token.lexeme);
      final next = token.next;
      if (next == null) break;
      token = next;
    }
    return names;
  }

  // ---- shared ------------------------------------------------------------------------

  /// The whole line a directive occupies, terminator included, or null if it does not
  /// occupy one alone.
  ///
  /// Line-oriented, like the `^import '...';$` regex it replaces and for the same reason:
  /// the directive goes with its line, leaving no blank behind. Returning null for a
  /// directive that shares its line is what that regex did too -- except that it also
  /// returned null for one WRAPPED across lines, which left 74 files in the corpus carrying
  /// a third-party import `--normalise` was supposed to remove. Here the span runs from the
  /// start of the first line to the end of the last, so a wrapped directive goes entirely.
  (int, int)? _wholeLine(Directive directive) {
    // `lastIndexOf` rejects a negative start, so offset 0 -- the very first line of the
    // file -- has to be handled before asking.
    final lineStart =
        directive.offset == 0 ? 0 : text.lastIndexOf('\n', directive.offset - 1) + 1;
    if (lineStart != directive.offset) return null;

    var end = directive.end;
    while (end < text.length &&
        (text.codeUnitAt(end) == 0x20 || text.codeUnitAt(end) == 0x09)) {
      end++;
    }
    if (end < text.length && text.codeUnitAt(end) == 0x0D) end++;
    if (end < text.length) {
      if (text.codeUnitAt(end) != 0x0A) return null; // shares its line
      end++;
    }
    return (lineStart, end);
  }

  /// Widen a named argument's span to swallow its trailing comma and its own line.
  ///
  /// Dropping an argument without this leaves a blank, indented line where it used to be.
  /// Ported character-for-character from `screen_samples._drop_argument`, because the
  /// existing corpus was written by it.
  (int, int) _dropArgument(int start, int end) {
    while (end < text.length &&
        (text[end] == ',' || text[end] == ' ')) {
      end++;
    }
    while (start > 0 && (text[start - 1] == ' ' || text[start - 1] == '\t')) {
      start--;
    }
    if (start > 0 && text[start - 1] == '\n') {
      start--;
      if (start > 0 && text[start - 1] == '\r') start--; // CRLF: take both
    }
    return (start, end);
  }
}
