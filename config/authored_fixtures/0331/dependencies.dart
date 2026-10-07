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
// long as it is untouched. The first HAND edit makes it yours: the screen records its hash,
// sees the difference, and never overwrites it again.
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

// HAND-FILLED. These three are the canonical `BuildContext` shorthands the source app
// declared; a stub cannot serve them because `titleLarge` reaches `Text.style` and
// `primary` reaches `Icon.color`, and a `dynamic` stub fails that implicit downcast at
// runtime. They resolve from the ambient `MaterialApp` theme, exactly as in the app.
extension BuildContextExtensions on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  Size get deviceSize => MediaQuery.sizeOf(this);
}

class ConsumerWidget extends StatelessWidget {
  const ConsumerWidget({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class Gap extends StatelessWidget {
  const Gap(
    dynamic mainAxisExtent, {
    super.key,
    dynamic crossAxisExtent,
    dynamic color,
  });
  const Gap.expand(dynamic mainAxisExtent, {super.key, dynamic color});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
  // HAND-FILLED. Inert accessors on a declaration-only stand-in: no build body in
  // this group reads them, so they decide no branch and change no tree size. They
  // carry the extents the revs actually pass (`Gap(10)` around the label, `Gap(8)`
  // between chips) rather than an empty 0.0/null, so the fixture reads like the app.
  dynamic get mainAxisExtent => 10.0;
  dynamic get crossAxisExtent => 8.0;
  dynamic get color => Colors.transparent;
}

class WidgetRef {
  WidgetRef();
  dynamic get context => const _Stub();
  // A provider below that carries a fixture value hands that value back; anything
  // else still falls through to the stub.
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
  dynamic read<T>(dynamic provider) => const _Stub();
  dynamic refresh<State>(dynamic provider) => const _Stub();
  void invalidate(dynamic provider) {}
}

// HAND-FILLED. The selected-category provider: rev_001 reads it under the name
// `selectedCategoryProvider`, the later revs under `categoryProvider`, so both carry
// the SAME value and every role in the group mounts with one chip selected -- the
// state a category strip is in whenever the user has picked anything. `personal` is
// the one member every rev's `TaskCategory` declares, so the selection lands on a real
// enum member in all four rather than matching nothing.
dynamic selectedCategoryProvider = TaskCategory.personal;

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

// HAND-FILLED. Same value as `selectedCategoryProvider` above -- see the note there.
dynamic categoryProvider = TaskCategory.personal;
