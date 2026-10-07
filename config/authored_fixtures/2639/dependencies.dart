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

RecentWatchManager fixture = RecentWatchManager();

// DECLARATION-ONLY STAND-INS -- repo-local declarations that build no UI, and
// third-party ones the transplant does not inline. Supertypes are mirrored so a
// widget still reads as a widget; everything else is `dynamic`, because none of it
// is measured.

class CachedNetworkImage extends StatelessWidget {
  CachedNetworkImage({
    super.key,
    dynamic imageUrl,
    dynamic httpHeaders,
    dynamic imageBuilder,
    dynamic placeholder,
    dynamic progressIndicatorBuilder,
    dynamic errorWidget,
    dynamic fadeOutDuration,
    dynamic fadeOutCurve,
    dynamic fadeInDuration,
    dynamic fadeInCurve,
    dynamic width,
    dynamic height,
    dynamic fit,
    dynamic alignment,
    dynamic repeat,
    dynamic matchTextDirection,
    dynamic cacheManager,
    dynamic useOldImageOnUrlChange,
    dynamic color,
    dynamic filterQuality,
    dynamic colorBlendMode,
    dynamic placeholderFadeInDuration,
    dynamic memCacheWidth,
    dynamic memCacheHeight,
    dynamic cacheKey,
    dynamic maxWidthDiskCache,
    dynamic maxHeightDiskCache,
    dynamic imageRenderMethodForWeb,
  });
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
  static dynamic get logLevel => const _Stub();
  static set logLevel(dynamic _) {}
  dynamic get cacheManager => null;
  dynamic get imageUrl =>
      'https://gogocdn.net/cover/jujutsu-kaisen-2nd-season.png';
  dynamic get cacheKey => null;
  dynamic get imageBuilder => null;
  dynamic get placeholder => null;
  dynamic get progressIndicatorBuilder => null;
  dynamic get errorWidget => null;
  dynamic get placeholderFadeInDuration => null;
  dynamic get fadeOutDuration => null;
  dynamic get fadeOutCurve => const _Stub();
  dynamic get fadeInDuration => Duration.zero;
  dynamic get fadeInCurve => const _Stub();
  dynamic get width => null;
  dynamic get height => null;
  dynamic get fit => null;
  dynamic get alignment => const _Stub();
  dynamic get repeat => const _Stub();
  dynamic get matchTextDirection => false;
  dynamic get httpHeaders => null;
  dynamic get useOldImageOnUrlChange => false;
  dynamic get color => null;
  dynamic get colorBlendMode => null;
  dynamic get filterQuality => const _Stub();
  dynamic get memCacheWidth => null;
  dynamic get memCacheHeight => null;
  dynamic get maxWidthDiskCache => null;
  dynamic get maxHeightDiskCache => null;
  static dynamic evictFromCache(
    dynamic url, {
    dynamic cacheKey,
    dynamic cacheManager,
    dynamic scale,
  }) => Future<dynamic>.value(const _Stub());
}

class CustomCacheManager {
  CustomCacheManager();
  static const dynamic key = null;
  static dynamic get instance => const _Stub();
  static set instance(dynamic _) {}
}

dynamic Get = _GetImpl();

extension Inst on dynamic {
  void lazyPut<S>(dynamic builder, {dynamic tag, dynamic fenix}) {}
  dynamic putAsync<S>(dynamic builder, {dynamic tag, dynamic permanent}) =>
      const _Stub();
  void create<S>(dynamic builder, {dynamic tag, dynamic permanent}) {}
  dynamic find<S>({dynamic tag}) => const _Stub();
  dynamic put<S>(
    dynamic dependency, {
    dynamic tag,
    dynamic permanent,
    dynamic builder,
  }) => const _Stub();
  dynamic delete<S>({dynamic tag, dynamic force}) => Future<bool>.value(false);
  dynamic deleteAll({dynamic force}) => const _Stub();
  void reloadAll({dynamic force}) {}
  void reload<S>({dynamic tag, dynamic key, dynamic force}) {}
  dynamic isRegistered<S>({dynamic tag}) => false;
  dynamic isPrepared<S>({dynamic tag}) => false;
  void replace<P>(dynamic child, {dynamic tag}) {}
  void lazyReplace<P>(dynamic builder, {dynamic tag, dynamic fenix}) {}
}

class RecentAnime {
  RecentAnime({
    dynamic currentEp,
    dynamic id,
    dynamic epUrl,
    dynamic name,
    dynamic imageUrl,
  });
  RecentAnime.fromJson(dynamic json);
  dynamic get id => 'jujutsu-kaisen-2nd-season';
  dynamic get name => 'Jujutsu Kaisen 2nd Season';
  dynamic get epUrl =>
      'https://gogoanime.cl/jujutsu-kaisen-2nd-season-episode-12';
  dynamic get currentEp => 'Episode 12';
  dynamic get imageUrl =>
      'https://gogocdn.net/cover/jujutsu-kaisen-2nd-season.png';
  dynamic toJson() => <String, dynamic>{};
}

class RecentWatchManager {
  RecentWatchManager();
  dynamic get animeList => [];
  dynamic loadRecentAnimeFromDatabase() => const _Stub();
  void addAnimeToRecent(dynamic anime) {}
  void removeAnime(dynamic id) {}
  void removeAllAnime() {}
}

class _GetImpl {
  _GetImpl();
  dynamic find<S>({dynamic tag}) => const _Stub();
}

const Color tkGradientBlue = Color(0xFF133F6E);

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

class TakoTheme {
  TakoTheme();
  static dynamic get darkTextTheme => const _Stub();
  static set darkTextTheme(dynamic _) {}
  static dynamic dark() => const _Stub();
}
