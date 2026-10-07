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

// HAND-AUTHORED 2026-09-15 (typed initialiser). Was `= Hive.box('password')`, and
// `HiveInterface.box<E>()` at :181 is a stand-in returning `const _Stub()` -- so this binding
// declared `Box<dynamic>` statically, held a `_Stub` at runtime, and threw the moment the role
// reached it. Dart accepts the assignment because `box` returns `dynamic`, which is why
// nothing before the device caught it.
//
// NO VALUE IS INVENTED HERE, AND THE BOX STAYS EMPTY ON PURPOSE. `class Box<E>` is the
// generator's own reconstruction at :117 and already answers every read the roles make:
// `values => []`, `get(...) => null`, `toMap() => {}`, `isEmpty => false`. Constructing it
// names what the file already declares. Its emptiness is NOT an oversight to be tidied: how
// many elements go in a collection is tree size, the dependent variable, and
// `config/fixture_policy.json`'s `cardinality: 3` applies to a collection the protocol fills,
// not to a stand-in's own accessor. Filling this box by hand would be choosing a row count for
// a list the role renders.
Box<dynamic> fixturePasswordbox = Box<dynamic>();

bool fixtureHidePassword = true;

bool fixtureHideConfirmPassword = true;

TextEditingController fixturePassword = TextEditingController(
  text: 'Str0ng#Pass2024',
);

TextEditingController fixtureConfirmPassword = TextEditingController(
  text: 'Str0ng#Pass2024',
);

TextEditingController fixtureResetPassword = TextEditingController(
  text: 'Str0ng#Pass2024',
);

// DECLARATION-ONLY STAND-INS -- repo-local declarations that build no UI, and
// third-party ones the transplant does not inline. Supertypes are mirrored so a
// widget still reads as a widget; everything else is `dynamic`, because none of it
// is measured.

class Bounceable extends StatelessWidget {
  final dynamic child;
  const Bounceable({
    super.key,
    dynamic onTap,
    this.child,
    dynamic onTapUp,
    dynamic onTapDown,
    dynamic onTapCancel,
    dynamic onLongPress,
    dynamic duration,
    dynamic reverseDuration,
    dynamic curve,
    dynamic reverseCurve,
    dynamic scaleFactor,
    dynamic hitTestBehavior,
  });
  @override
  Widget build(BuildContext context) =>
      child is Widget ? child as Widget : const SizedBox.shrink();
  dynamic get onTap => null;
  dynamic get onTapUp => null;
  dynamic get onTapDown => null;
  dynamic get onTapCancel => null;
  dynamic get duration => const Duration(milliseconds: 200);
  dynamic get reverseDuration => const Duration(milliseconds: 150);
  dynamic get curve => const _Stub();
  dynamic get reverseCurve => null;
  dynamic get scaleFactor => 0.9;
  dynamic get hitTestBehavior => null;
  dynamic get onLongPress => null;
}

class Box<E> {
  Box();
  dynamic get values => [];
  dynamic valuesBetween({dynamic startKey, dynamic endKey}) => [];
  dynamic get(dynamic key, {dynamic defaultValue}) => null;
  dynamic getAt(dynamic index) => null;
  dynamic toMap() => {};
  dynamic get isEmpty => false;
}

class BoxBase<E> {
  BoxBase();
  dynamic get name => 'password';
  dynamic get isOpen => false;
  dynamic get path => '/data/user/0/com.example.app/app_flutter/password.hive';
  dynamic get lazy => false;
  dynamic get keys => <dynamic>[];
  dynamic get length => 0;
  dynamic get isEmpty => false;
  dynamic get isNotEmpty => false;
  dynamic keyAt(dynamic index) => const _Stub();
  dynamic watch({dynamic key}) => const _Stub();
  dynamic containsKey(dynamic key) => false;
  dynamic put(dynamic key, dynamic value) => const _Stub();
  dynamic putAt(dynamic index, dynamic value) => const _Stub();
  dynamic putAll(dynamic entries) => const _Stub();
  dynamic add(dynamic value) => Future<int>.value(0);
  dynamic addAll(dynamic values) => Future<Iterable<int>>.value(<int>[]);
  dynamic delete(dynamic key) => const _Stub();
  dynamic deleteAt(dynamic index) => const _Stub();
  dynamic deleteAll(dynamic keys) => const _Stub();
  dynamic compact() => const _Stub();
  dynamic clear() => Future<int>.value(0);
  dynamic close() => const _Stub();
  dynamic deleteFromDisk() => const _Stub();
  dynamic flush() => const _Stub();
}

dynamic Hive = HiveInterface();

class HiveInterface {
  HiveInterface();
  void init(dynamic path, {dynamic backendPreference}) {}
  dynamic openBox<E>(
    dynamic name, {
    dynamic encryptionCipher,
    dynamic keyComparator,
    dynamic compactionStrategy,
    dynamic crashRecovery,
    dynamic path,
    dynamic bytes,
    dynamic collection,
    dynamic encryptionKey,
  }) => const _Stub();
  dynamic openLazyBox<E>(
    dynamic name, {
    dynamic encryptionCipher,
    dynamic keyComparator,
    dynamic compactionStrategy,
    dynamic crashRecovery,
    dynamic path,
    dynamic collection,
    dynamic encryptionKey,
  }) => const _Stub();
  dynamic box<E>(dynamic name) => const _Stub();
  dynamic lazyBox<E>(dynamic name) => const _Stub();
  dynamic isBoxOpen(dynamic name) => false;
  dynamic close() => const _Stub();
  dynamic deleteBoxFromDisk(dynamic name, {dynamic path}) => const _Stub();
  dynamic deleteFromDisk() => const _Stub();
  dynamic generateSecureKey() => <int>[];
  dynamic boxExists(dynamic name, {dynamic path}) => Future<bool>.value(false);
  void resetAdapters() {}
}

enum PasswordStrength { alreadyExposed, weak, medium, strong, secure }

class PasswordStrengthChecker<T> extends StatelessWidget {
  const PasswordStrengthChecker({
    super.key,
    dynamic strength,
    dynamic configuration,
  });
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
  dynamic get strength => const _Stub();
  dynamic get configuration => PasswordStrengthCheckerConfiguration();
}

class PasswordStrengthCheckerConfiguration {
  const PasswordStrengthCheckerConfiguration({
    dynamic width,
    dynamic height,
    dynamic leftToRight,
    dynamic showStatusWidget,
    dynamic statusWidgetAlignment,
    dynamic statusMargin,
    dynamic animationDuration,
    dynamic animationCurve,
    dynamic hasBorder,
    dynamic borderWidth,
    dynamic borderColor,
    dynamic inactiveBorderColor,
    dynamic externalBorderRadius,
    dynamic internalBorderRadius,
  });
  dynamic get width => 300.0;
  dynamic get height => 12.0;
  dynamic get leftToRight => false;
  dynamic get showStatusWidget => false;
  dynamic get statusWidgetAlignment => const _Stub();
  dynamic get statusMargin => const _Stub();
  dynamic get animationDuration => const Duration(milliseconds: 300);
  dynamic get animationCurve => const _Stub();
  dynamic get hasBorder => false;
  dynamic get borderWidth => 1.0;
  dynamic get borderColor => null;
  dynamic get inactiveBorderColor => const _Stub();
  dynamic get externalBorderRadius => null;
  dynamic get internalBorderRadius => null;
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
