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

GlobalKey<ScaffoldState> fixtureScaffoldKey = GlobalKey();

// DECLARATION-ONLY STAND-INS -- repo-local declarations that build no UI, and
// third-party ones the transplant does not inline. Supertypes are mirrored so a
// widget still reads as a widget; everything else is `dynamic`, because none of it
// is measured.

class AppRoutes {
  AppRoutes._();
  static const dynamic permissions = '/permissions';
  static const dynamic homePage = '/home';
  static const dynamic pairing = '/pairing';
  static const dynamic pairingSuccess = '/pairing/success';
  static const dynamic groupsForm = '/pairing/group';
  static const dynamic contacts = '/contacts';
  static const dynamic profile = '/profile';
  static const dynamic profileCreation = '/profile/create';
  static const dynamic welcome = '/welcome';
  static const dynamic settings = '/settings';
  static const dynamic error = '/error';
  static const dynamic pairingDebug = '/pairing/debug';
}

class S {
  S();
  static dynamic get current => S();
  static const dynamic delegate = null;
  dynamic get zCOMMENT => 'English translations for PairSonic';
  dynamic get appName => 'PairSonic';
  dynamic get profile => 'Profile';
  dynamic get pair => 'Pair';
  dynamic get contacts => 'Contacts';
  dynamic get settings => 'Settings';
  dynamic get submit => 'Submit';
  dynamic get pairingFailed => 'Pairing failed';
  dynamic get pairingImportFailed => 'Could not import the received contacts';
  dynamic get cancel => 'Cancel';
  dynamic get confirm => 'Confirm';
  dynamic get save => 'Save';
  dynamic get noContacts => 'You have not added any contacts yet';
  dynamic get language => 'Language';
  dynamic get advancedSettings => 'Advanced settings';
  dynamic get advancedSettingsShow => 'Show advanced settings';
  dynamic get initDatabase => 'Initialize database';
  dynamic get createTestdata => 'Create test data';
  dynamic get initDatabaseNow => 'Initialize the database now';
  dynamic get adminSettings => 'Developer settings';
  dynamic get adminSettingsShow => 'Show developer settings';
  dynamic get name => 'Name';
  dynamic get bio => 'Bio';
  dynamic get successful => 'Successful';
  dynamic get failed => 'Failed';
  dynamic get welcome => 'Welcome';
  dynamic get welcomeScreen => 'Welcome to PairSonic';
  dynamic get welcomeText =>
      'PairSonic exchanges contact details with the people around you and '
      'verifies over sound that nobody else slipped into the group.';
  dynamic get finishedProfile => 'Your profile is ready';
  dynamic get go => 'Go';
  dynamic get enterName => 'Enter your name';
  dynamic get enterBio => 'Enter a short bio';
  dynamic get emptyName => 'Please enter a name';
  dynamic get nameHint => 'e.g. Alex Jordan';
  dynamic get labelName => 'Name';
  dynamic get emptyId => 'Please enter an ID';
  dynamic get idHint => 'e.g. alex@example.org';
  dynamic get labelId => 'ID';
  dynamic get addContact => 'Add contact';
  dynamic get continueText => 'Continue';
  dynamic get switchText => 'Switch';
  dynamic get AudioProcessingErrorMessage =>
      'The audio channel could not be processed. Please try again in a '
      'quieter place.';
  dynamic get groupPairing => 'Group pairing';
  dynamic get confirmationDialogTitle => 'Are you sure?';
  dynamic get leaveGroupPairingConfirmationDialogDescription =>
      'Leaving now cancels the group pairing for everyone taking part.';
  dynamic get leaveContactImportConfirmationDialogDescription =>
      'Leaving now discards the contacts you have not imported yet.';
  dynamic get permissionRequiredDialogTitle => 'Permission required';
  dynamic get microphonePermissionRequiredDialogDescription =>
      'PairSonic needs the microphone to receive the verification tones of '
      'the other devices.';
  dynamic get microphonePermissionRequiredPromptOpenAppSettings =>
      'Grant the microphone permission in the app settings to continue.';
  dynamic get locationPermissionRequiredDialogDescription =>
      'Android requires the location permission to discover nearby devices.';
  dynamic get locationPermissionRequiredPromptOpenAppSettings =>
      'Grant the location permission in the app settings to continue.';
  dynamic get volumeDialogTitle => 'Turn up the volume';
  dynamic get volumeDialogDescription =>
      'The verification uses sound. Please raise the media volume before you '
      'start the exchange.';
  dynamic get dialogButtonOK => 'OK';
  dynamic get dialogButtonCancel => 'Cancel';
  dynamic get dialogButtonGrant => 'Grant';
  dynamic get dialogButtonLeave => 'Leave';
  dynamic get dialogButtonStay => 'Stay';
  dynamic get dialogButtonYes => 'Yes';
  dynamic get dialogButtonNo => 'No';
  dynamic get groupPairingParticipant => 'Participant';
  dynamic get groupPairingCoordinator => 'Coordinator';
  dynamic get participantCount => 'Participants';
  dynamic get groupPairingSetupConfirm => 'Confirm';
  dynamic get groupPairingSetupBack => 'Back';
  dynamic get groupPairingSetupCancel => 'Cancel';
  dynamic get groupPairingSetupGo => 'Start exchange';
  dynamic get groupPairingSetupHintReady =>
      'Wait until everyone in the group has reached this screen.';
  dynamic get groupPairingSetupGroupSize => 'Group size';
  dynamic get groupPairingSetupParticipantCountDescription =>
      'How many people are taking part, including yourself?';
  dynamic get groupPairingSetupExchangeModeDescription =>
      'Choose how the devices should exchange the verification code.';
  dynamic get groupPairingSetupFinishTitle => 'Ready to pair';
  dynamic get groupPairingSetupFinishDescription =>
      'Hold the devices close together and keep the screen on until the '
      'exchange has finished.';
  dynamic get groupPairingStatusRunning => 'Group pairing in progress';
  dynamic get groupPairingStatus_DEVICE_INIT2 => 'Preparing the device';
  dynamic get groupPairingCloseToOther =>
      'Move closer to the other devices.';
  dynamic get groupPairingStatus_ESTABLISHING_CONNECTION =>
      'Establishing the connection';
  dynamic get groupPairingStatus_COLLECT_MATCH_REVEALS =>
      'Collecting the verification codes';
  dynamic get groupPairingStatusDecrypting => 'Decrypting the contact data';
  dynamic get groupPairingVerificationPrompt =>
      'Does every device show the same phrase?';
  dynamic get groupPairingVerificationRetransmissionButton => 'Play again';
  dynamic get groupPairingSuccessText =>
      'The exchange was successful. Select the contacts you want to keep.';
  dynamic get groupPairingSuccessSelectAll => 'Select all';
  dynamic get groupPairingSuccessUnselectAll => 'Deselect all';
  dynamic get groupPairingSuccessCancel => 'Cancel';
  dynamic get groupPairingSuccessAddContacts => 'Add contacts';
  dynamic get groupPairingSuccessNoSelectionAlertTitle => 'No contact selected';
  dynamic get groupPairingSuccessCancelAlertTitle => 'Discard the contacts?';
  dynamic get groupPairingSuccessNoSelectionAlertText =>
      'You have not selected any contact. Leaving now discards all of them.';
  dynamic get groupPairingSuccessNoSelectionAlertButtonDestructive => 'Discard';
  dynamic get groupPairingSuccessNoSelectionAlertButtonAction => 'Keep selecting';
  dynamic get groupPairingErrTimeoutName => 'Timeout';
  dynamic get groupPairingErrTimeoutDescription =>
      'Not every device answered in time. Please start the exchange again.';
  dynamic get groupPairingErrSecurityName => 'Verification failed';
  dynamic get groupPairingErrSecurityDescription =>
      'The verification codes did not match. Somebody outside the group may '
      'have taken part in the exchange.';
  dynamic get groupPairingErrUnknownName => 'Unknown error';
  dynamic get groupPairingErrUnknownDescription =>
      'The exchange stopped for an unknown reason. Please try again.';
  dynamic get groupPairingErrCentCommName => 'Connection lost';
  dynamic get groupPairingErrCentCommDescription =>
      'The connection to the coordinator was lost during the exchange.';
  dynamic get groupPairingErrWifiName => 'Wi-Fi unavailable';
  dynamic get groupPairingErrWifiDescription =>
      'Nearby devices need Wi-Fi. Please switch Wi-Fi on and try again.';
  dynamic get groupPairingSelectRole => 'Select your role';
  dynamic get groupPairingCoordinatorHelp =>
      'The coordinator starts the exchange and every other device joins it.';
  dynamic get groupPairingDeviceHelp =>
      'Join the exchange that the coordinator has started.';
  dynamic get wifiEnableDialogTitle => 'Switch Wi-Fi on';
  dynamic get wifiEnableDialogDescription =>
      'PairSonic uses Wi-Fi to reach the devices nearby.';
  dynamic get retryGroupPairing => 'Try again';
  dynamic get groupPairingPromptRetry => 'Retry';
  dynamic get groupPairingPromptCancel => 'Cancel';
  dynamic get groupPairingUseUltrasound => 'Use ultrasound';
  dynamic get groupPairingAudioChannelBackend => 'Audio channel';
  dynamic get groupPairingConnectingWithParticipants =>
      'Connecting with the participants';
  dynamic get groupPairingExchangingContactInformation =>
      'Exchanging the contact information';
  dynamic get groupPairingVerifyingSecurity => 'Verifying the security code';
  dynamic get groupPairingTimeout => 'The group pairing timed out';
  dynamic get groupPairingError => 'The group pairing failed';
  dynamic get groupPairingDone => 'Done';
  dynamic get groupPairingSuccess => 'Group pairing successful';
  dynamic get groupPairingNoInternet =>
      'No internet connection. The exchange itself works offline.';
  dynamic get groupPairingSlingerBeginExchange => 'Begin the exchange';
  dynamic get groupPairingSlingerHowManyUsers =>
      'How many people are in the group?';
  dynamic get groupPairingSlingerLowestNumber =>
      'The person with the lowest number starts.';
  dynamic get groupPairingSlingerLowest2 =>
      'Wait for the person with the lowest number.';
  dynamic get groupPairingSlingerVerificationError =>
      'The phrases did not match on every device.';
  dynamic get groupPairingSlingerSelectPhrase =>
      'Select the phrase shown on the other devices';
  dynamic get groupPairingSlingerVerificationInstructions =>
      'Compare the phrase on your screen with the one on the other screens '
      'and confirm only if all of them are identical.';
  dynamic get groupPairingSlingerVerificationNoMatch => 'No phrase matches';
  dynamic get groupPairingSlingerNext => 'Next';
  dynamic get groupPairingSlingerLowest => 'Lowest number';
  dynamic get pairingFailureModeStandard => 'Standard';
  dynamic get pairingFailureModeFailAlways => 'Always fail';
  dynamic get permissionScreenTitle => 'Permissions';
  dynamic get permissionScreenIntroText =>
      'PairSonic needs a few permissions before the first exchange.';
  dynamic get permissionScreenNameMicrophone => 'Microphone';
  dynamic get permissionScreenDescriptionMicrophone =>
      'Used to receive the verification tones of the nearby devices.';
  dynamic get permissionScreenNameNearbyDevices => 'Nearby devices';
  dynamic get permissionScreenDescriptionNearbyDevices =>
      'Used to find the other participants over Bluetooth and Wi-Fi.';
  dynamic get permissionScreenNameLocation => 'Location';
  dynamic get permissionScreenDescriptionLocation =>
      'Android requires it to scan for nearby devices. Your location is never '
      'stored or sent anywhere.';
  dynamic get permissionScreenFooterText =>
      'You can revoke every permission again in the system settings.';
  dynamic get permissionScreenButtonTextRequestPermissions =>
      'Grant permissions';
  dynamic get permissionScreenButtonTextOpenSettings => 'Open settings';
  dynamic get settingsUltrasoundMicSupportTrue =>
      'This microphone supports ultrasound';
  dynamic get settingsUltrasoundMicSupportFalse =>
      'This microphone does not support ultrasound';
  dynamic get settingsUltrasoundSpeakerSupportTrue =>
      'This speaker supports ultrasound';
  dynamic get settingsUltrasoundSpeakerSupportFalse =>
      'This speaker does not support ultrasound';
  dynamic get welcomeTitle => 'Welcome to PairSonic';
  dynamic get welcomeTextFirst =>
      'Exchange contact details with everyone around you in a single step.';
  dynamic get profileCreationTitle => 'Create your profile';
  dynamic get profileCreationHintText =>
      'This is what the other participants will see after the exchange.';
  dynamic get profileEditButtonEdit => 'Edit';
  dynamic get generalButtonNext => 'Next';
  dynamic get generalButtonDone => 'Done';
  dynamic get generalButtonBack => 'Back';
  static dynamic load(dynamic locale) => Future<S>.value(S());
  static dynamic of(dynamic context) => S();
  static dynamic maybeOf(dynamic context) => null;
  dynamic AudioInactivityMessage(dynamic duration) =>
      'No sound was received for a while. Please check the volume.';
  dynamic groupPairingVerificationPromptWithSize(dynamic size) =>
      'Do all devices in the group show the same phrase?';
  dynamic groupPairingSizeIndicator(dynamic size) => 'Group of participants';
  dynamic groupPairingCompareScreen(dynamic size) =>
      'Compare the phrase with the other devices';
  dynamic get permissionScreenLocationServiceMessage =>
      'Location services are switched off. Please switch them on to find '
      'nearby devices.';
  dynamic get alertLocationServiceTitle => 'Location services are off';
  dynamic get alertLocationServiceMessage =>
      'PairSonic cannot discover nearby devices while location services are '
      'switched off.';
  dynamic get alertLocationServiceButton => 'Open location settings';
}
