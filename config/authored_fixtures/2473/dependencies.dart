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

bool fixtureDetected = false;

// DECLARATION-ONLY STAND-INS -- repo-local declarations that build no UI, and
// third-party ones the transplant does not inline. Supertypes are mirrored so a
// widget still reads as a widget; everything else is `dynamic`, because none of it
// is measured.

class BarcodeCapture {
  const BarcodeCapture({
    dynamic barcodes,
    dynamic image,
    dynamic raw,
    dynamic size,
  });
  dynamic get barcodes => [];
  dynamic get image => null;
  dynamic get raw => const _Stub();
  dynamic get size => const _Stub();
}

class MobileScanner extends StatelessWidget {
  const MobileScanner({
    dynamic controller,
    dynamic onDetect,
    dynamic onDetectError,
    dynamic fit,
    dynamic errorBuilder,
    dynamic overlayBuilder,
    dynamic placeholderBuilder,
    dynamic scanWindow,
    dynamic scanWindowUpdateThreshold,
    dynamic useAppLifecycleState,
    dynamic tapToFocus,
    super.key,
  });
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
  dynamic get controller => null;
  dynamic get onDetect => null;
  dynamic get onDetectError => const _Stub();
  dynamic get errorBuilder => null;
  dynamic get fit => const _Stub();
  dynamic get overlayBuilder => null;
  dynamic get placeholderBuilder => null;
  dynamic get scanWindow => null;
  dynamic get scanWindowUpdateThreshold => 0.0;
  dynamic get useAppLifecycleState => false;
  dynamic get tapToFocus => false;
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
  AppLocalizations(dynamic locale);
  dynamic get localeName => 'en';
  static const dynamic delegate = null;
  static const dynamic localizationsDelegates = null;
  static const dynamic supportedLocales = null;
  dynamic get appTitle => 'FlutterClaw';
  dynamic get chat => 'Chat';
  dynamic get channels => 'Channels';
  dynamic get agent => 'Agent';
  dynamic get settings => 'Settings';
  dynamic get getStarted => 'Get Started';
  dynamic get yourPersonalAssistant => 'Your personal assistant';
  dynamic get multiChannelChat => 'Multi-channel chat';
  dynamic get multiChannelChatDesc => 'Talk to your agent from Telegram, Discord, Slack or the built-in chat.';
  dynamic get powerfulAIModels => 'Powerful AI models';
  dynamic get powerfulAIModelsDesc => 'Bring your own key and pick any model from OpenAI, Anthropic or OpenRouter.';
  dynamic get localGateway => 'Local gateway';
  dynamic get localGatewayDesc => 'Runs on your device, so your conversations never leave it.';
  dynamic get chooseProvider => 'Choose a provider';
  dynamic get selectProviderDesc => 'Select where your model requests are sent.';
  dynamic get startForFree => 'Start for free';
  dynamic get freeProvidersDesc => 'These providers offer a free tier, no credit card required.';
  dynamic get free => 'Free';
  dynamic get otherProviders => 'Other providers';
  dynamic get enterApiKeyDesc => 'Paste the API key from your provider dashboard.';
  dynamic get dontHaveApiKey => 'Do not have an API key?';
  dynamic get createAccountCopyKey => 'Create an account and copy your key.';
  dynamic get signUp => 'Sign up';
  dynamic get apiKey => 'API key';
  dynamic get pasteFromClipboard => 'Paste from clipboard';
  dynamic get apiBaseUrl => 'API base URL';
  dynamic get selectModel => 'Select model';
  dynamic get modelId => 'Model ID';
  dynamic get validateKey => 'Validate key';
  dynamic get validating => 'Validating...';
  dynamic get invalidApiKey => 'That API key was rejected by the provider.';
  dynamic get gatewayConfiguration => 'Gateway configuration';
  dynamic get gatewayConfigDesc => 'The gateway routes messages between your channels and the agent.';
  dynamic get defaultSettingsNote => 'The default settings work for most setups.';
  dynamic get host => 'Host';
  dynamic get port => 'Port';
  dynamic get autoStartGateway => 'Auto-start gateway';
  dynamic get autoStartGatewayDesc => 'Start the gateway whenever the app launches.';
  dynamic get channelsPageTitle => 'Connect your channels';
  dynamic get channelsPageDesc => 'Choose where you want to talk to your agent.';
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
  dynamic get starting => 'Starting...';
  dynamic get startFlutterClaw => 'Start FlutterClaw';
  dynamic get newSession => 'New session';
  dynamic get photoLibrary => 'Photo library';
  dynamic get camera => 'Camera';
  dynamic get whatDoYouSeeInImage => 'What do you see in this image?';
  dynamic get imagePickerNotAvailable => 'The image picker is not available on this device.';
  dynamic get couldNotOpenImagePicker => 'Could not open the image picker.';
  dynamic get copiedToClipboard => 'Copied to clipboard';
  dynamic get attachImage => 'Attach image';
  dynamic get messageFlutterClaw => 'Message FlutterClaw';
  dynamic get channelsAndGateway => 'Channels and gateway';
  dynamic get stop => 'Stop';
  dynamic get start => 'Start';
  dynamic get builtInChatInterface => 'Built-in chat interface';
  dynamic get notConfigured => 'Not configured';
  dynamic get connected => 'Connected';
  dynamic get configuredStarting => 'Configured, starting...';
  dynamic get telegramConfiguration => 'Telegram configuration';
  dynamic get fromBotFather => 'From BotFather';
  dynamic get allowedUserIds => 'Allowed user IDs';
  dynamic get leaveEmptyToAllowAll => 'Leave empty to allow everyone.';
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
  dynamic get startConversationToCreate => 'Start a conversation to create one.';
  dynamic get startConversationToSee => 'Start a conversation to see it here.';
  dynamic get reset => 'Reset';
  dynamic get cronJobs => 'Cron jobs';
  dynamic get noCronJobs => 'No cron jobs';
  dynamic get addScheduledTasks => 'Add a scheduled task to run on its own.';
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
  dynamic get dailySummaryExample => 'Daily summary';
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
  dynamic get startGatewayWhenLaunches => 'Start the gateway when the app launches.';
  dynamic get heartbeat => 'Heartbeat';
  dynamic get enabled => 'Enabled';
  dynamic get periodicAgentTasks => 'Periodic agent tasks';
  dynamic get about => 'About';
  dynamic get personalAIAssistantForIOS => 'Personal AI assistant for iOS';
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
  dynamic get transcribingWithWhisper => 'Transcribing with Whisper...';
  dynamic get noTranscriptionCaptured => 'No transcription captured';
  dynamic get pause => 'Pause';
  dynamic get resume => 'Resume';
  dynamic get send => 'Send';
  dynamic get liveActivityActive => 'Live activity active';
  dynamic get restartGateway => 'Restart gateway';
  dynamic get iosBackgroundSupportActive => 'iOS background support is active';
  dynamic get webChatBuiltIn => 'Built in';
  dynamic get configure => 'Configure';
  dynamic get disconnect => 'Disconnect';
  dynamic get agents => 'Agents';
  dynamic get agentFiles => 'Agent files';
  dynamic get createAgent => 'Create agent';
  dynamic get editAgent => 'Edit agent';
  dynamic get noAgentsYet => 'No agents yet';
  dynamic get createYourFirstAgent => 'Create your first agent';
  dynamic get active => 'Active';
  dynamic get agentName => 'Agent name';
  dynamic get emoji => 'Emoji';
  dynamic get selectEmoji => 'Select emoji';
  dynamic get vibe => 'Vibe';
  dynamic get vibeHint => 'Describe how the agent should sound.';
  dynamic get modelConfiguration => 'Model configuration';
  dynamic get advancedSettings => 'Advanced settings';
  dynamic get agentCreated => 'Agent created';
  dynamic get agentUpdated => 'Agent updated';
  dynamic get agentDeleted => 'Agent deleted';
  dynamic get agentDetails => 'Agent details';
  dynamic get createdAt => 'Created';
  dynamic get lastUsed => 'Last used';
  dynamic get basicInformation => 'Basic information';
  dynamic get switchToAgent => 'Switch to agent';
  dynamic get providers => 'Providers';
  dynamic get addProvider => 'Add provider';
  dynamic get noProvidersConfigured => 'No providers configured';
  dynamic get editCredentials => 'Edit credentials';
  dynamic get defaultModelHint => 'Used by agents that do not pick a model.';
  dynamic get voiceCallModelSection => 'Voice call model';
  dynamic get voiceCallModelDescription => 'The model used for live voice conversations.';
  dynamic get voiceCallModelLabel => 'Voice model';
  dynamic get voiceCallModelAutomatic => 'Automatic';
  dynamic get preferLiveVoiceBootstrapTitle => 'Prefer live voice';
  dynamic get preferLiveVoiceBootstrapSubtitle => 'Open new conversations in voice mode.';
  dynamic get liveVoiceNameLabel => 'Voice';
  dynamic get firstHatchModeChoiceTitle => 'How do you want to start?';
  dynamic get firstHatchModeChoiceBody => 'You can switch between chat and voice at any time.';
  dynamic get firstHatchModeChoiceChatButton => 'Start with chat';
  dynamic get firstHatchModeChoiceVoiceButton => 'Start with voice';
  dynamic get liveVoiceBargeInHint => 'Just start talking to interrupt.';
  dynamic get liveVoiceFallbackTitle => 'Voice unavailable, switched to chat';
  dynamic get liveVoiceEndConversationTooltip => 'End conversation';
  dynamic get liveVoiceStatusConnecting => 'Connecting...';
  dynamic get liveVoiceStatusRunning => 'Live';
  dynamic get liveVoiceStatusSpeaking => 'Speaking';
  dynamic get liveVoiceStatusListening => 'Listening';
  dynamic get liveVoiceBadge => 'LIVE';
  dynamic get cannotAddLiveModelAsChat => 'A live voice model cannot be added as a chat model.';
  dynamic get authBearerTokenLabel => 'Bearer token';
  dynamic get authAccessKeysLabel => 'Access keys';
  dynamic get scanQrBarcodeTitle => 'Scan QR code';
  dynamic get oauthSignInTitle => 'Sign in';
  dynamic get browserOverlayDone => 'Done';
  dynamic get credentialsScreenTitle => 'Credentials';
  dynamic get credentialsIntroBody => 'Keys are stored in the device keychain and never leave it.';
  dynamic get credentialsNoProvidersBody => 'Add a provider to store a key for it.';
  dynamic get credentialsAddKeyTooltip => 'Add key';
  dynamic get credentialsNoExtraKeysMessage => 'No extra keys for this provider.';
  dynamic get credentialsKeyLabelHint => 'Work key';
  dynamic get credentialsApiKeyFieldLabel => 'API key';
  dynamic get securitySettingsTitle => 'Security';
  dynamic get securitySettingsIntro => 'Control what the agent is allowed to run on this device.';
  dynamic get securitySectionToolExecution => 'Tool execution';
  dynamic get securityPatternDetectionTitle => 'Pattern detection';
  dynamic get securityPatternDetectionSubtitle => 'Block shell commands that match known destructive patterns.';
  dynamic get securityUnsafeModeBanner => 'Unsafe mode is on for this session.';
  dynamic get securitySectionHowItWorks => 'How it works';
  dynamic get securityHowItWorksBlocked => 'Commands matching a destructive pattern are blocked before they run.';
  dynamic get securityHowItWorksUnsafeCmd => 'Run the unsafe command to let one through.';
  dynamic get securityHowItWorksToggleSession => 'The toggle applies to the current session only.';
  dynamic get holdToSetAsDefault => 'Hold to set as default';
  dynamic get integrations => 'Integrations';
  dynamic get shortcutsIntegrations => 'Shortcuts';
  dynamic get shortcutsIntegrationsDesc => 'Trigger the agent from the Shortcuts app.';
  dynamic get dangerZone => 'Danger zone';
  dynamic get resetOnboarding => 'Reset onboarding';
  dynamic get resetOnboardingDesc => 'Show the setup flow again on the next launch.';
  dynamic get resetAllConfiguration => 'Reset all configuration';
  dynamic get resetAllConfigurationDesc => 'Remove every provider, channel and session from this device.';
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
  dynamic get pairingDescription => 'Each device asks for approval the first time it writes.';
  dynamic get allowlistTitle => 'Allowlist';
  dynamic get allowlistDescription => 'Only the user IDs you list can reach the agent.';
  dynamic get openAccess => 'Open access';
  dynamic get openAccessDescription => 'Anyone who finds the bot can talk to it.';
  dynamic get disabledAccess => 'Disabled';
  dynamic get disabledAccessDescription => 'The channel stays configured but accepts nothing.';
  dynamic get approvedDevices => 'Approved devices';
  dynamic get noApprovedDevicesYet => 'No approved devices yet';
  dynamic get devicesAppearAfterApproval => 'Devices appear here once you approve them.';
  dynamic get noAllowedUsersConfigured => 'No allowed users configured';
  dynamic get addUserIdsHint => 'Add the user IDs that may talk to the agent.';
  dynamic get removeDevice => 'Remove device';
  dynamic get saving => 'Saving...';
  dynamic get channelsLabel => 'Channels';
  dynamic get clawHubAccount => 'ClawHub account';
  dynamic get loggedInToClawHub => 'Signed in to ClawHub';
  dynamic get loggedOutFromClawHub => 'Signed out of ClawHub';
  dynamic get login => 'Sign in';
  dynamic get logout => 'Sign out';
  dynamic get connect => 'Connect';
  dynamic get pasteClawHubToken => 'Paste your ClawHub token';
  dynamic get pleaseEnterApiToken => 'Enter an API token first.';
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
  dynamic get cannotDeleteLastAgent => 'The last agent cannot be deleted.';
  dynamic get close => 'Close';
  dynamic get nameIsRequired => 'Name is required';
  dynamic get pleaseSelectModel => 'Select a model';
  dynamic get maxTokens => 'Max tokens';
  dynamic get maxTokensRequired => 'Max tokens is required';
  dynamic get mustBePositiveNumber => 'Enter a positive number';
  dynamic get maxToolIterations => 'Max tool iterations';
  dynamic get maxIterationsRequired => 'Max iterations is required';
  dynamic get restrictToWorkspace => 'Restrict to workspace';
  dynamic get restrictToWorkspaceDesc => 'The agent can only read and write inside the workspace folder.';
  dynamic get noModelsConfiguredLong => 'No models are configured yet. Add one in Settings to start chatting.';
  dynamic get selectProviderFirst => 'Select a provider first';
  dynamic get skip => 'Skip';
  dynamic get continueButton => 'Continue';
  dynamic get uiAutomation => 'UI automation';
  dynamic get uiAutomationDesc => 'Let the agent tap and type in other apps.';
  dynamic get uiAutomationAccessibilityNote => 'This needs the accessibility service to stay enabled.';
  dynamic get openAccessibilitySettings => 'Open accessibility settings';
  dynamic get skipForNow => 'Skip for now';
  dynamic get checkingPermission => 'Checking permission...';
  dynamic get accessibilityEnabled => 'Accessibility enabled';
  dynamic get accessibilityNotEnabled => 'Accessibility not enabled';
  dynamic get exploreIntegrations => 'Explore integrations';
  dynamic get requestTimedOut => 'The request timed out.';
  dynamic get myShortcuts => 'My shortcuts';
  dynamic get addShortcut => 'Add shortcut';
  dynamic get noShortcutsYet => 'No shortcuts yet';
  dynamic get shortcutsInstructions => 'Create a shortcut in the Shortcuts app, then add it here.';
  dynamic get shortcutName => 'Shortcut name';
  dynamic get shortcutNameHint => 'Morning briefing';
  dynamic get descriptionOptional => 'Description (optional)';
  dynamic get whatDoesShortcutDo => 'What does this shortcut do?';
  dynamic get callbackSetup => 'Callback setup';
  dynamic get callbackInstructions => 'Add a callback URL at the end of the shortcut so the agent knows it finished.';
  dynamic get channelApp => 'App';
  dynamic get channelHeartbeat => 'Heartbeat';
  dynamic get channelCron => 'Cron';
  dynamic get channelSubagent => 'Subagent';
  dynamic get channelSystem => 'System';
  dynamic get messagesAbbrev => 'msgs';
  dynamic get modelAlreadyAdded => 'That model is already added.';
  dynamic get bothTokensRequired => 'Both tokens are required.';
  dynamic get slackSavedRestart => 'Slack settings saved. Restart the gateway to apply them.';
  dynamic get slackConfiguration => 'Slack configuration';
  dynamic get setupTitle => 'Setup';
  dynamic get slackSetupInstructions => 'Create a Slack app, enable Socket Mode, then paste both tokens below.';
  dynamic get botTokenXoxb => 'Bot token (xoxb-)';
  dynamic get appLevelToken => 'App-level token (xapp-)';
  dynamic get apiUrlPhoneRequired => 'API URL and phone number are required.';
  dynamic get signalSavedRestart => 'Signal settings saved. Restart the gateway to apply them.';
  dynamic get signalConfiguration => 'Signal configuration';
  dynamic get requirementsTitle => 'Requirements';
  dynamic get signalRequirements => 'Needs a signal-cli REST API reachable from this device.';
  dynamic get signalApiUrl => 'Signal API URL';
  dynamic get signalPhoneNumber => 'Phone number';
  dynamic get userIdLabel => 'User ID';
  dynamic get enterDiscordUserId => 'Enter a Discord user ID';
  dynamic get enterTelegramUserId => 'Enter a Telegram user ID';
  dynamic get fromDiscordDevPortal => 'From the Discord developer portal';
  dynamic get allowedUserIdsTitle => 'Allowed user IDs';
  dynamic get approvedDevice => 'Approved device';
  dynamic get allowedUser => 'Allowed user';
  dynamic get howToGetBotToken => 'How to get a bot token';
  dynamic get discordTokenInstructions => 'Open the developer portal, create an application, add a bot and copy its token.';
  dynamic get telegramTokenInstructions => 'Message BotFather, send the new bot command and copy the token it replies with.';
  dynamic get fromBotFatherHint => 'Looks like 123456789:ABCdef';
  dynamic get accessTokenLabel => 'Access token';
  dynamic get notSetOpenAccess => 'Not set (open access)';
  dynamic get gatewayAccessToken => 'Gateway access token';
  dynamic get tokenFieldLabel => 'Token';
  dynamic get leaveEmptyDisableAuth => 'Leave empty to disable authentication.';
  dynamic get toolPolicies => 'Tool policies';
  dynamic get toolPoliciesDesc => 'Choose which tools the agent may use.';
  dynamic get privacySensors => 'Privacy and sensors';
  dynamic get networkCategory => 'Network';
  dynamic get systemCategory => 'System';
  dynamic get toolTakePhotos => 'Take photos';
  dynamic get toolTakePhotosDesc => 'Capture a photo with the camera.';
  dynamic get toolRecordVideo => 'Record video';
  dynamic get toolRecordVideoDesc => 'Record a short video clip.';
  dynamic get toolLocation => 'Location';
  dynamic get toolLocationDesc => 'Read the current device location.';
  dynamic get toolHealthData => 'Health data';
  dynamic get toolHealthDataDesc => 'Read steps, sleep and workouts.';
  dynamic get toolContacts => 'Contacts';
  dynamic get toolContactsDesc => 'Look up contacts by name.';
  dynamic get toolScreenshots => 'Screenshots';
  dynamic get toolScreenshotsDesc => 'Capture what is on screen.';
  dynamic get toolWebFetch => 'Web fetch';
  dynamic get toolWebFetchDesc => 'Open a URL and read the page.';
  dynamic get toolWebSearch => 'Web search';
  dynamic get toolWebSearchDesc => 'Search the web for a query.';
  dynamic get toolHttpRequests => 'HTTP requests';
  dynamic get toolHttpRequestsDesc => 'Call an arbitrary HTTP endpoint.';
  dynamic get toolSandboxShell => 'Sandbox shell';
  dynamic get toolSandboxShellDesc => 'Run commands in the sandboxed shell.';
  dynamic get toolImageGeneration => 'Image generation';
  dynamic get toolImageGenerationDesc => 'Generate an image from a prompt.';
  dynamic get toolLaunchApps => 'Launch apps';
  dynamic get toolLaunchAppsDesc => 'Open another app on this device.';
  dynamic get toolLaunchIntents => 'Launch intents';
  dynamic get toolLaunchIntentsDesc => 'Send an Android intent to another app.';
  dynamic get renameSession => 'Rename session';
  dynamic get myConversationName => 'My conversation';
  dynamic get renameAction => 'Rename';
  dynamic get couldNotTranscribeAudio => 'Could not transcribe the audio.';
  dynamic get stopRecording => 'Stop recording';
  dynamic get voiceInput => 'Voice input';
  dynamic get speakMessage => 'Speak message';
  dynamic get stopSpeaking => 'Stop speaking';
  dynamic get selectText => 'Select text';
  dynamic get messageCopied => 'Message copied';
  dynamic get copyTooltip => 'Copy';
  dynamic get commandsTooltip => 'Commands';
  dynamic get providersAndModels => 'Providers and models';
  dynamic get autoStartEnabledLabel => 'Auto-start on';
  dynamic get autoStartOffLabel => 'Auto-start off';
  dynamic get allToolsEnabled => 'All tools enabled';
  dynamic get officialWebsite => 'Official website';
  dynamic get noPendingPairingRequests => 'No pending pairing requests';
  dynamic get pairingRequestsTitle => 'Pairing requests';
  dynamic get gatewayStartingStatus => 'Starting...';
  dynamic get gatewayRetryingStatus => 'Retrying...';
  dynamic get errorStartingGateway => 'Could not start the gateway.';
  dynamic get runningStatus => 'Running';
  dynamic get stoppedStatus => 'Stopped';
  dynamic get notSetUpStatus => 'Not set up';
  dynamic get configuredStatus => 'Configured';
  dynamic get whatsAppConfigSaved => 'WhatsApp configuration saved';
  dynamic get whatsAppDisconnected => 'WhatsApp disconnected';
  dynamic get whatsAppTitle => 'WhatsApp';
  dynamic get applyingSettings => 'Applying settings...';
  dynamic get reconnectWhatsApp => 'Reconnect WhatsApp';
  dynamic get saveSettingsLabel => 'Save settings';
  dynamic get applySettingsRestart => 'Apply and restart';
  dynamic get whatsAppMode => 'WhatsApp mode';
  dynamic get myPersonalNumber => 'My personal number';
  dynamic get myPersonalNumberDesc => 'Link your own number and reply from it.';
  dynamic get dedicatedBotAccount => 'Dedicated bot account';
  dynamic get dedicatedBotAccountDesc => 'Use a separate number that only the agent answers.';
  dynamic get allowedNumbers => 'Allowed numbers';
  dynamic get addNumberTitle => 'Add number';
  dynamic get phoneNumberJid => 'Phone number or JID';
  dynamic get noAllowedNumbersConfigured => 'No allowed numbers configured';
  dynamic get devicesAppearAfterPairing => 'Devices appear here once pairing completes.';
  dynamic get addPhoneNumbersHint => 'Add the numbers that may talk to the agent.';
  dynamic get allowedNumber => 'Allowed number';
  dynamic get howToConnect => 'How to connect';
  dynamic get whatsAppConnectInstructions => 'Open WhatsApp, go to Linked devices and scan the code below.';
  dynamic get whatsAppPairingDesc => 'Each number asks for approval the first time it writes.';
  dynamic get whatsAppAllowlistDesc => 'Only the numbers you list can reach the agent.';
  dynamic get whatsAppOpenDesc => 'Anyone who messages the number can talk to the agent.';
  dynamic get whatsAppDisabledDesc => 'WhatsApp stays linked but accepts nothing.';
  dynamic get sessionExpiredRelink => 'The session expired. Link the device again.';
  dynamic get connectWhatsAppBelow => 'Connect WhatsApp below.';
  dynamic get whatsAppAcceptedQr => 'WhatsApp accepted the code.';
  dynamic get waitingForWhatsApp => 'Waiting for WhatsApp...';
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
  dynamic get clawHubApiTokenInstructions => 'Open your ClawHub account settings and create a personal token.';
  dynamic get cronJobHintText => 'Send me a summary of the unread messages from today.';
  dynamic get androidPermissions => 'Android permissions';
  dynamic get androidPermissionsDesc => 'FlutterClaw needs two permissions to control other apps.';
  dynamic get twoPermissionsNeeded => 'Two permissions needed';
  dynamic get accessibilityService => 'Accessibility service';
  dynamic get accessibilityServiceDesc => 'Lets the agent read the screen and tap for you.';
  dynamic get displayOverOtherApps => 'Display over other apps';
  dynamic get displayOverOtherAppsDesc => 'Shows the agent overlay on top of other apps.';
  dynamic get changeDefaultModel => 'Change default model';
  dynamic get startNewSessions => 'Start new sessions';
  dynamic get currentConversationsArchived => 'Current conversations are archived.';
  dynamic get applyAction => 'Apply';
  dynamic get setAsDefaultModel => 'Set as default model';
  dynamic get usedByAgentsWithout => 'Used by agents without their own model.';
  dynamic get providerAlreadyAuth => 'That provider is already authenticated.';
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
  dynamic get addDeviceHint => 'Enter the device ID shown on the other device.';
  dynamic get skipAction => 'Skip';
  dynamic get mcpServers => 'MCP servers';
  dynamic get noMcpServersConfigured => 'No MCP servers configured';
  dynamic get mcpServersEmptyHint => 'Add a server to give the agent more tools.';
  dynamic get addMcpServer => 'Add MCP server';
  dynamic get editMcpServer => 'Edit MCP server';
  dynamic get removeMcpServer => 'Remove MCP server';
  dynamic get mcpTransport => 'Transport';
  dynamic get testConnection => 'Test connection';
  dynamic get mcpServerNameLabel => 'Server name';
  dynamic get mcpServerNameHint => 'Home automation';
  dynamic get mcpServerUrlLabel => 'Server URL';
  dynamic get mcpBearerTokenLabel => 'Bearer token';
  dynamic get mcpBearerTokenHint => 'Optional';
  dynamic get mcpCommandLabel => 'Command';
  dynamic get mcpArgumentsLabel => 'Arguments';
  dynamic get mcpEnvVarsLabel => 'Environment variables';
  dynamic get mcpStdioNotOnIos => 'Stdio servers are not supported on iOS.';
  dynamic get connectedStatus => 'Connected';
  dynamic get mcpConnecting => 'Connecting...';
  dynamic get mcpConnectionError => 'Connection error';
  dynamic get mcpDisconnected => 'Disconnected';
  dynamic get mcpTestOkNoTools => 'Connected, but the server exposes no tools.';
  dynamic get mcpTestFailed => 'Connection test failed.';
  dynamic get mcpAddServer => 'Add server';
  dynamic get mcpSaveChanges => 'Save changes';
  dynamic get urlIsRequired => 'URL is required';
  dynamic get enterValidUrl => 'Enter a valid URL';
  dynamic get commandIsRequired => 'Command is required';
  dynamic get editFileContentHint => 'Edit the file content';
  dynamic get whatsAppPairSubtitle => 'Pair this device with your WhatsApp account.';
  dynamic get whatsAppPairingOptional => 'Pairing is optional, you can do it later.';
  dynamic get whatsAppEnableToLink => 'Enable WhatsApp to link a device.';
  dynamic get whatsAppLinkedOnboarding => 'WhatsApp linked';
  dynamic get cancelLink => 'Cancel link';
  // HAND-AUTHORED 2026-09-15. Was `=> null`, and every call site writes
  // `AppLocalizations.of(context)!` -- so the bang threw `Null check operator used on a null
  // value` inside `build` and the device drew Flutter's error box. The generator had already
  // reconstructed every string this class hands back; returning an instance is what lets the
  // transplant reach them.
  static dynamic of(dynamic context) => AppLocalizations(null);
  dynamic connectToProvider(dynamic provider) => 'Connect to provider';
  dynamic telegramBotToken(dynamic platform) => 'Telegram bot token';
  dynamic viaProvider(dynamic provider) => 'via OpenRouter';
  dynamic status(dynamic status) => 'Status: running';
  dynamic minutesLeft(dynamic minutes) => '5 minutes left';
  dynamic sessionsCount(dynamic count) => '3 sessions';
  dynamic removeSkillConfirm(dynamic name) => 'Remove this skill?';
  dynamic installedSkill(dynamic name) => 'Skill installed';
  dynamic failedToInstallSkill(dynamic name) => 'Could not install the skill.';
  dynamic messagesCount(dynamic count) => '24 messages';
  dynamic tokensCount(dynamic count) => '1280 tokens';
  dynamic intervalMinutes(dynamic minutes) => 'Every 15 minutes';
  dynamic removeModelConfirm(dynamic name) => 'Remove this model?';
  dynamic getApiKeyAt(dynamic provider) => 'Get an API key from the provider dashboard.';
  dynamic minutesAgo(dynamic minutes) => '5 minutes ago';
  dynamic hoursAgo(dynamic hours) => '2 hours ago';
  dynamic daysAgo(dynamic days) => '3 days ago';
  dynamic liveTranscriptionUnavailable(dynamic error) => 'Live transcription is unavailable.';
  dynamic failedToStartRecording(dynamic error) => 'Could not start recording.';
  dynamic whisperApiFailed(dynamic error) => 'The Whisper API request failed.';
  dynamic failedToStopRecording(dynamic error) => 'Could not stop recording.';
  dynamic failedToPauseResume(dynamic action, dynamic error) => 'Could not pause or resume recording.';
  dynamic modelLabel(dynamic model) => 'Model: gpt-4o-mini';
  dynamic uptimeLabel(dynamic uptime) => 'Uptime: 4h 12m';
  dynamic switchedToAgent(dynamic name) => 'Switched agent';
  dynamic deleteAgentConfirm(dynamic name) => 'Delete this agent?';
  dynamic authModelsFoundCount(dynamic count) => '12 models found';
  dynamic authModelsFoundMoreManual(dynamic count) => '50 models found, add the rest manually.';
  dynamic appInitializationError(dynamic error) => 'The app could not start.';
  dynamic credentialsAddProviderKeyTitle(dynamic provider) => 'Add provider key';
  dynamic removeProviderConfirm(dynamic provider) => 'Remove this provider?';
  dynamic modelSetAsDefault(dynamic name) => 'Model set as default';
  dynamic couldNotOpenDocument(dynamic error) => 'Could not open the document.';
  dynamic gatewayFailed(dynamic error) => 'The gateway failed to start.';
  dynamic exceptionError(dynamic error) => 'Something went wrong.';
  dynamic removeAccessFor(dynamic name) => 'Remove access?';
  dynamic incompatibleSkillDesc(dynamic reason) => 'This skill needs a newer app version.';
  dynamic compatibilityWarningDesc(dynamic reason) => 'This skill may not work on this platform.';
  dynamic resetSessionConfirm(dynamic key) => 'Reset this session?';
  dynamic errorGeneric(dynamic error) => 'Something went wrong.';
  dynamic fileSaved(dynamic fileName) => 'File saved';
  dynamic errorSavingFile(dynamic error) => 'Could not save the file.';
  dynamic temperatureLabel(dynamic value) => 'Temperature 0.7';
  dynamic secondsAgo(dynamic seconds) => '30 seconds ago';
  dynamic modelsConfiguredCount(dynamic count) => '4 models configured';
  dynamic toolsDisabledCount(dynamic count) => '2 tools disabled';
  dynamic appVersionSubtitle(
    dynamic appName,
    dynamic version,
    dynamic buildNumber,
  ) => 'FlutterClaw 1.4.2 (312)';
  dynamic connectionFailed(dynamic error) => 'Connection failed.';
  dynamic cronJobRuns(dynamic count) => '18 runs';
  dynamic nextRunLabel(dynamic time) => 'Next run at 09:00';
  dynamic lastErrorLabel(dynamic error) => 'Last error: request timed out';
  dynamic setModelAsDefault(dynamic name) => 'Set this model as default?';
  dynamic alsoUpdateAgents(dynamic count) => 'Also update 3 agents';
  dynamic applyModelQuestion(dynamic name) => 'Apply this model?';
  dynamic applyToAgents(dynamic count) => 'Apply to 3 agents';
  dynamic idPrefix(dynamic id) => 'ID a7f3c1';
  dynamic removeMcpServerConfirm(dynamic name) => 'Remove this MCP server?';
  dynamic mcpToolsCount(dynamic count) => '7 tools';
  dynamic mcpTestOkTools(dynamic count) => 'Connected, 7 tools available.';
  dynamic skillRemoved(dynamic name) => 'Skill removed';
  dynamic get searchModels => 'Search models';
  dynamic get noModelsFound => 'No models found';
  dynamic get useCustomIdHint => 'Use a custom model ID instead.';
  dynamic get useModelId => 'Use model ID';
  dynamic get modelsAvailable => 'Models available';
  dynamic get modelUnavailableTitle => 'Model unavailable';
  dynamic get changeModel => 'Change model';
  dynamic get credentialLabel => 'Credential';
  dynamic get credentialLabelHint => 'Personal key';
  dynamic get selectCredential => 'Select credential';
  dynamic get saveAnyway => 'Save anyway';
  dynamic get channelDisconnected => 'Channel disconnected';
  dynamic get newConversationTitle => 'New conversation';
  dynamic get newConversationMessage => 'The current conversation will be archived.';
  dynamic get startNewConversation => 'Start new conversation';
  dynamic get retryingRequest => 'Retrying request...';
  dynamic get contextCompacted => 'Context compacted';
  dynamic get compactionFailed => 'Compaction failed';
  dynamic get allowedUsersTitle => 'Allowed users';
  dynamic get allowlistEmptyWarning => 'The allowlist is empty, so nobody can reach the agent.';
  dynamic get allowFromAddHint => 'Add a user ID to allow them.';
  dynamic get llmErrorPayloadTooLarge => 'The request is too large for this model.';
  dynamic get llmErrorPayloadTooLargeTitle => 'Request too large';
  dynamic get llmErrorViewDocs => 'View docs';
  dynamic get llmErrorOpenRouterPrivacy => 'OpenRouter needs a privacy setting change for this model.';
  dynamic get llmErrorOpenRouterPrivacyTitle => 'Privacy settings';
  dynamic get llmErrorOpenPrivacySettings => 'Open privacy settings';
  dynamic get llmError401 => 'The API key was rejected.';
  dynamic get llmError402 => 'The account has no credit left.';
  dynamic get llmError403 => 'Access to this model is denied.';
  dynamic get llmError404 => 'The model was not found.';
  dynamic get llmError413 => 'The request payload is too large.';
  dynamic get llmError429 => 'Rate limit reached, try again shortly.';
  dynamic get llmError500 => 'The provider had an internal error.';
  dynamic get llmError503 => 'The provider is unavailable right now.';
  dynamic get llmError529 => 'The provider is overloaded.';
  dynamic get llmErrorNetwork => 'No connection to the provider.';
  dynamic get llmErrorTimeout => 'The provider took too long to respond.';
  dynamic get llmErrorUnknown => 'Unknown provider error.';
  dynamic get discoverModels => 'Discover models';
  dynamic get refreshModels => 'Refresh models';
  dynamic get modelNotInProviderList => 'This model is not in the provider list.';
  dynamic modelUnavailableMessage(dynamic model) => 'This model is no longer available from the provider.';
  dynamic tokenValidationFailed(dynamic error) => 'Token validation failed.';
  dynamic channelConnectFailed(dynamic error) => 'The channel could not connect.';
  dynamic channelErrorLabel(dynamic error) => 'Channel error';
  dynamic llmError400(dynamic raw) => 'The provider rejected the request.';
  dynamic llmErrorWithStatus(dynamic statusCode, dynamic raw) => 'The provider returned an error.';
  dynamic get savedNotConnectedStatus => 'Saved, not connected';
  dynamic get savedNotConnectedHint => 'Start the gateway to connect this channel.';
  dynamic get gatewayRunsLocally => 'The gateway runs locally on this device.';
  dynamic get gatewaySettingsLink => 'Gateway settings';
  dynamic get mcpServersTitle => 'MCP servers';
  dynamic get mcpServersSubtitleEmpty => 'None configured';
  dynamic get securityChecksActive => 'Security checks active';
  dynamic get securityChecksDisabled => 'Security checks disabled';
  dynamic get keyRotationAdvanced => 'Key rotation (advanced)';
  dynamic get toolPoliciesOtherToolsNote => 'Tools not listed here are always available.';
  dynamic get toolPoliciesMcpLink => 'Manage MCP servers';
  dynamic get providerKeyInvalidTapToFix => 'This provider key is invalid, tap to fix it.';
  dynamic get sessionChatLabel => 'Chat';
  dynamic get switchAgentOrSession => 'Switch agent or session';
  dynamic get agentsSection => 'Agents';
  dynamic get errorNoBalance => 'No credit left on this account.';
  dynamic get errorAccessDenied => 'Access denied.';
  dynamic get errorModelNotFound => 'Model not found.';
  dynamic get errorRateLimitReached => 'Rate limit reached.';
  dynamic get errorServiceUnavailable => 'Service unavailable.';
  dynamic get errorConnection => 'Connection error.';
  dynamic get whatsappNotConnected => 'WhatsApp is not connected.';
  dynamic get channelHealthIssue => 'This channel needs attention.';
  dynamic get testConnectionFirst => 'Test the connection first.';
  dynamic mcpServersSubtitleActive(dynamic enabled, dynamic total) => '3 of 5 active';
  dynamic sessionDetailKey(dynamic key) => 'Session main';
  dynamic credentialsCoolingDown(dynamic reason) => 'Cooling down after repeated errors.';
  dynamic credentialsErrorCount(dynamic count) => '3 errors';
  dynamic get downloadingSkill => 'Downloading skill...';
  dynamic get checkingCompatibility => 'Checking compatibility...';
}

extension L10nContext on BuildContext {
  // HAND-AUTHORED 2026-09-15. Was `const _Stub()`, so `context.l10n.scanQrBarcodeTitle`
  // reached `Text(...)` as a `_Stub` and threw `type '_Stub' is not a subtype of type
  // 'String'` inside `build` -- the device drew Flutter's error box. Every string this
  // extension reaches is already reconstructed on `AppLocalizations` above; the extension
  // was the one link still standing in.
  dynamic get l10n => AppLocalizations(null);
}
