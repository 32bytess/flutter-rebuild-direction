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

class ConsumerWidget extends StatelessWidget {
  const ConsumerWidget({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
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
  dynamic get app_name => 'LocalMind';
  dynamic get app_tagline => 'Your models, your device';
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
  dynamic get none_selected => 'None Selected';
  dynamic get online => 'Online';
  dynamic get offline => 'Offline';
  dynamic get error => 'Something went wrong';
  dynamic get unknown_error => 'An unknown error occurred';
  dynamic get not_now => 'Not now';
  dynamic get enable => 'Enable';
  dynamic get proceed_anyway => 'Proceed Anyway';
  dynamic get test_connection => 'Test Connection';
  dynamic get testing => 'Testing';
  dynamic get connection_successful => 'Connection Successful';
  dynamic get connection_failed => 'Connection Failed';
  dynamic get save_continue => 'Save Continue';
  dynamic get save_changes => 'Save Changes';
  dynamic get finish_setup => 'Finish Setup';
  dynamic get start_new_chat => 'Start New Chat';
  dynamic get cannot_undo => 'Cannot Undo';
  dynamic get ram_warning => 'RAM warning';
  dynamic get recommended => 'Recommended';
  dynamic get may_be_large => 'May Be Large';
  dynamic get calculating => 'Calculating';
  dynamic get download_failed => 'Download Failed';
  dynamic get downloaded => 'Downloaded';
  dynamic get not_downloaded => 'Not Downloaded';
  dynamic get installed => 'Installed';
  dynamic get not_installed => 'Not Installed';
  dynamic get loading => 'Loading';
  dynamic get thinking => 'Thinking';
  dynamic get processing => 'Processing';
  dynamic get initializing => 'Initializing';
  dynamic get ready => 'Ready';
  dynamic get preparing_app => 'Preparing App';
  dynamic get initializing_services => 'Initializing Services';
  dynamic get configuring_server => 'Configuring Server';
  dynamic get startup_failed => 'Startup Failed';
  dynamic get something_went_wrong => 'Something Went Wrong';
  dynamic get delete_model_title => 'Delete Model';
  dynamic get delete_voice_title => 'Delete Voice';
  dynamic get delete_server_title => 'Delete Server';
  dynamic get delete_conversation_title => 'Delete Conversation';
  dynamic get delete_message_title => 'Delete Message';
  dynamic get delete_persona_body => 'Delete persona body';
  dynamic get clear_conversation_title => 'Clear Conversation';
  dynamic get clear_conversation_body => 'Clear conversation body';
  dynamic get clear => 'Clear';
  dynamic get no_model_loaded => 'No Model Loaded';
  dynamic get delete_conversation => 'Delete Conversation';
  dynamic get nav_history => 'History';
  dynamic get nav_servers => 'Servers';
  dynamic get nav_local_models => 'Local Models';
  dynamic get nav_tts => 'TTS';
  dynamic get nav_personas => 'Personas';
  dynamic get nav_settings => 'Settings';
  dynamic get nav_new_chat => 'New Chat';
  dynamic get search_hint => 'Search conversations';
  dynamic get no_server_selected => 'No Server Selected';
  dynamic get switch_server => 'Switch Server';
  dynamic get switch_server_subtitle => 'Switch server subtitle';
  dynamic get manage_servers => 'Manage Servers';
  dynamic get open_source => 'Open Source';
  dynamic get open_source_desc => 'Open source desc';
  dynamic get star_on_github => 'Star on Github';
  dynamic get settings_title => 'Settings';
  dynamic get settings_appearance => 'Settings Appearance';
  dynamic get settings_language => 'Settings Language';
  dynamic get language_system_default => 'System Default';
  dynamic get settings_tts => 'Settings TTS';
  dynamic get settings_behavior => 'Settings Behavior';
  dynamic get settings_on_device => 'Settings on Device';
  dynamic get settings_default_server => 'Settings Default Server';
  dynamic get settings_default_persona => 'Settings Default Persona';
  dynamic get settings_privacy => 'Settings Privacy';
  dynamic get settings_data_management => 'Settings Data Management';
  dynamic get settings_about => 'Settings About';
  dynamic get theme => 'Theme';
  dynamic get theme_system => 'Theme System';
  dynamic get theme_light => 'Theme Light';
  dynamic get theme_dark => 'Theme Dark';
  dynamic get theme_claude => 'Theme Claude';
  dynamic get font_size => 'Font Size';
  dynamic get font_size_desc => 'Font size desc';
  dynamic get font_preview => 'Font Preview';
  dynamic get code_theme_dark => 'Dark';
  dynamic get code_theme_light => 'Light';
  dynamic get code_theme_desc => 'Desc';
  dynamic get tts_engine => 'TTS Engine';
  dynamic get tts_engine_system => 'System';
  dynamic get tts_engine_kitten => 'Kitten';
  dynamic get voice => 'Voice';
  dynamic get voice_female => 'Voice Female';
  dynamic get voice_male => 'Voice Male';
  dynamic get voice_other => 'Voice Other';
  dynamic get tts_speed => 'TTS Speed';
  dynamic get tts_speed_desc => 'TTS speed desc';
  dynamic get manage_tts_models => 'Manage TTS Models';
  dynamic get manage_on_device_models => 'Manage on Device Models';
  dynamic get streaming_responses => 'Streaming Responses';
  dynamic get auto_generate_titles => 'Auto Generate Titles';
  dynamic get send_on_enter => 'Send on Enter';
  dynamic get show_system_messages => 'Show System Messages';
  dynamic get haptic_feedback => 'Haptic Feedback';
  dynamic get enable_mcp => 'Enable MCP';
  dynamic get new_chat_mcp_default => 'New Chat MCP Default';
  dynamic get show_data_indicator => 'Show Data Indicator';
  dynamic get privacy_info => 'Privacy Info';
  dynamic get delete_all_conversations => 'Delete All Conversations';
  dynamic get reset_settings_defaults => 'Reset Settings Defaults';
  dynamic get chat_title => 'Chat';
  dynamic get chat_parameters_tooltip => 'Chat Parameters';
  dynamic get change_persona => 'Change Persona';
  dynamic get set_persona => 'Set Persona';
  dynamic get remove_persona => 'Remove Persona';
  dynamic get clear_conversation => 'Clear Conversation';
  dynamic get connection_error => 'Connection Error';
  dynamic get disconnected => 'Disconnected';
  dynamic get configure => 'Configure';
  dynamic get select_model => 'Select Model';
  dynamic get select_persona => 'Select Persona';
  dynamic get start_conversation => 'Start Conversation';
  dynamic get recent_chats => 'Recent chats';
  dynamic get see_all => 'See all';
  dynamic get quick_write => 'Quick Write';
  dynamic get quick_explain => 'Quick Explain';
  dynamic get quick_debug => 'Quick Debug';
  dynamic get quick_async => 'Quick Async';
  dynamic get history_missing_title => 'History Missing';
  dynamic get history_missing_desc => 'History missing desc';
  dynamic get technical_details => 'Technical Details';
  dynamic get last_error => 'Last Error';
  dynamic get copy_info => 'Copy Info';
  dynamic get conversation_id => 'Conversation ID';
  dynamic get created_at => 'Created At';
  dynamic get expected_messages => 'Expected Messages';
  dynamic get debug_dialog_desc => 'Debug dialog desc';
  dynamic get chat_input_hint => 'Chat input hint';
  dynamic get send_message_tooltip => 'Send Message';
  dynamic get stop_generation_tooltip => 'Stop Generation';
  dynamic get attach_images_tooltip => 'Attach Images';
  dynamic get tool_unknown => 'Tool Unknown';
  dynamic get message_options => 'Message Options';
  dynamic get copy_markdown => 'Copy Markdown';
  dynamic get copied_markdown => 'Copied Markdown';
  dynamic get read_aloud => 'Read Aloud';
  dynamic get stop_reading => 'Stop Reading';
  dynamic get more => 'More';
  dynamic get edit_message => 'Edit Message';
  dynamic get edit_message_desc => 'Edit message desc';
  dynamic get save_regenerate => 'Save Regenerate';
  dynamic get chat_settings_title => 'Chat Settings';
  dynamic get reset_defaults => 'Reset Defaults';
  dynamic get parameters_tab => 'Parameters Tab';
  dynamic get mcp_tab => 'MCP Tab';
  dynamic get temperature => 'Temperature';
  dynamic get temperature_desc => 'Temperature desc';
  dynamic get top_p => 'Top P';
  dynamic get top_p_desc => 'Top p desc';
  dynamic get max_tokens => 'Max Tokens';
  dynamic get max_tokens_desc => 'Max tokens desc';
  dynamic get context_length => 'Context Length';
  dynamic get context_length_desc => 'Context length desc';
  dynamic get mcp_disabled_warning => 'MCP disabled warning';
  dynamic get mcp_enable_chat => 'MCP Enable Chat';
  dynamic get auto_execute_tools => 'Auto Execute Tools';
  dynamic get add_ephemeral_mcp => 'Add Ephemeral MCP';
  dynamic get mcp_label_placeholder => 'MCP label placeholder';
  dynamic get mcp_url_placeholder => 'MCP URL placeholder';
  dynamic get active_integrations => 'Active Integrations';
  dynamic get enable_notifications => 'Enable Notifications';
  dynamic get enable_notifications_desc => 'Enable notifications desc';
  dynamic get chat_history_title => 'History';
  dynamic get conversation_just_now => 'Just now';
  dynamic get conversation_yesterday => 'Yesterday';
  dynamic get options_tooltip => 'More options';
  dynamic get no_results_found => 'No results found';
  dynamic get no_conversations_yet => 'No conversations yet';
  dynamic get try_different_search => 'Try Different Search';
  dynamic get start_new_conversation => 'Start New Conversation';
  dynamic get rename_conversation => 'Rename Conversation';
  dynamic get enter_new_title => 'Enter New';
  dynamic get pinned_section => 'PINNED';
  dynamic get today_section => 'TODAY';
  dynamic get yesterday_section => 'YESTERDAY';
  dynamic get previous_7_days => 'PREVIOUS 7 DAYS';
  dynamic get previous_30_days => 'PREVIOUS 30 DAYS';
  dynamic get older_section => 'OLDER';
  dynamic get onboarding_localmind => 'Onboarding Localmind';
  dynamic get onboarding_connect_server => 'Onboarding Connect Server';
  dynamic get onboarding_connect_desc => 'Onboarding connect desc';
  dynamic get server_type_on_device => 'On Device';
  dynamic get server_type_on_device_sub => 'On Device';
  dynamic get server_type_lm_studio => 'Lm Studio';
  dynamic get server_type_lm_studio_sub => 'Lm Studio';
  dynamic get server_type_ollama => 'Ollama';
  dynamic get server_type_ollama_sub => 'Ollama';
  dynamic get server_type_openrouter => 'Openrouter';
  dynamic get server_type_openrouter_sub => 'Openrouter';
  dynamic get ready_continue => 'Ready Continue';
  dynamic get waiting_selection => 'Waiting Selection';
  dynamic get setup_connection => 'Setup Connection';
  dynamic get server_name => 'Server Name';
  dynamic get name_required => 'Name Required';
  dynamic get name_max_50 => 'Name Max 50';
  dynamic get host_label => 'Host';
  dynamic get host_required => 'Host Required';
  dynamic get port_label => 'Port';
  dynamic get port_required => 'Port Required';
  dynamic get port_invalid => 'Port Invalid';
  dynamic get port_range => 'Port Range';
  dynamic get api_key_required => 'API Key Required';
  dynamic get api_key_optional => 'API Key Optional';
  dynamic get api_key_required_openrouter => 'API Key Required Openrouter';
  dynamic get api_key_format => 'API Key Format';
  dynamic get my_server_hint => 'My server hint';
  dynamic get name_length_validation => 'Name length validation';
  dynamic get host_valid => 'Host Valid';
  dynamic get api_key_hint_openrouter => 'API Key Hint Openrouter';
  dynamic get api_key_hint_generic => 'API Key Hint Generic';
  dynamic get update_server => 'Update Server';
  dynamic get save_server => 'Save Server';
  dynamic get server_updated => 'Server Updated';
  dynamic get server_added => 'Server Added';
  dynamic get download_model_title => 'Download Model';
  dynamic get download_model_desc => 'Download model desc';
  dynamic get on_device_android_only => 'On Device Android Only';
  dynamic get total_ram => 'Total RAM';
  dynamic get available => 'Available';
  dynamic get choose_theme => 'Choose Theme';
  dynamic get choose_theme_desc => 'Choose theme desc';
  dynamic get theme_card_system => 'System';
  dynamic get theme_card_system_sub => 'System';
  dynamic get theme_card_light => 'Light';
  dynamic get theme_card_light_sub => 'Light';
  dynamic get theme_card_dark => 'Dark';
  dynamic get theme_card_dark_sub => 'Dark';
  dynamic get theme_card_claude => 'Claude';
  dynamic get theme_card_claude_sub => 'Claude';
  dynamic get stay_updated => 'Stay Updated';
  dynamic get stay_updated_desc => 'Stay updated desc';
  dynamic get notification_benefit_downloads => 'Notification Benefit Downloads';
  dynamic get notification_benefit_completions => 'Notification Benefit Completions';
  dynamic get notification_benefit_background => 'Notification Benefit Background';
  dynamic get allow_notifications => 'Allow Notifications';
  dynamic get servers_title => 'Servers';
  dynamic get no_servers_yet => 'No Servers Yet';
  dynamic get no_servers_desc => 'No servers desc';
  dynamic get add_server => 'Add Server';
  dynamic get edit_server => 'Edit Server';
  dynamic get add_server_title => 'Add Server';
  dynamic get server_type_label => 'Label';
  dynamic get server_icon_label => 'Label';
  dynamic get default_icon => 'Default Icon';
  dynamic get server_type_lm_studio_display => 'Lm Studio';
  dynamic get server_type_openai_display => 'Openai';
  dynamic get server_type_ollama_display => 'Ollama';
  dynamic get server_type_openrouter_display => 'Openrouter';
  dynamic get server_type_on_device_display => 'On Device';
  dynamic get server_address_openrouter => 'Server Address Openrouter';
  dynamic get server_address_on_device => 'Server Address on Device';
  dynamic get default_badge => 'Default';
  dynamic get set_as_default => 'Set As Default';
  dynamic get select_icon => 'Select Icon';
  dynamic get select_icon_desc => 'Select icon desc';
  dynamic get search_icons_hint => 'Search icons hint';
  dynamic get server_icon_stack => 'Stack';
  dynamic get server_icon_stack2 => 'Stack2';
  dynamic get server_icon_stack3 => 'Stack3';
  dynamic get server_icon_cloud => 'Cloud';
  dynamic get server_icon_cloud_server => 'Cloud Server';
  dynamic get server_icon_mcp => 'MCP';
  dynamic get server_icon_database => 'Database';
  dynamic get server_icon_database1 => 'Database1';
  dynamic get server_icon_database2 => 'Database2';
  dynamic get server_icon_cpu => 'CPU';
  dynamic get server_icon_chip => 'Chip';
  dynamic get server_icon_chip2 => 'Chip2';
  dynamic get server_icon_computer => 'Computer';
  dynamic get server_icon_laptop => 'Laptop';
  dynamic get server_icon_terminal => 'Terminal';
  dynamic get server_icon_code => 'Code';
  dynamic get server_icon_ai_brain => 'AI Brain';
  dynamic get server_icon_ai_brain2 => 'AI Brain2';
  dynamic get server_icon_ai_cloud => 'AI Cloud';
  dynamic get server_icon_ai_network => 'AI Network';
  dynamic get server_icon_ai_chat => 'AI Chat';
  dynamic get server_icon_cellular => 'Cellular';
  dynamic get server_icon_plug1 => 'Plug1';
  dynamic get server_icon_plug2 => 'Plug2';
  dynamic get server_icon_bot => 'Bot';
  dynamic get server_icon_bot2 => 'Bot2';
  dynamic get server_icon_robotic => 'Robotic';
  dynamic get server_icon_rocket => 'Rocket';
  dynamic get server_icon_star => 'Star';
  dynamic get server_icon_settings1 => 'Settings1';
  dynamic get server_icon_settings2 => 'Settings2';
  dynamic get server_icon_home1 => 'Home1';
  dynamic get server_icon_home2 => 'Home2';
  dynamic get server_icon_folder1 => 'Folder1';
  dynamic get server_icon_folder2 => 'Folder2';
  dynamic get server_icon_file1 => 'File1';
  dynamic get server_icon_lock => 'Lock';
  dynamic get server_icon_key => 'Key';
  dynamic get server_icon_link => 'Link';
  dynamic get server_icon_globe => 'Globe';
  dynamic get server_icon_api => 'API';
  dynamic get server_icon_arrow_right => 'Arrow Right';
  dynamic get server_icon_check => 'Check';
  dynamic get server_icon_alert => 'Alert';
  dynamic get server_icon_info => 'Info';
  dynamic get server_icon_zap => 'Zap';
  dynamic get server_icon_cloud_upload => 'Cloud Upload';
  dynamic get server_icon_cloud_download => 'Cloud Download';
  dynamic get server_icon_refresh => 'Refresh';
  dynamic get server_icon_hard_drive => 'Hard Drive';
  dynamic get server_icon_drive => 'Drive';
  dynamic get personas_title => 'Personas';
  dynamic get persona_category_general => 'General';
  dynamic get persona_category_coding => 'Coding';
  dynamic get persona_category_education => 'Education';
  dynamic get persona_category_creative => 'Creative';
  dynamic get persona_builtin_section => 'Persona Builtin';
  dynamic get persona_my_section => 'Persona My';
  dynamic get clone_edit => 'Clone Edit';
  dynamic get builtin_badge => 'Builtin';
  dynamic get no_personas_found => 'No Personas Found';
  dynamic get no_personas_desc => 'No personas desc';
  dynamic get edit_persona => 'Edit Persona';
  dynamic get create_persona => 'Create Persona';
  dynamic get create_persona_button => 'Create Persona';
  dynamic get emoji_label => 'Emoji';
  dynamic get name_label => 'Name';
  dynamic get my_persona_hint => 'My persona hint';
  dynamic get category_label => 'Category';
  dynamic get description_optional => 'Description Optional';
  dynamic get description_hint => 'Description hint';
  dynamic get system_prompt => 'System Prompt';
  dynamic get no_prompt_placeholder => 'No prompt placeholder';
  dynamic get prompt_hint => 'Prompt hint';
  dynamic get prompt_required => 'Prompt Required';
  dynamic get prompt_max_chars => 'Prompt Max Chars';
  dynamic get advanced_settings => 'Advanced Settings';
  dynamic get temperature_label => 'Temperature';
  dynamic get top_p_label => 'Top P';
  dynamic get temp_hint => 'Temp hint';
  dynamic get top_p_hint => 'Top p hint';
  dynamic get range_0_2 => 'Range 0 2';
  dynamic get range_0_1 => 'Range 0 1';
  dynamic get persona_updated => 'Persona Updated';
  dynamic get persona_created => 'Persona Created';
  dynamic get tts_models_title => 'TTS Models';
  dynamic get always_available => 'Always Available';
  dynamic get tts_system_desc => 'TTS system desc';
  dynamic get downloading_status => 'Downloading';
  dynamic get on_device_models_title => 'On Device Models';
  dynamic get available_models => 'Available Models';
  dynamic get device_memory => 'Device Memory';
  dynamic get ram_usage => 'RAM Usage';
  dynamic get memory_healthy => 'Memory Healthy';
  dynamic get memory_critical => 'Memory Critical';
  dynamic get memory_low => 'Memory Low';
  dynamic get available_ram => 'Available RAM';
  dynamic get total_capacity => 'Total Capacity';
  dynamic get loaded_status => 'Loaded';
  dynamic get inference_backend => 'Inference Backend';
  dynamic get backend_ios_notice => 'Backend IOS notice';
  dynamic get backend_cpu_desc => 'Backend CPU desc';
  dynamic get backend_gpu_desc => 'Backend GPU desc';
  dynamic get backend_npu_desc => 'Backend NPU desc';
  dynamic get select_model_title => 'Select Model';
  dynamic get refresh_models => 'Refresh Models';
  dynamic get search_models_hint => 'Search models hint';
  dynamic get no_server_connected => 'No Server Connected';
  dynamic get add_server_first => 'Add Server First';
  dynamic get failed_load_models => 'Failed Load Models';
  dynamic get no_models_available => 'No Models Available';
  dynamic get unload_from_server => 'Unload from Server';
  dynamic get download_complete_notification => 'Download Complete Notification';
  dynamic get engine_name_system => 'System';
  dynamic get engine_tagline_system => 'System';
  dynamic get engine_name_kitten => 'Kitten';
  dynamic get engine_tagline_kitten => 'Kitten';
  dynamic get engine_name_sherpa => 'Sherpa';
  dynamic get engine_tagline_sherpa => 'Sherpa';
  dynamic get voice_jasper => 'Voice Jasper';
  dynamic get voice_bella => 'Voice Bella';
  dynamic get voice_bruno => 'Voice Bruno';
  dynamic get voice_luna => 'Voice Luna';
  dynamic get voice_hugo => 'Voice Hugo';
  dynamic get voice_rosie => 'Voice Rosie';
  dynamic get voice_leo => 'Voice Leo';
  dynamic get voice_kiki => 'Voice Kiki';
  dynamic get voice_lessac => 'Voice Lessac';
  dynamic get voice_ryan => 'Voice Ryan';
  dynamic get model_qwen_3 => 'Model Qwen 3';
  dynamic get model_qwen_3_desc => 'Model qwen 3 desc';
  dynamic get model_license_apache => 'Apache';
  dynamic get model_qwen_25 => 'Model Qwen 25';
  dynamic get model_qwen_25_desc => 'Model qwen 25 desc';
  dynamic get model_deepseek => 'Model Deepseek';
  dynamic get model_deepseek_desc => 'Model deepseek desc';
  dynamic get model_license_mit => 'Mit';
  dynamic get model_gemma => 'Model Gemma';
  dynamic get model_gemma_desc => 'Model gemma desc';
  dynamic get export_role_user => 'User';
  dynamic get export_role_assistant => 'Assistant';
  dynamic get export_role_system => 'System';
  dynamic get export_role_tool => 'Tool';
  dynamic get export_text_user => 'User';
  dynamic get export_text_assistant => 'Assistant';
  dynamic get export_text_system => 'System';
  dynamic get export_text_tool => 'Tool';
  dynamic get export_label_user => 'User';
  dynamic get export_label_assistant => 'Assistant';
  dynamic get export_label_system => 'System';
  dynamic get export_label_tool => 'Tool';
  dynamic get select_model_hint => 'Select model hint';
  dynamic get test_notification_title => 'Test Notification';
  dynamic get test_notification_body => 'Test notification body';
  static final AppLocalizations _instance = AppLocalizations('en');
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
  dynamic get enable_smart_reply => 'Enable Smart Reply';
  dynamic get onboarding_choose_language => 'Onboarding Choose Language';
  dynamic get onboarding_choose_language_desc => 'Onboarding choose language desc';
  dynamic get onboarding_welcome => 'Onboarding Welcome';
  dynamic get beta_label => 'Beta';
  dynamic get experimental_label => 'Experimental';
  dynamic get add_more => 'Add More';
  dynamic get on_github => 'On Github';
  dynamic get could_not_open_github => 'Could Not Open Github';
  dynamic get openai_compatible_api => 'Openai Compatible API';
  dynamic get https_requires_ssl => 'HTTPS Requires SSL';
  dynamic get most_local_setups_use_http => 'Most Local Setups Use HTTP';
  dynamic get tts_supports_background => 'TTS Supports Background';
  dynamic get tts_other_services_background_note => 'TTS Other Services Background Note';
  dynamic get start_listening_tooltip => 'Start Listening';
  dynamic get stop_listening_tooltip => 'Stop Listening';
  dynamic get settings_huggingface_token => 'Settings Huggingface Token';
  dynamic get settings_huggingface_token_desc => 'Settings huggingface token desc';
  dynamic get settings_huggingface_token_set => 'Settings Huggingface Token Set';
  dynamic get settings_huggingface_token_cleared => 'Settings Huggingface Token Cleared';
  dynamic get model_requires_huggingface_token => 'Model Requires Huggingface Token';
  dynamic get model_missing_huggingface_token => 'Model Missing Huggingface Token';
  dynamic get set_huggingface_token => 'Set Huggingface Token';
  dynamic get clear_huggingface_token => 'Clear Huggingface Token';
  dynamic get edit_huggingface_token_dialog_title => 'Edit Huggingface Token Dialog';
  dynamic get huggingface_token_dialog_hint => 'Huggingface token dialog hint';
  dynamic get server_type_ollama_desc => 'Ollama desc';
  dynamic get server_type_on_device_desc => 'On device desc';
  dynamic get server_type_lm_studio_desc => 'Lm studio desc';
  dynamic get gguf_imported_models_title => 'GGUF Imported Models';
  dynamic get gguf_imported_models_empty_subtitle => 'GGUF imported models empty subtitle';
  dynamic get gguf_imported_models_ready => 'GGUF Imported Models Ready';
  dynamic get gguf_curated_models_subtitle => 'GGUF curated models subtitle';
  dynamic get gguf_only_supported => 'GGUF Only Supported';
  dynamic get gguf_imported_from_local_file => 'GGUF Imported from Local File';
  dynamic get gguf_import_failed => 'GGUF Import Failed';
  dynamic get gguf_imported_from_huggingface => 'GGUF Imported from Huggingface';
  dynamic get gguf_import_canceled => 'GGUF Import Canceled';
  dynamic get gguf_enter_huggingface_url => 'GGUF Enter Huggingface URL';
  dynamic get gguf_only_official_huggingface_urls => 'GGUF Only Official Huggingface Urls';
  dynamic get gguf_use_https_url => 'GGUF Use HTTPS URL';
  dynamic get gguf_url_must_point_to_file => 'GGUF URL Must Point to File';
  dynamic get gguf_unable_to_detect_file_name => 'GGUF Unable to Detect File Name';
  dynamic get gguf_download_empty => 'GGUF Download Empty';
  dynamic get gguf_selected_file_missing => 'GGUF Selected File Missing';
  dynamic get gguf_import_action => 'GGUF Import';
  dynamic get gguf_overview_title => 'GGUF Overview';
  dynamic get gguf_overview_subtitle => 'GGUF overview subtitle';
  dynamic get gguf_imported_count_label => 'GGUF Imported Count';
  dynamic get gguf_local_files_label => 'GGUF Local Files';
  dynamic get gguf_huggingface_label => 'GGUF Huggingface';
  dynamic get gguf_import_local_title => 'GGUF Import Local';
  dynamic get gguf_import_local_subtitle => 'GGUF import local subtitle';
  dynamic get gguf_import_huggingface_title => 'GGUF Import Huggingface';
  dynamic get gguf_import_huggingface_subtitle => 'GGUF import huggingface subtitle';
  dynamic get gguf_no_imported_title => 'GGUF No Imported';
  dynamic get gguf_no_imported_subtitle => 'GGUF no imported subtitle';
  dynamic get gguf_import_huggingface_dialog_title => 'GGUF Import Huggingface Dialog';
  dynamic get gguf_import_huggingface_dialog_subtitle => 'GGUF import huggingface dialog subtitle';
  dynamic get gguf_url_or_repo_path => 'GGUF URL or Repo Path';
  dynamic get paste => 'Paste';
  dynamic get gguf_browse => 'GGUF Browse';
  dynamic get gguf_huggingface_token_ready => 'GGUF Huggingface Token Ready';
  dynamic get gguf_huggingface_token_optional => 'GGUF Huggingface Token Optional';
  dynamic get gguf_huggingface_token_ready_desc => 'GGUF huggingface token ready desc';
  dynamic get gguf_huggingface_token_optional_desc => 'GGUF huggingface token optional desc';
  dynamic get gguf_downloading => 'GGUF Downloading';
  dynamic get gguf_preparing => 'GGUF Preparing';
  dynamic get gguf_preparing_download => 'GGUF Preparing Download';
  dynamic get gguf_cancel_import => 'GGUF Cancel Import';
  dynamic get clipboard_empty => 'Clipboard Empty';
  dynamic get could_not_open_huggingface => 'Could Not Open Huggingface';
  dynamic get gguf_paste_url_error => 'GGUF Paste URL Error';
  dynamic get gguf_blob_link => 'GGUF Blob Link';
  dynamic get gguf_repository_label => 'GGUF Repository';
  dynamic get gguf_detected_path_label => 'GGUF Detected Path';
  dynamic get gguf_imported_section_label => 'GGUF Imported Section';
  dynamic get gguf_already_available => 'GGUF Already Available';
  dynamic get gguf_curated_models_short => 'GGUF Curated Models';
  dynamic get execute_tool_title => 'Execute Tool';
  dynamic get execute_tool_request_desc => 'Execute tool request desc';
  dynamic get reject => 'Reject';
  dynamic get approve => 'Approve';
  dynamic get server_type_help => 'Help';
  dynamic get server_identity_title => 'Server Identity';
  dynamic get server_identity_desc => 'Server identity desc';
  dynamic get server_connection_title => 'Server Connection';
  dynamic get server_connection_desc => 'Server connection desc';
  dynamic get server_authentication_title => 'Server Authentication';
  dynamic get server_authentication_required_desc => 'Server authentication required desc';
  dynamic get server_authentication_optional_desc => 'Server authentication optional desc';
  dynamic get mcp_tools_title => 'MCP Tools';
  dynamic get available_tools => 'Available Tools';
  dynamic get unable_load_tools => 'Unable Load Tools';
  dynamic get no_tools_registered => 'No Tools Registered';
  dynamic get no_tools_registered_desc => 'No tools registered desc';
  dynamic get example_mcp_server_title => 'Example MCP Server';
  dynamic get example_mcp_server_desc => 'Example MCP server desc';
  dynamic get disable_example_server => 'Disable Example Server';
  dynamic get enable_example_server => 'Enable Example Server';
  dynamic get built_in_label => 'Built in';
  dynamic get highlights_label => 'Highlights';
  dynamic get built_with_label => 'Built with';
  dynamic get local_label => 'Local';
  dynamic get gguf_format_label => 'GGUF Format';
  dynamic get tool_status_requested => 'Requested';
  dynamic get tool_status_approved => 'Approved';
  dynamic get tool_status_rejected => 'Rejected';
  dynamic get tool_status_running => 'Running';
  dynamic get tool_status_done => 'Done';
  dynamic get tool_status_failed => 'Failed';
  dynamic get unload_all_models => 'Unload All Models';
  dynamic get all_models_unloaded => 'All Models Unloaded';
  dynamic get branch_chat => 'Branch chat';
  dynamic get branch_chat_desc => 'Branch chat desc';
  dynamic get edit_assistant_message_desc => 'Edit assistant message desc';
  dynamic get model_favorite_toggle => 'Model Favorite Toggle';
  dynamic get model_note_label => 'Model Note';
  dynamic get model_note_hint => 'Model note hint';
  dynamic get unload_models_before_load => 'Unload Models Before Load';
  dynamic get export_all_data => 'Export All Data';
  dynamic get import_all_data => 'Import All Data';
  dynamic get export_data_success => 'Export Data Success';
  dynamic get import_data_success => 'Import Data Success';
  dynamic get import_data_confirm => 'Import Data Confirm';
  dynamic loaded_models_count(dynamic count) => '';
  dynamic switch_to_model(dynamic modelName, dynamic model) => '';
  dynamic import_data_failed(dynamic error) => '';
  dynamic get import_settings_confirm => 'Import Settings Confirm';
  dynamic get export_conversations => 'Export Conversations';
  dynamic get import_conversations => 'Import Conversations';
  dynamic get export_personas => 'Export Personas';
  dynamic get import_personas => 'Import Personas';
  dynamic get export_settings => 'Export Settings';
  dynamic get import_settings => 'Import Settings';
  dynamic get export_all_zip => 'Export All ZIP';
  dynamic get import_all_zip => 'Import All ZIP';
  dynamic get duplicate_chat => 'Duplicate chat';
  dynamic get duplicate_chat_success => 'Duplicate Chat Success';
  dynamic get move_to_folder => 'Move to folder';
  dynamic get remove_from_folder => 'Remove from folder';
  dynamic get create_folder => 'Create Folder';
  dynamic get new_folder => 'New Folder';
  dynamic get folder_name_hint => 'Folder name hint';
  dynamic get all_chats => 'All Chats';
  dynamic get unfiled_chats => 'Unfiled Chats';
  dynamic get create => 'Create';
  dynamic get server_path_prefix_label => 'Server Path Prefix';
  dynamic get server_path_prefix_hint => 'Server path prefix hint';
  dynamic get search_message_contents => 'Search Message Contents';
  dynamic get message_search_results => 'Message Search Results';
  dynamic get saved_messages_title => 'Saved Messages';
  dynamic get nav_saved_messages => 'Saved Messages';
  dynamic get saved_messages_empty => 'Saved Messages Empty';
  dynamic get save_message => 'Save Message';
  dynamic get message_saved => 'Message Saved';
  dynamic get test_tts_section_title => 'Test TTS Section';
  dynamic get test_tts_hint => 'Test TTS hint';
  dynamic get test_speak_button => 'Test Speak';
  dynamic token_count(dynamic count) => '';
  dynamic estimated_token_count(dynamic count) => '';
  dynamic get scroll_to_bottom => 'Scroll to Bottom';
  dynamic get generate_ai_response => 'Generate AI Response';
  dynamic get no_response => 'No Response';
  dynamic get export => 'Export';
  dynamic get import => 'Import';
  dynamic get conversations_label => 'Conversations';
  dynamic get personas_label => 'Personas';
  dynamic get settings_label => 'Settings';
  dynamic get export_conversation => 'Export conversation';
  dynamic get tts_process_markdown => 'TTS Process Markdown';
  dynamic get tts_process_markdown_desc => 'TTS process markdown desc';
  dynamic get preview_system_prompts => 'Preview System Prompts';
  dynamic get welcome_message_1 => 'Welcome Message 1';
  dynamic get welcome_message_2 => 'Welcome Message 2';
  dynamic get welcome_message_3 => 'Welcome Message 3';
  dynamic get welcome_message_4 => 'Welcome Message 4';
  dynamic get tts_skip_seconds => 'TTS Skip Seconds';
  dynamic get tts_skip_seconds_desc => 'TTS skip seconds desc';
  dynamic get temporary_chat => 'Temporary Chat';
  dynamic get temporary_chat_desc => 'Temporary chat desc';
  dynamic get temporary_chat_banner => 'Temporary Chat Banner';
  dynamic get temporary_chat_save_warning_title => 'Temporary Chat Save Warning';
  dynamic get temporary_chat_save_warning_body => 'Temporary chat save warning body';
  dynamic get save_to_history => 'Save to History';
  dynamic get share_conversation => 'Share Conversation';
  dynamic get download_tts_audio => 'Download TTS Audio';
  dynamic get tts_download_unavailable => 'TTS Download Unavailable';
  dynamic get tts_download_no_audio => 'TTS Download No Audio';
  dynamic get tts_download_success => 'TTS Download Success';
  dynamic get return_to_chat => 'Return to Chat';
  dynamic get return_to_temp_chat => 'Return to Temp Chat';
  dynamic get insert_saved_message => 'Insert Saved Message';
  dynamic get insert_saved_message_desc => 'Insert saved message desc';
  dynamic get model_info => 'Model Info';
  dynamic get model_name => 'Model Name';
  dynamic get model_identifier => 'Model Identifier';
  dynamic get not_available => 'Not available';
  dynamic get save_message_folders => 'Save Message Folders';
  dynamic get remove_from_saved => 'Remove from Saved';
  dynamic get message_already_saved => 'Message Already Saved';
  dynamic get stream_ttft => 'Stream TTFT';
  dynamic get stream_tokens_per_sec => 'Stream Tokens Per Sec';
  dynamic get stream_stop_reason => 'Stream Stop Reason';
  dynamic get stream_input_tokens => 'Stream Input Tokens';
  dynamic get stream_output_tokens => 'Stream Output Tokens';
  dynamic get stream_generation_time => 'Stream Generation Time';
  dynamic get attach_image => 'Attach Image';
  dynamic get attach_text_document => 'Attach Text Document';
  dynamic get add_attachment => 'Add Attachment';
  dynamic get photo_permission_denied => 'Photo Permission Denied';
  dynamic get characters_label => 'Characters';
  dynamic get exit_temporary_chat_title => 'Exit Temporary Chat';
  dynamic get exit_temporary_chat_body => 'Exit temporary chat body';
  dynamic get saved_message_temp_snap_unavailable => 'Saved Message Temp Snap Unavailable';
  dynamic get filter_title => 'Title';
  dynamic get filter_pinned => 'Pinned';
  dynamic get filter_archived => 'Archived';
  dynamic get filter_temp_chats => 'Temp Chats';
  dynamic get filter_user_messages => 'User Messages';
  dynamic get filter_assistant_messages => 'Assistant Messages';
  dynamic get archive_chat => 'Archive chat';
  dynamic get unarchive_chat => 'Unarchive chat';
  dynamic get generate_title_with_ai => 'Generate Title with AI';
  dynamic get generating_title => 'Generating';
  dynamic get generate_title_failed => 'Generate Title Failed';
  dynamic tts_skip_seconds_value(dynamic seconds) => '';
  dynamic conversation_message_count(dynamic count) => '';
  dynamic conversation_character_count(dynamic count) => '';
  dynamic get ai_user_response_enabled => 'AI User Response Enabled';
  dynamic get ai_user_response_tooltip => 'AI User Response';
  dynamic get delete_builtin_persona_body => 'Delete builtin persona body';
  dynamic get restore_builtin_personas => 'Restore Builtin Personas';
  dynamic get restore_builtin_personas_desc => 'Restore builtin personas desc';
  dynamic get restore_builtin_personas_success => 'Restore Builtin Personas Success';
  dynamic get clear_personas => 'Clear Personas';
  dynamic get enable_image_compression => 'Enable Image Compression';
  dynamic get enable_image_compression_desc => 'Enable image compression desc';
  dynamic get image_compression_level => 'Image Compression Level';
  dynamic get image_compression_level_desc => 'Desc';
  dynamic get image_compression_level_low => 'Low';
  dynamic get image_compression_level_medium => 'Medium';
  dynamic get image_compression_level_high => 'High';
  dynamic get sort_models_tooltip => 'Sort Models';
  dynamic get sort_by_favorites => 'Favorites';
  dynamic get sort_by_name => 'Name';
  dynamic get sort_by_size_smallest => 'Size Smallest';
  dynamic get sort_by_size_largest => 'Size Largest';
  dynamic get sort_by_context_length => 'Context Length';
  dynamic get ai_rename_tooltip => 'AI Rename';
  dynamic get new_chat_in_folder_tooltip => 'New Chat in Folder';
  dynamic get smart_replies_use_persona => 'Smart Replies Use Persona';
  dynamic get smart_replies_use_persona_desc => 'Smart replies use persona desc';
  dynamic get keep_persona_on_new_chat => 'Keep Persona on New Chat';
  dynamic get keep_persona_on_new_chat_desc => 'Keep persona on new chat desc';
  dynamic get role_swap_button_enabled => 'Role Swap Button Enabled';
  dynamic get role_swap_button_enabled_desc => 'Role swap button enabled desc';
  dynamic get send_as_user_tooltip => 'Send As User';
  dynamic get send_as_assistant_tooltip => 'Send As Assistant';
  dynamic get insert_without_generating_tooltip => 'Insert Without Generating';
  dynamic get token_usage_title => 'Token Usage';
  dynamic get total_tokens_label => 'Total Tokens';
  dynamic get usage_percent_label => 'Usage Percent';
  dynamic get export_choice_title => 'Export Choice';
  dynamic get export_choice_body => 'Export choice body';
  dynamic get copy_to_clipboard => 'Copy to Clipboard';
  dynamic get bulk_ai_rename_confirm_title => 'Bulk AI Rename Confirm';
  dynamic get sort_by_modified_date => 'Modified Date';
  dynamic get sort_by_created_date => 'Created Date';
  dynamic get sort_title => 'Sort';
  dynamic get ai_user_response_enabled_desc => 'AI user response enabled desc';
  dynamic get show_system_messages_desc => 'Show system messages desc';
  dynamic get show_system_messages_in_chat => 'Show System Messages in Chat';
  dynamic get show_system_messages_in_chat_desc => 'Show system messages in chat desc';
  dynamic get manage_personas => 'Manage Personas';
  dynamic get personas_combine_hint => 'Personas combine hint';
  dynamic get temp_chat_keyboard_incognito => 'Temp Chat Keyboard Incognito';
  dynamic get temp_chat_keyboard_incognito_desc => 'Temp chat keyboard incognito desc';
  dynamic get resume_last_chat => 'Resume Last Chat';
  dynamic get resume_last_chat_desc => 'Resume last chat desc';
  dynamic get lm_studio_model_browser_title => 'Lm Studio Model Browser';
  dynamic get lm_studio_model_search_hint => 'Lm studio model search hint';
  dynamic get lm_studio_staff_picks => 'Lm Studio Staff Picks';
  dynamic get lm_studio_community_models => 'Lm Studio Community Models';
  dynamic get lm_studio_no_models => 'Lm Studio No Models';
  dynamic get lm_studio_browse_models => 'Lm Studio Browse Models';
  dynamic get lm_studio_model_search => 'Lm Studio Model Search';
  dynamic get lm_studio_downloads_title => 'Lm Studio Downloads';
  dynamic get lm_studio_choose_quant => 'Lm Studio Choose Quant';
  dynamic get lm_studio_use_default_quant => 'Lm Studio Use Default Quant';
  dynamic get lm_studio_recommended => 'Lm Studio Recommended';
  dynamic get lm_studio_clear_downloads => 'Lm Studio Clear Downloads';
  dynamic get lm_studio_no_downloads => 'Lm Studio No Downloads';
  dynamic get lm_studio_downloads_disclaimer => 'Lm studio downloads disclaimer';
  dynamic get lm_studio_staff_pick => 'Lm Studio Staff Pick';
  dynamic get lm_studio_params => 'Lm Studio Params';
  dynamic get lm_studio_arch => 'Lm Studio Arch';
  dynamic get lm_studio_domain => 'Lm Studio Domain';
  dynamic get lm_studio_format => 'Lm Studio Format';
  dynamic get lm_studio_vision => 'Lm Studio Vision';
  dynamic get lm_studio_tool_use => 'Lm Studio Tool Use';
  dynamic get lm_studio_reasoning => 'Lm Studio Reasoning';
  dynamic get lm_studio_download_options => 'Lm Studio Download Options';
  dynamic get lm_studio_download => 'Lm Studio Download';
  dynamic get lm_studio_readme_unavailable => 'Lm Studio Readme Unavailable';
  dynamic get lm_studio_full_gpu_offload => 'Lm Studio Full GPU Offload';
  dynamic get lm_studio_partial_gpu_offload => 'Lm Studio Partial GPU Offload';
  dynamic get lm_studio_likely_too_large => 'Lm Studio Likely Too Large';
  dynamic get lm_studio_available_ram_gb => 'Lm Studio Available RAM Gb';
  dynamic get lm_studio_available_vram_gb => 'Lm Studio Available Vram Gb';
  dynamic get lm_studio_memory_settings_title => 'Lm Studio Memory Settings';
  dynamic get lm_studio_memory_settings_desc => 'Lm studio memory settings desc';
  dynamic get think_button_label => 'Think Button';
  dynamic get reasoning_effort_low => 'Low';
  dynamic get reasoning_effort_medium => 'Medium';
  dynamic get reasoning_effort_high => 'High';
  dynamic bulk_ai_rename_progress(dynamic done, dynamic total) => '';
  dynamic selected_count(dynamic count) => '';
  dynamic total_tokens_count(dynamic count) => '';
  dynamic bulk_export_conversations_success(dynamic count) => '';
  dynamic bulk_ai_rename_confirm_body(dynamic count) => '';
  dynamic lm_studio_models_count(dynamic count) => '';
  dynamic lm_studio_download_size(dynamic size) => '';
  dynamic lm_studio_downloading_percent(dynamic percent) => '';
  dynamic get could_not_read_file => 'Could Not Read File';
  dynamic get server_offline => 'Server Offline';
  dynamic get could_not_establish_connection => 'Could Not Establish Connection';
  dynamic get retry_connection => 'Retry Connection';
  dynamic get tokens_label => 'Tokens';
  dynamic get enter_context_length => 'Enter Context Length';
}
