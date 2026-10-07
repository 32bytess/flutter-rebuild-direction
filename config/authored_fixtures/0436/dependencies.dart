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

String fixtureLogTag = '[PROFILES PAGE] - ';

int fixtureGroupValue = 0;

TextEditingController fixtureProfileNameController = TextEditingController();

GlobalKey<FormState> fixtureProfileNameFormKey = GlobalKey<FormState>();

Color fixtureMainColor = ThemeService().isDarkTheme()
    ? AppColors.dark
    : AppColors.light;

// Cardinality 3, the corpus-wide constant from config/fixture_policy.json.
//
// EVERY ENTRY IS `isDefault: false`, AND THAT IS THE MAXIMAL BRANCH, NOT A PREFERENCE.
// `isDefault` decides two subtrees in every role: `secondary:` renders an `IconButton`
// when it is false and `null` when it is true, and the title renders `profiles[index].label`
// rather than `'default'.tr`. Upstream seeds index 0 with `const Profile(label: 'Default',
// isDefault: true)` (profiles_page.dart:56), which would drop one `IconButton` out of the
// list and change tree size -- the dependent variable. So the labels below are three
// user-created profiles, which is what the application's own list holds after the seeded
// one, and no entry takes the default arm.
List<Profile> fixtureProfiles = <Profile>[
  const Profile(label: 'Travel', isDefault: false),
  const Profile(label: 'Work', isDefault: false),
  const Profile(label: 'Family', isDefault: false),
];

// Upstream reads this out of GetX's registry (`Get.find()`), relocated verbatim. The
// registry does not exist here: `Get` is `dynamic`, so the call dispatched to `_GetImpl.find`
// and returned a `_Stub`, and the implicit downcast to `DailyEntryController` threw a
// TypeError inside the generated `initState` -- before any role could build. The stand-in
// class is declared in this file, so it is constructible, which is the rule the policy
// already applies to transplant-declared types. No role reads a member off it.
DailyEntryController fixtureDailyEntryController = DailyEntryController();

// DECLARATION-ONLY STAND-INS -- repo-local declarations that build no UI, and
// third-party ones the transplant does not inline. Supertypes are mirrored so a
// widget still reads as a widget; everything else is `dynamic`, because none of it
// is measured.

// The palette the application really declares, taken verbatim from
// `lib/utils/constants.dart` at this group's anchor commit (a227e88a). Every role reads
// `AppColors.green` (the radio's `activeColor`, the button's `foregroundColor`) and
// `AppColors.mainColor` (the delete icon), and `fixtureMainColor` below picks `dark`/`light`
// off this class -- all of which resolved to `null` and rendered as Flutter's defaults,
// i.e. the wrong colours everywhere the app has an opinion. Values only: the members keep
// their `dynamic` type and the class keeps its shape.
//
// `orange` is the exception: it is not at the anchor commit, it arrives later in the same
// file, and no role here references it. Filled from that later revision rather than left
// null so nothing in this file is empty.
class AppColors {
  AppColors();
  static const dynamic mainColor = Color(0xffff6366);
  static const dynamic dark = Color(0xff212121);
  static const dynamic light = Color(0xffEEEEEE);
  static const dynamic purple = Color(0xff7D7ABC);
  static const dynamic green = Color(0xff7AC74F);
  static const dynamic yellow = Color(0xffE5B25D);
  static const dynamic rose = Color(0xffFFEBE7);
  static const dynamic orange = Color(0xffFFA500);
}

class DailyEntryController {
  DailyEntryController();
  dynamic get dailyEntry => const _Stub();
  void onInit() {}
  void updateDaily({dynamic value}) {}
  dynamic get notificationService => const _Stub();
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

// The stand-in holds what it is constructed with. Its getters returned constants while
// `fixtureProfiles` was empty, which was consistent then and is not now: every role puts
// `profiles[index].label` straight into a `Text`, so a constant getter renders the same
// blank row three times where the application renders three profile names. Storage only --
// no behaviour beyond what upstream's `@immutable class Profile` (lib/models/profile.dart)
// already is, which is two final fields.
//
// `isDefault` keeps `false` as its default for the reason given at `fixtureProfiles`: it
// decides which subtree renders, and false is the arm that renders more.
class Profile {
  const Profile({dynamic label, dynamic isDefault})
      : label = label ?? '',
        isDefault = isDefault ?? false;
  final dynamic label;
  final dynamic isDefault;
}

class ThemeService {
  ThemeService();
  dynamic get theme => const _Stub();
  dynamic isDarkTheme() => false;
  void switchTheme() {}
}

// The four strings this group actually asks for, taken verbatim from the application's own
// `lib/lang/en.dart` at the anchor commit. `.tr` returned the empty string, so every role
// rendered a blank app bar, a blank subtitle and a blank button where the application
// renders words -- and all four call sites rendered the SAME blank, which no real screen
// does. A table, not logic: the lookup falls back to the key itself, which is what GetX
// does for a key it has no translation for.
const Map<String, String> _en = <String, String>{
  'profiles': 'Profiles',
  'tapToSwitch': 'Tap on a profile to switch',
  'createNewProfile': 'Create New Profile',
  'default': 'Default',
};

extension Trans on String {
  dynamic get tr => _en[this] ?? this;
  dynamic trArgs([dynamic args]) => tr;
  dynamic trPlural([dynamic pluralKey, dynamic i, dynamic args]) => tr;
  dynamic trParams([dynamic params]) => tr;
  dynamic trPluralParams([dynamic pluralKey, dynamic i, dynamic params]) => tr;
}

class _GetImpl {
  _GetImpl();
  dynamic find<S>({dynamic tag}) => const _Stub();
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
