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

class ConsumerWidget extends StatelessWidget {
  const ConsumerWidget({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class Translations {
  Translations.build({
    dynamic overrides,
    dynamic cardinalResolver,
    dynamic ordinalResolver,
  });
  dynamic get $meta => const _Stub();
  dynamic get generic => const _Stub();
  dynamic get onboarding => const _Stub();
  dynamic get links => const _Stub();
  dynamic get search => const _Stub();
  // The only namespace this group reads. Held as a `late final` field rather than returned
  // from a getter so a rebuild reaching `t.settings` allocates nothing -- which is also
  // slang's own shape. The other namespaces are never reached here and stay stubs.
  late final dynamic settings = _StringsSettingsEn._(this);
  dynamic get webview => const _Stub();
  dynamic get colors => const _Stub();
  static dynamic of(dynamic context) => const _Stub();
  dynamic get bookmarks => const _Stub();
  dynamic get tags => const _Stub();
}

class WidgetRef {
  WidgetRef();
  dynamic get context => const _Stub();
  // HAND-AUTHORED 2026-09-15 (provider passthrough), after the same repair in group 0632.
  // Was `=> const _Stub()`, which threw away the stand-in the generator had already
  // reconstructed for the provider and handed the transplant a `_Stub` instead -- so
  // `ref.watch(x).y` reaching a statically typed slot threw inside `build` and the device drew
  // Flutter's error box. Handing back the provider itself keeps the chain typed; a provider
  // still standing in as `_Stub` is unchanged, so this is inert until one is given a value.
  dynamic watch<T>(dynamic provider) =>
      provider is _Stub ? const _Stub() : provider;
  dynamic exists(dynamic provider) => false;
  void listen<T>(dynamic provider, dynamic listener, {dynamic onError}) {}
  dynamic listenManual<T>(
    dynamic provider,
    dynamic listener, {
    dynamic onError,
    dynamic fireImmediately,
  }) => const _Stub();
  // Same passthrough, same reason, and needed here too: the role writes
  // `onChanged: ref.read(appStatusProvider.notifier).setUseInAppBrowser`, so `read` feeds a
  // `ValueChanged<bool>?` slot by way of the notifier. Matches 0632, which passes `watch`,
  // `read` and `refresh` alike.
  dynamic read<T>(dynamic provider) =>
      provider is _Stub ? const _Stub() : provider;
  dynamic refresh<State>(dynamic provider) =>
      provider is _Stub ? const _Stub() : provider;
  void invalidate(dynamic provider) {}
}

// The English copy of the settings screen. Length is laid-out text, so an empty string is a
// different line count under the same widget tree; these are the strings the measured screen
// actually renders.
class _StringsSettingsEn {
  _StringsSettingsEn._(dynamic p0);
  dynamic get settings => 'Settings';
  dynamic get appSettings => 'App settings';
  dynamic get aboutApp => 'About the app';
  dynamic get appVersion => 'App version';
  dynamic get createdBy => 'Created by JGeek00';
  dynamic get visitGooglePlay => 'Visit Google Play';
  dynamic get visitGitHubRepo => 'Visit the GitHub repository';
  dynamic get customization => const _Stub();
  late final dynamic generalSettings = _StringsSettingsGeneralSettingsEn._(this);
  dynamic get linkdingRepository => 'Linkding repository';
  dynamic get linkdingRepositoryDescription =>
      'Visit the official Linkding repository on GitHub.';
}

class _StringsSettingsGeneralSettingsEn {
  _StringsSettingsGeneralSettingsEn._(dynamic p0);
  dynamic get generalSettings => 'General settings';
  dynamic get generalSettingsDescription =>
      'Modify the general settings of the application.';
  dynamic get disconnectFromServer => 'Disconnect from server';
  dynamic get disconnectModal => const _Stub();
  dynamic get useInAppBrowser => 'Use in-app browser';
  dynamic get useInAppBrowserDescription =>
      'Open the links inside the application instead of using an external browser.';
  dynamic get bookmarks => 'Bookmarks';
  dynamic get showFavicon => 'Show favicon';
  dynamic get showFaviconDescription =>
      'Show the favicon of the website on each bookmark card.';
}

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

class AppStatus {
  AppStatus();
  dynamic build() => AppStatusModel();
  void setTheme(dynamic theme) {}
  void setSupportsDynamicTheme(dynamic value) {}
  void setUseDynamicTheme(dynamic value) {}
  void setSelectedColor(dynamic value) {}
  void setUseInAppBrowser(dynamic value) {}
  void setShowFavicon(dynamic value) {}
}

class AppStatusModel {
  AppStatusModel({
    dynamic selectedTheme,
    dynamic supportsDynamicTheme,
    dynamic useDynamicTheme,
    dynamic selectedColor,
    dynamic useInAppBrowser,
    dynamic showFavicon,
  });
  dynamic get selectedTheme => const _Stub();
  set selectedTheme(dynamic _) {}
  dynamic get supportsDynamicTheme => false;
  set supportsDynamicTheme(dynamic _) {}
  dynamic get useDynamicTheme => false;
  set useDynamicTheme(dynamic _) {}
  dynamic get selectedColor => 0;
  set selectedColor(dynamic _) {}
  dynamic get useInAppBrowser => false;
  set useInAppBrowser(dynamic _) {}
  dynamic get showFavicon => false;
  set showFavicon(dynamic _) {}

  // HAND-AUTHORED 2026-09-15, with the provider passthrough above. `provider.notifier` is
  // Riverpod's own accessor for the notifier behind a NotifierProvider, and the role uses it
  // for every switch: `ref.read(appStatusProvider.notifier).setUseInAppBrowser`. Once the
  // provider carries the MODEL (below), `.notifier` lands here rather than on a `_Stub`, and
  // without this getter it would be a NoSuchMethodError on a plain class -- the passthrough
  // would have moved the failure rather than fixed it.
  //
  // `AppStatus` is the generator's own reconstruction, declared at :185, and it already owns
  // every setter the roles reach: `setUseInAppBrowser`, `setShowFavicon`, `setTheme` and the
  // rest, each a `void Function(dynamic)` with an empty body. Handing it back is a
  // re-connection of two stand-ins this file already contains. It is also what makes the
  // handler slots type-check: `void Function(dynamic)` IS a subtype of `ValueChanged<bool>`,
  // by parameter contravariance. The bodies stay empty, so no callback does any work -- which
  // is correct here, since 0.7.0 no longer enters a closure a rebuild cannot run.
  dynamic get notifier => AppStatus();
}

class NotifierProviderImpl<NotifierT, T> {
  NotifierProviderImpl(
    dynamic p0, {
    dynamic name,
    dynamic dependencies,
    dynamic from,
    dynamic argument,
    dynamic debugGetCreateSourceHash,
  });
  NotifierProviderImpl.internal(
    dynamic p0, {
    dynamic name,
    dynamic dependencies,
    dynamic allTransitiveDependencies,
    dynamic debugGetCreateSourceHash,
    dynamic from,
    dynamic argument,
  });
  static const dynamic autoDispose = null;
  static const dynamic family = null;
  dynamic get notifier => const _Stub();
  dynamic createElement() => const _Stub();
  dynamic runNotifierBuild(dynamic notifier) => const _Stub();
  dynamic overrideWith(dynamic create) => const _Stub();
}

// HAND-AUTHORED 2026-09-15, with the provider passthrough above. The roles read
// `ref.watch(appStatusProvider).useInAppBrowser` and `.showFavicon` into `SwitchListTile`'s
// `value:`, which is a non-nullable `bool` -- so the `_Stub` threw and the device drew the
// error box.
//
// NO VALUE IS INVENTED HERE. `AppStatus.build()` at :187 already says what this provider
// yields -- `dynamic build() => AppStatusModel()` -- and `AppStatusModel` at :196 already
// carries every field the roles read, each with the value the generator resolved:
// `useInAppBrowser => false`, `showFavicon => false`, `supportsDynamicTheme => false`.
// Naming the model here is therefore a re-connection of what the file already states, not a
// new fact. Both switches render whatever their `value:` is, so no subtree is added or
// removed by it and tree size is untouched.
dynamic appStatusProvider = AppStatusModel();
