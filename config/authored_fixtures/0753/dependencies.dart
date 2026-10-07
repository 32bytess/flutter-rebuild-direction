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

TextEditingController fixtureController = TextEditingController(
  text:
      'The quick brown fox jumps over the lazy dog. '
      'This is a longer sample to test how the selected text-to-speech engine handles extended passages.',
);

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
  dynamic get app_name => 'LocalMind';
  dynamic get app_tagline => 'Your models, your device';
  dynamic get app_version => '1.4.2';
  dynamic get cancel => 'Cancel';
  dynamic get confirm => 'OK';
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
  dynamic get copied => 'Copied!';
  dynamic get copied_to_clipboard => 'Copied to clipboard';
  dynamic get select => 'Select';
  dynamic get active => 'Active';
  dynamic get all => 'All';
  dynamic get none => 'None';
  dynamic get none_selected => 'None selected';
  dynamic get online => 'Online';
  dynamic get offline => 'Offline';
  dynamic get error => 'Something went wrong';
  dynamic get unknown_error => 'An unknown error occurred';
  dynamic get not_now => 'Not now';
  dynamic get enable => 'Enable';
  dynamic get proceed_anyway => 'Proceed Anyway';
  dynamic get test_connection => 'Test Connection';
  dynamic get testing => 'Testing...';
  dynamic get connection_successful => 'Connection successful!';
  dynamic get connection_failed => 'Connection failed. Check your settings.';
  dynamic get save_continue => 'Save and continue';
  dynamic get save_changes => 'Save Changes';
  dynamic get finish_setup => 'Finish Setup';
  dynamic get start_new_chat => 'Start a new chat';
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
  dynamic get startup_failed => 'The app failed to start';
  dynamic get something_went_wrong => 'Something went wrong';
  dynamic get delete_model_title => 'Delete Model';
  dynamic get delete_voice_title => 'Delete Voice';
  dynamic get delete_server_title => 'Delete Server';
  dynamic get delete_conversation_title => 'Delete conversation?';
  dynamic get delete_message_title => 'Delete message?';
  dynamic get delete_persona_body => 'This cannot be undone.';
  dynamic get clear_conversation_title => 'Clear conversation?';
  dynamic get clear_conversation_body => 'This will remove every message in this chat. This cannot be undone.';
  dynamic get clear => 'Clear';
  dynamic get no_model_loaded => 'No Model Loaded';
  dynamic get delete_conversation => 'Delete conversation?';
  dynamic get nav_history => 'History';
  dynamic get nav_servers => 'Servers';
  dynamic get nav_local_models => 'Local Models';
  dynamic get nav_tts => 'TTS';
  dynamic get nav_personas => 'Personas';
  dynamic get nav_settings => 'Settings';
  dynamic get nav_new_chat => 'New Chat';
  dynamic get search_hint => 'Search conversations';
  dynamic get no_server_selected => 'No server selected';
  dynamic get switch_server => 'Switch Server';
  dynamic get switch_server_subtitle => 'Choose a server to connect to';
  dynamic get manage_servers => 'Manage Servers';
  dynamic get open_source => 'Open Source';
  dynamic get open_source_desc => 'LocalMind is free and open source.';
  dynamic get star_on_github => 'Star on GitHub';
  dynamic get add_more => 'Add More';
  dynamic get on_github => 'On Github';
  dynamic get could_not_open_github => 'Could Not Open Github';
  dynamic get settings_title => 'Settings';
  dynamic get settings_appearance => 'Appearance';
  dynamic get settings_language => 'Language';
  dynamic get language_system_default => 'System Default';
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
  dynamic get font_size => 'Font Size';
  dynamic get font_size_desc => 'Adjust text size in chat.';
  dynamic get font_preview => 'The quick brown fox jumps over the lazy dog.';
  dynamic get code_theme_dark => 'Dark';
  dynamic get code_theme_light => 'Light';
  dynamic get code_theme_desc => 'Desc';
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
  dynamic get manage_on_device_models => 'Manage On-Device Models';
  dynamic get enable_smart_reply => 'On-Device Smart Replies';
  dynamic get streaming_responses => 'Stream responses';
  dynamic get auto_generate_titles => 'Auto-generate Titles';
  dynamic get send_on_enter => 'Send with Enter';
  dynamic get show_system_messages => 'Show System Messages';
  dynamic get haptic_feedback => 'Haptic Feedback';
  dynamic get enable_mcp => 'Enable MCP integrations';
  dynamic get new_chat_mcp_default => 'Enable MCP in new chats';
  dynamic get show_data_indicator => 'Show data usage indicator';
  dynamic get privacy_info => '"LocalMind never sees your data"';
  dynamic get delete_all_conversations => 'Delete All Conversations';
  dynamic get reset_settings_defaults => 'Reset settings to defaults';
  dynamic get chat_title => 'Chat';
  dynamic get chat_parameters_tooltip => 'Chat Parameters';
  dynamic get change_persona => 'Change Persona';
  dynamic get set_persona => 'Set Persona';
  dynamic get remove_persona => 'Remove Persona';
  dynamic get clear_conversation => 'Clear Conversation';
  dynamic get connection_error => 'Connection error. Check your server.';
  dynamic get disconnected => 'Disconnected from server.';
  dynamic get configure => 'Configure';
  dynamic get select_model => 'Select Model';
  dynamic get select_persona => 'Select Persona';
  dynamic get start_conversation => 'Start a conversation';
  dynamic get recent_chats => 'Recent chats';
  dynamic get see_all => 'See all';
  dynamic get quick_write => 'Help me write a function';
  dynamic get quick_explain => 'Explain this code';
  dynamic get quick_debug => 'Debug my code';
  dynamic get quick_async => 'How do I use async/await?';
  dynamic get history_missing_title => 'History Missing';
  dynamic get history_missing_desc => 'Either the messages in this chat were deleted or the history record is corrupted.';
  dynamic get technical_details => 'Technical Details';
  dynamic get last_error => 'Last Error:';
  dynamic get copy_info => 'Copy details';
  dynamic get conversation_id => 'Conversation ID';
  dynamic get created_at => 'Created';
  dynamic get expected_messages => 'Expected Messages';
  dynamic get debug_dialog_desc => 'Include these details when you report the issue.';
  dynamic get chat_input_hint => 'Ask anything';
  dynamic get send_message_tooltip => 'Send message';
  dynamic get stop_generation_tooltip => 'Stop Generation';
  dynamic get attach_images_tooltip => 'Attach images';
  dynamic get start_listening_tooltip => 'Start Listening';
  dynamic get stop_listening_tooltip => 'Stop Listening';
  dynamic get tool_unknown => 'Unknown tool';
  dynamic get message_options => 'Message options';
  dynamic get copy_markdown => 'Copy as Markdown';
  dynamic get copied_markdown => 'Markdown copied';
  dynamic get read_aloud => 'Read Aloud';
  dynamic get stop_reading => 'Stop Reading';
  dynamic get more => 'More';
  dynamic get edit_message => 'Edit message';
  dynamic get edit_message_desc => 'Editing this message removes every reply after it.';
  dynamic get save_regenerate => 'Save and regenerate';
  dynamic get chat_settings_title => 'Chat Settings';
  dynamic get reset_defaults => 'Reset to defaults';
  dynamic get parameters_tab => 'Parameters';
  dynamic get mcp_tab => 'MCP';
  dynamic get temperature => 'Temperature';
  dynamic get temperature_desc => 'Higher values make replies more creative.';
  dynamic get top_p => 'Top P';
  dynamic get top_p_desc => 'Limits sampling to the most likely tokens';
  dynamic get max_tokens => 'Max Tokens';
  dynamic get max_tokens_desc => 'Response limit';
  dynamic get context_length => 'Context Length';
  dynamic get context_length_desc => 'History window';
  dynamic get mcp_disabled_warning => 'MCP is disabled in settings.';
  dynamic get mcp_enable_chat => 'Enable MCP for this chat';
  dynamic get auto_execute_tools => 'Auto-execute tools';
  dynamic get beta_label => 'Beta';
  dynamic get experimental_label => 'Experimental';
  dynamic get add_ephemeral_mcp => 'Add Ephemeral MCP Server';
  dynamic get mcp_label_placeholder => 'Label';
  dynamic get mcp_url_placeholder => 'https://example.com/mcp';
  dynamic get active_integrations => 'Active Integrations';
  dynamic get enable_notifications => 'Enable Notifications';
  dynamic get enable_notifications_desc => 'Get notified when downloads and replies finish.';
  dynamic get chat_history_title => 'History';
  dynamic get conversation_just_now => 'Just now';
  dynamic get conversation_yesterday => 'Yesterday';
  dynamic get options_tooltip => 'Options';
  dynamic get no_results_found => 'No results found';
  dynamic get no_conversations_yet => 'No conversations yet';
  dynamic get try_different_search => 'Try a different search term';
  dynamic get start_new_conversation => 'Start a new conversation';
  dynamic get rename_conversation => 'Rename conversation';
  dynamic get enter_new_title => 'Enter New';
  dynamic get pinned_section => 'PINNED';
  dynamic get today_section => 'TODAY';
  dynamic get yesterday_section => 'YESTERDAY';
  dynamic get previous_7_days => 'PREVIOUS 7 DAYS';
  dynamic get previous_30_days => 'PREVIOUS 30 DAYS';
  dynamic get older_section => 'OLDER';
  dynamic get onboarding_choose_language => 'Choose your language';
  dynamic get onboarding_choose_language_desc => 'You can change this later in Settings.';
  dynamic get onboarding_localmind => 'LOCALMIND';
  dynamic get onboarding_connect_server => 'Connect a server';
  dynamic get onboarding_connect_desc => 'Choose where your models run. You can change this later.';
  dynamic get openai_compatible_api => 'OpenAI-compatible API';
  dynamic get https_requires_ssl => 'HTTPS requires a valid SSL certificate';
  dynamic get most_local_setups_use_http => 'Most local setups use HTTP.';
  dynamic get onboarding_welcome => 'Welcome to LocalMind';
  dynamic get server_type_on_device => 'On Device';
  dynamic get server_type_lm_studio => 'LM Studio';
  dynamic get server_type_ollama => 'Ollama';
  dynamic get server_type_openrouter => 'OpenRouter';
  dynamic get server_type_openrouter_sub => 'Openrouter';
  dynamic get ready_continue => 'Ready to continue';
  dynamic get waiting_selection => 'Pick an option to continue';
  dynamic get setup_connection => 'Set up connection';
  dynamic get server_name => 'Server Name';
  dynamic get name_required => 'A name is required';
  dynamic get name_max_50 => 'Max 50 characters';
  dynamic get host_label => 'Host';
  dynamic get host_required => 'A host is required';
  dynamic get port_label => 'Port';
  dynamic get port_required => 'A port is required';
  dynamic get port_invalid => 'Must be a number';
  dynamic get port_range => 'Enter a valid port (1-65535)';
  dynamic get api_key_required => 'API Key *';
  dynamic get api_key_optional => 'API key (optional)';
  dynamic get api_key_required_openrouter => 'API Key required for OpenRouter';
  dynamic get api_key_format => 'OpenRouter API keys start with sk-';
  dynamic get my_server_hint => 'My server';
  dynamic get name_length_validation => 'Name must be 50 characters or less';
  dynamic get host_valid => 'Enter a valid hostname or IP address';
  dynamic get api_key_hint_openrouter => 'sk-or-v1-...';
  dynamic get api_key_hint_generic => 'For authenticated servers';
  dynamic get update_server => 'Update Server';
  dynamic get save_server => 'Save Server';
  dynamic get server_updated => 'Server updated';
  dynamic get server_added => 'Server added';
  dynamic get download_model_title => 'Download Model';
  dynamic get download_model_desc => 'Download a model to chat without a server.';
  dynamic get on_device_android_only => 'On-device inference is Android only for now.';
  dynamic get total_ram => 'Total memory';
  dynamic get available => 'Available';
  dynamic get choose_theme => 'Choose a theme';
  dynamic get choose_theme_desc => 'Pick how the app should look.';
  dynamic get theme_card_system => 'System';
  dynamic get theme_card_system_sub => 'System';
  dynamic get theme_card_light => 'Light';
  dynamic get theme_card_light_sub => 'Light';
  dynamic get theme_card_dark => 'Dark';
  dynamic get theme_card_dark_sub => 'Dark';
  dynamic get theme_card_claude => 'Claude';
  dynamic get theme_card_claude_sub => 'Claude';
  dynamic get stay_updated => 'Stay Updated';
  dynamic get stay_updated_desc => 'Allow notifications so you do not have to keep the app open.';
  dynamic get notification_benefit_downloads => 'Download progress';
  dynamic get notification_benefit_completions => 'Finished replies';
  dynamic get notification_benefit_background => 'Background activity';
  dynamic get allow_notifications => 'Allow Notifications';
  dynamic get servers_title => 'Servers';
  dynamic get no_servers_yet => 'No Servers Yet';
  dynamic get no_servers_desc => 'Add a server to start chatting.';
  dynamic get add_server => 'Add Server';
  dynamic get edit_server => 'Edit Server';
  dynamic get add_server_title => 'Add Server';
  dynamic get server_type_label => 'Label';
  dynamic get server_icon_label => 'Label';
  dynamic get default_icon => 'Default icon';
  dynamic get server_type_lm_studio_display => 'LM Studio';
  dynamic get server_type_openai_display => 'Openai';
  dynamic get server_type_ollama_display => 'Ollama';
  dynamic get server_type_openrouter_display => 'OpenRouter';
  dynamic get server_type_on_device_display => 'On Device';
  dynamic get server_address_openrouter => 'openrouter.ai';
  dynamic get server_address_on_device => 'Local inference';
  dynamic get default_badge => 'Default';
  dynamic get set_as_default => 'Set As Default';
  dynamic get select_icon => 'Select an icon';
  dynamic get select_icon_desc => 'Choose an icon for your server';
  dynamic get search_icons_hint => 'Search icons';
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
  dynamic get clone_edit => 'Clone and edit';
  dynamic get builtin_badge => 'Builtin';
  dynamic get no_personas_found => 'No personas found';
  dynamic get no_personas_desc => 'Create a persona to give the assistant a role.';
  dynamic get edit_persona => 'Edit Persona';
  dynamic get create_persona => 'Create Persona';
  dynamic get create_persona_button => 'Create Persona';
  dynamic get emoji_label => 'Emoji';
  dynamic get name_label => 'Name';
  dynamic get my_persona_hint => 'My persona';
  dynamic get category_label => 'Category';
  dynamic get description_optional => 'Description (optional)';
  dynamic get description_hint => 'What this persona does...';
  dynamic get system_prompt => 'System Prompt';
  dynamic get no_prompt_placeholder => 'No prompt set';
  dynamic get prompt_hint => 'You are a helpful assistant...';
  dynamic get prompt_required => 'A system prompt is required';
  dynamic get prompt_max_chars => 'Max 4000 characters';
  dynamic get advanced_settings => 'Advanced Settings';
  dynamic get temperature_label => 'Temperature';
  dynamic get top_p_label => 'Top P';
  dynamic get temp_hint => '0.7';
  dynamic get top_p_hint => '0.9';
  dynamic get range_0_2 => '0.0-2.0';
  dynamic get range_0_1 => '0.0-1.0';
  dynamic get persona_updated => 'Persona updated';
  dynamic get persona_created => 'Persona created';
  dynamic get tts_models_title => 'TTS Models';
  dynamic get always_available => 'Always available';
  dynamic get tts_system_desc => 'Uses the voice engine built into the device.';
  dynamic get downloading_status => 'Downloading...';
  dynamic get on_device_models_title => 'On Device Models';
  dynamic get settings_huggingface_token => 'Hugging Face Token';
  dynamic get settings_huggingface_token_desc => 'Required for gated model downloads.';
  dynamic get settings_huggingface_token_set => 'Token saved';
  dynamic get settings_huggingface_token_cleared => 'Token cleared';
  dynamic get model_requires_huggingface_token => 'This model requires a Hugging Face token.';
  dynamic get model_missing_huggingface_token => 'Add a Hugging Face token to download this model.';
  dynamic get set_huggingface_token => 'Set token';
  dynamic get clear_huggingface_token => 'Clear token';
  dynamic get edit_huggingface_token_dialog_title => 'Edit Huggingface Token Dialog';
  dynamic get huggingface_token_dialog_hint => 'hf_...';
  dynamic get server_type_ollama_desc => 'Ollama desc';
  dynamic get server_type_on_device_desc => 'On device desc';
  dynamic get server_type_lm_studio_desc => 'Lm studio desc';
  dynamic get available_models => 'Available Models';
  dynamic get device_memory => 'Device Memory';
  dynamic get ram_usage => 'Memory in use';
  dynamic get memory_healthy => 'Healthy';
  dynamic get memory_critical => 'Critical';
  dynamic get memory_low => 'Low';
  dynamic get available_ram => 'Available memory';
  dynamic get total_capacity => 'Total Capacity';
  dynamic get loaded_status => 'Loaded';
  dynamic get inference_backend => 'Inference Backend';
  dynamic get backend_ios_notice => 'Only CPU backend is available on iOS.';
  dynamic get backend_cpu_desc => 'Works everywhere, slowest option';
  dynamic get backend_gpu_desc => 'Faster, needs a supported GPU';
  dynamic get backend_npu_desc => 'Fastest on supported devices';
  dynamic get select_model_title => 'Select Model';
  dynamic get refresh_models => 'Refresh models';
  dynamic get search_models_hint => 'Search models';
  dynamic get no_server_connected => 'No server connected';
  dynamic get add_server_first => 'Add a server first';
  dynamic get failed_load_models => 'Could not load models';
  dynamic get no_models_available => 'No models available';
  dynamic get unload_from_server => 'Unload from server';
  dynamic get unload_all_models => 'Unload All Models';
  dynamic get all_models_unloaded => 'All Models Unloaded';
  dynamic get branch_chat => 'Branch chat';
  dynamic get branch_chat_desc => 'Branch chat desc';
  dynamic get edit_assistant_message_desc => 'Edit assistant message desc';
  dynamic get download_complete_notification => 'Download complete';
  dynamic get engine_name_system => 'System';
  dynamic get engine_tagline_system => 'System';
  dynamic get engine_name_kitten => 'Kitten';
  dynamic get engine_tagline_kitten => 'Kitten';
  dynamic get engine_name_sherpa => 'Sherpa';
  dynamic get engine_tagline_sherpa => 'Sherpa';
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
  dynamic get model_qwen_3 => 'Qwen 3 0.6B';
  dynamic get model_qwen_3_desc => 'Balanced general purpose model';
  dynamic get model_license_apache => 'Apache';
  dynamic get model_qwen_25 => 'Qwen 2.5 1.5B Instruct';
  dynamic get model_qwen_25_desc => 'Balanced instruct model for longer chats.';
  dynamic get model_deepseek => 'DeepSeek R1 Distill Qwen 1.5B';
  dynamic get model_deepseek_desc => 'Strong at reasoning and code';
  dynamic get model_license_mit => 'MIT';
  dynamic get model_gemma => 'Gemma 2 2B';
  dynamic get model_gemma_desc => 'Compact model from Google';
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
  dynamic get select_model_hint => 'Choose a model to chat with';
  dynamic get test_notification_title => 'Test Notification';
  dynamic get test_notification_body => 'Notifications are working.';
  dynamic get tts_supports_background => 'Playback continues in the background';
  dynamic get tts_other_services_background_note => 'Other engines stop when the app leaves the foreground.';
  dynamic get gguf_imported_models_title => 'GGUF Imported Models';
  dynamic get gguf_imported_models_empty_subtitle => 'GGUF imported models empty subtitle';
  dynamic get gguf_imported_models_ready => 'Ready to load';
  dynamic get gguf_curated_models_subtitle => 'GGUF curated models subtitle';
  dynamic get gguf_only_supported => 'Only GGUF files are supported';
  dynamic get gguf_imported_from_local_file => 'Imported from a local file';
  dynamic get gguf_import_failed => 'Import failed';
  dynamic get gguf_imported_from_huggingface => 'Imported from Hugging Face';
  dynamic get gguf_import_canceled => 'Import cancelled';
  dynamic get gguf_enter_huggingface_url => 'Enter a Hugging Face URL';
  dynamic get gguf_only_official_huggingface_urls => 'GGUF Only Official Huggingface Urls';
  dynamic get gguf_use_https_url => 'Use an HTTPS link';
  dynamic get gguf_url_must_point_to_file => 'GGUF URL Must Point to File';
  dynamic get gguf_unable_to_detect_file_name => 'GGUF Unable to Detect File Name';
  dynamic get gguf_download_empty => 'The download was empty';
  dynamic get gguf_selected_file_missing => 'GGUF Selected File Missing';
  dynamic get gguf_import_action => 'GGUF Import';
  dynamic get gguf_overview_title => 'GGUF Overview';
  dynamic get gguf_overview_subtitle => 'Bring your own quantised model files';
  dynamic get gguf_imported_count_label => 'GGUF Imported Count';
  dynamic get gguf_local_files_label => 'GGUF Local Files';
  dynamic get gguf_huggingface_label => 'GGUF Huggingface';
  dynamic get gguf_import_local_title => 'GGUF Import Local';
  dynamic get gguf_import_local_subtitle => 'Pick a GGUF file from storage';
  dynamic get gguf_import_huggingface_title => 'GGUF Import Huggingface';
  dynamic get gguf_import_huggingface_subtitle => 'Paste a link to a GGUF file';
  dynamic get gguf_no_imported_title => 'GGUF No Imported';
  dynamic get gguf_no_imported_subtitle => 'Anything you import shows up here.';
  dynamic get gguf_import_huggingface_dialog_title => 'GGUF Import Huggingface Dialog';
  dynamic get gguf_import_huggingface_dialog_subtitle => 'GGUF import huggingface dialog subtitle';
  dynamic get gguf_url_or_repo_path => 'URL or repository path';
  dynamic get paste => 'Paste';
  dynamic get gguf_browse => 'Browse';
  dynamic get gguf_huggingface_token_ready => 'Token ready';
  dynamic get gguf_huggingface_token_optional => 'Token optional';
  dynamic get gguf_huggingface_token_ready_desc => 'GGUF huggingface token ready desc';
  dynamic get gguf_huggingface_token_optional_desc => 'GGUF huggingface token optional desc';
  dynamic get gguf_downloading => 'Downloading';
  dynamic get gguf_preparing => 'Preparing';
  dynamic get gguf_preparing_download => 'Preparing download';
  dynamic get gguf_cancel_import => 'Cancel import';
  dynamic get clipboard_empty => 'The clipboard is empty';
  dynamic get could_not_open_huggingface => 'Could Not Open Huggingface';
  dynamic get gguf_paste_url_error => 'That does not look like a link';
  dynamic get gguf_blob_link => 'Blob link detected';
  dynamic get gguf_repository_label => 'GGUF Repository';
  dynamic get gguf_detected_path_label => 'GGUF Detected Path';
  dynamic get gguf_imported_section_label => 'GGUF Imported Section';
  dynamic get gguf_already_available => 'Already available';
  dynamic get gguf_curated_models_short => 'GGUF Curated Models';
  dynamic get execute_tool_title => 'Execute Tool';
  dynamic get execute_tool_request_desc => 'Execute tool request desc';
  dynamic get reject => 'Reject';
  dynamic get approve => 'Approve';
  dynamic get server_type_help => 'Help';
  dynamic get server_identity_title => 'Server Identity';
  dynamic get server_identity_desc => 'How this server is shown in the app.';
  dynamic get server_connection_title => 'Server Connection';
  dynamic get server_connection_desc => 'Where the app should send requests.';
  dynamic get server_authentication_title => 'Server Authentication';
  dynamic get server_authentication_required_desc => 'Server authentication required desc';
  dynamic get server_authentication_optional_desc => 'Server authentication optional desc';
  dynamic get mcp_tools_title => 'MCP Tools';
  dynamic get available_tools => 'Available Tools';
  dynamic get unable_load_tools => 'Could not load tools';
  dynamic get no_tools_registered => 'No Tools Registered';
  dynamic get no_tools_registered_desc => 'Connect an MCP server to add tools.';
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
  dynamic get model_favorite_toggle => 'Favourite';
  dynamic get model_note_label => 'Model Note';
  dynamic get model_note_hint => 'Anything worth remembering about this model';
  dynamic get unload_models_before_load => 'Unload Models Before Load';
  dynamic get export_all_data => 'Export everything';
  dynamic get import_all_data => 'Import everything';
  dynamic get export_data_success => 'Data exported';
  dynamic get import_data_success => 'Data imported';
  dynamic get import_data_confirm => 'Import Data Confirm';
  dynamic get import_settings_confirm => 'Import Settings Confirm';
  dynamic get export_conversations => 'Export Conversations';
  dynamic get import_conversations => 'Import Conversations';
  dynamic get export_personas => 'Export Personas';
  dynamic get import_personas => 'Import Personas';
  dynamic get export_settings => 'Export Settings';
  dynamic get import_settings => 'Import Settings';
  dynamic get export_all_zip => 'Export everything as a ZIP';
  dynamic get import_all_zip => 'Import everything from a ZIP';
  dynamic get duplicate_chat => 'Duplicate chat';
  dynamic get duplicate_chat_success => 'Chat duplicated';
  dynamic get move_to_folder => 'Move to folder';
  dynamic get remove_from_folder => 'Remove from folder';
  dynamic get create_folder => 'Create Folder';
  dynamic get new_folder => 'New Folder';
  dynamic get folder_name_hint => 'Folder name';
  dynamic get all_chats => 'All Chats';
  dynamic get unfiled_chats => 'Unfiled Chats';
  dynamic get create => 'Create';
  dynamic get server_path_prefix_label => 'Server Path Prefix';
  dynamic get server_path_prefix_hint => '/v1';
  dynamic get search_message_contents => 'Search inside messages';
  dynamic get message_search_results => 'Matches in messages';
  dynamic get saved_messages_title => 'Saved Messages';
  dynamic get nav_saved_messages => 'Saved Messages';
  dynamic get saved_messages_empty => 'Nothing saved yet';
  dynamic get save_message => 'Save Message';
  dynamic get message_saved => 'Message Saved';
  dynamic get test_tts_section_title => 'Try the voice';
  dynamic get test_tts_hint => 'Type something to hear it read aloud';
  dynamic get test_speak_button => 'Speak';
  static final AppLocalizations _instance = AppLocalizations('en');
  static dynamic of(dynamic context) => _instance;
  dynamic delete_model_body(dynamic name) => 'Delete? This cannot be undone.';
  dynamic delete_model_body_with_size(dynamic name, dynamic size) => 'Delete Model Body with Size';
  dynamic delete_voice_body(dynamic name, dynamic size) => 'Delete voice body';
  dynamic delete_server_body(dynamic name) => 'Delete? This cannot be undone.';
  dynamic delete_conversation_body(dynamic title) => 'Delete? This cannot be undone.';
  dynamic delete_persona_title(dynamic name) => 'Delete Persona Title';
  dynamic label_completed(dynamic label) => 'Label Completed';
  dynamic error_with_message(dynamic error) => 'Error With Message';
  dynamic preview_failed(dynamic error) => 'Preview Failed';
  dynamic loading_model(dynamic modelId) => 'Loading Model';
  dynamic model_loaded(dynamic modelId, dynamic backend) => 'Model Loaded';
  dynamic loading_model_error(dynamic error) => 'Loading Model Error';
  dynamic tool_label(dynamic toolCallId) => 'Tool Label';
  dynamic character_count(dynamic length) => 'Character Count';
  dynamic conversation_minutes_ago(dynamic minutes) => 'Conversation Minutes Ago';
  dynamic conversation_hours_ago(dynamic hours) => 'Conversation Hours Ago';
  dynamic conversation_days_ago(dynamic days) => 'Conversation Days Ago';
  dynamic conversation_date(dynamic month, dynamic day, dynamic year) => 'Conversation Date';
  dynamic setup_connection_desc(dynamic server) => 'Setup connection desc';
  dynamic ram_min_required(dynamic fileSize) => 'RAM Min Required';
  dynamic download_progress(dynamic percent, dynamic speed) => 'Download Progress';
  dynamic eta_label(dynamic eta) => 'Eta Label';
  dynamic paused_progress(dynamic percent) => 'Paused at%';
  dynamic ram_warning_body_download(dynamic ram, dynamic totalMemory) => 'RAM Warning Body Download';
  dynamic ram_warning_body_load(dynamic availableRAM, dynamic ram) => 'RAM Warning Body Load';
  dynamic switched_to_server(dynamic name) => 'Switched to';
  dynamic server_address_format(dynamic host, dynamic port) => 'Server Address Format';
  dynamic character_count_max(dynamic currentLen) => 'Character Count Max';
  dynamic tts_kitten_desc(dynamic size) => 'TTS kitten desc';
  dynamic tts_piper_desc(dynamic size) => 'TTS piper desc';
  dynamic engine_spec(dynamic sizeMb, dynamic ramMb, dynamic voiceCount) => 'Engine Spec';
  dynamic ram_used(dynamic percent) => '% of RAM in use';
  dynamic no_models_match(dynamic searchQuery) => 'No Models Match';
  dynamic model_load_failed(dynamic error) => 'Model Load Failed';
  dynamic model_unloaded_ollama(dynamic name) => 'Model Unloaded Ollama';
  dynamic model_unloaded_success(dynamic name) => 'Model Unloaded Success';
  dynamic model_unload_failed(dynamic error) => 'Model Unload Failed';
  dynamic context_chip(dynamic ctx) => 'Context Chip';
  dynamic loaded_models_count(dynamic count) => 'Models loaded';
  dynamic switch_to_model(dynamic modelName, dynamic model) => 'Switch to Model';
  dynamic download_notification_title(dynamic modelName) => 'Download Notification';
  dynamic download_complete_body(dynamic modelName) => 'Download complete body';
  dynamic download_failed_notification(dynamic error) => 'Download Failed Notification';
  dynamic download_failed_body(dynamic modelName) => 'Download failed body';
  dynamic export_header(dynamic date) => 'Exported on';
  dynamic import_data_failed(dynamic error) => 'Import Data Failed';
  dynamic token_count(dynamic count) => 'Token Count';
  dynamic estimated_token_count(dynamic count) => 'Estimated Token Count';
  dynamic get scroll_to_bottom => 'Scroll to Bottom';
  dynamic get generate_ai_response => 'Generate a reply';
  dynamic get no_response => 'No reply';
  dynamic get export => 'Export';
  dynamic get import => 'Import';
  dynamic get conversations_label => 'Conversations';
  dynamic get personas_label => 'Personas';
  dynamic get settings_label => 'Settings';
  dynamic get export_conversation => 'Export conversation';
  dynamic get tts_process_markdown => 'Clean up Markdown before speaking';
  dynamic get tts_process_markdown_desc => 'TTS process markdown desc';
  dynamic get preview_system_prompts => 'Preview System Prompts';
  dynamic get welcome_message_1 => 'What can I help you with today?';
  dynamic get welcome_message_2 => 'Ask me anything.';
  dynamic get welcome_message_3 => 'Where should we start?';
  dynamic get welcome_message_4 => 'Ready when you are.';
  dynamic get tts_skip_seconds => 'Skip interval';
  dynamic get tts_skip_seconds_desc => 'How far the skip buttons jump';
  dynamic get temporary_chat => 'Temporary Chat';
  dynamic get temporary_chat_desc => 'Temporary chat desc';
  dynamic get temporary_chat_banner => 'This chat will not be saved';
  dynamic get temporary_chat_save_warning_title => 'Temporary Chat Save Warning';
  dynamic get temporary_chat_save_warning_body => 'Temporary chat save warning body';
  dynamic get save_to_history => 'Save to History';
  dynamic get share_conversation => 'Share Conversation';
  dynamic get download_tts_audio => 'Download audio';
  dynamic get tts_download_unavailable => 'This engine cannot export audio';
  dynamic get tts_download_no_audio => 'There is no audio to save';
  dynamic get tts_download_success => 'Audio saved';
  dynamic get return_to_chat => 'Back to chat';
  dynamic get return_to_temp_chat => 'Back to the temporary chat';
  dynamic get insert_saved_message => 'Insert a saved message';
  dynamic get insert_saved_message_desc => 'Drop a saved message into the box.';
  dynamic get model_info => 'Model Info';
  dynamic get model_name => 'Model Name';
  dynamic get model_identifier => 'Identifier';
  dynamic get not_available => 'Not available';
  dynamic get save_message_folders => 'Save to folder';
  dynamic get remove_from_saved => 'Remove from Saved';
  dynamic get message_already_saved => 'Already saved';
  dynamic get stream_ttft => 'Time to first token';
  dynamic get stream_tokens_per_sec => 'Tokens per second';
  dynamic get stream_stop_reason => 'Stop reason';
  dynamic get stream_input_tokens => 'Input tokens';
  dynamic get stream_output_tokens => 'Output tokens';
  dynamic get stream_generation_time => 'Generation time';
  dynamic get attach_image => 'Attach an image';
  dynamic get attach_text_document => 'Attach a text file';
  dynamic get add_attachment => 'Add Attachment';
  dynamic get photo_permission_denied => 'Photo access was denied';
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
  dynamic get generate_title_with_ai => 'Name this chat with AI';
  dynamic get generating_title => 'Generating';
  dynamic get generate_title_failed => 'Could not name the chat';
  dynamic tts_skip_seconds_value(dynamic seconds) => 'TTS Skip Seconds Value';
  dynamic conversation_message_count(dynamic count) => 'Conversation Message Count';
  dynamic conversation_character_count(dynamic count) => 'Conversation Character Count';
  dynamic get ai_user_response_enabled => 'Suggest my replies';
  dynamic get ai_user_response_tooltip => 'AI User Response';
  dynamic get delete_builtin_persona_body => 'Delete builtin persona body';
  dynamic get restore_builtin_personas => 'Restore built in personas';
  dynamic get restore_builtin_personas_desc => 'Restore builtin personas desc';
  dynamic get restore_builtin_personas_success => 'Built in personas restored';
  dynamic get clear_personas => 'Clear Personas';
  dynamic get enable_image_compression => 'Compress images';
  dynamic get enable_image_compression_desc => 'Enable image compression desc';
  dynamic get image_compression_level => 'Compression level';
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
  dynamic get smart_replies_use_persona => 'Smart replies follow the persona';
  dynamic get smart_replies_use_persona_desc => 'Smart replies use persona desc';
  dynamic get keep_persona_on_new_chat => 'Keep persona in new chats';
  dynamic get keep_persona_on_new_chat_desc => 'Keep persona on new chat desc';
  dynamic get role_swap_button_enabled => 'Show the role swap button';
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
  dynamic get personas_combine_hint => 'Personas stack with the system prompt.';
  dynamic get temp_chat_keyboard_incognito => 'Incognito keyboard';
  dynamic get temp_chat_keyboard_incognito_desc => 'Temp chat keyboard incognito desc';
  dynamic get resume_last_chat => 'Resume the last chat';
  dynamic get resume_last_chat_desc => 'Resume last chat desc';
  dynamic get lm_studio_model_browser_title => 'Lm Studio Model Browser';
  dynamic get lm_studio_model_search_hint => 'Search LM Studio';
  dynamic get lm_studio_staff_picks => 'Staff picks';
  dynamic get lm_studio_community_models => 'Community models';
  dynamic get lm_studio_no_models => 'No models found';
  dynamic get lm_studio_browse_models => 'Browse models';
  dynamic get lm_studio_model_search => 'Search models';
  dynamic get lm_studio_downloads_title => 'Lm Studio Downloads';
  dynamic get lm_studio_choose_quant => 'Choose a quantisation';
  dynamic get lm_studio_use_default_quant => 'Use the recommended quantisation';
  dynamic get lm_studio_recommended => 'Recommended';
  dynamic get lm_studio_clear_downloads => 'Clear downloads';
  dynamic get lm_studio_no_downloads => 'No downloads yet';
  dynamic get lm_studio_downloads_disclaimer => 'Lm studio downloads disclaimer';
  dynamic get lm_studio_staff_pick => 'Staff pick';
  dynamic get lm_studio_params => 'Parameters';
  dynamic get lm_studio_arch => 'Architecture';
  dynamic get lm_studio_domain => 'Domain';
  dynamic get lm_studio_format => 'Format';
  dynamic get lm_studio_vision => 'Vision';
  dynamic get lm_studio_tool_use => 'Tool use';
  dynamic get lm_studio_reasoning => 'Reasoning';
  dynamic get lm_studio_download_options => 'Download options';
  dynamic get lm_studio_download => 'Download';
  dynamic get lm_studio_readme_unavailable => 'No README available';
  dynamic get lm_studio_full_gpu_offload => 'Fits fully on the GPU';
  dynamic get lm_studio_partial_gpu_offload => 'Partly on the GPU';
  dynamic get lm_studio_likely_too_large => 'Likely too large for this machine';
  dynamic get lm_studio_available_ram_gb => 'Available memory in GB';
  dynamic get lm_studio_available_vram_gb => 'Available video memory in GB';
  dynamic get lm_studio_memory_settings_title => 'Lm Studio Memory Settings';
  dynamic get lm_studio_memory_settings_desc => 'Lm studio memory settings desc';
  dynamic get think_button_label => 'Think Button';
  dynamic get reasoning_effort_low => 'Low';
  dynamic get reasoning_effort_medium => 'Medium';
  dynamic get reasoning_effort_high => 'High';
  dynamic bulk_ai_rename_progress(dynamic done, dynamic total) => 'Of renamed';
  dynamic selected_count(dynamic count) => 'Selected Count';
  dynamic total_tokens_count(dynamic count) => 'Total Tokens Count';
  dynamic bulk_export_conversations_success(dynamic count) => 'Bulk Export Conversations Success';
  dynamic bulk_ai_rename_confirm_body(dynamic count) => 'Bulk AI rename confirm body';
  dynamic lm_studio_models_count(dynamic count) => 'LM Studio Models Count';
  dynamic lm_studio_download_size(dynamic size) => 'LM Studio Download Size';
  dynamic lm_studio_downloading_percent(dynamic percent) => 'LM Studio Downloading Percent';
  dynamic get could_not_read_file => 'Could not read that file';
  dynamic get server_offline => 'Server Offline';
  dynamic get could_not_establish_connection => 'Could not reach the server';
  dynamic get retry_connection => 'Try again';
  dynamic get tokens_label => 'Tokens';
  dynamic get enter_context_length => 'Enter a context length';
}

class ConsumerState<WidgetT> {
  ConsumerState();
  dynamic get ref => WidgetRef();
}

class ShadButton extends StatelessWidget {
  final dynamic child;
  const ShadButton({
    super.key,
    this.child,
    dynamic leading,
    dynamic trailing,
    dynamic onPressed,
    dynamic size,
    dynamic cursor,
    dynamic width,
    dynamic height,
    dynamic padding,
    dynamic backgroundColor,
    dynamic hoverBackgroundColor,
    dynamic foregroundColor,
    dynamic hoverForegroundColor,
    dynamic autofocus,
    dynamic focusNode,
    dynamic pressedBackgroundColor,
    dynamic pressedForegroundColor,
    dynamic shadows,
    dynamic gradient,
    dynamic textDecoration,
    dynamic hoverTextDecoration,
    dynamic decoration,
    dynamic enabled,
    dynamic onLongPress,
    dynamic statesController,
    dynamic mainAxisAlignment,
    dynamic crossAxisAlignment,
    dynamic hoverStrategies,
    dynamic onHoverChange,
    dynamic onTapDown,
    dynamic onTapUp,
    dynamic onTapCancel,
    dynamic onSecondaryTapDown,
    dynamic onSecondaryTapUp,
    dynamic onSecondaryTapCancel,
    dynamic onLongPressStart,
    dynamic onLongPressCancel,
    dynamic onLongPressUp,
    dynamic onLongPressDown,
    dynamic onLongPressEnd,
    dynamic onDoubleTap,
    dynamic onDoubleTapDown,
    dynamic onDoubleTapCancel,
    dynamic longPressDuration,
    dynamic textDirection,
    dynamic gap,
    dynamic onFocusChange,
    dynamic expands,
    dynamic textStyle,
    dynamic canRequestFocus,
  });
  const ShadButton.raw({
    super.key,
    dynamic variant,
    dynamic size,
    this.child,
    dynamic leading,
    dynamic trailing,
    dynamic onPressed,
    dynamic cursor,
    dynamic width,
    dynamic height,
    dynamic padding,
    dynamic backgroundColor,
    dynamic hoverBackgroundColor,
    dynamic foregroundColor,
    dynamic hoverForegroundColor,
    dynamic autofocus,
    dynamic focusNode,
    dynamic pressedBackgroundColor,
    dynamic pressedForegroundColor,
    dynamic shadows,
    dynamic gradient,
    dynamic textDecoration,
    dynamic hoverTextDecoration,
    dynamic decoration,
    dynamic enabled,
    dynamic onLongPress,
    dynamic statesController,
    dynamic mainAxisAlignment,
    dynamic crossAxisAlignment,
    dynamic hoverStrategies,
    dynamic onHoverChange,
    dynamic onTapDown,
    dynamic onTapUp,
    dynamic onTapCancel,
    dynamic onSecondaryTapDown,
    dynamic onSecondaryTapUp,
    dynamic onSecondaryTapCancel,
    dynamic onLongPressStart,
    dynamic onLongPressCancel,
    dynamic onLongPressUp,
    dynamic onLongPressDown,
    dynamic onLongPressEnd,
    dynamic onDoubleTap,
    dynamic onDoubleTapDown,
    dynamic onDoubleTapCancel,
    dynamic longPressDuration,
    dynamic textDirection,
    dynamic gap,
    dynamic onFocusChange,
    dynamic expands,
    dynamic textStyle,
    dynamic canRequestFocus,
  });
  const ShadButton.destructive({
    super.key,
    this.child,
    dynamic leading,
    dynamic trailing,
    dynamic onPressed,
    dynamic size,
    dynamic cursor,
    dynamic width,
    dynamic height,
    dynamic padding,
    dynamic backgroundColor,
    dynamic hoverBackgroundColor,
    dynamic foregroundColor,
    dynamic hoverForegroundColor,
    dynamic autofocus,
    dynamic focusNode,
    dynamic pressedBackgroundColor,
    dynamic pressedForegroundColor,
    dynamic shadows,
    dynamic gradient,
    dynamic textDecoration,
    dynamic hoverTextDecoration,
    dynamic decoration,
    dynamic enabled,
    dynamic onLongPress,
    dynamic statesController,
    dynamic mainAxisAlignment,
    dynamic crossAxisAlignment,
    dynamic hoverStrategies,
    dynamic onHoverChange,
    dynamic onTapDown,
    dynamic onTapUp,
    dynamic onTapCancel,
    dynamic onSecondaryTapDown,
    dynamic onSecondaryTapUp,
    dynamic onSecondaryTapCancel,
    dynamic onLongPressStart,
    dynamic onLongPressCancel,
    dynamic onLongPressUp,
    dynamic onLongPressDown,
    dynamic onLongPressEnd,
    dynamic onDoubleTap,
    dynamic onDoubleTapDown,
    dynamic onDoubleTapCancel,
    dynamic longPressDuration,
    dynamic textDirection,
    dynamic gap,
    dynamic onFocusChange,
    dynamic expands,
    dynamic textStyle,
    dynamic canRequestFocus,
  });
  const ShadButton.outline({
    super.key,
    this.child,
    dynamic leading,
    dynamic trailing,
    dynamic onPressed,
    dynamic size,
    dynamic cursor,
    dynamic width,
    dynamic height,
    dynamic padding,
    dynamic backgroundColor,
    dynamic hoverBackgroundColor,
    dynamic foregroundColor,
    dynamic hoverForegroundColor,
    dynamic autofocus,
    dynamic focusNode,
    dynamic pressedBackgroundColor,
    dynamic pressedForegroundColor,
    dynamic shadows,
    dynamic gradient,
    dynamic textDecoration,
    dynamic hoverTextDecoration,
    dynamic decoration,
    dynamic enabled,
    dynamic onLongPress,
    dynamic statesController,
    dynamic mainAxisAlignment,
    dynamic crossAxisAlignment,
    dynamic hoverStrategies,
    dynamic onHoverChange,
    dynamic onTapDown,
    dynamic onTapUp,
    dynamic onTapCancel,
    dynamic onSecondaryTapDown,
    dynamic onSecondaryTapUp,
    dynamic onSecondaryTapCancel,
    dynamic onLongPressStart,
    dynamic onLongPressCancel,
    dynamic onLongPressUp,
    dynamic onLongPressDown,
    dynamic onLongPressEnd,
    dynamic onDoubleTap,
    dynamic onDoubleTapDown,
    dynamic onDoubleTapCancel,
    dynamic longPressDuration,
    dynamic textDirection,
    dynamic gap,
    dynamic onFocusChange,
    dynamic expands,
    dynamic textStyle,
    dynamic canRequestFocus,
  });
  const ShadButton.secondary({
    super.key,
    this.child,
    dynamic leading,
    dynamic trailing,
    dynamic onPressed,
    dynamic size,
    dynamic cursor,
    dynamic width,
    dynamic height,
    dynamic padding,
    dynamic backgroundColor,
    dynamic hoverBackgroundColor,
    dynamic foregroundColor,
    dynamic hoverForegroundColor,
    dynamic autofocus,
    dynamic focusNode,
    dynamic pressedBackgroundColor,
    dynamic pressedForegroundColor,
    dynamic shadows,
    dynamic gradient,
    dynamic textDecoration,
    dynamic hoverTextDecoration,
    dynamic decoration,
    dynamic enabled,
    dynamic onLongPress,
    dynamic statesController,
    dynamic mainAxisAlignment,
    dynamic crossAxisAlignment,
    dynamic hoverStrategies,
    dynamic onHoverChange,
    dynamic onTapDown,
    dynamic onTapUp,
    dynamic onTapCancel,
    dynamic onSecondaryTapDown,
    dynamic onSecondaryTapUp,
    dynamic onSecondaryTapCancel,
    dynamic onLongPressStart,
    dynamic onLongPressCancel,
    dynamic onLongPressUp,
    dynamic onLongPressDown,
    dynamic onLongPressEnd,
    dynamic onDoubleTap,
    dynamic onDoubleTapDown,
    dynamic onDoubleTapCancel,
    dynamic longPressDuration,
    dynamic textDirection,
    dynamic gap,
    dynamic onFocusChange,
    dynamic expands,
    dynamic textStyle,
    dynamic canRequestFocus,
  });
  const ShadButton.ghost({
    super.key,
    this.child,
    dynamic leading,
    dynamic trailing,
    dynamic onPressed,
    dynamic size,
    dynamic cursor,
    dynamic width,
    dynamic height,
    dynamic padding,
    dynamic backgroundColor,
    dynamic hoverBackgroundColor,
    dynamic foregroundColor,
    dynamic hoverForegroundColor,
    dynamic autofocus,
    dynamic focusNode,
    dynamic pressedBackgroundColor,
    dynamic pressedForegroundColor,
    dynamic shadows,
    dynamic gradient,
    dynamic textDecoration,
    dynamic hoverTextDecoration,
    dynamic decoration,
    dynamic enabled,
    dynamic onLongPress,
    dynamic statesController,
    dynamic mainAxisAlignment,
    dynamic crossAxisAlignment,
    dynamic hoverStrategies,
    dynamic onHoverChange,
    dynamic onTapDown,
    dynamic onTapUp,
    dynamic onTapCancel,
    dynamic onSecondaryTapDown,
    dynamic onSecondaryTapUp,
    dynamic onSecondaryTapCancel,
    dynamic onLongPressStart,
    dynamic onLongPressCancel,
    dynamic onLongPressUp,
    dynamic onLongPressDown,
    dynamic onLongPressEnd,
    dynamic onDoubleTap,
    dynamic onDoubleTapDown,
    dynamic onDoubleTapCancel,
    dynamic longPressDuration,
    dynamic textDirection,
    dynamic gap,
    dynamic onFocusChange,
    dynamic expands,
    dynamic textStyle,
    dynamic canRequestFocus,
  });
  const ShadButton.link({
    super.key,
    this.child,
    dynamic onPressed,
    dynamic size,
    dynamic cursor,
    dynamic width,
    dynamic height,
    dynamic padding,
    dynamic backgroundColor,
    dynamic hoverBackgroundColor,
    dynamic foregroundColor,
    dynamic hoverForegroundColor,
    dynamic autofocus,
    dynamic focusNode,
    dynamic pressedBackgroundColor,
    dynamic pressedForegroundColor,
    dynamic shadows,
    dynamic gradient,
    dynamic textDecoration,
    dynamic hoverTextDecoration,
    dynamic decoration,
    dynamic enabled,
    dynamic onLongPress,
    dynamic statesController,
    dynamic mainAxisAlignment,
    dynamic crossAxisAlignment,
    dynamic hoverStrategies,
    dynamic onHoverChange,
    dynamic onTapDown,
    dynamic onTapUp,
    dynamic onTapCancel,
    dynamic onSecondaryTapDown,
    dynamic onSecondaryTapUp,
    dynamic onSecondaryTapCancel,
    dynamic onLongPressStart,
    dynamic onLongPressCancel,
    dynamic onLongPressUp,
    dynamic onLongPressDown,
    dynamic onLongPressEnd,
    dynamic onDoubleTap,
    dynamic onDoubleTapDown,
    dynamic onDoubleTapCancel,
    dynamic longPressDuration,
    dynamic textDirection,
    dynamic gap,
    dynamic onFocusChange,
    dynamic expands,
    dynamic leading,
    dynamic trailing,
    dynamic textStyle,
    dynamic canRequestFocus,
  });
  @override
  Widget build(BuildContext context) =>
      child is Widget ? child as Widget : const SizedBox.shrink();
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
