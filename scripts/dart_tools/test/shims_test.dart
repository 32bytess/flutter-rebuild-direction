/// What R19's detector must find in a shim, and what it must not claim.
///
/// The inputs are group 0082 reduced to the smallest program that still has its defect: one
/// shim with a literal-`children` constructor and a builder-form one, reached from the
/// transplanted `build`. Every expectation is a rule stated in `lib/src/shims.dart`.
library;

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:dart_tools/src/shims.dart';
import 'package:test/test.dart';

/// `spm isolate`'s shim shape: ONE pass-through field, chosen over the union of the
/// constructors, and a `build` that renders it or renders nothing.
const _shim = '''

// Declaration-only stand-ins
class MiniGrid extends StatelessWidget {
  final dynamic children;
  MiniGrid.count({super.key, dynamic crossAxisCount, this.children});
  MiniGrid.builder({super.key, dynamic itemBuilder, dynamic itemCount})
      : children = null;
  @override
  Widget build(BuildContext context) => Stack(
    children: children is List<Widget>
        ? children as List<Widget>
        : const <Widget>[],
  );
}
''';

String _unit(String buildBody, {String shim = _shim}) => '''
import 'package:flutter/material.dart';

class _GeneratedWidgetState extends State<GeneratedWidget> {
  @override
  Widget build(BuildContext context) {
$buildBody
  }
}

// Fixture block
late int fixtureCount;
$shim''';

List<ShimDrop> _drops(String source) =>
    shimChildDrops(source, parseString(content: source).unit);

void main() {
  test('the builder form drops the children it was handed', () {
    final drops = _drops(_unit('''
    return MiniGrid.builder(
      itemBuilder: (BuildContext c, int i) => const Text('row'),
      itemCount: 3,
    );'''));
    expect(drops, hasLength(1));
    expect(drops.single.className, 'MiniGrid');
    expect(drops.single.constructorName, 'builder');
    expect(drops.single.passThrough, 'children');
    expect(drops.single.discarded, ['itemBuilder', 'itemCount']);
    expect(drops.single.builders, ['itemBuilder']);
    expect(drops.single.key, 'MiniGrid.builder');
  });

  test('the literal-children form drops nothing', () {
    expect(
        _drops(_unit('''
    return MiniGrid.count(
      crossAxisCount: 2,
      children: const [Text('row')],
    );''')),
        isEmpty);
  });

  test('a constructor passing no child-bearing argument is not a drop', () {
    // Nothing was handed over, so nothing was discarded. Reporting here would exclude a
    // scope for a shim it merely mentions.
    expect(_drops(_unit('    return MiniGrid.builder();')), isEmpty);
  });

  test('a shim with no pass-through parameter drops from every constructor', () {
    // `_renderShimBuild(null)` is `const SizedBox.shrink()`, so the subtree is erased
    // whichever constructor the call site used.
    const shim = '''

// Declaration-only stand-ins
class MiniLeaf extends StatelessWidget {
  MiniLeaf.of({super.key, dynamic builder});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
''';
    final drops = _drops(
        _unit('    return MiniLeaf.of(builder: (c) => const Text("x"));', shim: shim));
    expect(drops, hasLength(1));
    expect(drops.single.passThrough, isNull);
    expect(drops.single.discarded, ['builder']);
  });

  test('a call site inside the stand-in region is not a finding', () {
    // One shim reaching another is reconstruction, not the code the commit contained.
    const shim = '''

// Declaration-only stand-ins
class MiniOuter extends StatelessWidget {
  final dynamic child;
  MiniOuter({super.key, this.child});
  MiniOuter.wrapped({super.key, dynamic builder}) : child = null;
  @override
  Widget build(BuildContext context) =>
      child is Widget ? child as Widget : const SizedBox.shrink();
}

class MiniInner extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      MiniOuter.wrapped(builder: (c) => const Text('x'));
}
''';
    expect(_drops(_unit('    return const Text("plain");', shim: shim)), isEmpty);
  });

  test('a unit with no stand-in banner has no shims', () {
    const source = '''
import 'package:flutter/material.dart';

class MiniGrid extends StatelessWidget {
  final dynamic children;
  MiniGrid.builder({dynamic itemBuilder}) : children = null;
  @override
  Widget build(BuildContext context) => Stack(
    children: children is List<Widget>
        ? children as List<Widget>
        : const <Widget>[],
  );
}

Widget top() => MiniGrid.builder(itemBuilder: (c, i) => const Text('x'));
''';
    // No banner means `spm isolate` reconstructed nothing, so the class is the application's
    // own and its `build` is the one the commit contained.
    expect(_drops(source), isEmpty);
  });

  test('third-party source the transplant CARRIES is not a shim', () {
    // 0.6.0+ inlines a third-party widget's own source, and it lands below the same banner
    // with a real `build` that renders its children properly. `MiniCarried.builder` takes no
    // `children`, but nothing is discarded: the builder is what the widget uses.
    const carried = '''

// Declaration-only stand-ins
class MiniCarried extends StatelessWidget {
  final List<Widget>? children;
  final Widget Function(BuildContext, int)? itemBuilder;
  final int itemCount;
  const MiniCarried({super.key, this.children}) : itemBuilder = null, itemCount = 0;
  const MiniCarried.builder({super.key, this.itemBuilder, this.itemCount = 0})
      : children = null;
  @override
  Widget build(BuildContext context) => Column(
        children: children ??
            List<Widget>.generate(itemCount, (int i) => itemBuilder!(context, i)),
      );
}
''';
    expect(
        _drops(_unit(
            '    return MiniCarried.builder(itemBuilder: (c, i) => const Text("x"), '
            'itemCount: 3);',
            shim: carried)),
        isEmpty);
  });

  test('the pass-through preference order is the emitter\'s', () {
    // `child` outranks `children`, so the constructor declaring `children` is the one that
    // drops -- the reverse of the 0082 case, and the reason the order is in the digest.
    const shim = '''

// Declaration-only stand-ins
class MiniEither extends StatelessWidget {
  final dynamic child;
  MiniEither.one({super.key, this.child});
  MiniEither.many({super.key, dynamic children}) : child = null;
  @override
  Widget build(BuildContext context) =>
      child is Widget ? child as Widget : const SizedBox.shrink();
}
''';
    expect(kPassThroughParameters, ['child', 'body', 'children']);
    final drops = _drops(
        _unit('    return MiniEither.many(children: const [Text("x")]);', shim: shim));
    expect(drops.single.passThrough, 'child');
    expect(drops.single.discarded, ['children']);
  });
}
