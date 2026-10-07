/// What the fixture split must do to a mined transplant, and what it must refuse to do.
///
/// The inputs below are the shapes `spm isolate` actually writes, reduced to the smallest
/// thing that still exercises the decision: a 0.7.0 fixture block holding both a relocated
/// value and a generated-empty one, banner-delimited stand-in blocks, a top-level `late`
/// seed with no initialiser, a stand-in constant at `null`, and a class whose members two
/// roles reconstruct differently. Every expectation is a rule stated in
/// `lib/src/fixture.dart` or `scripts/fixture_skeleton.py`.
library;

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:dart_tools/src/fixture.dart';
import 'package:test/test.dart';

const _transplant = '''
import 'package:flutter/material.dart';

class GeneratedWidget extends StatefulWidget {
  const GeneratedWidget({super.key});

  @override
  State<GeneratedWidget> createState() => _GeneratedWidgetState();
}

class _GeneratedWidgetState extends State<GeneratedWidget> {
  late Repo repo;

  @override
  void initState() {
    super.initState();
    repo = seededRepo;
  }

  @override
  Widget build(BuildContext context) => Text(repo.title, style: headingStyle);
}

// Fixture block. These are the bindings the transplanted scope used to receive
// from the application, and this is the one region to edit when a real value is
// needed: nothing outside it has to change.
int fixtureLimit = 20;
List<Repo> fixtureRepos = [];

// Declaration-only stand-ins for symbols this scope references but does not
// carry: repo-local declarations that build no UI, and third-party ones the
// transplant does not inline.
class Repo {
  String get title => throw UnimplementedError();
}

const dynamic headingStyle = null;

// Stand-ins for references the analyzer could not resolve, either because the
// symbol lives in a package this file does not import.
extension _Shim on Object {
  dynamic get shimmed => throw UnimplementedError();
}

late dynamic seededRepo;
''';

/// The shapes that decide whether a fixture binding is one a measured rebuild reaches.
///
/// `_buildCard` is declared ABOVE `build` deliberately: that is the ordering Dart style
/// produces and the one the old `build`-to-end-of-file regex could not see past.
const _reach = '''
import 'package:flutter/material.dart';

class GeneratedWidget extends StatefulWidget {
  const GeneratedWidget({super.key});

  @override
  State<GeneratedWidget> createState() => _GeneratedWidgetState();
}

class _GeneratedWidgetState extends State<GeneratedWidget> {
  late bool trackingEnabled;
  late String mountOnly;
  late VoidCallback onTapHandler;
  late int viaHelper;

  @override
  void initState() {
    super.initState();
    trackingEnabled = fixtureTracking;
    mountOnly = fixtureMountOnly;
    onTapHandler = fixtureOnTap;
    viaHelper = fixtureViaHelper;
    debugPrint(mountOnly);
  }

  Widget _buildCard() => SwitchListTile(
        value: trackingEnabled,
        title: Text('\$viaHelper'),
        onChanged: null,
      );

  @override
  Widget build(BuildContext context) => Column(
        children: [
          _buildCard(),
          Text(fixturePairA.toString()),
          const Text('fixtureNamedInStringOnly'),
          // fixtureNamedInCommentOnly is named here and nowhere else.
          ElevatedButton(onPressed: onTapHandler, child: const Text('go')),
        ],
      );
}

// Fixture block. These are the bindings the transplanted scope used to receive
// from the application.
bool fixtureTracking = false;
String fixtureMountOnly = '';
VoidCallback fixtureOnTap = () {};
int fixtureViaHelper = 0;
String fixtureNamedInStringOnly = '';
String fixtureNamedInCommentOnly = '';
int fixturePairA = 1, fixturePairB = 2;
''';

FixtureSplit run(String source) {
  final unit = parseString(content: source, throwIfDiagnostics: false).unit;
  final result = split(source, unit);
  expect(
    result,
    isNotNull,
    reason: 'the split refused a transplant it should have taken',
  );
  return result!;
}

void main() {
  group('what moves', () {
    late FixtureSplit result;
    setUpAll(() => result = run(_transplant));

    test('everything below each banner is hoisted, and the seed with it', () {
      expect(
        result.hoisted.map((h) => h.name),
        containsAll([
          'Repo',
          'headingStyle',
          '_Shim',
          'seededRepo',
          'fixtureLimit',
          'fixtureRepos',
        ]),
      );
    });

    test('each hoisted declaration knows which section it belongs to', () {
      final sections = {for (final h in result.hoisted) h.name: h.section};
      expect(sections['Repo'], 'declaration');
      expect(sections['_Shim'], 'unresolved');
      expect(sections['seededRepo'], 'seed');
      // The fixture block comes FIRST in the file, so it needs its own upper bound rather
      // than a `>` test against a later banner -- get that wrong and it swallows the two
      // stand-in blocks with it.
      expect(sections['fixtureLimit'], 'lifted');
      expect(sections['fixtureRepos'], 'lifted');
    });

    test(
      'a `late` seed and a `null` constant are the values a human has to supply',
      () {
        final needs = {
          for (final h in result.hoisted)
            if (h.needsValue) h.name,
        };
        // `fixtureRepos` joins them: an empty collection is a decision, because how many
        // elements go in one is tree size. `fixtureLimit` does NOT -- 0.7.0 relocated the
        // value that was really there, and relocating is not inventing.
        expect(needs, {'seededRepo', 'headingStyle', 'fixtureRepos'});
      },
    );

    test('a relocated value is reproduced verbatim, never re-defaulted', () {
      final lifted = result.hoisted.firstWhere((h) => h.name == 'fixtureLimit');
      expect(lifted.text, 'int fixtureLimit = 20;');
    });

    test('the measured code stays: the scope and its build are untouched', () {
      expect(result.text, contains('class _GeneratedWidgetState'));
      expect(result.text, contains('Text(repo.title, style: headingStyle)'));
    });

    test('what was hoisted is gone from the transplant, banners included', () {
      expect(result.text, isNot(contains('class Repo')));
      expect(result.text, isNot(contains('late dynamic seededRepo')));
      expect(result.text, isNot(contains('Declaration-only stand-ins')));
      expect(result.text, isNot(contains('int fixtureLimit')));
      expect(result.text, isNot(contains('Fixture block')));
    });

    test('the two files are joined by a library name, not by a filename', () {
      // The URI form would have to name `rev_007_ab12cd34.dart` and would therefore be
      // per-role, which is the one thing a shared fixture cannot be.
      expect(result.text, contains('library generated_widget;'));
      expect(result.text, contains("part 'dependencies.dart';"));
      expect(
        result.text.indexOf('library'),
        lessThan(result.text.indexOf('import')),
      );
    });

    test(
      'the role keeps its own imports, and reports them for the group union',
      () {
        expect(result.imports, ["import 'package:flutter/material.dart';"]);
      },
    );

    test('plainText is the same file with nothing hoisted', () {
      expect(result.plainText, contains('class Repo'));
      expect(result.plainText, isNot(contains('library generated_widget;')));
    });
  });

  group('class-like declarations are split so two roles can be merged', () {
    late FixtureSplit result;
    setUpAll(() => result = run(_transplant));

    test('a class carries its header and its members separately', () {
      final repo = result.hoisted.firstWhere((h) => h.name == 'Repo');
      expect(repo.header, 'class Repo');
      expect(repo.members?.map((m) => m.name), ['get title']);
    });

    test(
      'the header keeps supertypes verbatim, because analyze walks them',
      () {
        const source = '''
import 'package:flutter/material.dart';

class _GeneratedWidgetState extends State<GeneratedWidget> {
  @override
  Widget build(BuildContext context) => Card();
}

// Declaration-only stand-ins for symbols this scope references but does not
class Card extends StatelessWidget implements Comparable<Card> {
  Widget build(BuildContext context) => throw UnimplementedError();
}
''';
        final card = run(source).hoisted.single;
        expect(
          card.header,
          'class Card extends StatelessWidget implements Comparable<Card>',
        );
      },
    );

    test('an enum is not split: its constants are part of its identity', () {
      const source = '''
import 'package:flutter/material.dart';

class _GeneratedWidgetState extends State<GeneratedWidget> {
  @override
  Widget build(BuildContext context) => Text('\${Mode.light}');
}

// Declaration-only stand-ins for symbols this scope references but does not
enum Mode { light, dark }
''';
      expect(run(source).hoisted.single.header, isNull);
    });
  });

  test('a transplant with nothing to hoist is returned unchanged', () {
    const source = '''
import 'package:flutter/material.dart';

class GeneratedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const SizedBox();
}
''';
    final result = run(source);
    expect(result.hoisted, isEmpty);
    expect(result.text, isNot(contains('part ')));
    expect(result.text, result.plainText);
  });

  group('which bindings a measured rebuild reaches', () {
    late Set<String> reaching;
    late Set<String> names;
    setUpAll(() {
      final result = run(_reach);
      names = {for (final h in result.hoisted) ...h.name.split(',')};
      reaching = {for (final h in result.hoisted) ...h.reaching};
    });

    test('a binding read through a helper declared ABOVE build still reaches it', () {
      // The defect the regex had: its slab started at `build` and Dart style puts `build`
      // last, so every `_buildXCard()` above it was invisible. 72 of 74 corrections on the
      // real corpus are this shape -- group 0586 is the original.
      expect(reaching, contains('fixtureTracking'));
      expect(reaching, contains('fixtureViaHelper'));
    });

    test('the fixture name is matched through the field the mount code assigns it to', () {
      // `build` never says `fixtureTracking`; it says `trackingEnabled`.
      expect(_reach, contains('trackingEnabled = fixtureTracking;'));
      expect(_reach.contains('fixtureTracking,'), isFalse);
    });

    test('a binding only ever read at mount does NOT reach build', () {
      // Assigned once in `initState`, outside the `setState` that `buildSpan` times. This
      // is the case the whole diagnostic exists to separate, and it is why the query is
      // `Region.rebuild` alone rather than `activeNames`.
      expect(reaching, isNot(contains('fixtureMountOnly')));
    });

    test('a binding that only feeds an interaction callback does NOT reach build', () {
      // `onPressed:` runs when a person taps. Nobody taps inside a measured rebuild.
      expect(reaching, isNot(contains('fixtureOnTap')));
    });

    test('a name that appears only in a string literal or a comment is not a reference', () {
      // The R2 precedent, which the word-boundary search over raw text could not honour.
      expect(names, containsAll(['fixtureNamedInStringOnly', 'fixtureNamedInCommentOnly']));
      expect(reaching, isNot(contains('fixtureNamedInStringOnly')));
      expect(reaching, isNot(contains('fixtureNamedInCommentOnly')));
    });

    test('a multi-name declaration reports only the names that reach', () {
      // `int a, b;` is ONE hoisted record naming two bindings, which is why `reaching` is a
      // list and not a flag: collapsing it would lose which of them moved.
      expect(names, containsAll(['fixturePairA', 'fixturePairB']));
      expect(reaching, contains('fixturePairA'));
      expect(reaching, isNot(contains('fixturePairB')));
    });
  });
}
