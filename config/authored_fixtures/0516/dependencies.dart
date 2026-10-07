// GENERATED FIXTURE SKELETON -- spm-fixture-v2
//
// Declarations lifted out of this group's transplants so that ONE fixture serves every role in
// it. That is the point of the file: the same values mount for both endpoints of every
// contrast, so a measured difference is attributable to the edit and not to the scaffolding.
//
// HOW THE VALUES GOT HERE. They are not authored by hand and not invented by the generator.
// Each one is resolved by a pre-registered hierarchy and the rule that fired is recorded, per
// binding, in this group's `fixture_provenance.json`:
//
//   relocated        the value really was in the application; `spm isolate` moved it here
//                    verbatim. Do not "tidy" one -- it is a measurement input.
//   upstream_literal not relocated, but the repository declares it at this group's anchor
//                    commit; taken verbatim, with `file@sha` recorded.
//   protocol_constant neither of the above; the committed table in `config/fixture_policy.json`.
//                    Collection cardinality is one declared constant, corpus-wide.
//   maximal_branch   a bool/enum/nullability that decides WHICH subtree renders takes the arm
//                    that renders more. This one OVERRIDES a relocated value, and says so.
//
// WHAT REMAINS TRUE REGARDLESS OF WHO OR WHAT FILLS A SLOT:
//
//   * The same values serve every role in the group. That is what makes the stubbing
//     symmetric across a pair, which is what makes a measured difference attributable to
//     the edit rather than to the scaffolding.
//   * Fixed collection cardinality. A list of 3 in one place and 10 in another is a change
//     in tree size, and tree size is the dependent variable.
//   * Deterministic values only: no `Random`, no `DateTime.now()`, no I/O, no network, no
//     animation controllers left ticking.
//   * Keep `extends` and `implements` clauses exactly as they are. `spm analyze` decides
//     widget versus value object by walking the supertype chain, so a stand-in that stops
//     extending its widget base silently moves allocations into `valueObjectAllocCount`.
//   * Fill before measuring, then freeze. A fixture edited after seeing a result is a
//     fixture the result cannot be defended against.
//
// A slot the hierarchy cannot resolve keeps its `// TODO: value` and is NOT guessed.
// `scripts/fixture_gate.py` then refuses the group, so an unfilled fixture cannot reach the
// device.
//
// This file is a pure function of the mine plus two committed tables, and is regenerated as
// long as it is untouched. The first HAND edit makes it yours: the screen sees the file no
// longer matches the hash it recorded, copies it into config/authored_fixtures/, and never
// generates over it again -- including after a prune deletes this directory, which is how
// the hash alone used to lose an edit. `scripts/authored_fixtures.py --list` says which
// groups the corpus no longer derives from the mine; `--release <group>` hands one back.
// ignore_for_file: unused_import, unused_element, unused_field
part of generated_widget;


// LIFTED BINDINGS -- the scope's initial state, which `spm isolate` 0.7.0 moves out
// of the application and into a fixture block of its own. Most of these carry the
// value that was really there, relocated rather than invented, and are reproduced
// here verbatim: do not "tidy" one, it is a measurement input.
//
// The ones marked TODO are the exception. Where the binding came from the
// application and no value existed to move, the block gets an empty collection or a
// null, and how many elements you put in one IS tree size -- the dependent variable.
// That is a decision, and it is why they are hoisted: filled in once here, the whole
// group mounts from identical values, so a measured difference is attributable to
// the edit rather than to the scaffolding.

// HAND-AUTHORED 2026-09-15 (typed initialiser). Was `= inject()`, and `inject<T>()` at :124 is
// a stand-in returning `const _Stub()` -- so this binding declared `AuthService` statically,
// held a `_Stub` at runtime, and threw the moment the role reached it. Dart accepts the
// assignment because `inject` returns `dynamic`, which is exactly why nothing before the
// device caught it: R10, R14 and R15 all see a well-typed declaration.
//
// NO VALUE IS INVENTED HERE. `class AuthService` is the generator's own reconstruction at
// :113, sitting unused in this same file, and its three members already carry resolved
// values -- `stopAuthenticate()` and `supportBiometric()` return `Future<bool>.value(false)`,
// `authenticate()` returns a stub the role only ever calls from a handler. Constructing it is
// naming what the file already declares, not adding a fact. `AuthService` is in neither of
// `config/fixture_policy.json`'s refusal tables.
AuthService fixtureLocalAuthService = AuthService();

// DECLARATION-ONLY STAND-INS -- repo-local declarations that build no UI, and
// third-party ones the transplant does not inline. Supertypes are mirrored so a
// widget still reads as a widget; everything else is `dynamic`, because none of it
// is measured.

class AllpassEdgeInsets {
  AllpassEdgeInsets._();
  static dynamic get listInset =>
      const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  static set listInset(dynamic _) {}
  static dynamic get dividerInset => const EdgeInsets.symmetric(horizontal: 16);
  static set dividerInset(dynamic _) {}
  static dynamic get forViewCardInset =>
      const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  static set forViewCardInset(dynamic _) {}
  static dynamic get forCardInset => const EdgeInsets.all(12);
  static set forCardInset(dynamic _) {}
  static dynamic get settingCardInset =>
      const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
  static set settingCardInset(dynamic _) {}
  static dynamic get forSearchButtonInset =>
      const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
  static set forSearchButtonInset(dynamic _) {}
  static dynamic get smallTBPadding => const EdgeInsets.symmetric(vertical: 8);
  static set smallTBPadding(dynamic _) {}
  static dynamic get smallLPadding => const EdgeInsets.only(left: 8);
  static set smallLPadding(dynamic _) {}
  static dynamic get smallRPadding => const EdgeInsets.only(right: 8);
  static set smallRPadding(dynamic _) {}
  static dynamic get smallTopInsets => const EdgeInsets.only(top: 8);
  static set smallTopInsets(dynamic _) {}
  static dynamic get bottom10Inset => const EdgeInsets.only(bottom: 10);
  static set bottom10Inset(dynamic _) {}
  static dynamic get bottom30Inset => const EdgeInsets.only(bottom: 30);
  static set bottom30Inset(dynamic _) {}
  static dynamic get bottom50Inset => const EdgeInsets.only(bottom: 50);
  static set bottom50Inset(dynamic _) {}
  static dynamic get widgetItemInset =>
      const EdgeInsets.symmetric(horizontal: 16, vertical: 4);
  static set widgetItemInset(dynamic _) {}
}

class AllpassScreenUtil {
  AllpassScreenUtil._();
  static dynamic get screenHighDp => 640.0;
  static set screenHighDp(dynamic _) {}
  static dynamic setWidth(dynamic width) => (width as num).toDouble();
  static dynamic setHeight(dynamic height) => (height as num).toDouble();
}

class AuthService {
  AuthService();
  dynamic authenticate(dynamic context) => const _Stub();
  dynamic stopAuthenticate() => Future<bool>.value(false);
  dynamic supportBiometric() => Future<bool>.value(false);
}

extension L10nSupport on BuildContext {
  dynamic get l10n => const _Stub();
}

dynamic inject<T>({dynamic instanceName, dynamic param1, dynamic param2}) =>
    const _Stub();

class _Stub {
  const _Stub();

  // l10n strings reached through `context.l10n` in this group's build bodies.
  String get unlockAllpass => 'Unlock Allpass';
  String get clickToUseBiometrics => 'Tap to unlock with biometrics';
  String get usePassword => 'Use password';

  int get length => 0;
  bool get isEmpty => true;
  bool get isNotEmpty => false;
  Iterator<dynamic> get iterator => const Iterable<dynamic>.empty().iterator;

  dynamic operator [](Object? key) => const _Stub();
  dynamic operator +(Object? other) => const _Stub();
  bool operator <(Object? other) => false;
  bool operator >(Object? other) => false;
  bool operator <=(Object? other) => false;
  bool operator >=(Object? other) => false;

  @override
  bool operator ==(Object other) => other is _Stub;

  @override
  int get hashCode => 0;

  @override
  dynamic noSuchMethod(Invocation invocation) => const _Stub();

  @override
  String toString() => '';
}

class AllpassNavigator {
  AllpassNavigator._();
  static void goRegisterPage(dynamic context) {}
  static void goLoginPage(dynamic context, {dynamic arguments}) {}
  static void goAuthLoginPage(dynamic context, {dynamic arguments}) {}
  static void goHomePage(dynamic context) {}
  static void goImportDataPage(dynamic context, dynamic data) {}
}

class AutoLockHandler {
  AutoLockHandler._();
  static void pendingLock() {}
  static void lock(dynamic context) {}
  static void unlock() {}
}

class LoginArguments {
  const LoginArguments({dynamic fromAutoLock});
  dynamic get fromAutoLock => false;
}

extension ReadContext on BuildContext {
  dynamic read<T>() => const _Stub();
}

class ThemeProvider extends ChangeNotifier {
  ThemeProvider();
  dynamic get appTheme => const _Stub();
  dynamic get specialBackgroundColor => const Color(0xFFF5F5F5);
  set specialBackgroundColor(dynamic _) {}
  dynamic get offstageColor => const Color(0x00000000);
  set offstageColor(dynamic _) {}
  dynamic init() => const _Stub();
  void changeThemeMode(dynamic targetMode, dynamic platformBrightness) {}
  void changePrimaryColor(dynamic color, dynamic platformBrightness) {}
  void setExtraColor(dynamic platformBrightness) {}
  dynamic get successContentColor => const Color(0xFF1B5E20);
  set successContentColor(dynamic _) {}
  dynamic get successBackgroundColor => const Color(0xFFE8F5E9);
  set successBackgroundColor(dynamic _) {}
  dynamic get infoContentColor => const Color(0xFF0D47A1);
  set infoContentColor(dynamic _) {}
  dynamic get infoBackgroundColor => const Color(0xFFE3F2FD);
  set infoBackgroundColor(dynamic _) {}
  dynamic get warningContentColor => const Color(0xFFE65100);
  set warningContentColor(dynamic _) {}
  dynamic get waringBackgroundColor => const Color(0xFFFFF3E0);
  set waringBackgroundColor(dynamic _) {}
  dynamic get errorContentColor => const Color(0xFFB71C1C);
  set errorContentColor(dynamic _) {}
  dynamic get errorBackgroundColor => const Color(0xFFFFEBEE);
  set errorBackgroundColor(dynamic _) {}
  dynamic get iconColor => const Color(0xFF616161);
  set iconColor(dynamic _) {}
}

// UNRESOLVED-REFERENCE STAND-INS -- reconstructed from the call sites, because the
// symbol lives in a package this file may not import or the source project's own
// dependencies were never installed. Every type here is `dynamic`.

extension _SpmPlatformDispatcherShim on PlatformDispatcher {
  dynamic get onPlatformBrightnessChanged => const _Stub();
}
