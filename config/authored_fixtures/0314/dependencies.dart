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

// HAND-FILLED. Inert glyph constants on a declaration-only stand-in: no build body in
// this group reads them (every rev names `Icons.circle` directly), so they decide no
// branch and change no tree size. They carry the Material glyph each carbon_icons name
// stands for in the source app -- a done/not-done mark and a pinned/unpinned pin --
// rather than an empty stub, so the fixture reads like the app it came from.
class CarbonIcons {
  CarbonIcons._();
  static dynamic get checkmark_outline => Icons.check_circle_outline;
  static dynamic get radio_button => Icons.radio_button_unchecked;
  static dynamic get pin_filled => Icons.push_pin;
  static dynamic get pin => Icons.push_pin_outlined;
}

class HookConsumerWidget extends StatelessWidget {
  const HookConsumerWidget({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
  // Return type mirrored from StatelessWidget: the generator's `dynamic` is not a
  // valid override, and the analysis error would make `spm analyze` skip the file.
  @override
  StatelessElement createElement() => StatelessElement(this);
}

class TodoModel {
  TodoModel({
    dynamic id,
    dynamic description,
    dynamic isCompleted,
    dynamic isPinned,
  }) : id = id ?? 'todo-4f2a91c0',
       description = description ?? 'Buy oat milk and coffee beans',
       isCompleted = isCompleted ?? false,
       isPinned = isPinned ?? true;
  TodoModel.fromJson(dynamic json)
    : id = 'todo-4f2a91c0',
      description = 'Buy oat milk and coffee beans',
      isCompleted = false,
      isPinned = true;
  dynamic id;
  String description;
  bool isCompleted;
  bool isPinned;
  dynamic toJson() => <String, dynamic>{
    'id': id,
    'description': description,
    'isCompleted': isCompleted,
    'isPinned': isPinned,
  };
}

class WidgetRef {
  WidgetRef();
  dynamic get context => const _Stub();
  dynamic watch<T>(dynamic provider) => provider;
  dynamic exists(dynamic provider) => false;
  void listen<T>(dynamic provider, dynamic listener, {dynamic onError}) {}
  dynamic listenManual<T>(
    dynamic provider,
    dynamic listener, {
    dynamic onError,
    dynamic fireImmediately,
  }) => const _Stub();
  dynamic read<T>(dynamic provider) => provider;
  dynamic refresh<State>(dynamic provider) => const _Stub();
  void invalidate(dynamic provider) {}
}

dynamic currentTodo = TodoModel(
  id: 'todo-4f2a91c0',
  description: 'Buy oat milk and coffee beans',
  isCompleted: false,
  isPinned: true,
);

// The hook stand-ins keep flutter_hooks' defining property: a call site gets the
// SAME object back on every rebuild, bound by call order within the build body.
// Fresh objects per rebuild would make the node identities -- and so the focus
// state that selects the title subtree -- differ between the endpoints of a pair.
final List<FocusNode> _fixtureFocusNodes = <FocusNode>[
  FocusNode(debugLabel: 'fixtureItemFocusNode'),
  FocusNode(debugLabel: 'fixtureTextFieldFocusNode'),
];
int _fixtureFocusNodeCursor = 0;

dynamic useFocusNode({
  dynamic debugLabel,
  dynamic onKey,
  dynamic onKeyEvent,
  dynamic skipTraversal,
  dynamic canRequestFocus,
  dynamic descendantsAreFocusable,
}) {
  final FocusNode node = _fixtureFocusNodes[_fixtureFocusNodeCursor];
  _fixtureFocusNodeCursor =
      (_fixtureFocusNodeCursor + 1) % _fixtureFocusNodes.length;
  return node;
}

dynamic useListenable<T>(dynamic listenable) => listenable;

final TextEditingController _fixtureTextEditingController =
    TextEditingController(text: 'Buy oat milk and coffee beans');

dynamic useTextEditingController({dynamic text}) =>
    _fixtureTextEditingController;

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
