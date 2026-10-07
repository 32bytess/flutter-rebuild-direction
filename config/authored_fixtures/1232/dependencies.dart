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

TextEditingController fixtureSearchController = TextEditingController();

CoreFilterStatus? fixtureSelectedStatus = null;

// DECLARATION-ONLY STAND-INS -- repo-local declarations that build no UI, and
// third-party ones the transplant does not inline. Supertypes are mirrored so a
// widget still reads as a widget; everything else is `dynamic`, because none of it
// is measured.

extension CoreFilterStatusX on CoreFilterStatus {
  dynamic title(dynamic context) => 'Active';
}

class S {
  S();
  static dynamic get current => S();
  static const dynamic delegate = null;
  dynamic get appTitle => 'Flutter Bloc App';
  dynamic get itemsTitle => 'Items';
  dynamic get emailsTitle => 'Emails';
  dynamic get launchesTitle => 'Launches';
  dynamic get settingsTitle => 'Settings';
  dynamic get appearanceTitle => 'Appearance';
  dynamic get dynamicColorSettingsItemTitle => 'Dynamic color';
  dynamic get dynamicColorSettingsItemDescription =>
      'Use colors taken from your wallpaper';
  dynamic get darkThemeSettingsItemTitle => 'Dark theme';
  dynamic get darkThemeOnSettingsItemTitle => 'On';
  dynamic get darkThemeOffSettingsItemTitle => 'Off';
  dynamic get darkThemeFollowSystemSettingsItemTitle => 'Follow system';
  dynamic get tryAgainButton => 'Try again';
  dynamic get appearanceSettingsItem => 'Appearance';
  dynamic get appearanceSettingsItemDescription =>
      'Theme, colors and text size';
  dynamic get aboutSettingsItem => 'About';
  dynamic get aboutSettingsItemDescription =>
      'Version, licenses and credits';
  dynamic get themeTitle => 'Theme';
  dynamic get systemThemeTitle => 'System';
  dynamic get lightThemeTitle => 'Light';
  dynamic get darkThemeTitle => 'Dark';
  dynamic get lightGoldThemeTitle => 'Light gold';
  dynamic get darkGoldThemeTitle => 'Dark gold';
  dynamic get lightMintThemeTitle => 'Light mint';
  dynamic get darkMintThemeTitle => 'Dark mint';
  dynamic get experimentalThemeTitle => 'Experimental';
  dynamic get itemDetailsTitle => 'Item details';
  dynamic get error => 'Something went wrong';
  dynamic get emptyList => 'Nothing here yet';
  dynamic get tabHome => 'Home';
  dynamic get tabSettings => 'Settings';
  dynamic get newsScreen => 'News';
  dynamic get disabledButtonTitle => 'Disabled button';
  dynamic get disabledRoundedButtonTitle => 'Disabled rounded button';
  dynamic get disabledWithIconButtonTitle => 'Disabled button with icon';
  dynamic get enabledButtonTitle => 'Enabled button';
  dynamic get borderRadiusButtonTitle => 'Border radius button';
  dynamic get borderSideButtonTitle => 'Border side button';
  dynamic get iconButtonTitle => 'Icon button';
  dynamic get iconAndPaddingButtonTitle => 'Icon and padding button';
  dynamic get transparentButtonTitle => 'Transparent button';
  dynamic get missionTimeline => 'Mission timeline';
  dynamic get staticFireTest => 'Static fire test';
  dynamic get launch => 'Launch';
  dynamic get missionSuccess => 'Mission success';
  dynamic get objectivesCompleted => 'Objectives completed';
  dynamic get missionSuccessful => 'Mission successful';
  dynamic get missionFailed => 'Mission failed';
  dynamic get allObjectivesCompleted => 'All objectives completed';
  dynamic get objectivesNotMet => 'Objectives not met';
  dynamic get rocketTitle => 'Rocket';
  dynamic get payload => 'Payload';
  dynamic get orbit => 'Orbit';
  dynamic get rocketDetails => 'Rocket details';
  dynamic get rocketName => 'Rocket name';
  dynamic get rocketType => 'Rocket type';
  dynamic get rocketBlock => 'Block';
  dynamic get firstStage => 'First stage';
  dynamic get coreSerial => 'Core serial';
  dynamic get flight => 'Flight';
  dynamic get landing => 'Landing';
  dynamic get landingSuccess => 'Landing success';
  dynamic get gridFins => 'Grid fins';
  dynamic get landingLegs => 'Landing legs';
  dynamic get reused => 'Reused';
  dynamic get notAvailable => 'Not available';
  dynamic get recoveryShips => 'Recovery ships';
  dynamic get payloadTitle => 'Payload';
  dynamic get id => 'ID';
  dynamic get type => 'Type';
  dynamic get mass => 'Mass';
  dynamic get manufacturer => 'Manufacturer';
  dynamic get nationality => 'Nationality';
  dynamic get customers => 'Customers';
  dynamic get missionOverview => 'Mission overview';
  dynamic get noDetails => 'No details available';
  dynamic get linksResources => 'Links and resources';
  dynamic get watchVideo => 'Watch video';
  dynamic get wikipedia => 'Wikipedia';
  dynamic get article => 'Article';
  dynamic get reddit => 'Reddit';
  dynamic get pressKit => 'Press kit';
  dynamic get launchSite => 'Launch site';
  dynamic get siteIdLabel => 'Site ID';
  dynamic get rocketsTab => 'Rockets';
  dynamic get activeStatus => 'Active';
  dynamic get retiredStatus => 'Retired';
  dynamic get rocketsTitle => 'Rockets';
  dynamic get core_status_active => 'Active';
  dynamic get core_status_lost => 'Lost';
  dynamic get core_status_inactive => 'Inactive';
  dynamic get core_status_unknown => 'Unknown';
  dynamic get errorLoadingCores => 'Could not load cores';
  dynamic get retry => 'Retry';
  dynamic get firstLaunch => 'First launch';
  dynamic get unknown => 'Unknown';
  dynamic get na => 'N/A';
  dynamic get core_filter_status_all => 'All';
  dynamic get core_filter_status_active => 'Active';
  dynamic get core_filter_status_lost => 'Lost';
  dynamic get core_filter_status_inactive => 'Inactive';
  dynamic get core_filter_status_unknown => 'Unknown';
  dynamic get core_filter_search_hint => 'Search cores by serial';
  dynamic get spaceXCoresTitle => 'SpaceX cores';
  dynamic get coresLabel => 'Cores';
  static dynamic load(dynamic locale) => Future<S>.value(S());
  static dynamic of(dynamic context) => S();
  static dynamic maybeOf(dynamic context) => null;
  dynamic itemTitle(dynamic id) => '';
  dynamic missionTitle(dynamic mission) => '';
  dynamic launchedAt(dynamic launchedAt) => '';
  dynamic rocket(dynamic rocketName, dynamic rocketType) => '';
  dynamic daysSinceTodayTitle(dynamic days) => '';
  dynamic daysFromTodayTitle(dynamic days) => '';
  dynamic flightNumber(dynamic number) => '';
  dynamic successRate(dynamic percentage) => '';
  dynamic missions(dynamic count) => '';
  dynamic reuses(dynamic count) => '';
  dynamic noCoresFound(dynamic query) => '';
  dynamic blockLabel(dynamic blockNumber) => '';
  dynamic get overview => 'Overview';
  dynamic get specifications => 'Specifications';
  dynamic get payloadCapacity => 'Payload capacity';
  dynamic get engineDetails => 'Engine details';
  dynamic get heightLabel => 'Height';
  dynamic get diameterLabel => 'Diameter';
  dynamic get massLabel => 'Mass';
  dynamic get stagesLabel => 'Stages';
  dynamic get typeLabel => 'Type';
  dynamic get versionLabel => 'Version';
  dynamic get numberLabel => 'Number';
  dynamic get propellant1Label => 'Propellant 1';
  dynamic get propellant2Label => 'Propellant 2';
  dynamic get thrustSeaLevelLabel => 'Thrust (sea level)';
  dynamic get tons => 'tons';
}
