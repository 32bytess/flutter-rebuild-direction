/// Which members a measured rebuild can reach, and therefore whose vocabulary R2 and R3 read.
///
/// `_RegionIndexer` reads a declaration in isolation, so it seeds every member that is
/// neither a lifecycle hook nor widget-returning as `inert`. That is only safe because
/// `FactCollector._propagateRegions` then promotes whatever the build path calls. These
/// cases are the ones that decide whether the promotion is right, and the first is the
/// shape that kept the finer rule switched off until now.
library;

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:dart_tools/src/facts.dart';
import 'package:dart_tools/src/rules.dart';
import 'package:test/test.dart';

/// Screens one transplant the way `screen_samples` does, regions included.
List<String> screen(String source) {
  final unit = parseString(content: source, throwIfDiagnostics: false).unit;
  final collector = FactCollector();
  collector.indexRegions(unit, source);
  unit.accept(collector);
  collector.collectNames(unit);
  return evaluate(collector.facts);
}

String wrap(String members) =>
    '''
import 'package:flutter/material.dart';

class Example extends StatefulWidget {
  const Example({super.key});
  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  List<String> rows = [];
$members
}
''';

void main() {
  group('a rebuild can reach it, so it still fires', () {
    test('async reached from initState fires R2', () {
      // The shape from v2 groups 0608 and 0616. `initState` carries no vocabulary of its
      // own and `_load` is neither a lifecycle member nor widget-returning, so a lexical
      // rule read it as inert and let an asynchronous setState into the measured span.
      final fired = screen(
        wrap('''
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await fetchRows();
    setState(() => rows = data);
  }

  @override
  Widget build(BuildContext context) => Text('\${rows.length}');
'''),
      );
      expect(fired, contains('R2_async'));
    });

    test('a member reached from BOTH a handler and initState fires R2', () {
      // Maximum over the callers, not minimum. Reaching it from `onPressed` must not
      // cancel out reaching it from `initState`.
      final fired = screen(
        wrap('''
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final data = await fetchRows();
    setState(() => rows = data);
  }

  @override
  Widget build(BuildContext context) =>
      TextButton(onPressed: _refresh, child: const Text('go'));
'''),
      );
      expect(fired, contains('R2_async'));
    });

    test('async reached through a builder callback fires R2', () {
      // `itemBuilder` is not an interaction callback, so it stays in the rebuild region
      // and what it calls stays reachable.
      final fired = screen(
        wrap('''
  Future<String> _label(int i) async => await fetchRow(i);

  @override
  Widget build(BuildContext context) => ListView.builder(
        itemCount: rows.length,
        itemBuilder: (context, index) => Text('\${_label(index)}'),
      );
'''),
      );
      expect(fired, contains('R2_async'));
    });

    test('I/O reached from build fires R3', () {
      final fired = screen(
        wrap('''
  String _avatar() => NetworkImage('u').toString();

  @override
  Widget build(BuildContext context) => Text(_avatar());
'''),
      );
      expect(fired, contains('R3_io_network'));
    });
  });

  group('a rebuild cannot reach it, so it no longer fires', () {
    test('async reached only from onPressed does not fire R2', () {
      final fired = screen(
        wrap('''
  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: () async {
          final data = await fetchRows();
          setState(() => rows = data);
        },
        child: const Text('go'),
      );
'''),
      );
      expect(fired, isNot(contains('R2_async')));
    });

    test('a member reached only through a handler tear-off does not fire R2', () {
      // `onPressed: _submit` defers the body exactly as the closure form does.
      final fired = screen(
        wrap('''
  Future<void> _submit() async {
    final data = await fetchRows();
    setState(() => rows = data);
  }

  @override
  Widget build(BuildContext context) =>
      TextButton(onPressed: _submit, child: const Text('go'));
'''),
      );
      expect(fired, isNot(contains('R2_async')));
    });

    test('I/O reached only from a handler does not fire R3', () {
      final fired = screen(
        wrap('''
  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: () => NetworkImage('u').toString(),
        child: const Text('go'),
      );
'''),
      );
      expect(fired, isNot(contains('R3_io_network')));
    });

    test('async in dispose does not fire R2', () {
      // `dispose` runs after the measured span, so nothing it does can perturb it.
      final fired = screen(
        wrap('''
  @override
  void dispose() {
    close().then((_) {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Text('\${rows.length}');
'''),
      );
      expect(fired, isNot(contains('R2_async')));
    });
  });

  group('propagation terminates and stays conservative', () {
    test('two inert members that call only each other stay inert', () {
      final fired = screen(
        wrap('''
  Future<void> _a() async => _b();
  Future<void> _b() async => _a();

  @override
  Widget build(BuildContext context) => Text('\${rows.length}');
'''),
      );
      expect(fired, isNot(contains('R2_async')));
    });

    test('mutual recursion reached from build fires R2', () {
      // The same pair, now reachable. Promotion has to cross both hops.
      final fired = screen(
        wrap('''
  Future<void> _a() async => _b();
  Future<void> _b() async => await fetchRows();

  @override
  Widget build(BuildContext context) {
    _a();
    return Text('\${rows.length}');
  }
'''),
      );
      expect(fired, contains('R2_async'));
    });

    test('an unindexed collector counts everything, as before', () {
      // The compatibility guarantee: skip indexRegions and every fact lands in `rebuild`,
      // which is what `calibration_test` relies on.
      const source = '''
class _S {
  Future<void> _submit() async => await fetchRows();
  Widget build(context) => TextButton(onPressed: _submit, child: Text('go'));
}
''';
      final unit = parseString(content: source, throwIfDiagnostics: false).unit;
      final collector = FactCollector();
      unit.accept(collector);
      collector.collectNames(unit);
      expect(evaluate(collector.facts), contains('R2_async'));
    });
  });
}
