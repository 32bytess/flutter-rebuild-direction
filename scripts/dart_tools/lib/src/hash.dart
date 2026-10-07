/// Stage-1c near-duplicate hash, computed from the token stream.
///
/// The regex version stripped comments and then collapsed every run of whitespace with
/// `\s+` -- INCLUDING whitespace inside string literals, so two transplants differing only
/// within a string collapsed into one near-duplicate. The token stream cannot make that
/// mistake: a string literal is one token and keeps its lexeme verbatim, while comments are
/// precomment tokens and never appear in the chain at all.
///
/// Hash values therefore differ from the regex version for every file. That is expected and
/// is covered by `rulesVersion()` flowing into the checkpoint mode.
///
/// `until` is what keeps the hash about the CODE. `spm isolate` 0.7.0 relocates a scope's
/// whole initial state into the fixture block, so hashing to EOF compares the values a
/// binding was seeded with alongside the tree they build: two transplants of one identical
/// widget tree hash apart because a lifted `int fixtureLimit` differs. Since the caller
/// already computes `standInStart` for the region map, the hash takes the same boundary,
/// and R7 goes back to asking the question stage 1c asked -- is this the same widget tree.
library;

import 'dart:convert';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:crypto/crypto.dart';

/// Separator between lexemes. NUL rather than a space because no Dart lexeme can contain
/// it, so no two distinct token sequences can join to the same string.
const _sep = '\u0000';

/// `until` is a source offset: tokens at or after it are scaffolding and are not hashed.
/// -1, the default, hashes the whole file, which is what a corpus carrying no generated
/// banner needs.
String normalisedHash(CompilationUnit unit, {int until = -1}) {
  final parts = <String>[];
  var token = unit.beginToken;
  while (!token.isEof) {
    if (until >= 0 && token.offset >= until) break;
    parts.add(token.lexeme);
    final next = token.next;
    if (next == null) break;
    token = next;
  }
  return sha256
      .convert(utf8.encode(parts.join(_sep)))
      .toString()
      .substring(0, 16);
}
