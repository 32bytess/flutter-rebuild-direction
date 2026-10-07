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

late TextEditingController fixtureSearchController = TextEditingController(
  text: 'github',
);

late FocusNode fixtureFocusNode = FocusNode(debugLabel: 'searchField');

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

AllpassType fixtureType = AllpassType.password;

// DECLARATION-ONLY STAND-INS -- repo-local declarations that build no UI, and
// third-party ones the transplant does not inline. Supertypes are mirrored so a
// widget still reads as a widget; everything else is `dynamic`, because none of it
// is measured.

class AllpassEdgeInsets {
  AllpassEdgeInsets._();
  static dynamic get listInset =>
      const EdgeInsets.symmetric(horizontal: 12, vertical: 4);
  static set listInset(dynamic _) {}
  static dynamic get dividerInset => const EdgeInsets.symmetric(horizontal: 16);
  static set dividerInset(dynamic _) {}
  static dynamic get forViewCardInset =>
      const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
  static set forViewCardInset(dynamic _) {}
  static dynamic get forCardInset =>
      const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  static set forCardInset(dynamic _) {}
  static dynamic get settingCardInset =>
      const EdgeInsets.symmetric(horizontal: 16, vertical: 6);
  static set settingCardInset(dynamic _) {}
  static dynamic get forSearchButtonInset =>
      const EdgeInsets.only(left: 20, right: 20);
  static set forSearchButtonInset(dynamic _) {}
  static dynamic get smallTBPadding =>
      const EdgeInsets.symmetric(vertical: 8);
  static set smallTBPadding(dynamic _) {}
  static dynamic get smallLPadding => const EdgeInsets.only(left: 8);
  static set smallLPadding(dynamic _) {}
  static dynamic get smallRPadding => const EdgeInsets.only(right: 8);
  static set smallRPadding(dynamic _) {}
  static dynamic get smallTopInsets => const EdgeInsets.only(top: 8);
  static set smallTopInsets(dynamic _) {}
  static dynamic get bottom10Inset => const EdgeInsets.only(bottom: 10);
  static set bottom10Inset(dynamic _) {}
  static dynamic get bottom30Inset => const EdgeInsets.only(bottom: 30);
  static set bottom30Inset(dynamic _) {}
  static dynamic get bottom50Inset => const EdgeInsets.only(bottom: 50);
  static set bottom50Inset(dynamic _) {}
  static dynamic get widgetItemInset =>
      const EdgeInsets.symmetric(horizontal: 16, vertical: 4);
  static set widgetItemInset(dynamic _) {}
}

class AllpassScreenUtil {
  AllpassScreenUtil._();
  static dynamic get screenHighDp => 640.0;
  static set screenHighDp(dynamic _) {}
  static dynamic setWidth(dynamic width) => 0.0;
  static dynamic setHeight(dynamic height) => 0.0;
}

class AllpassTextUI {
  AllpassTextUI._();
  static dynamic get titleBarStyle =>
      const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  static dynamic get firstTitleStyle =>
      const TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  static dynamic get secondTitleStyle =>
      const TextStyle(fontSize: 14, color: Colors.blue);
  static dynamic get smallTextStyle => const TextStyle(fontSize: 12);
  static dynamic get hintTextStyle =>
      const TextStyle(fontSize: 14, color: Colors.grey);
  static dynamic get settingTrailing =>
      const TextStyle(fontSize: 14, color: Colors.grey);
}

class AllpassUI {
  AllpassUI._();
  static const dynamic smallRadius = 8.0;
  static const dynamic smallBorderRadius = BorderRadius.all(Radius.circular(8));
}

class BaseModel {
  BaseModel();
  dynamic get color => Colors.indigo;
  set color(dynamic _) {}
}

class CardBean extends BaseModel {
  CardBean({
    dynamic key,
    dynamic name,
    dynamic ownerName,
    dynamic cardId,
    dynamic password,
    dynamic telephone,
    dynamic folder,
    dynamic notes,
    dynamic label,
    dynamic fav,
    dynamic createTime,
    dynamic sortNumber,
    dynamic color,
    dynamic gradientColor,
  });
  static dynamic get empty => CardBean();
  static set empty(dynamic _) {}
  dynamic get uniqueKey => null;
  set uniqueKey(dynamic _) {}
  dynamic get name => 'Visa Debit';
  set name(dynamic _) {}
  dynamic get ownerName => 'Alex Turner';
  set ownerName(dynamic _) {}
  dynamic get cardId => '4539 1488 0343 6467';
  set cardId(dynamic _) {}
  dynamic get password => '4821';
  set password(dynamic _) {}
  dynamic get telephone => '+44 7700 900312';
  set telephone(dynamic _) {}
  dynamic get folder => 'Finance';
  set folder(dynamic _) {}
  dynamic get notes => 'Expires 08/29. Daily limit raised on request.';
  set notes(dynamic _) {}
  dynamic get label => <String>[];
  set label(dynamic _) {}
  dynamic get fav => 0;
  set fav(dynamic _) {}
  dynamic get createTime => '2024-03-18 09:41:05';
  set createTime(dynamic _) {}
  dynamic get sortNumber => 0;
  set sortNumber(dynamic _) {}
  dynamic get gradientColor => null;
  set gradientColor(dynamic _) {}
  static dynamic fromJson(dynamic map) => CardBean();
  dynamic toJson() => <String, dynamic>{};
  static dynamic toCsv(dynamic bean) =>
      'Visa Debit,Alex Turner,4539 1488 0343 6467,Finance';
  dynamic copy() => CardBean();
  dynamic identify(dynamic other) => false;
}

class CardProvider extends ChangeNotifier {
  CardProvider();
  dynamic get cardList => [];
  dynamic get count => 0;
  dynamic get currCard => CardBean();
  dynamic get mostUsedOwnerName => <String>[];
  dynamic init() => const _Stub();
  dynamic refresh() => const _Stub();
  dynamic insertCard(dynamic bean) => const _Stub();
  dynamic deleteCard(dynamic bean) => const _Stub();
  dynamic updateCard(dynamic bean) => const _Stub();
  dynamic clear() => const _Stub();
  void previewCard({dynamic index, dynamic bean}) {}
}

class Config {
  Config._();
  static dynamic get password => 'sT7pQ2xL9vKd';
  static set password(dynamic _) {}
  static dynamic get enabledBiometrics => false;
  static set enabledBiometrics(dynamic _) {}
  static dynamic get longPressCopy => false;
  static set longPressCopy(dynamic _) {}
  static dynamic get primaryColor => Colors.blue;
  static set primaryColor(dynamic _) {}
  static dynamic get themeMode => ThemeMode.system;
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
  static dynamic get webDavBackupDirectory => '/allpass';
  static set webDavBackupDirectory(dynamic _) {}
  static dynamic get webDavUploadTime => null;
  static set webDavUploadTime(dynamic _) {}
  static dynamic get webDavDownloadTime => null;
  static set webDavDownloadTime(dynamic _) {}
  static dynamic get webDavBackupMethod => const _Stub();
  static set webDavBackupMethod(dynamic _) {}
  static dynamic get webDavBackupFilename => null;
  static set webDavBackupFilename(dynamic _) {}
  static dynamic get timingInMainPassword => 0;
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
}

class Consumer<T> extends StatelessWidget {
  final dynamic child;
  Consumer({super.key, dynamic builder, this.child});
  @override
  Widget build(BuildContext context) =>
      child is Widget ? child as Widget : const SizedBox.shrink();
  dynamic get builder => const _Stub();
  Widget buildWithChild(dynamic context, dynamic child) =>
      const SizedBox.shrink();
}

class CustomIcons {
  CustomIcons();
  static const dynamic chrome = Icons.language;
  static const dynamic noData = Icons.inbox_outlined;
}

class EncryptUtil {
  EncryptUtil._();
  static dynamic get initialKey => 'a7f3c1e95b2d4806';
  static set initialKey(dynamic _) {}
  static dynamic initEncrypt({dynamic needFresh}) =>
      Future<String?>.value(null);
  static dynamic initEncryptByKey(dynamic key) => const _Stub();
  static dynamic getStoreKey() => Future<String?>.value(null);
  static dynamic clearEncrypt() => const _Stub();
  static dynamic getEncryption() => const _Stub();
  static dynamic encrypt(dynamic password) => 'U2FsdGVkX1+9ZkQpR3mBvQ==';
  static dynamic decrypt(dynamic encryptTxt) => 'hunter2-Zx91';
  static dynamic generateRandomKey(
    dynamic len, {
    dynamic cap,
    dynamic low,
    dynamic number,
    dynamic sym,
  }) => 'Kq4#nZ7v!Lb2';
}

extension L10nSupport on BuildContext {
  dynamic get l10n => const AppLocalizations(null);
}

class PasswordBean extends BaseModel {
  PasswordBean({
    dynamic key,
    dynamic name,
    dynamic username,
    dynamic password,
    dynamic url,
    dynamic folder,
    dynamic notes,
    dynamic label,
    dynamic fav,
    dynamic createTime,
    dynamic color,
    dynamic sortNumber,
    dynamic appId,
    dynamic appName,
    dynamic encrypted,
  });
  static dynamic get empty => PasswordBean();
  static set empty(dynamic _) {}
  dynamic get uniqueKey => null;
  set uniqueKey(dynamic _) {}
  dynamic get name => 'GitHub';
  set name(dynamic _) {}
  dynamic get username => 'alex.turner@example.com';
  set username(dynamic _) {}
  dynamic get password => 'U2FsdGVkX1+9ZkQpR3mBvQ==';
  set password(dynamic _) {}
  dynamic get url => 'https://github.com/login';
  set url(dynamic _) {}
  dynamic get folder => 'Office';
  set folder(dynamic _) {}
  dynamic get notes => 'Two-factor enabled. Recovery codes stored offline.';
  set notes(dynamic _) {}
  dynamic get label => <String>[];
  set label(dynamic _) {}
  dynamic get fav => 0;
  set fav(dynamic _) {}
  dynamic get createTime => '2024-01-22 18:07:44';
  set createTime(dynamic _) {}
  dynamic get sortNumber => 0;
  set sortNumber(dynamic _) {}
  dynamic get appId => null;
  set appId(dynamic _) {}
  dynamic get appName => null;
  set appName(dynamic _) {}
  static dynamic fromJson(dynamic map) => PasswordBean();
  dynamic toJson() => <String, dynamic>{};
  static dynamic toCsv(dynamic bean) => Future<String>.value(
    'GitHub,alex.turner@example.com,https://github.com/login,Office',
  );
  dynamic get encrypted => false;
  set encrypted(dynamic _) {}
  dynamic copy() => PasswordBean();
  dynamic identify(dynamic other) => false;
}

class SearchProvider extends ChangeNotifier {
  SearchProvider(dynamic type, dynamic context);
  dynamic get passwordSearch => [];
  set passwordSearch(dynamic _) {}
  dynamic get cardSearch => [];
  set cardSearch(dynamic _) {}
  dynamic get type => AllpassType.password;
  void search(dynamic regex) {}
  dynamic empty() => false;
  dynamic length() => 0;
}

class ThemeUtil {
  ThemeUtil._();
  static dynamic isInDarkTheme(dynamic context) => false;
}

class ToastUtil {
  ToastUtil._();
  static void show({dynamic msg}) {}
  static void showError({dynamic msg}) {}
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

class AppLocalizations {
  const AppLocalizations(dynamic locale);
  dynamic get localeName => 'en';
  static const dynamic delegate = null;
  static const dynamic localizationsDelegates = null;
  static const dynamic supportedLocales = null;
  dynamic get allpass => 'Allpass';
  dynamic get appError => 'Something went wrong';
  dynamic get appErrorHint1 => 'Allpass ran into an unexpected problem.';
  dynamic get appErrorHint2 => 'Restart the app, or send us the error report.';
  dynamic get enabled => 'Enabled';
  dynamic get disabled => 'Disabled';
  dynamic get unlock => 'Unlock';
  dynamic get unlockAllpass => 'Unlock Allpass';
  dynamic get pleaseInputMainPassword => 'Enter your master password';
  dynamic get useBiometrics => 'Use biometrics';
  dynamic get notEnableBiometricsYet => 'Biometric unlock is not set up yet';
  dynamic get errorExceedThreshold => 'Too many failed attempts';
  dynamic get clickToUseBiometrics => 'Tap to unlock with biometrics';
  dynamic get usePassword => 'Use password';
  dynamic get inputMainPasswordTimingHint =>
      'How often Allpass asks for the master password';
  dynamic get verificationSuccess => 'Verified';
  dynamic get mainPasswordErrorHint => 'Master password is incorrect';
  dynamic get biometricsRecognizedFailed => 'Biometrics not recognised';
  dynamic get pleaseInputMainPasswordFirst =>
      'Enter the master password first';
  dynamic get unlockSuccess => 'Unlocked';
  dynamic get notSetupYet => 'Not set up yet';
  dynamic get appHasForceLock => 'Allpass has been locked';
  dynamic get setupAllpass => 'Set up Allpass';
  dynamic get pleaseInputAgain => 'Enter it again';
  dynamic get setup => 'Set up';
  dynamic get passwordNotSame => 'The two passwords do not match';
  dynamic get passwordTooShort => 'Password is too short';
  dynamic get setupSuccess => 'Setup complete';
  dynamic get alreadySetup => 'Already set up';
  dynamic get serviceTerms => 'Terms of Service';
  dynamic get confirmServiceTerms => 'I agree to the Terms of Service';
  dynamic get cancel => 'Cancel';
  dynamic get password => 'Password';
  dynamic get passwords => 'Passwords';
  dynamic get addPasswordItem => 'Add password';
  dynamic get passwordEmptyHint => 'No passwords saved yet';
  dynamic get selectOnePasswordAtLeast => 'Select at least one password';
  dynamic get confirmDelete => 'Confirm deletion';
  dynamic get emptyDataHint => 'Nothing here yet';
  dynamic get delete => 'Delete';
  dynamic get move => 'Move';
  dynamic get card => 'Card';
  dynamic get cards => 'Cards';
  dynamic get addCardItem => 'Add card';
  dynamic get cardEmptyHint => 'No cards saved yet';
  dynamic get selectOneCardAtLeast => 'Select at least one card';
  dynamic get unknownErrorOccur => 'An unknown error occurred';
  dynamic get account => 'Account';
  dynamic get copy => 'Copy';
  dynamic get accountCopied => 'Account copied';
  dynamic get passwordCopied => 'Password copied';
  dynamic get url => 'Website';
  dynamic get urlCopied => 'Link copied';
  dynamic get ownerApp => 'Linked app';
  dynamic get openAppFailed => 'Could not open the app';
  dynamic get notes => 'Notes';
  dynamic get emptyNotes => 'No notes';
  dynamic get label => 'Label';
  dynamic get labels => 'Labels';
  dynamic get accountPasswordCopied => 'Account and password copied';
  dynamic get deletePasswordWaring =>
      'This password will be deleted permanently.';
  dynamic get deleteSuccess => 'Deleted';
  dynamic get viewPassword => 'View password';
  dynamic get emptyLabel => 'No labels';
  dynamic get none => 'None';
  dynamic get viewCard => 'View card';
  dynamic get ownerName => 'Cardholder';
  dynamic get nameCopied => 'Name copied';
  dynamic get cardId => 'Card number';
  dynamic get cardIdCopied => 'Card number copied';
  dynamic get phoneNumber => 'Phone number';
  dynamic get phoneNumberCopied => 'Phone number copied';
  dynamic get deleteCardWarning => 'This card will be deleted permanently.';
  dynamic get createPassword => 'New password';
  dynamic get updatePassword => 'Edit password';
  dynamic get createSuccess => 'Created';
  dynamic get updateSuccess => 'Saved';
  dynamic get upsertPasswordRule => 'Name and account cannot be empty';
  dynamic get name => 'Name';
  dynamic get folder => 'Folder';
  dynamic get folderTitle => 'Folders';
  dynamic get setToNone => 'Set to none';
  dynamic get addNotes => 'Add a note';
  dynamic get passwordGenerator => 'Password generator';
  dynamic get symbols => 'Symbols';
  dynamic get generate => 'Generate';
  dynamic get pleaseSelectOneItemAtLeast => 'Select at least one item';
  dynamic get close => 'Close';
  dynamic get createCard => 'New card';
  dynamic get updateCard => 'Edit card';
  dynamic get cardPasswordEmptyAutoGen =>
      'Leave the PIN empty and one will be generated';
  dynamic get upsertCardRule => 'Name and cardholder cannot be empty';
  dynamic get settings => 'Settings';
  dynamic get mainPasswordManager => 'Master password';
  dynamic get biometricAuthentication => 'Biometric unlock';
  dynamic get enableBiometricSuccess => 'Biometric unlock enabled';
  dynamic get disableBiometricSuccess => 'Biometric unlock disabled';
  dynamic get biometricNotAvailable =>
      'Biometrics are not available on this device';
  dynamic get authorizationFailed => 'Authorisation failed';
  dynamic get biometricNotSupport => 'This device does not support biometrics';
  dynamic get autoLock => 'Auto-lock';
  dynamic get autoLockImmediate => 'Immediately';
  dynamic get autoLock30s => 'After 30 seconds';
  dynamic get autoLockDisable => 'Never';
  dynamic get longPressToCopy => 'Long press to copy';
  dynamic get appTheme => 'Theme';
  dynamic get labelManager => 'Manage labels';
  dynamic get folderManager => 'Manage folders';
  dynamic get webDavSync => 'WebDAV sync';
  dynamic get importExport => 'Import and export';
  dynamic get autofill => 'Autofill';
  dynamic get shareToFriends => 'Share with a friend';
  dynamic get feedback => 'Send feedback';
  dynamic get checkUpdate => 'Check for updates';
  dynamic get about => 'About';
  dynamic get shareAllpassSubject => 'Allpass, an offline password manager';
  dynamic get pleaseSelect => 'Please choose';
  dynamic get authorizeToUnlock => 'Authorise to unlock Allpass';
  dynamic get gotoSettings => 'Open Settings';
  dynamic get iosGoToSettingsDescFace =>
      'Enable Face ID for Allpass in Settings.';
  dynamic get iosGoToSettingsDescFingerprint =>
      'Enable Touch ID for Allpass in Settings.';
  dynamic get iosGoToSettingsDescIris =>
      'Enable iris unlock for Allpass in Settings.';
  dynamic get iosGoToSettingsDescDefault =>
      'Enable biometrics for Allpass in Settings.';
  dynamic get iosLogoutFace => 'Cancel Face ID';
  dynamic get iosLogoutFingerprint => 'Cancel Touch ID';
  dynamic get iosLogoutIris => 'Cancel iris unlock';
  dynamic get androidGoToSettingsDesc =>
      'Set up a fingerprint or face unlock in your device settings.';
  dynamic get biometricRequiredTitle => 'Biometrics required';
  dynamic get signInTitle => 'Sign in to Allpass';
  dynamic get biometricHint => 'Confirm your identity to continue';
  dynamic get modifyMainPassword => 'Change master password';
  dynamic get inputMainPasswordTiming => 'Ask for master password';
  dynamic get secretKeyUpdate => 'Update secret key';
  dynamic get clearAllData => 'Erase all data';
  dynamic get lockAllpass => 'Lock Allpass';
  dynamic get never => 'Never';
  dynamic get sevenDays => 'Every 7 days';
  dynamic get tenDays => 'Every 10 days';
  dynamic get fifteenDays => 'Every 15 days';
  dynamic get thirtyDays => 'Every 30 days';
  dynamic get confirmSelect => 'Confirm';
  dynamic get selectNeverWarning =>
      'Allpass will never ask for the master password again.';
  dynamic get confirmClearAll => 'Erase everything?';
  dynamic get clearAllWaring =>
      'Every password, card and setting will be removed. This cannot be undone.';
  dynamic get clearAllSuccess => 'All data erased';
  dynamic get mainPasswordIncorrect => 'Master password is incorrect';
  dynamic get oldPassword => 'Current password';
  dynamic get newPassword => 'New password';
  dynamic get pleaseInputOldPassword => 'Enter your current password';
  dynamic get pleaseInputNewPassword => 'Enter a new password';
  dynamic get modifySuccess => 'Password changed';
  dynamic get modifyPasswordFail => 'Could not change the password';
  dynamic get oldPasswordIncorrect => 'Current password is incorrect';
  dynamic get secretKeyUpdateHelp1 =>
      'The secret key encrypts every password and card on this device.';
  dynamic get secretKeyUpdateHelp2 =>
      'Older versions of Allpass used a shared built-in key.';
  dynamic get secretKeyUpdateHelp3 =>
      'Generating your own key makes each vault unique.';
  dynamic get secretKeyUpdateHelp4 => 'The upgrade runs entirely offline.';
  dynamic get secretKeyUpdateHelp5 =>
      'Back up your data before starting the upgrade.';
  dynamic get secretKeyUpdateHelp6 =>
      'Every stored record is re-encrypted with the new key.';
  dynamic get secretKeyUpdateHelp7 =>
      'Do not close Allpass while the upgrade is running.';
  dynamic get secretKeyUpdateHelp8 =>
      'The upgrade usually takes only a few seconds.';
  dynamic get secretKeyUpdateHelp9 =>
      'Old backups stay readable with the old key.';
  dynamic get secretKeyUpdateHelp10 =>
      'Store the new key somewhere safe and offline.';
  dynamic get secretKeyUpdateHelp11 =>
      'A lost key cannot be recovered by anyone.';
  dynamic get secretKeyUpdateHelp12 =>
      'You will need the key to restore a backup on a new device.';
  dynamic get secretKeyUpdateHelp13 =>
      'The key is never uploaded or sent anywhere.';
  dynamic get secretKeyUpdateHelp14 =>
      'You can generate a new key again at any time.';
  dynamic get secretKeyUpdateHint =>
      'Generate a key, then start the upgrade.';
  dynamic get generateSecretKey => 'Generate secret key';
  dynamic get generateSecretKeyDone => 'Secret key generated';
  dynamic get startUpgrade => 'Start upgrade';
  dynamic get upgradeDone => 'Upgrade complete';
  dynamic get pleaseGenerateKeyFirst => 'Generate a secret key first';
  dynamic get secretKeyLengthRequire =>
      'The secret key must be exactly 16 characters';
  dynamic get feedbackPlaceholder => 'Tell us what happened';
  dynamic get feedbackContact => 'Email or contact (optional)';
  dynamic get submit => 'Submit';
  dynamic get submitting => 'Submitting';
  dynamic get feedbackContentEmptyWarning => 'Feedback cannot be empty';
  dynamic get feedbackContentTooLong => 'Feedback is too long';
  dynamic get updateContent => 'What is new';
  dynamic get recentlyUpdateContent => 'Recent changes';
  dynamic get networkErrorHelp => 'Check your connection and try again.';
  dynamic get unknownErrorHelp => 'Try again in a moment.';
  dynamic get downloadUpdate => 'Download update';
  dynamic get remindMeLatter => 'Remind me later';
  dynamic get confirm => 'OK';
  dynamic get themeSystem => 'System default';
  dynamic get themeLight => 'Light';
  dynamic get themeDark => 'Dark';
  dynamic get themeColorBlue => 'Blue';
  dynamic get themeColorRed => 'Red';
  dynamic get themeColorTeal => 'Teal';
  dynamic get themeColorDeepPurple => 'Deep purple';
  dynamic get themeColorOrange => 'Orange';
  dynamic get themeColorPink => 'Pink';
  dynamic get themeColorBlueGrey => 'Blue grey';
  dynamic get selectExportType => 'Choose what to export';
  dynamic get exportConfirm => 'Confirm export';
  dynamic get exportPasswordConfirmWarning =>
      'Exported passwords are written in plain text.';
  dynamic get exportCardConfirmWarning =>
      'Exported cards are written in plain text.';
  dynamic get passwordAndCard => 'Passwords and cards';
  dynamic get exportAllConfirmWarning =>
      'Everything will be exported in plain text.';
  dynamic get importFromChrome => 'Import from Chrome';
  dynamic get importFromCsv => 'Import from CSV';
  dynamic get importFromClipboard => 'Import from clipboard';
  dynamic get exportToCsv => 'Export to CSV';
  dynamic get selectImportType => 'Choose an import source';
  dynamic get importFailedNotCsv => 'That file is not a CSV';
  dynamic get importCanceled => 'Import cancelled';
  dynamic get importFromClipboardHelp1 =>
      'Copy your records, then paste them below.';
  dynamic get importFromClipboardHelp2 => 'Put one record on each line.';
  dynamic get importFromClipboardHelp3 => 'Separate fields with a comma.';
  dynamic get importFromClipboardHelp4 =>
      'Leave a field empty to skip it, but keep the comma.';
  dynamic get importFromClipboardHelp5 =>
      'Pick the format that matches your data.';
  dynamic get importFromClipboardHelp6 =>
      'Preview the result before confirming.';
  dynamic get importFromClipboardSelectFormat => 'Choose a format';
  dynamic get importFromClipboardFormat1 => 'Name, account, password';
  dynamic get importFromClipboardFormat2 => 'Name, account, password, website';
  dynamic get importFromClipboardFormat3 =>
      'Name, account, password, website, notes';
  dynamic get importFromClipboardFormat4 => 'Name, cardholder, card number';
  dynamic get importFromClipboardFormat5 =>
      'Name, cardholder, card number, PIN';
  dynamic get importFromClipboardFormat6 =>
      'Name, cardholder, card number, PIN, phone';
  dynamic get importFromClipboardFormatHint =>
      'Example: GitHub,alex@example.com,hunter2';
  dynamic get importFromClipboardFormatHint2 =>
      'Example: Visa Debit,Alex Turner,4539148803436467';
  dynamic get importFromClipboardFormatHint3 =>
      'Lines that do not match the format are skipped.';
  dynamic get pasteDataHere => 'Paste your data here';
  dynamic get startImport => 'Start import';
  dynamic get importing => 'Importing';
  dynamic get importComplete => 'Import complete';
  dynamic get importFromExternalPreview => 'Preview';
  dynamic get importFromExternalTips =>
      'Check the records below before importing.';
  dynamic get confirmImport => 'Confirm import';
  dynamic get folderDisallowModify => 'This folder cannot be changed';
  dynamic get deleteLabelWarning =>
      'The label will be removed from every record.';
  dynamic get deleteFolderWarning =>
      'Records in this folder will be moved to the default folder.';
  dynamic get categoryNameNotValid => 'That name is not allowed';
  dynamic get categoryNameNotAllowEmpty => 'The name cannot be empty';
  dynamic get autofillEnableAllpass => 'Enable Allpass autofill';
  dynamic get autofillDisableAllpass => 'Disable Allpass autofill';
  dynamic get autofillHelp =>
      'Let Allpass fill accounts and passwords in other apps.';
  dynamic get uploadToRemote => 'Back up to server';
  dynamic get recoverToLocal => 'Restore to this device';
  dynamic get remoteBackupDirectory => 'Backup folder';
  dynamic get backupFileMethod => 'Backup file handling';
  dynamic get dataMergeMethod => 'Merge strategy';
  dynamic get encryptLevel => 'Encryption level';
  dynamic get logoutAccount => 'Sign out';
  dynamic get confirmUpload => 'Confirm backup';
  dynamic get uploading => 'Uploading';
  dynamic get confirmRecover => 'Confirm restore';
  dynamic get recovering => 'Restoring';
  dynamic get pleaseInputCustomSecretKey => 'Enter your secret key';
  dynamic get inputCustomSecretKeyHelp =>
      'This backup was encrypted with a custom key.';
  dynamic get pleaseInputBackupDirectory => 'Enter a backup folder';
  dynamic get encryptHelp1 =>
      'None: the backup is readable by anything that opens it.';
  dynamic get encryptHelp2 =>
      'Passwords only: password and PIN fields are encrypted.';
  dynamic get encryptHelp3 => 'Full: every field in the backup is encrypted.';
  dynamic get encryptHelp4 =>
      'A stronger level makes a backup slower to restore.';
  dynamic get encryptHelp5 =>
      'Backups are encrypted before they leave this device.';
  dynamic get encryptHelp6 => 'The server never receives your secret key.';
  dynamic get encryptHelp7 =>
      'You need the same key to restore on another device.';
  dynamic get encryptHelp8 => 'A lost key means a backup cannot be restored.';
  dynamic get confirmLogout => 'Sign out?';
  dynamic get confirmLogoutWaring =>
      'Your WebDAV details will be removed from this device.';
  dynamic get decryptBackupError => 'Could not decrypt the backup';
  dynamic get syncAuthFailed => 'Sign-in failed';
  dynamic get syncing => 'Syncing';
  dynamic get webdavConfig => 'WebDAV settings';
  dynamic get port => 'Port';
  dynamic get webdavServerUrl => 'Server address';
  dynamic get webdavServerUrlHint => 'https://dav.example.com';
  dynamic get webdavServerUrlRequire => 'Enter a server address';
  dynamic get webdavPortRequire => 'Enter a port number';
  dynamic get webdavLoginSuccess => 'Signed in';
  dynamic get webdavLoginFailed => 'Sign-in failed';
  dynamic get nextStep => 'Next';
  dynamic get inConfiguration => 'Setting up';
  dynamic get webdavHelp1 =>
      'Allpass works with any standard WebDAV server.';
  dynamic get webdavHelp2 =>
      'Use the address, username and password from your provider.';
  dynamic get webdavHelp3 =>
      'Backups are stored in a folder you choose on that server.';
  dynamic get webdavExample => 'For example https://dav.example.com/allpass';
  dynamic get copySuccess => 'Copied';
  dynamic get clickToViewAndEditConfig => 'Tap to view or edit the settings';
  dynamic get help => 'Help';
  dynamic get modifyBackupFilename => 'Rename backup files';
  dynamic get passwordBackupFilename => 'Password backup file';
  dynamic get cardBackupFilename => 'Card backup file';
  dynamic get extraBackupFilename => 'Settings backup file';
  dynamic get filenameNotAllowSame => 'File names must differ';
  dynamic get filenameNotAllowEmpty => 'File name cannot be empty';
  dynamic get filenameRuleRequire => 'Use letters, digits, - and _ only';
  dynamic get selectBackupFile => 'Choose a backup file';
  dynamic get gettingBackupFiles => 'Loading backup files';
  dynamic get noBackupFileHint => 'No backups found on the server';
  dynamic get uploadFileNotExists => 'The file to upload no longer exists';
  dynamic get downloadFileFailed => 'Download failed';
  dynamic get fileNotExists => 'File not found';
  dynamic get syncNeedReLogin => 'Please sign in to WebDAV again';
  dynamic get getBackupFileFailed => 'Could not load the backup list';
  dynamic get getBackupFileFailedCheckNetwork =>
      'Could not load the backup list. Check your connection.';
  dynamic get uploadSuccess => 'Backup uploaded';
  dynamic get uploadFileFailedReject => 'The server rejected the upload';
  dynamic get uploadFileFailedCheckNetwork =>
      'Upload failed. Check your connection.';
  dynamic get downloadComplete => 'Download complete';
  dynamic get unsupportedBackupFile => 'This backup format is not supported';
  dynamic get backupFileCorrupt => 'The backup file is damaged';
  dynamic get backupFileNotFound => 'Backup file not found';
  dynamic get networkError => 'Network error';
  dynamic get folderLabel => 'Folders and labels';
  dynamic get recoverySuccess => 'Restore complete';
  dynamic get mergeMethodLocalFirst => 'Keep local on conflict';
  dynamic get mergeMethodRemoteFirst => 'Keep server on conflict';
  dynamic get mergeMethodOnlyRemote => 'Replace with server copy';
  dynamic get mergeMethodLocalFirstHelp =>
      'Records on this device win when the same record differs.';
  dynamic get mergeMethodRemoteFirstHelp =>
      'Records from the server win when the same record differs.';
  dynamic get mergeMethodOnlyRemoteHelp =>
      'Local records are discarded and replaced by the backup.';
  dynamic get encryptLevelNone => 'None';
  dynamic get encryptLevelOnlyPassword => 'Passwords only';
  dynamic get encryptLevelAll => 'Everything';
  dynamic get encryptLevelNoneHelp => 'The backup is stored unencrypted.';
  dynamic get encryptLevelOnlyPasswordHelp =>
      'Only password and PIN fields are encrypted.';
  dynamic get encryptLevelAllHelp => 'Every field in the backup is encrypted.';
  dynamic get backupMethodCreateNew => 'Create a new file each time';
  dynamic get backupMethodReplaceExists => 'Replace the existing file';
  dynamic get searchHint => 'Search passwords and cards';
  dynamic get searchResultEmpty => 'No matches found';
  dynamic get view => 'View';
  dynamic get edit => 'Edit';
  dynamic get copyUsername => 'Copy account';
  dynamic get usernameCopied => 'Account copied';
  dynamic get copyPassword => 'Copy password';
  dynamic get deletePassword => 'Delete password';
  dynamic get copyOwnerName => 'Copy cardholder';
  dynamic get ownerNameCopied => 'Cardholder copied';
  dynamic get copyCardId => 'Copy card number';
  dynamic get deleteCard => 'Delete card';
  dynamic get fav => 'Favourite';
  dynamic get favorites => 'Favourites';
  dynamic get allpassIntroduction =>
      'Allpass keeps your passwords and cards on your own device.';
  dynamic get enterDebugMode => 'Enter debug mode';
  dynamic get contact => 'Contact';
  dynamic get website => 'Website';
  dynamic get contact1 => 'Homepage';
  dynamic get contact1Url => 'https://allpass.example.com';
  dynamic get contact2 => 'Email';
  dynamic get contact3 => 'Community';
  dynamic get projectUrl => 'https://github.com/sunyongsheng/Allpass';
  dynamic get gitee => 'Gitee';
  dynamic get defaultFolder => 'Default';
  dynamic get folderEntertainment => 'Entertainment';
  dynamic get folderOffice => 'Office';
  dynamic get folderFinance => 'Finance';
  dynamic get folderGame => 'Games';
  dynamic get folderForum => 'Forums';
  dynamic get folderEducation => 'Education';
  dynamic get folderSocial => 'Social';
  dynamic get debugListInstalledApp => 'List installed apps';
  dynamic get debugPageTest => 'Page test';
  dynamic get debugListSp => 'List preferences';
  dynamic get debugDeleteAllPassword => 'Delete all passwords';
  dynamic get debugDeleteAllCard => 'Delete all cards';
  dynamic get debugDeletePasswordDB => 'Drop password database';
  dynamic get debugDeleteCardDB => 'Drop card database';
  dynamic get debugAllPasswordDeleted => 'All passwords deleted';
  dynamic get debugAllCardDeleted => 'All cards deleted';
  dynamic get debugPasswordDBDeleted => 'Password database dropped';
  dynamic get debugCardDBDeleted => 'Card database dropped';
  dynamic get importFromChromeTips1 =>
      'Open Chrome and go to Settings, then Passwords.';
  dynamic get importFromChromeTips2 =>
      'Choose Export passwords and save the CSV file.';
  dynamic get importFromChromeTips3 =>
      'Come back here and pick that file to import it.';
  dynamic get storagePermissionDenied => 'Storage permission denied';
  static dynamic of(dynamic context) => null;
  dynamic lockingRemains(dynamic lockSeconds) =>
      'Locked for another $lockSeconds seconds';
  dynamic mainPasswordError(dynamic inputErrorTimes) =>
      'Wrong password, $inputErrorTimes attempts so far';
  dynamic deletePasswordsWarning(dynamic count) =>
      '$count passwords will be deleted permanently.';
  dynamic deletePasswordsSuccess(dynamic count) => '$count passwords deleted';
  dynamic movePasswordsSuccess(dynamic count, dynamic folder) =>
      '$count passwords moved to $folder';
  dynamic searchButton(dynamic type) => 'Search $type';
  dynamic deleteCardsWarning(dynamic count) =>
      '$count cards will be deleted permanently.';
  dynamic deleteCardsSuccess(dynamic count) => '$count cards deleted';
  dynamic moveCardsSuccess(dynamic count, dynamic folder) =>
      '$count cards moved to $folder';
  dynamic accountPassword(dynamic account, dynamic password) =>
      'Account: $account, password: $password';
  dynamic createLabelSuccess(dynamic tag) => 'Label $tag created';
  dynamic labelAlreadyExists(dynamic tag) => 'Label $tag already exists';
  dynamic shareAllpassDesc(dynamic downloadUrl) =>
      'I use Allpass to keep my passwords offline. Download it at $downloadUrl';
  dynamic nDays(dynamic n) => 'Every $n days';
  dynamic secretKeyUpgradeResult(dynamic passwordCount, dynamic cardCount) =>
      'Upgraded $passwordCount passwords and $cardCount cards';
  dynamic secretKeyUpgradeFailed(dynamic error) => 'Upgrade failed: $error';
  dynamic updateAvailable(dynamic channel, dynamic version) =>
      'Version $version is available on the $channel channel';
  dynamic alreadyLatestVersion(dynamic channel, dynamic version) =>
      'Version $version is the latest on the $channel channel';
  dynamic networkErrorMsg(dynamic message) => 'Network error: $message';
  dynamic unknownError(dynamic message) => 'Unknown error: $message';
  dynamic exportFailed(dynamic message) => 'Export failed: $message';
  dynamic importRecordSuccess(dynamic count) => '$count records imported';
  dynamic recordFormatIncorrect(dynamic n) => 'Line $n does not match the format';
  dynamic categoryManagement(dynamic categoryName) => 'Manage $categoryName';
  dynamic createCategory(dynamic categoryName) => 'New $categoryName';
  dynamic createCategorySuccess(dynamic categoryName, dynamic name) =>
      '$categoryName $name created';
  dynamic categoryAlreadyExists(dynamic categoryName, dynamic name) =>
      '$categoryName $name already exists';
  dynamic updateCategory(dynamic categoryName) => 'Edit $categoryName';
  dynamic updateCategorySuccess(dynamic categoryName, dynamic name) =>
      '$categoryName $name saved';
  dynamic deleteCategory(dynamic categoryName) => 'Delete $categoryName';
  dynamic pleaseInputCategoryName(dynamic categoryName) =>
      'Enter a $categoryName name';
  dynamic categoryNameRuleRequire(dynamic categoryName) =>
      'A $categoryName name must be 1 to 20 characters';
  dynamic confirmUploadWaring(dynamic encryptLevel) =>
      'The backup will be uploaded with encryption level $encryptLevel.';
  dynamic confirmRecoverWarning(dynamic mergeMethod) =>
      'The backup will be restored using $mergeMethod.';
  dynamic recoverV1FileHelp(dynamic encryptLevel, dynamic filename) =>
      '$filename is an older backup encrypted at level $encryptLevel.';
  dynamic lastUploadAt(dynamic uploadTimeString) =>
      'Last backup $uploadTimeString';
  dynamic lastRecoverAt(dynamic recoverTimeString) =>
      'Last restore $recoverTimeString';
  dynamic currentDirectory(dynamic directory) => 'Current folder: $directory';
  dynamic uploadFileFailedUnknown(dynamic message) =>
      'Upload failed: $message';
  dynamic uploadFileFailedOther(dynamic error) => 'Upload failed: $error';
  dynamic downloadFailedUnknown(dynamic message) =>
      'Download failed: $message';
  dynamic downloadFailedOther(dynamic error) => 'Download failed: $error';
  dynamic recoverySuccessMsg(dynamic name) => '$name restored';
  dynamic recoveryFailedMsg(dynamic error) => 'Restore failed: $error';
}
