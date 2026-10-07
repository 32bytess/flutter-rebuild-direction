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

String fixtureResponse =
    "Yes, I run entirely on your device. Nothing you type leaves the phone, "
    "there is no account to sign in to, and the model answers from what it "
    "already knows rather than from a search. Ask me anything and I will read "
    "the reply out loud while it streams in.";

bool fixtureIsDark = false;

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

ScrollController fixtureScrollController = ScrollController();

int fixtureLastTrackedWord = -1;

String? fixtureTrackedResponse = null;

// DECLARATION-ONLY STAND-INS -- repo-local declarations that build no UI, and
// third-party ones the transplant does not inline. Supertypes are mirrored so a
// widget still reads as a widget; everything else is `dynamic`, because none of it
// is measured.

class ConsumerState<WidgetT> {
  ConsumerState();
  dynamic get ref => WidgetRef();
}

class TtsState {
  const TtsState({
    dynamic isSpeaking,
    dynamic isPaused,
    dynamic isInitializing,
    dynamic error,
    dynamic activeEngine,
    dynamic playingContent,
    dynamic playingMessageId,
    dynamic playingConversationId,
    dynamic isPreview,
    dynamic position,
    dynamic duration,
    dynamic canSeek,
    dynamic isSeekPending,
    dynamic playbackSpeed,
    dynamic chunks,
    dynamic currentChunkIndex,
    dynamic spokenCharOffset,
  });
  dynamic get isSpeaking => false;
  dynamic get isPaused => false;
  dynamic get isInitializing => false;
  dynamic get error => null;
  dynamic get activeEngine => null;
  dynamic get playingContent => null;
  dynamic get playingMessageId => null;
  dynamic get playingConversationId => null;
  dynamic get isPreview => false;
  dynamic get position => Duration.zero;
  dynamic get duration => Duration.zero;
  dynamic get canSeek => false;
  dynamic get isSeekPending => false;
  dynamic get playbackSpeed => 0.0;
  dynamic get chunks => <String>[];
  dynamic get currentChunkIndex => 0;
  dynamic get spokenCharOffset => 0;
  dynamic copyWith({
    dynamic isSpeaking,
    dynamic isPaused,
    dynamic isInitializing,
    dynamic error,
    dynamic activeEngine,
    dynamic playingContent,
    dynamic playingMessageId,
    dynamic playingConversationId,
    dynamic isPreview,
    dynamic position,
    dynamic duration,
    dynamic canSeek,
    dynamic isSeekPending,
    dynamic playbackSpeed,
    dynamic clearPlayingTarget,
    dynamic resetProgress,
    dynamic chunks,
    dynamic currentChunkIndex,
    dynamic spokenCharOffset,
  }) => TtsState();
}

class VoiceModePalette {
  const VoiceModePalette._();
  static dynamic accentFor(dynamic phase, {dynamic isDark}) =>
      const Color(0xFF4F8CFF);
  static dynamic secondaryFor(dynamic phase, {dynamic isDark}) =>
      const Color(0xFF8E7BFF);
  static dynamic sphereGradientFor(dynamic phase, {dynamic isDark}) => [];
  static dynamic subtleBg(dynamic context, {dynamic opacity}) =>
      const Color(0x1F4F8CFF);
}

class WidgetRef {
  WidgetRef();
  dynamic get context => const _Stub();
  dynamic watch<StateT>(dynamic provider) => provider;
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

dynamic ttsProvider = const TtsState();

// UNRESOLVED-REFERENCE STAND-INS -- reconstructed from the call sites, because the
// symbol lives in a package this file may not import or the source project's own
// dependencies were never installed. Every type here is `dynamic`.

dynamic _lastTrackedWord = const _Stub();

dynamic _trackedResponse = const _Stub();

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

dynamic _bottomFade = const _Stub();

dynamic _topFade = const _Stub();
