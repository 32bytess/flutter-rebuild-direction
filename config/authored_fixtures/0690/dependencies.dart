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

late List<Voice> fixtureVoices = const <Voice>[
  Voice(
    id: 'kitten_bella',
    name: 'Bella',
    engine: EngineId.kitten,
    family: 'kitten-nano',
    language: 'en-US',
    gender: 'f',
  ),
  Voice(
    id: 'kitten_bruno',
    name: 'Bruno',
    engine: EngineId.kitten,
    family: 'kitten-nano',
    language: 'en-US',
    gender: 'm',
  ),
  Voice(
    id: 'kitten_luna',
    name: 'Luna',
    engine: EngineId.kitten,
    family: 'kitten-nano',
    language: 'en-GB',
    gender: 'f',
  ),
];

EngineId fixtureEngine = EngineId.system;

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

Voice? fixturePlayingVoice = null;

// DECLARATION-ONLY STAND-INS -- repo-local declarations that build no UI, and
// third-party ones the transplant does not inline. Supertypes are mirrored so a
// widget still reads as a widget; everything else is `dynamic`, because none of it
// is measured.

class AppSettings {
  AppSettings({
    dynamic temperature,
    dynamic topP,
    dynamic maxTokens,
    dynamic contextLength,
    dynamic themeMode,
    dynamic fontSize,
    dynamic showSystemMessages,
    dynamic hapticFeedbackEnabled,
    dynamic sendOnEnter,
    dynamic defaultServerId,
    dynamic showDataIndicator,
    dynamic autoGenerateTitle,
    dynamic streamingEnabled,
    dynamic defaultPersonaId,
    dynamic hasCompletedOnboarding,
    dynamic hasAskedForNotifications,
    dynamic mcpEnabled,
    dynamic newChatMcpEnabled,
    dynamic codeThemeDark,
    dynamic codeThemeLight,
    dynamic preferredBackend,
    dynamic ttsEngine,
    dynamic ttsVoiceId,
    dynamic ttsSpeed,
    dynamic kittenTtsModelVariant,
    dynamic autoSpeakEnabled,
    dynamic smartReplyEnabled,
    dynamic localeCode,
  });
  AppSettings.fromMap(dynamic map);
  AppSettings.fromJson(dynamic source);
  dynamic get temperature => 0.7;
  dynamic get topP => 0.9;
  dynamic get maxTokens => 2048;
  dynamic get contextLength => 4096;
  dynamic get themeMode => const _Stub();
  dynamic get fontSize => 15.0;
  dynamic get showSystemMessages => false;
  dynamic get hapticFeedbackEnabled => false;
  dynamic get sendOnEnter => false;
  dynamic get defaultServerId => null;
  dynamic get showDataIndicator => false;
  dynamic get autoGenerateTitle => false;
  dynamic get streamingEnabled => false;
  dynamic get defaultPersonaId => null;
  dynamic get hasCompletedOnboarding => false;
  dynamic get hasAskedForNotifications => false;
  dynamic get mcpEnabled => false;
  dynamic get newChatMcpEnabled => false;
  dynamic get codeThemeDark => const _Stub();
  dynamic get codeThemeLight => const _Stub();
  dynamic get preferredBackend => const _Stub();
  dynamic get ttsEngine => EngineId.system;
  dynamic get ttsVoiceId => null;
  dynamic get ttsSpeed => 1.0;
  dynamic get kittenTtsModelVariant => const _Stub();
  dynamic get kokoroTtsModelVariant => const _Stub();
  dynamic get autoSpeakEnabled => false;
  dynamic copyWith({
    dynamic temperature,
    dynamic topP,
    dynamic maxTokens,
    dynamic contextLength,
    dynamic themeMode,
    dynamic fontSize,
    dynamic showSystemMessages,
    dynamic hapticFeedbackEnabled,
    dynamic sendOnEnter,
    dynamic defaultServerId,
    dynamic showDataIndicator,
    dynamic autoGenerateTitle,
    dynamic streamingEnabled,
    dynamic defaultPersonaId,
    dynamic hasCompletedOnboarding,
    dynamic hasAskedForNotifications,
    dynamic mcpEnabled,
    dynamic newChatMcpEnabled,
    dynamic codeThemeDark,
    dynamic codeThemeLight,
    dynamic preferredBackend,
    dynamic ttsEngine,
    dynamic ttsVoiceId,
    dynamic ttsSpeed,
    dynamic kittenTtsModelVariant,
    dynamic autoSpeakEnabled,
    dynamic smartReplyEnabled,
    dynamic localeCode,
  }) => AppSettings();
  dynamic toMap() => <String, dynamic>{};
  dynamic toJson() => '';
  dynamic get localeCode => null;
  dynamic get smartReplyEnabled => false;
}

class ConsumerState<WidgetT> {
  ConsumerState();
  dynamic get ref => WidgetRef();
}

class EngineMeta {
  const EngineMeta({
    dynamic name,
    dynamic tagline,
    dynamic sizeMb,
    dynamic ramMb,
    dynamic voiceCount,
    dynamic accentColor,
  });
  dynamic get name => 'Kitten TTS';
  dynamic get tagline => 'Small, fast, on device';
  dynamic get sizeMb => 24;
  dynamic get ramMb => 96;
  dynamic get voiceCount => 8;
  dynamic get accentColor => 0xFF7C4DFF;
  static const dynamic system = EngineMeta(
    name: 'System',
    tagline: 'Built-in device voices',
    sizeMb: 0,
    ramMb: 16,
    voiceCount: 4,
    accentColor: 0xFF5C6BC0,
  );
  static const dynamic kitten = EngineMeta(
    name: 'Kitten TTS',
    tagline: 'Small, fast, on device',
    sizeMb: 24,
    ramMb: 96,
    voiceCount: 8,
    accentColor: 0xFF7C4DFF,
  );
  static const dynamic kokoro = EngineMeta(
    name: 'Kokoro',
    tagline: 'High quality neural voices',
    sizeMb: 82,
    ramMb: 310,
    voiceCount: 10,
    accentColor: 0xFF26A69A,
  );
  static const dynamic piper = EngineMeta(
    name: 'Piper',
    tagline: 'Compact neural voices',
    sizeMb: 63,
    ramMb: 220,
    voiceCount: 6,
    accentColor: 0xFFEF6C00,
  );
  static dynamic forEngine(dynamic engine) => EngineMeta();
}

class Voice {
  const Voice({
    this.id = 'kitten_bella',
    this.name = 'Bella',
    this.engine = EngineId.system,
    this.family = 'kitten-nano',
    this.language = 'en-US',
    this.gender = 'f',
  });
  final dynamic id;
  final dynamic name;
  final dynamic engine;
  final dynamic language;
  final dynamic gender;
  final dynamic family;
}

class WidgetRef {
  WidgetRef();
  dynamic get context => const _Stub();
  dynamic watch<StateT>(dynamic provider) => const _Stub();
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
  dynamic read<StateT>(dynamic provider) => const _Stub();
  dynamic refresh<StateT>(dynamic provider) => const _Stub();
  void invalidate(dynamic provider, {dynamic asReload}) {}
}

dynamic settingsProvider = const _Stub();

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
  static final AppLocalizations _instance = AppLocalizations(null);
  dynamic get localeName => 'en';
  static const dynamic delegate = null;
  static const dynamic localizationsDelegates = null;
  static const dynamic supportedLocales = null;
  dynamic get app_name => 'LocalMind';
  dynamic get app_tagline => 'Your private AI, on device';
  dynamic get app_version => '1.4.2';
  dynamic get cancel => 'Cancel';
  dynamic get confirm => 'Confirm';
  dynamic get delete => 'Delete';
  dynamic get save => 'Save';
  dynamic get retry => 'Retry';
  dynamic get close => 'Close';
  dynamic get done => 'Done';
  dynamic get continue_action => 'Continue';
  dynamic get skip => 'Skip';
  dynamic get install => 'Install';
  dynamic get download => 'Download';
  dynamic get resume => 'Resume';
  dynamic get pause => 'Pause';
  dynamic get stop => 'Stop';
  dynamic get edit => 'Edit';
  dynamic get preview => 'Preview';
  dynamic get unload => 'Unload';
  dynamic get load => 'Load';
  dynamic get rename => 'Rename';
  dynamic get pin => 'Pin';
  dynamic get unpin => 'Unpin';
  dynamic get share => 'Share';
  dynamic get copy => 'Copy';
  dynamic get copied => 'Copied';
  dynamic get copied_to_clipboard => 'Copied to clipboard';
  dynamic get select => 'Select';
  dynamic get active => 'Active';
  dynamic get all => 'All';
  dynamic get none => 'None';
  dynamic get none_selected => 'None selected';
  dynamic get online => 'Online';
  dynamic get offline => 'Offline';
  dynamic get error => 'Error';
  dynamic get unknown_error => 'An unknown error occurred';
  dynamic get not_now => 'Not now';
  dynamic get enable => 'Enable';
  dynamic get proceed_anyway => 'Proceed anyway';
  dynamic get test_connection => 'Test connection';
  dynamic get testing => 'Testing...';
  dynamic get connection_successful => 'Connection successful';
  dynamic get connection_failed => 'Connection failed';
  dynamic get save_continue => 'Save and continue';
  dynamic get save_changes => 'Save changes';
  dynamic get finish_setup => 'Finish setup';
  dynamic get start_new_chat => 'Start new chat';
  dynamic get cannot_undo => 'This action cannot be undone.';
  dynamic get ram_warning => 'Low memory warning';
  dynamic get recommended => 'Recommended';
  dynamic get may_be_large => 'This download may be large';
  dynamic get calculating => 'Calculating...';
  dynamic get download_failed => 'Download failed';
  dynamic get downloaded => 'Downloaded';
  dynamic get not_downloaded => 'Not downloaded';
  dynamic get installed => 'Installed';
  dynamic get not_installed => 'Not installed';
  dynamic get loading => 'Loading...';
  dynamic get thinking => 'Thinking...';
  dynamic get processing => 'Processing...';
  dynamic get initializing => 'Initializing...';
  dynamic get ready => 'Ready';
  dynamic get preparing_app => 'Preparing app...';
  dynamic get initializing_services => 'Initializing services...';
  dynamic get configuring_server => 'Configuring server...';
  dynamic get startup_failed => 'Startup failed';
  dynamic get something_went_wrong => 'Something went wrong';
  dynamic get delete_model_title => 'Delete model?';
  dynamic get delete_voice_title => 'Delete voice?';
  dynamic get delete_server_title => 'Delete server?';
  dynamic get delete_conversation_title => 'Delete conversation?';
  dynamic get delete_message_title => 'Delete message?';
  dynamic get delete_persona_body =>
      'This persona and its settings will be removed.';
  dynamic get clear_conversation_title => 'Clear conversation?';
  dynamic get clear_conversation_body =>
      'All messages in this chat will be removed.';
  dynamic get clear => 'Clear';
  dynamic get no_model_loaded => 'No model loaded';
  dynamic get delete_conversation => 'Delete conversation';
  dynamic get nav_history => 'History';
  dynamic get nav_servers => 'Servers';
  dynamic get nav_local_models => 'Local models';
  dynamic get nav_tts => 'Text to speech';
  dynamic get nav_personas => 'Personas';
  dynamic get nav_settings => 'Settings';
  dynamic get nav_new_chat => 'New chat';
  dynamic get search_hint => 'Search';
  dynamic get no_server_selected => 'No server selected';
  dynamic get switch_server => 'Switch server';
  dynamic get switch_server_subtitle => 'Choose which backend answers';
  dynamic get manage_servers => 'Manage servers';
  dynamic get open_source => 'Open source';
  dynamic get open_source_desc => 'LocalMind is free and open source.';
  dynamic get star_on_github => 'Star on GitHub';
  dynamic get settings_title => 'Settings';
  dynamic get settings_appearance => 'Appearance';
  dynamic get settings_language => 'Language';
  dynamic get language_system_default => 'System default';
  dynamic get settings_tts => 'Text to speech';
  dynamic get settings_behavior => 'Behavior';
  dynamic get settings_on_device => 'On device';
  dynamic get settings_default_server => 'Default server';
  dynamic get settings_default_persona => 'Default persona';
  dynamic get settings_privacy => 'Privacy';
  dynamic get settings_data_management => 'Data management';
  dynamic get settings_about => 'About';
  dynamic get theme => 'Theme';
  dynamic get theme_system => 'System';
  dynamic get theme_light => 'Light';
  dynamic get theme_dark => 'Dark';
  dynamic get theme_claude => 'Claude';
  dynamic get font_size => 'Font size';
  dynamic get font_size_desc => 'Text size used across the app';
  dynamic get font_preview => 'The quick brown fox jumps over the lazy dog';
  dynamic get code_theme_dark => 'Code theme (dark)';
  dynamic get code_theme_light => 'Code theme (light)';
  dynamic get code_theme_desc => 'Syntax highlighting for code blocks';
  dynamic get tts_engine => 'Speech engine';
  dynamic get tts_engine_system => 'System';
  dynamic get tts_engine_kitten => 'Kitten TTS';
  dynamic get voice => 'Voice';
  dynamic get voice_female => 'Female';
  dynamic get voice_male => 'Male';
  dynamic get voice_other => 'Other';
  dynamic get tts_speed => 'Speech rate';
  dynamic get tts_speed_desc => 'How fast replies are read aloud';
  dynamic get manage_tts_models => 'Manage speech models';
  dynamic get manage_on_device_models => 'Manage on-device models';
  dynamic get streaming_responses => 'Stream responses';
  dynamic get auto_generate_titles => 'Auto-generate titles';
  dynamic get send_on_enter => 'Send on Enter';
  dynamic get show_system_messages => 'Show system messages';
  dynamic get haptic_feedback => 'Haptic feedback';
  dynamic get enable_mcp => 'Enable MCP';
  dynamic get new_chat_mcp_default => 'Enable MCP in new chats';
  dynamic get show_data_indicator => 'Show data indicator';
  dynamic get privacy_info => 'Conversations stay on this device.';
  dynamic get delete_all_conversations => 'Delete all conversations';
  dynamic get reset_settings_defaults => 'Reset settings to defaults';
  dynamic get chat_title => 'Chat';
  dynamic get chat_parameters_tooltip => 'Chat parameters';
  dynamic get change_persona => 'Change persona';
  dynamic get set_persona => 'Set persona';
  dynamic get remove_persona => 'Remove persona';
  dynamic get clear_conversation => 'Clear conversation';
  dynamic get connection_error => 'Connection error';
  dynamic get disconnected => 'Disconnected';
  dynamic get configure => 'Configure';
  dynamic get select_model => 'Select model';
  dynamic get select_persona => 'Select persona';
  dynamic get start_conversation => 'Start a conversation';
  dynamic get recent_chats => 'Recent chats';
  dynamic get see_all => 'See all';
  dynamic get quick_write => 'Write';
  dynamic get quick_explain => 'Explain';
  dynamic get quick_debug => 'Debug';
  dynamic get quick_async => 'Async';
  dynamic get history_missing_title => 'Conversation not found';
  dynamic get history_missing_desc => 'This chat is no longer on this device.';
  dynamic get technical_details => 'Technical details';
  dynamic get last_error => 'Last error';
  dynamic get copy_info => 'Copy info';
  dynamic get conversation_id => 'Conversation ID';
  dynamic get created_at => 'Created';
  dynamic get expected_messages => 'Expected messages';
  dynamic get debug_dialog_desc =>
      'Share this with a maintainer to help diagnose the issue.';
  dynamic get chat_input_hint => 'Message LocalMind...';
  dynamic get send_message_tooltip => 'Send message';
  dynamic get stop_generation_tooltip => 'Stop generating';
  dynamic get attach_images_tooltip => 'Attach images';
  dynamic get tool_unknown => 'Unknown tool';
  dynamic get message_options => 'Message options';
  dynamic get copy_markdown => 'Copy as Markdown';
  dynamic get copied_markdown => 'Markdown copied';
  dynamic get read_aloud => 'Read aloud';
  dynamic get stop_reading => 'Stop reading';
  dynamic get more => 'More';
  dynamic get edit_message => 'Edit message';
  dynamic get edit_message_desc =>
      'Editing removes every reply after this message.';
  dynamic get save_regenerate => 'Save and regenerate';
  dynamic get chat_settings_title => 'Chat settings';
  dynamic get reset_defaults => 'Reset to defaults';
  dynamic get parameters_tab => 'Parameters';
  dynamic get mcp_tab => 'MCP';
  dynamic get temperature => 'Temperature';
  dynamic get temperature_desc => 'Higher values make replies more creative.';
  dynamic get top_p => 'Top P';
  dynamic get top_p_desc => 'Limits sampling to the most likely tokens.';
  dynamic get max_tokens => 'Max tokens';
  dynamic get max_tokens_desc => 'Longest reply the model may produce.';
  dynamic get context_length => 'Context length';
  dynamic get context_length_desc => 'How much history the model can see.';
  dynamic get mcp_disabled_warning => 'MCP is disabled in settings.';
  dynamic get mcp_enable_chat => 'Enable MCP for this chat';
  dynamic get auto_execute_tools => 'Auto-execute tools';
  dynamic get add_ephemeral_mcp => 'Add temporary MCP server';
  dynamic get mcp_label_placeholder => 'Label';
  dynamic get mcp_url_placeholder => 'https://example.com/mcp';
  dynamic get active_integrations => 'Active integrations';
  dynamic get enable_notifications => 'Enable notifications';
  dynamic get enable_notifications_desc =>
      'Get told when downloads and replies finish.';
  dynamic get chat_history_title => 'History';
  dynamic get conversation_just_now => 'Just now';
  dynamic get conversation_yesterday => 'Yesterday';
  dynamic get options_tooltip => 'Options';
  dynamic get no_results_found => 'No results found';
  dynamic get no_conversations_yet => 'No conversations yet';
  dynamic get try_different_search => 'Try a different search';
  dynamic get start_new_conversation => 'Start a new conversation';
  dynamic get rename_conversation => 'Rename conversation';
  dynamic get enter_new_title => 'Enter a new title';
  dynamic get pinned_section => 'Pinned';
  dynamic get today_section => 'Today';
  dynamic get yesterday_section => 'Yesterday';
  dynamic get previous_7_days => 'Previous 7 days';
  dynamic get previous_30_days => 'Previous 30 days';
  dynamic get older_section => 'Older';
  dynamic get onboarding_localmind => 'LocalMind';
  dynamic get onboarding_connect_server => 'Connect a server';
  dynamic get onboarding_connect_desc =>
      'Pick where your replies are generated.';
  dynamic get server_type_on_device => 'On device';
  dynamic get server_type_on_device_sub => 'Runs entirely offline';
  dynamic get server_type_lm_studio => 'LM Studio';
  dynamic get server_type_lm_studio_sub => 'Local desktop server';
  dynamic get server_type_ollama => 'Ollama';
  dynamic get server_type_ollama_sub => 'Local or networked server';
  dynamic get server_type_openrouter => 'OpenRouter';
  dynamic get server_type_openrouter_sub => 'Hosted models via API key';
  dynamic get ready_continue => 'Ready to continue';
  dynamic get waiting_selection => 'Select an option to continue';
  dynamic get setup_connection => 'Set up connection';
  dynamic get server_name => 'Server name';
  dynamic get name_required => 'Name is required';
  dynamic get name_max_50 => 'Name must be 50 characters or fewer';
  dynamic get host_label => 'Host';
  dynamic get host_required => 'Host is required';
  dynamic get port_label => 'Port';
  dynamic get port_required => 'Port is required';
  dynamic get port_invalid => 'Port must be a number';
  dynamic get port_range => 'Port must be between 1 and 65535';
  dynamic get api_key_required => 'API key is required';
  dynamic get api_key_optional => 'API key (optional)';
  dynamic get api_key_required_openrouter => 'OpenRouter requires an API key';
  dynamic get api_key_format => 'Key format looks wrong';
  dynamic get my_server_hint => 'My server';
  dynamic get name_length_validation => 'Use between 1 and 50 characters';
  dynamic get host_valid => 'Host looks valid';
  dynamic get api_key_hint_openrouter => 'sk-or-v1-...';
  dynamic get api_key_hint_generic => 'Paste your API key';
  dynamic get update_server => 'Update server';
  dynamic get save_server => 'Save server';
  dynamic get server_updated => 'Server updated';
  dynamic get server_added => 'Server added';
  dynamic get download_model_title => 'Download model';
  dynamic get download_model_desc => 'Models run on device once downloaded.';
  dynamic get on_device_android_only =>
      'On-device models are Android only for now.';
  dynamic get total_ram => 'Total RAM';
  dynamic get available => 'Available';
  dynamic get choose_theme => 'Choose a theme';
  dynamic get choose_theme_desc => 'You can change this later in settings.';
  dynamic get theme_card_system => 'System';
  dynamic get theme_card_system_sub => 'Follow device setting';
  dynamic get theme_card_light => 'Light';
  dynamic get theme_card_light_sub => 'Bright and clean';
  dynamic get theme_card_dark => 'Dark';
  dynamic get theme_card_dark_sub => 'Easy on the eyes';
  dynamic get theme_card_claude => 'Claude';
  dynamic get theme_card_claude_sub => 'Warm and paper-like';
  dynamic get stay_updated => 'Stay updated';
  dynamic get stay_updated_desc =>
      'Notifications keep you posted while the app is closed.';
  dynamic get notification_benefit_downloads => 'Download progress';
  dynamic get notification_benefit_completions => 'Finished replies';
  dynamic get notification_benefit_background => 'Background activity';
  dynamic get allow_notifications => 'Allow notifications';
  dynamic get servers_title => 'Servers';
  dynamic get no_servers_yet => 'No servers yet';
  dynamic get no_servers_desc => 'Add a server to start chatting.';
  dynamic get add_server => 'Add server';
  dynamic get edit_server => 'Edit server';
  dynamic get add_server_title => 'Add a server';
  dynamic get server_type_label => 'Server type';
  dynamic get server_icon_label => 'Server icon';
  dynamic get default_icon => 'Default icon';
  dynamic get server_type_lm_studio_display => 'LM Studio';
  dynamic get server_type_openai_display => 'OpenAI compatible';
  dynamic get server_type_ollama_display => 'Ollama';
  dynamic get server_type_openrouter_display => 'OpenRouter';
  dynamic get server_type_on_device_display => 'On device';
  dynamic get server_address_openrouter => 'openrouter.ai';
  dynamic get server_address_on_device => 'localhost';
  dynamic get default_badge => 'Default';
  dynamic get set_as_default => 'Set as default';
  dynamic get select_icon => 'Select icon';
  dynamic get select_icon_desc => 'Pick an icon to identify this server.';
  dynamic get search_icons_hint => 'Search icons';
  dynamic get server_icon_stack => 'Stack';
  dynamic get server_icon_stack2 => 'Stack 2';
  dynamic get server_icon_stack3 => 'Stack 3';
  dynamic get server_icon_cloud => 'Cloud';
  dynamic get server_icon_cloud_server => 'Cloud server';
  dynamic get server_icon_mcp => 'MCP';
  dynamic get server_icon_database => 'Database';
  dynamic get server_icon_database1 => 'Database 1';
  dynamic get server_icon_database2 => 'Database 2';
  dynamic get server_icon_cpu => 'CPU';
  dynamic get server_icon_chip => 'Chip';
  dynamic get server_icon_chip2 => 'Chip 2';
  dynamic get server_icon_computer => 'Computer';
  dynamic get server_icon_laptop => 'Laptop';
  dynamic get server_icon_terminal => 'Terminal';
  dynamic get server_icon_code => 'Code';
  dynamic get server_icon_ai_brain => 'AI brain';
  dynamic get server_icon_ai_brain2 => 'AI brain 2';
  dynamic get server_icon_ai_cloud => 'AI cloud';
  dynamic get server_icon_ai_network => 'AI network';
  dynamic get server_icon_ai_chat => 'AI chat';
  dynamic get server_icon_cellular => 'Cellular';
  dynamic get server_icon_plug1 => 'Plug';
  dynamic get server_icon_plug2 => 'Plug 2';
  dynamic get server_icon_bot => 'Bot';
  dynamic get server_icon_bot2 => 'Bot 2';
  dynamic get server_icon_robotic => 'Robot';
  dynamic get server_icon_rocket => 'Rocket';
  dynamic get server_icon_star => 'Star';
  dynamic get server_icon_settings1 => 'Settings';
  dynamic get server_icon_settings2 => 'Settings 2';
  dynamic get server_icon_home1 => 'Home';
  dynamic get server_icon_home2 => 'Home 2';
  dynamic get server_icon_folder1 => 'Folder';
  dynamic get server_icon_folder2 => 'Folder 2';
  dynamic get server_icon_file1 => 'File';
  dynamic get server_icon_lock => 'Lock';
  dynamic get server_icon_key => 'Key';
  dynamic get server_icon_link => 'Link';
  dynamic get server_icon_globe => 'Globe';
  dynamic get server_icon_api => 'API';
  dynamic get server_icon_arrow_right => 'Arrow';
  dynamic get server_icon_check => 'Check';
  dynamic get server_icon_alert => 'Alert';
  dynamic get server_icon_info => 'Info';
  dynamic get server_icon_zap => 'Zap';
  dynamic get server_icon_cloud_upload => 'Cloud upload';
  dynamic get server_icon_cloud_download => 'Cloud download';
  dynamic get server_icon_refresh => 'Refresh';
  dynamic get server_icon_hard_drive => 'Hard drive';
  dynamic get server_icon_drive => 'Drive';
  dynamic get personas_title => 'Personas';
  dynamic get persona_category_general => 'General';
  dynamic get persona_category_coding => 'Coding';
  dynamic get persona_category_education => 'Education';
  dynamic get persona_category_creative => 'Creative';
  dynamic get persona_builtin_section => 'Built in';
  dynamic get persona_my_section => 'My personas';
  dynamic get clone_edit => 'Clone and edit';
  dynamic get builtin_badge => 'Built in';
  dynamic get no_personas_found => 'No personas found';
  dynamic get no_personas_desc => 'Create one to tailor how replies sound.';
  dynamic get edit_persona => 'Edit persona';
  dynamic get create_persona => 'Create persona';
  dynamic get create_persona_button => 'Create persona';
  dynamic get emoji_label => 'Emoji';
  dynamic get name_label => 'Name';
  dynamic get my_persona_hint => 'My persona';
  dynamic get category_label => 'Category';
  dynamic get description_optional => 'Description (optional)';
  dynamic get description_hint => 'What is this persona for?';
  dynamic get system_prompt => 'System prompt';
  dynamic get no_prompt_placeholder => 'No prompt set';
  dynamic get prompt_hint => 'You are a helpful assistant...';
  dynamic get prompt_required => 'A system prompt is required';
  dynamic get prompt_max_chars => 'Prompt is too long';
  dynamic get advanced_settings => 'Advanced settings';
  dynamic get temperature_label => 'Temperature';
  dynamic get top_p_label => 'Top P';
  dynamic get temp_hint => '0.7';
  dynamic get top_p_hint => '0.9';
  dynamic get range_0_2 => '0.0 - 2.0';
  dynamic get range_0_1 => '0.0 - 1.0';
  dynamic get persona_updated => 'Persona updated';
  dynamic get persona_created => 'Persona created';
  dynamic get tts_models_title => 'Speech models';
  dynamic get always_available => 'Always available';
  dynamic get tts_system_desc => 'Uses the voices installed on your device.';
  dynamic get downloading_status => 'Downloading...';
  dynamic get on_device_models_title => 'On-device models';
  dynamic get available_models => 'Available models';
  dynamic get device_memory => 'Device memory';
  dynamic get ram_usage => 'RAM usage';
  dynamic get memory_healthy => 'Memory healthy';
  dynamic get memory_critical => 'Memory critical';
  dynamic get memory_low => 'Memory low';
  dynamic get available_ram => 'Available RAM';
  dynamic get total_capacity => 'Total capacity';
  dynamic get loaded_status => 'Loaded';
  dynamic get inference_backend => 'Inference backend';
  dynamic get backend_ios_notice => 'Backend selection is unavailable on iOS.';
  dynamic get backend_cpu_desc => 'Runs anywhere, slowest';
  dynamic get backend_gpu_desc => 'Faster, uses more battery';
  dynamic get backend_npu_desc => 'Fastest on supported devices';
  dynamic get select_model_title => 'Select a model';
  dynamic get refresh_models => 'Refresh models';
  dynamic get search_models_hint => 'Search models';
  dynamic get no_server_connected => 'No server connected';
  dynamic get add_server_first => 'Add a server first';
  dynamic get failed_load_models => 'Could not load models';
  dynamic get no_models_available => 'No models available';
  dynamic get unload_from_server => 'Unload from server';
  dynamic get download_complete_notification => 'Download complete';
  dynamic get engine_name_system => 'System';
  dynamic get engine_tagline_system => 'Built-in device voices';
  dynamic get engine_name_kitten => 'Kitten TTS';
  dynamic get engine_tagline_kitten => 'Small, fast, on device';
  dynamic get engine_name_sherpa => 'Sherpa';
  dynamic get engine_tagline_sherpa => 'High quality neural voices';
  dynamic get voice_jasper => 'Jasper';
  dynamic get voice_bella => 'Bella';
  dynamic get voice_bruno => 'Bruno';
  dynamic get voice_luna => 'Luna';
  dynamic get voice_hugo => 'Hugo';
  dynamic get voice_rosie => 'Rosie';
  dynamic get voice_leo => 'Leo';
  dynamic get voice_kiki => 'Kiki';
  dynamic get voice_lessac => 'Lessac';
  dynamic get voice_ryan => 'Ryan';
  dynamic get model_qwen_3 => 'Qwen 3';
  dynamic get model_qwen_3_desc => 'Balanced general-purpose model';
  dynamic get model_license_apache => 'Apache 2.0';
  dynamic get model_qwen_25 => 'Qwen 2.5';
  dynamic get model_qwen_25_desc => 'Smaller, quicker replies';
  dynamic get model_deepseek => 'DeepSeek';
  dynamic get model_deepseek_desc => 'Strong at reasoning and code';
  dynamic get model_license_mit => 'MIT';
  dynamic get model_gemma => 'Gemma';
  dynamic get model_gemma_desc => 'Compact model from Google';
  dynamic get export_role_user => 'user';
  dynamic get export_role_assistant => 'assistant';
  dynamic get export_role_system => 'system';
  dynamic get export_role_tool => 'tool';
  dynamic get export_text_user => 'User';
  dynamic get export_text_assistant => 'Assistant';
  dynamic get export_text_system => 'System';
  dynamic get export_text_tool => 'Tool';
  dynamic get export_label_user => 'You';
  dynamic get export_label_assistant => 'LocalMind';
  dynamic get export_label_system => 'System';
  dynamic get export_label_tool => 'Tool';
  dynamic get select_model_hint => 'Choose a model to chat with';
  dynamic get test_notification_title => 'Test notification';
  dynamic get test_notification_body => 'Notifications are working.';
  static dynamic of(dynamic context) => _instance;
  dynamic delete_model_body(dynamic name) => '';
  dynamic delete_model_body_with_size(dynamic name, dynamic size) => '';
  dynamic delete_voice_body(dynamic name, dynamic size) => '';
  dynamic delete_server_body(dynamic name) => '';
  dynamic delete_conversation_body(dynamic title) => '';
  dynamic delete_persona_title(dynamic name) => '';
  dynamic label_completed(dynamic label) => '';
  dynamic error_with_message(dynamic error) => '';
  dynamic preview_failed(dynamic error) => '';
  dynamic loading_model(dynamic modelId) => '';
  dynamic model_loaded(dynamic modelId, dynamic backend) => '';
  dynamic loading_model_error(dynamic error) => '';
  dynamic tool_label(dynamic toolCallId) => '';
  dynamic character_count(dynamic length) => '';
  dynamic conversation_minutes_ago(dynamic minutes) => '';
  dynamic conversation_hours_ago(dynamic hours) => '';
  dynamic conversation_days_ago(dynamic days) => '';
  dynamic conversation_date(dynamic month, dynamic day, dynamic year) => '';
  dynamic setup_connection_desc(dynamic server) => '';
  dynamic ram_min_required(dynamic fileSize) => '';
  dynamic download_progress(dynamic percent, dynamic speed) => '';
  dynamic eta_label(dynamic eta) => '';
  dynamic paused_progress(dynamic percent) => '';
  dynamic ram_warning_body_download(dynamic ram, dynamic totalMemory) => '';
  dynamic ram_warning_body_load(dynamic availableRAM, dynamic ram) => '';
  dynamic switched_to_server(dynamic name) => '';
  dynamic server_address_format(dynamic host, dynamic port) => '';
  dynamic character_count_max(dynamic currentLen) => '';
  dynamic tts_kitten_desc(dynamic size) => '';
  dynamic tts_piper_desc(dynamic size) => '';
  dynamic engine_spec(dynamic sizeMb, dynamic ramMb, dynamic voiceCount) => '';
  dynamic ram_used(dynamic percent) => '';
  dynamic no_models_match(dynamic searchQuery) => '';
  dynamic model_load_failed(dynamic error) => '';
  dynamic model_unloaded_ollama(dynamic name) => '';
  dynamic model_unloaded_success(dynamic name) => '';
  dynamic model_unload_failed(dynamic error) => '';
  dynamic context_chip(dynamic ctx) => '';
  dynamic download_notification_title(dynamic modelName) => '';
  dynamic download_complete_body(dynamic modelName) => '';
  dynamic download_failed_notification(dynamic error) => '';
  dynamic download_failed_body(dynamic modelName) => '';
  dynamic export_header(dynamic date) => '';
  dynamic get enable_smart_reply => 'Enable smart reply';
  dynamic get onboarding_choose_language => 'Choose your language';
  dynamic get onboarding_choose_language_desc =>
      'You can change this later in settings.';
  dynamic get onboarding_welcome => 'Welcome to LocalMind';
  dynamic get beta_label => 'Beta';
  dynamic get experimental_label => 'Experimental';
  dynamic get add_more => 'Add more';
  dynamic get on_github => 'On GitHub';
  dynamic get could_not_open_github => 'Could not open GitHub';
  dynamic get openai_compatible_api => 'OpenAI-compatible API';
  dynamic get https_requires_ssl => 'HTTPS requires a valid SSL certificate';
  dynamic get most_local_setups_use_http => 'Most local setups use HTTP';
}
