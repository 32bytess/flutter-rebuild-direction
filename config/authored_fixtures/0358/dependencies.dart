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

// The subject of every role in this group: one herb monograph page. `Herb` is a
// declaration-only stand-in whose constructor stores nothing, so the values live on its
// getters below and this is a plain construction -- one allocation, in `initState`, outside
// the measured rebuild. Giving the stand-in real fields would be a change of structure, not
// of value, so it is not made here.
Herb fixtureHerb = Herb();

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

bool fixtureIsBookmarked = false;

// DECLARATION-ONLY STAND-INS -- repo-local declarations that build no UI, and
// third-party ones the transplant does not inline. Supertypes are mirrored so a
// widget still reads as a widget; everything else is `dynamic`, because none of it
// is measured.

class Formula {
  Formula({
    dynamic id,
    dynamic name,
    dynamic alias,
    dynamic meridian,
    dynamic category,
    dynamic components,
    dynamic indication,
    dynamic contraindication,
    dynamic dosage,
    dynamic preparation,
    dynamic explanation,
    dynamic keywords,
  });
  Formula.fromJson(dynamic json);
  // 麻黃湯, the canonical formula containing the herb above. Reached only through
  // `FormulaRepository`, which is left exactly as generated (see the note there), so these
  // values are inert in this group -- they are filled so the stand-in is internally
  // consistent with the herb, not to change what renders.
  dynamic get id => 'F0013';
  dynamic get name => '麻黃湯';
  dynamic get alias => '還魂湯';
  dynamic get meridian => '太陽經';
  dynamic get category => '辛溫解表劑';
  dynamic get components => <FormulaComponent>[
    FormulaComponent(),
    FormulaComponent(),
    FormulaComponent(),
  ];
  dynamic get indication =>
      '外感風寒表實證:惡寒發熱,頭身疼痛,無汗而喘,舌苔薄白,脈浮緊。';
  dynamic get contraindication => '表虛有汗、外感風熱、體虛喘咳及瘡家、衄家者禁用。';
  dynamic get dosage => '麻黃三兩,桂枝二兩,杏仁七十個,炙甘草一兩。';
  dynamic get preparation =>
      '以水九升,先煮麻黃減二升,去上沫,內諸藥,煮取二升半,去滓,溫服八合,覆取微似汗。';
  dynamic get explanation =>
      '麻黃發汗解表為君,桂枝助陽解肌為臣,杏仁降氣平喘為佐,炙甘草調和諸藥為使。';
  dynamic get keywords => <String>['發汗解表', '宣肺平喘', '太陽傷寒'];
  dynamic get componentsText => '麻黃 三兩 · 桂枝 二兩 · 杏仁 七十個 · 炙甘草 一兩';
  dynamic toJson() => <String, dynamic>{};
}

class FormulaComponent {
  FormulaComponent({dynamic name, dynamic dosage, dynamic role});
  FormulaComponent.fromJson(dynamic json);
  dynamic get name => '麻黃';
  dynamic get dosage => '三兩';
  dynamic get role => '君';
  dynamic toJson() => <String, dynamic>{};
}

// LEFT EXACTLY AS GENERATED, DELIBERATELY. These are the group's two repositories, and what
// they return is decided in a method body rather than in a value slot -- which is outside
// what this pass fills. It also matters for the contrast: `getAll()` feeds the 方剂 section,
// and roles 001 and 002 differ precisely in how they filter it (`c.name == herb.name` versus
// `HerbRepository.canonicalOf(c.name) == herb.name`). With `getAll()` empty both endpoints
// render `SizedBox.shrink()` and the pair stays symmetric; populating it while
// `canonicalOf` returns `''` would render N tiles in 001 and none in 002, putting a tree-size
// difference on a contrast that is supposed to isolate the edit.
class FormulaRepository {
  FormulaRepository();
  static dynamic load() => const _Stub();
  static dynamic getAll() => [];
  static dynamic getById(dynamic id) => null;
  static dynamic getByName(dynamic name) => null;
  static dynamic search(dynamic query) => [];
  static dynamic getByMeridian(dynamic meridian) => [];
  static dynamic getByCategory(dynamic category) => [];
  static dynamic getCategories() => <String>[];
  static dynamic resolveFormula(dynamic engineName) => null;
  static dynamic buildPrescription(
    dynamic formulaName, {
    dynamic modifications,
  }) => null;
}

class Herb {
  Herb({
    dynamic name,
    dynamic original,
    dynamic nature,
    dynamic action,
    dynamic rongchuan,
    dynamic niNote,
    dynamic dosage,
    dynamic contraindication,
    dynamic clinicalNotes,
    dynamic historicalNotes,
    dynamic herbComparisons,
    dynamic natureCategory,
    dynamic flavor,
    dynamic meridians,
    dynamic category,
  });
  Herb.fromJson(dynamic json);
  // 麻黃 (Ephedra) -- a 神農本草經 entry the application really ships, chosen because it is one
  // of the few monographs that fills every optional section, which is the arm that renders
  // more. Every getter below returns a value: the nullable ones each gate an
  // `if (herb.X != null)` section in all three roles, so a null here would silently delete
  // that section from the whole group rather than from one side of a contrast.
  //
  // The list literals stay non-`const` and stay at three elements: non-`const` keeps the
  // per-read allocation the generated `<String>[]` already had, and three is the
  // corpus-wide cardinality constant from config/fixture_policy.json.
  dynamic get name => '麻黃';
  dynamic get original =>
      '味苦,溫。主中風、傷寒頭痛,溫瘧,發表出汗,去邪熱氣,止咳逆上氣,除寒熱,破癥堅積聚。';
  dynamic get nature => '味苦、辛,性溫。無毒。';
  dynamic get action => '發汗解表,宣肺平喘,利水消腫。治風寒表實無汗、咳逆上氣、風水浮腫。';
  dynamic get rongchuan =>
      '容川曰:麻黃中空似毛竅,其味辛,其氣溫,能引營分之邪由毛竅而出,故為發汗第一要藥。中空則不傷津,辛溫則不留邪。';
  dynamic get niNote =>
      '倪注:麻黃為發汗峻劑,無汗而喘者用之,有汗者絕不可用,誤用則亡陽。煎時必先煮麻黃去上沫,沫令人心煩。';
  dynamic get dosage => '一錢半至三錢(4.5–9 克),先煎去上沫。體虛及老幼減半用。';
  dynamic get contraindication =>
      '表虛自汗、陰虛盜汗、腎不納氣之虛喘者忌用。高血壓、心悸、失眠者慎用,不可久服。';
  dynamic get clinicalNotes =>
      '倪師云:小兒感冒無汗高燒,麻黃湯一劑即退,汗出即停後服。若病人已自汗出,改用桂枝湯,此處分寸不可含糊。';
  dynamic get historicalNotes =>
      '《本草綱目》:麻黃乃肺經專藥,故治肺病多用之。《本經疏證》:麻黃之用有三,曰發表出汗,曰身腫風腫,曰咳逆上氣。'
      '《醫學衷中參西錄》:麻黃發汗之力甚猛,然佐以石膏則其性轉涼,可治肺熱作喘。';
  dynamic get herbComparisons => <String>[
    '麻黃與桂枝:同為辛溫解表,麻黃開腠理而力峻,桂枝解肌和營而力緩;無汗用麻黃,有汗用桂枝。',
    '麻黃與杏仁:麻黃宣肺以開,杏仁降氣以斂,一宣一降,咳喘乃平。',
    '麻黃與石膏:麻黃湯證無汗而喘,加石膏即成麻杏石甘湯,轉治肺熱壅盛之汗出而喘。',
  ];
  dynamic get natureCategory => '溫性';
  dynamic get flavor => '辛、微苦';
  dynamic get meridians => <String>['肺經', '膀胱經', '大腸經'];
  dynamic get category => '解表藥 · 發散風寒';
  // The 001/002 contrast puts this in a `Text`; 003 replaces it with `Icon(herb.natureIcon)`.
  // Both endpoints therefore need a real value of their own type -- a `_Stub` reaching
  // `Icon`'s `IconData?` parameter is a runtime type error, not a blank glyph. Both name the
  // same 溫性, so the pair differs only by the edit.
  dynamic get natureEmoji => '🔥';
  dynamic get hasDetailedInfo => true;
  dynamic get natureIcon => Icons.local_fire_department;
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

class HerbRepository {
  HerbRepository();
  static dynamic load() => const _Stub();
  static dynamic canonicalOf(dynamic name) => '';
  static dynamic getAll() => [];
  static dynamic getByCategory(dynamic category) => [];
  static dynamic search(dynamic query) => [];
  static dynamic getByName(dynamic name) => null;
  static dynamic getCategories() => <String>[];
  static dynamic getNatureCategories() => <String>[];
  static dynamic getByNature(dynamic nature) => [];
  static dynamic getExactByName(dynamic name) => null;
}
