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

// maximal_branch: `build` returns `SizedBox.shrink()` when false, so true is the arm
// that renders.
late bool fixtureIsVisible = true;

// maximal_branch: false is the arm that renders more -- it adds the "not allowed"
// Positioned.fill overlay on top of the preview. On the role where it only picks a
// colour it costs nothing.
late bool fixtureIsAllowed = false;

// Where the drag preview sits. Read only as Positioned left/top, so it moves the
// subtree without changing it.
late Offset fixturePosition = const Offset(96.0, 240.0);

// maximal_branch (nullability): non-null is the arm that renders the sized preview
// plus the per-type subtree instead of the flat default box. `type` picks the switch
// arm; 'Container' is one of the widest ones.
late FlutterWidgetBean? fixtureWidgetBean = FlutterWidgetBean(
  id: 'widget_1725926400000_482913',
  type: 'Container',
  properties: <String, dynamic>{
    'text': 'Product details',
    'hint': 'Enter product name',
    'fontSize': '14',
    'textAlign': 'center',
    'icon': 'star',
    'size': '24',
    'backgroundColor': '#3F51B5',
    'borderColor': '#1A237E',
    'borderRadius': '8',
    'borderWidth': '1',
  },
  parentId: 'root_layout',
  children: <String>['widget_1725926400001_482914'],
  position: PositionBean(x: 24.0, y: 96.0, width: 160.0, height: 48.0),
  events: <String, String>{'onClick': 'onProductCardClick'},
  isSelected: false,
  isVisible: true,
  customCode: null,
  layout: LayoutBean(
    width: -1,
    height: -2,
    marginLeft: 8.0,
    marginTop: 8.0,
    marginRight: 8.0,
    marginBottom: 8.0,
    paddingLeft: 12,
    paddingTop: 8,
    paddingRight: 12,
    paddingBottom: 8,
    layoutGravity: 0,
    gravity: 17,
    weight: 0.0,
    orientation: 1,
    weightSum: 0.0,
    backgroundColor: 0xFF3F51B5,
    backgroundResource: 'card_background',
    backgroundResColor: '#3F51B5',
  ),
  parentType: 2,
  index: 0,
  parent: 'root_layout',
  preIndex: 0,
  preParent: 'root_layout',
  preParentType: 2,
  isFixed: false,
);

// Declared and assigned but never read by any role's `build`, so it decides no
// subtree. Left null rather than given a widget: a stand-in widget here would add
// tree the application does not have.
late Widget? fixtureDraggedWidget = null;

// Declared and assigned but never read by any role's `build`. false = a palette
// widget rather than a user-authored one.
late bool fixtureIsCustomWidget = false;

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

// Stays null: a `ui.Image` cannot be built without an async decode, which the
// determinism rule forbids. It also decides nothing -- the only guard that reads it
// is `_isImageReady && _widgetImage != null`, and `fixtureIsImageReady` is a
// relocated false, so that arm is unreachable whatever this holds.
ui.Image? fixtureWidgetImage = null;

bool fixtureIsImageReady = false;

// DECLARATION-ONLY STAND-INS -- repo-local declarations that build no UI, and
// third-party ones the transplant does not inline. Supertypes are mirrored so a
// widget still reads as a widget; everything else is `dynamic`, because none of it
// is measured.

class PositionBean {
  PositionBean({dynamic x, dynamic y, dynamic width, dynamic height});
  PositionBean.fromJson(dynamic json);
  dynamic get x => 0.0;
  dynamic get y => 0.0;
  dynamic get width => 0.0;
  dynamic get height => 0.0;
  dynamic toJson() => <String, dynamic>{};
  dynamic copyWith({dynamic x, dynamic y, dynamic width, dynamic height}) =>
      PositionBean();
}

class ColorUtils {
  ColorUtils();
  static dynamic parseColor(dynamic colorValue) => null;
  static dynamic parseHexColor(dynamic hexString) => null;
  static dynamic parseNamedColor(dynamic colorName) => null;
  static dynamic isValidColor(dynamic value) => false;
  static dynamic colorToHex(dynamic color) => '';
}

class IconUtils {
  IconUtils();
  static dynamic getIconFromName(dynamic iconName) => const _Stub();
  static dynamic getAvailableIcons() => <String>[];
  static dynamic isValidIcon(dynamic iconName) => false;
}

class TextPropertyService {
  TextPropertyService();
  static const dynamic defaultText = null;
  static const dynamic defaultTextSize = null;
  static const dynamic defaultTextColor = null;
  static const dynamic defaultBackgroundColor = null;
  static const dynamic defaultTextType = null;
  static const dynamic defaultLines = null;
  static const dynamic defaultSingleLine = null;
  static dynamic getDefaultProperties() => <String, dynamic>{};
  static dynamic getText(dynamic properties) => '';
  static dynamic getTextStyle(
    dynamic context,
    dynamic properties,
    dynamic scale,
  ) => const _Stub();
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
