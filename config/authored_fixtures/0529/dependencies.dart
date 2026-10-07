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

TextEditingController fixturePasswordController = TextEditingController();

// DECLARATION-ONLY STAND-INS -- repo-local declarations that build no UI, and
// third-party ones the transplant does not inline. Supertypes are mirrored so a
// widget still reads as a widget; everything else is `dynamic`, because none of it
// is measured.

class AllpassColorUI {
  AllpassColorUI._();
  static dynamic get allColor => const <Color>[
    Color.fromRGBO(8, 200, 224, 1),
    Color.fromRGBO(72, 120, 240, 1),
    Colors.amber,
    Colors.deepOrangeAccent,
    Colors.teal,
    Color.fromRGBO(52, 184, 105, 1),
    Color.fromRGBO(255, 86, 85, 1),
    Color.fromRGBO(121, 75, 115, 1),
  ];
  static dynamic get allGradients => const <Gradient>[
    LinearGradient(
      colors: [Color(0xFFa3bded), Color(0xFF6991c7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF74ebd5), Color(0xFF9face6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFe0c3fc), Color(0xFF8ec5fc)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF0ba360), Color(0xFF3cba92)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF6a85b6), Color(0xFFbac8e0)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF13547a), Color(0xFF80d0c7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFff758c), Color(0xFFff7eb3)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFc79081), Color(0xFFdfa579)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFdcb0ed), Color(0xFF99c99c)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF96deda), Color(0xFF50c9c3)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];
}

// The upstream insets are `AllpassScreenUtil.setWidth/setHeight` calls against a
// designSize of 1080x1920; the values below are those calls resolved once, for a
// 360x800 logical viewport (setWidth = n / 3, setHeight = n / 2.4), so the fixture
// carries a fixed number rather than a device-dependent one.
class AllpassEdgeInsets {
  AllpassEdgeInsets._();
  static dynamic get listInset =>
      const EdgeInsets.only(left: 10.0, right: 10.0);
  static set listInset(dynamic _) {}
  static dynamic get dividerInset =>
      const EdgeInsets.only(left: 23.33, right: 23.33);
  static set dividerInset(dynamic _) {}
  static dynamic get forViewCardInset => const EdgeInsets.only(
    left: 23.33,
    right: 23.33,
    top: 10.42,
    bottom: 10.42,
  );
  static set forViewCardInset(dynamic _) {}
  static dynamic get forCardInset =>
      const EdgeInsets.only(left: 10.0, right: 10.0, top: 6.25, bottom: 10.42);
  static set forCardInset(dynamic _) {}
  static dynamic get settingCardInset =>
      const EdgeInsets.symmetric(vertical: 8.33, horizontal: 16.67);
  static set settingCardInset(dynamic _) {}
  static dynamic get forSearchButtonInset =>
      const EdgeInsets.only(left: 16.67, right: 16.67, bottom: 6.25);
  static set forSearchButtonInset(dynamic _) {}
  static dynamic get smallTBPadding =>
      const EdgeInsets.only(top: 10.42, bottom: 10.42);
  static set smallTBPadding(dynamic _) {}
  static dynamic get smallLPadding => const EdgeInsets.only(left: 16.67);
  static set smallLPadding(dynamic _) {}
  static dynamic get smallRPadding => const EdgeInsets.only(right: 16.67);
  static set smallRPadding(dynamic _) {}
  static dynamic get smallTopInsets => const EdgeInsets.only(top: 6.25);
  static set smallTopInsets(dynamic _) {}
  static dynamic get bottom10Inset =>
      const EdgeInsets.only(left: 33.33, right: 33.33, bottom: 4.17);
  static set bottom10Inset(dynamic _) {}
  static dynamic get bottom30Inset =>
      const EdgeInsets.only(left: 33.33, right: 33.33, bottom: 12.5);
  static set bottom30Inset(dynamic _) {}
  static dynamic get bottom50Inset =>
      const EdgeInsets.only(left: 33.33, right: 33.33, bottom: 20.83);
  static set bottom50Inset(dynamic _) {}
  static dynamic get widgetItemInset =>
      const EdgeInsets.symmetric(horizontal: 17.5);
  static set widgetItemInset(dynamic _) {}
}

class AllpassTextUI {
  AllpassTextUI._();
  static dynamic get titleBarStyle => const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.02,
  );
  static dynamic get firstTitleStyle => const TextStyle(fontSize: 16);
  static dynamic get secondTitleStyle => const TextStyle(fontSize: 14);
  static dynamic get smallTextStyle => const TextStyle(fontSize: 12);
  static dynamic get hintTextStyle =>
      const TextStyle(fontSize: 16, color: Color(0xFF424242));
  static dynamic get settingTrailing =>
      const TextStyle(fontSize: 12, color: Colors.grey);
}

extension L10nSupport on BuildContext {
  dynamic get l10n => const AppLocalizations('en');
}

class ThemeProvider extends ChangeNotifier {
  ThemeProvider();
  dynamic get appTheme => const _Stub();
  dynamic get specialBackgroundColor => const Color.fromRGBO(245, 246, 250, 1);
  set specialBackgroundColor(dynamic _) {}
  dynamic get offstageColor => Colors.black87;
  set offstageColor(dynamic _) {}
  dynamic init() => const _Stub();
  void changeThemeMode(dynamic targetMode, dynamic platformBrightness) {}
  void changePrimaryColor(dynamic color, dynamic platformBrightness) {}
  void setExtraColor(dynamic platformBrightness) {}
  dynamic get lightTheme => const _Stub();
  set lightTheme(dynamic _) {}
  dynamic get darkTheme => const _Stub();
  set darkTheme(dynamic _) {}
  dynamic get themeMode => const _Stub();
  set themeMode(dynamic _) {}
  dynamic get successContentColor => const Color(0xFF3B7055);
  set successContentColor(dynamic _) {}
  dynamic get successBackgroundColor => const Color(0xFFEDFBF3);
  set successBackgroundColor(dynamic _) {}
  dynamic get infoContentColor => const Color(0xFF307185);
  set infoContentColor(dynamic _) {}
  dynamic get infoBackgroundColor => const Color(0xFFF1FBFE);
  set infoBackgroundColor(dynamic _) {}
  dynamic get warningContentColor => const Color(0xFF81642E);
  set warningContentColor(dynamic _) {}
  dynamic get waringBackgroundColor => const Color(0xFFFFF9EC);
  set waringBackgroundColor(dynamic _) {}
  dynamic get errorContentColor => const Color(0xFFAC2F52);
  set errorContentColor(dynamic _) {}
  dynamic get errorBackgroundColor => const Color(0xFFFFF1F6);
  set errorBackgroundColor(dynamic _) {}
  dynamic get iconColor => const Color(0xFF81879F);
  set iconColor(dynamic _) {}
}

// One instance for the whole group, the way `context.watch` hands back the
// provider already mounted above the widget rather than building a new one.
final ThemeProvider _themeProviderStandIn = ThemeProvider();

extension WatchContext on BuildContext {
  dynamic watch<T>() => _themeProviderStandIn;
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

class Config {
  Config._();
  static dynamic get password => 'U2FsdGVkX1+8kQ0rTfEwZmJhNzM5ZDQ2';
  static set password(dynamic _) {}
  static dynamic get enabledBiometrics => false;
  static set enabledBiometrics(dynamic _) {}
  static dynamic get longPressCopy => false;
  static set longPressCopy(dynamic _) {}
  static dynamic get primaryColor => const _Stub();
  static set primaryColor(dynamic _) {}
  static dynamic get themeMode => const _Stub();
  static set themeMode(dynamic _) {}
  static dynamic get webDavAuthSuccess => false;
  static set webDavAuthSuccess(dynamic _) {}
  static dynamic get webDavUrl => null;
  static set webDavUrl(dynamic _) {}
  static dynamic get webDavUsername => null;
  static set webDavUsername(dynamic _) {}
  static dynamic get webDavPassword => null;
  static set webDavPassword(dynamic _) {}
  static dynamic get webDavEncryptLevel => const _Stub();
  static set webDavEncryptLevel(dynamic _) {}
  static dynamic get webDavMergeMethod => const _Stub();
  static set webDavMergeMethod(dynamic _) {}
  static dynamic get webDavBackupDirectory => '/Allpass';
  static set webDavBackupDirectory(dynamic _) {}
  static dynamic get webDavUploadTime => null;
  static set webDavUploadTime(dynamic _) {}
  static dynamic get webDavDownloadTime => null;
  static set webDavDownloadTime(dynamic _) {}
  static dynamic get webDavBackupMethod => const _Stub();
  static set webDavBackupMethod(dynamic _) {}
  static dynamic get webDavBackupFilename => null;
  static set webDavBackupFilename(dynamic _) {}
  static dynamic get timingInMainPassword => const _Stub();
  static set timingInMainPassword(dynamic _) {}
  static void initConfig() {}
  static void configClear() {}
  static void updateLatestUsePasswordTime() {}
  static void setPassword(dynamic encryptedValue) {}
  static void setEnabledBiometrics(dynamic value) {}
  static void setLongPressCopy(dynamic value) {}
  static void setPrimaryColor(dynamic color) {}
  static void setThemeMode(dynamic mode) {}
  static void setWebDavAuthSuccess(dynamic value) {}
  static void setWebDavUrl(dynamic value) {}
  static void setWebDavUsername(dynamic value) {}
  static void setWebDavPassword(dynamic encryptedValue) {}
  static void setWevDavEncryptLevel(dynamic level) {}
  static void setWebDavMergeMethod(dynamic method) {}
  static void setWebDavBackupDirectory(dynamic directory) {}
  static void setWebDavUploadTime(dynamic value) {}
  static void setWebDavDownloadTime(dynamic value) {}
  static void setWebDavBackupMethod(dynamic method) {}
  static void setWebDavCustomBackupFilename(dynamic filename) {}
  static void setTimingInMainPassDays(dynamic value) {}
  static dynamic get autoLock => const _Stub();
  static set autoLock(dynamic _) {}
  static void setAutoLock(dynamic value) {}
  static dynamic get hasLockManually => false;
  static set hasLockManually(dynamic _) {}
  static dynamic allowUseAuthLogin() => false;
  static dynamic isPasswordCorrect(dynamic password) => false;
  static void setHasLockManually(dynamic value) {}
}

// Upstream this switches the timing enum to its localised label. `Config`'s
// default is `InputMainPasswordTimingEnum.tenDays`, so that is the label here.
extension InputMainPasswordTimingExt on dynamic {
  dynamic l10n(dynamic context) => '10 Days';
}

class AppLocalizations {
  const AppLocalizations(dynamic locale);
  dynamic get localeName => 'en';
  static const dynamic delegate = null;
  static const dynamic localizationsDelegates = null;
  static const dynamic supportedLocales = null;
  dynamic get allpass => 'Allpass';
  dynamic get appError => 'Occurs error';
  dynamic get appErrorHint1 =>
      'App occurs unexpected error, please report to author';
  dynamic get appErrorHint2 =>
      'Please see below for the error message. Kindly take a screenshot and send it to the email address sys6511@126.com.';
  dynamic get enabled => 'Enabled';
  dynamic get disabled => 'Disabled';
  dynamic get unlock => 'Unlock';
  dynamic get unlockAllpass => 'Unlock Allpass';
  dynamic get pleaseInputMainPassword => 'Please input master password';
  dynamic get useBiometrics => 'Use Biometrics to unlock';
  dynamic get notEnableBiometricsYet =>
      'You have not yet enabled biometric recognition';
  dynamic get errorExceedThreshold =>
      'Locked for 30 seconds due to five consecutive errors';
  dynamic get clickToUseBiometrics =>
      'To unlock using biometrics, simply tap here';
  dynamic get usePassword => 'Use password to unlock';
  dynamic get inputMainPasswordTimingHint =>
      'To ensure you don\'t forget your master password, Allpass will periodically prompt you to enter it';
  dynamic get verificationSuccess => 'Verification successful';
  dynamic get mainPasswordErrorHint =>
      'It seems like you may have forgotten your master password';
  dynamic get biometricsRecognizedFailed =>
      'Recognition failed, please try again';
  dynamic get pleaseInputMainPasswordFirst =>
      'Please input master password first';
  dynamic get unlockSuccess => 'Unlock successfully';
  dynamic get notSetupYet =>
      'Allpass has not been set up yet, please set it up first';
  dynamic get appHasForceLock =>
      'Allpass has been locked, please use password to unlock';
  dynamic get setupAllpass => 'Setup Allpass';
  dynamic get pleaseInputAgain => 'Please input again';
  dynamic get setup => 'Setup';
  dynamic get passwordNotSame => 'The two passwords are not the same';
  dynamic get passwordTooShort => 'Main password length must be greater than 6';
  dynamic get setupSuccess => 'Setup successfully';
  dynamic get alreadySetup => 'Already setup, only allow to setup once';
  dynamic get serviceTerms => 'Service Terms';
  dynamic get confirmServiceTerms => 'Agree and continue';
  dynamic get cancel => 'Cancel';
  dynamic get password => 'Password';
  dynamic get passwords => 'passwords';
  dynamic get addPasswordItem => 'Add Password Item';
  dynamic get passwordEmptyHint =>
      'Here stores your password information, such as\nGoogle account, Twitter account, etc.';
  dynamic get selectOnePasswordAtLeast =>
      'Please select at least one password item';
  dynamic get confirmDelete => 'Confirm Delete';
  dynamic get emptyDataHint => 'Oops, it seems like there\'s nothing here!';
  dynamic get delete => 'Delete';
  dynamic get move => 'Move';
  dynamic get card => 'Card';
  dynamic get cards => 'cards';
  dynamic get addCardItem => 'Add Card Item';
  dynamic get cardEmptyHint =>
      'This is where your card information such as ID cards, bank cards, or VIP cards are stored.';
  dynamic get selectOneCardAtLeast => 'Please select at least one card item';
  dynamic get unknownErrorOccur => 'An error has occurred.';
  dynamic get account => 'Account';
  dynamic get copy => 'Copy';
  dynamic get accountCopied => 'Account has been copied to clipboard';
  dynamic get passwordCopied => 'Password has been copied to clipboard';
  dynamic get url => 'Link';
  dynamic get urlCopied => 'Link has been copied to clipboard';
  dynamic get ownerApp => 'Belongs to app';
  dynamic get openAppFailed =>
      'Failed to open app, please ensure that the app is installed';
  dynamic get notes => 'Notes';
  dynamic get emptyNotes => 'No notes';
  dynamic get label => 'tag';
  dynamic get labels => 'Tags';
  dynamic get accountPasswordCopied =>
      'Account and Password has been copied to clipboard';
  dynamic get deletePasswordWaring =>
      'You are about to permanently delete this password item. continue to delete?';
  dynamic get deleteSuccess => 'Delete Successfully';
  dynamic get viewPassword => 'Password Detail';
  dynamic get emptyLabel => 'No tags';
  dynamic get none => 'None';
  dynamic get viewCard => 'Card Detail';
  dynamic get ownerName => 'Owner Name';
  dynamic get nameCopied => 'Name has been copied to clipboard';
  dynamic get cardId => 'Card Number';
  dynamic get cardIdCopied => 'Card number has been copied to clipboard';
  dynamic get phoneNumber => 'Phone Number';
  dynamic get phoneNumberCopied => 'Phone number has been copied to clipboard';
  dynamic get deleteCardWarning =>
      'You are about to permanently delete this card item. continue to delete?';
  dynamic get createPassword => 'Create Password';
  dynamic get updatePassword => 'Edit Password';
  dynamic get createSuccess => 'Create successfully';
  dynamic get updateSuccess => 'Update successfully';
  dynamic get upsertPasswordRule =>
      'Name, Account and Password can\'t be empty';
  dynamic get name => 'Name';
  dynamic get folder => 'folder';
  dynamic get folderTitle => 'Folder';
  dynamic get setToNone => 'Set to none';
  dynamic get addNotes => 'Add notes';
  dynamic get passwordGenerator => 'Password Generator';
  dynamic get symbols => 'Symbols';
  dynamic get generate => 'Generate';
  dynamic get pleaseSelectOneItemAtLeast => 'Please select one item at least';
  dynamic get close => 'Close';
  dynamic get createCard => 'Create Card';
  dynamic get updateCard => 'Update Card';
  dynamic get cardPasswordEmptyAutoGen =>
      'No password entered, automatically initialized as 00000';
  dynamic get upsertCardRule => 'Owner Name and Card Number can\'t be empty';
  dynamic get settings => 'Settings';
  dynamic get mainPasswordManager => 'Primary account management';
  dynamic get biometricAuthentication => 'Biometric authentication';
  dynamic get enableBiometricSuccess =>
      'Enable biometric authentication successfully';
  dynamic get disableBiometricSuccess =>
      'Disable biometric authentication successfully';
  dynamic get biometricNotAvailable =>
      'Biometric recognition is unavailable, please go to system settings to enable it and retry';
  dynamic get authorizationFailed => 'Authorization failed';
  dynamic get biometricNotSupport => 'Your device not support biometric';
  dynamic get autoLock => 'Auto-lock';
  dynamic get autoLockImmediate => 'Immediately';
  dynamic get autoLock30s => 'In 30s';
  dynamic get autoLockDisable => 'Disabled';
  dynamic get longPressToCopy => 'Long Press to Copy';
  dynamic get appTheme => 'App Theme';
  dynamic get labelManager => 'Tag Management';
  dynamic get folderManager => 'Folder Management';
  dynamic get webDavSync => 'WebDAV Sync';
  dynamic get importExport => 'Import/Export';
  dynamic get autofill => 'Autofill Service';
  dynamic get shareToFriends => 'Share Allpass';
  dynamic get feedback => 'Feedback';
  dynamic get checkUpdate => 'Check Update';
  dynamic get about => 'About';
  dynamic get shareAllpassSubject => 'Software recommendation - Allpass';
  dynamic get pleaseSelect => 'Please Select an Item';
  dynamic get authorizeToUnlock => 'Authorize to unlock Allpass';
  dynamic get gotoSettings => 'Go to Settings';
  dynamic get iosGoToSettingsDescFace =>
      'Face ID is currently disabled. Please go to settings to enable Face ID and try again';
  dynamic get iosGoToSettingsDescFingerprint =>
      'Fingerprint unlock is currently disabled. Please go to settings to enable fingerprint unlock and try again';
  dynamic get iosGoToSettingsDescIris =>
      'Biometric recognition is currently disabled. Please go to settings to enable it and try again';
  dynamic get iosGoToSettingsDescDefault =>
      'Biometric authorization is currently disabled. Please go to settings to enable Touch ID or Face ID and try again';
  dynamic get iosLogoutFace =>
      'Face ID has been disabled. Please lock and unlock your device to enable Face ID';
  dynamic get iosLogoutFingerprint =>
      'Touch ID has been disabled. Please lock and unlock your device to enable Touch ID';
  dynamic get iosLogoutIris =>
      'Biometric recognition has been disabled. Please lock and unlock your device to enable biometric recognition';
  dynamic get androidGoToSettingsDesc =>
      'Fingerprint unlock is currently disabled. Please go to settings to enable it and try again';
  dynamic get biometricRequiredTitle =>
      'Biometric recognition is not enabled yet';
  dynamic get signInTitle => 'Please verify';
  dynamic get biometricHint => 'Use fingerprint to unlock';
  dynamic get modifyMainPassword => 'Modify master password';
  dynamic get inputMainPasswordTiming => 'Regularly require master password';
  dynamic get secretKeyUpdate => 'Update encrypt secret key';
  dynamic get clearAllData => 'Clear all data';
  dynamic get lockAllpass => 'Lock Allpass';
  dynamic get never => 'Never';
  dynamic get sevenDays => '7 Days';
  dynamic get tenDays => '10 Days';
  dynamic get fifteenDays => '15 Days';
  dynamic get thirtyDays => '30 Days';
  dynamic get confirmSelect => 'Confirm Select';
  dynamic get selectNeverWarning =>
      'After selecting this option, Allpass will no longer regularly ask you to enter the master password. Please keep your master password safe';
  dynamic get confirmClearAll => 'Confirm Clear';
  dynamic get clearAllWaring =>
      'This operation will clear all App data and can\'t rollback, continue?';
  dynamic get clearAllSuccess => 'Clear all data successfully';
  dynamic get mainPasswordIncorrect => 'Master password is incorrect';
  dynamic get oldPassword => 'Original Password';
  dynamic get newPassword => 'New Password';
  dynamic get pleaseInputOldPassword => 'Please input original password';
  dynamic get pleaseInputNewPassword => 'Please input new password';
  dynamic get modifySuccess => 'Modify successfully';
  dynamic get modifyPasswordFail =>
      'Password is less than 6 characters or the two password entries do not match';
  dynamic get oldPasswordIncorrect =>
      'The entered original password is incorrect!';
  dynamic get secretKeyUpdateHelp1 => 'Please read carefully';
  dynamic get secretKeyUpdateHelp2 =>
      'Allpass 1.5.0 and later versions use a new key storage method';
  dynamic get secretKeyUpdateHelp3 =>
      'Allpass will generate a unique key for each user and store it in a system-specific area. This means that even if Allpass is decompiled and the data in the database is obtained through some means, it cannot be easily decrypted';
  dynamic get secretKeyUpdateHelp4 =>
      'After upgrading, all password encryption and decryption will rely on the newly generated key. Please ';
  dynamic get secretKeyUpdateHelp5 => 'keep the newly generated key safe';
  dynamic get secretKeyUpdateHelp6 =>
      'If you have enabled WebDAV synchronization, your data can still be accessed using the encryption key, even if you uninstall Allpass and the backup files are encrypted';
  dynamic get secretKeyUpdateHelp7 =>
      'The time required for the upgrade is relatively short, and may vary depending on the device';
  dynamic get secretKeyUpdateHelp8 =>
      'Please do not exit the program during the upgrade process, as this may cause data loss!';
  dynamic get secretKeyUpdateHelp9 =>
      '***************** ATTENTION *****************';
  dynamic get secretKeyUpdateHelp10 =>
      'If you have used Allpass for WebDAV backup, and the \'Encrypt level\' is not the \'Not encrypted\', the old backup files will ';
  dynamic get secretKeyUpdateHelp11 => 'no longer ';
  dynamic get secretKeyUpdateHelp12 =>
      'be usable after the encryption key updated. (Local data will not be affected)';
  dynamic get secretKeyUpdateHelp13 =>
      'For the sake of data security, we still recommend backing up your data by \'Export to CSV File\' function before upgrading!';
  dynamic get secretKeyUpdateHelp14 =>
      'You can directly edit the input box below and manually input a custom key (32 characters)';
  dynamic get secretKeyUpdateHint => 'The generated key is displayed here';
  dynamic get generateSecretKey => 'Generate';
  dynamic get generateSecretKeyDone =>
      'Generation complete, please keep the new key safe (long press to copy)';
  dynamic get startUpgrade => 'Start Upgrade';
  dynamic get upgradeDone => 'Upgrade complete';
  dynamic get pleaseGenerateKeyFirst => 'Please generate a key first';
  dynamic get secretKeyLengthRequire => 'The key length must be 32 characters';
  dynamic get feedbackPlaceholder => 'Tell us what you think';
  dynamic get feedbackContact =>
      'Please enter your contact information (optional)';
  dynamic get submit => 'Submit';
  dynamic get submitting => 'Submitting, please wait';
  dynamic get feedbackContentEmptyWarning => 'Please input your feedback';
  dynamic get feedbackContentTooLong =>
      'The feedback content must be less than 1000 characters!';
  dynamic get updateContent => 'Update Log: ';
  dynamic get recentlyUpdateContent => 'Recent update log: ';
  dynamic get networkErrorHelp =>
      'An error has occurred due to network issues. If you have confirmed that your network is not the problem, then it may be due to the following reasons:\n';
  dynamic get unknownErrorHelp =>
      'An error has occurred during the check process! Below is the error message, please take a screenshot and send it to sys6511@126.com\n';
  dynamic get downloadUpdate => 'Download Update';
  dynamic get remindMeLatter => 'Remind me later';
  dynamic get confirm => 'Confirm';
  dynamic get themeSystem => 'System';
  dynamic get themeLight => 'Light';
  dynamic get themeDark => 'Dark';
  dynamic get themeColorBlue => 'Blue';
  dynamic get themeColorRed => 'Red';
  dynamic get themeColorTeal => 'Teal';
  dynamic get themeColorDeepPurple => 'Deep Purple';
  dynamic get themeColorOrange => 'Orange';
  dynamic get themeColorPink => 'Pink';
  dynamic get themeColorBlueGrey => 'Blue Grey';
  dynamic get selectExportType => 'Select Export Type';
  dynamic get exportConfirm => 'Confirm Export';
  dynamic get exportPasswordConfirmWarning =>
      'The exported password will be displayed in plain text. Please keep it secure';
  dynamic get exportCardConfirmWarning =>
      'The exported card items will be displayed in plain text. Please keep it secure';
  dynamic get passwordAndCard => 'Both Password and Card';
  dynamic get exportAllConfirmWarning =>
      'The exported data will be displayed in plain text. Please keep it secure';
  dynamic get importFromChrome => 'Import from Chrome';
  dynamic get importFromCsv => 'Import from CSV File';
  dynamic get importFromClipboard => 'Import from Clipboard';
  dynamic get exportToCsv => 'Export to CSV File';
  dynamic get selectImportType => 'Select Import Type';
  dynamic get importFailedNotCsv =>
      'Import failed, please make sure the CSV file is exported by Allpass';
  dynamic get importCanceled => 'Import canceled';
  dynamic get importFromClipboardHelp1 =>
      'This feature helps you easily import passwords previously saved in Notepad to Allpass;\n';
  dynamic get importFromClipboardHelp2 =>
      'The name is a mnemonic for the password item, you can give it any name you like to help you identify what this record is about;\n';
  dynamic get importFromClipboardHelp3 =>
      'The account is the username used for login, which may be a phone number, email, or other account you have set up;\n';
  dynamic get importFromClipboardHelp4 =>
      'The website address can help Allpass correctly fill in your password on the website, usually the URL address of the website login page;\n';
  dynamic get importFromClipboardHelp5 =>
      'Please use a \'space\' as the separator between the two fields, so that Allpass can correctly distinguish which one is the username and which one is the password;\n';
  dynamic get importFromClipboardHelp6 =>
      'If you have selected the last two import format, please enter the uniform username. If there are multiple usernames, they can be imported in several times';
  dynamic get importFromClipboardSelectFormat =>
      'Please select import password item format(use \'space\' as the separator)';
  dynamic get importFromClipboardFormat1 => 'Name Account Password WebUrl/Link';
  dynamic get importFromClipboardFormat2 => 'Name Account Password';
  dynamic get importFromClipboardFormat3 => 'Account Password WebUrl/Link';
  dynamic get importFromClipboardFormat4 => 'Account Password';
  dynamic get importFromClipboardFormat5 => 'Name Password';
  dynamic get importFromClipboardFormat6 => 'Password';
  dynamic get importFromClipboardFormatHint =>
      'Please input account(username) here';
  dynamic get importFromClipboardFormatHint2 =>
      'Please input account(username)';
  dynamic get importFromClipboardFormatHint3 => 'Please input records';
  dynamic get pasteDataHere => 'Paste your data here';
  dynamic get startImport => 'Start import';
  dynamic get importing => 'Importing, please wait';
  dynamic get importComplete => 'Import completed';
  dynamic get importFromExternalPreview => 'Imports Preview';
  dynamic get importFromExternalTips => 'Slide to delete item';
  dynamic get confirmImport => 'Continue import';
  dynamic get folderDisallowModify => 'This folded is not allowed to modify';
  dynamic get deleteLabelWarning =>
      'Passwords or cards associated with this tag will also delete this tag, continue to delete?';
  dynamic get deleteFolderWarning =>
      'This operation will move all passwords and cards in this folder to the \'Default\' folder, continue to delete?';
  dynamic get categoryNameNotValid =>
      'input content is not valid, can\'t contains \',\' \'~\' or \'space\'';
  dynamic get categoryNameNotAllowEmpty => 'input content is not valid';
  dynamic get autofillEnableAllpass =>
      'Allpass is already your autofill service';
  dynamic get autofillDisableAllpass =>
      'Allpass is not your autofill service yet';
  dynamic get autofillHelp =>
      'When you enter a password in the application, the autofill service will automatically provide possible password item matching options for you to choose from. Stored password items will be considered as candidates when they meet one of the following conditions:\n\n1. The password item belongs to an app that matches the current app;\n2. The name of the password item matches the current app name;\n\nIf you find that the autofill result is not accurate, you can modify the owner app of the password item on the password editing page to help the autofill function match the password more accurately.';
  dynamic get uploadToRemote => 'Sync to server';
  dynamic get recoverToLocal => 'Restore to local';
  dynamic get remoteBackupDirectory => 'Cloud backup directory';
  dynamic get backupFileMethod => 'Backup file method';
  dynamic get dataMergeMethod => 'Data recovery method';
  dynamic get encryptLevel => 'Encryption Level';
  dynamic get logoutAccount => 'Logout';
  // Not an upstream key: earlier revisions in this group reach `l10n.logout`,
  // which the application answered from the same string.
  dynamic get logout => 'Logout';
  dynamic get confirmUpload => 'Confirm Upload';
  dynamic get uploading =>
      'Uploading, please wait and try again when it\'s complete';
  dynamic get confirmRecover => 'Confirm Restore';
  dynamic get recovering =>
      'Restoring, please wait and try again when it\'s complete';
  dynamic get pleaseInputCustomSecretKey =>
      'Please input custom secret key(32 characters)';
  dynamic get inputCustomSecretKeyHelp =>
      'The secret key used for the backup file is not the same as the current key. Please either use another backup file or use the custom secret key';
  dynamic get pleaseInputBackupDirectory =>
      'Please enter the backup directory path';
  dynamic get encryptHelp1 =>
      'The encryption level refers to the encryption method used for files backed up to WebDAV. For old backup files (generated by Allpass versions 1.7.0 or earlier), please ensure that the encryption level used for upload and recovery is the same\n';
  dynamic get encryptHelp2 => 'Not encrypted: ';
  dynamic get encryptHelp3 =>
      'Data is backed up in plaintext, with password fields visible; this is the least secure but most universal method, as backup files can be opened directly to view passwords\n';
  dynamic get encryptHelp4 => 'Only password: ';
  dynamic get encryptHelp5 =>
      'The default option is to only encrypt the \'password\' field in password and card records, while fields such as name, username, and tags are not encrypted\n';
  dynamic get encryptHelp6 => 'All encrypted: ';
  dynamic get encryptHelp7 =>
      'All fields are encrypted, and the encrypted data is completely unreadable. This is the most secure option, but if the encryption key is lost, it may be impossible to recover the file\n';
  dynamic get encryptHelp8 =>
      'The last two encryption level strictly rely on the encryption key used by the Allpass application on the device. If the key is lost, the data will be unrecoverable after uninstallation or data deletion!!!';
  dynamic get confirmLogout => 'Confirm Logout';
  dynamic get confirmLogoutWaring =>
      'After logging out, you will need to log in again and all configuration information will be cleared, continue to logout?';
  dynamic get decryptBackupError => 'Failed to decrypt backup file';
  dynamic get syncAuthFailed =>
      'Account permission expired, please check your network or log out and reconfigure';
  dynamic get syncing => 'Syncing, please wait';
  dynamic get webdavConfig => 'WebDAV Config';
  dynamic get port => 'Port number';
  dynamic get webdavServerUrl => 'WebDAV server url';
  dynamic get webdavServerUrlHint => 'Please start with http:// or https://';
  dynamic get webdavServerUrlRequire =>
      'Server url must start with http:// or https://';
  dynamic get webdavPortRequire => 'WebDAV port must be a number';
  dynamic get webdavLoginSuccess => 'Login successfully';
  dynamic get webdavLoginFailed => 'Login failed, please try again';
  dynamic get nextStep => 'Next';
  dynamic get inConfiguration => 'In configuration';
  dynamic get webdavHelp1 =>
      'This feature allows you to back up your data to a WebDAV server or recover your data\n';
  dynamic get webdavHelp2 =>
      'The WebDAV server address should start with http:// or https://, such as the address for Dropbox (click to copy):';
  dynamic get webdavHelp3 =>
      'Port number represents the port where the service is located. If you are not sure, please do not edit.';
  dynamic get webdavExample => 'https://dav.dropdav.com/';
  dynamic get copySuccess => 'Copy successfully';
  dynamic get clickToViewAndEditConfig => 'Click to review or edit config';
  dynamic get help => 'Help';
  dynamic get modifyBackupFilename => 'Modify backup filename';
  dynamic get passwordBackupFilename => 'Passwords backup filename';
  dynamic get cardBackupFilename => 'Cards backup filename';
  dynamic get extraBackupFilename => 'Tag and folder backup filename';
  dynamic get filenameNotAllowSame => 'Filename can\'t be same';
  dynamic get filenameNotAllowEmpty => 'Filename can\'t be empty';
  dynamic get filenameRuleRequire => 'Filename can\'t contains \\/:*?"<>|';
  dynamic get selectBackupFile => 'Select Backup File';
  dynamic get gettingBackupFiles => 'Retrieving backup file, please wait...';
  dynamic get noBackupFileHint =>
      'There are no files in the current directory, please ensure that the backup directory is correct';
  dynamic get uploadFileNotExists => 'Upload file failed, file not exists';
  dynamic get downloadFileFailed => 'Download file failed';
  dynamic get fileNotExists => 'File not exists!';
  dynamic get syncNeedReLogin => 'Account have expired, please login again';
  dynamic get getBackupFileFailed =>
      'Failed to retrieve file list, please try changing the backup directory to a subfolder and retrying';
  dynamic get getBackupFileFailedCheckNetwork =>
      'Failed to retrieve file list, please check the network';
  dynamic get uploadSuccess => 'Upload successfully';
  dynamic get uploadFileFailedReject =>
      'Upload failed, please try changing the backup directory to a subfolder and retrying';
  dynamic get uploadFileFailedCheckNetwork =>
      'Upload failed, please check the network';
  dynamic get downloadComplete => 'Download complete';
  dynamic get unsupportedBackupFile => 'Unsupported backup file';
  dynamic get backupFileCorrupt => 'Backup file data is corrupt';
  dynamic get backupFileNotFound =>
      'Backup file has been deleted, please reopen the dialog and try again after refreshing';
  dynamic get networkError => 'Network error, please retry later';
  dynamic get folderLabel => 'Folder and tags';
  dynamic get recoverySuccess => 'Recovery successfully';
  dynamic get mergeMethodLocalFirst => 'Local First';
  dynamic get mergeMethodRemoteFirst => 'Server First';
  dynamic get mergeMethodOnlyRemote => 'Only Server';
  dynamic get mergeMethodLocalFirstHelp =>
      'If local and server records have the same name, username, and link, keep the local record';
  dynamic get mergeMethodRemoteFirstHelp =>
      'If local and server records have the same name, username, and link, use the server record';
  dynamic get mergeMethodOnlyRemoteHelp =>
      'Delete all local data and use only server data';
  dynamic get encryptLevelNone => 'Not encrypted';
  dynamic get encryptLevelOnlyPassword => 'Only password';
  dynamic get encryptLevelAll => 'All encrypted';
  dynamic get encryptLevelNoneHelp =>
      'The password in the backup file will be displayed in plain text';
  dynamic get encryptLevelOnlyPasswordHelp =>
      'Default option, encrypt only password field';
  dynamic get encryptLevelAllHelp =>
      'All fields are encrypted, information cannot be directly retrieved from the backup file';
  dynamic get backupMethodCreateNew => 'Create new file every time';
  dynamic get backupMethodReplaceExists => 'Backup to specified file';
  dynamic get searchHint => 'Search by name, account, notes or tags';
  dynamic get searchResultEmpty =>
      'No results found, please try a different keyword.';
  dynamic get view => 'View';
  dynamic get edit => 'Edit';
  dynamic get copyUsername => 'Copy username';
  dynamic get usernameCopied => 'Username has been copied to clipboard';
  dynamic get copyPassword => 'Copy password';
  dynamic get deletePassword => 'Delete password';
  dynamic get copyOwnerName => 'Copy owner name';
  dynamic get ownerNameCopied => 'Owner name has been copied to clipboard';
  dynamic get copyCardId => 'Copy card number';
  dynamic get deleteCard => 'Delete Card';
  dynamic get fav => 'Fav';
  dynamic get favorites => 'Favorites';
  dynamic get allpassIntroduction =>
      'A simple tool for managing private information.';
  dynamic get enterDebugMode => 'Enter Debug Mode';
  dynamic get contact => 'Contact';
  dynamic get website => 'Website: https://allpass.aengus.top';
  dynamic get contact1 => 'Twitter: @AengusSun';
  dynamic get contact1Url => 'https://twitter.com/AengusSun';
  dynamic get contact2 => 'Email: sys6511@126.com';
  dynamic get contact3 => 'Developer Address: https://www.aengus.top';
  dynamic get projectUrl => 'Source Repository: Github';
  dynamic get gitee => 'Gitee';
  dynamic get defaultFolder => 'Default';
  dynamic get folderEntertainment => 'Entertainment';
  dynamic get folderOffice => 'Office';
  dynamic get folderFinance => 'Finance';
  dynamic get folderGame => 'Game';
  dynamic get folderForum => 'Forum';
  dynamic get folderEducation => 'Education';
  dynamic get folderSocial => 'Social';
  dynamic get debugListInstalledApp => 'List installed apps';
  dynamic get debugPageTest => 'Page router';
  dynamic get debugListSp => 'List Sp';
  dynamic get debugDeleteAllPassword => 'Delete all passwords';
  dynamic get debugDeleteAllCard => 'Delete all cards';
  dynamic get debugDeletePasswordDB => 'Delete password database';
  dynamic get debugDeleteCardDB => 'Delete card database';
  dynamic get debugAllPasswordDeleted => 'All password deleted';
  dynamic get debugAllCardDeleted => 'All card deleted';
  dynamic get debugPasswordDBDeleted => 'Password database deleted';
  dynamic get debugCardDBDeleted => 'Card database deleted';
  dynamic get importFromChromeTips1 =>
      'Open the Chrome，and then open \'Google Password Manager\'，click \'Export passwords\'';
  dynamic get importFromChromeTips2 =>
      'Find exported password file in File Explorer，click \'Share\'';
  dynamic get importFromChromeTips3 =>
      'Click \'Allpass\'，the import page will be open automatically';
  dynamic get storagePermissionDenied =>
      'Storage permission is denied, please goto setting page to allow Allpass to access your storage';
  static dynamic of(dynamic context) => const AppLocalizations('en');

  // Any key this stand-in does not declare still answers with a String, so a
  // build body that reaches one runs to its end instead of throwing.
  @override
  dynamic noSuchMethod(Invocation invocation) => '';

  dynamic lockingRemains(dynamic lockSeconds) =>
      'Locked, $lockSeconds seconds remaining';
  dynamic mainPasswordError(dynamic inputErrorTimes) =>
      'Main password incorrect, has been entered incorrectly $inputErrorTimes times, consecutive errors exceeding five times will result in a 30-second lockout';
  dynamic deletePasswordsWarning(dynamic count) =>
      'You will delete $count password items, continue to delete?';
  dynamic deletePasswordsSuccess(dynamic count) => '$count password(s) deleted';
  dynamic movePasswordsSuccess(dynamic count, dynamic folder) =>
      'Moved $count password(s) to $folder folder';
  dynamic searchButton(dynamic type) => 'Search $type';
  dynamic deleteCardsWarning(dynamic count) =>
      'You will delete $count card items, continue to delete?';
  dynamic deleteCardsSuccess(dynamic count) => '$count card(s) deleted';
  dynamic moveCardsSuccess(dynamic count, dynamic folder) =>
      'Moved $count card(s) to $folder folder';
  dynamic accountPassword(dynamic account, dynamic password) =>
      'Account: $account\nPassword: $password';
  dynamic createLabelSuccess(dynamic tag) => 'Create Tag $tag successfully';
  dynamic labelAlreadyExists(dynamic tag) => 'Tag $tag already exists';
  dynamic shareAllpassDesc(dynamic downloadUrl) =>
      '[Allpass] is a simple and easy-to-use tool for managing private information. [DownloadUrl] $downloadUrl';
  dynamic nDays(dynamic n) => '$n Days';
  dynamic secretKeyUpgradeResult(dynamic passwordCount, dynamic cardCount) =>
      'Upgraded $passwordCount password items and $cardCount card items';
  dynamic secretKeyUpgradeFailed(dynamic error) => 'Upgrade failed: $error';
  dynamic updateAvailable(dynamic channel, dynamic version) =>
      'A new version is available for download! Latest version $channel V$version';
  dynamic alreadyLatestVersion(dynamic channel, dynamic version) =>
      'Your version is up-to-date! $channel V$version';
  dynamic networkErrorMsg(dynamic message) => 'Network error: $message';
  dynamic unknownError(dynamic message) => 'Unknown error: $message';
  dynamic exportFailed(dynamic message) => 'Export Failed: $message';
  dynamic importRecordSuccess(dynamic count) => 'Importing $count records';
  dynamic recordFormatIncorrect(dynamic n) =>
      'The format of a $n row\'s record is incorrect';
  dynamic categoryManagement(dynamic categoryName) =>
      '$categoryName Management';
  dynamic createCategory(dynamic categoryName) => 'Create $categoryName';
  dynamic createCategorySuccess(dynamic categoryName, dynamic name) =>
      'Create $categoryName $name successfully';
  dynamic categoryAlreadyExists(dynamic categoryName, dynamic name) =>
      '$categoryName $name already exists';
  dynamic updateCategory(dynamic categoryName) => 'Edit $categoryName';
  dynamic updateCategorySuccess(dynamic categoryName, dynamic name) =>
      '$categoryName $name saved';
  dynamic deleteCategory(dynamic categoryName) => 'Delete $categoryName';
  dynamic pleaseInputCategoryName(dynamic categoryName) =>
      'Please input $categoryName name';
  dynamic categoryNameRuleRequire(dynamic categoryName) =>
      '$categoryName name can\'t contains \',\' \'~\' or \'space\'';
  dynamic confirmUploadWaring(dynamic encryptLevel) =>
      'Current encryption level is [$encryptLevel], continue to upload?';
  dynamic confirmRecoverWarning(dynamic mergeMethod) =>
      'Current data recovery method is [$mergeMethod], continue to restore?';
  dynamic recoverV1FileHelp(dynamic encryptLevel, dynamic filename) =>
      'We have detected that an old backup file is being restored. Please select the type of file, as this will affect the final recovery result. Please make sure to choose the correct type.\n\nEncryption level: $encryptLevel Filename: $filename';
  dynamic lastUploadAt(dynamic uploadTimeString) =>
      'Last uploaded on $uploadTimeString';
  dynamic lastRecoverAt(dynamic recoverTimeString) =>
      'Last restored on $recoverTimeString';
  dynamic currentDirectory(dynamic directory) =>
      'Current Directory: $directory';
  dynamic uploadFileFailedUnknown(dynamic message) =>
      'Upload failed, message: $message';
  dynamic uploadFileFailedOther(dynamic error) => 'Upload failed, $error';
  dynamic downloadFailedUnknown(dynamic message) =>
      'Download failed, message: $message';
  dynamic downloadFailedOther(dynamic error) => 'Download failed, $error';
  dynamic recoverySuccessMsg(dynamic name) => 'Recovery $name successfully';
  dynamic recoveryFailedMsg(dynamic error) => 'Recovery failed, $error';
}
