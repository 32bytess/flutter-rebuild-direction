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

// HAND-FILLED. `Translations` is a class declared in the transplant and `spm isolate` could
// build no value for it, so the two seeds are authored here (fixture_provenance.json:
// rule `unrecoverable`, rule_id `class_standin_authored`). One instance is built once, at
// top level, not per build: constructing it has a cost and that cost belongs to the
// scaffolding, not to the measured rebuild. `initState` still does `t = tValue`, so both
// endpoints of every contrast read the same strings.
Translations t = Translations.build();

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

// HAND-FILLED. One shared provider value and one shared notifier, built once at top level so
// that every build in every rev reads the SAME objects: a fresh `ConnectModel()` per
// `ref.watch` would hand each rebuild new controllers, which is scaffolding cost inside the
// measured window and a form that resets itself between frames. The controllers carry the
// text a filled-in connection form really holds in this screen, which is what the revs
// interpolate into `connectionString` and render. Every `.text` here is non-empty, which is
// the arm the empty stub already took (`_Stub != ''` is true), so the `:port` segment of the
// URL renders exactly as before -- no branch moves.
final TextEditingController _fixtureIpDomainController = TextEditingController(
  text: 'linkding.home.arpa',
);

final TextEditingController _fixturePortController = TextEditingController(
  text: '9090',
);

final TextEditingController _fixturePathController = TextEditingController(
  text: '/linkding',
);

final TextEditingController _fixtureTokenController = TextEditingController(
  text: '4f1c8a2be9d34761b05ecf3a8d2719c6',
);

final ConnectModel _fixtureConnectModel = ConnectModel();

final Connect _fixtureConnect = Connect();

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

class Connect {
  Connect();
  dynamic build() => ConnectModel();
  void setConnectionMethod(dynamic method) {}
  void validateIpDomain(dynamic value) {}
  void validatePort(dynamic value) {}
  void validateToken(dynamic value) {}
  dynamic validValues() => false;
  void validatePath(dynamic value) {}
}

class ConnectModel {
  ConnectModel({
    dynamic isConnecting,
    dynamic method,
    dynamic ipDomainController,
    dynamic ipDomainError,
    dynamic portController,
    dynamic portError,
    dynamic pathController,
    dynamic pathError,
    dynamic tokenController,
    dynamic tokenError,
    dynamic validValues,
  });
  // HAND-FILLED. Only the four controllers change: they reach a typed `TextFormField`
  // slot and their `.text` is rendered, so they carry the real values of a filled-in
  // connection form instead of a stub with no text. The rest are deliberately left as
  // they are -- `method` picks which enum member the segmented button selects,
  // `validValues` decides whether the test-URL button gets a callback or `null`, and each
  // `...Error` decides whether an error line renders. Those are conditions, and a
  // condition moved here would move the tree, not the fixture.
  dynamic get isConnecting => false;
  dynamic get method => 0;
  dynamic get ipDomainController => _fixtureIpDomainController;
  dynamic get ipDomainError => null;
  dynamic get portController => _fixturePortController;
  dynamic get portError => null;
  dynamic get pathController => _fixturePathController;
  dynamic get pathError => null;
  dynamic get tokenController => _fixtureTokenController;
  dynamic get tokenError => null;
  dynamic get validValues => false;
  dynamic copyWidth({
    dynamic isConnecting,
    dynamic method,
    dynamic ipDomainController,
    dynamic ipDomainError,
    dynamic portController,
    dynamic portError,
    dynamic pathController,
    dynamic pathError,
    dynamic tokenController,
    dynamic tokenError,
    dynamic validValues,
  }) => ConnectModel();
  set isConnecting(dynamic _) {}
  set method(dynamic _) {}
  set ipDomainError(dynamic _) {}
  set portError(dynamic _) {}
  set pathError(dynamic _) {}
  set tokenError(dynamic _) {}
  set validValues(dynamic _) {}
}

class ConsumerWidget extends StatelessWidget {
  const ConsumerWidget({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class SegmentedButtonSlide extends StatelessWidget {
  const SegmentedButtonSlide({
    super.key,
    dynamic entries,
    dynamic selectedEntry,
    dynamic onChange,
    dynamic colors,
    dynamic animationDuration,
    dynamic curve,
    dynamic slideShadow,
    dynamic barShadow,
    dynamic margin,
    dynamic height,
    dynamic fontSize,
    dynamic iconSize,
    dynamic textOverflow,
  });
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
  // HAND-FILLED. Inert accessors on a declaration-only stand-in: `build` returns
  // `SizedBox.shrink()` and no rev reads one, so they decide no branch and change no tree
  // size. They carry what the revs actually pass at the call site -- a 40pt bar with 24pt
  // side margins, 14pt labels, ellipsised overflow -- so the fixture reads like the app.
  // `entries` keeps its cardinality: how many elements a collection holds is tree size.
  dynamic get entries => [];
  dynamic get selectedEntry => 0;
  dynamic get onChange => const _Stub();
  dynamic get colors => SegmentedButtonSlideColors();
  // `animationDuration` stays `Duration.zero`: the fixture protocol forbids anything left
  // ticking, and zero is the value that guarantees it.
  dynamic get animationDuration => Duration.zero;
  dynamic get curve => Curves.easeInOut;
  dynamic get slideShadow => null;
  dynamic get barShadow => null;
  dynamic get margin => const EdgeInsets.symmetric(horizontal: 24);
  dynamic get height => 40.0;
  dynamic get fontSize => 14.0;
  dynamic get iconSize => 20.0;
  dynamic get textOverflow => TextOverflow.ellipsis;
}

class SegmentedButtonSlideColors {
  const SegmentedButtonSlideColors({
    dynamic barColor,
    dynamic backgroundSelectedColor,
    dynamic foregroundSelectedColor,
    dynamic foregroundUnselectedColor,
    dynamic hoverColor,
  });
  // HAND-FILLED. Inert accessors -- the revs build this object with their own theme colors
  // and nothing reads these back. They carry the same roles the call site passes (a faded
  // primary bar, primary on the selected segment, onPrimary/onSurface labels), as colors
  // rather than stubs.
  dynamic get barColor => const Color(0x33006874);
  dynamic get backgroundSelectedColor => const Color(0xFF006874);
  dynamic get foregroundSelectedColor => const Color(0xFFFFFFFF);
  dynamic get foregroundUnselectedColor => const Color(0xFF191C1D);
  dynamic get hoverColor => const Color(0xFF3F484A);
}

class SegmentedButtonSlideEntry {
  const SegmentedButtonSlideEntry({dynamic icon, dynamic label});
  // HAND-FILLED. Inert accessors -- the revs pass `label:` themselves ("HTTP"/"HTTPS") and
  // read nothing back. They carry the first of those two segments rather than nulls.
  dynamic get icon => Icons.link_rounded;
  dynamic get label => 'HTTP';
}

class Translations {
  Translations.build({
    dynamic overrides,
    dynamic cardinalResolver,
    dynamic ordinalResolver,
  });
  dynamic get $meta => const _Stub();
  // HAND-FILLED. `onboarding` is the only sub-table the revs read, and the transplant
  // already carries the class that holds it, so it returns that rather than a bare stub --
  // otherwise every `t.onboarding.<key>` is a `_Stub` reaching a `String` slot. It is a
  // `const` instance, exactly like the `_Stub` it replaces, so the swap allocates nothing.
  // The remaining sub-tables have no declared class here and no rev reads one.
  dynamic get onboarding => const _StringsOnboardingEn._(null);
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
  // HAND-FILLED. `watch` hands back the group's one `ConnectModel` and `read` its one
  // `Connect`, both built once above -- the transplant declares both classes, and the revs
  // reach a typed slot through each (`provider.method` indexes `ConnectionMethod.values`,
  // `...Controller` is a `TextFormField`'s controller, the notifier's `validateXxx` is an
  // `onChanged`). Returning the shared instance, not a new one, keeps the objects identical
  // across rebuilds and across every role in the group.
  dynamic watch<T>(dynamic provider) => _fixtureConnectModel;
  dynamic exists(dynamic provider) => false;
  void listen<T>(dynamic provider, dynamic listener, {dynamic onError}) {}
  dynamic listenManual<T>(
    dynamic provider,
    dynamic listener, {
    dynamic onError,
    dynamic fireImmediately,
  }) => const _Stub();
  dynamic read<T>(dynamic provider) => _fixtureConnect;
  dynamic refresh<State>(dynamic provider) => const _Stub();
  void invalidate(dynamic provider) {}
}

// HAND-FILLED. The English onboarding copy of the connection screen this group was mined
// from. Nine of these keys are rendered by the revs (`createConnectionSubtitle`,
// `serverDetails`, `ipAddressOrDomain`, `required`, `port`, `authentication`, `token`,
// `path`, `testConnectionUrl`); the rest belong to the same table and are filled for the
// same reason, so no slot renders an empty string. Labels and helpers are one line, as the
// app's are -- none of them wraps to a second line at the widths these revs lay out, so
// tree size is the same for every role in the group. The constructor is `const` so the
// table is a compile-time value and no build allocates one.
class _StringsOnboardingEn {
  const _StringsOnboardingEn._(dynamic p0);
  dynamic get title => 'Welcome to Linkdy';
  dynamic get subtitle => 'Your bookmarks, everywhere';
  dynamic get start => 'Get started';
  dynamic get next => 'Next';
  dynamic get previous => 'Back';
  dynamic get serverRequired => 'A server is required';
  dynamic get serverRequiredDescription =>
      'Linkdy needs a Linkding server to connect to';
  dynamic get installationInstructions => 'Installation instructions';
  dynamic get serverRunningConfirmation => 'My server is already running';
  dynamic get createConnection => 'Create a connection';
  dynamic get createConnectionSubtitle =>
      'Enter the details of your Linkding server';
  dynamic get ipAddressOrDomain => 'IP address or domain';
  dynamic get port => 'Port';
  dynamic get token => 'API token';
  dynamic get required => 'Required';
  dynamic get serverDetails => 'Server details';
  dynamic get authentication => 'Authentication';
  dynamic get testConnectionUrl => 'Test connection URL';
  dynamic get connect => 'Connect';
  dynamic get connecting => 'Connecting';
  dynamic get cannotConnectToServer => 'Cannot connect to the server';
  dynamic get invalidToken => 'Invalid API token';
  dynamic get invalidIpDomain => 'Invalid IP address or domain';
  dynamic get invalidPort => 'Invalid port';
  dynamic get tokenRequired => 'The API token is required';
  dynamic get path => 'Path';
  dynamic get invalidPath => 'Invalid path';
}

dynamic connectProvider = const _Stub();

void openUrl(dynamic url) {}

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
