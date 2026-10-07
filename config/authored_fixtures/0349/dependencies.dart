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

// The month the calendar renders is `fixtureSelectedDate`'s, which is pinned below. Every
// date here is derived from it rather than written out, so the event days really do land in
// the rendered month on any device clock or zone -- which is what puts `hasEvent` on the arm
// that renders more, in every role in the group.
DateTime fixtureInitialDate = fixtureSelectedDate;

Color fixtureBgColor = const Color(0xFFF7F5F2);

Color fixtureAccentColor = const Color(0xFFE5533D);

Color fixtureTextColor = const Color(0xFF1C1B1F);

String fixtureFontFamily = 'Rubik';

// Cardinality 3, the corpus-wide constant from config/fixture_policy.json.
List<DateTime> fixtureEventDates = <DateTime>[
  DateTime(fixtureSelectedDate.year, fixtureSelectedDate.month, 4, 9, 30),
  DateTime(fixtureSelectedDate.year, fixtureSelectedDate.month, 12, 14, 0),
  DateTime(fixtureSelectedDate.year, fixtureSelectedDate.month, 23, 18, 45),
];

List<Event> fixtureEvents = <Event>[
  Event(
    name: 'Dentist appointment',
    description: 'Dr. Halvorsen, second floor, bring the referral letter',
    deadline: fixtureEventDates[0],
    showOnHomeScreen: true,
    isCompleted: false,
  ),
  Event(
    name: 'Pay electricity bill',
    description: 'Standing order failed last month, pay it from the app',
    deadline: fixtureEventDates[1],
    showOnHomeScreen: true,
    isCompleted: false,
  ),
  Event(
    name: 'Call mum about the weekend',
    description: 'Confirm the train times before booking anything',
    deadline: fixtureEventDates[2],
    showOnHomeScreen: false,
    isCompleted: false,
  ),
];

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

// Upstream passes `initialDate: DateTime.now()` (right_screen.dart), so there was no literal
// to relocate and the block arrived holding the epoch. That is not a value the application
// ever renders: every role puts the month straight into a `Text`, so the epoch renders
// "January 1970" / "JAN '70" where the app renders the current month. Pinned instead to the
// month the wall clock actually read at this group's anchor commit (ac39b5d2, 2024-10-31),
// which is what `DateTime.now()` returned there -- deterministic, and no longer dependent on
// the device zone the way `fromMillisecondsSinceEpoch(0)` was (it straddles 1969-12-31).
//
// TREE SIZE IS UNCHANGED, which is why this is fillable at all. `_buildCalendarDays` emits
// one `Column` per day plus `Container()` padding to a whole number of `TableRow`s, so the
// counts are fixed by (days in month, weekday of the 1st): October 2024 is 31 days starting
// Tuesday -> 5 rows, 35 cells, 31 day columns, 4 fillers. The epoch month was 31 days
// starting Thursday -> 5 rows, 35 cells, 31 day columns, 4 fillers. Identical. Any
// replacement must keep 31 days and a 1st no later than Thursday.
DateTime fixtureSelectedDate = DateTime(2024, 10, 1);

// DECLARATION-ONLY STAND-INS -- repo-local declarations that build no UI, and
// third-party ones the transplant does not inline. Supertypes are mirrored so a
// widget still reads as a widget; everything else is `dynamic`, because none of it
// is measured.

// `format` returned the empty string while the date slots above were empty, which was
// consistent then and is not now: every role in this group puts its result straight into a
// `Text`, so an empty return renders a blank month header where the application renders
// "JANUARY '70". The renderer below is the ICU skeleton subset the group actually asks for
// (y/M/L/d/E/Q/H/m/s/j, runs and literals) over the DateTime it is handed -- no locale
// data, no clock, no I/O, and the same string for the same date in every role.
class DateFormat {
  final String _pattern;

  static const List<String> _monthShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static const List<String> _monthFull = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  static const List<String> _dayShort = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];
  static const List<String> _dayFull = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];

  static String _pad(int value) => value.toString().padLeft(2, '0');

  DateFormat([dynamic newPattern, dynamic locale])
      : _pattern =
            (newPattern is String && newPattern.isNotEmpty) ? newPattern : 'yMMMd';
  DateFormat.d([dynamic locale]) : _pattern = 'd';
  DateFormat.E([dynamic locale]) : _pattern = 'E';
  DateFormat.EEEE([dynamic locale]) : _pattern = 'EEEE';
  DateFormat.EEEEE([dynamic locale]) : _pattern = 'EEEEE';
  DateFormat.LLL([dynamic locale]) : _pattern = 'LLL';
  DateFormat.LLLL([dynamic locale]) : _pattern = 'LLLL';
  DateFormat.M([dynamic locale]) : _pattern = 'M';
  DateFormat.Md([dynamic locale]) : _pattern = 'Md';
  DateFormat.MEd([dynamic locale]) : _pattern = 'MEd';
  DateFormat.MMM([dynamic locale]) : _pattern = 'MMM';
  DateFormat.MMMd([dynamic locale]) : _pattern = 'MMMd';
  DateFormat.MMMEd([dynamic locale]) : _pattern = 'MMMEd';
  DateFormat.MMMM([dynamic locale]) : _pattern = 'MMMM';
  DateFormat.MMMMd([dynamic locale]) : _pattern = 'MMMMd';
  DateFormat.MMMMEEEEd([dynamic locale]) : _pattern = 'MMMMEEEEd';
  DateFormat.QQQ([dynamic locale]) : _pattern = 'QQQ';
  DateFormat.QQQQ([dynamic locale]) : _pattern = 'QQQQ';
  DateFormat.y([dynamic locale]) : _pattern = 'y';
  DateFormat.yM([dynamic locale]) : _pattern = 'yM';
  DateFormat.yMd([dynamic locale]) : _pattern = 'yMd';
  DateFormat.yMEd([dynamic locale]) : _pattern = 'yMEd';
  DateFormat.yMMM([dynamic locale]) : _pattern = 'yMMM';
  DateFormat.yMMMd([dynamic locale]) : _pattern = 'yMMMd';
  DateFormat.yMMMEd([dynamic locale]) : _pattern = 'yMMMEd';
  DateFormat.yMMMM([dynamic locale]) : _pattern = 'yMMMM';
  DateFormat.yMMMMd([dynamic locale]) : _pattern = 'yMMMMd';
  DateFormat.yMMMMEEEEd([dynamic locale]) : _pattern = 'yMMMMEEEEd';
  DateFormat.yQQQ([dynamic locale]) : _pattern = 'yQQQ';
  DateFormat.yQQQQ([dynamic locale]) : _pattern = 'yQQQQ';
  DateFormat.H([dynamic locale]) : _pattern = 'H';
  DateFormat.Hm([dynamic locale]) : _pattern = 'Hm';
  DateFormat.Hms([dynamic locale]) : _pattern = 'Hms';
  DateFormat.j([dynamic locale]) : _pattern = 'j';
  DateFormat.jm([dynamic locale]) : _pattern = 'jm';
  DateFormat.jms([dynamic locale]) : _pattern = 'jms';
  DateFormat.jmv([dynamic locale]) : _pattern = 'jmv';
  DateFormat.jmz([dynamic locale]) : _pattern = 'jmz';
  DateFormat.jv([dynamic locale]) : _pattern = 'jv';
  DateFormat.jz([dynamic locale]) : _pattern = 'jz';
  DateFormat.m([dynamic locale]) : _pattern = 'm';
  DateFormat.ms([dynamic locale]) : _pattern = 'ms';
  DateFormat.s([dynamic locale]) : _pattern = 's';
  dynamic format(dynamic date) {
    if (date is! DateTime) return '';
    final out = StringBuffer();
    var dayPeriod = false;
    String? prevField;
    var i = 0;
    while (i < _pattern.length) {
      final ch = _pattern[i];
      if (ch == "'") {
        // ICU quoting: '' is a literal apostrophe, '...' is literal text.
        if (i + 1 < _pattern.length && _pattern[i + 1] == "'") {
          out.write("'");
          i += 2;
        } else {
          i++;
          while (i < _pattern.length && _pattern[i] != "'") {
            out.write(_pattern[i]);
            i++;
          }
          i++;
        }
        prevField = null;
        continue;
      }
      final code = ch.codeUnitAt(0);
      final isField =
          (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
      if (!isField) {
        out.write(ch);
        prevField = null;
        i++;
        continue;
      }
      // Skeletons ('yMMMd', 'Hms') carry no separators of their own, so one is
      // supplied between adjacent runs; a pattern that spells its separators out
      // ('MMM dd, yyyy') never reaches this, prevField having been cleared above.
      if (prevField != null) {
        const timeFields = ['H', 'h', 'j', 'm'];
        out.write(
          timeFields.contains(prevField) && (ch == 'm' || ch == 's') ? ':' : ' ',
        );
      }
      var run = 0;
      while (i + run < _pattern.length && _pattern[i + run] == ch) {
        run++;
      }
      i += run;
      prevField = ch;
      switch (ch) {
        case 'y':
          out.write(run == 2 ? _pad(date.year % 100) : date.year.toString());
          break;
        case 'M':
        case 'L':
          if (run >= 4) {
            out.write(_monthFull[date.month - 1]);
          } else if (run == 3) {
            out.write(_monthShort[date.month - 1]);
          } else {
            out.write(run == 2 ? _pad(date.month) : date.month.toString());
          }
          break;
        case 'd':
          out.write(run >= 2 ? _pad(date.day) : date.day.toString());
          break;
        case 'E':
          if (run >= 5) {
            out.write(_dayFull[date.weekday - 1][0]);
          } else if (run == 4) {
            out.write(_dayFull[date.weekday - 1]);
          } else {
            out.write(_dayShort[date.weekday - 1]);
          }
          break;
        case 'Q':
          final quarter = ((date.month - 1) ~/ 3) + 1;
          if (run >= 4) {
            out.write('Quarter $quarter');
          } else if (run == 3) {
            out.write('Q$quarter');
          } else {
            out.write(quarter.toString());
          }
          break;
        case 'H':
          out.write(run >= 2 ? _pad(date.hour) : date.hour.toString());
          break;
        case 'h':
        case 'j':
          dayPeriod = true;
          final hour12 = date.hour % 12 == 0 ? 12 : date.hour % 12;
          out.write(run >= 2 ? _pad(hour12) : hour12.toString());
          break;
        case 'a':
          dayPeriod = true;
          break;
        case 'm':
          out.write(_pad(date.minute));
          break;
        case 's':
          out.write(_pad(date.second));
          break;
        default:
          // 'v' and 'z' ask for a zone name. The device clock is out of scope
          // here, so nothing is written rather than a zone asserted.
          break;
      }
    }
    if (dayPeriod) {
      out.write(date.hour < 12 ? ' AM' : ' PM');
    }
    return out.toString();
  }
}

const dynamic fontNormal = 'Rubik';

// The stand-in holds what it is constructed with. Its getters returned constants while the
// slots above were empty; now that they carry values, an `Event` that dropped them would
// render an empty `Text` where the application renders a title, and the fixture would be
// stubbing out the very strings the group is meant to mount. No behaviour is added beyond
// storage -- still no I/O, no clock, no allocation the application does not make.
class Event {
  Event({
    dynamic name,
    dynamic description,
    dynamic deadline,
    dynamic showOnHomeScreen,
    dynamic isCompleted,
  })  : name = name ?? '',
        description = description ?? '',
        deadline = deadline ?? DateTime.fromMillisecondsSinceEpoch(0),
        showOnHomeScreen = showOnHomeScreen ?? false,
        isCompleted = isCompleted ?? false;
  dynamic name;
  dynamic description;
  dynamic deadline;
  dynamic showOnHomeScreen;
  dynamic isCompleted;
  dynamic toJson() => <String, dynamic>{
        'name': name,
        'description': description,
        'deadline': deadline.toString(),
        'showOnHomeScreen': showOnHomeScreen,
        'isCompleted': isCompleted,
      };
  static dynamic fromJson(dynamic json) => Event();
}
