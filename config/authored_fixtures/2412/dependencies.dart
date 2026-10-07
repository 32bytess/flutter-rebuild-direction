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
  dynamic connectToProvider(dynamic provider) => 'Connect to OpenAI';
  dynamic telegramBotToken(dynamic platform) => 'Telegram bot token';
  dynamic viaProvider(dynamic provider) => 'via OpenAI';
  dynamic status(dynamic status) => 'Connected';
  dynamic minutesLeft(dynamic minutes) => '4 minutes left';
  dynamic sessionsCount(dynamic count) => '3 sessions';
  dynamic removeSkillConfirm(dynamic name) =>
      'Remove Daily digest from this device?';
  dynamic installedSkill(dynamic name) => 'Installed Daily digest';
  dynamic failedToInstallSkill(dynamic name) =>
      'Could not install Daily digest';
  dynamic messagesCount(dynamic count) => '128 messages';
  dynamic tokensCount(dynamic count) => '18.4k tokens';
  dynamic intervalMinutes(dynamic minutes) => 'Every 15 minutes';
  dynamic removeModelConfirm(dynamic name) =>
      'Remove gpt-4o-mini from your models?';
  dynamic getApiKeyAt(dynamic provider) =>
      'Get an API key at platform.openai.com';
  dynamic minutesAgo(dynamic minutes) => '12 minutes ago';
  dynamic hoursAgo(dynamic hours) => '5 hours ago';
  dynamic daysAgo(dynamic days) => '3 days ago';
  dynamic liveTranscriptionUnavailable(dynamic error) =>
      'Live transcription is unavailable: the microphone is busy';
  dynamic failedToStartRecording(dynamic error) =>
      'Could not start recording: the microphone is busy';
  dynamic whisperApiFailed(dynamic error) =>
      'Whisper request failed: rate limited';
  dynamic failedToStopRecording(dynamic error) =>
      'Could not stop recording: the recorder is not active';
  dynamic failedToPauseResume(dynamic action, dynamic error) =>
      'Could not pause recording: the recorder is not active';
  dynamic modelLabel(dynamic model) => 'Model: gpt-4o-mini';
  dynamic uptimeLabel(dynamic uptime) => 'Uptime: 2h 14m';
  dynamic switchedToAgent(dynamic name) => 'Switched to Aria';
  dynamic deleteAgentConfirm(dynamic name) => 'Delete Aria and its workspace?';
  dynamic removeProviderConfirm(dynamic provider) =>
      'Remove OpenAI and its saved keys?';
  dynamic modelSetAsDefault(dynamic name) =>
      'gpt-4o-mini is now the default model';
  dynamic couldNotOpenDocument(dynamic error) =>
      'Could not open the document: unsupported format';
  dynamic gatewayFailed(dynamic error) =>
      'Gateway failed: port 8765 is already in use';
  dynamic exceptionError(dynamic error) =>
      'Something went wrong: the connection was closed';
  dynamic removeAccessFor(dynamic name) => 'Remove access for iPhone 15?';
  dynamic incompatibleSkillDesc(dynamic reason) =>
      'This skill needs tools this device does not provide.';
  dynamic compatibilityWarningDesc(dynamic reason) =>
      'This skill was written for a newer FlutterClaw build.';
  dynamic resetSessionConfirm(dynamic key) =>
      'Reset the conversation in this session?';
  dynamic errorGeneric(dynamic error) => 'Error: the connection was closed';
  dynamic fileSaved(dynamic fileName) => 'Saved notes.md';
  dynamic errorSavingFile(dynamic error) =>
      'Could not save the file: not enough space';
  dynamic temperatureLabel(dynamic value) => 'Temperature 0.7';
  dynamic secondsAgo(dynamic seconds) => '45 seconds ago';
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
  dynamic modelsConfiguredCount(dynamic count) => '4 models configured';
  dynamic toolsDisabledCount(dynamic count) => '2 tools disabled';
  dynamic connectionFailed(dynamic error) =>
      'Connection failed: the request timed out';
  dynamic cronJobRuns(dynamic count) => '12 runs';
  dynamic nextRunLabel(dynamic time) => 'Next run 18:30';
  dynamic lastErrorLabel(dynamic error) => 'Last error: the request timed out';
  dynamic setModelAsDefault(dynamic name) => 'Set gpt-4o-mini as default?';
  dynamic alsoUpdateAgents(dynamic count) => 'Also update 3 agents';
  dynamic applyModelQuestion(dynamic name) => 'Apply gpt-4o-mini everywhere?';
  dynamic applyToAgents(dynamic count) => 'Apply to 3 agents';
  dynamic idPrefix(dynamic id) => 'ID a1b2c3';
}

class ConfigManager {
  ConfigManager([dynamic p0]);
  dynamic get config => FlutterClawConfig();
  dynamic get configDir => Future<String>.value(
    '/var/mobile/Containers/Data/Application/'
    'FlutterClaw/Documents/config',
  );
  dynamic get configPath => Future<String>.value(
    '/var/mobile/Containers/Data/Application/'
    'FlutterClaw/Documents/config/flutterclaw.json',
  );
  dynamic get workspacePath => Future<String>.value(
    '/var/mobile/Containers/Data/Application/'
    'FlutterClaw/Documents/workspace',
  );
  dynamic getAgentWorkspace(dynamic agentId) => Future<String>.value(
    '/var/mobile/Containers/Data/Application/'
    'FlutterClaw/Documents/workspace/aria',
  );
  dynamic ensureDirectories() => const _Stub();
  dynamic createAgentWorkspace(dynamic agent) => const _Stub();
  dynamic switchAgent(dynamic agentId) => const _Stub();
  dynamic load() => const _Stub();
  dynamic syncAgentIdentitiesFromWorkspace() => const _Stub();
  static dynamic updateIdentityField(
    dynamic content,
    dynamic field,
    dynamic value,
  ) => 'name: Aria';
  dynamic save() => const _Stub();
  void update(dynamic config) {}
  dynamic hasBootstrap() => Future<bool>.value(false);
  dynamic removeBootstrap() => const _Stub();
}

class ConsumerWidget extends StatelessWidget {
  const ConsumerWidget({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
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
    dynamic agentProfiles,
    dynamic activeAgentId,
    dynamic providerCredentials,
  });
  FlutterClawConfig.fromJson(dynamic json);
  dynamic get agents => const _Stub();
  dynamic get modelList => [];
  dynamic get channels => const _Stub();
  dynamic get tools => ToolsConfig();
  dynamic get heartbeat => const _Stub();
  dynamic get gateway => GatewayConfig();
  dynamic get onboardingCompleted => false;
  dynamic get agentProfiles => [];
  dynamic get activeAgentId => null;
  dynamic get providerCredentials => {};
  dynamic get activeAgent => null;
  dynamic getModel(dynamic name) => null;
  dynamic getModels(dynamic name) => [];
  dynamic resolveApiKey(dynamic entry) => 'sk-fixture-4f2b9c7d1a6e';
  dynamic resolveApiBase(dynamic entry) => 'https://api.openai.com/v1';
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
    dynamic agentProfiles,
    dynamic activeAgentId,
    dynamic providerCredentials,
  }) => FlutterClawConfig();
}

class GatewayConfig {
  const GatewayConfig({
    dynamic host,
    dynamic port,
    dynamic autoStart,
    dynamic token,
  });
  GatewayConfig.fromJson(dynamic json);
  dynamic get host => '127.0.0.1';
  dynamic get port => 8765;
  dynamic get autoStart => false;
  dynamic get token => '';
  dynamic toJson() => <String, dynamic>{};
}

extension L10nContext on BuildContext {
  dynamic get l10n => const AppLocalizations('en');
}

class ToolsConfig {
  const ToolsConfig({dynamic web, dynamic disabled});
  ToolsConfig.fromJson(dynamic json);
  dynamic get web => const _Stub();
  dynamic get disabled => <String>[];
  dynamic isDisabled(dynamic toolName) => false;
  dynamic toJson() => <String, dynamic>{};
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
