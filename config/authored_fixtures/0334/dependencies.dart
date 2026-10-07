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

// HAND-FILLED. The three `BuildContext` shorthands the source app declared in
// `lib/utils/extensions.dart`, reproduced with their real return types: `titleLarge`
// reaches `Text.style`, so a `dynamic` stub would have to survive an implicit
// downcast at runtime. They resolve from the ambient `MaterialApp` theme, exactly as
// in the app.
extension BuildContextExtensions on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  Size get deviceSize => MediaQuery.sizeOf(this);
}

class ConsumerWidget extends StatelessWidget {
  const ConsumerWidget({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

// Every constructor carries the rendering of the one fixture instant --
// Mon 7 September 2026, 09:30:00 -- under its own pattern. The instant is a
// single constant, so every role in the group lays out the same glyph count.
class DateFormat {
  DateFormat([dynamic newPattern, dynamic locale]) : _formatted = 'Sep 7, 2026';
  DateFormat.d([dynamic locale]) : _formatted = '7';
  DateFormat.E([dynamic locale]) : _formatted = 'Mon';
  DateFormat.EEEE([dynamic locale]) : _formatted = 'Monday';
  DateFormat.LLL([dynamic locale]) : _formatted = 'Sep';
  DateFormat.LLLL([dynamic locale]) : _formatted = 'September';
  DateFormat.M([dynamic locale]) : _formatted = '9';
  DateFormat.Md([dynamic locale]) : _formatted = '9/7';
  DateFormat.MEd([dynamic locale]) : _formatted = 'Mon, 9/7';
  DateFormat.MMM([dynamic locale]) : _formatted = 'Sep';
  DateFormat.MMMd([dynamic locale]) : _formatted = 'Sep 7';
  DateFormat.MMMEd([dynamic locale]) : _formatted = 'Mon, Sep 7';
  DateFormat.MMMM([dynamic locale]) : _formatted = 'September';
  DateFormat.MMMMd([dynamic locale]) : _formatted = 'September 7';
  DateFormat.MMMMEEEEd([dynamic locale])
    : _formatted = 'Monday, September 7';
  DateFormat.QQQ([dynamic locale]) : _formatted = 'Q3';
  DateFormat.QQQQ([dynamic locale]) : _formatted = '3rd quarter';
  DateFormat.y([dynamic locale]) : _formatted = '2026';
  DateFormat.yM([dynamic locale]) : _formatted = '9/2026';
  DateFormat.yMd([dynamic locale]) : _formatted = '9/7/2026';
  DateFormat.yMEd([dynamic locale]) : _formatted = 'Mon, 9/7/2026';
  DateFormat.yMMM([dynamic locale]) : _formatted = 'Sep 2026';
  DateFormat.yMMMd([dynamic locale]) : _formatted = 'Sep 7, 2026';
  DateFormat.yMMMEd([dynamic locale]) : _formatted = 'Mon, Sep 7, 2026';
  DateFormat.yMMMM([dynamic locale]) : _formatted = 'September 2026';
  DateFormat.yMMMMd([dynamic locale]) : _formatted = 'September 7, 2026';
  DateFormat.yMMMMEEEEd([dynamic locale])
    : _formatted = 'Monday, September 7, 2026';
  DateFormat.yQQQ([dynamic locale]) : _formatted = 'Q3 2026';
  DateFormat.yQQQQ([dynamic locale]) : _formatted = '3rd quarter 2026';
  DateFormat.H([dynamic locale]) : _formatted = '09';
  DateFormat.Hm([dynamic locale]) : _formatted = '09:30';
  DateFormat.Hms([dynamic locale]) : _formatted = '09:30:00';
  DateFormat.j([dynamic locale]) : _formatted = '9 AM';
  DateFormat.jm([dynamic locale]) : _formatted = '9:30 AM';
  DateFormat.jms([dynamic locale]) : _formatted = '9:30:00 AM';
  DateFormat.jmv([dynamic locale]) : _formatted = '9:30 AM GMT+1';
  DateFormat.jmz([dynamic locale]) : _formatted = '9:30 AM +0100';
  DateFormat.jv([dynamic locale]) : _formatted = '9 AM GMT+1';
  DateFormat.jz([dynamic locale]) : _formatted = '9 AM +0100';
  DateFormat.m([dynamic locale]) : _formatted = '30';
  DateFormat.ms([dynamic locale]) : _formatted = '30:00';
  DateFormat.s([dynamic locale]) : _formatted = '00';

  final String _formatted;

  dynamic format(dynamic date) => _formatted;
}

class FaIcon extends StatelessWidget {
  const FaIcon(
    dynamic icon, {
    super.key,
    dynamic size,
    dynamic color,
    dynamic semanticLabel,
    dynamic textDirection,
  });
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
  dynamic get icon => Icons.circle;
  dynamic get size => 20.0;
  dynamic get color => const Color(0xFF1F2933);
  dynamic get semanticLabel => 'Icon';
  dynamic get textDirection => TextDirection.ltr;
}

class FontAwesomeIcons {
  FontAwesomeIcons();
  static dynamic get calendar => Icons.calendar_today;
  static dynamic get clock => Icons.access_time;
}

class Gap extends StatelessWidget {
  const Gap(
    dynamic mainAxisExtent, {
    super.key,
    dynamic crossAxisExtent,
    dynamic color,
  });
  const Gap.expand(dynamic mainAxisExtent, {super.key, dynamic color});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
  dynamic get mainAxisExtent => 10.0;
  dynamic get crossAxisExtent => 0.0;
  dynamic get color => const Color(0x00000000);
}

class Helpers {
  const Helpers._();
  // The same instant as `DateFormat` above, and the date spellings match
  // `DateFormat.yMMMd` exactly: the three revisions of this group differ only
  // in WHICH of these they call, so they must all lay out the same string.
  static dynamic timeToString(dynamic time) => '9:30 AM';
  static dynamic displaySnackbar(dynamic context, dynamic message) =>
      const _Stub();
  static void selectDate(dynamic context, dynamic ref) {}
  static dynamic isTaskFromSelectedDate(dynamic task, dynamic selectedDate) =>
      false;
  static dynamic dateFormater(dynamic date) => 'Sep 7, 2026';
  static dynamic dateFormatter(dynamic date) => 'Sep 7, 2026';
}

class WidgetRef {
  WidgetRef();
  dynamic get context => const _Stub();
  // A provider below that carries a fixture value hands that value back; anything
  // else stays a stub.
  dynamic watch<T>(dynamic provider) =>
      provider is _Stub ? const _Stub() : provider;
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

// HAND-FILLED. The two pickers' backing state. Upstream they are
// `StateProvider<DateTime>` seeded `DateTime.now()` and
// `StateProvider.autoDispose<TimeOfDay>` seeded `TimeOfDay.now()`; here they carry the
// one fixture instant -- Mon 7 September 2026, 09:30:00 -- the same instant `DateFormat`
// and `Helpers` above already render, so the two hint strings the revs lay out agree
// with the values behind them. Frozen literals, not `now()`, so every role in the group
// mounts identically on every run. Neither decides a branch: `format` and
// `timeToString` return their constant whatever they are handed, so the pair changes
// no tree size and no measured feature.
dynamic dateProvider = DateTime(2026, 9, 7, 9, 30);

dynamic timeProvider = const TimeOfDay(hour: 9, minute: 30);

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
  String toString() => 'Sample value';
}
