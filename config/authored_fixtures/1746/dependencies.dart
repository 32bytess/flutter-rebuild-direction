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

SettingsController fixtureCtrl = SettingsController.instance;

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
  dynamic get navHome => 'Home';
  dynamic get navIsland => 'Island';
  dynamic get navApps => 'Apps';
  dynamic get navSettings => 'Settings';
  dynamic get cancel => 'Cancel';
  dynamic get confirm => 'Confirm';
  dynamic get ok => 'OK';
  dynamic get apply => 'Apply';
  dynamic get noChange => 'No changes';
  dynamic get newVersionFound => 'A new version is available';
  dynamic get later => 'Later';
  dynamic get goUpdate => 'Update';
  dynamic get sponsorSupport => 'Sponsor Support';
  dynamic get sponsorAuthor => 'Sponsor Author';
  dynamic get donorList => 'Donor List';
  dynamic get documentation => 'Documentation';
  dynamic get versionUpdatedContent => 'Version Updated Content';
  dynamic get versionUpdatedChangelog => 'Version Updated Changelog';
  dynamic get versionUpdatedStarHint => 'Enter version updated star';
  dynamic get restartScope => 'Restart Scope';
  dynamic get systemUI => 'System UI';
  dynamic get downloadManager => 'Download Manager';
  dynamic get xmsf => 'XMSF';
  dynamic get notificationTest => 'Notification Test';
  dynamic get sendTestNotification => 'Send Test Notification';
  dynamic get customTestNotification => 'Custom Test Notification';
  dynamic get customTestTitle => 'Custom Test';
  dynamic get customTestTitleHint => 'Enter custom test title';
  dynamic get customTestContent => 'Custom Test Content';
  dynamic get customTestContentHint => 'Enter custom test content';
  dynamic get clearPreviousNotification => 'Clear Previous Notification';
  dynamic get clearPreviousNotificationSubtitle =>
      'Configure clear previous notification';
  dynamic get enableFloatNotification => 'Enable Float Notification';
  dynamic get enableFloatNotificationSubtitle =>
      'Configure enable float notification';
  dynamic get notes => 'Notes';
  dynamic get detectingModuleStatus => 'Detecting Module Status';
  dynamic get moduleStatus => 'Module Status';
  dynamic get activated => 'Activated';
  dynamic get notActivated => 'Not activated';
  dynamic get enableInLSPosed => 'Enable in LSPosed';
  dynamic get enableSystemUiScopeInLSPosed =>
      'Enable System UI Scope in LSPosed';
  dynamic get updateLSPosedRequired => 'Update LSPosed Required';
  dynamic get systemNotSupported => 'System Not Supported';
  dynamic get restartRootRequired => 'Restart Root Required';
  dynamic get note1 => 'Note 1';
  dynamic get note2 => 'Note 2';
  dynamic get note3 => 'Note 3';
  dynamic get note4 => 'Note 4';
  dynamic get note5 => 'Note 5';
  dynamic get behaviorSection => 'Behavior';
  dynamic get defaultConfigSection => 'Default Config';
  dynamic get appearanceSection => 'Appearance';
  dynamic get configSection => 'Config';
  dynamic get aboutSection => 'About';
  dynamic get keepFocusNotifTitle => 'Keep Focus Notification';
  dynamic get keepFocusNotifSubtitle => 'Configure keep focus notif';
  dynamic get unlockAllFocusTitle => 'Unlock All Focus';
  dynamic get unlockAllFocusSubtitle => 'Configure unlock all focus';
  dynamic get unlockFocusAuthTitle => 'Unlock Focus Auth';
  dynamic get unlockFocusAuthSubtitle => 'Configure unlock focus auth';
  dynamic get checkUpdateOnLaunchTitle => 'Check Update on Launch';
  dynamic get checkUpdateOnLaunchSubtitle => 'Configure check update on launch';
  dynamic get debugLogTitle => 'Debug Log';
  dynamic get debugLogSubtitle => 'Configure debug log';
  dynamic get showWelcomeTitle => 'Show Welcome';
  dynamic get showWelcomeSubtitle => 'Configure show welcome';
  dynamic get openOnboardingTitle => 'Open Onboarding';
  dynamic get openOnboardingSubtitle => 'Configure open onboarding';
  dynamic get interactionHapticsTitle => 'Interaction Haptics';
  dynamic get interactionHapticsSubtitle => 'Configure interaction haptics';
  dynamic get checkUpdate => 'Check Update';
  dynamic get alreadyLatest => 'You are on the latest version';
  dynamic get roundIconTitle => 'Round Icon';
  dynamic get roundIconSubtitle => 'Configure round icon';
  dynamic get marqueeChannelTitle => 'Marquee Channel';
  dynamic get marqueeSpeedTitle => 'Marquee Speed';
  dynamic get bigIslandMaxWidthTitle => 'Big Island Max Width';
  dynamic get bigIslandMinWidthTitle => 'Big Island Min Width';
  dynamic get testNotifTooltip => 'Test Notification Tooltip';
  dynamic get themeModeTitle => 'Theme Mode';
  dynamic get themeModeSystem => 'Follow system';
  dynamic get themeModeLight => 'Light';
  dynamic get themeModeDark => 'Dark';
  dynamic get languageTitle => 'Language';
  dynamic get languageAuto => 'Follow system';
  dynamic get languageZh => '中文';
  dynamic get languageEn => 'English';
  dynamic get languageJa => '日本語';
  dynamic get languageTr => 'Türkçe';
  dynamic get exportToFile => 'Export to File';
  dynamic get exportToFileSubtitle => 'Configure export to file';
  dynamic get exportToClipboard => 'Export to Clipboard';
  dynamic get exportToClipboardSubtitle => 'Configure export to clipboard';
  dynamic get exportConfig => 'Export Config';
  dynamic get exportConfigSubtitle => 'Configure export config';
  dynamic get importFromFile => 'Import From File';
  dynamic get importFromFileSubtitle => 'Configure import from file';
  dynamic get importFromClipboard => 'Import From Clipboard';
  dynamic get importFromClipboardSubtitle => 'Configure import from clipboard';
  dynamic get importConfig => 'Import Config';
  dynamic get importConfigSubtitle => 'Configure import config';
  dynamic get qqGroup => 'QQ Group';
  dynamic get restartScopeApp => 'Restart Scope App';
  dynamic get groupNumberCopied => 'Group Number Copied';
  dynamic get configCopied => 'Config Copied';
  dynamic get appAdaptation => 'App Adaptation';
  dynamic get toastAdaptation => 'Toast Adaptation';
  dynamic get adaptationModeNotification => 'Adaptation Mode Notification';
  dynamic get adaptationModeToast => 'Adaptation Mode Toast';
  dynamic get cancelSelection => 'Cancel Selection';
  dynamic get deselectAll => 'Deselect all';
  dynamic get selectAll => 'Select all';
  dynamic get batchChannelSettings => 'Batch Channel Settings';
  dynamic get selectEnabledApps => 'Select Enabled Apps';
  dynamic get batchEnable => 'Batch Enable';
  dynamic get batchDisable => 'Batch Disable';
  dynamic get multiSelect => 'Multiple selection';
  dynamic get showSystemApps => 'Show system apps';
  dynamic get refreshList => 'Refresh list';
  dynamic get enableAll => 'Enable all';
  dynamic get disableAll => 'Disable all';
  dynamic get searchApps => 'Search apps';
  dynamic get noAppsFound => 'No apps found';
  dynamic get noMatchingApps => 'No matching apps';
  dynamic get applyingConfig => 'Applying Config';
  dynamic get cannotReadChannels => 'Cannot Read Channels';
  dynamic get rootRequiredMessage => 'Root Required Message';
  dynamic get enableAllChannels => 'Enable All Channels';
  dynamic get noChannelsFound => 'No Channels Found';
  dynamic get noChannelsFoundSubtitle => 'Configure no channels found';
  dynamic get appDisabledBanner => 'App Disabled Banner';
  dynamic get channelSettings => 'Channel Settings';
  dynamic get toastForwardTitle => 'Toast Forward';
  dynamic get toastForwardSubtitle => 'Configure toast forward';
  dynamic get toastBlockOriginalTitle => 'Toast Block Original';
  dynamic get toastBlockOriginalSubtitle => 'Configure toast block original';
  dynamic get toastShowNotificationTitle => 'Toast Show Notification';
  dynamic get toastShowNotificationSubtitle =>
      'Configure toast show notification';
  dynamic get toastShowIslandIconTitle => 'Toast Show Island Icon';
  dynamic get toastShowIslandIconSubtitle => 'Configure toast show island icon';
  dynamic get toastStandardOnlyHint => 'Enter toast standard only';
  dynamic get importanceNone => 'None';
  dynamic get importanceMin => 'Minimum';
  dynamic get importanceLow => 'Low';
  dynamic get importanceDefault => 'Default';
  dynamic get importanceHigh => 'High';
  dynamic get importanceUnknown => 'Unknown';
  dynamic get templateDownloadName => 'Template Download';
  dynamic get templateNotificationIslandName => 'Template Notification Island';
  dynamic get templateNotificationIslandLiteName =>
      'Template Notification Island Lite';
  dynamic get templateDownloadLiteName => 'Template Download Lite';
  dynamic get islandSection => 'Island';
  dynamic get template => 'Template';
  dynamic get rendererLabel => 'Renderer';
  dynamic get rendererImageTextWithButtons4Name =>
      'Renderer Image Text with Buttons 4';
  dynamic get rendererCoverInfoName => 'Renderer Cover Info';
  dynamic get rendererImageTextWithRightTextButtonName =>
      'Renderer Image Text with Right Text Button';
  dynamic get rendererImageTextWithProgressName =>
      'Renderer Image Text with Progress';
  dynamic get islandIcon => 'Island Icon';
  dynamic get islandIconLabel => 'Island Icon';
  dynamic get islandIconLabelSubtitle => 'Configure island icon label';
  dynamic get focusIconLabel => 'Focus Icon';
  dynamic get focusExpressionCustomizationSection =>
      'Focus Expression Customization';
  dynamic get islandExpressionCustomizationSection =>
      'Island Expression Customization';
  dynamic get aodSection => 'AOD';
  dynamic get expandCustomization => 'Expand Customization';
  dynamic get collapseCustomization => 'Collapse Customization';
  dynamic get availablePlaceholdersLabel => 'Available Placeholders';
  dynamic get expressionFunctionsLabel => 'Expression Functions';
  dynamic get focusTitleExprLabel => 'Focus Title Expression';
  dynamic get focusContentExprLabel => 'Focus Content Expression';
  dynamic get focusIconSourceLabel => 'Focus Icon Source';
  dynamic get focusPicProfileSourceLabel => 'Focus Pic Profile Source';
  dynamic get focusAppIconPkgLabel => 'Focus App Icon package';
  dynamic get focusSecondaryIconSourceLabel => 'Focus Secondary Icon Source';
  dynamic get chatTitleColorLabel => 'Chat Title Color';
  dynamic get chatTitleColorDarkLabel => 'Chat Title Color Dark';
  dynamic get chatContentColorLabel => 'Chat Content Color';
  dynamic get chatContentColorDarkLabel => 'Chat Content Color Dark';
  dynamic get progressColorLabel => 'Progress Color';
  dynamic get progressBarColorLabel => 'Progress Bar Color';
  dynamic get progressBarColorEndLabel => 'Progress Bar Color End';
  dynamic get placeholderTitle => 'Placeholder';
  dynamic get placeholderSubtitle => 'Configure placeholder';
  dynamic get placeholderSubtitleOrTitle => 'Placeholder Subtitle or';
  dynamic get placeholderPkg => 'Placeholder package';
  dynamic get placeholderChannelId => 'Placeholder Channel ID';
  dynamic get placeholderProgress => 'Placeholder Progress';
  dynamic get placeholderStateLabel => 'Placeholder State';
  dynamic get placeholderProgressText => 'Placeholder Progress Text';
  dynamic get placeholderAiLeft => 'Placeholder AI Left';
  dynamic get placeholderAiRight => 'Placeholder AI Right';
  dynamic get placeholderRawTitle => 'Placeholder Raw';
  dynamic get placeholderRawSubtitle => 'Configure placeholder raw';
  dynamic get placeholderRawSubtitleOrTitle => 'Placeholder Raw Subtitle or';
  dynamic get islandLeftExprLabel => 'Island Left Expression';
  dynamic get islandRightExprLabel => 'Island Right Expression';
  dynamic get aodTextSwitchLabel => 'AOD Text Switch';
  dynamic get aodTextExprLabel => 'AOD Text Expression';
  dynamic get aodIconSourceLabel => 'AOD Icon Source';
  dynamic get focusNotificationLabel => 'Focus Notification';
  dynamic get hideNotificationLabel => 'Hide Notification';
  dynamic get hideNotificationLabelSubtitle =>
      'Configure hide notification label';
  dynamic get preserveStatusBarSmallIconLabel =>
      'Preserve Status Bar Small Icon';
  dynamic get restoreLockscreenTitle => 'Restore Lockscreen';
  dynamic get restoreLockscreenSubtitle => 'Configure restore lockscreen';
  dynamic get firstFloatLabel => 'First Float';
  dynamic get updateFloatLabel => 'Update Float';
  dynamic get autoDisappear => 'Auto Disappear';
  dynamic get seconds => 'seconds';
  dynamic get highlightColorLabel => 'Highlight Color';
  dynamic get dynamicHighlightColorLabel => 'Dynamic Highlight Color';
  dynamic get dynamicHighlightColorLabelSubtitle =>
      'Configure dynamic highlight color label';
  dynamic get followDynamicColorLabel => 'Follow Dynamic Color';
  dynamic get dynamicHighlightModeDark => 'Dynamic Highlight Mode Dark';
  dynamic get dynamicHighlightModeDarker => 'Dynamic Highlight Mode Darker';
  dynamic get outerGlowLabel => 'Outer Glow';
  dynamic get forceOuterGlowLabel => 'Force Outer Glow';
  dynamic get forceFocusOuterGlowSubtitle => 'Configure force focus outer glow';
  dynamic get forceIslandOuterGlowSubtitle =>
      'Configure force island outer glow';
  dynamic get outEffectColorLabel => 'Out Effect Color';
  dynamic get highlightColorHint => 'Enter highlight color';
  dynamic get actionBgColorLabel => 'Action Background Color';
  dynamic get actionBgColorDarkLabel => 'Action Background Color Dark';
  dynamic get actionTitleColorLabel => 'Action Title Color';
  dynamic get actionTitleColorDarkLabel => 'Action Title Color Dark';
  dynamic get action1BgColorLabel => 'Action 1 Background Color';
  dynamic get action1BgColorDarkLabel => 'Action 1 Background Color Dark';
  dynamic get action1TitleColorLabel => 'Action 1 Title Color';
  dynamic get action1TitleColorDarkLabel => 'Action 1 Title Color Dark';
  dynamic get action2BgColorLabel => 'Action 2 Background Color';
  dynamic get action2BgColorDarkLabel => 'Action 2 Background Color Dark';
  dynamic get action2TitleColorLabel => 'Action 2 Title Color';
  dynamic get action2TitleColorDarkLabel => 'Action 2 Title Color Dark';
  dynamic get textHighlightLabel => 'Text Highlight';
  dynamic get narrowFontLabel => 'Narrow Font';
  dynamic get showLeftHighlightLabel => 'Show Left Highlight';
  dynamic get showRightHighlightLabel => 'Show Right Highlight';
  dynamic get showLeftHighlightShort => 'Show Left Highlight Short';
  dynamic get showRightHighlightShort => 'Show Right Highlight Short';
  dynamic get colorHue => 'Color Hue';
  dynamic get colorSaturation => 'Color Saturation';
  dynamic get colorBrightness => 'Color Brightness';
  dynamic get colorOpacity => 'Color Opacity';
  dynamic get onlyEnabledChannels => 'Only Enabled Channels';
  dynamic get iconModeAuto => 'Icon Mode Auto';
  dynamic get iconModeNotifSmall => 'Icon Mode Notification Small';
  dynamic get iconModeNotifLarge => 'Icon Mode Notification Large';
  dynamic get iconModeAppIcon => 'Icon Mode App Icon';
  dynamic get optDefault => 'Follow default';
  dynamic get optDefaultOn => 'Default (on)';
  dynamic get optDefaultOff => 'Default (off)';
  dynamic get optOn => 'On';
  dynamic get optOff => 'Off';
  dynamic get errorInvalidFormat => 'Invalid format';
  dynamic get errorNoStorageDir => 'No storage dir';
  dynamic get errorNoFileSelected => 'No file selected';
  dynamic get errorNoFilePath => 'No file path';
  dynamic get errorEmptyClipboard => 'Empty clipboard';
  dynamic get navBlacklist => 'Blacklist';
  dynamic get navBlacklistSubtitle => 'Configure nav blacklist';
  dynamic get presetGamesTitle => 'Preset Games';
  dynamic get firstFloatLabelSubtitle => 'Configure first float label';
  dynamic get updateFloatLabelSubtitle => 'Configure update float label';
  dynamic get marqueeChannelTitleSubtitle => 'Configure marquee channel';
  dynamic get focusNotificationLabelSubtitle =>
      'Configure focus notification label';
  dynamic get preserveStatusBarSmallIconLabelSubtitle =>
      'Configure preserve status bar small icon label';
  dynamic get fullscreenBehaviorTitle => 'Fullscreen Behavior';
  dynamic get fullscreenBehaviorSubtitle => 'Configure fullscreen behavior';
  dynamic get fullscreenBehaviorOff => 'Fullscreen Behavior Off';
  dynamic get fullscreenBehaviorFallback => 'Fullscreen Behavior Fallback';
  dynamic get fullscreenBehaviorExpand => 'Fullscreen Behavior Expand';
  dynamic get filterRulesTitle => 'Filter Rules';
  dynamic get filterRulesOrderTitle => 'Filter Rules Order';
  dynamic get filterRuleDnd => 'Filter Rule DND';
  dynamic get filterRuleFullscreen => 'Filter Rule Fullscreen';
  dynamic get filterRuleLandscape => 'Filter Rule Landscape';
  dynamic get dndBehaviorTitle => 'DND Behavior';
  dynamic get fullscreenRuleTitle => 'Fullscreen Rule';
  dynamic get landscapeRuleTitle => 'Landscape Rule';
  dynamic get behaviorPreviewDefault => 'Behavior Preview Default';
  dynamic get behaviorPreviewSuppress => 'Behavior Preview Suppress';
  dynamic get behaviorPreviewSmallOnly => 'Behavior Preview Small Only';
  dynamic get behaviorPreviewExpand => 'Behavior Preview Expand';
  dynamic get aiConfigSection => 'AI Config';
  dynamic get aiConfigTitle => 'AI Config';
  dynamic get aiConfigSubtitleEnabled => 'AI Config Subtitle Enabled';
  dynamic get aiConfigSubtitleDisabled => 'AI Config Subtitle Disabled';
  dynamic get aiEnabledTitle => 'AI Enabled';
  dynamic get aiEnabledSubtitle => 'Configure ai enabled';
  dynamic get aiApiSection => 'AI API';
  dynamic get aiUrlLabel => 'AI URL';
  dynamic get aiUrlHint => 'Enter ai url';
  dynamic get aiApiKeyLabel => 'AI API Key';
  dynamic get aiApiKeyHint => 'Enter ai api key';
  dynamic get aiModelLabel => 'AI Model';
  dynamic get aiModelHint => 'Enter ai model';
  dynamic get aiPromptLabel => 'AI Prompt';
  dynamic get aiPromptHint => 'Enter ai prompt';
  dynamic get aiPromptInUserTitle => 'AI Prompt in User';
  dynamic get aiPromptInUserSubtitle => 'Configure ai prompt in user';
  dynamic get aiTimeoutTitle => 'AI Timeout';
  dynamic get aiTemperatureTitle => 'AI Temperature';
  dynamic get aiTemperatureSubtitle => 'Configure ai temperature';
  dynamic get aiMaxTokensTitle => 'AI Max Tokens';
  dynamic get aiMaxTokensSubtitle => 'Configure ai max tokens';
  dynamic get aiDefaultPromptFull => 'AI Default Prompt Full';
  dynamic get aiTestButton => 'AI Test Button';
  dynamic get aiTestUrlEmpty => 'AI Test URL Empty';
  dynamic get aiLastLogTitle => 'AI Last Log';
  dynamic get aiLastLogSubtitle => 'Configure ai last log';
  dynamic get aiLastLogEmpty => 'AI Last Log Empty';
  dynamic get aiLastLogSourceLabel => 'AI Last Log Source';
  dynamic get aiLastLogTimeLabel => 'AI Last Log Time';
  dynamic get aiLastLogStatusLabel => 'AI Last Log Status';
  dynamic get aiLastLogDurationLabel => 'AI Last Log Duration';
  dynamic get aiLastLogSourceNotification => 'AI Last Log Source Notification';
  dynamic get aiLastLogSourceSettingsTest => 'AI Last Log Source Settings Test';
  dynamic get aiLastLogRendered => 'AI Last Log Rendered';
  dynamic get aiLastLogRaw => 'AI Last Log Raw';
  dynamic get aiLastLogCopy => 'AI Last Log Copy';
  dynamic get aiLastLogCopied => 'AI Last Log Copied';
  dynamic get aiLastLogRequest => 'AI Last Log Request';
  dynamic get aiLastLogResponse => 'AI Last Log Response';
  dynamic get aiLastLogUsage => 'AI Last Log Usage';
  dynamic get aiLastLogMessages => 'AI Last Log Messages';
  dynamic get aiLastLogError => 'AI Last Log Error';
  dynamic get aiLastLogHttpCode => 'AI Last Log HTTP Code';
  dynamic get aiLastLogLeftText => 'AI Last Log Left Text';
  dynamic get aiLastLogRightText => 'AI Last Log Right Text';
  dynamic get aiLastLogAssistantContent => 'AI Last Log Assistant Content';
  dynamic get aiConfigSaveButton => 'AI Config Save Button';
  dynamic get aiConfigSaved => 'AI Config Saved';
  dynamic get aiConfigTips => 'AI Config Tips';
  dynamic get templateAiNotificationIslandName =>
      'Template AI Notification Island';
  dynamic get hideDesktopIconTitle => 'Hide Desktop Icon';
  dynamic get hideDesktopIconSubtitle => 'Configure hide desktop icon';
  dynamic get filterRulesSection => 'Filter Rules';
  dynamic get foregroundRulesTab => 'Foreground Rules';
  dynamic get foregroundExclusionsTab => 'Foreground Exclusions';
  dynamic get foregroundRulesDescription => 'Foreground Rules Description';
  dynamic get foregroundExclusionsDescription =>
      'Foreground Exclusions Description';
  dynamic get hideSystemApps => 'Hide system apps';
  dynamic get restoreDefaultConfig => 'Restore Default Config';
  dynamic get sceneActionDefault => 'Scene Action Default';
  dynamic get sceneActionSmallOnly => 'Scene Action Small Only';
  dynamic get sceneActionExpand => 'Scene Action Expand';
  dynamic get sceneActionSuppress => 'Scene Action Suppress';
  dynamic get filterModeLabel => 'Filter Mode';
  dynamic get filterModeBlacklist => 'Filter Mode Blacklist';
  dynamic get filterModeWhitelist => 'Filter Mode Whitelist';
  dynamic get filterModeBlacklistDesc => 'Filter Mode Blacklist Desc';
  dynamic get filterModeWhitelistDesc => 'Filter Mode Whitelist Desc';
  dynamic get whitelistKeywordsLabel => 'Whitelist Keywords';
  dynamic get blacklistKeywordsLabel => 'Blacklist Keywords';
  dynamic get addKeyword => 'Add Keyword';
  dynamic get keywordHint => 'Enter keyword';
  dynamic get removeKeyword => 'Remove Keyword';
  dynamic get keywordFilterPriority => 'Keyword Filter Priority';
  dynamic get exportChannelsToClipboard => 'Export Channels to Clipboard';
  dynamic get importChannelsFromClipboard => 'Import Channels From Clipboard';
  dynamic get exportChannelsSuccess => 'Export Channels Success';
  dynamic get importErrorEmptyClipboard => 'Import Error Empty Clipboard';
  dynamic get importErrorNotJson => 'Import Error Not JSON';
  dynamic get importErrorMissingChannels => 'Import Error Missing Channels';
  dynamic get importErrorNoMatch => 'Import Error No Match';
  dynamic get importErrorUnknown => 'Import Error Unknown';
  dynamic get mediaNotificationTitle => 'Media Notification';
  dynamic get mediaNotificationDisabledSubtitle =>
      'Configure media notification disabled';
  dynamic get normalNotificationTitle => 'Normal Notification';
  dynamic get normalNotificationSubtitle => 'Configure normal notification';
  dynamic get channelSettingsUnmodified => 'Channel Settings Unmodified';
  dynamic get restoreDefault => 'Restore defaults';
  dynamic get islandDimenSection => 'Island Dimensions';
  dynamic get islandDimenHeight => 'Island Dimensions Height';
  dynamic get islandTopOffset => 'Island Top Offset';
  dynamic get followSystem => 'Follow system';
  dynamic get islandDimenMiniY => 'Island Dimensions Mini Y';
  dynamic get islandDimenMiniYHint => 'Enter island dimen mini y';
  dynamic get islandBgSection => 'Island Background';
  dynamic get islandBgSmallTitle => 'Island Background Small';
  dynamic get islandBgSmallSubtitle => 'Configure island bg small';
  dynamic get islandBgBigTitle => 'Island Background Big';
  dynamic get islandBgBigSubtitle => 'Configure island bg big';
  dynamic get islandBgExpandTitle => 'Island Background Expand';
  dynamic get islandBgExpandSubtitle => 'Configure island bg expand';
  dynamic get islandBgNotSet => 'Island Background Not Set';
  dynamic get islandBgCornerRadius => 'Island Background Corner Radius';
  dynamic get islandBgCornerRadiusHint => 'Enter island bg corner radius';
  dynamic get islandBgImageSelected => 'Island Background Image Selected';
  dynamic get islandBgImageDeleted => 'Island Background Image Deleted';
  dynamic get islandBgDeleteFailed => 'Island Background Delete Failed';
  dynamic get islandBgBlurLabel => 'Island Background Blur';
  dynamic get islandBgBrightnessLabel => 'Island Background Brightness';
  dynamic get islandBgOpacityLabel => 'Island Background Opacity';
  dynamic get islandBgOff => 'Island Background Off';
  dynamic get islandBgDefault => 'Island Background Default';
  dynamic get keepIslandTitle => 'Keep Island';
  dynamic get keepIslandSubtitle => 'Configure keep island';
  dynamic get keepIslandAutoHideTitle => 'Keep Island Auto Hide';
  dynamic get keepIslandAutoHideSubtitle => 'Configure keep island auto hide';
  dynamic get keepIslandHighlightColorTitle => 'Keep Island Highlight Color';
  dynamic get keepIslandHighlightColorSubtitle =>
      'Configure keep island highlight color';
  dynamic get islandOtherSection => 'Island Other';
  dynamic get miscSection => 'Misc';
  dynamic get onboardingEntryTitle => 'Onboarding Entry';
  dynamic get onboardingEntrySubtitle => 'Configure onboarding entry';
  dynamic get onboardingAppName => 'Onboarding App';
  dynamic get onboardingWelcomeTitle => 'Onboarding Welcome';
  dynamic get onboardingWelcomeSubtitle => 'Configure onboarding welcome';
  dynamic get onboardingEnvironmentTitle => 'Onboarding Environment';
  dynamic get onboardingEnvironmentSubtitle =>
      'Configure onboarding environment';
  dynamic get onboardingNotificationStyleTitle =>
      'Onboarding Notification Style';
  dynamic get onboardingNotificationStyleSubtitle =>
      'Configure onboarding notification style';
  dynamic get onboardingOriginalNotificationLabel =>
      'Onboarding Original Notification';
  dynamic get onboardingFinishTitle => 'Onboarding Finish';
  dynamic get onboardingFinishSubtitle => 'Configure onboarding finish';
  dynamic get onboardingPrevious => 'Onboarding Previous';
  dynamic get onboardingNext => 'Onboarding Next';
  dynamic get onboardingDone => 'Onboarding Done';
  dynamic get onboardingStatusTitle => 'Onboarding Status';
  dynamic get onboardingRetry => 'Onboarding Retry';
  dynamic get onboardingLsposedStatus => 'Onboarding LSPosed Status';
  dynamic get onboardingRootStatus => 'Onboarding Root Status';
  dynamic get onboardingAppListStatus => 'Onboarding App List Status';
  dynamic get onboardingProtocolStatus => 'Onboarding Protocol Status';
  dynamic get onboardingAndroidStatus => 'Onboarding Android Status';
  dynamic get onboardingUnsupportedSystem => 'Onboarding Unsupported System';
  dynamic get onboardingAndroid15Limited => 'Onboarding Android15 Limited';
  dynamic get onboardingMissingPermissionTitle =>
      'Onboarding Missing Permission';
  dynamic get onboardingMissingPermissionMessage =>
      'Onboarding Missing Permission Message';
  dynamic get onboardingDialogClose => 'Onboarding Dialog Close';
  dynamic get onboardingDialogContinue => 'Onboarding Dialog Continue';
  dynamic get backupRestoreSection => 'Backup Restore';
  dynamic get hookExtensionSection => 'Hook Extension';
  dynamic get hookScopeSettings => 'Hook Scope Settings';
  dynamic get settingsHomeEntryTitle => 'Settings Home Entry';
  dynamic get settingsHomeEntrySubtitle => 'Configure settings home entry';
  dynamic get xposedScopeRequestFailed => 'Xposed Scope Request Failed';
  dynamic get hookScopeSystemUI => 'Hook Scope System UI';
  dynamic get smoothIslandTitle => 'Smooth Island';
  dynamic get smoothIslandSubtitle => 'Configure smooth island';
  dynamic get smoothIslandSmoothingTitle => 'Smooth Island Smoothing';
  dynamic get bluetoothIslandStatusEnabled => 'Bluetooth Island Status Enabled';
  dynamic get bluetoothIslandStatusDisabled =>
      'Bluetooth Island Status Disabled';
  dynamic get bluetoothIslandTitle => 'Bluetooth Island';
  dynamic get bluetoothIslandSettingsTitle => 'Bluetooth Island Settings';
  dynamic get bluetoothIslandEnableTitle => 'Bluetooth Island Enable';
  dynamic get bluetoothIslandEnableSubtitle =>
      'Configure bluetooth island enable';
  dynamic get bluetoothIslandShowDeviceNameTitle =>
      'Bluetooth Island Show Device Name';
  dynamic get bluetoothIslandShowDeviceNameSubtitle =>
      'Configure bluetooth island show device name';
  dynamic get outerGlowTitle => 'Outer Glow';
  dynamic get bluetoothIslandOuterGlowSubtitle =>
      'Configure bluetooth island outer glow';
  dynamic get outerGlowColorTitle => 'Outer Glow Color';
  dynamic get hookScopeXMSF => 'Hook Scope XMSF';
  dynamic get downloadManagerSection => 'Download Manager';
  dynamic get themePageTitle => 'Theme Page';
  dynamic get themeSeedColorTitle => 'Theme Seed Color';
  dynamic get themeSeedColorSubtitle => 'Configure theme seed color';
  dynamic get presetColors => 'Preset Colors';
  dynamic get themeResetColor => 'Theme Reset Color';
  dynamic get blurBarsTitle => 'Blur Bars';
  dynamic get blurBarsSubtitle => 'Configure blur bars';
  dynamic get bluetoothIslandWhitelistTitle => 'Bluetooth Island Whitelist';
  dynamic get bluetoothIslandWhitelistSubtitle =>
      'Configure bluetooth island whitelist';
  dynamic get bluetoothIslandWhitelistButton =>
      'Bluetooth Island Whitelist Button';
  dynamic get bluetoothIslandWhitelistDialogTitle =>
      'Bluetooth Island Whitelist Dialog';
  dynamic get bluetoothIslandWhitelistEmpty =>
      'Bluetooth Island Whitelist Empty';
  dynamic get bluetoothIslandWhitelistAllHint =>
      'Enter bluetooth island whitelist all';
  dynamic get bluetoothIslandLoadDevicesFailed =>
      'Bluetooth Island Load Devices Failed';
  dynamic get bluetoothIslandNeedBtPermission =>
      'Bluetooth Island Need Bluetooth Permission';
  dynamic get hideBehaviorTitle => 'Hide Behavior';
  dynamic get hideBehaviorDescription =>
      'Choose the situations in which the island is temporarily hidden. Changes take effect on the next notification.';
  dynamic get hideBehaviorScreenPinning => 'Screen Pinning';
  dynamic get hideBehaviorScreenPinningSubtitle =>
      'Hide while an app is pinned to the screen';
  dynamic get hideBehaviorBouncerShowing => 'Lock Screen Password';
  dynamic get hideBehaviorBouncerShowingSubtitle =>
      'Hide while the PIN or password entry is showing';
  dynamic get hideBehaviorDesktopAnimating => 'Home Screen Animation';
  dynamic get hideBehaviorDesktopAnimatingSubtitle =>
      'Hide while the launcher is playing a transition';
  dynamic get hideBehaviorFullscreen => 'Fullscreen Apps';
  dynamic get hideBehaviorFullscreenSubtitle =>
      'Hide while an app is running in fullscreen';
  dynamic get hideBehaviorScreenLocked => 'Screen Locked';
  dynamic get hideBehaviorScreenLockedSubtitle =>
      'Hide while the device is locked';
  dynamic get hideBehaviorNotificationCenter => 'Notification Shade';
  dynamic get hideBehaviorNotificationCenterSubtitle =>
      'Hide while the notification shade is pulled down';
  dynamic get hideBehaviorControlCenter => 'Control Center';
  dynamic get hideBehaviorControlCenterSubtitle =>
      'Hide while the control center is open';
  // HAND-AUTHORED 2026-09-15 (typed stand-in return), found by the device run that validated
  // the `SettingsController.instance` repair above. Was `=> null`, and every role opens with
  // `final l10n = AppLocalizations.of(context)!;` -- so the null-check operator threw, `build`
  // died, and the device drew the error box for a second reason once the first was gone. This
  // is what the fixture repair uncovered rather than caused: the roles never got far enough to
  // reach it before.
  //
  // NO VALUE IS INVENTED HERE. `AppLocalizations` is this same class, and the ~150 getters
  // around this line already carry the English copy the generator resolved --
  // `hideBehaviorControlCenterSubtitle => 'Hide while the control center is open'` two lines
  // up. `of()` is the accessor that hands the class to the widget tree and it was the one
  // member returning nothing. The `locale` argument is unused by every getter, so `null` is
  // passed for it; the strings are constants on the class, not a function of the locale.
  //
  // String length is laid-out text, and laid-out text is line count under the same tree, so
  // these strings ARE measurement inputs. That is why the copy stays exactly as resolved.
  static dynamic of(dynamic context) => AppLocalizations(null);
  dynamic currentVersion(dynamic version) => '';
  dynamic latestVersion(dynamic version) => '';
  dynamic versionUpdatedTitle(dynamic version) => '';
  dynamic lsposedApiVersion(dynamic version) => '';
  dynamic systemNotSupportedSubtitle(dynamic version) => '';
  dynamic restartFailed(dynamic message) => '';
  dynamic marqueeSpeedLabel(dynamic speed) => '';
  dynamic bigIslandMaxWidthLabel(dynamic width) => '';
  dynamic bigIslandMinWidthLabel(dynamic width) => '';
  dynamic exportedTo(dynamic path) => '';
  dynamic exportFailed(dynamic error) => '';
  dynamic importSuccess(dynamic count) => '';
  dynamic importFailed(dynamic error) => '';
  dynamic toastEnabledAppsCount(dynamic count) => '';
  dynamic toastEnabledAppsCountWithSystem(dynamic count) => '';
  dynamic selectedAppsCount(dynamic count) => '';
  dynamic enabledAppsCount(dynamic count) => '';
  dynamic enabledAppsCountWithSystem(dynamic count) => '';
  dynamic applyToSelectedAppsChannels(dynamic count) => '';
  dynamic progressApps(dynamic done, dynamic total) => '';
  dynamic batchApplied(dynamic count) => '';
  dynamic allChannelsActive(dynamic count) => '';
  dynamic selectedChannels(dynamic selected, dynamic total) => '';
  dynamic allChannelsDisabled(dynamic count) => '';
  dynamic channelImportance(dynamic importance, dynamic id) => '';
  dynamic applyToEnabledChannels(dynamic count) => '';
  dynamic applyToAllChannels(dynamic count) => '';
  dynamic enabledChannelsCount(dynamic enabled, dynamic total) => '';
  dynamic presetGamesSuccess(dynamic count) => '';
  dynamic blacklistedAppsCount(dynamic count) => '';
  dynamic blacklistedAppsCountWithSystem(dynamic count) => '';
  dynamic aiTimeoutLabel(dynamic seconds) => '';
  dynamic resetDefaultConfigSuccess(dynamic count) => '';
  dynamic importChannelsSuccess(dynamic count) => '';
  dynamic importChannelsPartialSuffix(dynamic total, dynamic matched) => '';
  dynamic importChannelsFailed(dynamic error) => '';
  dynamic islandBgEditTitle(dynamic type) => '';
  dynamic onboardingStepLabel(dynamic current, dynamic total) => '';
  dynamic bluetoothIslandSubtitle(dynamic status) => '';
  dynamic bluetoothIslandWhitelistButtonSubtitle(dynamic count) => '';
  dynamic get hideBehaviorMasterSwitch => 'Enable Hide Rules';
  dynamic get hideBehaviorMasterSwitchSubtitle =>
      'Turn this off to keep the island visible in every situation';
  dynamic get chargeIslandTitle => 'Charge Island';
  dynamic get chargeIslandSettingsTitle => 'Charge Island Settings';
  dynamic get chargeIslandEnableTitle => 'Charge Island Enable';
  dynamic get chargeIslandEnableSubtitle => 'Configure charge island enable';
  dynamic get chargeIslandLeftModeTitle => 'Charge Island Left Mode';
  dynamic get chargeIslandRightModeTitle => 'Charge Island Right Mode';
  dynamic get chargeIslandModeDefault => 'Charge Island Mode Default';
  dynamic get chargeIslandModePower => 'Charge Island Mode Power';
  dynamic get chargeIslandModeVoltage => 'Charge Island Mode Voltage';
  dynamic get chargeIslandModeCurrent => 'Charge Island Mode Current';
  dynamic get chargeIslandModeLevel => 'Charge Island Mode Level';
  dynamic get chargeIslandModeTemperature => 'Charge Island Mode Temperature';
  dynamic get chargeIslandDurationModeTitle => 'Charge Island Duration Mode';
  dynamic get chargeIslandDurationDefault => 'Charge Island Duration Default';
  dynamic get chargeIslandDurationCustom => 'Charge Island Duration Custom';
  dynamic get chargeIslandDurationPersistent =>
      'Charge Island Duration Persistent';
  dynamic get chargeIslandDurationSecondsTitle =>
      'Charge Island Duration Seconds';
  dynamic get chargeIslandDurationSecondsUnit =>
      'Charge Island Duration Seconds Unit';
  dynamic chargeIslandSubtitle(dynamic status) => '';
  dynamic get languageRu => 'Русский';
  dynamic get chargeIslandOuterGlowSubtitle =>
      'Configure charge island outer glow';
  dynamic get aiPromptDefault => 'AI Prompt Default';
  dynamic get aiDefaultNotificationText => 'AI Default Notification Text';
  dynamic get aiTestSampleUserContent => 'AI Test Sample User Content';
  dynamic get aiJsonOnlyInstruction => 'AI JSON Only Instruction';
  dynamic get aiJsonLeftDescription => 'AI JSON Left Description';
  dynamic get aiJsonRightDescription => 'AI JSON Right Description';
  dynamic get aiInvalidJsonError => 'AI Invalid JSON Error';
  dynamic get aiEmptyJsonError => 'AI Empty JSON Error';
  dynamic get aiNotificationTestSection => 'AI Notification Test';
  dynamic get aiNotificationContentLabel => 'AI Notification Content';
  dynamic get aiTestNotificationTitle => 'AI Test Notification';
  dynamic get aiNotificationSent => 'AI Notification Sent';
  dynamic get aiAiNotificationSent => 'AI AI Notification Sent';
  dynamic get aiSendNotificationButton => 'AI Send Notification Button';
  dynamic get aiSendAiNotificationButton => 'AI Send AI Notification Button';
  dynamic aiNotificationUserContent(dynamic content) => '';
  dynamic get keepIslandHideLandscapeTitle => 'Keep Island Hide Landscape';
  dynamic get keepIslandHideLandscapeSubtitle =>
      'Configure keep island hide landscape';
  dynamic get marqueeAutoHideTitle => 'Marquee Auto Hide';
  dynamic get marqueeAutoHideSubtitle => 'Configure marquee auto hide';
  dynamic get marqueeAutoHideOff => 'Marquee Auto Hide Off';
  dynamic get marqueeAutoHideOnce => 'Marquee Auto Hide Once';
  dynamic get marqueeAutoHideTwice => 'Marquee Auto Hide Twice';
  dynamic get off => 'Off';
  dynamic get tapToSelectImage => 'Tap to Select Image';
  dynamic get autoExpandNotification => 'Auto Expand Notification';
  dynamic widthDpLabel(dynamic width) => '';
  dynamic get bluetoothIslandDisplayDurationTitle =>
      'Bluetooth Island Display Duration';
  dynamic get islandTextSection => 'Island Text';
  dynamic get islandTextColorTitle => 'Island Text Color';
  dynamic get islandTextColorBlack => 'Island Text Color Black';
  dynamic get islandTextColorFollowBackground =>
      'Island Text Color Follow Background';
  dynamic get islandTextColorInvertBackground =>
      'Island Text Color Invert Background';
  dynamic get islandTextColorFollowStatusBar =>
      'Island Text Color Follow Status Bar';
  dynamic get islandTextColorInvertStatusBar =>
      'Island Text Color Invert Status Bar';
  dynamic get islandTextColorDefault => 'Island Text Color Default';
  dynamic get islandEnabledLabel => 'Island Enabled';
  dynamic get aiModelPickerTitle => 'AI Model Picker';
  dynamic get aiModelPickerSearchHint => 'Enter ai model picker search';
  dynamic get aiModelPickerEmpty => 'AI Model Picker Empty';
  dynamic get aiModelPickerRetry => 'AI Model Picker Retry';
  dynamic get aiModelPickerClose => 'AI Model Picker Close';
  dynamic get aiModelPickerFetchError => 'AI Model Picker Fetch Error';
  dynamic get keepIslandLeftContentTitle => 'Keep Island Left Content';
  dynamic get keepIslandRightContentTitle => 'Keep Island Right Content';
  dynamic get keepIslandPlaceholdersTitle => 'Keep Island Placeholders';
  dynamic get keepIslandDefaultEmpty => 'Keep Island Default Empty';
  dynamic get clear => 'Clear';
  dynamic get save => 'Save';
  dynamic keepIslandPlaceholdersDescription(
    dynamic batteryLevel,
    dynamic cpuUsage,
  ) => '';
  dynamic keepIslandPlaceholderCopied(dynamic placeholder) => '';
  dynamic keepIslandContentHint(dynamic placeholder) => '';
  dynamic get aodTextSwitchSubtitle => 'Configure aod text switch';
  dynamic get onboardingFocusUnlockTitle => 'Onboarding Focus Unlock';
  dynamic get onboardingFocusUnlockSubtitle =>
      'Configure onboarding focus unlock';
  dynamic get onboardingFocusUnlockMethodHyperCeiler =>
      'Onboarding Focus Unlock Method Hyper Ceiler';
  dynamic get onboardingFocusUnlockHyperCeilerSubtitle =>
      'Configure onboarding focus unlock hyper ceiler';
  dynamic get onboardingFocusUnlockViewTutorial =>
      'Onboarding Focus Unlock View Tutorial';
  dynamic get onboardingFocusUnlockMethodEmbedded =>
      'Onboarding Focus Unlock Method Embedded';
  dynamic get onboardingFocusUnlockEmbeddedSubtitle =>
      'Configure onboarding focus unlock embedded';
  dynamic get onboardingFocusUnlockEmbeddedEnabled =>
      'Onboarding Focus Unlock Embedded Enabled';
  dynamic get onboardingFocusUnlockEnableButton =>
      'Onboarding Focus Unlock Enable Button';
  dynamic get onboardingFocusUnlockEnabledButton =>
      'Onboarding Focus Unlock Enabled Button';
  dynamic get onboardingFocusUnlockEnabled => 'Onboarding Focus Unlock Enabled';
  dynamic get alwaysOnIsland => 'Always on Island';
  dynamic get marqueeAutoHideOnceOverride => 'Marquee Auto Hide Once Override';
  dynamic get marqueeAutoHideTwiceOverride =>
      'Marquee Auto Hide Twice Override';
  dynamic get aiTriggerCharCountTitle => 'AI Trigger Char Count';
  dynamic get aiTriggerCharCountSubtitle => 'Configure ai trigger char count';
  dynamic get aiTriggerCharCountAlways => 'AI Trigger Char Count Always';
  dynamic get keepIslandFocusNotificationTitle =>
      'Keep Island Focus Notification';
  dynamic get keepIslandFocusNotificationSubtitle =>
      'Configure keep island focus notification';
  dynamic get keepIslandNotificationTitle => 'Keep Island Notification';
  dynamic get keepIslandNotificationContent =>
      'Keep Island Notification Content';
  dynamic get keepIslandShowIslandIconTitle => 'Keep Island Show Island Icon';
  dynamic get keepIslandShowIslandIconSubtitle =>
      'Configure keep island show island icon';
  dynamic get keepIslandCustomIconTitle => 'Keep Island Custom Icon';
  dynamic get keepIslandCustomIconSelected =>
      'Keep Island Custom Icon Selected';
  dynamic get keepIslandWeatherCategory => 'Keep Island Weather Category';
  dynamic get keepIslandDisplayCategory => 'Keep Island Display Category';
  dynamic get islandBlurSmallTitle => 'Island Blur Small';
  dynamic get islandBlurBigTitle => 'Island Blur Big';
  dynamic get islandBlurExpandTitle => 'Island Blur Expand';
  dynamic get islandBlurEnabled => 'Island Blur Enabled';
  dynamic get islandBlurRadius => 'Island Blur Radius';
  dynamic get islandBlurBlendColor => 'Island Blur Blend Color';
  dynamic get islandBlurDisabled => 'Island Blur Disabled';
  dynamic islandBlurRadiusValue(dynamic radius) => '';
  dynamic get hideBehaviorFullscreenLandscapeDisable => 'Landscape Only';
  dynamic get hideBehaviorFullscreenLandscapeDisableSubtitle =>
      'Only hide in fullscreen when the screen is in landscape';
  dynamic get islandBlurUnavailableWithBackground =>
      'Island Blur Unavailable with Background';
  dynamic get islandBlurBigTextColorSuggestion =>
      'Island Blur Big Text Color Suggestion';
  dynamic get islandOutlineSection => 'Island Outline';
  dynamic get alwaysShowIslandOutlineTitle => 'Always Show Island Outline';
  dynamic get alwaysShowFocusOutlineTitle => 'Always Show Focus Outline';
  dynamic get focusNotificationTextColorTitle =>
      'Focus Notification Text Color';
  dynamic get keepIslandTextHighlightTitle => 'Keep Island Text Highlight';
  dynamic get keepIslandHighlightLeft => 'Keep Island Highlight Left';
  dynamic get keepIslandHighlightRight => 'Keep Island Highlight Right';
  dynamic get outerGlowAppearanceSection => 'Outer Glow Appearance';
  dynamic get outerGlowRangeTitle => 'Outer Glow Range';
  dynamic get islandGlassSection => 'Island Glass';
  dynamic get islandGlassEnabled => 'Island Glass Enabled';
  dynamic get islandGlassEnabledSubtitle => 'Configure island glass enabled';
  dynamic get islandGlassRequiresBlur => 'Island Glass Requires Blur';
  dynamic get islandGlassEdgeWidth => 'Island Glass Edge Width';
  dynamic get islandGlassRefraction => 'Island Glass Refraction';
  dynamic get islandGlassHighlight => 'Island Glass Highlight';
  dynamic get islandGlassShadow => 'Island Glass Shadow';
  dynamic get islandGlassLightDirection => 'Island Glass Light Direction';
  dynamic get islandGlassDispersion => 'Island Glass Dispersion';
  dynamic get islandGlassGyroscope => 'Island Glass Gyroscope';
  dynamic get islandGlassGyroscopeSubtitle =>
      'Configure island glass gyroscope';
  dynamic get islandGlassTrueRefraction => 'Island Glass True Refraction';
  dynamic get islandGlassTrueRefractionSubtitle =>
      'Configure island glass true refraction';
  dynamic get islandGlassCaptureSettings => 'Island Glass Capture Settings';
  dynamic get islandGlassCaptureFps => 'Island Glass Capture FPS';
  dynamic get islandGlassCaptureQuality => 'Island Glass Capture Quality';
  dynamic get keepIslandTimeCategory => 'Keep Island Time Category';
  dynamic get defaultTimeoutSubtitle => 'Configure default timeout';
  dynamic get timeoutUseDefault => 'Timeout Use Default';
  dynamic get timeoutUseDefaultSubtitle => 'Configure timeout use default';
  dynamic defaultTimeoutHint(dynamic seconds) => '';
  dynamic get islandGlassHdrHighlight => 'Island Glass HDR Highlight';
  dynamic get islandGlassHdrHighlightSubtitle =>
      'Configure island glass hdr highlight';
  dynamic get mediaNotificationTextColorTitle =>
      'Media Notification Text Color';
  dynamic get hideBehaviorForegroundApp => 'Selected Apps';
  dynamic get hideBehaviorForegroundAppSubtitle =>
      'Hide while one of the selected apps is in the foreground';
  dynamic get roundIconRadiusTitle => 'Round Icon Radius';
  dynamic get keepIslandNetworkCategory => 'Keep Island Network Category';
  dynamic get keepIslandCarouselIntervalTitle =>
      'Keep Island Carousel Interval';
  dynamic get keepIslandCarouselIntervalSubtitle =>
      'Configure keep island carousel interval';
  dynamic get keepIslandAddCarouselItem => 'Keep Island Add Carousel Item';
  dynamic keepIslandCarouselItem(dynamic index) => '';
  dynamic get settingsHomeEntryIconStyle => 'Settings Home Entry Icon Style';
  dynamic get settingsHomeEntryIconStyleDefault =>
      'Settings Home Entry Icon Style Default';
  dynamic get settingsHomeEntryIconStyleOutline =>
      'Settings Home Entry Icon Style Outline';
  dynamic get faceUnlockIslandTitle => 'Face Unlock Island';
  dynamic get faceUnlockIslandSettingsTitle => 'Face Unlock Island Settings';
  dynamic get faceUnlockIslandEnableTitle => 'Face Unlock Island Enable';
  dynamic get faceUnlockIslandEnableSubtitle =>
      'Configure face unlock island enable';
  dynamic get faceUnlockIslandFirstFloatTitle =>
      'Face Unlock Island First Float';
  dynamic get faceUnlockIslandFirstFloatSubtitle =>
      'Configure face unlock island first float';
  dynamic get hideLockscreenFaceUnlockIconTitle =>
      'Hide Lockscreen Face Unlock Icon';
  dynamic get hideLockscreenFaceUnlockIconSubtitle =>
      'Configure hide lockscreen face unlock icon';
  dynamic faceUnlockIslandSubtitle(dynamic status) => '';
  dynamic get faceUnlockIslandAnimationStyleTitle =>
      'Face Unlock Island Animation Style';
  dynamic get faceUnlockIslandAnimationStyleSubtitle =>
      'Configure face unlock island animation style';
  dynamic get faceUnlockIslandAnimationDefault =>
      'Face Unlock Island Animation Default';
  dynamic get faceUnlockIslandAnimationLock =>
      'Face Unlock Island Animation Lock';
  dynamic get faceUnlockIslandKeepUntilKeyguardHiddenTitle =>
      'Face Unlock Island Keep Until Keyguard Hidden';
  dynamic get faceUnlockIslandKeepUntilKeyguardHiddenSubtitle =>
      'Configure face unlock island keep until keyguard hidden';
  dynamic get referencesTitle => 'References';
  dynamic get referencesDescription => 'References Description';
  dynamic get islandGlassCustomize => 'Island Glass Customize';
  dynamic get islandGlassCustomizeSubtitle =>
      'Configure island glass customize';
  dynamic get islandGlassEnableFirst => 'Island Glass Enable First';
  dynamic get islandGlassCaptureSettingsSubtitle =>
      'Configure island glass capture settings';
  dynamic get islandGlassEnableLiquidFirst =>
      'Island Glass Enable Liquid First';
  dynamic get keepIslandFocusContentType => 'Keep Island Focus Content Type';
  dynamic get keepIslandFocusContentNotification =>
      'Keep Island Focus Content Notification';
  dynamic get keepIslandFocusContentPerformance =>
      'Keep Island Focus Content Performance';
  dynamic get keepIslandFocusContentDevice =>
      'Keep Island Focus Content Device';
  dynamic get keepIslandDeviceCategory => 'Keep Island Device Category';
  dynamic get keepIslandFocusContentCharging =>
      'Keep Island Focus Content Charging';
  dynamic get keepIslandIslandConfigTitle => 'Keep Island Island Config';
  dynamic get keepIslandFocusConfigTitle => 'Keep Island Focus Config';
  dynamic get keepIslandEnableIslandTitle => 'Keep Island Enable Island';
  dynamic get keepIslandShowNotificationTitle =>
      'Keep Island Show Notification';
  dynamic get keepIslandConfigEnabled => 'Keep Island Config Enabled';
  dynamic get keepIslandConfigDisabled => 'Keep Island Config Disabled';
  dynamic get keepIslandDisplayTimingTitle => 'Keep Island Display Timing';
  dynamic get keepIslandDisplayTimingAlways =>
      'Keep Island Display Timing Always';
  dynamic get keepIslandDisplayTimingCharging =>
      'Keep Island Display Timing Charging';
  dynamic get aiCustomFieldsTitle => 'AI Custom Fields';
  dynamic get aiCustomFieldsSubtitle => 'Configure ai custom fields';
  dynamic get aiCustomFieldsDialogTitle => 'AI Custom Fields Dialog';
  dynamic get aiCustomFieldsDescription => 'AI Custom Fields Description';
  dynamic get aiCustomFieldsReset => 'AI Custom Fields Reset';
  dynamic get aiCustomFieldName => 'AI Custom Field';
  dynamic get aiCustomFieldValue => 'AI Custom Field Value';
  dynamic get aiCustomFieldAdd => 'AI Custom Field Add';
  dynamic get aiCustomFieldDelete => 'AI Custom Field Delete';
  dynamic get aiCustomFieldsError => 'AI Custom Fields Error';
  dynamic get aiCustomFieldsCancel => 'AI Custom Fields Cancel';
  dynamic get aiCustomFieldsSave => 'AI Custom Fields Save';
  dynamic get keepIslandExpandTextColorTitle => 'Keep Island Expand Text Color';
  dynamic get keepIslandExpandTextColorWhite =>
      'Keep Island Expand Text Color White';
  dynamic get aiThinkingModeError => 'AI Thinking Mode Error';
  dynamic get islandIconSectionTitle => 'Island Icon Section';
  dynamic get iconSizeTitle => 'Icon Size';
  dynamic get islandSwipeActionsTitle => 'Island Swipe Actions';
  dynamic get expandedCollapseActionTitle => 'Expanded Collapse Action';
  dynamic get expandedCollapseActionSubtitle =>
      'Configure expanded collapse action';
  dynamic get bigIslandCollapseActionTitle => 'Big Island Collapse Action';
  dynamic get bigIslandCollapseActionSubtitle =>
      'Configure big island collapse action';
  dynamic get islandSwipeActionNone => 'Island Swipe Action None';
  dynamic get islandSwipeActionCancelNotification =>
      'Island Swipe Action Cancel Notification';
  dynamic get islandSwipeActionHideIsland => 'Island Swipe Action Hide Island';
  dynamic get islandSwipeIgnoreOngoingTitle => 'Island Swipe Ignore Ongoing';
  dynamic get iconPaddingTitle => 'Icon Padding';
  dynamic get outerGlowSingleColorTitle => 'Outer Glow Single Color';
  dynamic get outerGlowBaseColorTitle => 'Outer Glow Base Color';
}

class InteractionHaptics {
  InteractionHaptics();
  static dynamic button({dynamic force}) => const _Stub();
  static dynamic toggle({dynamic force}) => const _Stub();
  static dynamic sliderTick({dynamic force}) => const _Stub();
  static dynamic interceptButton(dynamic onPressed, {dynamic force}) => null;
  static dynamic interceptToggle(dynamic onChanged, {dynamic force}) => null;
  static dynamic interceptCheckbox(dynamic onChanged, {dynamic force}) => null;
  static dynamic interceptDropdown<T>(dynamic onChanged, {dynamic force}) =>
      null;
  static dynamic interceptSlider(dynamic onChanged, {dynamic force}) => null;
}

class SettingsController extends ChangeNotifier {
  SettingsController._();
  // HAND-AUTHORED 2026-09-15 (typed stand-in return). Was `=> const _Stub()`, reached through
  // `SettingsController fixtureCtrl = SettingsController.instance;` at :60 -- a binding that
  // declared `SettingsController` statically and held a `_Stub` at runtime, so it threw the
  // moment a role read a setting. Dart accepts the assignment because the getter returns
  // `dynamic`, which is why nothing before the device caught it.
  //
  // NO VALUE IS INVENTED HERE. This class is the generator's own reconstruction, and every one
  // of its ~150 accessors already carries the value the hierarchy resolved -- `showWelcome =>
  // false`, `bluetoothIslandOuterGlowColor => '#FF3482FF'`, `bluetoothIslandWhitelistAddresses
  // => <String>[]`. The singleton simply never handed any of them over. `_()` is private, but
  // `dependencies.dart` is `part of generated_widget`, so it is in scope here; that is also
  // why the real singleton shape is preserved rather than exposing a public constructor.
  static dynamic get instance => SettingsController._();
  dynamic get showWelcome => false;
  set showWelcome(dynamic _) {}
  dynamic get resumeNotification => false;
  set resumeNotification(dynamic _) {}
  dynamic get settingsHomeEntry => false;
  set settingsHomeEntry(dynamic _) {}
  dynamic get bluetoothIsland => false;
  set bluetoothIsland(dynamic _) {}
  dynamic get bluetoothIslandShowDeviceName => false;
  set bluetoothIslandShowDeviceName(dynamic _) {}
  dynamic get bluetoothIslandOuterGlow => false;
  set bluetoothIslandOuterGlow(dynamic _) {}
  dynamic get bluetoothIslandOuterGlowColor => '#FF3482FF';
  set bluetoothIslandOuterGlowColor(dynamic _) {}
  dynamic get bluetoothIslandWhitelistEnabled => false;
  set bluetoothIslandWhitelistEnabled(dynamic _) {}
  dynamic get bluetoothIslandWhitelistAddresses => <String>[];
  set bluetoothIslandWhitelistAddresses(dynamic _) {}
  dynamic get interactionHaptics => false;
  set interactionHaptics(dynamic _) {}
  dynamic get roundIcon => false;
  set roundIcon(dynamic _) {}
  dynamic get marqueeFeature => false;
  set marqueeFeature(dynamic _) {}
  dynamic get marqueeSpeed => 3;
  set marqueeSpeed(dynamic _) {}
  dynamic get bigIslandMaxWidth => 0;
  set bigIslandMaxWidth(dynamic _) {}
  dynamic get bigIslandMinWidth => 0;
  set bigIslandMinWidth(dynamic _) {}
  dynamic get smoothIsland => false;
  set smoothIsland(dynamic _) {}
  dynamic get smoothIslandSmoothing => 0.35;
  set smoothIslandSmoothing(dynamic _) {}
  dynamic get unlockAllFocus => false;
  set unlockAllFocus(dynamic _) {}
  dynamic get unlockFocusAuth => false;
  set unlockFocusAuth(dynamic _) {}
  dynamic get checkUpdateOnLaunch => false;
  set checkUpdateOnLaunch(dynamic _) {}
  dynamic get defaultFirstFloat => false;
  set defaultFirstFloat(dynamic _) {}
  dynamic get defaultEnableFloat => false;
  set defaultEnableFloat(dynamic _) {}
  dynamic get defaultShowIslandIcon => false;
  set defaultShowIslandIcon(dynamic _) {}
  dynamic get defaultMarquee => false;
  set defaultMarquee(dynamic _) {}
  dynamic get defaultFocusNotif => false;
  set defaultFocusNotif(dynamic _) {}
  dynamic get defaultAodText => false;
  set defaultAodText(dynamic _) {}
  dynamic get defaultDynamicHighlightColor => false;
  set defaultDynamicHighlightColor(dynamic _) {}
  dynamic get defaultOuterGlow => '';
  set defaultOuterGlow(dynamic _) {}
  dynamic get defaultIslandOuterGlow => '';
  set defaultIslandOuterGlow(dynamic _) {}
  dynamic get defaultForceOuterGlow => false;
  set defaultForceOuterGlow(dynamic _) {}
  dynamic get defaultForceIslandOuterGlow => false;
  set defaultForceIslandOuterGlow(dynamic _) {}
  dynamic get hideDesktopIcon => false;
  set hideDesktopIcon(dynamic _) {}
  dynamic get defaultRestoreLockscreen => false;
  set defaultRestoreLockscreen(dynamic _) {}
  dynamic get defaultPreserveSmallIcon => false;
  set defaultPreserveSmallIcon(dynamic _) {}
  dynamic get defaultOutEffectColor => '#FF2C6BED';
  set defaultOutEffectColor(dynamic _) {}
  dynamic get defaultIslandOuterGlowColor => '#FF2C6BED';
  set defaultIslandOuterGlowColor(dynamic _) {}
  dynamic get fullscreenBehavior => '';
  set fullscreenBehavior(dynamic _) {}
  dynamic get landscapeBehavior => '';
  set landscapeBehavior(dynamic _) {}
  dynamic get dndBehavior => '';
  set dndBehavior(dynamic _) {}
  dynamic get aiEnabled => false;
  set aiEnabled(dynamic _) {}
  dynamic get aiUrl => 'https://api.openai.com/v1/chat/completions';
  set aiUrl(dynamic _) {}
  dynamic get aiApiKey => 'sk-proj-0000000000000000000000000000';
  set aiApiKey(dynamic _) {}
  dynamic get aiModel => 'gpt-4o-mini';
  set aiModel(dynamic _) {}
  dynamic get aiPrompt =>
      'Summarise the notification into a short left and right label.';
  set aiPrompt(dynamic _) {}
  dynamic get aiPromptInUser => false;
  set aiPromptInUser(dynamic _) {}
  dynamic get aiTimeout => 0;
  set aiTimeout(dynamic _) {}
  dynamic get aiTemperature => 0.7;
  set aiTemperature(dynamic _) {}
  dynamic get aiMaxTokens => 256;
  set aiMaxTokens(dynamic _) {}
  dynamic get aiLastLog => null;
  set aiLastLog(dynamic _) {}
  dynamic get configAppVersion => '1.9.2';
  set configAppVersion(dynamic _) {}
  dynamic get themeMode => const _Stub();
  set themeMode(dynamic _) {}
  dynamic get islandBgSmallPath => '';
  set islandBgSmallPath(dynamic _) {}
  dynamic get islandBgBigPath => '';
  set islandBgBigPath(dynamic _) {}
  dynamic get islandBgExpandPath => '';
  set islandBgExpandPath(dynamic _) {}
  dynamic get islandHeight => 32.0;
  set islandHeight(dynamic _) {}
  dynamic get islandTopOffset => 12.0;
  set islandTopOffset(dynamic _) {}
  dynamic get keepIsland => false;
  set keepIsland(dynamic _) {}
  dynamic get keepIslandAutoHide => false;
  set keepIslandAutoHide(dynamic _) {}
  dynamic get keepIslandHighlightColor => '#FF3D8BFD';
  set keepIslandHighlightColor(dynamic _) {}
  dynamic get tempHideScreenPinning => false;
  set tempHideScreenPinning(dynamic _) {}
  dynamic get tempHideBouncerShowing => false;
  set tempHideBouncerShowing(dynamic _) {}
  dynamic get tempHideDesktopAnimating => false;
  set tempHideDesktopAnimating(dynamic _) {}
  dynamic get tempHideFullscreen => false;
  set tempHideFullscreen(dynamic _) {}
  dynamic get tempHideScreenLocked => false;
  set tempHideScreenLocked(dynamic _) {}
  dynamic get tempHideNotificationCenter => false;
  set tempHideNotificationCenter(dynamic _) {}
  dynamic get tempHideControlCenter => false;
  set tempHideControlCenter(dynamic _) {}
  dynamic get themeSeedColor => 0xFF2C6BED;
  set themeSeedColor(dynamic _) {}
  dynamic get blurBars => false;
  set blurBars(dynamic _) {}
  dynamic get debugLog => false;
  set debugLog(dynamic _) {}
  dynamic get onboardingCompleted => false;
  set onboardingCompleted(dynamic _) {}
  dynamic get locale => null;
  set locale(dynamic _) {}
  dynamic get loading => false;
  set loading(dynamic _) {}
  dynamic setOnboardingCompleted(dynamic value) => const _Stub();
  dynamic setShowWelcome(dynamic value) => const _Stub();
  dynamic setResumeNotification(dynamic value) => const _Stub();
  dynamic setSettingsHomeEntry(dynamic value) => const _Stub();
  dynamic setBluetoothIsland(dynamic value) => const _Stub();
  dynamic setBluetoothIslandShowDeviceName(dynamic value) => const _Stub();
  dynamic setBluetoothIslandOuterGlow(dynamic value) => const _Stub();
  dynamic setBluetoothIslandOuterGlowColor(dynamic value) => const _Stub();
  dynamic setBluetoothIslandWhitelistEnabled(dynamic value) => const _Stub();
  dynamic setBluetoothIslandWhitelistAddresses(dynamic addresses) =>
      const _Stub();
  dynamic setInteractionHaptics(dynamic value) => const _Stub();
  dynamic setRoundIcon(dynamic value) => const _Stub();
  dynamic setMarqueeFeature(dynamic value) => const _Stub();
  dynamic setMarqueeSpeed(dynamic value) => const _Stub();
  dynamic setBigIslandMaxWidth(dynamic value) => const _Stub();
  dynamic setBigIslandMinWidth(dynamic value) => const _Stub();
  dynamic setSmoothIsland(dynamic value) => const _Stub();
  dynamic setSmoothIslandSmoothing(dynamic value) => const _Stub();
  dynamic setUnlockAllFocus(dynamic value) => const _Stub();
  dynamic setUnlockFocusAuth(dynamic value) => const _Stub();
  dynamic setCheckUpdateOnLaunch(dynamic value) => const _Stub();
  dynamic setDefaultFirstFloat(dynamic value) => const _Stub();
  dynamic setDefaultEnableFloat(dynamic value) => const _Stub();
  dynamic setDefaultShowIslandIcon(dynamic value) => const _Stub();
  dynamic setDefaultMarquee(dynamic value) => const _Stub();
  dynamic setDefaultFocusNotif(dynamic value) => const _Stub();
  dynamic setDefaultAodText(dynamic value) => const _Stub();
  dynamic setDefaultDynamicHighlightColor(dynamic value) => const _Stub();
  dynamic setDefaultOuterGlow(dynamic value) => const _Stub();
  dynamic setDefaultIslandOuterGlow(dynamic value) => const _Stub();
  dynamic setDefaultForceOuterGlow(dynamic value) => const _Stub();
  dynamic setDefaultForceIslandOuterGlow(dynamic value) => const _Stub();
  dynamic setDefaultOutEffectColor(dynamic value) => const _Stub();
  dynamic setDefaultIslandOuterGlowColor(dynamic value) => const _Stub();
  dynamic setDefaultPreserveSmallIcon(dynamic value) => const _Stub();
  dynamic setFullscreenBehavior(dynamic value) => const _Stub();
  dynamic setLandscapeBehavior(dynamic value) => const _Stub();
  dynamic setDndBehavior(dynamic value) => const _Stub();
  dynamic setHideDesktopIcon(dynamic value) => const _Stub();
  dynamic setDefaultRestoreLockscreen(dynamic value) => const _Stub();
  dynamic syncHideDesktopIconFromSystem() => const _Stub();
  dynamic setAiEnabled(dynamic value) => const _Stub();
  dynamic setAiUrl(dynamic value) => const _Stub();
  dynamic setAiApiKey(dynamic value) => const _Stub();
  dynamic setAiModel(dynamic value) => const _Stub();
  dynamic setAiPrompt(dynamic value) => const _Stub();
  dynamic setAiPromptInUser(dynamic value) => const _Stub();
  dynamic setAiTimeout(dynamic value) => const _Stub();
  dynamic setAiTemperature(dynamic value) => const _Stub();
  dynamic setAiMaxTokens(dynamic value) => const _Stub();
  dynamic saveAiLastLog(dynamic entry) => const _Stub();
  dynamic refreshAiLastLog() => const _Stub();
  dynamic setThemeMode(dynamic mode) => const _Stub();
  dynamic setLocale(dynamic loc) => const _Stub();
  dynamic setIslandBgSmallPath(dynamic value) => const _Stub();
  dynamic setIslandBgBigPath(dynamic value) => const _Stub();
  dynamic setIslandBgExpandPath(dynamic value) => const _Stub();
  dynamic setIslandHeight(dynamic value) => const _Stub();
  dynamic setIslandTopOffset(dynamic value) => const _Stub();
  dynamic setKeepIsland(dynamic value) => const _Stub();
  dynamic setKeepIslandAutoHide(dynamic value) => const _Stub();
  dynamic setKeepIslandHighlightColor(dynamic value) => const _Stub();
  dynamic setTempHideScreenPinning(dynamic value) => const _Stub();
  dynamic setTempHideBouncerShowing(dynamic value) => const _Stub();
  dynamic setTempHideDesktopAnimating(dynamic value) => const _Stub();
  dynamic setTempHideFullscreen(dynamic value) => const _Stub();
  dynamic setTempHideScreenLocked(dynamic value) => const _Stub();
  dynamic setTempHideNotificationCenter(dynamic value) => const _Stub();
  dynamic setTempHideControlCenter(dynamic value) => const _Stub();
  dynamic setThemeSeedColor(dynamic value) => const _Stub();
  dynamic setBlurBars(dynamic value) => const _Stub();
  dynamic setDebugLog(dynamic value) => const _Stub();
  dynamic syncConfigAppVersion(dynamic currentVersion) =>
      Future<bool>.value(false);
  static dynamic compareVersionStrings(dynamic a, dynamic b) => 0;
  dynamic get islandTextColorMode => '';
  set islandTextColorMode(dynamic _) {}
  dynamic setIslandTextColorMode(dynamic value) => const _Stub();
  dynamic get tempHideBehaviorEnabled => false;
  set tempHideBehaviorEnabled(dynamic _) {}
  dynamic setTempHideBehaviorEnabled(dynamic value) => const _Stub();
  dynamic get chargeIsland => false;
  set chargeIsland(dynamic _) {}
  dynamic get chargeIslandLeftMode => '';
  set chargeIslandLeftMode(dynamic _) {}
  dynamic get chargeIslandRightMode => '';
  set chargeIslandRightMode(dynamic _) {}
  dynamic get chargeIslandDurationMode => '';
  set chargeIslandDurationMode(dynamic _) {}
  dynamic get chargeIslandDurationSeconds => 0;
  set chargeIslandDurationSeconds(dynamic _) {}
  dynamic setChargeIsland(dynamic value) => const _Stub();
  dynamic setChargeIslandLeftMode(dynamic value) => const _Stub();
  dynamic setChargeIslandRightMode(dynamic value) => const _Stub();
  dynamic setChargeIslandDurationMode(dynamic value) => const _Stub();
  dynamic setChargeIslandDurationSeconds(dynamic value) => const _Stub();
  dynamic get chargeIslandOuterGlow => false;
  set chargeIslandOuterGlow(dynamic _) {}
  dynamic setChargeIslandOuterGlow(dynamic value) => const _Stub();
  dynamic get keepIslandHideLandscape => false;
  set keepIslandHideLandscape(dynamic _) {}
  dynamic setKeepIslandHideLandscape(dynamic value) => const _Stub();
  dynamic get defaultMarqueeAutoHide => '';
  set defaultMarqueeAutoHide(dynamic _) {}
  dynamic setDefaultMarqueeAutoHide(dynamic value) => const _Stub();
  dynamic get bluetoothIslandDisplayDurationSeconds => 0;
  set bluetoothIslandDisplayDurationSeconds(dynamic _) {}
  dynamic setBluetoothIslandDisplayDurationSeconds(dynamic value) =>
      const _Stub();
  dynamic get keepIslandLeftContent => '{time}';
  set keepIslandLeftContent(dynamic _) {}
  dynamic get keepIslandRightContent => '{battery}';
  set keepIslandRightContent(dynamic _) {}
  dynamic setKeepIslandLeftContent(dynamic value) => const _Stub();
  dynamic setKeepIslandRightContent(dynamic value) => const _Stub();
  dynamic get aiTriggerCharCount => 0;
  set aiTriggerCharCount(dynamic _) {}
  dynamic setAiTriggerCharCount(dynamic value) => const _Stub();
  dynamic get keepIslandFocusNotification => false;
  set keepIslandFocusNotification(dynamic _) {}
  dynamic get keepIslandNotificationTitle => 'Dynamic Island';
  set keepIslandNotificationTitle(dynamic _) {}
  dynamic get keepIslandNotificationContent => 'Tap to open settings';
  set keepIslandNotificationContent(dynamic _) {}
  dynamic setKeepIslandFocusNotification(dynamic value) => const _Stub();
  dynamic setKeepIslandNotificationTitle(dynamic value) => const _Stub();
  dynamic setKeepIslandNotificationContent(dynamic value) => const _Stub();
  dynamic get keepIslandShowIslandIcon => false;
  set keepIslandShowIslandIcon(dynamic _) {}
  dynamic get keepIslandCustomIconPath => '';
  set keepIslandCustomIconPath(dynamic _) {}
  dynamic setKeepIslandShowIslandIcon(dynamic value) => const _Stub();
  dynamic setKeepIslandCustomIconPath(dynamic value) => const _Stub();
  dynamic get islandBlurSmallEnabled => false;
  set islandBlurSmallEnabled(dynamic _) {}
  dynamic get islandBlurSmallRadius => 0;
  set islandBlurSmallRadius(dynamic _) {}
  dynamic get islandBlurSmallColor => '#66000000';
  set islandBlurSmallColor(dynamic _) {}
  dynamic get islandBlurBigEnabled => false;
  set islandBlurBigEnabled(dynamic _) {}
  dynamic get islandBlurBigRadius => 0;
  set islandBlurBigRadius(dynamic _) {}
  dynamic get islandBlurBigColor => '#66000000';
  set islandBlurBigColor(dynamic _) {}
  dynamic get islandBlurExpandEnabled => false;
  set islandBlurExpandEnabled(dynamic _) {}
  dynamic get islandBlurExpandRadius => 0;
  set islandBlurExpandRadius(dynamic _) {}
  dynamic get islandBlurExpandColor => '#66000000';
  set islandBlurExpandColor(dynamic _) {}
  dynamic setIslandBlurSmall({
    dynamic enabled,
    dynamic radius,
    dynamic color,
  }) => const _Stub();
  dynamic setIslandBlurBig({dynamic enabled, dynamic radius, dynamic color}) =>
      const _Stub();
  dynamic setIslandBlurExpand({
    dynamic enabled,
    dynamic radius,
    dynamic color,
  }) => const _Stub();
  dynamic get tempHideFullscreenLandscapeDisable => false;
  set tempHideFullscreenLandscapeDisable(dynamic _) {}
  dynamic setTempHideFullscreenLandscapeDisable(dynamic value) => const _Stub();
  dynamic get alwaysShowIslandOutline => false;
  set alwaysShowIslandOutline(dynamic _) {}
  dynamic get alwaysShowFocusOutline => false;
  set alwaysShowFocusOutline(dynamic _) {}
  dynamic setAlwaysShowIslandOutline(dynamic value) => const _Stub();
  dynamic setAlwaysShowFocusOutline(dynamic value) => const _Stub();
  dynamic get focusNotificationTextColorMode => '';
  set focusNotificationTextColorMode(dynamic _) {}
  dynamic setFocusNotificationTextColorMode(dynamic value) => const _Stub();
  dynamic get keepIslandLeftHighlight => false;
  set keepIslandLeftHighlight(dynamic _) {}
  dynamic get keepIslandRightHighlight => false;
  set keepIslandRightHighlight(dynamic _) {}
  dynamic setKeepIslandLeftHighlight(dynamic value) => const _Stub();
  dynamic setKeepIslandRightHighlight(dynamic value) => const _Stub();
  dynamic get outerGlowRange => 12;
  set outerGlowRange(dynamic _) {}
  dynamic setOuterGlowRange(dynamic value) => const _Stub();
  dynamic get islandGlassEnabled => false;
  set islandGlassEnabled(dynamic _) {}
  dynamic get islandGlassEdgeWidth => 0;
  set islandGlassEdgeWidth(dynamic _) {}
  dynamic get islandGlassRefraction => 0;
  set islandGlassRefraction(dynamic _) {}
  dynamic get islandGlassHighlight => 0;
  set islandGlassHighlight(dynamic _) {}
  dynamic get islandGlassShadow => 0;
  set islandGlassShadow(dynamic _) {}
  dynamic get islandGlassLightDirection => 0;
  set islandGlassLightDirection(dynamic _) {}
  dynamic get islandGlassDispersion => 0;
  set islandGlassDispersion(dynamic _) {}
  dynamic get islandGlassGyroscope => false;
  set islandGlassGyroscope(dynamic _) {}
  dynamic setIslandGlassEnabled(dynamic value) => const _Stub();
  dynamic setIslandGlassGyroscope(dynamic value) => const _Stub();
  dynamic setIslandGlassEdgeWidth(dynamic value) => const _Stub();
  dynamic setIslandGlassRefraction(dynamic value) => const _Stub();
  dynamic setIslandGlassHighlight(dynamic value) => const _Stub();
  dynamic setIslandGlassShadow(dynamic value) => const _Stub();
  dynamic setIslandGlassLightDirection(dynamic value) => const _Stub();
  dynamic setIslandGlassDispersion(dynamic value) => const _Stub();
  dynamic get islandGlassTrueRefraction => false;
  set islandGlassTrueRefraction(dynamic _) {}
  dynamic setIslandGlassTrueRefraction(dynamic value) => const _Stub();
  dynamic get islandGlassCaptureFps => 0;
  set islandGlassCaptureFps(dynamic _) {}
  dynamic get islandGlassCaptureQuality => 0;
  set islandGlassCaptureQuality(dynamic _) {}
  dynamic setIslandGlassCaptureSettings({dynamic fps, dynamic quality}) =>
      const _Stub();
  dynamic get islandGlassSmallEnabled => false;
  set islandGlassSmallEnabled(dynamic _) {}
  dynamic get islandGlassBigEnabled => false;
  set islandGlassBigEnabled(dynamic _) {}
  dynamic get islandGlassExpandEnabled => false;
  set islandGlassExpandEnabled(dynamic _) {}
  dynamic get islandRefractionSmallEnabled => false;
  set islandRefractionSmallEnabled(dynamic _) {}
  dynamic get islandRefractionBigEnabled => false;
  set islandRefractionBigEnabled(dynamic _) {}
  dynamic get islandRefractionExpandEnabled => false;
  set islandRefractionExpandEnabled(dynamic _) {}
  dynamic setIslandGlassSmallEnabled(dynamic value) => const _Stub();
  dynamic setIslandGlassBigEnabled(dynamic value) => const _Stub();
  dynamic setIslandGlassExpandEnabled(dynamic value) => const _Stub();
  dynamic setIslandRefractionSmallEnabled(dynamic value) => const _Stub();
  dynamic setIslandRefractionBigEnabled(dynamic value) => const _Stub();
  dynamic setIslandRefractionExpandEnabled(dynamic value) => const _Stub();
  dynamic get defaultTimeout => 0;
  set defaultTimeout(dynamic _) {}
  dynamic setDefaultTimeout(dynamic value) => const _Stub();
  dynamic get islandGlassHdrHighlight => false;
  set islandGlassHdrHighlight(dynamic _) {}
  dynamic setIslandGlassHdrHighlight(dynamic value) => const _Stub();
  dynamic get mediaNotificationTextColorMode => '';
  set mediaNotificationTextColorMode(dynamic _) {}
  dynamic setMediaNotificationTextColorMode(dynamic value) => const _Stub();
  dynamic get tempHideForegroundApp => false;
  set tempHideForegroundApp(dynamic _) {}
  dynamic setTempHideForegroundApp(dynamic value) => const _Stub();
  dynamic get roundIconRadius => 8;
  set roundIconRadius(dynamic _) {}
  dynamic setRoundIconRadius(dynamic value) => const _Stub();
  dynamic get keepIslandLeftContents => <String>[];
  set keepIslandLeftContents(dynamic _) {}
  dynamic get keepIslandRightContents => <String>[];
  set keepIslandRightContents(dynamic _) {}
  dynamic get keepIslandCarouselInterval => 0;
  set keepIslandCarouselInterval(dynamic _) {}
  dynamic setKeepIslandLeftContents(dynamic values) => const _Stub();
  dynamic setKeepIslandRightContents(dynamic values) => const _Stub();
  dynamic setKeepIslandCarouselInterval(dynamic value) => const _Stub();
  dynamic get settingsHomeEntryIconStyle => '';
  set settingsHomeEntryIconStyle(dynamic _) {}
  dynamic setSettingsHomeEntryIconStyle(dynamic value) => const _Stub();
  dynamic get faceUnlockIsland => false;
  set faceUnlockIsland(dynamic _) {}
  dynamic get faceUnlockIslandFirstFloat => false;
  set faceUnlockIslandFirstFloat(dynamic _) {}
  dynamic get hideLockscreenFaceUnlockIcon => false;
  set hideLockscreenFaceUnlockIcon(dynamic _) {}
  dynamic setFaceUnlockIslandFirstFloat(dynamic value) => const _Stub();
  dynamic setFaceUnlockIsland(dynamic value) => const _Stub();
  dynamic setHideLockscreenFaceUnlockIcon(dynamic value) => const _Stub();
  dynamic get faceUnlockIslandAnimationStyle => '';
  set faceUnlockIslandAnimationStyle(dynamic _) {}
  dynamic setFaceUnlockIslandAnimationStyle(dynamic value) => const _Stub();
  dynamic get faceUnlockIslandKeepUntilKeyguardHidden => false;
  set faceUnlockIslandKeepUntilKeyguardHidden(dynamic _) {}
  dynamic setFaceUnlockIslandKeepUntilKeyguardHidden(dynamic value) =>
      const _Stub();
  dynamic get keepIslandFocusContentType => '';
  set keepIslandFocusContentType(dynamic _) {}
  dynamic setKeepIslandFocusContentType(dynamic value) => const _Stub();
  dynamic get keepIslandShowNotification => false;
  set keepIslandShowNotification(dynamic _) {}
  dynamic setKeepIslandShowNotification(dynamic value) => const _Stub();
  dynamic get keepIslandDisplayTiming => '';
  set keepIslandDisplayTiming(dynamic _) {}
  dynamic setKeepIslandDisplayTiming(dynamic value) => const _Stub();
  dynamic get aiCustomFields => '{}';
  set aiCustomFields(dynamic _) {}
  dynamic setAiCustomFields(dynamic value) => const _Stub();
  dynamic get keepIslandExpandTextColorMode => '';
  set keepIslandExpandTextColorMode(dynamic _) {}
  dynamic setKeepIslandExpandTextColorMode(dynamic value) => const _Stub();
  dynamic get islandIconSize => 20;
  set islandIconSize(dynamic _) {}
  dynamic setIslandIconSize(dynamic value) => const _Stub();
  dynamic get expandedCollapseAction => '';
  set expandedCollapseAction(dynamic _) {}
  dynamic get bigIslandCollapseAction => '';
  set bigIslandCollapseAction(dynamic _) {}
  dynamic setExpandedCollapseAction(dynamic value) => const _Stub();
  dynamic setBigIslandCollapseAction(dynamic value) => const _Stub();
  dynamic get islandSwipeIgnoreOngoing => false;
  set islandSwipeIgnoreOngoing(dynamic _) {}
  dynamic setIslandSwipeIgnoreOngoing(dynamic value) => const _Stub();
  dynamic get islandIconPadding => 4.0;
  set islandIconPadding(dynamic _) {}
  dynamic setIslandIconPadding(dynamic value) => const _Stub();
  dynamic get outerGlowSingleColor => false;
  set outerGlowSingleColor(dynamic _) {}
  dynamic get outerGlowBaseColor => '#FF2C6BED';
  set outerGlowBaseColor(dynamic _) {}
  dynamic setOuterGlowSingleColor(dynamic value) => const _Stub();
  dynamic setOuterGlowBaseColor(dynamic value) => const _Stub();
}

// UNRESOLVED-REFERENCE STAND-INS -- reconstructed from the call sites, because the
// symbol lives in a package this file may not import or the source project's own
// dependencies were never installed. Every type here is `dynamic`.

dynamic _ownsController = const _Stub();

dynamic _scrollController = const _Stub();

dynamic _scrollOffset = const _Stub();

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
