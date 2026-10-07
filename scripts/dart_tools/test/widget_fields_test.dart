/// What the constructor-field lift does to a transplant, per mode.
///
/// Every case here is a shape the 2026-09 mine actually produced. The `late final` cases in
/// particular are not hypothetical: a lifted field is assigned exactly once by the `initState`
/// the lift writes, so `final` is the honest modifier -- but the scope's own code may assign a
/// name the lift chose, and `final` there does not compile. The corpus must build.
library;

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:dart_tools/src/widget_fields.dart';
import 'package:test/test.dart';

LiftResult liftOf(String source, {LiftMode mode = LiftMode.state}) {
  final parsed = parseString(content: source, throwIfDiagnostics: false);
  return liftWidgetFields(source, parsed.unit, mode: mode);
}

/// A transplant in the shape `spm isolate` emits: the commit's own constructor, copied
/// verbatim, which is why nothing could write `GeneratedWidget()` until state mode dropped
/// it.
String unit({
  String widgetFields = '  final String title;',
  String widgetCtor = '  const GeneratedWidget({required this.title, super.key});',
  String stateMembers = '',
  String buildBody = '    return Text(widget.title);',
}) =>
    '''
import 'package:flutter/material.dart';

class GeneratedWidget extends StatefulWidget {
$widgetFields
$widgetCtor
  @override
  State<GeneratedWidget> createState() => _GeneratedWidgetState();
}

class _GeneratedWidgetState extends State<GeneratedWidget> {
$stateMembers
  @override
  Widget build(BuildContext context) {
$buildBody
  }
}
''';

void main() {
  group('state mode', () {
    test('a field nothing reassigns is declared late final', () {
      final result = liftOf(unit());
      expect(result.fields.single.binding, 'fixtureTitle');
      expect(result.text, contains('late final String title;'));
      expect(result.text, isNot(contains('late String title;')));
    });

    test('a field the scope reassigns keeps bare late, so it still compiles', () {
      // `title = ...` inside a member: `late final` would be a compile error, and a corpus
      // that does not build is worse than one carrying a weaker modifier.
      final result = liftOf(unit(
        stateMembers: '  void reset() { title = "x"; }',
        buildBody: '    return Text(widget.title);',
      ));
      expect(result.text, contains('late String title;'));
      expect(result.text, isNot(contains('late final String title;')));
    });

    test('compound assignment and increment count as assignment', () {
      for (final body in ['count += 1;', 'count++;', '--count;']) {
        final result = liftOf(unit(
          widgetFields: '  final int count;',
          widgetCtor: '  const GeneratedWidget({required this.count, super.key});',
          stateMembers: '  void bump() { $body }',
          buildBody: '    return Text("\${widget.count}");',
        ));
        expect(result.text, contains('late int count;'), reason: body);
        expect(result.text, isNot(contains('late final int count;')), reason: body);
      }
    });

    test('assignment to someone else\'s member of the same name does not drop final', () {
      final result = liftOf(unit(
        stateMembers: '  void push(dynamic other) { other.title = "x"; }',
      ));
      expect(result.text, contains('late final String title;'));
    });

    test('the mount assignment lands after super.initState()', () {
      final result = liftOf(unit(
        stateMembers: '  @override\n'
            '  void initState() {\n'
            '    super.initState();\n'
            '    debugPrint("own");\n'
            '  }\n',
      ));
      final body = result.text;
      // The INDENTED form. State mode leaves no other assignment of this binding in the
      // file, but the indentation is what makes the assertion about the initState statement
      // rather than about any line that happens to carry the same text.
      const mount = '    title = fixtureTitle;';
      expect(body.indexOf(mount), greaterThan(body.indexOf('super.initState();')));
      // Before the scope's own statements: a lifted field read by anything the scope wrote
      // in initState would otherwise be read before it is assigned.
      expect(body.indexOf(mount), lessThan(body.indexOf('debugPrint')));
    });

    test('a State with no initState gets one written', () {
      final result = liftOf(unit());
      expect(result.text, contains('void initState() {'));
      expect(result.text, contains('super.initState();'));
      expect(result.text, contains('title = fixtureTitle;'));
    });

    test('widget.title becomes title inside the State', () {
      final result = liftOf(unit());
      expect(result.text, contains('return Text(title);'));
      expect(result.text, isNot(contains('widget.title')));
    });

    test('the binding is declared, never valued', () {
      final result = liftOf(unit());
      expect(result.text, contains('late String fixtureTitle;'));
      // Nothing here invents a value: `fixture_skeleton` stamps `// TODO: value` and
      // `fixture_gate` refuses the group until it is filled.
      expect(result.text, isNot(contains("fixtureTitle = '")));
    });

    test('the widget is left constructible with no argument', () {
      // `lib/main.dart` and `scripts/reset_lib.sh` both write `body: GeneratedWidget()`, so
      // this is the whole point of the lift: a role whose commit declared `required
      // this.title` did not compile when it was staged.
      final result = liftOf(unit());
      expect(result.text, contains('const GeneratedWidget({super.key});'));
      expect(result.text, isNot(contains('required this.title')));
      expect(result.text, isNot(contains('GeneratedWidget.fixture')));
    });

    test('the lifted field leaves the widget, since the State declares it now', () {
      final result = liftOf(unit());
      expect(result.text, isNot(contains('  final String title;')));
      expect(result.text, contains('late final String title;'));
    });

    test('a widget the commit gave no constructor still gets the bare one', () {
      final result = liftOf(unit(widgetCtor: ''));
      expect(result.text, contains('const GeneratedWidget({super.key});'));
    });

    test('a field the lift did not take keeps the widget as it was', () {
      // An untyped `final` is what `_constructorFields` skips, because inferring a type here
      // would be a guess. Dropping the constructor would leave it uninitialised, the file
      // would not compile, and `spm analyze` skips a file with errors -- so the role would
      // lose the vector this pass exists to give it.
      final result = liftOf(unit(
        widgetFields: '  final String title;\n  final untyped;',
        widgetCtor:
            '  const GeneratedWidget({required this.title, required this.untyped, super.key});',
      ));
      expect(result.text, contains('required this.title'));
      expect(result.text,
          contains('GeneratedWidget.fixture({super.key}) : title = fixtureTitle;'));
    });

    test('a surviving field with its own value costs the constructor its const', () {
      final result = liftOf(unit(
        widgetFields: '  final String title;\n'
            '  final controller = TextEditingController();',
      ));
      expect(result.text, contains('GeneratedWidget({super.key});'));
      expect(result.text, isNot(contains('const GeneratedWidget({super.key});')));
      expect(result.text, contains('final controller = TextEditingController();'));
    });

    test('a field whose type nothing could build still mounts', () {
      // The defect this fixes: `_buildFixtureConstructor` returned '' for these, and the
      // role could not be mounted at all.
      final result = liftOf(unit(
        widgetFields: '  final AnimationController? controller;',
        widgetCtor: '  const GeneratedWidget({this.controller, super.key});',
        buildBody: '    return Text("\${widget.controller}");',
      ));
      expect(result.text, contains('controller = fixtureController'));
      expect(result.text, contains('late AnimationController? fixtureController;'));
      expect(result.text, contains('const GeneratedWidget({super.key});'));
    });

    test('the lift is idempotent: a second pass over an exported tree changes nothing', () {
      final once = liftOf(unit());
      final twice = liftOf(once.text);
      expect(twice.fields, isEmpty);
      expect(twice.text, once.text);
    });

    test('a name the State already declares is renamed, not shadowed', () {
      final result = liftOf(unit(
        stateMembers: '  String title = "mine";',
        buildBody: '    return Text(widget.title + title);',
      ));
      expect(result.text, contains('widgetTitle'));
      expect(result.text, contains('return Text(widgetTitle + title);'));
    });
  });

  group('constructor mode', () {
    test('the build body is left byte-identical', () {
      final result = liftOf(unit(), mode: LiftMode.constructor);
      expect(result.text, contains('return Text(widget.title);'));
      expect(result.text, isNot(contains('late final String title;')));
    });

    test('but the binding and the fixture constructor still arrive', () {
      final result = liftOf(unit(), mode: LiftMode.constructor);
      expect(result.text, contains('late String fixtureTitle;'));
      expect(result.text, contains('title = fixtureTitle'));
    });
  });
}
