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

// `TabController` is the type `config/fixture_policy.json` DECLARES unrecoverable
// (`ticker_provider`): a real one needs a `TickerProvider vsync`, `Ticker` and
// `TickerCallback` are not exported by `package:flutter/material.dart` -- only
// `TickerProvider` is -- a part file cannot add the import, and every
// `TickerProvider` Flutter ships is a private `State`. So no real one can exist
// above the element tree, and the policy is not wrong; it is authored around here.
//
// `_FixtureTabController` below is a VALUE, not a controller: fixed index, a
// stopped animation, and `animateTo` a no-op. It is inert in exactly the way the
// header asks for -- nothing ticking, no clock, no I/O -- and it holds the only
// thing the revs read off it. `length: 3` is READ OFF THE REVS (three `Tab`s and
// three `TabBarView` children in all three roles); it is not a chosen cardinality.
late TabController fixtureTabController = _FixtureTabController(length: 3);

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

GlobalKey<ScaffoldState> fixtureScaffoldKey = GlobalKey<ScaffoldState>();

String fixtureSelectedActivity = 'main.dart';

// DECLARATION-ONLY STAND-INS -- repo-local declarations that build no UI, and
// third-party ones the transplant does not inline. Supertypes are mirrored so a
// widget still reads as a widget; everything else is `dynamic`, because none of it
// is measured.

class WidgetFactory {
  WidgetFactory();
  static List<Draggable<String>> getDraggableWidgets() => [];
}

// The stand-in for the seed above. It mirrors its supertype -- `spm analyze` walks
// the chain, and a `ChangeNotifier` still reads as a value object -- and adds no
// behaviour beyond storage: `TabBar` and `TabBarView` read `length`, `index`,
// `previousIndex`, `indexIsChanging`, `offset`, `animationDuration` and
// `animation`, and every one of those is a constant here. It is constructed once,
// lazily, at top level, so the allocation is outside every measured build body.
class _FixtureTabController extends ChangeNotifier implements TabController {
  _FixtureTabController({required this.length});

  @override
  final int length;

  @override
  int index = 0;

  @override
  int get previousIndex => index;

  @override
  bool get indexIsChanging => false;

  @override
  double offset = 0.0;

  @override
  Duration get animationDuration => Duration.zero;

  @override
  Animation<double> get animation =>
      AlwaysStoppedAnimation<double>(index.toDouble());

  @override
  void animateTo(int value, {Duration? duration, Curve curve = Curves.ease}) {}
}

// UNRESOLVED-REFERENCE STAND-INS -- reconstructed from the call sites, because the
// symbol lives in a package this file may not import or the source project's own
// dependencies were never installed. Every type here is `dynamic`.

extension _SpmPaintShim on Paint {
  dynamic get color => const _Stub();
  dynamic get strokeWidth => const _Stub();
  dynamic get style => const _Stub();
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
