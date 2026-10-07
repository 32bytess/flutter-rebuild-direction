/// Parse-only Dart analysis and rewriting for the Python tooling under `scripts/`.
///
/// WHY THIS EXISTS.
///
/// `scripts/screen_samples.py` classified and rewrote Dart source with regexes and two
/// hand-written scanners -- a string/comment lexer and a paren balancer. That is the work
/// `package:analyzer` does correctly, and the regexes had the failure modes you would
/// expect: `\bawait\b` fired inside `Text('please await ...')`, `\bMaterialApp\b` fired on
/// a commented-out line, and the near-duplicate hash collapsed whitespace inside string
/// literals.
///
/// Parse-only, via `parseString`, for the same reason `history_probe/scope_ast` is: mined
/// transplants frequently will not resolve -- they carry deep `package:.../src/` imports
/// the analyser reached them through, and no `pubspec.yaml` here declares those packages.
/// A resolving tool would report nothing for exactly the files the corpus is made of.
///
/// PROTOCOL. One JSON object per line on stdout, one per input file, in input order. A
/// file that cannot be read or parsed emits a row with a non-`ok` status rather than being
/// skipped: the caller decides, and `screen_samples` treats it as a hard error, because a
/// silently empty rule set would let an unscreened file into the corpus.
library;

import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:args/args.dart';

import 'package:dart_tools/src/branches.dart';
import 'package:dart_tools/src/facts.dart';
import 'package:dart_tools/src/fixture.dart';
import 'package:dart_tools/src/hash.dart';
import 'package:dart_tools/src/normalise.dart';
import 'package:dart_tools/src/widget_fields.dart';
import 'package:dart_tools/src/rules.dart';
import 'package:dart_tools/src/shims.dart';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addMultiOption('file', abbr: 'f', help: 'Dart file to process. Repeatable.')
    ..addFlag('stdin-list',
        negatable: false,
        help: 'Read newline-separated file paths from stdin instead of --file. '
            'Use this for large batches; an argv list has an OS length limit.')
    ..addOption('out', abbr: 'o', help: 'JSONL output path. Defaults to stdout.')
    ..addFlag('rules-version',
        negatable: false, help: 'Print the rule-vocabulary digest and exit.')
    ..addFlag('prune-imports',
        defaultsTo: true,
        help: 'normalise only: also drop every import whose contribution is already '
            'covered by another import that stays. Subsumes unused and unnecessary.')
    ..addFlag('lift-fields',
        defaultsTo: true,
        help: 'fixture only: lift the transplanted widget\'s constructor fields into '
            'fixture bindings. Off is the pre-2026-09-08 shape, kept so the fidelity '
            'check can analyse both. See lib/src/widget_fields.dart.')
    ..addOption('lift-mode',
        defaultsTo: 'state',
        allowed: ['constructor', 'state'],
        help: 'fixture only: how far the field lift goes. `state` -- the default, and what '
            'the corpus is built in -- gives the State a `late final` field per constructor '
            'field, assigns it in initState from the fixture binding, rewrites widget.x to x, '
            'and leaves the widget as `const GeneratedWidget({super.key})` so it mounts with '
            'no argument. `constructor` leaves the build body byte-identical, keeps the '
            'copied constructor and mounts through GeneratedWidget.fixture; it is kept so the '
            'fidelity check can analyse both. See lib/src/widget_fields.dart.')
    ..addFlag('help', abbr: 'h', negatable: false);

  final options = parser.parse(args);
  final rest = options.rest;

  if (options['help'] as bool || (rest.isEmpty && !(options['rules-version'] as bool))) {
    stdout.writeln('dart_tools <screen|normalise|fixture|branches> [options]\n');
    stdout.writeln(parser.usage);
    return;
  }

  if (options['rules-version'] as bool) {
    stdout.writeln(rulesVersion());
    return;
  }

  final command = rest.first;
  if (command != 'screen' &&
      command != 'normalise' &&
      command != 'fixture' &&
      command != 'branches') {
    stderr.writeln('unknown command "$command"; expected screen, normalise, fixture '
        'or branches');
    exitCode = 2;
    return;
  }

  final paths = <String>[...options['file'] as List<String>];
  if (options['stdin-list'] as bool) {
    paths.addAll(
      (await stdin.transform(utf8.decoder).transform(const LineSplitter()).toList())
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty),
    );
  }
  if (paths.isEmpty) {
    stderr.writeln('no input files; pass --file or --stdin-list');
    exitCode = 2;
    return;
  }

  final sink =
      options['out'] != null ? File(options['out'] as String).openWrite() : stdout;
  final pruneImports = options['prune-imports'] as bool;
  final liftFields = options['lift-fields'] as bool;
  final liftMode = options['lift-mode'] == 'state'
      ? LiftMode.state
      : LiftMode.constructor;
  for (final path in paths) {
    sink.writeln(jsonEncode(switch (command) {
      'screen' => screenFile(path),
      'fixture' => fixtureFile(path,
          pruneImports: pruneImports,
          liftFields: liftFields,
          liftMode: liftMode),
      'branches' => branchesFile(path),
      _ => normaliseFile(path, pruneImports: pruneImports),
    }));
  }
  if (options['out'] != null) {
    await sink.flush();
    await sink.close();
  }
}

/// Rule verdicts and the near-duplicate hash for one file.
Map<String, Object?> screenFile(String path) => _withUnit(path, (source, unit) {
      final collector = FactCollector();
      // Must precede both passes: it is what lets R2 and R3 tell an `await` in `build`
      // from one in an `onPressed` handler or in `spm isolate`'s generated stand-in block.
      collector.indexRegions(unit, source);
      unit.accept(collector);
      collector.collectNames(unit);
      // R19's input, and R20's: reported alongside the verdict because the pair-level rule
      // compares the two endpoints' drops, which a rule id alone cannot express.
      final drops = shimChildDrops(source, unit);
      return {
        'rules': evaluate(collector.facts, shimDrops: drops),
        // Same boundary the region map uses: the hash is about the transplanted code, not
        // about the fixture values and stand-ins spm generated below it.
        'normHash': normalisedHash(unit, until: standInStart(source)),
        'shimDrops': [for (final drop in drops) drop.toJson()],
      };
    });

/// Every conditional in one file, with per-arm counts.
///
/// Reports, decides nothing: `scripts/maximal_branch.py` owns which literal a binding
/// takes and what counts as undecidable, the same split screening uses. Emitting every
/// conditional rather than filtering by field keeps this side free of the fixture
/// vocabulary -- and the caller needs the whole set anyway to report what it did not use.
Map<String, Object?> branchesFile(String path) =>
    _withUnit(path, (source, unit) => collectBranches(unit));

/// The rewritten source for one file, plus the substitution counts the report prints.
Map<String, Object?> normaliseFile(String path, {bool pruneImports = true}) =>
    _withUnit(path, (source, unit) {
      final result = normalise(source, unit, pruneImports: pruneImports);
      return {
        'text': result.text,
        'counts': result.counts,
        if (result.unknownImports.isNotEmpty) 'unknownImports': result.unknownImports,
      };
    });

/// The normalised source split into what stays in the transplant and what moves to the
/// group's shared `dependencies.dart`. See `lib/src/fixture.dart` for why the fixture is a
/// `part` rather than a library of its own.
///
/// `text` is the transplant after the split, `plainText` the same file with normalisation
/// only -- the caller writes the second when its group gets no fixture, so both come back
/// from the one pass that already parsed the file.
Map<String, Object?> fixtureFile(String path,
        {bool pruneImports = true,
        bool liftFields = true,
        LiftMode liftMode = LiftMode.constructor}) =>
    _withUnit(path, (source, unit) {
      final result = split(source, unit,
          pruneImports: pruneImports,
          liftFields: liftFields,
          liftMode: liftMode);
      if (result == null) {
        // The normalised text would not re-parse. A status row is what `ast_tools` turns
        // into a hard failure, which is what an unsplittable file deserves: the alternative
        // is a transplant exported as though it had been split.
        return {'status': 'split_failed'};
      }
      return {
        'text': result.text,
        'plainText': result.plainText,
        'counts': result.counts,
        'imports': result.imports,
        'hoisted': [for (final h in result.hoisted) h.toJson()],
        if (result.unknownImports.isNotEmpty) 'unknownImports': result.unknownImports,
      };
    });

/// Read, parse, and hand the source and its unit to `body`, turning every failure into a
/// status row instead of an exception. One file that will not parse must not abort a batch
/// of five thousand.
Map<String, Object?> _withUnit(
    String path, Map<String, Object?> Function(String, CompilationUnit) body) {
  final file = File(path);
  if (!file.existsSync()) {
    return {'file': path, 'status': 'absent'};
  }

  final String source;
  try {
    // Bytes, then UTF-8: `readAsStringSync` would be the same here, but being explicit
    // documents that nothing translates line endings. `0787/rev_005.dart` has 82 CRLF
    // lines and must keep them -- a rewritten file is compared to its source by CONTENT,
    // so a silent CRLF-to-LF would rewrite every line of it on every run.
    source = utf8.decode(file.readAsBytesSync());
  } catch (error) {
    return {'file': path, 'status': 'unreadable', 'error': '$error'};
  }

  final parsed = parseString(content: source, throwIfDiagnostics: false, path: path);
  // `.severity.name` rather than the enum: `DiagnosticSeverity` is not exported from
  // `package:analyzer`'s public surface, only from `_fe_analyzer_shared`.
  final fatal =
      parsed.errors.where((d) => d.severity.name == 'ERROR').toList();
  if (fatal.isNotEmpty) {
    // Syntax errors only -- there is no resolution here, so an unresolved import or an
    // undefined name never reaches this point. A file that will not PARSE cannot be
    // screened, and pretending otherwise is how an unscreened transplant ships.
    return {
      'file': path,
      'status': 'parse_error',
      'error': fatal.take(3).map((d) => '${d.offset}: ${d.message}').join('; '),
    };
  }

  return {'file': path, 'status': 'ok', ...body(source, parsed.unit)};
}
