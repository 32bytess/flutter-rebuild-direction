import 'dart:io';

// `onScreenshot` lives only in the EXTENDED driver; the plain
// `integration_test_driver.dart` has no such parameter and fails to compile with one.
import 'package:integration_test/integration_test_driver_extended.dart';

/// Where `takeScreenshot` bytes land. The runner exports it per execution as
/// `dataset/<group>/<device>/shots/`; a bare `flutter drive` gets a usable default
/// rather than an error, because a driver that throws takes the execution with it.
String get _shotDir => Platform.environment['SPM_SHOT_DIR'] ?? 'dataset/_shots';

/// The driver runs on the HOST, so this is host-side file IO and touches neither the
/// device nor the measured span. `onScreenshot` is only ever invoked when the test was
/// built with `--dart-define=SPM_SHOT=true`; in a measurement build the test never
/// calls `takeScreenshot`, so this callback is dead code at runtime.
Future<bool> _write(
  String name,
  List<int> bytes, [
  Map<String, Object?>? args,
]) async {
  try {
    final dir = Directory(_shotDir);
    await dir.create(recursive: true);
    final safe = name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final file = File('${dir.path}/$safe.png');
    await file.writeAsBytes(bytes);
    stdout.writeln('[SPM:shot] wrote ${file.path} (${bytes.length} bytes)');
    return true;
  } catch (e) {
    // Returning false fails the test. A diagnostic image is never worth a lost
    // execution, so report and carry on.
    stdout.writeln('[SPM:shot] FAILED to write $name: $e');
    return true;
  }
}

Future<void> main() {
  return integrationDriver(onScreenshot: _write);
}
