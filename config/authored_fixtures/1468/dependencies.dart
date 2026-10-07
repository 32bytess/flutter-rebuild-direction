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

List<String> fixtureLogs = <String>[
  '2026-09-12 08:14:03 [service] location 52.520008, 13.404954',
  '2026-09-12 08:14:33 [network] response 200 OK from server',
  '2026-09-12 08:15:03 [service] status online, battery 87%',
];

// DECLARATION-ONLY STAND-INS -- repo-local declarations that build no UI, and
// third-party ones the transplant does not inline. Supertypes are mirrored so a
// widget still reads as a widget; everything else is `dynamic`, because none of it
// is measured.

class AppLocalizations {
  AppLocalizations(dynamic locale);
  dynamic get localeName => 'en';
  static const dynamic delegate = null;
  static const dynamic localizationsDelegates = null;
  static const dynamic supportedLocales = null;
  dynamic get trackingTitle => 'Traccar Client';
  dynamic get settingsTitle => 'Settings';
  dynamic get statusTitle => 'Status';
  dynamic get saveButton => 'Save';
  dynamic get cancelButton => 'Cancel';
  dynamic get locationButton => 'Location';
  dynamic get statusButton => 'Status';
  dynamic get settingsButton => 'Settings';
  dynamic get invalidValue => 'Invalid value';
  dynamic get idLabel => 'Device identifier';
  dynamic get urlLabel => 'Server URL';
  dynamic get accuracyLabel => 'Location accuracy';
  dynamic get highAccuracyLabel => 'High';
  dynamic get mediumAccuracyLabel => 'Medium';
  dynamic get lowAccuracyLabel => 'Low';
  dynamic get intervalLabel => 'Frequency';
  dynamic get distanceLabel => 'Distance';
  dynamic get bufferLabel => 'Offline buffering';
  dynamic get trackingLabel => 'Service status';
  dynamic get startAction => 'Start';
  dynamic get stopAction => 'Stop';
  dynamic get sosAction => 'SOS';
  static final AppLocalizations _instance = AppLocalizations('en');
  static dynamic of(dynamic context) => _instance;
  dynamic get heartbeatLabel => 'Heartbeat interval';
  dynamic get preventSuspendLabel => 'Prevent suspend';
  dynamic get disableElasticityLabel => 'Disable elasticity';
  dynamic get stopDetectionLabel => 'Stop detection';
  dynamic get disabledValue => 'Disabled';
  dynamic get fastestIntervalLabel => 'Fastest interval';
  dynamic get motionLabel => 'Motion';
  dynamic get advancedLabel => 'Advanced';
  dynamic get okButton => 'OK';
  dynamic get wakelockLabel => 'Wakelock';
  dynamic get optimizationMessage =>
      'Disable battery optimizations for reliable tracking.';
  dynamic get highestAccuracyLabel => 'Highest';
  dynamic get angleLabel => 'Angle';
  dynamic get passwordLabel => 'Password';
  dynamic get passwordError => 'Wrong password';
  dynamic get disclosureMessage =>
      'This app collects location data to enable tracking even when the app is '
      'closed or not in use.';
  dynamic get acceptButton => 'Accept';
  dynamic get configurationMessage => 'Configuration updated';
}
