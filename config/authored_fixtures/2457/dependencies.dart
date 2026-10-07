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

LoyaltyCard fixtureLoyaltyCard = LoyaltyCard(
  id: 'card_10427',
  barcode: '036000291452',
  name: 'Green Valley Rewards',
  points: 250,
  usedCount: 12,
);

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

bool canCreateCardWidget = false;

bool canCreateCardWidgetValue = false;

// HAND-AUTHORED 2026-09-15 (typed initialisers). Both were `= GetIt.I<...>()`, and `GetIt.I`
// at :118 is a stand-in returning `const _Stub()` -- so each binding declared a `Box<E>`
// statically, held a `_Stub` at runtime, and threw the moment a role reached it. Dart accepts
// the assignment because `I` returns `dynamic`, which is why nothing before the device caught
// it. `LoyaltyCardsBox` is `typedef LoyaltyCardsBox = dynamic` at :217, so the type argument
// carried no information either.
//
// BOTH ARE REPAIRED, not just the one that threw. Only `fixtureCardsBox` appears in the
// device logs, because `build` dies at the first one; `fixtureSettingsBox` has the identical
// defect and would throw on the next execution, and leaving it would buy one re-measure to
// discover a fault already visible here.
//
// NO VALUE IS INVENTED HERE, AND THE BOXES STAY EMPTY ON PURPOSE. `class Box<E>` at :87 is the
// generator's own reconstruction and already answers every read the roles make -- `values =>
// []`, `get(...) => null`, `value => Settings()`. Their emptiness is not an oversight: how
// many elements go in a collection is tree size, the dependent variable, and a card list with
// rows chosen by hand would be a row count chosen by hand.
Box<LoyaltyCard> fixtureCardsBox = Box<LoyaltyCard>();

Box<Settings> fixtureSettingsBox = Box<Settings>();

// DECLARATION-ONLY STAND-INS -- repo-local declarations that build no UI, and
// third-party ones the transplant does not inline. Supertypes are mirrored so a
// widget still reads as a widget; everything else is `dynamic`, because none of it
// is measured.

class Box<E> {
  Box();
  dynamic get values => [];
  dynamic valuesBetween({dynamic startKey, dynamic endKey}) => [];
  dynamic get(dynamic key, {dynamic defaultValue}) => null;
  dynamic getAt(dynamic index) => null;
  dynamic toMap() => {};
  dynamic get value => Settings();
}

class CardListViewOptions {
  const CardListViewOptions({
    dynamic numberOfColumns,
    dynamic sortingStyle,
    dynamic sortNameCaseInsensitive,
    dynamic sortNameIgnoreAccents,
    dynamic customOrder,
  });
  const CardListViewOptions.defaultValue();
  CardListViewOptions.fromJsonMap(dynamic map);
  dynamic get numberOfColumns => 0;
  dynamic get sortingStyle => SortingStyle.nameAz;
  dynamic get sortNameCaseInsensitive => false;
  dynamic get sortNameIgnoreAccents => false;
  dynamic get customOrder => <String>[];
  dynamic toJsonMap() => <String, dynamic>{};
  dynamic editable() => const _Stub();
  void sortCards(dynamic cards) {}
}

class GetIt {
  GetIt.asNewInstance();
  static dynamic get I => const _Stub();
}

class HiveField {
  const HiveField(dynamic index, {dynamic defaultValue});
  dynamic get index => 0;
  dynamic get defaultValue => const _Stub();
}

class HiveType {
  const HiveType({dynamic typeId, dynamic adapterName});
  dynamic get typeId => 0;
  dynamic get adapterName => null;
}

class HiveTypeIds {
  HiveTypeIds();
  static const dynamic settings = null;
  static const dynamic autoBackupSettings = null;
  static const dynamic themeSettings = null;
  static const dynamic loyaltyCardEffectSettings = null;
  static const dynamic loyaltyCardEffect = null;
  static const dynamic developerOptions = null;
  static const dynamic sortingStyle = null;
  static const dynamic cardListViewOptions = null;
  static const dynamic loyaltyCard = null;
  static const dynamic barcode = null;
  static const dynamic color = null;
  static const dynamic barcodeType = null;
  static const dynamic backupFormat = null;
}

class LoyaltyCard {
  LoyaltyCard({
    dynamic id,
    dynamic barcode,
    dynamic name,
    dynamic color,
    dynamic tags,
    dynamic notes,
    dynamic frontImagePath,
    dynamic backImagePath,
    dynamic useFrontImageOverlay,
    dynamic points,
    dynamic requiresAuth,
    dynamic hideName,
    dynamic createdAt,
    dynamic lastModifiedAt,
    dynamic usePoints,
    dynamic usedCount,
  });
  LoyaltyCard.fromLegacySharing(dynamic value);
  LoyaltyCard.fromLegacyExport(dynamic value);
  LoyaltyCard.fromJson(dynamic value);
  LoyaltyCard.fromJsonMap(dynamic jsonMap);
  static const dynamic defaultColor = null;
  dynamic get id => 'card_10427';
  dynamic get barcode => const _Stub();
  dynamic get name => 'Green Valley Rewards';
  dynamic get color => null;
  dynamic get tags => <String>{};
  dynamic get notes => null;
  dynamic get frontImagePath => null;
  dynamic get backImagePath => null;
  dynamic get useFrontImageOverlay => false;
  dynamic get points => 250;
  dynamic get requiresAuth => false;
  dynamic get hideName => false;
  dynamic get createdAt => DateTime.utc(2024, 3, 14, 9, 30);
  dynamic get lastModifiedAt => DateTime.utc(2024, 11, 2, 18, 5);
  dynamic get nonNullColor => const _Stub();
  dynamic editable() => const _Stub();
  dynamic toJson() => '{"id":"card_10427","name":"Green Valley Rewards"}';
  dynamic toJsonMap() => <String, dynamic>{};
  dynamic clone() => LoyaltyCard();
  dynamic get usePoints => false;
  dynamic copyWith({
    dynamic id,
    dynamic barcode,
    dynamic name,
    dynamic color,
    dynamic tags,
    dynamic notes,
    dynamic frontImagePath,
    dynamic backImagePath,
    dynamic useFrontImageOverlay,
    dynamic points,
    dynamic requiresAuth,
    dynamic hideName,
    dynamic createdAt,
    dynamic lastModifiedAt,
    dynamic usePoints,
    dynamic usedCount,
  }) => LoyaltyCard();
  LoyaltyCard.fromLegacyValueList(dynamic rawList);
  dynamic get usedCount => 12;
}

typedef LoyaltyCardsBox = dynamic;

class Settings {
  const Settings({
    dynamic lastSeenAppVersion,
    dynamic autoBackups,
    dynamic theme,
    dynamic developerOptions,
    dynamic useAutoBrightness,
    dynamic vibrateOnDifferentActions,
    dynamic tags,
    dynamic cardListViewOptions,
    dynamic customExportPath,
    dynamic format,
  });
  const Settings.defaultValue();
  Settings.fromJsonMap(dynamic map);
  static const dynamic defaultCardExportDirectoryPath = null;
  dynamic get lastSeenAppVersion => null;
  dynamic get autoBackups => const _Stub();
  dynamic get theme => const _Stub();
  dynamic get developerOptions => const _Stub();
  dynamic get useAutoBrightness => false;
  dynamic get vibrateOnDifferentActions => false;
  dynamic get tags => <String>[];
  dynamic get cardListViewOptions => CardListViewOptions();
  dynamic get customExportPath => '/storage/emulated/0/Download/Catima';
  dynamic toJsonMap() => <String, dynamic>{};
  dynamic editable() => const _Stub();
  dynamic get format => const _Stub();
}

typedef SettingsBox = dynamic;

extension SettingsBoxExtensions on Box<Settings> {
  dynamic get value => Settings();
  dynamic save(dynamic settings) => const _Stub();
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
