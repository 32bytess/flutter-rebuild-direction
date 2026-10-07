/// One pass over a parsed compilation unit, gathering the structural facts the screening
/// rules ask about.
///
/// The rules used to be regexes over raw source, which is why they fired on `await` inside
/// `Text('please await ...')` and on a commented-out `MaterialApp`. Collecting facts from
/// the AST removes both failure modes for free: string literals are `StringLiteral` nodes
/// whose contents are never identifiers, and comments are not in the visited tree at all.
///
/// The facts are deliberately coarse -- a set of identifier names, a set of `Target.member`
/// pairs, a handful of booleans. The screen is a CONSERVATIVE PRE-FILTER (see
/// `scripts/screen_samples.py`'s docstring), so breadth of vocabulary is preserved; what
/// changes is only that a name now has to appear as a real reference.
///
/// NOTE ON UNRESOLVED PARSING. `parseString` does no resolution, so `MaterialApp(...)`
/// without `const`/`new` is a `MethodInvocation`, not an `InstanceCreationExpression` --
/// the parser cannot know `MaterialApp` is a class. Both shapes are therefore collected.
///
/// NOTE ON WHERE `names` COMES FROM. The token stream, not `visitSimpleIdentifier`.
///
/// Analyzer 14 exposes a great many names as bare `Token`s rather than `SimpleIdentifier`
/// nodes -- a type name (`NamedType.name`), a named argument's label
/// (`NamedArgument.name`), and every declaration name. Collecting identifiers from the AST
/// therefore MISSED `bool get wantKeepAlive`, `vsync:` and `class WebViewScreen`, and the
/// A/B against the regexes caught all three. Which names live in nodes and which in tokens
/// is an analyzer implementation detail that has already changed once, so this does not
/// depend on it.
///
/// Reading tokens costs nothing in precision: a string literal is ONE token and its
/// contents are never identifiers, and comments are precomment tokens that never appear in
/// the chain. `Text('please await ...')` therefore still cannot fire R2, which is the whole
/// point of the port. Code inside a string INTERPOLATION does tokenize, and should -- it is
/// real code.
///
/// NOTE ON REGIONS, added 2026-08-23.
///
/// R2 and R3 ask whether asynchronous or I/O work DRIVES THE REBUILD. The facts above are
/// flat and unit-wide, so they answered a different question: whether the file mentions the
/// vocabulary anywhere. A bare `Future` in an `onPressed` handler, or in a stand-in block
/// the extractor generated, fired R2 exactly as hard as a `FutureBuilder` in `build`. The
/// harness mounts the widget and calls `setState`; nobody taps anything, so a handler never
/// runs inside the measured span.
///
/// Every fact is therefore also bucketed by the region of the file it came from:
///
///   * `rebuild`   -- `build`, a widget-returning helper or getter, and any callback that
///                    is not a recognised interaction handler. The default, because an
///                    unrecognised callback might be a builder.
///   * `lifecycle` -- `initState`, `didChangeDependencies`, `didUpdateWidget`, the
///                    constructor, and field initialisers. All of these run before or
///                    during the measured span and can call `setState` inside it.
///                    `dispose` is deliberately NOT here: it runs after.
///   * `inert`     -- recognised interaction handlers, and members reachable only from
///                    them.
///   * `standIn`   -- at or after `spm isolate`'s stand-in banner. Code the extractor
///                    wrote, not code the commit contained.
///
/// The flat sets are unchanged and R1, R4, R5 and R6 still read them, so this note changes
/// no verdict those four rules produce. Only R2 and R3 consult the regions.
///
/// COMPATIBILITY. Regions are only populated when `indexRegions` is called before
/// `unit.accept(...)`. A collector that skips it puts every fact in `rebuild`, which makes
/// `active*` identical to the flat sets and reproduces the pre-2026-08-23 behaviour exactly.
/// That is the conservative direction: unindexed means everything counts.
library;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'fixture.dart' show standInStart;

/// Where in a transplant a fact was found. See the library docstring.
enum Region { rebuild, lifecycle, inert, standIn }

/// Members whose body runs before or during the measured span. `dispose` is absent on
/// purpose -- it runs after the span, so async work in it cannot perturb a measurement.
const kLifecycleMembers = <String>{
  'initState',
  'didChangeDependencies',
  'didUpdateWidget',
};

/// Named-argument labels whose closure is an INTERACTION callback: it runs when a person
/// touches the widget, which never happens inside a measured rebuild.
///
/// This is the same judgement `rules.dart` already records for `.then(`, which "was tried
/// and removed from the regex for being an interaction callback".
///
/// The pattern is the one `spm`'s `isNonRebuildCallback` uses, so the screen and the
/// extractor agree on what a rebuild is. A literal list drifted from it: `onHover` and the
/// drag handlers were handler-shaped to the extractor and build-shaped here, which excluded
/// roles whose features were never contaminated. No builder is named `onX`, so widening to
/// the pattern does not endanger the rule that an unrecognised callback stays `rebuild`.
final kInteractionCallbackLabel = RegExp(r'^on[A-Z]');

/// Interaction callbacks the pattern cannot reach. Both defer their body: `validator` runs
/// on form validation and `confirmDismiss` on a dismiss gesture.
const kInteractionCallbackExtras = <String>{'validator', 'confirmDismiss'};

/// Whether a named-argument label carries a body a rebuild never runs.
bool isInteractionCallback(String label) =>
    kInteractionCallbackLabel.hasMatch(label) ||
    kInteractionCallbackExtras.contains(label);

/// Facts from one region of the unit.
class RegionFacts {
  final names = <String>{};
  final qualified = <String>{};
  final invoked = <String>{};

  bool hasAwait = false;
  bool hasAsyncBody = false;
}

class Facts {
  /// Every name appearing as an identifier or a type in the unit. Includes declaration
  /// names, named-argument labels and member names -- all of which the old regexes matched.
  final names = <String>{};

  /// `Target.member` for every qualified access, however it parsed.
  final qualified = <String>{};

  /// Names in constructor or function-call position: `File(...)`, `Random()`.
  final invoked = <String>{};

  /// Mixin names from every `with` clause.
  final mixins = <String>{};

  /// Import URIs, verbatim. File-level: an import has no enclosing member, so it is not
  /// bucketed by region.
  final imports = <String>{};

  bool hasAwait = false;
  bool hasAsyncBody = false;

  /// The same facts, split by where in the file they were found.
  final byRegion = <Region, RegionFacts>{
    for (final r in Region.values) r: RegionFacts(),
  };

  RegionFacts region(Region r) => byRegion[r]!;

  /// Every region EXCEPT the generated stand-in block: the code the commit actually
  /// contained, wherever in the file it sits.
  ///
  /// Kept because it answers "does this transplant mention the vocabulary at all", which is
  /// the question the flat sets ask and the one R1, R4, R5 and R6 still want. R2 and R3 no
  /// longer read it; they read [activeNames] and the rest of the `active` view.
  Set<String> get codeNames => _union(_code, (r) => r.names);
  Set<String> get codeQualified => _union(_code, (r) => r.qualified);
  Set<String> get codeInvoked => _union(_code, (r) => r.invoked);

  bool get codeHasAwait => _any(_code, (r) => r.hasAwait);
  bool get codeHasAsyncBody => _any(_code, (r) => r.hasAsyncBody);

  /// The code a measured rebuild can actually reach: `build`, widget-returning helpers, the
  /// lifecycle members that run before or during the span, and any member propagation found
  /// reachable from one of those. This is what R2 and R3 read.
  ///
  /// `inert` is excluded, which is only sound because `FactCollector._propagateRegions`
  /// promotes a member the build path calls. Before that existed, an `await` in a `_load()`
  /// invoked from `initState` was classified `inert` and stopped counting, while the call
  /// site in `initState` carried no vocabulary of its own: an asynchronous `setState` inside
  /// the measured span, which is exactly what R2 exists to exclude.
  ///
  /// `dispose` stays out. It runs after the span, so async work there cannot perturb a
  /// measurement.
  Set<String> get activeNames => _union(_active, (r) => r.names);
  Set<String> get activeQualified => _union(_active, (r) => r.qualified);
  Set<String> get activeInvoked => _union(_active, (r) => r.invoked);

  bool get activeHasAwait => _any(_active, (r) => r.hasAwait);
  bool get activeHasAsyncBody => _any(_active, (r) => r.hasAsyncBody);

  static const _code = [Region.rebuild, Region.lifecycle, Region.inert];
  static const _active = [Region.rebuild, Region.lifecycle];

  Set<String> _union(
    List<Region> regions,
    Set<String> Function(RegionFacts) pick,
  ) => {for (final r in regions) ...pick(region(r))};

  bool _any(List<Region> regions, bool Function(RegionFacts) pick) =>
      regions.any((r) => pick(region(r)));
}

/// A declared member and the span that carries its region, so propagation can promote it.
class _Member {
  _Member(this.name, this.span);
  final String name;
  final _Span span;
}

/// One region's extent in the source. Spans nest; the innermost containing span wins.
class _Span {
  _Span(this.offset, this.end, this.region);
  final int offset;
  final int end;

  /// Not final. `_propagateRegions` promotes a member's span once it finds a reference to
  /// that member from a rebuild or lifecycle region. Ordering is by `offset`, which never
  /// moves, so promoting in place does not disturb the binary search.
  Region region;
}

class FactCollector extends RecursiveAstVisitor<void> {
  final facts = Facts();

  /// Sorted by `offset` ascending. Empty until `indexRegions` runs.
  final _spans = <_Span>[];
  var _indexed = false;
  var _standInStart = -1;

  /// Build the region map for `unit`. Call BEFORE `unit.accept(this)` and before
  /// `collectNames`, or every fact lands in `Region.rebuild` and the rules behave as they
  /// did before regions existed.
  ///
  /// `source` is the raw text, needed only to find `spm isolate`'s stand-in banner -- the
  /// banner is a comment, and comments are not in the visited tree.
  void indexRegions(CompilationUnit unit, String source) {
    _standInStart = standInStart(source);
    final indexer = _RegionIndexer(_spans);
    unit.accept(indexer);
    _spans.sort((a, b) => a.offset != b.offset
        ? a.offset.compareTo(b.offset)
        : b.end.compareTo(a.end));
    // `regionAt` is what propagation asks about a reference, so the map has to be live
    // before it runs.
    _indexed = true;
    _propagateRegions(unit, indexer.members);
  }

  /// Promotes a member whose body a rebuild can actually reach.
  ///
  /// `_RegionIndexer` reads a declaration in isolation, so it seeds every member that is
  /// neither a lifecycle hook nor widget-returning as `inert`. That is wrong the moment
  /// something on the build path calls it: the shape found in v2 groups 0608 and 0616 is an
  /// `initState` whose own body carries no vocabulary calling a `_load()` that awaits and
  /// then calls `setState`, which fires inside the measured span.
  ///
  /// So a member's region is the MAXIMUM over its seed and every reference to it from
  /// outside its own body. Maximum is the whole correctness argument: a `_load` reached from
  /// both `initState` and `onPressed` has to come out `lifecycle`, not `inert`.
  ///
  /// Matching is by name within the unit, because this package parses without resolving.
  /// That over-links, and over-linking is the safe direction here: it keeps a member active
  /// that might not be reachable, and a false exclusion costs one role where a false
  /// retention costs a measurement that violates the research scope.
  ///
  /// Regions only ever move up the lattice, which is bounded, so the loop terminates. Two
  /// inert members that call only each other never rise, which is the answer for mutual
  /// recursion.
  void _propagateRegions(CompilationUnit unit, List<_Member> members) {
    if (members.isEmpty) return;
    final declared = {for (final m in members) m.name};

    // Reference offsets per member name, read from the token stream for the same reason
    // `collectNames` does: analyzer 14 leaves many names as bare tokens.
    final refs = <String, List<int>>{};
    var token = unit.beginToken;
    while (!token.isEof) {
      if (token.isIdentifier && declared.contains(token.lexeme)) {
        refs.putIfAbsent(token.lexeme, () => []).add(token.offset);
      }
      final next = token.next;
      if (next == null) break;
      token = next;
    }

    var changed = true;
    while (changed) {
      changed = false;
      for (final m in members) {
        if (m.span.region == Region.rebuild) continue; // already at the top
        var best = m.span.region;
        for (final offset in refs[m.name] ?? const <int>[]) {
          // A reference inside the member's own body, its declaration name included, says
          // nothing about who can reach it.
          if (offset >= m.span.offset && offset < m.span.end) continue;
          final at = regionAt(offset);
          if (_rank(at) > _rank(best)) best = at;
        }
        if (best != m.span.region) {
          m.span.region = best;
          changed = true;
        }
      }
    }
  }

  /// Lattice order. `standIn` ranks below `inert` so a reference the extractor generated
  /// can never promote a member.
  static int _rank(Region r) => switch (r) {
    Region.rebuild => 2,
    Region.lifecycle => 1,
    Region.inert => 0,
    Region.standIn => -1,
  };

  /// The region an offset falls in. Innermost span wins; the stand-in block outranks
  /// everything, because a declaration the extractor generated is scaffolding wherever the
  /// AST happens to place it.
  Region regionAt(int offset) {
    if (!_indexed) return Region.rebuild;
    if (_standInStart >= 0 && offset >= _standInStart) return Region.standIn;
    // Spans are sorted by offset. Every candidate starts at or before `offset`; among
    // those, the innermost is the one that starts LAST and still ends after `offset`.
    var lo = 0, hi = _spans.length;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (_spans[mid].offset <= offset) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    for (var i = lo - 1; i >= 0; i--) {
      if (_spans[i].end > offset) return _spans[i].region;
    }
    return Region.rebuild;
  }

  RegionFacts _at(int offset) => facts.region(regionAt(offset));

  /// Every identifier token in the unit, which is where `names` comes from. Call once per
  /// unit, alongside `unit.accept(this)`.
  void collectNames(CompilationUnit unit) {
    var token = unit.beginToken;
    while (!token.isEof) {
      if (token.isIdentifier) {
        facts.names.add(token.lexeme);
        _at(token.offset).names.add(token.lexeme);
      }
      final next = token.next;
      if (next == null) break;
      token = next;
    }
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    final q = '${node.prefix.name}.${node.identifier.name}';
    facts.qualified.add(q);
    _at(node.offset).qualified.add(q);
    super.visitPrefixedIdentifier(node);
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    final target = node.target;
    if (target is SimpleIdentifier) {
      final q = '${target.name}.${node.propertyName.name}';
      facts.qualified.add(q);
      _at(node.offset).qualified.add(q);
    }
    super.visitPropertyAccess(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final target = node.target;
    if (target is SimpleIdentifier) {
      final q = '${target.name}.${node.methodName.name}';
      facts.qualified.add(q);
      _at(node.offset).qualified.add(q);
    }
    // Unresolved, a bare `File('x')` or `MaterialApp(...)` lands here rather than in
    // visitInstanceCreationExpression. Prefixed too: `\bFile\s*\(` matched `math.File(`
    // as well, and `math.Random()` is exactly as non-deterministic as `Random()`.
    facts.invoked.add(node.methodName.name);
    _at(node.offset).invoked.add(node.methodName.name);
    super.visitMethodInvocation(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final ctor = node.constructorName;
    final typeName = ctor.type.name.lexeme;
    facts.invoked.add(typeName);
    _at(node.offset).invoked.add(typeName);
    final named = ctor.name;
    if (named != null) {
      final q = '$typeName.${named.name}';
      facts.qualified.add(q);
      _at(node.offset).qualified.add(q);
    }
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitWithClause(WithClause node) {
    for (final m in node.mixinTypes) {
      facts.mixins.add(m.name.lexeme);
    }
    super.visitWithClause(node);
  }

  @override
  void visitImportDirective(ImportDirective node) {
    facts.imports.add(node.uri.stringValue ?? '');
    super.visitImportDirective(node);
  }

  @override
  void visitAwaitExpression(AwaitExpression node) {
    facts.hasAwait = true;
    _at(node.offset).hasAwait = true;
    super.visitAwaitExpression(node);
  }

  @override
  void visitBlockFunctionBody(BlockFunctionBody node) {
    if (node.isAsynchronous) {
      facts.hasAsyncBody = true;
      _at(node.offset).hasAsyncBody = true;
    }
    super.visitBlockFunctionBody(node);
  }

  @override
  void visitExpressionFunctionBody(ExpressionFunctionBody node) {
    if (node.isAsynchronous) {
      facts.hasAsyncBody = true;
      _at(node.offset).hasAsyncBody = true;
    }
    super.visitExpressionFunctionBody(node);
  }
}

/// Collects the extents that `FactCollector.regionAt` resolves against.
///
/// Only spans that DIFFER from the enclosing default are worth recording -- `rebuild` is
/// what an unmatched offset resolves to anyway -- but `build` and widget-returning helpers
/// are recorded explicitly so that a handler nested inside one resolves correctly by
/// nesting rather than by luck.
class _RegionIndexer extends RecursiveAstVisitor<void> {
  _RegionIndexer(this.spans);
  final List<_Span> spans;

  /// Method declarations and the span each one seeded, for `_propagateRegions`.
  final members = <_Member>[];

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final name = node.name.lexeme;
    final Region region;
    if (kLifecycleMembers.contains(name)) {
      region = Region.lifecycle;
    } else if (name == 'build' || _returnsWidget(node.returnType)) {
      region = Region.rebuild;
    } else {
      // A service method, an event handler written as a member, `dispose`. Not reachable
      // from a rebuild unless something in the rebuild path calls it -- and if it is
      // called from `build`, the CALL SITE is in the rebuild region and its own vocabulary
      // fires there.
      region = Region.inert;
    }
    final span = _Span(node.offset, node.end, region);
    spans.add(span);
    members.add(_Member(name, span));
    super.visitMethodDeclaration(node);
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    // Runs when the element is created, which is inside the measured mount.
    spans.add(_Span(node.offset, node.end, Region.lifecycle));
    super.visitConstructorDeclaration(node);
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    // `late final _future = api.fetch();` completes mid-measurement exactly as an
    // `initState` call does. A field with no initialiser carries no executable code, but
    // its TYPE is still evidence, so the span is recorded either way.
    spans.add(_Span(node.offset, node.end, Region.lifecycle));
    super.visitFieldDeclaration(node);
  }

  @override
  void visitNamedArgument(NamedArgument node) {
    // Analyzer 14 models `onPressed: () {...}` as a `NamedArgument` whose `name` is a bare
    // `Token`, not a `Label` node -- the same token-vs-node split the library docstring
    // records for identifiers.
    final expr = node.argumentExpression;
    // A closure and a tear-off defer their body the same way, and `onPressed: _submit` is
    // as much a deferred call site as `onPressed: () => submit()`. Marking only the closure
    // left the tear-off's reference sitting in the rebuild region, which promoted the very
    // member the slot was deferring.
    //
    // Any other shape keeps counting. `onTap: enabled ? _a : _b` evaluates during the build,
    // and narrowing it would deactivate whatever the condition itself calls.
    if ((expr is FunctionExpression || expr is SimpleIdentifier) &&
        isInteractionCallback(node.name.lexeme)) {
      spans.add(_Span(expr.offset, expr.end, Region.inert));
    }
    super.visitNamedArgument(node);
  }
}

/// Whether a declared return type names `Widget`. Unresolved parsing means this is a
/// syntactic check: `Widget`, `Widget?`, `List<Widget>` and `PreferredSizeWidget` all
/// count, and a helper declared `dynamic` does not. Erring toward `rebuild` is the
/// conservative direction.
bool _returnsWidget(TypeAnnotation? type) =>
    type != null && type.toSource().contains('Widget');
