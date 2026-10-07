/// R19/R20: shim constructors that drop the child their call site supplied.
///
/// WHAT GOES WRONG. `spm isolate` replaces a widget it will not carry with a SHIM -- a class
/// mirroring the real one's constructors and supertypes, whose `build` renders exactly ONE
/// pass-through parameter. `ShimEmitter._passThroughFor` picks that parameter over the UNION
/// of every constructor the class declares, preferring `child`, then `body`, then `children`,
/// and `_renderShimBuild` renders it: `children` wraps in a `Stack`, anything else is used
/// where it is, and a shim with no pass-through at all renders `const SizedBox.shrink()`.
///
/// A constructor that does not declare the chosen parameter therefore initialises it to
/// `null` and renders NOTHING, while still accepting -- and discarding -- whatever the call
/// site handed it. Every builder-form constructor is in this position: the field is declared
/// by the literal-`children` constructor, so `StaggeredGridView.countBuilder(itemBuilder:,
/// itemCount:)` renders an empty `Stack` where the application drew a grid of items.
///
/// GROUP 0082 is why this exists. Its two revisions differ by exactly
/// `StaggeredGridView.countBuilder(...)` -> `StaggeredGrid.count(children: [...])`. The
/// first renders nothing, the second renders all three items, and the measured delta is the
/// shim's constructor coverage rather than the developer's edit. `R13_binding_set` cannot see
/// it: both endpoints mount from an identical binding set, and the asymmetry is in what the
/// shim DOES with them.
///
/// A SHIM IS NOT EVERY CLASS BELOW THE BANNER. Since 0.6.0 `spm isolate` also CARRIES a
/// third-party widget's own source into the transplant, and carried source lands in the same
/// region -- with a real `build` that renders its children properly. A constructor of one of
/// those that does not take `child`/`children` is not dropping anything. So a class counts as
/// a shim only when its `build` is one of the three bodies `_renderShimBuild` emits, matched
/// against the emitted text: without that check this fired on 2,409 roles instead of the
/// 1,344 that have a shim at all, and every carried `ToolBar`/`Sidebar` read as a drop.
///
/// WHAT IS DECIDED HERE, AND WHAT IS NOT. This reports drops per file; the two rules that
/// read them live in `rules.dart` (R19, role-level and soft) and `scripts/screen/shims.py`
/// (R20, pair-level and hard). The partition matters: a drop on BOTH endpoints understates
/// the magnitude of a delta the way `R12_inline_reverted` does, and is soft for the same
/// reason; a drop on ONE endpoint makes the delta unattributable, and is hard for the reason
/// R13 is.
///
/// PARSE-ONLY, AND WHY THAT SHAPES THE VISITOR. `parseString` does no resolution, so
/// `StaggeredGridView.countBuilder(...)` without `const`/`new` is not an
/// `InstanceCreationExpression` at all -- the parser cannot know the name is a class, and it
/// lands in `visitMethodInvocation` as a target plus a method name. `ThemeSwitcher(builder:)`
/// lands there too, with no target. Both shapes are matched, the same way `FactCollector`
/// matches both; looking only at instance creations would have found 1 of the corpus's drops
/// and missed the rest.
///
/// Parse-only, like everything else here. The shim region is found by the same banner
/// boundary `standInStart` gives the region map and the R7 hash, and the shim's own
/// declaration is the only thing consulted -- nothing depends on `package:` resolving, which
/// is what lets this run against a mined transplant at all.
library;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'fixture.dart' show declarationNameToken, standInStart;
// `classMembers` reads the body across both analyzer versions the package supports:
// analyzer 14 moved a class's members onto a `body` child and dropped the getter.
import 'widget_fields.dart' show classMembers;

/// The parameter a shim's `build` hands on, in `ShimEmitter._passThroughParameters` order.
/// Mirrored, not imported: spm is a subprocess here and never a library, so the two lists
/// are kept identical by this comment and by `shims_test.dart`.
const kPassThroughParameters = <String>['child', 'body', 'children'];

/// Arguments that supply a subtree, and are silently discarded by a constructor that does
/// not declare the pass-through parameter.
///
/// `itemCount` and `crossAxisCount` are not children themselves, but a call site passing one
/// is building a list whose extent is the count -- which is tree size, and therefore the
/// dependent variable. Included so a drop reports the whole shape of what was lost.
const kChildBearingArguments = <String>{
  'child', 'children', 'body',
  'itemBuilder', 'separatorBuilder', 'staggeredTileBuilder', 'tileBuilder',
  'childrenDelegate', 'delegate', 'builder', 'pageBuilder', 'contentBuilder',
  'slivers', 'tiles', 'items', 'pages', 'tabs', 'actions',
  'itemCount',
};

/// A subset of the above that supplies subtrees by CALLING BACK, which is the form no shim
/// can render without synthesising the loop the real widget runs.
const kBuilderArguments = <String>{
  'itemBuilder', 'separatorBuilder', 'staggeredTileBuilder', 'tileBuilder',
  'childrenDelegate', 'delegate', 'builder', 'pageBuilder', 'contentBuilder',
};

/// One call site whose shim renders none of the subtree it was handed.
class ShimDrop {
  /// The shim class named at the call site.
  final String className;

  /// The named constructor invoked, or `''` for the unnamed one.
  final String constructorName;

  /// The pass-through parameter the shim's `build` renders, or null when it has none and
  /// therefore renders `const SizedBox.shrink()` from every constructor.
  final String? passThrough;

  /// Child-bearing arguments the call site passed and the shim discards, sorted.
  final List<String> discarded;

  /// The subset of [discarded] that supplies subtrees by callback.
  final List<String> builders;

  const ShimDrop({
    required this.className,
    required this.constructorName,
    required this.passThrough,
    required this.discarded,
    required this.builders,
  });

  Map<String, Object?> toJson() => {
        'class': className,
        'constructor': constructorName,
        'passThrough': passThrough,
        'discarded': discarded,
        'builders': builders,
      };

  /// What R20 compares. Two endpoints agreeing on this set agree about the subtree the shim
  /// erases, so the delta between them is still the edit; disagreeing makes it the shim.
  String get key => '$className.$constructorName';
}

/// Every call site in [unit]'s TRANSPLANTED code whose shim discards the subtree it supplied.
///
/// The transplant is what precedes `standInStart`; a shim reaching another shim is not a
/// finding, because neither is code the commit contained. A unit with no stand-in banner has
/// no shims and returns empty, which is every file `spm isolate` did not have to reconstruct
/// anything for.
List<ShimDrop> shimChildDrops(String source, CompilationUnit unit) {
  final boundary = standInStart(source);
  if (boundary < 0) return const [];

  final shims = <String, _Shim>{};
  for (final member in unit.declarations) {
    if (member is! ClassDeclaration || member.offset < boundary) continue;
    final name = declarationNameToken(member)?.lexeme;
    if (name == null) continue;
    final shim = _Shim.of(member, source);
    if (shim != null) shims[name] = shim;
  }
  if (shims.isEmpty) return const [];

  final finder = _CallSiteFinder(shims, boundary);
  unit.accept(finder);
  return finder.drops;
}

/// A shim's constructors and the one parameter its `build` renders.
class _Shim {
  /// Constructor name (`''` unnamed) -> the parameter names it declares.
  final Map<String, Set<String>> constructors;
  final String? passThrough;

  _Shim(this.constructors, this.passThrough);

  /// The class as a shim, or null when its `build` is not one `ShimEmitter` wrote -- which
  /// is what tells a stand-in apart from third-party source the transplant CARRIES.
  static _Shim? of(ClassDeclaration declaration, String source) {
    final constructors = <String, Set<String>>{};
    for (final member in classMembers(declaration)) {
      if (member is! ConstructorDeclaration) continue;
      constructors[member.name?.lexeme ?? ''] = {
        for (final parameter in member.parameters.parameters)
          if (parameter.name != null) parameter.name!.lexeme,
      };
    }
    // The union, and in the emitter's preference order: this is `_passThroughFor`, and
    // reproducing its choice is the whole point -- picking a different parameter here would
    // report drops the emitted `build` does not have.
    final declared = {for (final names in constructors.values) ...names};
    String? passThrough;
    for (final candidate in kPassThroughParameters) {
      if (declared.contains(candidate)) {
        passThrough = candidate;
        break;
      }
    }
    if (!_rendersShimBody(declaration, source, passThrough)) return null;
    return _Shim(constructors, passThrough);
  }

  /// True when [constructorName] renders nothing: either the class has no pass-through at
  /// all, or this constructor is not the one that declares it.
  bool drops(String constructorName) =>
      passThrough == null ||
      !(constructors[constructorName] ?? const <String>{}).contains(passThrough);

  bool declares(String constructorName) => constructors.containsKey(constructorName);
}

/// The three bodies `ShimEmitter._renderShimBuild` emits, for a given pass-through.
///
/// Compared as whitespace-normalised text rather than structurally: the emitter writes these
/// as string literals, so text is what it actually produces, and a structural matcher would
/// have to re-derive a shape that is not otherwise expressed anywhere on this side.
List<String> _shimBodies(String? passThrough) {
  if (passThrough == null) return const ['=> const SizedBox.shrink();'];
  if (passThrough == 'children') {
    return const [
      '=> Stack( children: children is List<Widget> ? children as List<Widget> '
          ': const <Widget>[], );',
    ];
  }
  return [
    '=> \$passThrough is Widget ? \$passThrough as Widget : const SizedBox.shrink();'
        .replaceAll('\$passThrough', passThrough),
  ];
}

String _squash(String text) => text.replaceAll(RegExp(r'\s+'), ' ').trim();

/// True when [declaration] declares a `build` whose body is one the emitter writes.
bool _rendersShimBody(ClassDeclaration declaration, String source, String? passThrough) {
  for (final member in classMembers(declaration)) {
    if (member is! MethodDeclaration) continue;
    if (member.name.lexeme != 'build') continue;
    final body = _squash(source.substring(member.body.offset, member.body.end));
    return _shimBodies(passThrough).any((emitted) => body == _squash(emitted));
  }
  // No `build` at all: not a widget stand-in, so it renders nothing and drops nothing.
  return false;
}

class _CallSiteFinder extends RecursiveAstVisitor<void> {
  _CallSiteFinder(this._shims, this._boundary);

  final Map<String, _Shim> _shims;
  final int _boundary;
  final drops = <ShimDrop>[];

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final ctor = node.constructorName;
    _consider(node.offset, ctor.type.name.lexeme, ctor.name?.name ?? '',
        node.argumentList);
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final target = node.target;
    if (target is SimpleIdentifier && _shims.containsKey(target.name)) {
      // `Shim.named(...)` -- a named constructor the parser read as a method on a name.
      _consider(node.offset, target.name, node.methodName.name, node.argumentList);
    } else if (target == null && _shims.containsKey(node.methodName.name)) {
      // `Shim(...)` -- the unnamed constructor.
      _consider(node.offset, node.methodName.name, '', node.argumentList);
    }
    super.visitMethodInvocation(node);
  }

  void _consider(int offset, String className, String constructorName,
      ArgumentList arguments) {
    // Inside the stand-in region: one shim reaching another is reconstruction, not the
    // code the commit contained, and excluding a scope for it would exclude on spm's
    // output rather than on the application's.
    if (offset >= _boundary) return;
    final shim = _shims[className];
    if (shim == null) return;
    // An unrecognised constructor name means the type is shadowed by something this is not
    // looking at; saying nothing is the conservative direction for a rule that excludes.
    if (!shim.declares(constructorName) || !shim.drops(constructorName)) return;

    final passed = <String>{
      for (final argument in arguments.arguments)
        if (argument is NamedArgument) argument.name.lexeme,
    };
    final discarded = passed.intersection(kChildBearingArguments).toList()..sort();
    if (discarded.isEmpty) return;
    final builders = passed.intersection(kBuilderArguments).toList()..sort();
    drops.add(ShimDrop(
      className: className,
      constructorName: constructorName,
      passThrough: shim.passThrough,
      discarded: discarded,
      builders: builders,
    ));
  }
}
