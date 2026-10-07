/// The screening rules R1-R6, evaluated over `Facts` rather than over raw text.
///
/// The vocabulary is the same one `scripts/screen_samples.py` carried as regexes; only the
/// matching changed. Where the two differ deliberately it is noted on the rule.
library;

import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'facts.dart';
import 'shims.dart';

const kAnimatedWidgets = <String>{
  'AnimatedContainer', 'AnimatedOpacity', 'AnimatedAlign', 'AnimatedPadding',
  'AnimatedPositioned', 'AnimatedSwitcher', 'AnimatedCrossFade', 'AnimatedBuilder',
  'AnimatedDefaultTextStyle', 'AnimatedSize', 'AnimatedPhysical', 'AnimatedTheme',
  'AnimatedList', 'AnimatedIcon', 'AnimatedRotation', 'AnimatedScale', 'AnimatedSlide',
};

const kAnimationNames = <String>{
  'AnimationController',
  'Ticker',
  'TweenAnimationBuilder',
  'Hero',
  'vsync',
  'CircularProgressIndicator',
  'LinearProgressIndicator',
  'RefreshProgressIndicator',
};

const kAsyncNames = <String>{
  'StreamBuilder',
  'FutureBuilder',
  'Timer',
  'Future',
  'Stream',
};

const kIoNames = <String>{
  'HttpClient',
  'Dio',
  'Socket',
  'rootBundle',
  'NetworkImage',
  'SharedPreferences',
};

/// Platform views and media players: a live fetch and an embedded surface inside a traced
/// rebuild, which is what R3 exists to keep out. `samples/` contains none of the three;
/// before they were added, groups 0914 and 0980 shipped with no rule fired.
const kIoPrefixes = <String>{'WebView', 'VideoPlayer', 'AudioPlayer'};
const kIoConstructed = <String>{'File', 'Directory'};

const kKeepAliveNames = <String>{
  'AutomaticKeepAliveClientMixin',
  'wantKeepAlive',
  'KeepAliveHandle',
};

const kAppRoots = <String>{'MaterialApp', 'WidgetsApp', 'CupertinoApp'};

const kNonDeterministicNames = <String>{'Stopwatch'};

/// Digest of the whole vocabulary. `screen_samples.rules_fingerprint` folds this into the
/// checkpoint mode, so editing any rule here invalidates every `checkpoints_screen/` record
/// -- the same protection hashing `pat.pattern` used to give.
String rulesVersion() {
  final payload = [
    'R1:${_sorted(kAnimationNames)}|${_sorted(kAnimatedWidgets)}|suffix:Transition|mixin:TickerProvider',
    'R2:${_sorted(kAsyncNames)}|await|asyncBody|region:active',
    'R3:${_sorted(kIoNames)}|${_sorted(kIoPrefixes)}|${_sorted(kIoConstructed)}|dart:io|Image.network|http.|region:active',
    // The region partition is part of the matching, not of the vocabulary, so it has to be
    // spelled out here or a checkpoint written under the flat rules would replay as valid.
    // `fixture` joined the stand-in region in the 0.7.0 alignment, and the same boundary
    // now bounds the R7 hash, so both belong in the digest.
    'regions:standIn(fixture,declaration,unresolved),inert:excluded',
    'R7:hash:tokens<standInStart',
    'R4:${_sorted(kKeepAliveNames)}',
    'R5:${_sorted(kAppRoots)}',
    'R6:${_sorted(kNonDeterministicNames)}|DateTime.now|Random()',
    // R19's vocabulary is the emitter's pass-through preference order plus the argument
    // names a drop is reported for. Both decide verdicts, so both belong in the digest --
    // and the order matters as much as the membership, because it is what picks the
    // parameter the shim's `build` renders.
    'R19:${kPassThroughParameters.join(',')}|${_sorted(kChildBearingArguments)}'
        '|${_sorted(kBuilderArguments)}|region:transplant<standInStart',
  ].join('\n');
  return sha256.convert(utf8.encode(payload)).toString().substring(0, 16);
}

String _sorted(Set<String> s) => (s.toList()..sort()).join(',');

/// Ids of every rule that fires. Never short-circuits: `screen_samples` needs the full set
/// so a group can be adjudicated on one rule without losing the rest.
///
/// [shimDrops] comes from `shims.dart` and is empty for a file with no stand-in region. It is
/// a parameter rather than a `Facts` field because a drop is not a name in the unit: it is a
/// relation between a call site and a generated declaration, and `Facts` is a name index.
List<String> evaluate(Facts f, {List<ShimDrop> shimDrops = const []}) {
  final fired = <String>[];

  // R1 -- animation-driven rebuild. Also the round-1 rule that removed old seeds
  // 17/19/25/27/28: an indeterminate progress indicator kept MOUNTED animates forever, so
  // `pumpAndSettle` never settles.
  if (f.names.any(kAnimationNames.contains) ||
      f.names.any(kAnimatedWidgets.contains) ||
      f.names.any((n) => n.length > 10 && n.endsWith('Transition')) ||
      f.mixins.any((m) => m.contains('TickerProvider'))) {
    fired.add('R1_animation');
  }

  // R2 -- async/await- or Future/Stream-driven rebuild.
  //
  // Deliberately broader than the regex on one point: `\bFuture\s*\.` / `\bFuture<` only
  // fired on a qualified access or a generic type, so `Future foo()` slipped through. A
  // bare reference now counts, which is the conservative direction.
  //
  // Deliberately narrower on the point that motivated the port: `await` and `async` are
  // now the language constructs, so `Text('please await ...')` no longer fires. Unit 65's
  // `showMenu(...).then((index) {...})` still does not fire -- `.then(` was tried and
  // removed from the regex for being an interaction callback, and no rule replaces it.
  //
  // Narrowed 2026-08-23 to the code the COMMIT CONTAINED, dropping `spm isolate`'s
  // generated stand-in block, which is roughly 46% of the median transplant and was
  // excluding scopes with no async of their own at all.
  //
  // Narrowed again 2026-08-24 to the code a rebuild can REACH. An earlier attempt at this
  // was rejected for being lexical: it could not follow a call, so an `await` in a `_load()`
  // invoked from `initState` read as inert and slipped through, while `initState` itself
  // carried no vocabulary. `Facts._propagateRegions` closes that by promoting a member to
  // the region of whatever reaches it, so `active` now means reachable rather than merely
  // outside a handler.
  if (f.activeHasAwait ||
      f.activeHasAsyncBody ||
      f.activeNames.any(kAsyncNames.contains)) {
    fired.add('R2_async');
  }

  // R3 -- I/O- or network-driven rebuild.
  //
  // Same region treatment as R2: an `http.get` a rebuild can reach disqualifies the scope,
  // and one reachable only from an `onPressed` does not, because the harness mounts the
  // widget and calls `setState` without touching anything. `dart:io` stays unit-wide: an
  // import has no enclosing member, so it has no region to be reached from.
  if (f.imports.contains('dart:io') ||
      f.activeNames.any(kIoNames.contains) ||
      f.activeNames.any((n) => kIoPrefixes.any(n.startsWith)) ||
      f.activeInvoked.any(kIoConstructed.contains) ||
      f.activeQualified.contains('Image.network') ||
      f.activeQualified.any((q) => q.startsWith('http.'))) {
    fired.add('R3_io_network');
  }

  // R4 -- scrolling / keep-alive lifecycle mixin.
  if (f.names.any(kKeepAliveNames.contains) ||
      f.mixins.any(kKeepAliveNames.contains)) {
    fired.add('R4_keepalive');
  }

  // R5 -- nested application root. Round 2, units 09 and 31: the harness supplies the app,
  // and a nested root puts framework re-initialisation inside the measured span.
  if (f.names.any(kAppRoots.contains)) {
    fired.add('R5_nested_app');
  }

  // R6 -- non-deterministic input. `DateTime.now()` / `Random()` were REPAIRED to fixed
  // values in the original corpus; that repair is not available for a mined transplant --
  // editing one would make it stop being the code the commit contained -- so what was a
  // repair there is an exclusion here.
  if (f.names.any(kNonDeterministicNames.contains) ||
      f.qualified.contains('DateTime.now') ||
      f.invoked.contains('Random')) {
    fired.add('R6_nondeterminism');
  }

  // R19 -- a shim renders none of the subtree the transplanted code handed it, so the file
  // describes a smaller tree than the code it came from builds. That is the same defect
  // `R12_inline_reverted` reports, reached by shim synthesis rather than by inline revert,
  // and it is SOFT for the same reason: a drop present at both endpoints of a contrast
  // understates the magnitude of the delta without misattributing it. The pair-level half,
  // where the endpoints DISAGREE about the drop and the delta becomes the shim's, is
  // `R20_shim_child_form` in `scripts/screen/shims.py` -- hard, as R13 is.
  if (shimDrops.isNotEmpty) {
    fired.add('R19_shim_dropped_children');
  }

  return fired;
}
