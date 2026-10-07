/// What `branches.dart` sees that the regex it replaces did not.
///
/// Every case here is a measured failure of `scripts/maximal_branch.py`'s scanner, not a
/// hypothetical: the widget/value-object confusion and the lazy builder were both found in
/// the deciding groups of the arm-2 corpus, and the ternary was the shape group `1656`
/// decides on.
library;

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:dart_tools/src/branches.dart';
import 'package:test/test.dart';

Map<String, Object> unitOf(String body) =>
    collectBranches(parseString(content: '''
import 'package:flutter/material.dart';

class _S extends State<GeneratedWidget> {
  bool flag = false;
  Object? maybe;
  List<int> items = const [];

  @override
  Widget build(BuildContext context) {
$body
  }
}
''', throwIfDiagnostics: false).unit);

List<Map<String, Object>> branchesOf(String body) =>
    (unitOf(body)['branches'] as List).cast<Map<String, Object>>();

List<Map<String, String>> assignmentsOf(String body) =>
    (unitOf(body)['assignments'] as List)
        .map((a) => (a as Map).cast<String, String>())
        .toList();

Map<String, Object> only(String body) {
  final found = branchesOf(body);
  expect(found, hasLength(1), reason: 'expected exactly one conditional');
  return found.single;
}

Map<String, Object> arm(Map<String, Object> branch, String which) =>
    branch[which] as Map<String, Object>;

void main() {
  group('conditional kinds the scanner could not see', () {
    test('an if statement is found, with its condition verbatim', () {
      final b = only('''
    if (flag) {
      return Container(child: Text('a'));
    } else {
      return SizedBox();
    }
''');
      expect(b['kind'], 'if');
      expect(b['condition'], 'flag');
      expect(arm(b, 'then')['widgets'], 2);
      expect(arm(b, 'else')['widgets'], 1);
    });

    test('a ternary is found -- invisible to a scanner looking for `if (`', () {
      final b = only("    return flag ? Column(children: [Text('a')]) : SizedBox();");
      expect(b['kind'], 'ternary');
      expect(b['condition'], 'flag');
      expect(arm(b, 'then')['widgets'], 2);
      expect(arm(b, 'else')['widgets'], 1);
    });

    test('a collection if element is found -- ordinary Flutter, also invisible', () {
      final b = only('''
    return Column(children: [
      if (flag) Padding(padding: EdgeInsets.zero, child: Text('a')) else SizedBox(),
    ]);
''');
      expect(b['kind'], 'ifElement');
      expect(b['condition'], 'flag');
      expect(arm(b, 'then')['widgets'], 2);
      expect(arm(b, 'else')['widgets'], 1);
    });

    test('the condition is reproduced exactly for each decidable shape', () {
      expect(only('    return !flag ? SizedBox() : Text("a");')['condition'], '!flag');
      expect(only('    return maybe != null ? SizedBox() : Text("a");')['condition'],
          'maybe != null');
      expect(only('    return maybe == null ? SizedBox() : Text("a");')['condition'],
          'maybe == null');
    });
  });

  group('what counts as a widget', () {
    test('value objects are not widgets -- the 13-of-28 miscount', () {
      // Every name here was counted as a widget by the regex this replaces.
      final b = only('''
    if (flag) {
      return Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
        child: Text('a', style: TextStyle(color: Color(0xFF000000))),
      );
    }
    return SizedBox();
''');
      final then = arm(b, 'then');
      expect(then['widgets'], 2, reason: 'Container and Text only');
      expect(then['valueObjects'], 5,
          reason: 'EdgeInsets, BoxDecoration, BorderRadius, TextStyle, Color');
    });

    test('a user-defined type is unknown, never a widget', () {
      final b = only('''
    if (flag) {
      return Container(child: AppInfo(label: 'x'));
    }
    return SizedBox();
''');
      expect(arm(b, 'then')['widgets'], 1);
      expect(arm(b, 'then')['unknown'], 1, reason: 'AppInfo cannot be classified');
    });

    test('const widgets are excluded, however they are spaced', () {
      final b = only('''
    if (flag) {
      return Column(children: [const Text('a'), const    Padding(padding: EdgeInsets.zero)]);
    }
    return SizedBox();
''');
      final then = arm(b, 'then');
      expect(then['widgets'], 1, reason: 'only the non-const Column');
      expect(then['constWidgets'], 2,
          reason: 'a six-character lookback misses `const    Padding(`');
    });

    test('const propagates into a const subtree', () {
      final b = only('''
    if (flag) {
      return const Column(children: [Text('a'), SizedBox()]);
    }
    return SizedBox();
''');
      expect(arm(b, 'then')['widgets'], 0);
      expect(arm(b, 'then')['constWidgets'], 3);
    });
  });

  group('lazy builders', () {
    test('a named .builder constructor is flagged', () {
      final b = only('''
    if (flag) {
      return ListView.builder(itemCount: 3, itemBuilder: (c, i) => Card());
    } else {
      return Column(children: [Text('a'), Text('b'), Text('c'), Text('d')]);
    }
''');
      expect(arm(b, 'then')['hasLazyBuilder'], isTrue);
      expect(arm(b, 'else')['hasLazyBuilder'], isFalse);
      // The point of the flag: the arm that renders more scores LOWER on source widgets.
      expect(arm(b, 'then')['widgets'], lessThan(arm(b, 'else')['widgets'] as int));
    });

    test('a builder delegate handed to a sliver is flagged', () {
      final b = only('''
    if (flag) {
      return CustomScrollView(slivers: [
        SliverList(delegate: SliverChildBuilderDelegate((c, i) => Card())),
      ]);
    }
    return SizedBox();
''');
      expect(arm(b, 'then')['hasLazyBuilder'], isTrue);
    });

    test('an eager list is not flagged', () {
      final b = only('''
    if (flag) {
      return ListView(children: [Text('a')]);
    }
    return SizedBox();
''');
      expect(arm(b, 'then')['hasLazyBuilder'], isFalse);
    });
  });

  group('text that only looks like code', () {
    test('a commented-out conditional is not a branch', () {
      expect(branchesOf('''
    // if (flag) Container() else SizedBox();
    /* if (flag) { return Container(); } */
    return SizedBox();
'''), isEmpty);
    });

    test('a conditional inside a string literal is not a branch', () {
      expect(branchesOf('''
    return Text('if (flag) Container( else SizedBox(');
'''), isEmpty);
    });

    test('braces inside strings do not confuse arm extraction', () {
      // The hand-rolled brace matcher counted `{` and `}` through string literals, so the
      // `}` in this interpolation truncated the arm.
      final b = only(r'''
    if (flag) {
      return Text('${items.length} items }{');
    } else {
      return SizedBox();
    }
''');
      expect(arm(b, 'then')['widgets'], 1);
      expect(arm(b, 'else')['widgets'], 1);
    });
  });

  group('what the caller matches on', () {
    test('the condition names its identifiers, so a prefix cannot match', () {
      final b = only('    return showAllApps ? SizedBox() : Text("a");');
      expect(b['conditionNames'], ['showAllApps']);
      // A substring test over `condition` would answer yes when asked about `showAll`.
      expect((b['conditionNames'] as List).contains('showAll'), isFalse);
    });

    test('enum equality names both sides', () {
      final b = only('    return type == AllpassType.password ? SizedBox() : Text("a");');
      expect(b['conditionNames'], containsAll(['type', 'AllpassType', 'password']));
    });

    test('a fixture binding mounted into a field is reported as an assignment', () {
      expect(
        assignmentsOf('''
    showAllApps = fixtureShowAllApps;
    return SizedBox();
'''),
        equals([
          {'target': 'showAllApps', 'value': 'fixtureShowAllApps'}
        ]),
      );
    });

    test('an assignment inside a comment or string is not reported', () {
      expect(
        assignmentsOf('''
    // showAllApps = fixtureShowAllApps;
    return Text('showAllApps = fixtureShowAllApps;');
'''),
        isEmpty,
      );
    });
  });

  test('nested conditionals are reported separately and counted in the enclosing arm', () {
    final found = branchesOf('''
    if (flag) {
      if (maybe != null) {
        return Container(child: Text('a'));
      }
      return Padding(padding: EdgeInsets.zero);
    }
    return SizedBox();
''');
    expect(found, hasLength(2));
    final outer = found.firstWhere((b) => b['condition'] == 'flag');
    expect(arm(outer, 'then')['widgets'], 3,
        reason: 'the outer arm does render the inner arms');
  });
}
