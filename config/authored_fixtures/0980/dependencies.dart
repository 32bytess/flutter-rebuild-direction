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

// slang's generated root object. Every `Text` in this group reads through `t`, and each
// role's `initState` assigns it from `tValue`, so one instance serves the whole group.
// `Translations` is declared in the transplant, so the generated fill would not construct
// one (`class_standin_authored`); it is authored here instead.
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

class BookmarksModel {
  BookmarksModel({
    dynamic currentPage,
    dynamic limit,
    dynamic bookmarks,
    dynamic inialLoadStatus,
    dynamic loadingMore,
    dynamic maxNumber,
    dynamic readStatus,
    dynamic selectedBookmark,
  });
  dynamic get currentPage => 0;
  set currentPage(dynamic _) {}
  dynamic get limit => 0;
  set limit(dynamic _) {}
  dynamic get bookmarks => [];
  set bookmarks(dynamic _) {}
  dynamic get inialLoadStatus => const _Stub();
  set inialLoadStatus(dynamic _) {}
  dynamic get loadingMore => false;
  set loadingMore(dynamic _) {}
  dynamic get maxNumber => 0;
  set maxNumber(dynamic _) {}
  dynamic get readStatus => const _Stub();
  set readStatus(dynamic _) {}
  dynamic get selectedBookmark => null;
  set selectedBookmark(dynamic _) {}
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
  dynamic get entries => [];
  dynamic get selectedEntry => 0;
  dynamic get onChange => const _Stub();
  dynamic get colors => SegmentedButtonSlideColors();
  dynamic get animationDuration => Duration.zero;
  dynamic get curve => const _Stub();
  dynamic get slideShadow => null;
  dynamic get barShadow => null;
  dynamic get margin => null;
  dynamic get height => 0.0;
  dynamic get fontSize => null;
  dynamic get iconSize => null;
  dynamic get textOverflow => const _Stub();
}

class SegmentedButtonSlideColors {
  const SegmentedButtonSlideColors({
    dynamic barColor,
    dynamic backgroundSelectedColor,
    dynamic foregroundSelectedColor,
    dynamic foregroundUnselectedColor,
    dynamic hoverColor,
  });
  dynamic get barColor => const _Stub();
  dynamic get backgroundSelectedColor => const _Stub();
  dynamic get foregroundSelectedColor => const _Stub();
  dynamic get foregroundUnselectedColor => const _Stub();
  dynamic get hoverColor => const _Stub();
}

class SegmentedButtonSlideEntry {
  const SegmentedButtonSlideEntry({dynamic icon, dynamic label});
  dynamic get icon => null;
  dynamic get label => null;
}

class Translations {
  Translations.build({
    dynamic overrides,
    dynamic cardinalResolver,
    dynamic ordinalResolver,
  });
  dynamic get $meta => const _Stub();
  dynamic get onboarding => const _Stub();
  // The two namespaces this group reads. Held as `late final` fields rather than returned
  // from getters so a rebuild reaching `t.bookmarks` allocates nothing -- which is also
  // slang's own shape. The other namespaces are never reached here and stay stubs.
  late final dynamic bookmarks = _StringsBookmarksEn._(this);
  late final dynamic generic = _StringsGenericEn._(this);
  dynamic get tags => const _Stub();
  dynamic get settings => const _Stub();
  dynamic get webview => const _Stub();
  dynamic get colors => const _Stub();
  static dynamic of(dynamic context) => const _Stub();
}

class WidgetRef {
  WidgetRef();
  dynamic get context => const _Stub();
  dynamic watch<T>(dynamic provider) => const _Stub();
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

// The English copy of the bookmarks screen. Length is laid-out text, so an empty string
// would be a different line box under the same widget tree; these are the labels the
// measured sheet actually renders. Nested namespaces the group never reaches stay stubs.
class _StringsBookmarksEn {
  _StringsBookmarksEn._(dynamic p0);
  dynamic get bookmarks => 'Bookmarks';
  dynamic get noBookmarksAdded => 'No bookmarks added';
  dynamic get cannotLoadBookmarks => 'Cannot load the bookmarks';
  dynamic get dates => const _Stub();
  dynamic get shared => 'Shared';
  dynamic get archived => 'Archived';
  dynamic get showOnlyRead => 'Show only read';
  dynamic get showOnlyUnread => 'Show only unread';
  dynamic get showAllBookmarks => 'Show all bookmarks';
  dynamic get readStatus => 'Read status';
  dynamic get all => 'All';
  dynamic get unread => 'Unread';
  dynamic get read => 'Read';
  dynamic get filterSort => 'Filter and sort';
  dynamic get addBookmark => const _Stub();
  dynamic get search => const _Stub();
  dynamic get bookmarkOptions => const _Stub();
  dynamic get shareOptions => const _Stub();
  dynamic get sorting => 'Sorting';
  dynamic get date => 'Date';
  dynamic get title => 'Title';
  dynamic get ascendant => 'Ascendant';
  dynamic get descendant => 'Descendant';
}

class _StringsGenericEn {
  _StringsGenericEn._(dynamic p0);
  dynamic get confirm => 'Confirm';
  dynamic get cancel => 'Cancel';
  dynamic get next => 'Next';
  dynamic get save => 'Save';
  dynamic get close => 'Close';
  dynamic get error => 'Error';
  dynamic get optional => 'Optional';
  dynamic get authTokenNotValid => 'The authentication token is not valid';
  dynamic get options => 'Options';
}

dynamic bookmarksProvider = const _Stub();

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

class Bookmark {
  Bookmark({
    dynamic id,
    dynamic url,
    dynamic title,
    dynamic description,
    dynamic notes,
    dynamic websiteTitle,
    dynamic websiteDescription,
    dynamic isArchived,
    dynamic unread,
    dynamic shared,
    dynamic tagNames,
    dynamic dateAdded,
    dynamic dateModified,
  });
  Bookmark.fromJson(dynamic json);
  dynamic get id => null;
  dynamic get url => null;
  dynamic get title => null;
  dynamic get description => null;
  dynamic get notes => null;
  dynamic get websiteTitle => null;
  dynamic get websiteDescription => null;
  dynamic get isArchived => null;
  dynamic get unread => null;
  dynamic get shared => null;
  dynamic get tagNames => null;
  dynamic get dateAdded => null;
  dynamic get dateModified => null;
  dynamic toJson() => <String, dynamic>{};
  dynamic copyWith({
    dynamic id,
    dynamic url,
    dynamic title,
    dynamic description,
    dynamic notes,
    dynamic websiteTitle,
    dynamic websiteDescription,
    dynamic isArchived,
    dynamic unread,
    dynamic shared,
    dynamic tagNames,
    dynamic dateAdded,
    dynamic dateModified,
  }) => Bookmark();
}

class ConfigOptions {
  ConfigOptions();
  static const dynamic listLimit = null;
  static const dynamic slidableGroupTag = null;
}

class GoRouter {
  GoRouter({
    dynamic routes,
    dynamic extraCodec,
    dynamic onException,
    dynamic errorPageBuilder,
    dynamic errorBuilder,
    dynamic redirect,
    dynamic refreshListenable,
    dynamic redirectLimit,
    dynamic routerNeglect,
    dynamic initialLocation,
    dynamic overridePlatformDefaultLocation,
    dynamic initialExtra,
    dynamic observers,
    dynamic debugLogDiagnostics,
    dynamic navigatorKey,
    dynamic restorationScopeId,
    dynamic requestFocus,
  });
  GoRouter.routingConfig({
    dynamic routingConfig,
    dynamic extraCodec,
    dynamic onException,
    dynamic errorPageBuilder,
    dynamic errorBuilder,
    dynamic refreshListenable,
    dynamic routerNeglect,
    dynamic initialLocation,
    dynamic overridePlatformDefaultLocation,
    dynamic initialExtra,
    dynamic observers,
    dynamic debugLogDiagnostics,
    dynamic navigatorKey,
    dynamic restorationScopeId,
    dynamic requestFocus,
  });
  static dynamic get optionURLReflectsImperativeAPIs => false;
  static set optionURLReflectsImperativeAPIs(dynamic _) {}
  dynamic get configuration => const _Stub();
  dynamic get backButtonDispatcher => const _Stub();
  dynamic get routerDelegate => const _Stub();
  dynamic get routeInformationProvider => const _Stub();
  dynamic get routeInformationParser => const _Stub();
  dynamic get overridePlatformDefaultLocation => false;
  dynamic canPop() => false;
  dynamic namedLocation(
    dynamic name, {
    dynamic pathParameters,
    dynamic queryParameters,
    dynamic fragment,
  }) => '';
  void go(dynamic location, {dynamic extra}) {}
  void restore(dynamic matchList) {}
  void goNamed(
    dynamic name, {
    dynamic pathParameters,
    dynamic queryParameters,
    dynamic extra,
    dynamic fragment,
  }) {}
  dynamic push<T>(dynamic location, {dynamic extra}) => Future<T?>.value(null);
  dynamic pushNamed<T>(
    dynamic name, {
    dynamic pathParameters,
    dynamic queryParameters,
    dynamic extra,
  }) => Future<T?>.value(null);
  dynamic pushReplacement<T>(dynamic location, {dynamic extra}) =>
      Future<T?>.value(null);
  dynamic pushReplacementNamed<T>(
    dynamic name, {
    dynamic pathParameters,
    dynamic queryParameters,
    dynamic extra,
  }) => Future<T?>.value(null);
  dynamic replace<T>(dynamic location, {dynamic extra}) =>
      Future<T?>.value(null);
  dynamic replaceNamed<T>(
    dynamic name, {
    dynamic pathParameters,
    dynamic queryParameters,
    dynamic extra,
  }) => Future<T?>.value(null);
  void pop<T>([dynamic result]) {}
  void refresh() {}
  static dynamic of(dynamic context) => GoRouter();
  static dynamic maybeOf(dynamic context) => null;
  void dispose() {}
  dynamic get state => const _Stub();
}
