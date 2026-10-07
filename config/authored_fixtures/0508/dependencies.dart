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

bool fixtureCardIdVisible = false;

bool fixturePasswordVisible = false;

String fixturePassword = "";

String fixtureCache = "noCache";

bool fixtureDeleted = true;

// DECLARATION-ONLY STAND-INS -- repo-local declarations that build no UI, and
// third-party ones the transplant does not inline. Supertypes are mirrored so a
// widget still reads as a widget; everything else is `dynamic`, because none of it
// is measured.

class AllpassEdgeInsets {
  AllpassEdgeInsets._();
  static dynamic get listInset => const _Stub();
  static set listInset(dynamic _) {}
  static dynamic get dividerInset => const _Stub();
  static set dividerInset(dynamic _) {}
  static dynamic get forViewCardInset => const _Stub();
  static set forViewCardInset(dynamic _) {}
  static dynamic get forCardInset => const _Stub();
  static set forCardInset(dynamic _) {}
  static dynamic get settingCardInset => const _Stub();
  static set settingCardInset(dynamic _) {}
  static dynamic get forSearchButtonInset => const _Stub();
  static set forSearchButtonInset(dynamic _) {}
  static dynamic get smallTBPadding => const _Stub();
  static set smallTBPadding(dynamic _) {}
  static dynamic get smallLPadding => const _Stub();
  static set smallLPadding(dynamic _) {}
  static dynamic get smallRPadding => const _Stub();
  static set smallRPadding(dynamic _) {}
  static dynamic get smallTopInsets => const _Stub();
  static set smallTopInsets(dynamic _) {}
  static dynamic get bottom10Inset => const _Stub();
  static set bottom10Inset(dynamic _) {}
  static dynamic get bottom30Inset => const _Stub();
  static set bottom30Inset(dynamic _) {}
  static dynamic get bottom50Inset => const _Stub();
  static set bottom50Inset(dynamic _) {}
  static dynamic get widgetItemInset => const _Stub();
  static set widgetItemInset(dynamic _) {}
}

class AllpassScreenUtil {
  AllpassScreenUtil._();
  static dynamic get screenHighDp => 0.0;
  static set screenHighDp(dynamic _) {}
  static dynamic setWidth(dynamic width) => 0.0;
  static dynamic setHeight(dynamic height) => 0.0;
}

class AllpassTextUI {
  AllpassTextUI._();
  static dynamic get titleBarStyle => const _Stub();
  static dynamic get firstTitleStyle => const _Stub();
  static dynamic get secondTitleStyle => const _Stub();
  static dynamic get smallTextStyle => const _Stub();
  static dynamic get hintTextStyle => const _Stub();
  static dynamic get settingTrailing => const _Stub();
}

class AllpassUI {
  AllpassUI._();
  static const dynamic smallRadius = null;
  static const dynamic smallBorderRadius = null;
}

class BaseModel {
  BaseModel();
  dynamic get color => null;
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
  dynamic get uniqueKey => 'card_0508_a1';
  set uniqueKey(dynamic _) {}
  dynamic get name => 'Chase Sapphire Preferred';
  set name(dynamic _) {}
  dynamic get ownerName => 'Alex Morgan';
  set ownerName(dynamic _) {}
  dynamic get cardId => '4539 8712 3456 7890';
  set cardId(dynamic _) {}
  dynamic get password => 'U2FsdGVkX1+9kQ3mZp8vTQ==';
  set password(dynamic _) {}
  dynamic get telephone => '+1 415 555 0142';
  set telephone(dynamic _) {}
  dynamic get folder => 'Finance';
  set folder(dynamic _) {}
  dynamic get notes =>
      'Billing address on file. PIN was reset at the branch on 2025-11-03.';
  set notes(dynamic _) {}
  dynamic get label => <String>[];
  set label(dynamic _) {}
  dynamic get fav => 0;
  set fav(dynamic _) {}
  dynamic get createTime => '2025-11-03 14:22:07';
  set createTime(dynamic _) {}
  dynamic get sortNumber => 0;
  set sortNumber(dynamic _) {}
  dynamic get gradientColor => null;
  set gradientColor(dynamic _) {}
  static dynamic fromJson(dynamic map) => CardBean();
  dynamic toJson() => <String, dynamic>{};
  static dynamic toCsv(dynamic bean) => '';
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
  dynamic delete(dynamic list) => const _Stub();
}

class EncryptUtil {
  EncryptUtil._();
  static dynamic get initialKey => 'a7f3c9e15b2d48h6';
  static set initialKey(dynamic _) {}
  static dynamic initEncrypt({dynamic needFresh}) =>
      Future<String?>.value(null);
  static dynamic initEncryptByKey(dynamic key) => const _Stub();
  static dynamic getStoreKey() => Future<String?>.value(null);
  static dynamic clearEncrypt() => const _Stub();
  static dynamic getEncryption() => const _Stub();
  static dynamic encrypt(dynamic password) => 'U2FsdGVkX1+9kQ3mZp8vTQ==';
  static dynamic decrypt(dynamic encryptTxt) => 'Tr0ub4dor&3-chase';
  static dynamic generateRandomKey(
    dynamic len, {
    dynamic cap,
    dynamic low,
    dynamic number,
    dynamic sym,
  }) => 'kL9mQ2vX7pR4';
  static const dynamic storeKey = 'allpass_encrypt_key';
}

extension L10nSupport on BuildContext {
  dynamic get l10n => const AppLocalizations('en');
}

class ThemeProvider extends ChangeNotifier {
  ThemeProvider();
  dynamic get appTheme => const _Stub();
  dynamic get specialBackgroundColor => const _Stub();
  set specialBackgroundColor(dynamic _) {}
  dynamic get offstageColor => const _Stub();
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
  dynamic get successContentColor => const _Stub();
  set successContentColor(dynamic _) {}
  dynamic get successBackgroundColor => const _Stub();
  set successBackgroundColor(dynamic _) {}
  dynamic get infoContentColor => const _Stub();
  set infoContentColor(dynamic _) {}
  dynamic get infoBackgroundColor => const _Stub();
  set infoBackgroundColor(dynamic _) {}
  dynamic get warningContentColor => const _Stub();
  set warningContentColor(dynamic _) {}
  dynamic get waringBackgroundColor => const _Stub();
  set waringBackgroundColor(dynamic _) {}
  dynamic get errorContentColor => const _Stub();
  set errorContentColor(dynamic _) {}
  dynamic get errorBackgroundColor => const _Stub();
  set errorBackgroundColor(dynamic _) {}
  dynamic get iconColor => const _Stub();
  set iconColor(dynamic _) {}
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

extension WatchContext on BuildContext {
  dynamic watch<T>() => const _Stub();
}

class AppLocalizations {
  const AppLocalizations(dynamic locale);
  dynamic get localeName => 'en';
  static const dynamic delegate = null;
  static const dynamic localizationsDelegates = null;
  static const dynamic supportedLocales = null;
  dynamic get allpass => 'Allpass';
  dynamic get appError => 'App Error';
  dynamic get appErrorHint1 => 'Something went wrong while loading this page.';
  dynamic get appErrorHint2 => 'Please restart Allpass and try again.';
  dynamic get enabled => 'Enabled';
  dynamic get disabled => 'Disabled';
  dynamic get unlock => 'Unlock';
  dynamic get unlockAllpass => 'Unlock Allpass';
  dynamic get pleaseInputMainPassword => 'Please enter your master password';
  dynamic get useBiometrics => 'Use biometrics';
  dynamic get notEnableBiometricsYet => 'Biometric unlock is not enabled yet';
  dynamic get errorExceedThreshold => 'Too many failed attempts';
  dynamic get clickToUseBiometrics => 'Tap to unlock with biometrics';
  dynamic get usePassword => 'Use password';
  dynamic get inputMainPasswordTimingHint =>
      'Choose when Allpass asks for the master password';
  dynamic get verificationSuccess => 'Verified';
  dynamic get mainPasswordErrorHint => 'The master password is incorrect';
  dynamic get biometricsRecognizedFailed => 'Biometrics not recognized';
  dynamic get pleaseInputMainPasswordFirst =>
      'Enter your master password first';
  dynamic get unlockSuccess => 'Unlocked';
  dynamic get notSetupYet => 'Not set up yet';
  dynamic get appHasForceLock => 'Allpass has been locked';
  dynamic get setupAllpass => 'Set up Allpass';
  dynamic get pleaseInputAgain => 'Please enter it again';
  dynamic get setup => 'Set up';
  dynamic get passwordNotSame => 'The two passwords do not match';
  dynamic get passwordTooShort => 'The password is too short';
  dynamic get setupSuccess => 'Setup complete';
  dynamic get alreadySetup => 'Already set up';
  dynamic get serviceTerms => 'Terms of Service';
  dynamic get confirmServiceTerms =>
      'I have read and accept the Terms of Service';
  dynamic get cancel => 'Cancel';
  dynamic get password => 'Password';
  dynamic get passwords => 'Passwords';
  dynamic get addPasswordItem => 'Add password';
  dynamic get passwordEmptyHint => 'No passwords saved yet';
  dynamic get selectOnePasswordAtLeast => 'Select at least one password';
  dynamic get confirmDelete => 'Confirm delete';
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
  dynamic get url => 'URL';
  dynamic get urlCopied => 'URL copied';
  dynamic get ownerApp => 'App';
  dynamic get openAppFailed => 'Could not open the app';
  dynamic get notes => 'Notes';
  dynamic get emptyNotes => 'No notes';
  dynamic get label => 'Label';
  dynamic get labels => 'Labels';
  dynamic get accountPasswordCopied => 'Account and password copied';
  dynamic get deletePasswordWaring =>
      'This password will be permanently deleted';
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
  dynamic get deleteCardWarning => 'This card will be permanently deleted';
  dynamic get createPassword => 'Create password';
  dynamic get updatePassword => 'Update password';
  dynamic get createSuccess => 'Created';
  dynamic get updateSuccess => 'Updated';
  dynamic get upsertPasswordRule => 'Name and password are required';
  dynamic get name => 'Name';
  dynamic get folder => 'Folder';
  dynamic get folderTitle => 'Folders';
  dynamic get setToNone => 'Set to none';
  dynamic get addNotes => 'Add notes';
  dynamic get passwordGenerator => 'Password generator';
  dynamic get symbols => 'Symbols';
  dynamic get generate => 'Generate';
  dynamic get pleaseSelectOneItemAtLeast => 'Select at least one item';
  dynamic get close => 'Close';
  dynamic get createCard => 'Create card';
  dynamic get updateCard => 'Update card';
  dynamic get cardPasswordEmptyAutoGen =>
      'Leave the password empty to generate one automatically';
  dynamic get upsertCardRule => 'Name and card number are required';
  dynamic get settings => 'Settings';
  dynamic get mainPasswordManager => 'Master password';
  dynamic get biometricAuthentication => 'Biometric authentication';
  dynamic get enableBiometricSuccess => 'Biometric unlock enabled';
  dynamic get disableBiometricSuccess => 'Biometric unlock disabled';
  dynamic get biometricNotAvailable =>
      'Biometrics are not available on this device';
  dynamic get authorizationFailed => 'Authorization failed';
  dynamic get biometricNotSupport => 'This device does not support biometrics';
  dynamic get autoLock => 'Auto lock';
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
  dynamic get shareToFriends => 'Share with friends';
  dynamic get feedback => 'Feedback';
  dynamic get checkUpdate => 'Check for updates';
  dynamic get about => 'About';
  dynamic get shareAllpassSubject => 'Allpass, an open source password manager';
  dynamic get pleaseSelect => 'Please select';
  dynamic get authorizeToUnlock => 'Authenticate to unlock Allpass';
  dynamic get gotoSettings => 'Open settings';
  dynamic get iosGoToSettingsDescFace =>
      'Face ID is not set up. Enable it in Settings.';
  dynamic get iosGoToSettingsDescFingerprint =>
      'Touch ID is not set up. Enable it in Settings.';
  dynamic get iosGoToSettingsDescIris =>
      'Iris unlock is not set up. Enable it in Settings.';
  dynamic get iosGoToSettingsDescDefault =>
      'Biometrics are not set up. Enable them in Settings.';
  dynamic get iosLogoutFace => 'Cancel Face ID';
  dynamic get iosLogoutFingerprint => 'Cancel Touch ID';
  dynamic get iosLogoutIris => 'Cancel iris unlock';
  dynamic get androidGoToSettingsDesc =>
      'Biometrics are not set up. Enable them in system settings.';
  dynamic get biometricRequiredTitle => 'Biometrics required';
  dynamic get signInTitle => 'Sign in to Allpass';
  dynamic get biometricHint => 'Verify your identity';
  dynamic get modifyMainPassword => 'Change master password';
  dynamic get inputMainPasswordTiming => 'Ask for master password';
  dynamic get secretKeyUpdate => 'Update encryption key';
  dynamic get clearAllData => 'Erase all data';
  dynamic get lockAllpass => 'Lock Allpass';
  dynamic get never => 'Never';
  dynamic get sevenDays => '7 days';
  dynamic get tenDays => '10 days';
  dynamic get fifteenDays => '15 days';
  dynamic get thirtyDays => '30 days';
  dynamic get confirmSelect => 'Confirm';
  dynamic get selectNeverWarning =>
      'Allpass will never ask for the master password again';
  dynamic get confirmClearAll => 'Erase everything?';
  dynamic get clearAllWaring =>
      'All passwords and cards will be deleted permanently';
  dynamic get clearAllSuccess => 'All data erased';
  dynamic get mainPasswordIncorrect => 'Master password incorrect';
  dynamic get oldPassword => 'Current password';
  dynamic get newPassword => 'New password';
  dynamic get pleaseInputOldPassword => 'Enter your current password';
  dynamic get pleaseInputNewPassword => 'Enter a new password';
  dynamic get modifySuccess => 'Changed';
  dynamic get modifyPasswordFail => 'Could not change the password';
  dynamic get oldPasswordIncorrect => 'Current password incorrect';
  dynamic get secretKeyUpdateHelp1 =>
      'Allpass encrypts every password and card with a secret key.';
  dynamic get secretKeyUpdateHelp2 =>
      'Older versions derived that key from a fixed seed.';
  dynamic get secretKeyUpdateHelp3 =>
      'Newer versions generate a random key for each install.';
  dynamic get secretKeyUpdateHelp4 =>
      'Updating the key re-encrypts every existing record.';
  dynamic get secretKeyUpdateHelp5 =>
      'The update runs entirely on this device.';
  dynamic get secretKeyUpdateHelp6 =>
      'Nothing is uploaded while the key is being updated.';
  dynamic get secretKeyUpdateHelp7 =>
      'Back up your data before starting the update.';
  dynamic get secretKeyUpdateHelp8 =>
      'The update may take a moment on a large library.';
  dynamic get secretKeyUpdateHelp9 =>
      'Do not close Allpass while the update is running.';
  dynamic get secretKeyUpdateHelp10 =>
      'Records already using the new key are skipped.';
  dynamic get secretKeyUpdateHelp11 =>
      'If the update fails, your old data is left untouched.';
  dynamic get secretKeyUpdateHelp12 =>
      'After updating, older WebDAV backups can no longer be restored.';
  dynamic get secretKeyUpdateHelp13 =>
      'Create a fresh backup once the update finishes.';
  dynamic get secretKeyUpdateHelp14 =>
      'Keep a copy of the generated key somewhere safe.';
  dynamic get secretKeyUpdateHint => 'Generate a key, then start the upgrade';
  dynamic get generateSecretKey => 'Generate key';
  dynamic get generateSecretKeyDone => 'Key generated';
  dynamic get startUpgrade => 'Start upgrade';
  dynamic get upgradeDone => 'Upgrade complete';
  dynamic get pleaseGenerateKeyFirst => 'Generate a key first';
  dynamic get secretKeyLengthRequire => 'The key must be 16 characters long';
  dynamic get feedbackPlaceholder =>
      'Tell us what went wrong or what you would like to see';
  dynamic get feedbackContact => 'Email or other contact, optional';
  dynamic get submit => 'Submit';
  dynamic get submitting => 'Submitting';
  dynamic get feedbackContentEmptyWarning => 'Feedback cannot be empty';
  dynamic get feedbackContentTooLong => 'Feedback is too long';
  dynamic get updateContent => 'What is new';
  dynamic get recentlyUpdateContent => 'Recent changes';
  dynamic get networkErrorHelp => 'Check your connection and try again';
  dynamic get unknownErrorHelp => 'Please try again later';
  dynamic get downloadUpdate => 'Download update';
  dynamic get remindMeLatter => 'Remind me later';
  dynamic get confirm => 'Confirm';
  dynamic get themeSystem => 'System';
  dynamic get themeLight => 'Light';
  dynamic get themeDark => 'Dark';
  dynamic get themeColorBlue => 'Blue';
  dynamic get themeColorRed => 'Red';
  dynamic get themeColorTeal => 'Teal';
  dynamic get themeColorDeepPurple => 'Deep purple';
  dynamic get themeColorOrange => 'Orange';
  dynamic get themeColorPink => 'Pink';
  dynamic get themeColorBlueGrey => 'Blue grey';
  dynamic get selectExportType => 'Select what to export';
  dynamic get exportConfirm => 'Confirm export';
  dynamic get exportPasswordConfirmWarning =>
      'Exported passwords are stored as plain text';
  dynamic get exportCardConfirmWarning =>
      'Exported cards are stored as plain text';
  dynamic get passwordAndCard => 'Passwords and cards';
  dynamic get exportAllConfirmWarning =>
      'Everything will be exported as plain text';
  dynamic get importFromChrome => 'Import from Chrome';
  dynamic get importFromCsv => 'Import from CSV';
  dynamic get importFromClipboard => 'Import from clipboard';
  dynamic get exportToCsv => 'Export to CSV';
  dynamic get selectImportType => 'Select what to import';
  dynamic get importFailedNotCsv => 'The selected file is not a CSV file';
  dynamic get importCanceled => 'Import canceled';
  dynamic get importFromClipboardHelp1 =>
      'Copy the records you want to import to the clipboard.';
  dynamic get importFromClipboardHelp2 => 'Put one record on each line.';
  dynamic get importFromClipboardHelp3 =>
      'Separate the fields of a record with a comma.';
  dynamic get importFromClipboardHelp4 =>
      'Pick the format that matches your data below.';
  dynamic get importFromClipboardHelp5 =>
      'Fields you leave out are filled with defaults.';
  dynamic get importFromClipboardHelp6 =>
      'Preview the parsed records before confirming.';
  dynamic get importFromClipboardSelectFormat => 'Select clipboard format';
  dynamic get importFromClipboardFormat1 => 'Name, account, password';
  dynamic get importFromClipboardFormat2 => 'Name, account, password, URL';
  dynamic get importFromClipboardFormat3 =>
      'Name, account, password, URL, notes';
  dynamic get importFromClipboardFormat4 =>
      'Name, cardholder, card number, card password';
  dynamic get importFromClipboardFormat5 =>
      'Name, cardholder, card number, card password, phone number';
  dynamic get importFromClipboardFormat6 =>
      'Name, cardholder, card number, card password, phone number, notes';
  dynamic get importFromClipboardFormatHint =>
      'Fields must appear in the order shown';
  dynamic get importFromClipboardFormatHint2 => 'Blank lines are ignored';
  dynamic get importFromClipboardFormatHint3 =>
      'Lines that do not parse are reported and skipped';
  dynamic get pasteDataHere => 'Paste your data here';
  dynamic get startImport => 'Start import';
  dynamic get importing => 'Importing';
  dynamic get importComplete => 'Import complete';
  dynamic get importFromExternalPreview => 'Preview';
  dynamic get importFromExternalTips =>
      'Check the records below before importing';
  dynamic get confirmImport => 'Confirm import';
  dynamic get folderDisallowModify => 'This folder cannot be modified';
  dynamic get deleteLabelWarning =>
      'This label will be removed from every record';
  dynamic get deleteFolderWarning =>
      'Records in this folder will be moved to the default folder';
  dynamic get categoryNameNotValid =>
      'That name contains characters that are not allowed';
  dynamic get categoryNameNotAllowEmpty => 'The name cannot be empty';
  dynamic get autofillEnableAllpass => 'Enable Allpass autofill';
  dynamic get autofillDisableAllpass => 'Disable Allpass autofill';
  dynamic get autofillHelp => 'Allpass can fill saved accounts into other apps';
  dynamic get uploadToRemote => 'Upload to remote';
  dynamic get recoverToLocal => 'Restore to this device';
  dynamic get remoteBackupDirectory => 'Backup directory';
  dynamic get backupFileMethod => 'Backup file method';
  dynamic get dataMergeMethod => 'Merge method';
  dynamic get encryptLevel => 'Encryption level';
  dynamic get logoutAccount => 'Sign out';
  dynamic get confirmUpload => 'Confirm upload';
  dynamic get uploading => 'Uploading';
  dynamic get confirmRecover => 'Confirm restore';
  dynamic get recovering => 'Restoring';
  dynamic get pleaseInputCustomSecretKey => 'Enter a custom secret key';
  dynamic get inputCustomSecretKeyHelp =>
      'The same key is needed to restore this backup';
  dynamic get pleaseInputBackupDirectory => 'Enter a backup directory';
  dynamic get encryptHelp1 =>
      'Backups can be encrypted before they leave this device.';
  dynamic get encryptHelp2 => 'None uploads your records as plain text.';
  dynamic get encryptHelp3 => 'Only password encrypts the password fields.';
  dynamic get encryptHelp4 => 'All encrypts every field of every record.';
  dynamic get encryptHelp5 => 'The key never leaves this device.';
  dynamic get encryptHelp6 =>
      'A backup can only be restored with the key that made it.';
  dynamic get encryptHelp7 => 'Stronger levels make backups slower to upload.';
  dynamic get encryptHelp8 => 'When in doubt, choose All.';
  dynamic get confirmLogout => 'Sign out?';
  dynamic get confirmLogoutWaring =>
      'Local data is kept, but syncing will stop';
  dynamic get decryptBackupError => 'The backup could not be decrypted';
  dynamic get syncAuthFailed => 'Authentication failed';
  dynamic get syncing => 'Syncing';
  dynamic get webdavConfig => 'WebDAV configuration';
  dynamic get port => 'Port';
  dynamic get webdavServerUrl => 'Server URL';
  dynamic get webdavServerUrlHint => 'https://dav.example.com/remote.php/dav';
  dynamic get webdavServerUrlRequire => 'A server URL is required';
  dynamic get webdavPortRequire => 'A port is required';
  dynamic get webdavLoginSuccess => 'Connected';
  dynamic get webdavLoginFailed => 'Could not connect to the server';
  dynamic get nextStep => 'Next';
  dynamic get inConfiguration => 'Configuring';
  dynamic get webdavHelp1 => 'Allpass syncs through any WebDAV server.';
  dynamic get webdavHelp2 =>
      'Enter the server URL, port, user name and password.';
  dynamic get webdavHelp3 => 'Backups are written to the directory you choose.';
  dynamic get webdavExample => 'Example: https://dav.example.com:443/allpass';
  dynamic get copySuccess => 'Copied';
  dynamic get clickToViewAndEditConfig =>
      'Tap to view and edit the configuration';
  dynamic get help => 'Help';
  dynamic get modifyBackupFilename => 'Change backup file names';
  dynamic get passwordBackupFilename => 'Password backup file';
  dynamic get cardBackupFilename => 'Card backup file';
  dynamic get extraBackupFilename => 'Settings backup file';
  dynamic get filenameNotAllowSame => 'The file names must be different';
  dynamic get filenameNotAllowEmpty => 'The file name cannot be empty';
  dynamic get filenameRuleRequire =>
      'File names may contain letters, digits and underscores';
  dynamic get selectBackupFile => 'Select a backup file';
  dynamic get gettingBackupFiles => 'Loading backup files';
  dynamic get noBackupFileHint => 'No backup files found in this directory';
  dynamic get uploadFileNotExists => 'The file to upload no longer exists';
  dynamic get downloadFileFailed => 'Download failed';
  dynamic get fileNotExists => 'The file does not exist';
  dynamic get syncNeedReLogin => 'Please sign in to the server again';
  dynamic get getBackupFileFailed => 'Could not list the backup files';
  dynamic get getBackupFileFailedCheckNetwork =>
      'Could not list the backup files, check your connection';
  dynamic get uploadSuccess => 'Upload complete';
  dynamic get uploadFileFailedReject => 'The server rejected the upload';
  dynamic get uploadFileFailedCheckNetwork =>
      'Upload failed, check your connection';
  dynamic get downloadComplete => 'Download complete';
  dynamic get unsupportedBackupFile => 'This backup file is not supported';
  dynamic get backupFileCorrupt => 'The backup file is damaged';
  dynamic get backupFileNotFound => 'Backup file not found';
  dynamic get networkError => 'Network error';
  dynamic get folderLabel => 'Folders and labels';
  dynamic get recoverySuccess => 'Restore complete';
  dynamic get mergeMethodLocalFirst => 'Local data wins';
  dynamic get mergeMethodRemoteFirst => 'Remote data wins';
  dynamic get mergeMethodOnlyRemote => 'Replace with remote data';
  dynamic get mergeMethodLocalFirstHelp =>
      'Keeps the local record when both sides changed';
  dynamic get mergeMethodRemoteFirstHelp =>
      'Keeps the remote record when both sides changed';
  dynamic get mergeMethodOnlyRemoteHelp =>
      'Deletes local records and restores the backup as is';
  dynamic get encryptLevelNone => 'None';
  dynamic get encryptLevelOnlyPassword => 'Only passwords';
  dynamic get encryptLevelAll => 'Everything';
  dynamic get encryptLevelNoneHelp =>
      'Fastest, but the backup is readable by anyone';
  dynamic get encryptLevelOnlyPasswordHelp =>
      'Encrypts the password fields only';
  dynamic get encryptLevelAllHelp => 'Encrypts every field, recommended';
  dynamic get backupMethodCreateNew => 'Create a new file';
  dynamic get backupMethodReplaceExists => 'Replace the existing file';
  dynamic get searchHint => 'Search passwords and cards';
  dynamic get searchResultEmpty => 'No matches';
  dynamic get view => 'View';
  dynamic get edit => 'Edit';
  dynamic get copyUsername => 'Copy user name';
  dynamic get usernameCopied => 'User name copied';
  dynamic get copyPassword => 'Copy password';
  dynamic get deletePassword => 'Delete password';
  dynamic get copyOwnerName => 'Copy cardholder';
  dynamic get ownerNameCopied => 'Cardholder copied';
  dynamic get copyCardId => 'Copy card number';
  dynamic get deleteCard => 'Delete card';
  dynamic get fav => 'Favorite';
  dynamic get favorites => 'Favorites';
  dynamic get allpassIntroduction =>
      'Allpass is an open source password manager that keeps your data on your own device';
  dynamic get enterDebugMode => 'Enter debug mode';
  dynamic get contact => 'Contact';
  dynamic get website => 'Website';
  dynamic get contact1 => 'GitHub';
  dynamic get contact1Url => 'https://github.com/allpass-app/allpass';
  dynamic get contact2 => 'support@allpass.app';
  dynamic get contact3 => 'Telegram @allpass';
  dynamic get projectUrl => 'https://github.com/allpass-app/allpass';
  dynamic get gitee => 'https://gitee.com/allpass/allpass';
  dynamic get defaultFolder => 'Default';
  dynamic get folderEntertainment => 'Entertainment';
  dynamic get folderOffice => 'Work';
  dynamic get folderFinance => 'Finance';
  dynamic get folderGame => 'Games';
  dynamic get folderForum => 'Forums';
  dynamic get folderEducation => 'Education';
  dynamic get folderSocial => 'Social';
  dynamic get debugListInstalledApp => 'List installed apps';
  dynamic get debugPageTest => 'Page test';
  dynamic get debugListSp => 'List shared preferences';
  dynamic get debugDeleteAllPassword => 'Delete all passwords';
  dynamic get debugDeleteAllCard => 'Delete all cards';
  dynamic get debugDeletePasswordDB => 'Drop the password database';
  dynamic get debugDeleteCardDB => 'Drop the card database';
  dynamic get debugAllPasswordDeleted => 'All passwords deleted';
  dynamic get debugAllCardDeleted => 'All cards deleted';
  dynamic get debugPasswordDBDeleted => 'Password database dropped';
  dynamic get debugCardDBDeleted => 'Card database dropped';
  dynamic get importFromChromeTips1 =>
      'Open Chrome and go to Settings, then Passwords.';
  dynamic get importFromChromeTips2 =>
      'Choose Export passwords and save the CSV file.';
  dynamic get importFromChromeTips3 => 'Come back here and pick that file.';
  dynamic get storagePermissionDenied => 'Storage permission denied';
  // HAND-AUTHORED 2026-09-15. Was `=> null`, and every call site writes
  // `AppLocalizations.of(context)!` -- so the bang threw `Null check operator used on a null
  // value` inside `build` and the device drew Flutter's error box. The generator had already
  // reconstructed every string this class hands back; returning an instance is what lets the
  // transplant reach them.
  static dynamic of(dynamic context) => AppLocalizations(null);
  dynamic lockingRemains(dynamic lockSeconds) => '';
  dynamic mainPasswordError(dynamic inputErrorTimes) => '';
  dynamic deletePasswordsWarning(dynamic count) => '';
  dynamic deletePasswordsSuccess(dynamic count) => '';
  dynamic movePasswordsSuccess(dynamic count, dynamic folder) => '';
  dynamic searchButton(dynamic type) => '';
  dynamic deleteCardsWarning(dynamic count) => '';
  dynamic deleteCardsSuccess(dynamic count) => '';
  dynamic moveCardsSuccess(dynamic count, dynamic folder) => '';
  dynamic accountPassword(dynamic account, dynamic password) => '';
  dynamic createLabelSuccess(dynamic tag) => '';
  dynamic labelAlreadyExists(dynamic tag) => '';
  dynamic shareAllpassDesc(dynamic downloadUrl) => '';
  dynamic nDays(dynamic n) => '';
  dynamic secretKeyUpgradeResult(dynamic passwordCount, dynamic cardCount) =>
      '';
  dynamic secretKeyUpgradeFailed(dynamic error) => '';
  dynamic updateAvailable(dynamic channel, dynamic version) => '';
  dynamic alreadyLatestVersion(dynamic channel, dynamic version) => '';
  dynamic networkErrorMsg(dynamic message) => '';
  dynamic unknownError(dynamic message) => '';
  dynamic exportFailed(dynamic message) => '';
  dynamic importRecordSuccess(dynamic count) => '';
  dynamic recordFormatIncorrect(dynamic n) => '';
  dynamic categoryManagement(dynamic categoryName) => '';
  dynamic createCategory(dynamic categoryName) => '';
  dynamic createCategorySuccess(dynamic categoryName, dynamic name) => '';
  dynamic categoryAlreadyExists(dynamic categoryName, dynamic name) => '';
  dynamic updateCategory(dynamic categoryName) => '';
  dynamic updateCategorySuccess(dynamic categoryName, dynamic name) => '';
  dynamic deleteCategory(dynamic categoryName) => '';
  dynamic pleaseInputCategoryName(dynamic categoryName) => '';
  dynamic categoryNameRuleRequire(dynamic categoryName) => '';
  dynamic confirmUploadWaring(dynamic encryptLevel) => '';
  dynamic confirmRecoverWarning(dynamic mergeMethod) => '';
  dynamic recoverV1FileHelp(dynamic encryptLevel, dynamic filename) => '';
  dynamic lastUploadAt(dynamic uploadTimeString) => '';
  dynamic lastRecoverAt(dynamic recoverTimeString) => '';
  dynamic currentDirectory(dynamic directory) => '';
  dynamic uploadFileFailedUnknown(dynamic message) => '';
  dynamic uploadFileFailedOther(dynamic error) => '';
  dynamic downloadFailedUnknown(dynamic message) => '';
  dynamic downloadFailedOther(dynamic error) => '';
  dynamic recoverySuccessMsg(dynamic name) => '';
  dynamic recoveryFailedMsg(dynamic error) => '';
}

// UNRESOLVED-REFERENCE STAND-INS -- reconstructed from the call sites, because the
// symbol lives in a package this file may not import or the source project's own
// dependencies were never installed. Every type here is `dynamic`.

dynamic cache = const _Stub();

dynamic password = const _Stub();

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
