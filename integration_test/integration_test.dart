import 'package:benchmark_container/generated_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:benchmark_container/main.dart' as app;
// spm 0.2.0 removed the `package:spm/features/profiler/presentation/` compatibility exports;
// `package:spm/spm.dart` is the only public entry point for SpmState/SpmProfiler from 0.2.0 on.
import 'package:spm/spm.dart';

Future<void> _settle(WidgetTester tester) async {
  try {
    await tester.pumpAndSettle(const Duration(seconds: 2));
  } catch (_) {
    await tester.pump(const Duration(milliseconds: 500));
  }
}

/// Whether to capture one diagnostic image after the measured span. Compile-time, so
/// an unset SPM_SHOT removes the capture block from the build entirely.
const bool _shot = bool.fromEnvironment('SPM_SHOT');

/// What to call the image. The runner passes `<group>__<role>`; the driver turns it
/// into a path. Never read when `_shot` is false.
const String _shotName = String.fromEnvironment(
  'SPM_SHOT_NAME',
  defaultValue: 'role',
);

/// Whether to print every framework error in full. Compile-time, exactly like [_shot],
/// so an unset SPM_DUMP_ERRORS removes the handler from the build entirely.
///
/// WHY IT EXISTS. In profile mode Flutter collapses repeated errors to
/// `Multiple exceptions (N) were detected during the running of the current test`, and
/// prints no exception and no stack for any of them. That is the whole log for 12 of the
/// roles `scripts/render_gate.py` condemns on pixels alone: the screenshot proves the
/// role drew `RenderErrorBox`, and nothing on disk says what threw, so the fixture cannot
/// be repaired. This hands back the message and the top frames.
///
/// It is a DIAGNOSTIC, never on for a measured execution. `FlutterError.onError` runs on
/// the UI thread, and printing from it during `traceAction` would add work to exactly the
/// frames being measured. Runs taken with this flag belong in a throwaway session.
const bool _dumpErrors = bool.fromEnvironment('SPM_DUMP_ERRORS');

/// Mount the widget, photograph it, and stop. Compile-time, like the two flags above.
///
/// WHAT IT IS FOR. A census asks one question -- does this role draw anything, or does it
/// draw Flutter's error box -- and the measured path answers it 126 seconds at a time: 61 s
/// of profiled rebuilds and ~41 s of `spm run` (its own pub resolve, `flutter analyze`,
/// injection, revert) before a single pixel is read back. None of that is evidence about
/// what the widget DRAWS.
///
/// The 30 rebuilds in particular buy nothing here: the loop below fires `setState(() {})`,
/// which re-runs the same `build` against the same state, so thirty of them photograph one
/// tree thirty times. What they exercise is the MEASURED path, and a census does not measure.
///
/// The load-bearing part is the `tester.state<SpmState>()` cast below. It only succeeds on an
/// injected build, which is what forces `spm run`; skipping it is what lets the census run a
/// bare `flutter drive` -- no injection, no profile mode, no analyze pass. Without injection
/// `GeneratedWidget` keeps the transplant's own `State`, and since `SpmState` extends `State`
/// and adds profiling only, the tree that mounts is the same one.
const bool _shotOnly = bool.fromEnvironment('SPM_SHOT_ONLY');

/// How many stack frames to print per error. Enough to name the throwing expression in
/// `generated_widget.dart` -- which is frame 0 whenever the role's own `build` threw --
/// without burying the message in framework frames.
const int _dumpFrames = 8;

/// Install a handler that prints each error in full, prefixed so `render_gate` can find it.
///
/// Chains to the previous handler rather than replacing it: `IntegrationTestWidgetsFlutter
/// Binding` installs its own to collect failures, and dropping that would turn a real test
/// failure into a silent pass.
void _installErrorDump() {
  final previous = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    // ignore: avoid_print -- the runner captures stdout; this is how it surfaces.
    print('[SPM:err] ${details.exception}');
    final frames = details.stack.toString().split('\n')
        .where((line) => line.trim().isNotEmpty)
        .take(_dumpFrames);
    for (final frame in frames) {
      // ignore: avoid_print
      print('[SPM:err] $frame');
    }
    previous?.call(details);
  };
}

/// Take the one diagnostic image, if this build asked for one. Safe on both paths.
///
/// Why it cannot perturb buildSpan on the MEASURED path:
///
///   1. `_shot` is `const bool.fromEnvironment`, a COMPILE-TIME constant. With SPM_SHOT unset
///      the whole block is tree-shaken out of the profile build, so the measured binary is
///      byte-identical to one built without this code.
///   2. It is called AFTER `traceAction` returns. Every `[SPM:perf] buildSpan` line the parser
///      consumes is already emitted and every profiler monitor has closed.
///   3. `convertFlutterSurfaceToImage` -- which DOES change the render surface, and is the
///      reason this is not simply always on -- is called here and nowhere earlier, so no
///      measured frame is ever rastered through it.
///
/// On the census path there is no measured span to protect, and this is the only thing the
/// run exists to do.
///
/// Failure is swallowed on purpose: the surface conversion is Android-only and can throw on
/// some device/driver combinations. Losing a measured execution because a diagnostic image
/// failed would be a strictly worse trade.
Future<void> _capture(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
) async {
  if (!_shot) {
    return;
  }
  try {
    await binding.convertFlutterSurfaceToImage();
    await _settle(tester);
    await binding.takeScreenshot(_shotName);
  } catch (e) {
    // ignore: avoid_print -- the runner greps stdout; this is how it surfaces.
    print('[SPM:shot] FAILED $_shotName: $e');
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Performance Benchmark', (WidgetTester tester) async {
    // Before `app.main()`: the errors worth naming are thrown by the FIRST build, and a
    // handler installed after the widget has mounted would miss every one of them.
    if (_dumpErrors) {
      _installErrorDump();
    }
    app.main();
    await _settle(tester);

    final widgetFinder = find.byType(GeneratedWidget);
    expect(
      widgetFinder,
      findsOneWidget,
      reason: 'GeneratedWidget did not mount',
    );
    // The census stops here: mounted, settled, and about to be photographed. Returning before
    // the cast is the whole point -- see `_shotOnly`.
    if (_shotOnly) {
      await _capture(binding, tester);
      return;
    }

    final state = tester.state<SpmState>(widgetFinder);

    // Inner loop: N profiled rebuilds. Each setState routes through SpmState ->
    // SpmProfiler.monitor (profile mode) and emits one `[SPM:perf] <id> buildSpan: <us>`
    // line. Warm-up is NOT discarded here — all N are emitted and the parser drops warm-up
    // off-device so the count stays tunable without re-measuring. Sized by --dart-define.
    const rebuilds = int.fromEnvironment('SPM_REBUILDS', defaultValue: 30);

    await binding.traceAction(() async {
      await _settle(tester);
      for (var i = 0; i < rebuilds; i++) {
        state.setState(() {});
        // Settle so each rebuild produces its own frame; the profiler matches one
        // target frame per setState. Coalesced frames would collapse measurements.
        await _settle(tester);
        // Wait for THIS rebuild's buildSpan to be recorded before triggering the next.
        // The profiler's frame-timing callback fires after the frame is presented,
        // which can be after pumpAndSettle returns; without this await the next
        // setState collides with the still-active monitor and the reading is lost.
        await SpmProfiler.current;
      }
    });

    // ---- Diagnostic screenshot: STRICTLY after the measured span -------------------
    //
    // What it is for: a fixture that mounts but renders nothing is invisible to every
    // check we have. `0792` shipped `<String, List<Conversation>>{}` -> `itemCount: 0`
    // across 34 of 215 contrasts, and `1860` was handed a `Color` where the revisions
    // index a `List`. Both produce a feature vector the device cannot possibly match --
    // a systematically wrong label, not noise. One image per role makes that visible.
    // Why it cannot perturb buildSpan:
    //
    //   1. `_shot` is `const bool.fromEnvironment`, a COMPILE-TIME constant. With
    //      SPM_SHOT unset the whole block is tree-shaken out of the profile build, so
    //      the measured binary is byte-identical to one built without this code.
    //   2. It runs AFTER `traceAction` returns. Every `[SPM:perf] buildSpan` line the
    //      parser consumes is already emitted and every profiler monitor has closed.
    //   3. `convertFlutterSurfaceToImage` -- which DOES change the render surface, and
    //      is the reason this is not simply always on -- is called here and nowhere
    //      earlier, so no measured frame is ever rastered through it.
    //
    // Failure is swallowed on purpose: the surface conversion is Android-only and can
    // throw on some device/driver combinations. Losing a measured execution because a
    // diagnostic image failed would be a strictly worse trade.
    await _capture(binding, tester);
  });
}
