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

// Cardinality 3, the corpus-wide protocol constant, so `itemCount` is the same
// tree size for both roles. `color` is left off every entry on purpose: it is the
// `league.color != null` condition, and the two roles spend it differently
// (`HexColor(...)` against `'...'.toColor`), so filling it would price one arm
// against the other. The logos end in `.png` for the same reason -- a `.svg` URL
// sends only rev_007's `CustomImage` down the `SvgPicture` branch.
List<League> fixtureLeagues = const <League>[
  League(
    id: 39,
    name: 'Premier League',
    logo: 'https://media.api-sports.io/football/leagues/39.png',
    country: Country(id: 39, name: 'England'),
  ),
  League(
    id: 140,
    name: 'La Liga',
    logo: 'https://media.api-sports.io/football/leagues/140.png',
    country: Country(id: 140, name: 'Spain'),
  ),
  League(
    id: 135,
    name: 'Serie A',
    logo: 'https://media.api-sports.io/football/leagues/135.png',
    country: Country(id: 135, name: 'Italy'),
  ),
];

// Held as a field and never read by `build` in either role.
bool fixtureGetFixtures = true;

// Also field-only: `build` reads `selectedLeagueId`, never this one.
int? fixtureInitialSelectedLeagueId = 39;

// Null by decision, not by omission. `prefixIcon` gates `if (prefixIcon != null)`,
// so a stand-in here is a subtree, and subtree size is the dependent variable.
Widget? fixturePrefixIcon = null;

// Null by the same decision: the icon it belongs to does not mount, and both roles
// build their own erased `onTap` closure rather than reading this one.
VoidCallback? fixtureOnPrefixIconTap = null;

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

// Left null deliberately. This one decides `isSelected`, and the selected card is
// exactly where the two roles differ in tree size (rev_006 mounts a `Padding` and a
// check `Icon` that rev_007 dropped). Naming an id here chooses that subtree; it is
// a branch decision, not a value, so it stays on the arm the mine recorded.
int? fixtureSelectedLeagueId = null;

// DECLARATION-ONLY STAND-INS -- repo-local declarations that build no UI, and
// third-party ones the transplant does not inline. Supertypes are mirrored so a
// widget still reads as a widget; everything else is `dynamic`, because none of it
// is measured.

class AppColors {
  AppColors._();
  static const dynamic white = null;
  static const dynamic black = null;
  static const dynamic red = null;
  static const dynamic lightRed = null;
  static const dynamic blueGrey = null;
  static const dynamic green = null;
  static const dynamic darkGreen = null;
  static const dynamic yellow = null;
  static const dynamic blue = null;
  static const dynamic darkBlue = null;
  static const dynamic deepOrange = null;
  static const dynamic grey = null;
  static const dynamic darkGrey = null;
  static const dynamic purple = null;
  static const dynamic lightGrey = null;
  static const dynamic blueGradient = null;
  static const dynamic redGradient = null;
}

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
    dynamic errorListener,
    dynamic imageRenderMethodForWeb,
    dynamic scale,
  });
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
  static dynamic get logLevel => const _Stub();
  static set logLevel(dynamic _) {}
  dynamic get cacheManager => null;
  dynamic get imageUrl => '';
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
  dynamic get errorListener => null;
  static dynamic evictFromCache(
    dynamic url, {
    dynamic cacheKey,
    dynamic cacheManager,
    dynamic scale,
  }) => Future<bool>.value(false);
}

extension ColorExtension on Color {
  dynamic withOpacitySafe(dynamic opacity) => const _Stub();
}

class Country {
  const Country({this.id = 0, this.name = ''});
  final dynamic id;
  final dynamic name;
  dynamic get props => <Object?>[];
}

class HexColor {
  HexColor(dynamic hex);
  static dynamic tryParse(dynamic hex) => null;
}

// The constructor keeps what it is handed, so the three fixture entries read as
// three different leagues. Ids and names are distinct, which holds
// `leagues.any((l) => l.name == ... && l.id != ...)` false for every index, the
// same verdict the all-defaults stand-in gave.
class League {
  const League({
    this.id = 0,
    this.name = '',
    this.logo = '',
    this.country,
    this.color,
  });
  League.light({dynamic id, dynamic name})
    : id = id ?? 0,
      name = name ?? '',
      logo = '',
      country = null,
      color = null;
  final dynamic id;
  final dynamic name;
  final dynamic logo;
  final dynamic country;
  final dynamic color;
  dynamic get props => <Object?>[];
}

extension ResponsiveInt on int {
  dynamic get width => 0.0;
  dynamic get height => 0.0;
  dynamic get radius => 0.0;
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

class AppColorsExtension {
  // HAND-AUTHORED 2026-09-15. Every getter below was `const _Stub()`, and the role passes
  // them straight into `color:`, `Border.all(color:)` and `gradient:` -- so
  // `type '_Stub' is not a subtype of type 'Color?'` threw inside `build` and the device drew
  // Flutter's error box. `const Color(0xFF000000)` is the stand-in the fixture policy carried
  // for `Color` before its 2026-09-05 primitives-only trim, and it is the same SHAPE as the
  // `_Stub` it replaces: one const constructor call, so no allocation moves. The two
  // `*Gradient` slots take `null`, which is what `gradient:` accepts and allocates nothing.

  const AppColorsExtension({
    dynamic green,
    dynamic red,
    dynamic purple,
    dynamic yellow,
    dynamic darkGrey,
    dynamic lightGrey,
    dynamic grey,
    dynamic deepOrange,
    dynamic blueGrey,
    dynamic blue,
    dynamic white,
    dynamic lightRed,
    dynamic darkBlue,
    dynamic darkGreen,
    dynamic blueGradient,
    dynamic redGradient,
  });
  dynamic get green => const Color(0xFF000000);
  dynamic get red => const Color(0xFF000000);
  dynamic get purple => const Color(0xFF000000);
  dynamic get yellow => const Color(0xFF000000);
  dynamic get darkGrey => const Color(0xFF000000);
  dynamic get lightGrey => const Color(0xFF000000);
  dynamic get grey => const Color(0xFF000000);
  dynamic get deepOrange => const Color(0xFF000000);
  dynamic get blueGrey => const Color(0xFF000000);
  dynamic get blue => const Color(0xFF000000);
  dynamic get white => const Color(0xFF000000);
  dynamic get lightRed => const Color(0xFF000000);
  dynamic get darkBlue => const Color(0xFF000000);
  dynamic get darkGreen => const Color(0xFF000000);
  dynamic get blueGradient => null;
  dynamic get redGradient => null;
  dynamic copyWith({
    dynamic green,
    dynamic red,
    dynamic purple,
    dynamic yellow,
    dynamic darkGrey,
    dynamic lightGrey,
    dynamic grey,
    dynamic deepOrange,
    dynamic blueGrey,
    dynamic blue,
    dynamic white,
    dynamic lightRed,
    dynamic darkBlue,
    dynamic darkGreen,
    dynamic blueGradient,
    dynamic redGradient,
  }) => const _Stub();
  dynamic lerp(dynamic other, dynamic t) => const _Stub();
}

class AppSpacing {
  const AppSpacing._();
  static const dynamic xs = null;
  static const dynamic s = null;
  static const dynamic m = null;
  static const dynamic l = null;
  static const dynamic xl = null;
  static const dynamic xxl = null;
  static const dynamic xxxl = null;
  static const dynamic jumbo = null;
}

extension ContextExtension on BuildContext {
  dynamic get screenWidth => 0.0;
  dynamic get screenHeight => 0.0;
  dynamic get colors => const _Stub();
  dynamic get colorsExt => AppColorsExtension();
  dynamic get textTheme => const _Stub();
  dynamic get l10n => const _Stub();
  dynamic get localeName => '';
}

extension HexColorExt on String {
  dynamic get toColor => const _Stub();
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
    dynamic renderingStrategy,
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
    dynamic colorMapper,
    dynamic colorFilter,
    dynamic color,
    dynamic colorBlendMode,
    dynamic cacheColorFilter,
    dynamic renderingStrategy,
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
    dynamic colorMapper,
    dynamic httpClient,
    dynamic renderingStrategy,
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
    dynamic colorMapper,
    dynamic cacheColorFilter,
    dynamic renderingStrategy,
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
    dynamic colorMapper,
    dynamic cacheColorFilter,
    dynamic renderingStrategy,
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
    dynamic colorMapper,
    dynamic cacheColorFilter,
    dynamic renderingStrategy,
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
  dynamic get errorBuilder => null;
  dynamic get colorFilter => null;
  dynamic get renderingStrategy => const _Stub();
}
