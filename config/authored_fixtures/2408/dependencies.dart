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

WidgetRef fixtureRef = WidgetRef();

// DECLARATION-ONLY STAND-INS -- repo-local declarations that build no UI, and
// third-party ones the transplant does not inline. Supertypes are mirrored so a
// widget still reads as a widget; everything else is `dynamic`, because none of it
// is measured.

class AgentsConfig {
  const AgentsConfig({dynamic defaults});
  AgentsConfig.fromJson(dynamic json);
  dynamic get defaults => AgentsDefaults();
  dynamic toJson() => <String, dynamic>{};
  dynamic copyWith({dynamic defaults}) => AgentsConfig();
}

class AgentsDefaults {
  const AgentsDefaults({
    dynamic workspace,
    dynamic modelName,
    dynamic maxTokens,
    dynamic temperature,
    dynamic maxToolIterations,
    dynamic restrictToWorkspace,
    dynamic maxToolResultTokens,
    dynamic autoCompactEnabled,
    dynamic autoCompactThreshold,
    dynamic memoryFlushEnabled,
    dynamic typingMode,
    dynamic liveVoiceModelId,
    dynamic preferLiveVoiceBootstrap,
    dynamic liveVoiceName,
  });
  AgentsDefaults.fromJson(dynamic json);
  dynamic get workspace =>
      '/var/mobile/Containers/Data/Application/FlutterClaw/Documents/workspace';
  dynamic get modelName => 'claude-sonnet-4-5';
  dynamic get maxTokens => 8192;
  dynamic get temperature => 0.7;
  dynamic get maxToolIterations => 24;
  dynamic get restrictToWorkspace => false;
  dynamic toJson() => <String, dynamic>{};
  dynamic get maxToolResultTokens => 16000;
  dynamic get autoCompactEnabled => false;
  dynamic get autoCompactThreshold => 0.8;
  dynamic get typingMode => 'streaming';
  dynamic get memoryFlushEnabled => false;
  dynamic get liveVoiceModelId => null;
  dynamic get preferLiveVoiceBootstrap => false;
  dynamic copyWith({
    dynamic workspace,
    dynamic modelName,
    dynamic maxTokens,
    dynamic temperature,
    dynamic maxToolIterations,
    dynamic restrictToWorkspace,
    dynamic maxToolResultTokens,
    dynamic autoCompactEnabled,
    dynamic autoCompactThreshold,
    dynamic memoryFlushEnabled,
    dynamic typingMode,
    dynamic liveVoiceModelId,
    dynamic preferLiveVoiceBootstrap,
    dynamic clearLiveVoiceModelId,
    dynamic liveVoiceName,
  }) => AgentsDefaults();
  dynamic get liveVoiceName => 'Kore';
}

class AppLocalizations {
  const AppLocalizations(dynamic locale);
  dynamic get localeName => 'en';
  static const dynamic delegate = null;
  static const dynamic localizationsDelegates = null;
  static const dynamic supportedLocales = null;
  dynamic get appTitle => 'FlutterClaw';
  dynamic get chat => 'Chat';
  dynamic get channels => 'Channels';
  dynamic get agent => 'Agent';
  dynamic get settings => 'Settings';
  dynamic get getStarted => 'Get started';
  dynamic get yourPersonalAssistant => 'Your personal AI assistant';
  dynamic get multiChannelChat => 'Multi-channel chat';
  dynamic get multiChannelChatDesc =>
      'Talk to your agent from Telegram, Discord, Slack or WhatsApp.';
  dynamic get powerfulAIModels => 'Powerful AI models';
  dynamic get powerfulAIModelsDesc =>
      'Bring your own key and pick any model your provider offers.';
  dynamic get localGateway => 'Local gateway';
  dynamic get localGatewayDesc =>
      'Runs on this device, so your messages never leave it.';
  dynamic get chooseProvider => 'Choose a provider';
  dynamic get selectProviderDesc =>
      'Pick where your agent gets its intelligence from.';
  dynamic get startForFree => 'Start for free';
  dynamic get freeProvidersDesc =>
      'These providers have a free tier, no credit card needed.';
  dynamic get free => 'Free';
  dynamic get otherProviders => 'Other providers';
  dynamic get enterApiKeyDesc =>
      'Paste the API key for the provider you chose.';
  dynamic get dontHaveApiKey => "Don't have an API key?";
  dynamic get createAccountCopyKey => 'Create an account and copy your key.';
  dynamic get signUp => 'Sign up';
  dynamic get apiKey => 'API key';
  dynamic get pasteFromClipboard => 'Paste from clipboard';
  dynamic get apiBaseUrl => 'API base URL';
  dynamic get selectModel => 'Select a model';
  dynamic get modelId => 'Model ID';
  dynamic get validateKey => 'Validate key';
  dynamic get validating => 'Validating…';
  dynamic get invalidApiKey => 'The provider rejected that API key.';
  dynamic get gatewayConfiguration => 'Gateway configuration';
  dynamic get gatewayConfigDesc =>
      'The gateway relays messages between your channels and the agent.';
  dynamic get defaultSettingsNote => 'The defaults work for most setups.';
  dynamic get host => 'Host';
  dynamic get port => 'Port';
  dynamic get autoStartGateway => 'Start gateway automatically';
  dynamic get autoStartGatewayDesc =>
      'Launch the gateway whenever the app opens.';
  dynamic get channelsPageTitle => 'Connect your channels';
  dynamic get channelsPageDesc =>
      'Choose where you want to talk to your agent.';
  dynamic get telegram => 'Telegram';
  dynamic get connectTelegramBot => 'Connect a Telegram bot';
  dynamic get openBotFather => 'Open BotFather';
  dynamic get discord => 'Discord';
  dynamic get connectDiscordBot => 'Connect a Discord bot';
  dynamic get developerPortal => 'Developer portal';
  dynamic get botToken => 'Bot token';
  dynamic get readyToGo => 'Ready to go';
  dynamic get reviewConfiguration => 'Review your configuration';
  dynamic get model => 'Model';
  dynamic get gateway => 'Gateway';
  dynamic get webChatOnly => 'Web chat only';
  dynamic get webChat => 'Web chat';
  dynamic get starting => 'Starting…';
  dynamic get startFlutterClaw => 'Start FlutterClaw';
  dynamic get newSession => 'New session';
  dynamic get photoLibrary => 'Photo library';
  dynamic get camera => 'Camera';
  dynamic get whatDoYouSeeInImage => 'What do you see in this image?';
  dynamic get imagePickerNotAvailable =>
      'The image picker is not available on this device.';
  dynamic get couldNotOpenImagePicker => 'Could not open the image picker.';
  dynamic get copiedToClipboard => 'Copied to clipboard';
  dynamic get attachImage => 'Attach image';
  dynamic get messageFlutterClaw => 'Message FlutterClaw…';
  dynamic get channelsAndGateway => 'Channels and gateway';
  dynamic get stop => 'Stop';
  dynamic get start => 'Start';
  dynamic get builtInChatInterface => 'Built-in chat interface';
  dynamic get notConfigured => 'Not configured';
  dynamic get connected => 'Connected';
  dynamic get configuredStarting => 'Configured, starting…';
  dynamic get telegramConfiguration => 'Telegram configuration';
  dynamic get fromBotFather => 'From @BotFather';
  dynamic get allowedUserIds => 'Allowed user IDs';
  dynamic get leaveEmptyToAllowAll => 'Leave empty to allow everyone';
  dynamic get cancel => 'Cancel';
  dynamic get saveAndConnect => 'Save and connect';
  dynamic get discordConfiguration => 'Discord configuration';
  dynamic get pendingPairingRequests => 'Pending pairing requests';
  dynamic get approve => 'Approve';
  dynamic get reject => 'Reject';
  dynamic get expired => 'Expired';
  dynamic get workspaceFiles => 'Workspace files';
  dynamic get personalAIAssistant => 'Personal AI assistant';
  dynamic get noActiveSessions => 'No active sessions';
  dynamic get startConversationToCreate =>
      'Start a conversation to create one.';
  dynamic get startConversationToSee => 'Start a conversation to see it here.';
  dynamic get reset => 'Reset';
  dynamic get cronJobs => 'Cron jobs';
  dynamic get noCronJobs => 'No cron jobs yet';
  dynamic get addScheduledTasks =>
      'Add a scheduled task to run your agent on a timer.';
  dynamic get runNow => 'Run now';
  dynamic get enable => 'Enable';
  dynamic get disable => 'Disable';
  dynamic get delete => 'Delete';
  dynamic get skills => 'Skills';
  dynamic get browseClawHub => 'Browse ClawHub';
  dynamic get noSkillsInstalled => 'No skills installed';
  dynamic get browseClawHubToAdd => 'Browse ClawHub to add one.';
  dynamic get clawHubSkills => 'ClawHub skills';
  dynamic get searchSkills => 'Search skills';
  dynamic get noSkillsFound => 'No skills found';
  dynamic get addCronJob => 'Add cron job';
  dynamic get jobName => 'Job name';
  dynamic get dailySummaryExample => 'e.g. Daily summary';
  dynamic get taskPrompt => 'Task prompt';
  dynamic get whatShouldAgentDo => 'What should the agent do?';
  dynamic get interval => 'Interval';
  dynamic get every5Minutes => 'Every 5 minutes';
  dynamic get every15Minutes => 'Every 15 minutes';
  dynamic get every30Minutes => 'Every 30 minutes';
  dynamic get everyHour => 'Every hour';
  dynamic get every6Hours => 'Every 6 hours';
  dynamic get every12Hours => 'Every 12 hours';
  dynamic get every24Hours => 'Every 24 hours';
  dynamic get add => 'Add';
  dynamic get save => 'Save';
  dynamic get sessions => 'Sessions';
  dynamic get compact => 'Compact';
  dynamic get models => 'Models';
  dynamic get noModelsConfigured => 'No models configured';
  dynamic get addModelToStartChatting => 'Add a model to start chatting.';
  dynamic get addModel => 'Add model';
  dynamic get default_ => 'Default';
  dynamic get autoStart => 'Auto-start';
  dynamic get startGatewayWhenLaunches =>
      'Start the gateway when the app launches';
  dynamic get heartbeat => 'Heartbeat';
  dynamic get enabled => 'Enabled';
  dynamic get periodicAgentTasks => 'Run periodic agent tasks';
  dynamic get about => 'About';
  dynamic get personalAIAssistantForIOS => 'A personal AI assistant for iOS';
  dynamic get version => 'Version';
  dynamic get basedOnOpenClaw => 'Based on OpenClaw';
  dynamic get removeModel => 'Remove model';
  dynamic get remove => 'Remove';
  dynamic get setAsDefault => 'Set as default';
  dynamic get paste => 'Paste';
  dynamic get chooseProviderStep => 'Provider';
  dynamic get selectModelStep => 'Model';
  dynamic get apiKeyStep => 'API key';
  dynamic get justNow => 'Just now';
  dynamic get microphonePermissionDenied => 'Microphone permission denied';
  dynamic get usingOnDeviceTranscription => 'Using on-device transcription';
  dynamic get transcribingWithWhisper => 'Transcribing with Whisper…';
  dynamic get noTranscriptionCaptured => 'No speech was captured';
  dynamic get pause => 'Pause';
  dynamic get resume => 'Resume';
  dynamic get send => 'Send';
  dynamic get liveActivityActive => 'Live Activity running';
  dynamic get restartGateway => 'Restart gateway';
  dynamic get iosBackgroundSupportActive => 'iOS background support is active';
  dynamic get webChatBuiltIn => 'Web chat (built in)';
  dynamic get configure => 'Configure';
  dynamic get disconnect => 'Disconnect';
  dynamic get agents => 'Agents';
  dynamic get agentFiles => 'Agent files';
  dynamic get createAgent => 'Create agent';
  dynamic get editAgent => 'Edit agent';
  dynamic get noAgentsYet => 'No agents yet';
  dynamic get createYourFirstAgent => 'Create your first agent to get started.';
  dynamic get active => 'Active';
  dynamic get agentName => 'Agent name';
  dynamic get emoji => 'Emoji';
  dynamic get selectEmoji => 'Select emoji';
  dynamic get vibe => 'Vibe';
  dynamic get vibeHint => 'Describe how your agent should sound.';
  dynamic get modelConfiguration => 'Model configuration';
  dynamic get advancedSettings => 'Advanced settings';
  dynamic get agentCreated => 'Agent created';
  dynamic get agentUpdated => 'Agent updated';
  dynamic get agentDeleted => 'Agent deleted';
  dynamic get agentDetails => 'Agent details';
  dynamic get createdAt => 'Created';
  dynamic get lastUsed => 'Last used';
  dynamic get basicInformation => 'Basic information';
  dynamic get switchToAgent => 'Switch to this agent';
  dynamic get providers => 'Providers';
  dynamic get addProvider => 'Add provider';
  dynamic get noProvidersConfigured => 'No providers configured';
  dynamic get editCredentials => 'Edit credentials';
  dynamic get defaultModelHint =>
      'Used by agents that have no model of their own.';
  dynamic get holdToSetAsDefault => 'Hold to set as default';
  dynamic get integrations => 'Integrations';
  dynamic get shortcutsIntegrations => 'Shortcuts';
  dynamic get shortcutsIntegrationsDesc =>
      'Let your agent run Apple Shortcuts on this device.';
  dynamic get dangerZone => 'Danger zone';
  dynamic get resetOnboarding => 'Reset onboarding';
  dynamic get resetOnboardingDesc =>
      'Show the setup flow again the next time the app starts.';
  dynamic get resetAllConfiguration => 'Reset all configuration';
  dynamic get resetAllConfigurationDesc =>
      'Delete every provider, agent and channel setting.';
  dynamic get removeProvider => 'Remove provider';
  dynamic get photoImage => 'Photo or image';
  dynamic get documentPdfTxt => 'Document (PDF, TXT)';
  dynamic get retry => 'Retry';
  dynamic get gatewayStopped => 'Gateway stopped';
  dynamic get gatewayStarted => 'Gateway started';
  dynamic get pairingRequestApproved => 'Pairing request approved';
  dynamic get pairingRequestRejected => 'Pairing request rejected';
  dynamic get addDevice => 'Add device';
  dynamic get telegramConfigSaved => 'Telegram configuration saved';
  dynamic get discordConfigSaved => 'Discord configuration saved';
  dynamic get securityMethod => 'Security method';
  dynamic get pairingRecommended => 'Pairing (recommended)';
  dynamic get pairingDescription =>
      'New devices ask for approval before they can chat.';
  dynamic get allowlistTitle => 'Allowlist';
  dynamic get allowlistDescription =>
      'Only the user IDs you list can reach your agent.';
  dynamic get openAccess => 'Open access';
  dynamic get openAccessDescription =>
      'Anyone who finds the bot can talk to your agent.';
  dynamic get disabledAccess => 'Disabled';
  dynamic get disabledAccessDescription =>
      'The channel stays connected but answers nobody.';
  dynamic get approvedDevices => 'Approved devices';
  dynamic get noApprovedDevicesYet => 'No approved devices yet';
  dynamic get devicesAppearAfterApproval =>
      'Devices appear here once you approve them.';
  dynamic get noAllowedUsersConfigured => 'No allowed users configured';
  dynamic get addUserIdsHint => 'Add the user IDs that may talk to your agent.';
  dynamic get removeDevice => 'Remove device';
  dynamic get saving => 'Saving…';
  dynamic get channelsLabel => 'Channels';
  dynamic get clawHubAccount => 'ClawHub account';
  dynamic get loggedInToClawHub => 'Signed in to ClawHub';
  dynamic get loggedOutFromClawHub => 'Signed out of ClawHub';
  dynamic get login => 'Sign in';
  dynamic get logout => 'Sign out';
  dynamic get connect => 'Connect';
  dynamic get pasteClawHubToken => 'Paste your ClawHub token';
  dynamic get pleaseEnterApiToken => 'Please enter an API token';
  dynamic get successfullyConnected => 'Connected';
  dynamic get browseSkillsButton => 'Browse skills';
  dynamic get installSkill => 'Install skill';
  dynamic get incompatibleSkill => 'Incompatible skill';
  dynamic get compatibilityWarning => 'Compatibility warning';
  dynamic get ok => 'OK';
  dynamic get installOriginal => 'Install original';
  dynamic get installAdapted => 'Install adapted';
  dynamic get resetSession => 'Reset session';
  dynamic get sessionReset => 'Session reset';
  dynamic get activeSessions => 'Active sessions';
  dynamic get scheduledTasks => 'Scheduled tasks';
  dynamic get defaultBadge => 'DEFAULT';
  dynamic get cannotDeleteLastAgent => 'You cannot delete your last agent.';
  dynamic get close => 'Close';
  dynamic get nameIsRequired => 'Name is required';
  dynamic get pleaseSelectModel => 'Please select a model';
  dynamic get maxTokens => 'Max tokens';
  dynamic get maxTokensRequired => 'Max tokens is required';
  dynamic get mustBePositiveNumber => 'Enter a positive number';
  dynamic get maxToolIterations => 'Max tool iterations';
  dynamic get maxIterationsRequired => 'Max iterations is required';
  dynamic get restrictToWorkspace => 'Restrict to workspace';
  dynamic get restrictToWorkspaceDesc =>
      'The agent may only read and write inside its workspace folder.';
  dynamic get noModelsConfiguredLong =>
      'No models are configured yet. Add one in Settings to start chatting.';
  dynamic get selectProviderFirst => 'Select a provider first';
  dynamic get skip => 'Skip';
  dynamic get continueButton => 'Continue';
  dynamic get uiAutomation => 'UI automation';
  dynamic get uiAutomationDesc =>
      'Let your agent tap and type in other apps for you.';
  dynamic get uiAutomationAccessibilityNote =>
      'This needs the Accessibility permission.';
  dynamic get openAccessibilitySettings => 'Open accessibility settings';
  dynamic get skipForNow => 'Skip for now';
  dynamic get checkingPermission => 'Checking permission…';
  dynamic get accessibilityEnabled => 'Accessibility is enabled';
  dynamic get accessibilityNotEnabled => 'Accessibility is not enabled';
  dynamic get exploreIntegrations => 'Explore integrations';
  dynamic get requestTimedOut => 'The request timed out';
  dynamic get myShortcuts => 'My shortcuts';
  dynamic get addShortcut => 'Add shortcut';
  dynamic get noShortcutsYet => 'No shortcuts yet';
  dynamic get shortcutsInstructions =>
      'Create a shortcut in the Shortcuts app, then add it here.';
  dynamic get shortcutName => 'Shortcut name';
  dynamic get shortcutNameHint => 'e.g. Start focus mode';
  dynamic get descriptionOptional => 'Description (optional)';
  dynamic get whatDoesShortcutDo => 'What does this shortcut do?';
  dynamic get callbackSetup => 'Callback setup';
  dynamic get callbackInstructions =>
      'End your shortcut with an Open URL action pointing at the callback below.';
  dynamic get channelApp => 'App';
  dynamic get channelHeartbeat => 'Heartbeat';
  dynamic get channelCron => 'Cron';
  dynamic get channelSubagent => 'Subagent';
  dynamic get channelSystem => 'System';
  dynamic get messagesAbbrev => 'msgs';
  // HAND-AUTHORED 2026-09-15. Was `=> null`, and every call site writes
  // `AppLocalizations.of(context)!` -- so the bang threw `Null check operator used on a null
  // value` inside `build` and the device drew Flutter's error box. The generator had already
  // reconstructed every string this class hands back; returning an instance is what lets the
  // transplant reach them.
  static dynamic of(dynamic context) => AppLocalizations(null);
  dynamic connectToProvider(dynamic provider) => '';
  dynamic telegramBotToken(dynamic platform) => '';
  dynamic viaProvider(dynamic provider) => '';
  dynamic status(dynamic status) => '';
  dynamic minutesLeft(dynamic minutes) => '';
  dynamic sessionsCount(dynamic count) => '';
  dynamic removeSkillConfirm(dynamic name) => '';
  dynamic installedSkill(dynamic name) => '';
  dynamic failedToInstallSkill(dynamic name) => '';
  dynamic messagesCount(dynamic count) => '';
  dynamic tokensCount(dynamic count) => '';
  dynamic intervalMinutes(dynamic minutes) => '';
  dynamic removeModelConfirm(dynamic name) => '';
  dynamic getApiKeyAt(dynamic provider) => '';
  dynamic minutesAgo(dynamic minutes) => '';
  dynamic hoursAgo(dynamic hours) => '';
  dynamic daysAgo(dynamic days) => '';
  dynamic liveTranscriptionUnavailable(dynamic error) => '';
  dynamic failedToStartRecording(dynamic error) => '';
  dynamic whisperApiFailed(dynamic error) => '';
  dynamic failedToStopRecording(dynamic error) => '';
  dynamic failedToPauseResume(dynamic action, dynamic error) => '';
  dynamic modelLabel(dynamic model) => '';
  dynamic uptimeLabel(dynamic uptime) => '';
  dynamic switchedToAgent(dynamic name) => '';
  dynamic deleteAgentConfirm(dynamic name) => '';
  dynamic removeProviderConfirm(dynamic provider) => '';
  dynamic modelSetAsDefault(dynamic name) => '';
  dynamic couldNotOpenDocument(dynamic error) => '';
  dynamic gatewayFailed(dynamic error) => '';
  dynamic exceptionError(dynamic error) => '';
  dynamic removeAccessFor(dynamic name) => '';
  dynamic incompatibleSkillDesc(dynamic reason) => '';
  dynamic compatibilityWarningDesc(dynamic reason) => '';
  dynamic resetSessionConfirm(dynamic key) => '';
  dynamic errorGeneric(dynamic error) => '';
  dynamic fileSaved(dynamic fileName) => '';
  dynamic errorSavingFile(dynamic error) => '';
  dynamic temperatureLabel(dynamic value) => '';
  dynamic secondsAgo(dynamic seconds) => '';
  dynamic get modelAlreadyAdded => 'That model has already been added';
  dynamic get bothTokensRequired => 'Both tokens are required';
  dynamic get slackSavedRestart =>
      'Slack settings saved — restart the gateway to apply them';
  dynamic get slackConfiguration => 'Slack configuration';
  dynamic get setupTitle => 'Setup';
  dynamic get slackSetupInstructions =>
      'Create a Slack app, turn on Socket Mode, then paste both tokens below.';
  dynamic get botTokenXoxb => 'Bot token (xoxb-…)';
  dynamic get appLevelToken => 'App-level token (xapp-…)';
  dynamic get apiUrlPhoneRequired => 'API URL and phone number are required';
  dynamic get signalSavedRestart =>
      'Signal settings saved — restart the gateway to apply them';
  dynamic get signalConfiguration => 'Signal configuration';
  dynamic get requirementsTitle => 'Requirements';
  dynamic get signalRequirements =>
      'Needs a signal-cli REST API this device can reach.';
  dynamic get signalApiUrl => 'Signal API URL';
  dynamic get signalPhoneNumber => 'Signal phone number';
  dynamic get userIdLabel => 'User ID';
  dynamic get enterDiscordUserId => 'Enter a Discord user ID';
  dynamic get enterTelegramUserId => 'Enter a Telegram user ID';
  dynamic get fromDiscordDevPortal => 'From the Discord developer portal';
  dynamic get allowedUserIdsTitle => 'Allowed user IDs';
  dynamic get approvedDevice => 'Approved device';
  dynamic get allowedUser => 'Allowed user';
  dynamic get howToGetBotToken => 'How to get a bot token';
  dynamic get discordTokenInstructions =>
      'Open the Discord developer portal, create an application, add a bot and copy its token.';
  dynamic get telegramTokenInstructions =>
      'Message @BotFather on Telegram, send /newbot and copy the token it returns.';
  dynamic get fromBotFatherHint => 'Paste the token from @BotFather';
  dynamic get accessTokenLabel => 'Access token';
  dynamic get notSetOpenAccess => 'Not set — open access (loopback only)';
  dynamic get gatewayAccessToken => 'Gateway access token';
  dynamic get tokenFieldLabel => 'Token';
  dynamic get leaveEmptyDisableAuth => 'Leave empty to disable authentication';
  dynamic get toolPolicies => 'Tool policies';
  dynamic get toolPoliciesDesc =>
      'Choose what your agent is allowed to do on this device.';
  dynamic get privacySensors => 'Privacy and sensors';
  dynamic get networkCategory => 'Network';
  dynamic get systemCategory => 'System';
  dynamic get toolTakePhotos => 'Take photos';
  dynamic get toolTakePhotosDesc => 'Capture a photo with the camera';
  dynamic get toolRecordVideo => 'Record video';
  dynamic get toolRecordVideoDesc => 'Record a short video clip';
  dynamic get toolLocation => 'Location';
  dynamic get toolLocationDesc => 'Read your current location';
  dynamic get toolHealthData => 'Health data';
  dynamic get toolHealthDataDesc => 'Read workouts and health metrics';
  dynamic get toolContacts => 'Contacts';
  dynamic get toolContactsDesc => 'Look up people in your address book';
  dynamic get toolScreenshots => 'Screenshots';
  dynamic get toolScreenshotsDesc => 'Capture what is on the screen';
  dynamic get toolWebFetch => 'Web fetch';
  dynamic get toolWebFetchDesc => 'Open a URL and read the page';
  dynamic get toolWebSearch => 'Web search';
  dynamic get toolWebSearchDesc => 'Search the web for answers';
  dynamic get toolHttpRequests => 'HTTP requests';
  dynamic get toolHttpRequestsDesc => 'Call arbitrary HTTP endpoints';
  dynamic get toolSandboxShell => 'Sandbox shell';
  dynamic get toolSandboxShellDesc => 'Run commands inside the sandbox';
  dynamic get toolImageGeneration => 'Image generation';
  dynamic get toolImageGenerationDesc => 'Generate images from a prompt';
  dynamic get toolLaunchApps => 'Launch apps';
  dynamic get toolLaunchAppsDesc => 'Open another app on this device';
  dynamic get toolLaunchIntents => 'Launch intents';
  dynamic get toolLaunchIntentsDesc => 'Trigger an Android intent';
  dynamic get renameSession => 'Rename session';
  dynamic get myConversationName => 'e.g. Trip planning';
  dynamic get renameAction => 'Rename';
  dynamic get couldNotTranscribeAudio => 'Could not transcribe the audio';
  dynamic get stopRecording => 'Stop recording';
  dynamic get voiceInput => 'Voice input';
  dynamic get copyTooltip => 'Copy';
  dynamic get commandsTooltip => 'Commands';
  dynamic get providersAndModels => 'Providers and models';
  dynamic get autoStartEnabledLabel => 'Auto-start on';
  dynamic get autoStartOffLabel => 'Auto-start off';
  dynamic get allToolsEnabled => 'All tools enabled';
  dynamic get flutterClawVersion => 'FlutterClaw 1.4.2';
  dynamic get noPendingPairingRequests => 'No pending pairing requests';
  dynamic get pairingRequestsTitle => 'Pairing requests';
  dynamic get gatewayStartingStatus => 'Starting…';
  dynamic get gatewayRetryingStatus => 'Retrying…';
  dynamic get errorStartingGateway => 'Could not start the gateway';
  dynamic get runningStatus => 'Running';
  dynamic get stoppedStatus => 'Stopped';
  dynamic get notSetUpStatus => 'Not set up';
  dynamic get configuredStatus => 'Configured';
  dynamic get whatsAppConfigSaved => 'WhatsApp configuration saved';
  dynamic get whatsAppDisconnected => 'WhatsApp disconnected';
  dynamic get whatsAppTitle => 'WhatsApp';
  dynamic get applyingSettings => 'Applying settings…';
  dynamic get reconnectWhatsApp => 'Reconnect WhatsApp';
  dynamic get saveSettingsLabel => 'Save settings';
  dynamic get applySettingsRestart => 'Apply settings and restart';
  dynamic get whatsAppMode => 'WhatsApp mode';
  dynamic get myPersonalNumber => 'My personal number';
  dynamic get myPersonalNumberDesc =>
      'Link the number you already use every day.';
  dynamic get dedicatedBotAccount => 'Dedicated bot account';
  dynamic get dedicatedBotAccountDesc =>
      'Use a separate number just for your agent.';
  dynamic get allowedNumbers => 'Allowed numbers';
  dynamic get addNumberTitle => 'Add number';
  dynamic get phoneNumberJid => 'Phone number or JID';
  dynamic get noAllowedNumbersConfigured => 'No allowed numbers configured';
  dynamic get devicesAppearAfterPairing =>
      'Devices appear here once pairing completes.';
  dynamic get addPhoneNumbersHint =>
      'Add the numbers that may talk to your agent.';
  dynamic get allowedNumber => 'Allowed number';
  dynamic get howToConnect => 'How to connect';
  dynamic get whatsAppConnectInstructions =>
      'Open WhatsApp, go to Linked devices and scan the code below.';
  dynamic get whatsAppPairingDesc =>
      'New chats ask for your approval before the agent replies.';
  dynamic get whatsAppAllowlistDesc =>
      'Only the numbers you list can reach your agent.';
  dynamic get whatsAppOpenDesc =>
      'Anyone who messages this number gets a reply.';
  dynamic get whatsAppDisabledDesc =>
      'WhatsApp stays linked but the agent stays quiet.';
  dynamic get sessionExpiredRelink =>
      'The session expired — link the device again.';
  dynamic get connectWhatsAppBelow => 'Connect WhatsApp below to start.';
  dynamic get whatsAppAcceptedQr => 'WhatsApp accepted the code';
  dynamic get waitingForWhatsApp => 'Waiting for WhatsApp…';
  dynamic get focusedLabel => 'Focused';
  dynamic get balancedLabel => 'Balanced';
  dynamic get creativeLabel => 'Creative';
  dynamic get preciseLabel => 'Precise';
  dynamic get expressiveLabel => 'Expressive';
  dynamic get browseLabel => 'Browse';
  dynamic get apiTokenLabel => 'API token';
  dynamic get connectToClawHub => 'Connect to ClawHub';
  dynamic get clawHubLoginHint => 'Sign in to install and publish skills.';
  dynamic get howToGetApiToken => 'How to get an API token';
  dynamic get clawHubApiTokenInstructions =>
      'Open clawhub.dev, go to Account then Tokens, and create a new token.';
  dynamic get cronJobHintText => 'e.g. Summarise my unread mail every morning';
  dynamic get androidPermissions => 'Android permissions';
  dynamic get androidPermissionsDesc =>
      'FlutterClaw needs two permissions to control other apps.';
  dynamic get twoPermissionsNeeded => '2 permissions needed';
  dynamic get accessibilityService => 'Accessibility service';
  dynamic get accessibilityServiceDesc =>
      'Lets the agent read the screen and tap for you.';
  dynamic get displayOverOtherApps => 'Display over other apps';
  dynamic get displayOverOtherAppsDesc =>
      'Shows the agent overlay on top of other apps.';
  dynamic get changeDefaultModel => 'Change default model';
  dynamic get startNewSessions => 'Start new sessions';
  dynamic get currentConversationsArchived =>
      'Your current conversations are archived.';
  dynamic get applyAction => 'Apply';
  dynamic get setAsDefaultModel => 'Set as default model';
  dynamic get usedByAgentsWithout => 'Used by agents without their own model';
  dynamic get providerAlreadyAuth => 'This provider is already authenticated';
  dynamic get selectFromList => 'Select from list';
  dynamic get enterCustomModelId => 'Enter a custom model ID';
  dynamic get removeSkillTitle => 'Remove skill';
  dynamic get browseClawHubToDiscover => 'Browse ClawHub to discover skills.';
  dynamic get addDeviceTooltip => 'Add device';
  dynamic get addNumberTooltip => 'Add number';
  dynamic get searchSkillsHint => 'Search by name or tag';
  dynamic get loginToClawHub => 'Sign in to ClawHub';
  dynamic get accountTooltip => 'Account';
  dynamic get editAction => 'Edit';
  dynamic get setAsDefaultAction => 'Set as default';
  dynamic get chooseProviderTitle => 'Choose a provider';
  dynamic get apiKeyTitle => 'API key';
  dynamic get slackConfigSaved => 'Slack configuration saved';
  dynamic get signalConfigSaved => 'Signal configuration saved';
  dynamic get addDeviceHint => 'Enter the device ID you want to approve.';
  dynamic get skipAction => 'Skip';
  dynamic modelsConfiguredCount(dynamic count) => '';
  dynamic toolsDisabledCount(dynamic count) => '';
  dynamic connectionFailed(dynamic error) => '';
  dynamic cronJobRuns(dynamic count) => '';
  dynamic nextRunLabel(dynamic time) => '';
  dynamic lastErrorLabel(dynamic error) => '';
  dynamic setModelAsDefault(dynamic name) => '';
  dynamic alsoUpdateAgents(dynamic count) => '';
  dynamic applyModelQuestion(dynamic name) => '';
  dynamic applyToAgents(dynamic count) => '';
  dynamic idPrefix(dynamic id) => '';
  dynamic get officialWebsite => 'Official website';
  dynamic appVersionSubtitle(
    dynamic appName,
    dynamic version,
    dynamic buildNumber,
  ) => '';
  dynamic get speakMessage => 'Speak message';
  dynamic get stopSpeaking => 'Stop speaking';
  dynamic get selectText => 'Select text';
  dynamic get messageCopied => 'Message copied';
  dynamic get mcpServers => 'MCP servers';
  dynamic get noMcpServersConfigured => 'No MCP servers configured';
  dynamic get mcpServersEmptyHint =>
      'Add a server to give your agent more tools.';
  dynamic get addMcpServer => 'Add MCP server';
  dynamic get editMcpServer => 'Edit MCP server';
  dynamic get removeMcpServer => 'Remove MCP server';
  dynamic get mcpTransport => 'Transport';
  dynamic get testConnection => 'Test connection';
  dynamic get mcpServerNameLabel => 'Server name';
  dynamic get mcpServerNameHint => 'e.g. Company wiki';
  dynamic get mcpServerUrlLabel => 'Server URL';
  dynamic get mcpBearerTokenLabel => 'Bearer token';
  dynamic get mcpBearerTokenHint => 'Optional, sent as an Authorization header';
  dynamic get mcpCommandLabel => 'Command';
  dynamic get mcpArgumentsLabel => 'Arguments';
  dynamic get mcpEnvVarsLabel => 'Environment variables';
  dynamic get mcpStdioNotOnIos => 'stdio servers are not supported on iOS';
  dynamic get connectedStatus => 'Connected';
  dynamic get mcpConnecting => 'Connecting…';
  dynamic get mcpConnectionError => 'Connection error';
  dynamic get mcpDisconnected => 'Disconnected';
  dynamic get mcpTestOkNoTools => 'Connected, but the server exposes no tools';
  dynamic get mcpTestFailed => 'The connection test failed';
  dynamic get mcpAddServer => 'Add server';
  dynamic get mcpSaveChanges => 'Save changes';
  dynamic get urlIsRequired => 'URL is required';
  dynamic get enterValidUrl => 'Enter a valid URL';
  dynamic get commandIsRequired => 'Command is required';
  dynamic get editFileContentHint => 'Edit the file content';
  dynamic get whatsAppPairSubtitle => 'Link WhatsApp to chat from your phone';
  dynamic get whatsAppPairingOptional => 'You can do this later in Settings.';
  dynamic get whatsAppEnableToLink => 'Enable WhatsApp to link a device';
  dynamic get whatsAppLinkedOnboarding => 'WhatsApp is linked';
  dynamic get cancelLink => 'Cancel linking';
  dynamic removeMcpServerConfirm(dynamic name) => '';
  dynamic mcpToolsCount(dynamic count) => '';
  dynamic mcpTestOkTools(dynamic count) => '';
  dynamic skillRemoved(dynamic name) => '';
  dynamic get voiceCallModelSection => 'Voice call model';
  dynamic get voiceCallModelDescription =>
      'The model used for live voice conversations.';
  dynamic get voiceCallModelLabel => 'Voice model';
  dynamic get voiceCallModelAutomatic => 'Automatic';
  dynamic get preferLiveVoiceBootstrapTitle => 'Start in voice mode';
  dynamic get preferLiveVoiceBootstrapSubtitle =>
      'Open a live voice call instead of the chat screen.';
  dynamic get firstHatchModeChoiceTitle => 'How do you want to start?';
  dynamic get firstHatchModeChoiceBody =>
      'You can switch between chat and voice at any time.';
  dynamic get firstHatchModeChoiceChatButton => 'Start chatting';
  dynamic get firstHatchModeChoiceVoiceButton => 'Start talking';
  dynamic get liveVoiceBargeInHint => 'Just start talking to interrupt.';
  dynamic get cannotAddLiveModelAsChat =>
      'Live voice models cannot be added as chat models.';
  dynamic get liveVoiceNameLabel => 'Live voice';
  dynamic get liveVoiceFallbackTitle => 'Voice unavailable';
  dynamic get liveVoiceEndConversationTooltip => 'End conversation';
  dynamic get liveVoiceStatusConnecting => 'Connecting…';
  dynamic get liveVoiceStatusRunning => 'Live';
  dynamic get liveVoiceStatusSpeaking => 'Speaking…';
  dynamic get liveVoiceStatusListening => 'Listening…';
  dynamic get liveVoiceBadge => 'LIVE';
  dynamic get authBearerTokenLabel => 'Bearer token';
  dynamic get authAccessKeysLabel => 'Access keys';
  dynamic get scanQrBarcodeTitle => 'Scan QR code';
  dynamic get oauthSignInTitle => 'Sign in';
  dynamic get browserOverlayDone => 'Done';
  dynamic get credentialsScreenTitle => 'Credentials';
  dynamic get credentialsIntroBody =>
      'Keys are stored in the device keychain and never leave it.';
  dynamic get credentialsNoProvidersBody =>
      'Add a provider to store its credentials here.';
  dynamic get credentialsAddKeyTooltip => 'Add key';
  dynamic get credentialsNoExtraKeysMessage =>
      'No extra keys for this provider';
  dynamic get credentialsKeyLabelHint => 'e.g. Work account';
  dynamic get credentialsApiKeyFieldLabel => 'API key';
  dynamic get securitySettingsTitle => 'Security';
  dynamic get securitySettingsIntro =>
      'Controls how carefully tool calls are checked before they run.';
  dynamic get securitySectionToolExecution => 'Tool execution';
  dynamic get securityPatternDetectionTitle => 'Pattern detection';
  dynamic get securityPatternDetectionSubtitle =>
      'Block commands that match known dangerous patterns.';
  dynamic get securityUnsafeModeBanner => 'Unsafe mode is on for this session.';
  dynamic get securitySectionHowItWorks => 'How it works';
  dynamic get securityHowItWorksBlocked => 'Blocked commands are never run.';
  dynamic get securityHowItWorksUnsafeCmd =>
      'Unsafe commands ask for your confirmation first.';
  dynamic get securityHowItWorksToggleSession =>
      'You can turn this off per session from the chat menu.';
  dynamic authModelsFoundCount(dynamic count) => '';
  dynamic authModelsFoundMoreManual(dynamic count) => '';
  dynamic appInitializationError(dynamic error) => '';
  dynamic credentialsAddProviderKeyTitle(dynamic provider) => '';
  dynamic get searchModels => 'Search models';
  dynamic get noModelsFound => 'No models found';
  dynamic get useCustomIdHint => 'Not listed? Enter the model ID by hand.';
  dynamic get useModelId => 'Use this model ID';
  dynamic get modelsAvailable => 'Models available';
  dynamic get modelUnavailableTitle => 'Model unavailable';
  dynamic get changeModel => 'Change model';
  dynamic get credentialLabel => 'Credential';
  dynamic get credentialLabelHint => 'e.g. Personal key';
  dynamic get selectCredential => 'Select credential';
  dynamic get saveAnyway => 'Save anyway';
  dynamic get channelDisconnected => 'Channel disconnected';
  dynamic get newConversationTitle => 'New conversation';
  dynamic get newConversationMessage =>
      'This archives the current conversation and starts a fresh one.';
  dynamic get startNewConversation => 'Start new conversation';
  dynamic get retryingRequest => 'Retrying the request…';
  dynamic get contextCompacted => 'Conversation compacted';
  dynamic get compactionFailed => 'Compaction failed';
  dynamic get allowedUsersTitle => 'Allowed users';
  dynamic get allowlistEmptyWarning =>
      'The allowlist is empty, so nobody can reach your agent.';
  dynamic get allowFromAddHint => 'Add a user ID to allow them.';
  dynamic get llmErrorPayloadTooLarge =>
      'The request was too large for this model. Try compacting the conversation.';
  dynamic get llmErrorPayloadTooLargeTitle => 'Request too large';
  dynamic get llmErrorViewDocs => 'View docs';
  dynamic get llmErrorOpenRouterPrivacy =>
      'OpenRouter needs a privacy setting enabled before this model can run.';
  dynamic get llmErrorOpenRouterPrivacyTitle => 'Privacy settings required';
  dynamic get llmErrorOpenPrivacySettings => 'Open privacy settings';
  dynamic get llmError401 => 'Your API key was rejected. Check it in Settings.';
  dynamic get llmError402 => 'Your provider account is out of credit.';
  dynamic get llmError403 => 'This model is not available to your account.';
  dynamic get llmError404 => 'The model was not found at this provider.';
  dynamic get llmError413 => 'The request was too large.';
  dynamic get llmError429 => 'Rate limit reached. Wait a moment and try again.';
  dynamic get llmError500 => 'The provider had an internal error.';
  dynamic get llmError503 => 'The provider is temporarily unavailable.';
  dynamic get llmError529 => 'The provider is overloaded. Try again shortly.';
  dynamic get llmErrorNetwork => 'No connection to the provider.';
  dynamic get llmErrorTimeout => 'The provider took too long to answer.';
  dynamic get llmErrorUnknown =>
      'Something went wrong talking to the provider.';
  dynamic get discoverModels => 'Discover models';
  dynamic get refreshModels => 'Refresh models';
  dynamic get modelNotInProviderList =>
      'This model is not in the provider list.';
  dynamic modelUnavailableMessage(dynamic model) => '';
  dynamic tokenValidationFailed(dynamic error) => '';
  dynamic channelConnectFailed(dynamic error) => '';
  dynamic channelErrorLabel(dynamic error) => '';
  dynamic llmError400(dynamic raw) => '';
  dynamic llmErrorWithStatus(dynamic statusCode, dynamic raw) => '';
  dynamic get savedNotConnectedStatus => 'Saved, not connected';
  dynamic get savedNotConnectedHint =>
      'The settings are stored, but the gateway is not running.';
  dynamic get gatewayRunsLocally => 'The gateway runs on this device.';
  dynamic get gatewaySettingsLink => 'Gateway settings';
  dynamic get mcpServersTitle => 'MCP servers';
  dynamic get mcpServersSubtitleEmpty => 'No servers connected';
  dynamic get securityChecksActive => 'Security checks are active';
  dynamic get securityChecksDisabled => 'Security checks are turned off';
  dynamic get keyRotationAdvanced => 'Key rotation (advanced)';
  dynamic get toolPoliciesOtherToolsNote =>
      'Tools not listed here are always available to your agent.';
  dynamic get toolPoliciesMcpLink =>
      'Tools from MCP servers follow their own policy.';
  dynamic get providerKeyInvalidTapToFix =>
      'This provider key was rejected — tap to fix it.';
  dynamic get sessionChatLabel => 'Chat';
  dynamic get switchAgentOrSession => 'Switch agent or session';
  dynamic get agentsSection => 'Agents';
  dynamic get errorNoBalance => 'Your provider account is out of credit.';
  dynamic get errorAccessDenied => 'Access denied by the provider.';
  dynamic get errorModelNotFound => 'That model was not found.';
  dynamic get errorRateLimitReached =>
      'Rate limit reached. Try again in a moment.';
  dynamic get errorServiceUnavailable =>
      'The service is unavailable right now.';
  dynamic get errorConnection => 'No connection. Check your network.';
  dynamic get whatsappNotConnected => 'WhatsApp is not connected';
  dynamic get channelHealthIssue => 'This channel needs attention';
  dynamic get testConnectionFirst => 'Test the connection first';
  dynamic mcpServersSubtitleActive(dynamic enabled, dynamic total) => '';
  dynamic sessionDetailKey(dynamic key) => '';
  dynamic credentialsCoolingDown(dynamic reason) => '';
  dynamic credentialsErrorCount(dynamic count) => '';
  dynamic get downloadingSkill => 'Downloading skill…';
  dynamic get checkingCompatibility => 'Checking compatibility…';
}

class AppTokens {
  AppTokens();
  static const dynamic spacingXS = 4.0;
  static const dynamic spacingSM = 8.0;
  static const dynamic spacingMD = 12.0;
  static const dynamic spacingLG = 16.0;
  static const dynamic spacingXL = 24.0;
  static const dynamic spacingXXL = 32.0;
  static const dynamic radiusSM = 8.0;
  static const dynamic radiusMD = 12.0;
  static const dynamic radiusLG = 20.0;
  static const dynamic radiusPill = 999.0;
  static const dynamic durationFast = Duration(milliseconds: 120);
  static const dynamic durationNormal = Duration(milliseconds: 220);
  static const dynamic durationSlow = Duration(milliseconds: 400);
  static const dynamic iconXS = 14.0;
  static const dynamic iconSM = 18.0;
  static const dynamic iconMD = 20.0;
  static const dynamic iconLG = 24.0;
  static const dynamic iconXL = 32.0;
  static const dynamic iconHero = 48.0;
  static const dynamic iconDisplay = 64.0;
  static const dynamic elevationNone = 0.0;
  static const dynamic elevationLow = 1.0;
  static const dynamic elevationMid = 3.0;
  static const dynamic elevationHigh = 6.0;
  static const dynamic touchTarget = 48.0;
  static const dynamic touchTargetSM = 40.0;
  static const dynamic opacityDisabled = 0.38;
  static const dynamic opacitySubdued = 0.60;
  static const dynamic opacityHint = 0.45;
}

class CatalogProvider {
  const CatalogProvider({
    dynamic id,
    dynamic displayName,
    dynamic description,
    dynamic icon,
    dynamic logoAsset,
    dynamic signupUrl,
    dynamic apiBase,
    dynamic hasFreeModels,
  });
  dynamic get id => 'anthropic';
  dynamic get displayName => 'Anthropic';
  dynamic get description =>
      'Claude models, billed straight to your Anthropic account.';
  dynamic get icon => const _Stub();
  dynamic get signupUrl => 'https://console.anthropic.com/settings/keys';
  dynamic get apiBase => null;
  dynamic get hasFreeModels => false;
  dynamic get logoAsset => null;
}

class ConfigManager {
  ConfigManager([dynamic p0]);
  dynamic get config => FlutterClawConfig();
  dynamic get configDir => Future<String>.value(
    '/var/mobile/Containers/Data/Application/FlutterClaw/Documents/config',
  );
  dynamic get configPath => Future<String>.value(
    '/var/mobile/Containers/Data/Application/FlutterClaw/Documents/config/'
    'flutterclaw.json',
  );
  dynamic get workspacePath => Future<String>.value(
    '/var/mobile/Containers/Data/Application/FlutterClaw/Documents/workspace',
  );
  dynamic getAgentWorkspace(dynamic agentId) => Future<String>.value('');
  dynamic ensureDirectories() => const _Stub();
  dynamic createAgentWorkspace(dynamic agent) => const _Stub();
  dynamic switchAgent(dynamic agentId) => const _Stub();
  dynamic load() => const _Stub();
  dynamic syncAgentIdentitiesFromWorkspace() => const _Stub();
  static dynamic updateIdentityField(
    dynamic content,
    dynamic field,
    dynamic value,
  ) => '';
  dynamic save() => const _Stub();
  void update(dynamic config) {}
  dynamic hasBootstrap() => Future<bool>.value(false);
  dynamic removeBootstrap() => const _Stub();
  dynamic get secretsResolver => null;
  set secretsResolver(dynamic _) {}
  dynamic resolveApiKeyAsync(dynamic entry) => Future<String>.value('');
  dynamic get secretsWriter => null;
  set secretsWriter(dynamic _) {}
  static void addSaveListener(dynamic listener) {}
  static dynamic isSecretRef(dynamic value) => false;
  static dynamic secretRef(dynamic name) => '';
  dynamic ensureGatewayToken() => const _Stub();
  static dynamic providerSecretName(dynamic credentialId) => '';
}

class ConsumerState<WidgetT> {
  ConsumerState();
  dynamic get ref => WidgetRef();
}

class FlutterClawConfig {
  const FlutterClawConfig({
    dynamic agents,
    dynamic modelList,
    dynamic channels,
    dynamic tools,
    dynamic heartbeat,
    dynamic gateway,
    dynamic onboardingCompleted,
    dynamic pendingFirstHatchModePrompt,
    dynamic agentProfiles,
    dynamic activeAgentId,
    dynamic providerCredentials,
    dynamic mcpServers,
    dynamic emailAccounts,
    dynamic oauthConnections,
  });
  FlutterClawConfig.fromJson(dynamic json);
  dynamic get agents => AgentsConfig();
  dynamic get modelList => [];
  dynamic get channels => const _Stub();
  dynamic get tools => const _Stub();
  dynamic get heartbeat => const _Stub();
  dynamic get gateway => const _Stub();
  dynamic get onboardingCompleted => false;
  dynamic get agentProfiles => [];
  dynamic get activeAgentId => null;
  dynamic get providerCredentials => {};
  dynamic get activeAgent => null;
  dynamic getModel(dynamic name) => null;
  dynamic getModels(dynamic name) => [];
  dynamic resolveApiKey(dynamic entry) => '';
  dynamic resolveApiBase(dynamic entry) => '';
  dynamic isProviderAuthenticated(dynamic providerId) => false;
  dynamic withProviderCredential(dynamic providerId, dynamic credential) =>
      FlutterClawConfig();
  dynamic toJson() => <String, dynamic>{};
  dynamic copyWith({
    dynamic agents,
    dynamic modelList,
    dynamic channels,
    dynamic tools,
    dynamic heartbeat,
    dynamic gateway,
    dynamic onboardingCompleted,
    dynamic pendingFirstHatchModePrompt,
    dynamic agentProfiles,
    dynamic activeAgentId,
    dynamic providerCredentials,
    dynamic mcpServers,
    dynamic emailAccounts,
    dynamic oauthConnections,
  }) => FlutterClawConfig();
  dynamic get mcpServers => [];
  dynamic get emailAccounts => [];
  dynamic get oauthConnections => [];
  dynamic get pendingFirstHatchModePrompt => false;
  dynamic credentialsForProvider(dynamic baseProviderId) => {};
}

extension L10nContext on BuildContext {
  dynamic get l10n => const AppLocalizations('en');
}

class ModelCatalog {
  ModelCatalog();
  static const dynamic providers = null;
  static const dynamic models = null;
  static dynamic get freeModels => [];
  static dynamic getProvider(dynamic id) => null;
  static dynamic modelsForProvider(dynamic providerId) => [];
  static dynamic inputFor(dynamic modelId) => null;
  static dynamic formatContext(dynamic tokens) => '';
  static dynamic get availableProviders => [];
  static dynamic get availableModels => [];
  static dynamic availableModelsForProvider(dynamic providerId) => [];
  static dynamic tryGetModel(dynamic id) => null;
  static dynamic tryGetModelFlexible(dynamic id) => null;
  static dynamic isLiveCatalogId(dynamic modelId) => false;
  static dynamic chatCatalogModelsForProvider(dynamic providerId) => [];
  static dynamic liveCatalogModelsForProvider(dynamic providerId) => [];
  static dynamic providerHasLiveVoiceModel(dynamic providerId) => false;
}

class ModelEntry {
  const ModelEntry({
    dynamic modelName,
    dynamic model,
    dynamic apiKey,
    dynamic apiBase,
    dynamic requestTimeout,
    dynamic provider,
    dynamic isFree,
    dynamic input,
    dynamic credentialId,
  });
  ModelEntry.fromJson(dynamic json);
  dynamic get modelName => 'claude-sonnet-4-5';
  dynamic get model => 'claude-sonnet-4-5-20250929';
  dynamic get apiKey => null;
  dynamic get apiBase => null;
  dynamic get requestTimeout => null;
  dynamic get provider => 'anthropic';
  dynamic get isFree => false;
  dynamic get input => null;
  dynamic get supportsVision => false;
  dynamic get supportsAudio => false;
  dynamic get vendor => 'Anthropic';
  dynamic get modelId => 'claude-sonnet-4-5-20250929';
  dynamic toJson() => <String, dynamic>{};
  dynamic get isLiveOnly => false;
  dynamic get supportsLive => false;
  dynamic get credentialId => null;
}

class ProviderCredential {
  const ProviderCredential({
    dynamic apiKey,
    dynamic apiBase,
    dynamic awsSecretKey,
    dynamic awsRegion,
    dynamic awsAuthMode,
  });
  ProviderCredential.fromJson(dynamic json);
  dynamic get apiKey => 'sk-ant-api03-fixture-0000000000000000000000';
  dynamic get apiBase => null;
  dynamic toJson() => <String, dynamic>{};
  dynamic get awsSecretKey => null;
  dynamic get awsRegion => null;
  dynamic get awsAuthMode => null;
}

class WidgetRef {
  WidgetRef();
  dynamic get context => const _Stub();
  // HAND-AUTHORED 2026-09-15 (provider passthrough). Was `=> const _Stub()`, which threw
  // away the stand-in the generator had already reconstructed for the provider and handed the
  // transplant a `_Stub` instead -- so any `ref.watch(x).y` reaching a statically typed slot
  // threw inside `build` and the device drew Flutter's error box. Handing back the provider
  // itself keeps the chain typed; a provider still standing in as `_Stub` is unchanged, so
  // this is inert until one is given a value.
  dynamic watch<StateT>(dynamic provider) =>
      provider is _Stub ? const _Stub() : provider;
  dynamic exists(dynamic provider) => false;
  void listen<StateT>(
    dynamic provider,
    dynamic listener, {
    dynamic onError,
    dynamic weak,
  }) {}
  dynamic listenManual<StateT>(
    dynamic provider,
    dynamic listener, {
    dynamic onError,
    dynamic fireImmediately,
    dynamic weak,
  }) => const _Stub();
  dynamic read<StateT>(dynamic provider) =>
      provider is _Stub ? const _Stub() : provider;
  dynamic refresh<StateT>(dynamic provider) =>
      provider is _Stub ? const _Stub() : provider;
  void invalidate(dynamic provider, {dynamic asReload}) {}
}

dynamic analyticsServiceProvider = const _Stub();

// HAND-AUTHORED 2026-09-15, with the provider passthrough above. `ref.watch(configManagerProvider)`
// reaches a statically typed slot in the transplant, so a `_Stub` threw inside `build`
// and the device drew Flutter's error box. `ConfigManager` is the stand-in the generator already
// reconstructed from the call sites; the provider was the one link still standing in.
dynamic configManagerProvider = ConfigManager();

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

class SvgPicture extends StatelessWidget {
  const SvgPicture(
    dynamic bytesLoader, {
    super.key,
    dynamic width,
    dynamic height,
    dynamic fit,
    dynamic alignment,
    dynamic matchTextDirection,
    dynamic allowDrawingOutsideViewBox,
    dynamic placeholderBuilder,
    dynamic colorFilter,
    dynamic semanticsLabel,
    dynamic excludeFromSemantics,
    dynamic clipBehavior,
    dynamic errorBuilder,
    dynamic theme,
    dynamic cacheColorFilter,
    dynamic renderingStrategy,
  });
  SvgPicture.asset(
    dynamic assetName, {
    super.key,
    dynamic matchTextDirection,
    dynamic bundle,
    dynamic package,
    dynamic width,
    dynamic height,
    dynamic fit,
    dynamic alignment,
    dynamic allowDrawingOutsideViewBox,
    dynamic placeholderBuilder,
    dynamic semanticsLabel,
    dynamic excludeFromSemantics,
    dynamic clipBehavior,
    dynamic errorBuilder,
    dynamic theme,
    dynamic colorMapper,
    dynamic colorFilter,
    dynamic color,
    dynamic colorBlendMode,
    dynamic cacheColorFilter,
    dynamic renderingStrategy,
  });
  SvgPicture.network(
    dynamic url, {
    super.key,
    dynamic headers,
    dynamic width,
    dynamic height,
    dynamic fit,
    dynamic alignment,
    dynamic matchTextDirection,
    dynamic allowDrawingOutsideViewBox,
    dynamic placeholderBuilder,
    dynamic colorFilter,
    dynamic color,
    dynamic colorBlendMode,
    dynamic semanticsLabel,
    dynamic excludeFromSemantics,
    dynamic clipBehavior,
    dynamic errorBuilder,
    dynamic cacheColorFilter,
    dynamic theme,
    dynamic colorMapper,
    dynamic httpClient,
    dynamic renderingStrategy,
  });
  SvgPicture.file(
    dynamic file, {
    super.key,
    dynamic width,
    dynamic height,
    dynamic fit,
    dynamic alignment,
    dynamic matchTextDirection,
    dynamic allowDrawingOutsideViewBox,
    dynamic placeholderBuilder,
    dynamic colorFilter,
    dynamic color,
    dynamic colorBlendMode,
    dynamic semanticsLabel,
    dynamic excludeFromSemantics,
    dynamic clipBehavior,
    dynamic errorBuilder,
    dynamic theme,
    dynamic colorMapper,
    dynamic cacheColorFilter,
    dynamic renderingStrategy,
  });
  SvgPicture.memory(
    dynamic bytes, {
    super.key,
    dynamic width,
    dynamic height,
    dynamic fit,
    dynamic alignment,
    dynamic matchTextDirection,
    dynamic allowDrawingOutsideViewBox,
    dynamic placeholderBuilder,
    dynamic colorFilter,
    dynamic color,
    dynamic colorBlendMode,
    dynamic semanticsLabel,
    dynamic excludeFromSemantics,
    dynamic clipBehavior,
    dynamic errorBuilder,
    dynamic theme,
    dynamic colorMapper,
    dynamic cacheColorFilter,
    dynamic renderingStrategy,
  });
  SvgPicture.string(
    dynamic string, {
    super.key,
    dynamic width,
    dynamic height,
    dynamic fit,
    dynamic alignment,
    dynamic matchTextDirection,
    dynamic allowDrawingOutsideViewBox,
    dynamic placeholderBuilder,
    dynamic colorFilter,
    dynamic color,
    dynamic colorBlendMode,
    dynamic semanticsLabel,
    dynamic excludeFromSemantics,
    dynamic clipBehavior,
    dynamic errorBuilder,
    dynamic theme,
    dynamic colorMapper,
    dynamic cacheColorFilter,
    dynamic renderingStrategy,
  });
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
  static dynamic get defaultPlaceholderBuilder => const _Stub();
  static set defaultPlaceholderBuilder(dynamic _) {}
  dynamic get width => null;
  dynamic get height => null;
  dynamic get fit => const _Stub();
  dynamic get alignment => const _Stub();
  dynamic get bytesLoader => const _Stub();
  dynamic get placeholderBuilder => null;
  dynamic get matchTextDirection => false;
  dynamic get allowDrawingOutsideViewBox => false;
  dynamic get semanticsLabel => null;
  dynamic get excludeFromSemantics => false;
  dynamic get clipBehavior => const _Stub();
  dynamic get errorBuilder => null;
  dynamic get colorFilter => null;
  dynamic get renderingStrategy => const _Stub();
}

class CatalogModel {
  const CatalogModel({
    dynamic id,
    dynamic displayName,
    dynamic providerId,
    dynamic isFree,
    dynamic contextWindow,
    dynamic description,
    dynamic input,
    dynamic inputPriceUsdPerMillion,
    dynamic outputPriceUsdPerMillion,
    dynamic cacheReadPriceUsdPerMillion,
    dynamic cacheWritePriceUsdPerMillion,
    dynamic supportsAdaptiveThinking,
    dynamic supportsExtendedThinking,
    dynamic defaultEffort,
    dynamic supportsLive,
  });
  dynamic get id => 'claude-sonnet-4-5';
  dynamic get displayName => 'Claude Sonnet 4.5';
  dynamic get providerId => 'anthropic';
  dynamic get isFree => false;
  dynamic get contextWindow => 200000;
  dynamic get description => null;
  dynamic get input => <String>[];
  dynamic get inputPriceUsdPerMillion => 3.0;
  dynamic get outputPriceUsdPerMillion => 15.0;
  dynamic get cacheReadPriceUsdPerMillion => 0.3;
  dynamic get cacheWritePriceUsdPerMillion => 3.75;
  dynamic get supportsAdaptiveThinking => false;
  dynamic get supportsExtendedThinking => false;
  dynamic get defaultEffort => 'medium';
  dynamic get supportsLive => false;
  dynamic get supportsVision => false;
  dynamic get supportsAudio => false;
  dynamic get hasPricing => false;
  dynamic get isLiveModel => false;
  dynamic computeCostUsd({
    dynamic inputTokens,
    dynamic outputTokens,
    dynamic cacheReadTokens,
    dynamic cacheWriteTokens,
  }) => 0.0;
}
