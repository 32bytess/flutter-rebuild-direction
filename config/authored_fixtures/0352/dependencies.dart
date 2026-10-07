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

late TabController fixtureTabController; // TODO: value

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

String fixtureSelectedCategory = '全部';

String fixtureSearchQuery = '';

String fixturePenetrationSearch = '';

String fixtureSelectedMeridian = '全部';

String fixtureAcupointSearch = '';

// DECLARATION-ONLY STAND-INS -- repo-local declarations that build no UI, and
// third-party ones the transplant does not inline. Supertypes are mirrored so a
// widget still reads as a widget; everything else is `dynamic`, because none of it
// is measured.

// The stand-ins below HOLD what they are constructed with. They returned constants while the
// data slots were empty, which was consistent then and is not now: every role in this group
// puts these strings straight into a `Text` and these lists straight into a `children:`, so a
// stand-in that dropped them would render a blank card where the application renders an entry.
// No behaviour is added beyond storage and the one-expression getters the application itself
// declares -- still no I/O, no clock, no `Random`, no allocation the application does not make.
//
// FOUR MEMBERS CARRY A STATIC TYPE instead of `dynamic`, and that is not cosmetic: it is what
// lets this group mount at all. `Acupoint.name`, `AcupointEntry.acupoints`,
// `PenetrationEntry.name` and `PenetrationEntry.indications` are each fed straight into a
// `.map(...).toList()` whose result lands in a `children:` slot. Reached through `dynamic`,
// that chain is a dynamic invocation, so `map` is instantiated to its bound and returns
// `List<dynamic>` -- which is not a `List<Widget>` and throws on the cast, EMPTY OR NOT. The
// generated `dynamic get acupoints => []` therefore could not mount either; typing the four is
// what removes the throw, not the values. Everything else stays `dynamic`, as generated.
class Acupoint {
  Acupoint({dynamic name, this.method}) : name = name ?? '';
  Acupoint.fromJson(dynamic json)
      : name = '',
        method = null;
  String name;
  dynamic method;
  dynamic toJson() => <String, dynamic>{'name': name, 'method': method};
}

class AcupointDetail {
  AcupointDetail({
    dynamic name,
    dynamic meridian,
    dynamic attribute,
    dynamic description,
    dynamic location,
    dynamic needling,
    dynamic moxibustion,
    dynamic contraindication,
    dynamic clinicalNotes,
  })  : name = name ?? '',
        meridian = meridian ?? '',
        attribute = attribute ?? '',
        description = description ?? '',
        location = location ?? '',
        needling = needling ?? '',
        moxibustion = moxibustion ?? '',
        contraindication = contraindication ?? '',
        clinicalNotes = clinicalNotes ?? '';
  AcupointDetail.fromJson(dynamic json)
      : name = '',
        meridian = '',
        attribute = '',
        description = '',
        location = '',
        needling = '',
        moxibustion = '',
        contraindication = '',
        clinicalNotes = '';
  dynamic name;
  dynamic meridian;
  dynamic attribute;
  dynamic description;
  dynamic location;
  dynamic needling;
  dynamic moxibustion;
  dynamic contraindication;
  dynamic clinicalNotes;
  dynamic get hasNotes => true;
  dynamic get hasLocation => true;
  dynamic toJson() => <String, dynamic>{};
}

class AcupointEntry {
  AcupointEntry({
    dynamic id,
    dynamic symptom,
    List<String>? aliases,
    List<Acupoint>? acupoints,
    dynamic notes,
    dynamic medicalCase,
    dynamic source,
  })  : id = id ?? 0,
        symptom = symptom ?? '',
        aliases = aliases ?? const <String>[],
        acupoints = acupoints ?? const <Acupoint>[],
        notes = notes ?? '',
        medicalCase = medicalCase ?? '',
        source = source ?? '';
  AcupointEntry.fromJson(dynamic json)
      : id = 0,
        symptom = '',
        aliases = const <String>[],
        acupoints = const <Acupoint>[],
        notes = '',
        medicalCase = '',
        source = '';
  dynamic id;
  dynamic symptom;
  List<String> aliases;
  List<Acupoint> acupoints;
  dynamic notes;
  dynamic medicalCase;
  dynamic source;
  dynamic get acupointsText => acupoints.map((a) => a.name).join('、');
  dynamic get hasCase => medicalCase.isNotEmpty;
  dynamic get sourceLabel => source == 'nihaisha' ? '倪海厦' : '针灸大成';
  dynamic toJson() => <String, dynamic>{};
}

// Both repositories are lookups over the fixture data at the foot of this file. Each method
// hands back the whole collection its name selects rather than filtering by its argument: the
// argument every role actually passes is the relocated initial state -- `_searchQuery ''`,
// `_selectedCategory '全部'`, `_acupointSearch ''`, `_selectedMeridian '全部'` -- which is the
// "show everything" case in the application too, so returning the collection IS the answer for
// the values this group mounts, and it is the same answer in every role. No search is
// implemented here: a filter is behaviour, and behaviour is what a stand-in must not add.
//
// The lists returned are typed exactly as the roles' own signatures demand
// (`List<AcupointEntry>`, `List<PenetrationEntry>`, `List<AcupointDetail>`, `List<String>`),
// because each return crosses `dynamic` back into a typed local and is cast on arrival.
class AcupointRepository {
  AcupointRepository();
  static dynamic get count => _acupointDetails.length;
  static dynamic load() => const _Stub();
  static dynamic getAll() => _acupointDetails;
  static dynamic findByName(dynamic name) => _acupointDetails[0];
  static dynamic search(dynamic query) => _acupointDetails;
  static dynamic getMeridians() => _meridians;
  static dynamic getByMeridian(dynamic meridian) => _acupointDetails;
  static dynamic get allNames => _acupointNames;
  static dynamic canonicalOf(dynamic name) => name;
}

class AcupunctureRepository {
  AcupunctureRepository();
  static dynamic load() => const _Stub();
  static dynamic getAll() => _entries;
  static dynamic getEntries() => _entries;
  static dynamic getByCategory(dynamic categoryName) => _entries;
  static dynamic getCategories() => _categories;
  static dynamic getPenetrations() => _penetrations;
  static dynamic search(dynamic query) => _entries;
  static dynamic searchPenetrations(dynamic query) => _penetrations;
}

class PenetrationEntry {
  PenetrationEntry({
    dynamic id,
    String? name,
    List<String>? indications,
    dynamic source,
    dynamic clinicalInsight,
    dynamic medicalCase,
  })  : id = id ?? 0,
        name = name ?? '',
        indications = indications ?? const <String>[],
        source = source ?? '',
        clinicalInsight = clinicalInsight ?? '',
        medicalCase = medicalCase ?? '';
  PenetrationEntry.fromJson(dynamic json)
      : id = 0,
        name = '',
        indications = const <String>[],
        source = '',
        clinicalInsight = '',
        medicalCase = '';
  dynamic id;
  String name;
  List<String> indications;
  dynamic source;
  dynamic clinicalInsight;
  dynamic medicalCase;
  dynamic get hasInsight => clinicalInsight.isNotEmpty;
  dynamic get hasCase => medicalCase.isNotEmpty;
  dynamic toJson() => <String, dynamic>{};
}

// FIXTURE DATA -- what the two repositories hand back, and the only thing in this file that
// decides tree size. EVERY COLLECTION HERE HOLDS EXACTLY 3, the corpus-wide cardinality
// constant from `config/fixture_policy.json`: 3 categories, 3 meridians, 3 prescription
// entries, 3 acupoints inside each entry, 3 aliases, 3 penetrations, 3 indications, 3 acupoint
// details. The one place a rendered count is not 3 is the meridian filter, where the role
// itself writes `['全部', ...getMeridians()]` and so draws 4 chips; that extra chip is the
// application's structure, not this fixture's.
//
// The content is ordinary data for what this application is -- a TCM acupuncture reference --
// so that a card renders a symptom, a point list and a case note the way the shipped app does,
// rather than a blank of the right shape. Every field is filled, which also puts each of the
// conditionals the roles guard subtrees with (`aliases.isNotEmpty`, `notes.isNotEmpty`,
// `hasCase`, `hasInsight`, `description.isNotEmpty`, `location.isNotEmpty`,
// `meridian.isNotEmpty`) on the arm that renders MORE, in both roles alike.
//
// `'全部'` leads `_categories` because `fixtureSelectedCategory` is the relocated `'全部'`: the
// chip row compares `_selectedCategory == cat`, so without it no chip would read as selected
// and the fixture would be mounting a state the application never starts in.

const List<String> _categories = <String>['全部', '内科', '妇科'];

const List<String> _meridians = <String>[
  '手太阴肺经',
  '足阳明胃经',
  '足太阴脾经',
];

// The lookup table `_parseFormulas` scans clinical notes against. Held to the same 3 as every
// other collection, and to the three points `_acupointDetails` actually declares, so a name it
// finds is a name this fixture can also resolve through `findByName`.
const List<String> _acupointNames = <String>['中府', '足三里', '三阴交'];

final List<AcupointDetail> _acupointDetails = <AcupointDetail>[
  AcupointDetail(
    name: '中府',
    meridian: '手太阴肺经',
    attribute: '肺之募穴 / 手足太阴之会',
    description: '肺气结聚之处，宣肺理气、止咳平喘的要穴。',
    location: '胸前壁外上方，前正中线旁开6寸，平第一肋间隙处。',
    needling: '向外斜刺或平刺 0.5~0.8 寸，得气为度。',
    moxibustion: '艾炷灸 3~5 壮，或艾条温和灸 5~10 分钟。',
    contraindication: '不可向内深刺，以免伤及肺脏；局部破损感染者禁针。',
    clinicalNotes: '**中府透云门**：咳喘胸闷，沿皮下平刺，肺气一宣则咳自止。',
  ),
  AcupointDetail(
    name: '足三里',
    meridian: '足阳明胃经',
    attribute: '合穴 / 胃之下合穴',
    description: '胃经合穴，主治一切胃肠疾患，为强壮保健要穴。',
    location: '小腿外侧，犊鼻下3寸，胫骨前嵴外一横指处。',
    needling: '直刺 1~2 寸，局部酸胀，可向足背方向放散。',
    moxibustion: '艾炷灸 5~7 壮，或艾条温和灸 10~20 分钟，可长期施灸。',
    contraindication: '孕妇慎用强刺激手法；过饥过饱者不宜施针。',
    clinicalNotes: '**足三里配三阴交**：脾胃虚弱、纳呆便溏，先补足三里再补三阴交。',
  ),
  AcupointDetail(
    name: '三阴交',
    meridian: '足太阴脾经',
    attribute: '足三阴经交会穴',
    description: '肝脾肾三经交会，调经止带、健脾利湿的常用穴。',
    location: '小腿内侧，内踝尖上3寸，胫骨内侧缘后际。',
    needling: '直刺 1~1.5 寸，酸胀感可向膝部放散。',
    moxibustion: '艾炷灸 3~5 壮，或艾条温和灸 10~15 分钟。',
    contraindication: '孕妇禁针，恐动胎气。',
    clinicalNotes: '**暖宫方**：三阴交 + 关元 + 气海，经寒腹痛者温灸尤佳。',
  ),
];

final List<AcupointEntry> _entries = <AcupointEntry>[
  AcupointEntry(
    id: 101,
    symptom: '胃脘痛',
    aliases: <String>['胃痛', '心下痛', '胃气痛'],
    acupoints: <Acupoint>[
      Acupoint(name: '足三里', method: '补'),
      Acupoint(name: '中脘', method: '平补平泻'),
      Acupoint(name: '内关', method: '泻'),
    ],
    notes: '饭后半小时施针，留针二十分钟，忌生冷油腻。',
    medicalCase: '一男子胃痛年余，服药不效，针足三里、中脘三次而痛止。',
    source: 'nihaisha',
  ),
  AcupointEntry(
    id: 102,
    symptom: '失眠',
    aliases: <String>['不寐', '不得眠', '目不瞑'],
    acupoints: <Acupoint>[
      Acupoint(name: '神门', method: '补'),
      Acupoint(name: '三阴交', method: '补'),
      Acupoint(name: '安眠', method: '平补平泻'),
    ],
    notes: '睡前一小时施治，配合按揉涌泉，忌浓茶咖啡。',
    medicalCase: '一妇彻夜不眠半年，针神门、三阴交七次，夜能安睡五六时。',
    source: 'zhenjiu',
  ),
  AcupointEntry(
    id: 103,
    symptom: '腰痛',
    aliases: <String>['腰脊痛', '腰腿痛', '闪腰'],
    acupoints: <Acupoint>[
      Acupoint(name: '委中', method: '泻'),
      Acupoint(name: '肾俞', method: '补'),
      Acupoint(name: '腰阳关', method: '温针'),
    ],
    notes: '「腰背委中求」，急性闪腰先取委中，再补肾俞固本。',
    medicalCase: '一工人闪腰不能俯仰，委中点刺出血，当即能行。',
    source: 'nihaisha',
  ),
];

// Each name is one `A透B` pair, so `_extractAcupointsFromName` yields 2 chips for every entry
// alike -- the split is on '透' and '、', and both halves are inside its `length <= 4` filter.
final List<PenetrationEntry> _penetrations = <PenetrationEntry>[
  PenetrationEntry(
    id: 201,
    name: '中府透云门',
    indications: <String>['咳嗽', '气喘', '胸满'],
    source: '《针灸大成》',
    clinicalInsight: '沿皮下向外上方平刺，得气后留针二十分钟，肺气宣通则咳止。',
    medicalCase: '一妇久咳三月，透刺三次，咳减大半。',
  ),
  PenetrationEntry(
    id: 202,
    name: '曲池透少海',
    indications: <String>['肘臂疼痛', '上肢麻木', '眩晕'],
    source: '《针灸甲乙经》',
    clinicalInsight: '屈肘取穴，缓慢透刺，酸胀达指端者效佳，忌反复提插。',
    medicalCase: '一老者右臂麻木不举，透刺五次，抬举自如。',
  ),
  PenetrationEntry(
    id: 203,
    name: '地仓透颊车',
    indications: <String>['口眼歪斜', '面痛', '流涎'],
    source: '《玉龙歌》',
    clinicalInsight: '自地仓向颊车方向沿皮透刺，针尖不越颊车，面部得气即止。',
    medicalCase: '一男子口角㖞斜旬日，透刺十次而复常。',
  ),
];

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
