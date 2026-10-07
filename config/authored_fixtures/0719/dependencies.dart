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

WidgetRef fixtureRef = WidgetRef();

// DECLARATION-ONLY STAND-INS -- repo-local declarations that build no UI, and
// third-party ones the transplant does not inline. Supertypes are mirrored so a
// widget still reads as a widget; everything else is `dynamic`, because none of it
// is measured.

class AppColors {
  AppColors();
  static const dynamic darkBackground = Color(0xFF1E1E1E);
  static const dynamic darkSurface = Color(0xFF252525);
  static const dynamic darkSurfaceInput = Color(0xFF2D2D2D);
  static const dynamic darkSurfaceCard = Color(0xFF323232);
  static const dynamic darkBorder = Color(0xFF3A3A3A);
  static const dynamic darkPrimaryText = Color(0xFFEDEDED);
  static const dynamic darkMutedText = Color(0xFF9E9E9E);
  static const dynamic darkAccent = Color(0xFF4F8DF5);
  static const dynamic lightBackground = Color(0xFFFFFFFF);
  static const dynamic lightSurface = Color(0xFFF7F7F8);
  static const dynamic lightBorder = Color(0xFFE0E0E0);
  static const dynamic lightPrimaryText = Color(0xFF1A1A1A);
  static const dynamic lightMutedText = Color(0xFF6B6B6B);
  static const dynamic lightAccent = Color(0xFF2563EB);
  static const dynamic claudeBackground = Color(0xFFF5F4EF);
  static const dynamic claudeSurface = Color(0xFFFFFFFF);
  static const dynamic claudeBorder = Color(0xFFE3DFD3);
  static const dynamic claudePrimaryText = Color(0xFF2C2B28);
  static const dynamic claudeSecondaryText = Color(0xFF54524C);
  static const dynamic claudeMutedText = Color(0xFF8A877E);
  static const dynamic claudeAccent = Color(0xFFD97757);
  static const dynamic claudeDarkBackground = Color(0xFF262624);
  static const dynamic claudeDarkSurface = Color(0xFF30302E);
  static const dynamic claudeDarkBorder = Color(0xFF3E3E3B);
  static const dynamic claudeDarkPrimaryText = Color(0xFFF5F4EF);
  static const dynamic claudeDarkSecondaryText = Color(0xFFC2BFB6);
  static const dynamic success = Color(0xFF2E7D32);
  static const dynamic error = Color(0xFFC62828);
  static const dynamic warning = Color(0xFFF9A825);
}

class ConsumerWidget extends StatelessWidget {
  const ConsumerWidget({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class WidgetRef {
  WidgetRef();
  dynamic get context => const _Stub();
  // HAND-AUTHORED 2026-09-15 (provider passthrough). Was `=> const _Stub()`, which threw
  // away the stand-in the generator had already reconstructed for the provider and handed the
  // transplant a `_Stub` instead -- so any `ref.watch(x).y` reaching a statically typed slot
  // threw inside `build` and the device drew Flutter's error box. Handing back the provider
  // itself keeps the chain typed; a provider still standing in as `_Stub` is unchanged, so
  // this is inert until one is given a value.
  dynamic watch<StateT>(dynamic provider) =>
      provider is _Stub ? const _Stub() : provider;
  dynamic exists(dynamic provider) => false;
  void listen<StateT>(
    dynamic provider,
    dynamic listener, {
    dynamic onError,
    dynamic weak,
  }) {}
  dynamic listenManual<StateT>(
    dynamic provider,
    dynamic listener, {
    dynamic onError,
    dynamic fireImmediately,
    dynamic weak,
  }) => const _Stub();
  dynamic read<StateT>(dynamic provider) =>
      provider is _Stub ? const _Stub() : provider;
  dynamic refresh<StateT>(dynamic provider) =>
      provider is _Stub ? const _Stub() : provider;
  void invalidate(dynamic provider, {dynamic asReload}) {}
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

class HugeIcon extends StatelessWidget {
  const HugeIcon({
    super.key,
    dynamic icon,
    dynamic color,
    dynamic secondaryColor,
    dynamic size,
    dynamic strokeWidth,
  });
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
  dynamic get icon => [];
  dynamic get color => const Color(0xFF6B6B6B);
  dynamic get secondaryColor => const Color(0xFF9E9E9E);
  dynamic get size => 24.0;
  dynamic get strokeWidth => 1.5;
}

class HugeIcons {
  HugeIcons._();
  static dynamic get strokeRoundedChatting01 => [];
  static dynamic get strokeRoundedArrowLeft01 => [];
  static dynamic get strokeRoundedArrowRight01 => [];
}
