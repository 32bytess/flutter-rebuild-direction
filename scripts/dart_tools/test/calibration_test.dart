/// The cases the regexes got wrong, and the ones they got right and must keep getting right.
///
/// Every expectation here is a calibration decision recorded somewhere in
/// `scripts/screen_samples.py` -- in a rule comment, in the `normalise` docstring, or in the
/// hand curation those describe. They were prose; the port is the reason they are now
/// executable. The fixture lives beside this file as `calibration_fixture.dart.txt`, named
/// so `dart analyze` does not try to resolve a file that deliberately imports packages this
/// package does not have.
library;

import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:dart_tools/src/facts.dart';
import 'package:dart_tools/src/fixture.dart';
import 'package:dart_tools/src/normalise.dart';
import 'package:dart_tools/src/hash.dart';
import 'package:dart_tools/src/rules.dart';
import 'package:test/test.dart';

late final String fixture;
late final List<String> fired;
late final Rewrite rewritten;

void main() {
  setUpAll(() {
    fixture = File('test/calibration_fixture.dart.txt').readAsStringSync();
    final unit = parseString(content: fixture, throwIfDiagnostics: false).unit;
    final collector = FactCollector();
    unit.accept(collector);
    collector.collectNames(unit);
    fired = evaluate(collector.facts);
    rewritten = normalise(fixture, unit);
  });

  group('rules do not fire on text that merely contains the word', () {
    test('R2 ignores `await` and `async` inside a string literal', () {
      // `Text('please await ...')` is display text. This is the false positive that
      // motivated the port.
      expect(fixture, contains("'please await the result, it is async'"));
      expect(fired, isNot(contains('R2_async')));
    });

    test('R5 ignores a commented-out MaterialApp', () {
      expect(fixture, contains('// return MaterialApp('));
      expect(fired, isNot(contains('R5_nested_app')));
    });

    test('R1 ignores an AnimationController inside a block comment', () {
      expect(fixture, contains('/* AnimationController controller; */'));
      expect(fired, isNot(contains('R1_animation')));
    });

    test('R3 ignores a URL that happens to contain `//`', () {
      expect(fixture, contains('https://example.com'));
      expect(fired, isNot(contains('R3_io_network')));
    });
  });

  test('R2 does not fire on `.then(` -- an interaction callback, not async rebuild', () {
    // Calibrated against the 66 curated samples: a bare `.then(` was tried as an R2 pattern
    // and removed, because on unit 65 it fired on `showMenu(...).then((index) {...})`.
    expect(fixture, contains('.then((index)'));
    expect(fired, isEmpty);
  });

  group('normalise', () {
    test('a placeholder in a Widget slot becomes the grey box', () {
      expect(rewritten.text, contains(kGreyBox));
    });

    test('a placeholder in CircleAvatar.backgroundImage rewrites the KEY', () {
      // An ImageProvider slot: a Widget there is a hard compile error, so the argument name
      // changes rather than its value.
      expect(rewritten.text, contains('backgroundColor: $kGrey'));
    });

    test('...unless the avatar already sets backgroundColor, when it is dropped', () {
      // Naming it twice would not compile, and the avatar is already grey.
      expect(rewritten.text, contains('backgroundColor: Colors.red,\n      )'));
      expect('backgroundColor:'.allMatches(rewritten.text).length, 2);
    });

    test('a sized placeholder keeps the image\'s own dimensions', () {
      // The transplant is supposed to preserve tree geometry; an 80x80 box where the commit
      // drew 48x48 is a layout the commit never had. 25 files in the v2 corpus are sized.
      expect(rewritten.text,
          contains('Container(color: $kGrey, width: 48, height: 48)'));
    });

    test('a double dimension is reproduced verbatim, not renormalised', () {
      expect(rewritten.text,
          contains('Container(color: $kGrey, width: 50.0, height: 50.0)'));
    });

    test('extra arguments do not defeat the match, and nothing inside survives', () {
      // spm 0.7.0 preserves `color:` and `errorBuilder:`; matching on the argument COUNT is
      // what stopped recognising these. The node is replaced whole, so the foreign icon
      // font inside the builder must neither survive nor collect an overlapping edit.
      expect(rewritten.text,
          contains('Container(color: $kGrey, width: 64, height: 64)'));
      expect(rewritten.text, isNot(contains('errorBuilder')));
    });

    test('one axis only, or a non-literal dimension, falls back to the fixed box', () {
      // Three fixture cases reach the fallback: the unsized placeholder, `width:` alone,
      // and a dimension naming something an isolated file does not have.
      expect(kGreyBox.allMatches(rewritten.text).length, 3);
    });

    test('a foreign icon font becomes the stand-in', () {
      expect(rewritten.text, isNot(contains('FontAwesomeIcons')));
      expect(rewritten.text, contains(kIconStandIn));
    });

    test('CupertinoIcons survives -- cupertino_icons IS a dependency', () {
      expect(rewritten.text, contains('CupertinoIcons.book'));
    });

    test('a custom fontFamily is dropped, a generic one is not', () {
      expect(rewritten.text, isNot(contains('PingFang')));
      expect(rewritten.text, contains("fontFamily: 'monospace'"));
    });

    test('third-party imports go, flutter SDK imports stay', () {
      expect(rewritten.text, contains("import 'package:flutter/material.dart';"));
      expect(rewritten.text, isNot(contains('package:some_pkg')));
      expect(rewritten.text, isNot(contains('font_awesome_flutter')));
    });

    test('counts match what the regex pass reported for this fixture', () {
      // `icons` stays 1 with a second FontAwesomeIcons in the fixture: it sits inside a
      // placeholder's `errorBuilder`, and that node is replaced whole, so it collects no
      // edit of its own. One rewrite, counted once.
      expect(rewritten.counts,
          {'images': 8, 'icons': 1, 'fonts': 1, 'imports': 2, 'unused': 0});
    });

    test('dropping an argument leaves no blank indented line behind', () {
      expect(rewritten.text, isNot(contains(RegExp(r'\n[ \t]+\n'))));
    });
  });

  group('rules still fire on real references', () {
    test('R1, R2, R3, R5, R6 each fire on the construct they name', () {
      const source = '''
import 'dart:io';
class S extends State<W> with SingleTickerProviderStateMixin {
  late AnimationController c;
  Future<void> load() async { await File('x').readAsString(); }
  @override
  Widget build(BuildContext context) =>
      MaterialApp(home: Text('\${DateTime.now()} \${Random().nextInt(2)}'));
}
''';
      final unit = parseString(content: source, throwIfDiagnostics: false).unit;
      final collector = FactCollector();
      unit.accept(collector);
      collector.collectNames(unit);
      expect(
          evaluate(collector.facts),
          containsAll([
            'R1_animation',
            'R2_async',
            'R3_io_network',
            'R5_nested_app',
            'R6_nondeterminism',
          ]));
    });

    test('R4 fires on the keep-alive mixin', () {
      const source = '''
class S extends State<W> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
}
''';
      final unit = parseString(content: source, throwIfDiagnostics: false).unit;
      final collector = FactCollector();
      unit.accept(collector);
      collector.collectNames(unit);
      expect(evaluate(collector.facts), contains('R4_keepalive'));
    });
  });

  group('names the AST does not expose as SimpleIdentifier still count', () {
    // Every case here was a MISS found by A/B-ing this tool against the regexes it
    // replaces, all from the same cause: analyzer 14 carries declaration names and named
    // argument labels as bare `Token`s. `names` reads the token stream because of them.
    void expectFires(String source, String rule) {
      final unit = parseString(content: source, throwIfDiagnostics: false).unit;
      final collector = FactCollector();
      unit.accept(collector);
      collector.collectNames(unit);
      expect(evaluate(collector.facts), contains(rule), reason: source);
    }

    test('R4 on a `wantKeepAlive` getter declaration alone', () {
      // 130 files in the mine. The mixin is applied on a superclass, so the getter name is
      // the only trace of it in the transplant.
      expectFires('class S { bool get wantKeepAlive => true; }', 'R4_keepalive');
    });

    test('R1 on a `vsync:` named argument label', () {
      expectFires('var x = Foo(vsync: this);', 'R1_animation');
    });

    test('R3 on a class DECLARED as WebViewScreen', () {
      expectFires('class WebViewScreen extends StatelessWidget {}', 'R3_io_network');
    });

    test('R6 on a prefixed `math.Random()`', () {
      expectFires("import 'dart:math' as math; var r = math.Random();",
          'R6_nondeterminism');
    });

    test('R2 on a bare `Future(...)` construction', () {
      // The regex needed `Future.` or `Future<`, so a plain constructor call slipped
      // through it -- 15 files in the mine. This is the one delta in the widening
      // direction.
      expectFires('void f() { Future(() => 1); }', 'R2_async');
    });
  });

  group('covered imports', () {
    // The rule: an import goes when every name it provides that the file REFERENCES is also
    // provided by an import that stays. "Unused" is the degenerate case of that.
    Rewrite run(String source) {
      final unit = parseString(content: source, throwIfDiagnostics: false).unit;
      return normalise(source, unit);
    }

    test('drops a re-export already covered by material', () {
      final r = run("""
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/painting.dart';
class W extends StatelessWidget {
  const W({super.key});
  @override
  Widget build(BuildContext context) => const Text('x');
}
""");
      expect(r.text, contains("import 'package:flutter/material.dart';"));
      expect(r.text, isNot(contains('widgets.dart')));
      expect(r.text, isNot(contains('painting.dart')));
      expect(r.counts['unused'], 2);
    });

    test('keeps material and drops widgets, not the other way round', () {
      // Narrowest-first ordering. Both cover this file; the curated corpus keeps material.
      final r = run("""
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
class W extends StatelessWidget {
  const W({super.key});
  @override
  Widget build(BuildContext context) => const Text('x');
}
""");
      expect(r.text, contains('material.dart'));
      expect(r.text, isNot(contains('widgets.dart')));
    });

    test('drops dart:ui when only material-covered names are used', () {
      // 279 of the corpus's 283 bare `dart:ui` imports are this case.
      final r = run("""
import 'package:flutter/material.dart';
import 'dart:ui';
const c = Color(0xFF000000);
const o = Offset(1, 2);
""");
      expect(r.text, isNot(contains("import 'dart:ui';")));
      expect(r.counts['unused'], 1);
    });

    test('KEEPS dart:ui when a ui-only name is used', () {
      // The other 4. `PathMetric` is not re-exported by material.
      final r = run("""
import 'package:flutter/material.dart';
import 'dart:ui';
PathMetric? m;
const c = Color(0xFF000000);
""");
      expect(r.text, contains("import 'dart:ui';"));
      expect(r.text, contains('material.dart'));
      expect(r.counts['unused'], 0);
    });

    test('even material goes when the file references nothing it provides', () {
      final r = run("""
import 'package:flutter/material.dart';
import 'dart:ui';
PathMetric? m;
""");
      expect(r.text, isNot(contains('material.dart')));
      expect(r.text, contains("import 'dart:ui';"));
    });

    test('a name that appears only in a string or comment does not keep an import', () {
      final r = run("""
import 'package:flutter/material.dart';
import 'dart:ui';
// PathMetric mentioned in a comment
const s = 'PathMetric in a string';
const c = Color(0xFF000000);
""");
      expect(r.text, isNot(contains("import 'dart:ui';")));
    });

    test('never touches an import carrying as / show / hide', () {
      final r = run("""
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' show Text;
import 'dart:ui' as ui;
const c = Color(0xFF000000);
""");
      expect(r.text, contains("show Text"));
      expect(r.text, contains("import 'dart:ui' as ui;"));
    });

    test('a `show` import only covers what it shows', () {
      // Crediting the full namespace here would drop `material`, which still supplies
      // `Colors`. The file would stop compiling.
      final r = run("""
import 'package:flutter/widgets.dart' show Text;
import 'package:flutter/material.dart';
const t = Text('x');
const c = Colors.red;
""");
      expect(r.text, contains('material.dart'));
      expect(r.counts['unused'], 0);
    });

    test('a prefixed import covers nothing unprefixed', () {
      final r = run("""
import 'package:flutter/material.dart' as m;
import 'package:flutter/widgets.dart';
const t = Text('x');
""");
      expect(r.text, contains('widgets.dart'));
      expect(r.counts['unused'], 0);
    });

    test('never drops a relative import -- dependencies.dart is not in the table', () {
      final r = run("""
import 'package:flutter/material.dart';
import 'dependencies.dart';
const c = Color(0xFF000000);
""");
      expect(r.text, contains("import 'dependencies.dart';"));
      expect(r.counts['unused'], 0);
    });

    test('reports an import URI the table does not know', () {
      final r = run("import 'dart:isolate';\nvoid main() {}\n");
      expect(r.unknownImports, contains('dart:isolate'));
      expect(r.text, contains("import 'dart:isolate';"));
    });

    test('pruneImports: false leaves every covered import in place', () {
      const source = """
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
const c = Color(0xFF000000);
""";
      final unit = parseString(content: source, throwIfDiagnostics: false).unit;
      final r = normalise(source, unit, pruneImports: false);
      expect(r.text, contains('widgets.dart'));
      expect(r.counts['unused'], 0);
    });
  });

  group("R2 and R3 read the commit's code, not the extractor's stand-ins", () {
    // Added 2026-08-23. The vocabulary is unchanged and so is the unit it applies to, with
    // one exception: `spm isolate`'s generated stand-in block is no longer evidence, because
    // it is boilerplate the extractor wrote rather than code the commit contained.
    //
    // A finer rule was built and rejected the same day -- fire only from the rebuild path,
    // treating `onPressed` bodies as inert. It cannot follow a call, so an async helper
    // invoked from `initState` slipped through on real v2 groups. The last test in this
    // group pins that shape so the finer rule cannot come back without handling it.
    //
    // Every case is self-contained rather than appended to `calibration_fixture.dart.txt`,
    // which is asserted to fire NOTHING and is shared by 13 tests.
    List<String> screen(String source) {
      final unit = parseString(content: source, throwIfDiagnostics: false).unit;
      final collector = FactCollector();
      collector.indexRegions(unit, source);
      unit.accept(collector);
      collector.collectNames(unit);
      return evaluate(collector.facts);
    }

    test('Future.value in a generated stand-in block does not fire R2', () {
      // The recovery this change exists for: 51 v2 groups fired R2 on the extractor's own
      // `Future<Label?>.value(null)` boilerplate, with no async anywhere in the scope.
      expect(
          screen('''
class S extends State<W> {
  @override
  Widget build(BuildContext context) => Text('x');
}

// Declaration-only stand-ins for symbols this scope references but does not carry.
class Repo {
  Future<Label?> lookup() => Future<Label?>.value(null);
}
'''),
          isNot(contains('R2_async')));
    });

    test('a NetworkImage named only in a stand-in block does not fire R3', () {
      expect(
          screen('''
class S extends State<W> {
  @override
  Widget build(BuildContext context) => Text('x');
}

// Stand-ins for references the analyzer could not resolve.
class Avatar {
  NetworkImage get image => throw UnimplementedError();
}
'''),
          isNot(contains('R3_io_network')));
    });

    test('await in build fires R2', () {
      expect(
          screen('''
class S extends State<W> {
  @override
  Widget build(BuildContext context) =>
      FutureBuilder(future: f, builder: (c, s) => Text('x'));
}
'''),
          contains('R2_async'));
    });

    test('await in initState fires R2', () {
      expect(
          screen('''
class S extends State<W> {
  @override
  void initState() async { await load(); }
  @override
  Widget build(BuildContext context) => Text('x');
}
'''),
          contains('R2_async'));
    });

    test('await in an onPressed handler does NOT fire R2', () {
      // Reversed 2026-08-24. This asserted the opposite, on the grounds that treating a
      // handler as inert is only sound if the rule can also prove nothing on the rebuild
      // path calls it. `Facts._propagateRegions` now proves exactly that, by promoting a
      // member to the region of whatever reaches it. The harness mounts the widget and
      // calls setState without touching anything, so this body never runs in the span.
      // `region_propagation_test.dart` holds the cases that decide the promotion.
      expect(
          screen('''
class S extends State<W> {
  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: () async { await save(); },
        child: Text('save'),
      );
}
'''),
          isNot(contains('R2_async')));
    });

    test('http.get in a save handler does NOT fire R3', () {
      // Same reversal, same reason.
      expect(
          screen('''
class S extends State<W> {
  @override
  Widget build(BuildContext context) =>
      ElevatedButton(onPressed: () { http.get(uri); }, child: Text('go'));
}
'''),
          isNot(contains('R3_io_network')));
    });

    test('a dart:io import fires R3 wherever it is used', () {
      // Unit-wide on purpose: an import has no enclosing member, and it is the one entry
      // in R3's vocabulary that `--normalise` cannot stand in for.
      expect(
          screen('''
import 'dart:io';
class S extends State<W> {
  @override
  Widget build(BuildContext context) => Text('x');
}
'''),
          contains('R3_io_network'));
    });

    test('an async helper reached from initState fires R2 (v2 groups 0608, 0616)', () {
      // The shape that killed the rebuild-path rule. `_load` is neither a lifecycle member
      // nor widget-returning, and `initState` carries no async vocabulary of its own -- so
      // a region rule that does not follow calls sees nothing, while the running widget
      // does an asynchronous `setState` inside the measured span.
      expect(
          screen('''
class S extends State<W> {
  @override
  void initState() { super.initState(); _load(); }
  void _load() async {
    final rows = await db.getAll();
    setState(() => _rows = rows);
  }
  @override
  Widget build(BuildContext context) => Text('x');
}
'''),
          contains('R2_async'));
    });

    test('R1, R4, R5 and R6 still read the whole unit, stand-ins included', () {
      // The stand-in carve-out is scoped to R2 and R3. R1 in particular stays flat: a
      // mounted animation hangs `pumpAndSettle` wherever in the tree it lives.
      final fired = screen('''
class S extends State<W> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: () {
          showDialog(builder: (_) => MaterialApp(home: CircularProgressIndicator()));
          print(Stopwatch());
        },
        child: Text('go'),
      );
}
''');
      expect(
          fired,
          containsAll([
            'R1_animation',
            'R4_keepalive',
            'R5_nested_app',
            'R6_nondeterminism',
          ]));
    });

    test('an unindexed collector reproduces the pre-region behaviour', () {
      // The compatibility guarantee in `facts.dart`: skip `indexRegions` and every fact
      // lands in the rebuild region, nothing is ever marked as a stand-in, and the rules
      // behave exactly as they did before regions existed.
      const source = '''
class S extends State<W> {
  @override
  Widget build(BuildContext context) => Text('x');
}

// Declaration-only stand-ins for symbols this scope references but does not carry.
class Repo { Future<Label?> lookup() => Future<Label?>.value(null); }
''';
      final unit = parseString(content: source, throwIfDiagnostics: false).unit;
      final collector = FactCollector();
      unit.accept(collector);
      collector.collectNames(unit);
      expect(evaluate(collector.facts), contains('R2_async'));
      expect(screen(source), isNot(contains('R2_async')));
    });
  });

  group('spm 0.7.0 relocates a scope\'s initial state into a fixture block', () {
    /// Regions, the way `screen_samples` builds them.
    List<String> screen(String source) {
      final unit = parseString(content: source, throwIfDiagnostics: false).unit;
      final collector = FactCollector();
      collector.indexRegions(unit, source);
      unit.accept(collector);
      collector.collectNames(unit);
      return evaluate(collector.facts);
    }

    const withFixtureBlock = '''
class S extends State<W> {
  @override
  Widget build(BuildContext context) => Text('\${fixtureLabel}');
}

// Fixture block. These are the bindings the transplanted scope used to receive
// from the application.
String fixtureLabel = '';
Stream<int>? fixtureUpdates = null;
''';

    test('a lifted binding is scaffolding, so R2 does not fire on its type', () {
      // The block is the extractor's, not the commit's, and it sits ABOVE the two stand-in
      // banners -- so until the boundary took the earliest of three, a `Stream` the
      // application used to supply read as evidence that the scope rebuilds on a stream.
      // Same recovery as the stand-in block got in 2026-08-23, for the same reason.
      expect(screen(withFixtureBlock), isNot(contains('R2_async')));
    });

    test('...and the same declaration above the banner still fires', () {
      const source = '''
Stream<int>? fixtureUpdates = null;

class S extends State<W> {
  @override
  Widget build(BuildContext context) => const SizedBox();
}
''';
      expect(screen(source), contains('R2_async'));
    });

    test('R1 stays unit-wide: a lifted AnimationController still fires it', () {
      // Not an oversight. R1, R4, R5 and R6 read `names` rather than `activeNames` -- only
      // R2 and R3 are region-gated -- so widening the boundary does not touch them, and
      // this pins that it did not quietly start to. The direction is the conservative one,
      // and on the mined corpus it costs nothing: 21 files mention an animation name in
      // their fixture block and not one of them mentions it ONLY there, because a lifted
      // binding mirrors a type the scope already uses.
      const source = '''
class S extends State<W> {
  @override
  Widget build(BuildContext context) => const SizedBox();
}

// Fixture block. These are the bindings the transplanted scope used to receive
// from the application.
AnimationController? fixtureController = null;
''';
      expect(screen(source), contains('R1_animation'));
    });

    test('the hash ignores the fixture block, so one tree is one hash', () {
      // 0.7.0 puts a scope's whole initial state in the file, so hashing to EOF compared
      // seeded VALUES alongside the tree they build: two transplants of one identical widget
      // tree hashed apart because a lifted `int` differed, and R7 stopped seeing duplicates.
      const a = '''
class S extends State<W> {
  @override
  Widget build(BuildContext context) => const SizedBox();
}

// Fixture block. These are the bindings the transplanted scope used to receive
// from the application.
int fixtureLimit = 20;
''';
      const b = '''
class S extends State<W> {
  @override
  Widget build(BuildContext context) => const SizedBox();
}

// Fixture block. These are the bindings the transplanted scope used to receive
// from the application.
int fixtureLimit = 10;
''';
      final ua = parseString(content: a, throwIfDiagnostics: false).unit;
      final ub = parseString(content: b, throwIfDiagnostics: false).unit;
      expect(
        normalisedHash(ua, until: standInStart(a)),
        normalisedHash(ub, until: standInStart(b)),
      );
      // Without the boundary they are two different transplants, which is the bug.
      expect(normalisedHash(ua), isNot(normalisedHash(ub)));
    });

    test('a difference in the MEASURED code still separates two hashes', () {
      const a = '''
class S extends State<W> {
  @override
  Widget build(BuildContext context) => const SizedBox();
}

// Fixture block.
int fixtureLimit = 20;
''';
      const b = '''
class S extends State<W> {
  @override
  Widget build(BuildContext context) => const Placeholder();
}

// Fixture block.
int fixtureLimit = 20;
''';
      final ua = parseString(content: a, throwIfDiagnostics: false).unit;
      final ub = parseString(content: b, throwIfDiagnostics: false).unit;
      expect(
        normalisedHash(ua, until: standInStart(a)),
        isNot(normalisedHash(ub, until: standInStart(b))),
      );
    });
  });

  test('the near-duplicate hash does not collapse whitespace inside a string', () {
    // The regex version applied `\s+ -> ' '` to the whole file, so these two hashed equal.
    final a = parseString(content: "var x = 'a  b';", throwIfDiagnostics: false).unit;
    final b = parseString(content: "var x = 'a b';", throwIfDiagnostics: false).unit;
    expect(normalisedHash(a), isNot(normalisedHash(b)));
  });

  test('the near-duplicate hash still ignores comments and layout', () {
    final a = parseString(
            content: 'class A {}   // trailing\n', throwIfDiagnostics: false)
        .unit;
    final b = parseString(content: '\n\nclass    A\n{\n}\n', throwIfDiagnostics: false).unit;
    expect(normalisedHash(a), normalisedHash(b));
  });
}
