/// Names a transplant references ONLY from an interaction handler.
///
/// If `spm isolate` skipped handler subtrees it would not have to carry or stub these, so
/// this is the upper bound on how much of the stand-in machinery, and therefore of
/// `R10_unverified`, handler exclusion could remove.
///
/// Emits JSONL: {"group": "0038", "file": "...", "inertOnly": [...], "active": N}
library;

import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:dart_tools/src/facts.dart';

void main(List<String> args) {
  final root = Directory(args.isEmpty ? '.' : args.first);
  for (final dir in root.listSync().whereType<Directory>()) {
    final revs = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    if (revs.isEmpty) continue;
    final f = revs.first;
    final source = f.readAsStringSync();
    final unit = parseString(content: source, throwIfDiagnostics: false).unit;
    final c = FactCollector();
    c.indexRegions(unit, source);
    unit.accept(c);
    c.collectNames(unit);
    final inert = c.facts.region(Region.inert).names;
    final active = {
      ...c.facts.region(Region.rebuild).names,
      ...c.facts.region(Region.lifecycle).names,
    };
    final standIn = c.facts.region(Region.standIn).names;
    final inertOnly = inert.difference(active).difference(standIn);
    stdout.writeln(jsonEncode({
      'group': dir.path.split(Platform.pathSeparator).last,
      'inertOnly': inertOnly.toList()..sort(),
      'active': active.length,
    }));
  }
}
