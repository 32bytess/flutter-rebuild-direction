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


// SEEDS -- the values the generated `initState` reads, for which `spm isolate`
// could build none. It declares each of these `late` and leaves it unassigned on
// purpose: a fabricated default would be measured as though it were the value that
// was really there. Assign one below and every role in this group gets it.

// slang's generated root object. Every `Text` in this group reads through `t`, and each
// role's `initState` assigns it from `tValue`, so one instance serves the whole group.
// `Translations` is declared in the transplant, so the generated fill would not construct
// one (`class_standin_authored`); it is authored here instead.
late Translations t;

Translations tValue = Translations.build();

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

WidgetRef fixtureRef = WidgetRef();

// DECLARATION-ONLY STAND-INS -- repo-local declarations that build no UI, and
// third-party ones the transplant does not inline. Supertypes are mirrored so a
// widget still reads as a widget; everything else is `dynamic`, because none of it
// is measured.

class AutoDisposeNotifierProviderImpl<NotifierT, T> {
  AutoDisposeNotifierProviderImpl(
    dynamic p0, {
    dynamic name,
    dynamic dependencies,
    dynamic from,
    dynamic argument,
    dynamic debugGetCreateSourceHash,
  });
  AutoDisposeNotifierProviderImpl.internal(
    dynamic p0, {
    dynamic name,
    dynamic dependencies,
    dynamic allTransitiveDependencies,
    dynamic debugGetCreateSourceHash,
    dynamic from,
    dynamic argument,
  });
  static const dynamic family = null;
  dynamic get notifier => const _Stub();
  dynamic createElement() => const _Stub();
  dynamic runNotifierBuild(dynamic notifier) => const _Stub();
  dynamic overrideWith(dynamic create) => const _Stub();
}

class ConsumerWidget extends StatelessWidget {
  const ConsumerWidget({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class Onboarding {
  Onboarding();
  dynamic build() => OnboardingModel();
  void nextPage() {}
  void previousPage() {}
  void confirmServerRunning() {}
}

class OnboardingModel {
  OnboardingModel({dynamic pageController, dynamic confirmServerRunning});
  dynamic get pageController => const _Stub();
  dynamic get confirmServerRunning => false;
  dynamic toggleConfirmServerRunning(dynamic newValue) => OnboardingModel();
  set confirmServerRunning(dynamic _) {}
}

class SvgPicture extends StatelessWidget {
  const SvgPicture(
    dynamic bytesLoader, {
    super.key,
    dynamic width,
    dynamic height,
    dynamic fit,
    dynamic alignment,
    dynamic matchTextDirection,
    dynamic allowDrawingOutsideViewBox,
    dynamic placeholderBuilder,
    dynamic colorFilter,
    dynamic semanticsLabel,
    dynamic excludeFromSemantics,
    dynamic clipBehavior,
    dynamic errorBuilder,
    dynamic theme,
    dynamic cacheColorFilter,
  });
  SvgPicture.asset(
    dynamic assetName, {
    super.key,
    dynamic matchTextDirection,
    dynamic bundle,
    dynamic package,
    dynamic width,
    dynamic height,
    dynamic fit,
    dynamic alignment,
    dynamic allowDrawingOutsideViewBox,
    dynamic placeholderBuilder,
    dynamic semanticsLabel,
    dynamic excludeFromSemantics,
    dynamic clipBehavior,
    dynamic errorBuilder,
    dynamic theme,
    dynamic colorFilter,
    dynamic color,
    dynamic colorBlendMode,
    dynamic cacheColorFilter,
  });
  SvgPicture.network(
    dynamic url, {
    super.key,
    dynamic headers,
    dynamic width,
    dynamic height,
    dynamic fit,
    dynamic alignment,
    dynamic matchTextDirection,
    dynamic allowDrawingOutsideViewBox,
    dynamic placeholderBuilder,
    dynamic colorFilter,
    dynamic color,
    dynamic colorBlendMode,
    dynamic semanticsLabel,
    dynamic excludeFromSemantics,
    dynamic clipBehavior,
    dynamic errorBuilder,
    dynamic cacheColorFilter,
    dynamic theme,
    dynamic httpClient,
  });
  SvgPicture.file(
    dynamic file, {
    super.key,
    dynamic width,
    dynamic height,
    dynamic fit,
    dynamic alignment,
    dynamic matchTextDirection,
    dynamic allowDrawingOutsideViewBox,
    dynamic placeholderBuilder,
    dynamic colorFilter,
    dynamic color,
    dynamic colorBlendMode,
    dynamic semanticsLabel,
    dynamic excludeFromSemantics,
    dynamic clipBehavior,
    dynamic errorBuilder,
    dynamic theme,
    dynamic cacheColorFilter,
  });
  SvgPicture.memory(
    dynamic bytes, {
    super.key,
    dynamic width,
    dynamic height,
    dynamic fit,
    dynamic alignment,
    dynamic matchTextDirection,
    dynamic allowDrawingOutsideViewBox,
    dynamic placeholderBuilder,
    dynamic colorFilter,
    dynamic color,
    dynamic colorBlendMode,
    dynamic semanticsLabel,
    dynamic excludeFromSemantics,
    dynamic clipBehavior,
    dynamic errorBuilder,
    dynamic theme,
    dynamic cacheColorFilter,
  });
  SvgPicture.string(
    dynamic string, {
    super.key,
    dynamic width,
    dynamic height,
    dynamic fit,
    dynamic alignment,
    dynamic matchTextDirection,
    dynamic allowDrawingOutsideViewBox,
    dynamic placeholderBuilder,
    dynamic colorFilter,
    dynamic color,
    dynamic colorBlendMode,
    dynamic semanticsLabel,
    dynamic excludeFromSemantics,
    dynamic clipBehavior,
    dynamic errorBuilder,
    dynamic theme,
    dynamic cacheColorFilter,
  });
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
  static dynamic get defaultPlaceholderBuilder => const _Stub();
  static set defaultPlaceholderBuilder(dynamic _) {}
  dynamic get width => null;
  dynamic get height => null;
  dynamic get fit => const _Stub();
  dynamic get alignment => const _Stub();
  dynamic get bytesLoader => const _Stub();
  dynamic get placeholderBuilder => null;
  dynamic get matchTextDirection => false;
  dynamic get allowDrawingOutsideViewBox => false;
  dynamic get semanticsLabel => null;
  dynamic get excludeFromSemantics => false;
  dynamic get clipBehavior => const _Stub();
  dynamic get colorFilter => null;
  dynamic get errorBuilder => null;
}

class Translations {
  Translations.build({
    dynamic overrides,
    dynamic cardinalResolver,
    dynamic ordinalResolver,
  });
  dynamic get $meta => const _Stub();
  // The only namespace this group reads. Held as a `late final` field rather than returned
  // from a getter so a rebuild reaching `t.onboarding` allocates nothing -- which is also
  // slang's own shape. The other namespaces are never reached here and stay stubs.
  late final dynamic onboarding = _StringsOnboardingEn._(this);
  dynamic get connect => const _Stub();
  dynamic get links => const _Stub();
  dynamic get settings => const _Stub();
  static dynamic of(dynamic context) => const _Stub();
  dynamic get search => const _Stub();
  dynamic get webview => const _Stub();
  dynamic get colors => const _Stub();
  dynamic get generic => const _Stub();
  dynamic get bookmarks => const _Stub();
  dynamic get tags => const _Stub();
}

class WidgetRef {
  WidgetRef();
  dynamic get context => const _Stub();
  // `ref.watch(onboardingProvider).confirmServerRunning` lands in `Checkbox.value`, a
  // `bool?`, so a `_Stub` here is a TypeError at mount rather than a harmless placeholder.
  // The provider below holds the value, and `watch` hands it back.
  dynamic watch<T>(dynamic provider) => provider;
  dynamic exists(dynamic provider) => false;
  void listen<T>(dynamic provider, dynamic listener, {dynamic onError}) {}
  dynamic listenManual<T>(
    dynamic provider,
    dynamic listener, {
    dynamic onError,
    dynamic fireImmediately,
  }) => const _Stub();
  dynamic read<T>(dynamic provider) => const _Stub();
  dynamic refresh<State>(dynamic provider) => const _Stub();
  void invalidate(dynamic provider) {}
}

// The English copy the application really ships, taken verbatim from the repository's
// `lib/i18n/strings_en.i18n.json` at this group's anchor. Length is laid-out text, so an
// invented placeholder would be a different line count under the same widget tree; these
// are the strings the measured screen actually renders.
class _StringsOnboardingEn {
  _StringsOnboardingEn._(dynamic p0);
  dynamic get title => 'Welcome to Linkdy';
  dynamic get subtitle => 'An application to manage your bookmarks.';
  dynamic get start => 'Start';
  dynamic get next => 'Next';
  dynamic get previous => 'Previous';
  dynamic get serverRequired => 'Server required';
  dynamic get serverRequiredDescription =>
      "Linkdy it's not an standalone app, it requires the Linkding server to work.\n"
      'In order to use this application, you must deploy Linkding on your home '
      'server, VPS or any other computer.';
  dynamic get installationInstructions =>
      'Check the installation instructions on the official GitHub repository.';
  dynamic get serverRunningConfirmation =>
      'I confirm that I have an instance of the Linkding server already running.';
  dynamic get createConnection => 'Create a connection';
  dynamic get createConnectionSubtitle =>
      'Enter all the required details to create a connection to your server.';
  dynamic get ipAddressOrDomain => 'IP address or domain';
  dynamic get port => 'Port';
  dynamic get token => 'Token';
  dynamic get required => 'Required';
  dynamic get serverDetails => 'Server details';
  dynamic get authentication => 'Authentication';
  dynamic get testConnectionUrl => 'Test connection url';
  dynamic get connect => 'Connect';
  dynamic get connecting => 'Connecting...';
  dynamic get cannotConnectToServer => 'Cannot connect to the server.';
  dynamic get invalidToken => 'Invalid token.';
  dynamic get invalidIpDomain => 'Invalid IP address or domain';
  dynamic get invalidPort => 'Invalid port';
  dynamic get tokenRequired => 'Token is required';
  dynamic get path => 'Path';
  dynamic get invalidPath => 'Invalid path';
  dynamic get connectionServerEstablished => 'Connection with server established';
  dynamic get testingConnection => 'Testing connection...';
  dynamic get connectionServerFailed => 'Connection with server failed';
}

// The state the onboarding screen mounts with. `confirmServerRunning` stays `false`, the
// value `onboarding.provider.dart` really seeds it with -- it is the condition deciding
// which arm of `onPressed` renders, so it is not a slot to fill by taste.
dynamic onboardingProvider = OnboardingModel();

class _Stub {
  const _Stub();

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
