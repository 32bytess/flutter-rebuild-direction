/// How many transplants the `active` region view changes a verdict for, against `code`.
///
/// R2 and R3 moved from "anywhere in the commit's own code" to "anywhere a rebuild can
/// reach". This reports the size of that move on a real corpus, which is the check that
/// `_propagateRegions` is not over-promoting: the expected delta is small, and a large one
/// is a defect rather than a win.
///
/// Usage: dart run tool/region_delta.dart <dir-of-transplants>
library;

import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:dart_tools/src/facts.dart';

const _async = {'Future', 'Stream', 'FutureBuilder', 'StreamBuilder', 'Completer'};
const _io = {'HttpClient', 'Dio', 'Socket', 'rootBundle', 'NetworkImage', 'SharedPreferences'};
const _ioPrefixes = {'WebView', 'VideoPlayer', 'AudioPlayer'};
const _ioCtors = {'File', 'Directory'};

({bool r2, bool r3}) verdict(Facts f, List<Region> view) {
  final names = <String>{for (final r in view) ...f.region(r).names};
  final invoked = <String>{for (final r in view) ...f.region(r).invoked};
  final qualified = <String>{for (final r in view) ...f.region(r).qualified};
  final hasAwait = view.any((r) => f.region(r).hasAwait);
  final hasAsync = view.any((r) => f.region(r).hasAsyncBody);
  return (
    r2: hasAwait || hasAsync || names.any(_async.contains),
    r3: f.imports.contains('dart:io') ||
        names.any(_io.contains) ||
        names.any((n) => _ioPrefixes.any(n.startsWith)) ||
        invoked.any(_ioCtors.contains) ||
        qualified.contains('Image.network') ||
        qualified.any((q) => q.startsWith('http.')),
  );
}

void main(List<String> args) {
  final root = Directory(args.isEmpty ? '.' : args.first);
  const code = [Region.rebuild, Region.lifecycle, Region.inert];
  const active = [Region.rebuild, Region.lifecycle];
  var seen = 0, r2Freed = 0, r3Freed = 0, bothFreed = 0;
  // Group-level: a group is a directory of revisions. It only becomes a candidate sample if
  // NO revision in it still fires, so the per-file count overstates what the screen can use.
  final firedBefore = <String>{};
  final firedAfter = <String>{};
  final groups = <String>{};
  for (final e in root.listSync(recursive: true)) {
    if (e is! File || !e.path.endsWith('.dart')) continue;
    final source = e.readAsStringSync();
    final unit = parseString(content: source, throwIfDiagnostics: false).unit;
    final collector = FactCollector();
    collector.indexRegions(unit, source);
    unit.accept(collector);
    collector.collectNames(unit);
    seen++;
    final before = verdict(collector.facts, code);
    final after = verdict(collector.facts, active);
    final f2 = before.r2 && !after.r2;
    final f3 = before.r3 && !after.r3;
    final group = e.parent.path.split(Platform.pathSeparator).last;
    groups.add(group);
    if (before.r2 || before.r3) firedBefore.add(group);
    if (after.r2 || after.r3) firedAfter.add(group);
    if (f2) r2Freed++;
    if (f3) r3Freed++;
    if ((before.r2 || before.r3) && !after.r2 && !after.r3) {
      bothFreed++;
      if (Platform.environment['LIST'] != null) stdout.writeln('FREED ${e.path}');
    }
  }
  stdout.writeln('transplants scanned: $seen');
  stdout.writeln('R2 no longer fires : $r2Freed');
  stdout.writeln('R3 no longer fires : $r3Freed');
  stdout.writeln('clear of BOTH now  : $bothFreed');
  final freedGroups = firedBefore.difference(firedAfter);
  stdout.writeln('');
  stdout.writeln('groups seen                       : ${groups.length}');
  stdout.writeln('groups where R2/R3 fired before   : ${firedBefore.length}');
  stdout.writeln('groups where R2/R3 still fire     : ${firedAfter.length}');
  stdout.writeln('groups FREED of R2/R3 by the change: ${freedGroups.length}');
  if (Platform.environment['GROUPS'] != null) {
    for (final g in freedGroups.toList()..sort()) stdout.writeln('GROUP $g');
  }
}
