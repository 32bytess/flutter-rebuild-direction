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
  AppLocalizations(dynamic locale);
  dynamic get localeName => 'en';
  static const dynamic delegate = null;
  static const dynamic localizationsDelegates = null;
  static const dynamic supportedLocales = null;
  dynamic get app_name => 'LocalMind';
  dynamic get app_tagline => 'Private AI chat, on your own hardware';
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
  dynamic get start_new_chat => 'Start a new chat';
  dynamic get cannot_undo => 'This action cannot be undone';
  dynamic get ram_warning => 'This model may not fit in available memory';
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
  dynamic get preparing_app => 'Preparing the app...';
  dynamic get initializing_services => 'Initializing services...';
  dynamic get configuring_server => 'Configuring server...';
  dynamic get startup_failed => 'The app failed to start';
  dynamic get something_went_wrong => 'Something went wrong';
  dynamic get delete_model_title => 'Delete model?';
  dynamic get delete_voice_title => 'Delete voice?';
  dynamic get delete_server_title => 'Delete server?';
  dynamic get delete_conversation_title => 'Delete conversation?';
  dynamic get delete_message_title => 'Delete message?';
  dynamic get delete_persona_body =>
      'This persona will be removed from every chat that uses it.';
  dynamic get clear_conversation_title => 'Clear conversation?';
  dynamic get clear_conversation_body =>
      'Every message in this chat will be removed.';
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
  dynamic get search_hint => 'Search conversations';
  dynamic get no_server_selected => 'No server selected';
  dynamic get switch_server => 'Switch server';
  dynamic get switch_server_subtitle => 'Pick which backend answers this chat';
  dynamic get manage_servers => 'Manage servers';
  dynamic get open_source => 'Open source';
  dynamic get open_source_desc =>
      'LocalMind is free software and the code is public.';
  dynamic get star_on_github => 'Star on GitHub';
  dynamic get add_more => 'Add more';
  dynamic get on_github => 'On GitHub';
  dynamic get could_not_open_github => 'Could not open GitHub';
  dynamic get settings_title => 'Settings';
  dynamic get settings_appearance => 'Appearance';
  dynamic get settings_language => 'Language';
  dynamic get language_system_default => 'System default';
  dynamic get settings_tts => 'Text to speech';
  dynamic get settings_behavior => 'Behavior';
  dynamic get settings_on_device => 'On device models';
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
  dynamic get font_size_desc => 'Set the text size used across chats';
  dynamic get font_preview => 'The quick brown fox jumps over the lazy dog';
  dynamic get code_theme_dark => 'Dark code theme';
  dynamic get code_theme_light => 'Light code theme';
  dynamic get code_theme_desc =>
      'Colour scheme used for code blocks in replies';
  dynamic get tts_engine => 'Speech engine';
  dynamic get tts_engine_system => 'System engine';
  dynamic get tts_engine_kitten => 'Kitten TTS';
  dynamic get voice => 'Voice';
  dynamic get voice_female => 'Female';
  dynamic get voice_male => 'Male';
  dynamic get voice_other => 'Other';
  dynamic get tts_speed => 'Speech rate';
  dynamic get tts_speed_desc => 'How fast replies are read aloud';
  dynamic get manage_tts_models => 'Manage voice models';
  dynamic get manage_on_device_models => 'Manage on device models';
  dynamic get enable_smart_reply => 'Smart replies';
  dynamic get streaming_responses => 'Stream responses';
  dynamic get auto_generate_titles => 'Generate chat titles automatically';
  dynamic get send_on_enter => 'Send on Enter';
  dynamic get show_system_messages => 'Show system messages';
  dynamic get haptic_feedback => 'Haptic feedback';
  dynamic get enable_mcp => 'Enable MCP integrations';
  dynamic get new_chat_mcp_default => 'Enable MCP in new chats';
  dynamic get show_data_indicator => 'Show network activity indicator';
  dynamic get privacy_info =>
      'Conversations stay on this device unless you export them.';
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
  dynamic get quick_write => 'Write something';
  dynamic get quick_explain => 'Explain this';
  dynamic get quick_debug => 'Debug my code';
  dynamic get quick_async => 'Explain async in Dart';
  dynamic get history_missing_title => 'Conversation not found';
  dynamic get history_missing_desc =>
      'This chat is no longer stored on this device.';
  dynamic get technical_details => 'Technical details';
  dynamic get last_error => 'Last error';
  dynamic get copy_info => 'Copy details';
  dynamic get conversation_id => 'Conversation ID';
  dynamic get created_at => 'Created';
  dynamic get expected_messages => 'Expected messages';
  dynamic get debug_dialog_desc =>
      'Details that help diagnose a broken conversation.';
  dynamic get chat_input_hint => 'Send a message';
  dynamic get send_message_tooltip => 'Send message';
  dynamic get stop_generation_tooltip => 'Stop generating';
  dynamic get attach_images_tooltip => 'Attach images';
  dynamic get start_listening_tooltip => 'Start voice input';
  dynamic get stop_listening_tooltip => 'Stop voice input';
  dynamic get tool_unknown => 'Unknown tool';
  dynamic get message_options => 'Message options';
  dynamic get copy_markdown => 'Copy as Markdown';
  dynamic get copied_markdown => 'Markdown copied';
  dynamic get read_aloud => 'Read aloud';
  dynamic get stop_reading => 'Stop reading';
  dynamic get more => 'More';
  dynamic get edit_message => 'Edit message';
  dynamic get edit_message_desc =>
      'Editing this message discards the replies after it.';
  dynamic get save_regenerate => 'Save and regenerate';
  dynamic get chat_settings_title => 'Chat settings';
  dynamic get reset_defaults => 'Reset to defaults';
  dynamic get parameters_tab => 'Parameters';
  dynamic get mcp_tab => 'Integrations';
  dynamic get temperature => 'Temperature';
  dynamic get temperature_desc => 'Higher values make replies more varied';
  dynamic get top_p => 'Top P';
  dynamic get top_p_desc => 'Limits sampling to the most likely tokens';
  dynamic get max_tokens => 'Max tokens';
  dynamic get max_tokens_desc => 'Upper bound on the length of a reply';
  dynamic get context_length => 'Context length';
  dynamic get context_length_desc =>
      'How much of the chat the model can see at once';
  dynamic get mcp_disabled_warning =>
      'MCP integrations are turned off in settings.';
  dynamic get mcp_enable_chat => 'Enable MCP for this chat';
  dynamic get auto_execute_tools => 'Run tools without asking';
  dynamic get beta_label => 'Beta';
  dynamic get experimental_label => 'Experimental';
  dynamic get add_ephemeral_mcp => 'Add a temporary MCP server';
  dynamic get mcp_label_placeholder => 'My MCP server';
  dynamic get mcp_url_placeholder => 'https://example.com/mcp';
  dynamic get active_integrations => 'Active integrations';
  dynamic get enable_notifications => 'Enable notifications';
  dynamic get enable_notifications_desc =>
      'Get told when a download or a reply finishes';
  dynamic get chat_history_title => 'Chat history';
  dynamic get conversation_just_now => 'Just now';
  dynamic get conversation_yesterday => 'Yesterday';
  dynamic get options_tooltip => 'Options';
  dynamic get no_results_found => 'No results found';
  dynamic get no_conversations_yet => 'No conversations yet';
  dynamic get try_different_search => 'Try a different search term';
  dynamic get start_new_conversation => 'Start a new conversation';
  dynamic get rename_conversation => 'Rename conversation';
  dynamic get enter_new_title => 'Enter a new title';
  dynamic get pinned_section => 'Pinned';
  dynamic get today_section => 'Today';
  dynamic get yesterday_section => 'Yesterday';
  dynamic get previous_7_days => 'Previous 7 days';
  dynamic get previous_30_days => 'Previous 30 days';
  dynamic get older_section => 'Older';
  dynamic get onboarding_choose_language => 'Choose your language';
  dynamic get onboarding_choose_language_desc =>
      'You can change this later in settings.';
  dynamic get onboarding_localmind => 'Welcome to LocalMind';
  dynamic get onboarding_connect_server => 'Connect a server';
  dynamic get onboarding_connect_desc =>
      'Point the app at a model server you control.';
  dynamic get openai_compatible_api => 'OpenAI compatible API';
  dynamic get https_requires_ssl => 'HTTPS requires a valid certificate';
  dynamic get most_local_setups_use_http => 'Most local setups use HTTP';
  dynamic get onboarding_welcome => 'Welcome';
  dynamic get server_type_on_device => 'On device';
  dynamic get server_type_lm_studio => 'LM Studio';
  dynamic get server_type_ollama => 'Ollama';
  dynamic get server_type_openrouter => 'OpenRouter';
  dynamic get server_type_openrouter_sub => 'Hosted models, bring your own key';
  dynamic get ready_continue => 'Ready to continue';
  dynamic get waiting_selection => 'Pick an option to continue';
  dynamic get setup_connection => 'Set up the connection';
  dynamic get server_name => 'Server name';
  dynamic get name_required => 'A name is required';
  dynamic get name_max_50 => 'Use at most 50 characters';
  dynamic get host_label => 'Host';
  dynamic get host_required => 'A host is required';
  dynamic get port_label => 'Port';
  dynamic get port_required => 'A port is required';
  dynamic get port_invalid => 'Enter a valid port number';
  dynamic get port_range => 'Use a port between 1 and 65535';
  dynamic get api_key_required => 'An API key is required';
  dynamic get api_key_optional => 'API key (optional)';
  dynamic get api_key_required_openrouter => 'OpenRouter needs an API key';
  dynamic get api_key_format =>
      'Keys start with sk- followed by letters and digits';
  dynamic get my_server_hint => 'My server';
  dynamic get name_length_validation => 'Use between 2 and 50 characters';
  dynamic get host_valid => 'Host looks valid';
  dynamic get api_key_hint_openrouter => 'sk-or-v1-...';
  dynamic get api_key_hint_generic => 'sk-...';
  dynamic get update_server => 'Update server';
  dynamic get save_server => 'Save server';
  dynamic get server_updated => 'Server updated';
  dynamic get server_added => 'Server added';
  dynamic get download_model_title => 'Download a model';
  dynamic get download_model_desc =>
      'Models run entirely on this device once downloaded.';
  dynamic get on_device_android_only =>
      'On device models are Android only for now';
  dynamic get total_ram => 'Total memory';
  dynamic get available => 'Available';
  dynamic get choose_theme => 'Choose a theme';
  dynamic get choose_theme_desc => 'Pick how the app should look.';
  dynamic get theme_card_system => 'System';
  dynamic get theme_card_system_sub => 'Follow the device setting';
  dynamic get theme_card_light => 'Light';
  dynamic get theme_card_light_sub => 'Bright background';
  dynamic get theme_card_dark => 'Dark';
  dynamic get theme_card_dark_sub => 'Easier at night';
  dynamic get theme_card_claude => 'Claude';
  dynamic get theme_card_claude_sub => 'Warm, paper like tones';
  dynamic get stay_updated => 'Stay updated';
  dynamic get stay_updated_desc =>
      'Turn on notifications so long jobs can finish in the background.';
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
  dynamic get server_address_openrouter => 'openrouter.ai/api/v1';
  dynamic get server_address_on_device => 'Runs on this device';
  dynamic get default_badge => 'Default';
  dynamic get set_as_default => 'Set as default';
  dynamic get select_icon => 'Select an icon';
  dynamic get select_icon_desc => 'Pick the icon shown next to this server.';
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
  dynamic get server_icon_plug1 => 'Plug 1';
  dynamic get server_icon_plug2 => 'Plug 2';
  dynamic get server_icon_bot => 'Bot';
  dynamic get server_icon_bot2 => 'Bot 2';
  dynamic get server_icon_robotic => 'Robotic';
  dynamic get server_icon_rocket => 'Rocket';
  dynamic get server_icon_star => 'Star';
  dynamic get server_icon_settings1 => 'Settings 1';
  dynamic get server_icon_settings2 => 'Settings 2';
  dynamic get server_icon_home1 => 'Home 1';
  dynamic get server_icon_home2 => 'Home 2';
  dynamic get server_icon_folder1 => 'Folder 1';
  dynamic get server_icon_folder2 => 'Folder 2';
  dynamic get server_icon_file1 => 'File 1';
  dynamic get server_icon_lock => 'Lock';
  dynamic get server_icon_key => 'Key';
  dynamic get server_icon_link => 'Link';
  dynamic get server_icon_globe => 'Globe';
  dynamic get server_icon_api => 'API';
  dynamic get server_icon_arrow_right => 'Arrow right';
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
  dynamic get no_personas_desc => 'Create one to give the model a fixed style.';
  dynamic get edit_persona => 'Edit persona';
  dynamic get create_persona => 'Create persona';
  dynamic get create_persona_button => 'Create persona';
  dynamic get emoji_label => 'Emoji';
  dynamic get name_label => 'Name';
  dynamic get my_persona_hint => 'My persona';
  dynamic get category_label => 'Category';
  dynamic get description_optional => 'Description (optional)';
  dynamic get description_hint => 'A short summary of what this persona does';
  dynamic get system_prompt => 'System prompt';
  dynamic get no_prompt_placeholder => 'No system prompt set';
  dynamic get prompt_hint =>
      'You are a helpful assistant that answers concisely.';
  dynamic get prompt_required => 'A system prompt is required';
  dynamic get prompt_max_chars => 'Use at most 4000 characters';
  dynamic get advanced_settings => 'Advanced settings';
  dynamic get temperature_label => 'Temperature';
  dynamic get top_p_label => 'Top P';
  dynamic get temp_hint => '0.7';
  dynamic get top_p_hint => '0.9';
  dynamic get range_0_2 => 'Between 0 and 2';
  dynamic get range_0_1 => 'Between 0 and 1';
  dynamic get persona_updated => 'Persona updated';
  dynamic get persona_created => 'Persona created';
  dynamic get tts_models_title => 'Voice models';
  dynamic get always_available => 'Always available';
  dynamic get tts_system_desc => 'Uses the voice engine built into the device.';
  dynamic get downloading_status => 'Downloading...';
  dynamic get on_device_models_title => 'On device models';
  dynamic get settings_huggingface_token => 'Hugging Face token';
  dynamic get settings_huggingface_token_desc =>
      'Needed for gated repositories';
  dynamic get settings_huggingface_token_set => 'Token saved';
  dynamic get settings_huggingface_token_cleared => 'Token cleared';
  dynamic get model_requires_huggingface_token =>
      'This model needs a Hugging Face token';
  dynamic get model_missing_huggingface_token => 'No Hugging Face token saved';
  dynamic get set_huggingface_token => 'Set token';
  dynamic get clear_huggingface_token => 'Clear token';
  dynamic get edit_huggingface_token_dialog_title => 'Hugging Face token';
  dynamic get huggingface_token_dialog_hint => 'hf_...';
  dynamic get server_type_ollama_desc =>
      'Talk to an Ollama instance on your network.';
  dynamic get server_type_on_device_desc =>
      'Run a downloaded model on this phone.';
  dynamic get server_type_lm_studio_desc =>
      'Talk to LM Studio over its local API.';
  dynamic get available_models => 'Available models';
  dynamic get device_memory => 'Device memory';
  dynamic get ram_usage => 'Memory in use';
  dynamic get memory_healthy => 'Memory healthy';
  dynamic get memory_critical => 'Memory critical';
  dynamic get memory_low => 'Memory low';
  dynamic get available_ram => 'Available memory';
  dynamic get total_capacity => 'Total capacity';
  dynamic get loaded_status => 'Loaded';
  dynamic get inference_backend => 'Inference backend';
  dynamic get backend_ios_notice => 'Only the CPU backend is available on iOS.';
  dynamic get backend_cpu_desc => 'Works everywhere, slowest option';
  dynamic get backend_gpu_desc => 'Faster, needs a supported GPU';
  dynamic get backend_npu_desc => 'Fastest, needs a supported neural engine';
  dynamic get select_model_title => 'Select a model';
  dynamic get refresh_models => 'Refresh models';
  dynamic get search_models_hint => 'Search models';
  dynamic get no_server_connected => 'No server connected';
  dynamic get add_server_first => 'Add a server first';
  dynamic get failed_load_models => 'Could not load models';
  dynamic get no_models_available => 'No models available';
  dynamic get unload_from_server => 'Unload from server';
  dynamic get unload_all_models => 'Unload all models';
  dynamic get all_models_unloaded => 'All models unloaded';
  dynamic get branch_chat => 'Branch chat';
  dynamic get branch_chat_desc =>
      'Continue from this message in a new conversation.';
  dynamic get edit_assistant_message_desc =>
      'Edit the reply without asking the model again.';
  dynamic get download_complete_notification => 'Download complete';
  dynamic get engine_name_system => 'System';
  dynamic get engine_tagline_system => 'Built into the device';
  dynamic get engine_name_kitten => 'Kitten';
  dynamic get engine_tagline_kitten => 'Small and quick';
  dynamic get engine_name_sherpa => 'Sherpa';
  dynamic get engine_tagline_sherpa => 'Natural sounding voices';
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
  dynamic get model_qwen_3 => 'Qwen 3 4B';
  dynamic get model_qwen_3_desc => 'Balanced general purpose model';
  dynamic get model_license_apache => 'Apache 2.0';
  dynamic get model_qwen_25 => 'Qwen 2.5 3B';
  dynamic get model_qwen_25_desc => 'Smaller and faster, good for chat';
  dynamic get model_deepseek => 'DeepSeek R1 Distill';
  dynamic get model_deepseek_desc => 'Strong at reasoning and code';
  dynamic get model_license_mit => 'MIT';
  dynamic get model_gemma => 'Gemma 2 2B';
  dynamic get model_gemma_desc => 'Very small, runs on modest hardware';
  dynamic get export_role_user => 'user';
  dynamic get export_role_assistant => 'assistant';
  dynamic get export_role_system => 'system';
  dynamic get export_role_tool => 'tool';
  dynamic get export_text_user => 'You said';
  dynamic get export_text_assistant => 'The assistant said';
  dynamic get export_text_system => 'System instruction';
  dynamic get export_text_tool => 'Tool output';
  dynamic get export_label_user => 'User';
  dynamic get export_label_assistant => 'Assistant';
  dynamic get export_label_system => 'System';
  dynamic get export_label_tool => 'Tool';
  dynamic get select_model_hint => 'Choose a model to chat with';
  dynamic get test_notification_title => 'Notifications work';
  dynamic get test_notification_body =>
      'This is what a LocalMind notification looks like.';
  dynamic get tts_supports_background => 'Playback continues in the background';
  dynamic get tts_other_services_background_note =>
      'Other engines stop when the app is closed.';
  dynamic get gguf_imported_models_title => 'Imported models';
  dynamic get gguf_imported_models_empty_subtitle =>
      'Import a GGUF file to see it here';
  dynamic get gguf_imported_models_ready => 'Ready to load';
  dynamic get gguf_curated_models_subtitle =>
      'Tested models that run well on phones';
  dynamic get gguf_only_supported => 'Only GGUF files are supported';
  dynamic get gguf_imported_from_local_file => 'Imported from a local file';
  dynamic get gguf_import_failed => 'Import failed';
  dynamic get gguf_imported_from_huggingface => 'Imported from Hugging Face';
  dynamic get gguf_import_canceled => 'Import cancelled';
  dynamic get gguf_enter_huggingface_url => 'Enter a Hugging Face URL';
  dynamic get gguf_only_official_huggingface_urls =>
      'Only huggingface.co links are accepted';
  dynamic get gguf_use_https_url => 'Use an HTTPS link';
  dynamic get gguf_url_must_point_to_file =>
      'The link must point at a GGUF file';
  dynamic get gguf_unable_to_detect_file_name =>
      'Could not work out the file name';
  dynamic get gguf_download_empty => 'The download was empty';
  dynamic get gguf_selected_file_missing =>
      'The selected file is no longer there';
  dynamic get gguf_import_action => 'Import';
  dynamic get gguf_overview_title => 'GGUF models';
  dynamic get gguf_overview_subtitle => 'Bring your own quantised model files';
  dynamic get gguf_imported_count_label => 'Imported';
  dynamic get gguf_local_files_label => 'Local files';
  dynamic get gguf_huggingface_label => 'Hugging Face';
  dynamic get gguf_import_local_title => 'Import from this device';
  dynamic get gguf_import_local_subtitle => 'Pick a GGUF file from storage';
  dynamic get gguf_import_huggingface_title => 'Import from Hugging Face';
  dynamic get gguf_import_huggingface_subtitle => 'Paste a link to a GGUF file';
  dynamic get gguf_no_imported_title => 'No imported models';
  dynamic get gguf_no_imported_subtitle => 'Anything you import shows up here.';
  dynamic get gguf_import_huggingface_dialog_title =>
      'Import from Hugging Face';
  dynamic get gguf_import_huggingface_dialog_subtitle =>
      'Paste a repository path or a file link.';
  dynamic get gguf_url_or_repo_path => 'URL or repository path';
  dynamic get paste => 'Paste';
  dynamic get gguf_browse => 'Browse';
  dynamic get gguf_huggingface_token_ready => 'Token ready';
  dynamic get gguf_huggingface_token_optional => 'Token optional';
  dynamic get gguf_huggingface_token_ready_desc =>
      'Gated repositories will work.';
  dynamic get gguf_huggingface_token_optional_desc =>
      'Add one only for gated repositories.';
  dynamic get gguf_downloading => 'Downloading';
  dynamic get gguf_preparing => 'Preparing';
  dynamic get gguf_preparing_download => 'Preparing download';
  dynamic get gguf_cancel_import => 'Cancel import';
  dynamic get clipboard_empty => 'The clipboard is empty';
  dynamic get could_not_open_huggingface => 'Could not open Hugging Face';
  dynamic get gguf_paste_url_error => 'That does not look like a link';
  dynamic get gguf_blob_link => 'Blob link detected';
  dynamic get gguf_repository_label => 'Repository';
  dynamic get gguf_detected_path_label => 'Detected path';
  dynamic get gguf_imported_section_label => 'Imported';
  dynamic get gguf_already_available => 'Already available';
  dynamic get gguf_curated_models_short => 'Curated';
  dynamic get execute_tool_title => 'Run this tool?';
  dynamic get execute_tool_request_desc =>
      'The assistant wants to run a tool on your behalf.';
  dynamic get reject => 'Reject';
  dynamic get approve => 'Approve';
  dynamic get server_type_help => 'Not sure which to pick?';
  dynamic get server_identity_title => 'Identity';
  dynamic get server_identity_desc => 'How this server is shown in the app.';
  dynamic get server_connection_title => 'Connection';
  dynamic get server_connection_desc => 'Where the app should send requests.';
  dynamic get server_authentication_title => 'Authentication';
  dynamic get server_authentication_required_desc =>
      'This server requires an API key.';
  dynamic get server_authentication_optional_desc =>
      'Add a key only if your server needs one.';
  dynamic get mcp_tools_title => 'Tools';
  dynamic get available_tools => 'Available tools';
  dynamic get unable_load_tools => 'Could not load tools';
  dynamic get no_tools_registered => 'No tools registered';
  dynamic get no_tools_registered_desc => 'Connect an MCP server to add tools.';
  dynamic get example_mcp_server_title => 'Example MCP server';
  dynamic get example_mcp_server_desc =>
      'A demo server with a couple of simple tools.';
  dynamic get disable_example_server => 'Disable example server';
  dynamic get enable_example_server => 'Enable example server';
  dynamic get built_in_label => 'Built in';
  dynamic get highlights_label => 'Highlights';
  dynamic get built_with_label => 'Built with';
  dynamic get local_label => 'Local';
  dynamic get gguf_format_label => 'GGUF';
  dynamic get tool_status_requested => 'Requested';
  dynamic get tool_status_approved => 'Approved';
  dynamic get tool_status_rejected => 'Rejected';
  dynamic get tool_status_running => 'Running';
  dynamic get tool_status_done => 'Done';
  dynamic get tool_status_failed => 'Failed';
  dynamic get model_favorite_toggle => 'Favourite';
  dynamic get model_note_label => 'Note';
  dynamic get model_note_hint => 'Anything worth remembering about this model';
  dynamic get unload_models_before_load =>
      'Unload a model before loading another';
  dynamic get export_all_data => 'Export everything';
  dynamic get import_all_data => 'Import everything';
  dynamic get export_data_success => 'Data exported';
  dynamic get import_data_success => 'Data imported';
  dynamic get import_data_confirm =>
      'Importing replaces the data already on this device.';
  dynamic get import_settings_confirm =>
      'Importing replaces your current settings.';
  dynamic get export_conversations => 'Export conversations';
  dynamic get import_conversations => 'Import conversations';
  dynamic get export_personas => 'Export personas';
  dynamic get import_personas => 'Import personas';
  dynamic get export_settings => 'Export settings';
  dynamic get import_settings => 'Import settings';
  dynamic get export_all_zip => 'Export everything as a ZIP';
  dynamic get import_all_zip => 'Import everything from a ZIP';
  dynamic get duplicate_chat => 'Duplicate chat';
  dynamic get duplicate_chat_success => 'Chat duplicated';
  dynamic get move_to_folder => 'Move to folder';
  dynamic get remove_from_folder => 'Remove from folder';
  dynamic get create_folder => 'Create folder';
  dynamic get new_folder => 'New folder';
  dynamic get folder_name_hint => 'Folder name';
  dynamic get all_chats => 'All chats';
  dynamic get unfiled_chats => 'Unfiled chats';
  dynamic get create => 'Create';
  dynamic get server_path_prefix_label => 'Path prefix';
  dynamic get server_path_prefix_hint => '/v1';
  dynamic get search_message_contents => 'Search inside messages';
  dynamic get message_search_results => 'Matches in messages';
  dynamic get saved_messages_title => 'Saved messages';
  dynamic get nav_saved_messages => 'Saved messages';
  dynamic get saved_messages_empty => 'Nothing saved yet';
  dynamic get save_message => 'Save message';
  dynamic get message_saved => 'Message saved';
  dynamic get test_tts_section_title => 'Try the voice';
  dynamic get test_tts_hint => 'Type something to hear it read aloud';
  dynamic get test_speak_button => 'Speak';
  // HAND-AUTHORED 2026-09-15. Was `=> null`, and every call site writes
  // `AppLocalizations.of(context)!` -- so the bang threw `Null check operator used on a null
  // value` inside `build` and the device drew Flutter's error box. The generator had already
  // reconstructed every string this class hands back; returning an instance is what lets the
  // transplant reach them.
  static dynamic of(dynamic context) => AppLocalizations(null);
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
  dynamic loaded_models_count(dynamic count) => '';
  dynamic switch_to_model(dynamic modelName, dynamic model) => '';
  dynamic download_notification_title(dynamic modelName) => '';
  dynamic download_complete_body(dynamic modelName) => '';
  dynamic download_failed_notification(dynamic error) => '';
  dynamic download_failed_body(dynamic modelName) => '';
  dynamic export_header(dynamic date) => '';
  dynamic import_data_failed(dynamic error) => '';
  dynamic token_count(dynamic count) => '';
  dynamic estimated_token_count(dynamic count) => '';
  dynamic get scroll_to_bottom => 'Scroll to bottom';
  dynamic get generate_ai_response => 'Generate a reply';
  dynamic get no_response => 'No reply';
  dynamic get export => 'Export';
  dynamic get import => 'Import';
  dynamic get conversations_label => 'Conversations';
  dynamic get personas_label => 'Personas';
  dynamic get settings_label => 'Settings';
  dynamic get export_conversation => 'Export conversation';
  dynamic get tts_process_markdown => 'Clean up Markdown before speaking';
  dynamic get tts_process_markdown_desc =>
      'Skips symbols and code fences when reading aloud';
  dynamic get preview_system_prompts => 'Preview system prompts';
  dynamic get welcome_message_1 => 'What can I help you with today?';
  dynamic get welcome_message_2 => 'Ask me anything.';
  dynamic get welcome_message_3 => 'Where should we start?';
  dynamic get welcome_message_4 => 'Ready when you are.';
  dynamic get tts_skip_seconds => 'Skip interval';
  dynamic get tts_skip_seconds_desc => 'How far the skip buttons jump';
  dynamic get temporary_chat => 'Temporary chat';
  dynamic get temporary_chat_desc =>
      'Nothing from this chat is written to history.';
  dynamic get temporary_chat_banner => 'This chat will not be saved';
  dynamic get temporary_chat_save_warning_title => 'Save this chat?';
  dynamic get temporary_chat_save_warning_body =>
      'It will be added to your history.';
  dynamic get save_to_history => 'Save to history';
  dynamic get share_conversation => 'Share conversation';
  dynamic get download_tts_audio => 'Download audio';
  dynamic get tts_download_unavailable => 'This engine cannot export audio';
  dynamic get tts_download_no_audio => 'There is no audio to save';
  dynamic get tts_download_success => 'Audio saved';
  dynamic get return_to_chat => 'Back to chat';
  dynamic get return_to_temp_chat => 'Back to the temporary chat';
  dynamic get insert_saved_message => 'Insert a saved message';
  dynamic get insert_saved_message_desc => 'Drop a saved message into the box.';
  dynamic get model_info => 'Model info';
  dynamic get model_name => 'Model name';
  dynamic get model_identifier => 'Identifier';
  dynamic get not_available => 'Not available';
  dynamic get save_message_folders => 'Save to folder';
  dynamic get remove_from_saved => 'Remove from saved';
  dynamic get message_already_saved => 'Already saved';
  dynamic get stream_ttft => 'Time to first token';
  dynamic get stream_tokens_per_sec => 'Tokens per second';
  dynamic get stream_stop_reason => 'Stop reason';
  dynamic get stream_input_tokens => 'Input tokens';
  dynamic get stream_output_tokens => 'Output tokens';
  dynamic get stream_generation_time => 'Generation time';
  dynamic get attach_image => 'Attach an image';
  dynamic get attach_text_document => 'Attach a text file';
  dynamic get add_attachment => 'Add attachment';
  dynamic get photo_permission_denied => 'Photo access was denied';
  dynamic get characters_label => 'Characters';
  dynamic get exit_temporary_chat_title => 'Leave temporary chat?';
  dynamic get exit_temporary_chat_body =>
      'The messages here will be discarded.';
  dynamic get saved_message_temp_snap_unavailable =>
      'Saved messages are not available in a temporary chat';
  dynamic get filter_title => 'Filter';
  dynamic get filter_pinned => 'Pinned';
  dynamic get filter_archived => 'Archived';
  dynamic get filter_temp_chats => 'Temporary chats';
  dynamic get filter_user_messages => 'My messages';
  dynamic get filter_assistant_messages => 'Assistant replies';
  dynamic get archive_chat => 'Archive chat';
  dynamic get unarchive_chat => 'Unarchive chat';
  dynamic get generate_title_with_ai => 'Name this chat with AI';
  dynamic get generating_title => 'Naming the chat...';
  dynamic get generate_title_failed => 'Could not name the chat';
  dynamic tts_skip_seconds_value(dynamic seconds) => '';
  dynamic conversation_message_count(dynamic count) => '';
  dynamic conversation_character_count(dynamic count) => '';
  dynamic get ai_user_response_enabled => 'Suggest my replies';
  dynamic get ai_user_response_tooltip => 'Let the model draft a reply for you';
  dynamic get delete_builtin_persona_body =>
      'Built in personas can be restored later.';
  dynamic get restore_builtin_personas => 'Restore built in personas';
  dynamic get restore_builtin_personas_desc =>
      'Brings back the personas shipped with the app.';
  dynamic get restore_builtin_personas_success => 'Built in personas restored';
  dynamic get clear_personas => 'Clear personas';
  dynamic get enable_image_compression => 'Compress images';
  dynamic get enable_image_compression_desc =>
      'Shrinks attachments before they are sent';
  dynamic get image_compression_level => 'Compression level';
  dynamic get image_compression_level_desc =>
      'Higher compression sends smaller images';
  dynamic get image_compression_level_low => 'Low';
  dynamic get image_compression_level_medium => 'Medium';
  dynamic get image_compression_level_high => 'High';
  dynamic get sort_models_tooltip => 'Sort models';
  dynamic get sort_by_favorites => 'Favourites first';
  dynamic get sort_by_name => 'Name';
  dynamic get sort_by_size_smallest => 'Smallest first';
  dynamic get sort_by_size_largest => 'Largest first';
  dynamic get sort_by_context_length => 'Context length';
  dynamic get ai_rename_tooltip => 'Rename with AI';
  dynamic get new_chat_in_folder_tooltip => 'New chat in this folder';
  dynamic get smart_replies_use_persona => 'Smart replies follow the persona';
  dynamic get smart_replies_use_persona_desc =>
      'Suggestions keep the tone of the active persona.';
  dynamic get keep_persona_on_new_chat => 'Keep persona in new chats';
  dynamic get keep_persona_on_new_chat_desc =>
      'New chats start with the persona you used last.';
  dynamic get role_swap_button_enabled => 'Show the role swap button';
  dynamic get role_swap_button_enabled_desc =>
      'Lets you send a message as the assistant.';
  dynamic get send_as_user_tooltip => 'Send as user';
  dynamic get send_as_assistant_tooltip => 'Send as assistant';
  dynamic get insert_without_generating_tooltip => 'Insert without generating';
  dynamic get token_usage_title => 'Token usage';
  dynamic get total_tokens_label => 'Total tokens';
  dynamic get usage_percent_label => 'Context used';
  dynamic get export_choice_title => 'How should this be exported?';
  dynamic get export_choice_body =>
      'Save it as a file or copy it to the clipboard.';
  dynamic get copy_to_clipboard => 'Copy to clipboard';
  dynamic get bulk_ai_rename_confirm_title => 'Rename these chats with AI?';
  dynamic get sort_by_modified_date => 'Last modified';
  dynamic get sort_by_created_date => 'Date created';
  dynamic get sort_title => 'Sort';
  dynamic get ai_user_response_enabled_desc =>
      'Adds a button that writes your next message.';
  dynamic get show_system_messages_desc =>
      'Show the hidden instructions sent with each chat';
  dynamic get show_system_messages_in_chat =>
      'Show system messages in the chat';
  dynamic get show_system_messages_in_chat_desc =>
      'Renders system instructions inline.';
  dynamic get manage_personas => 'Manage personas';
  dynamic get personas_combine_hint => 'Personas stack with the system prompt.';
  dynamic get temp_chat_keyboard_incognito => 'Incognito keyboard';
  dynamic get temp_chat_keyboard_incognito_desc =>
      'Asks the keyboard not to learn from temporary chats.';
  dynamic get resume_last_chat => 'Resume the last chat';
  dynamic get resume_last_chat_desc =>
      'Opens the conversation you had open last.';
  dynamic get lm_studio_model_browser_title => 'LM Studio models';
  dynamic get lm_studio_model_search_hint => 'Search LM Studio';
  dynamic get lm_studio_staff_picks => 'Staff picks';
  dynamic get lm_studio_community_models => 'Community models';
  dynamic get lm_studio_no_models => 'No models found';
  dynamic get lm_studio_browse_models => 'Browse models';
  dynamic get lm_studio_model_search => 'Search models';
  dynamic get lm_studio_downloads_title => 'Downloads';
  dynamic get lm_studio_choose_quant => 'Choose a quantisation';
  dynamic get lm_studio_use_default_quant => 'Use the recommended quantisation';
  dynamic get lm_studio_recommended => 'Recommended';
  dynamic get lm_studio_clear_downloads => 'Clear downloads';
  dynamic get lm_studio_no_downloads => 'No downloads yet';
  dynamic get lm_studio_downloads_disclaimer =>
      'Downloads are handled by LM Studio on your machine.';
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
  dynamic get lm_studio_memory_settings_title => 'Memory settings';
  dynamic get lm_studio_memory_settings_desc =>
      'Tell the app how much memory it may use.';
  dynamic get think_button_label => 'Think';
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
  dynamic get could_not_read_file => 'Could not read that file';
  dynamic get server_offline => 'Server offline';
  dynamic get could_not_establish_connection => 'Could not reach the server';
  dynamic get retry_connection => 'Try again';
  dynamic get tokens_label => 'Tokens';
  dynamic get enter_context_length => 'Enter a context length';
}

class ConsumerWidget extends StatelessWidget {
  const ConsumerWidget({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class DataBackupService {
  DataBackupService();
  dynamic exportAll(dynamic store, {dynamic prefs}) => <String, dynamic>{};
  dynamic exportConversations(dynamic store) => <String, dynamic>{};
  dynamic exportPersonas(dynamic store) => <String, dynamic>{};
  dynamic exportSettings(
    dynamic settingsJson, {
    dynamic store,
    dynamic prefs,
  }) => <String, dynamic>{};
  dynamic exportConversationsAsJson(dynamic store) => '';
  dynamic exportPersonasAsJson(dynamic store) => '';
  dynamic exportSettingsAsJson(
    dynamic settingsJson, {
    dynamic store,
    dynamic prefs,
  }) => '';
  dynamic exportAllZip(dynamic store, dynamic settingsJson, {dynamic prefs}) =>
      <int>[];
  dynamic exportAllAsJson(dynamic store, {dynamic prefs}) => '';
  dynamic importFromJson(dynamic store, dynamic jsonString) => const _Stub();
  dynamic importZip(dynamic store, dynamic bytes) => const _Stub();
  dynamic exportConversation(dynamic store, dynamic conversationId) =>
      <String, dynamic>{};
  dynamic exportConversationAsJson(dynamic store, dynamic conversationId) => '';
  dynamic exportConversationsForIds(dynamic store, dynamic conversationIds) =>
      <String, dynamic>{};
  dynamic exportConversationsForIdsAsJson(
    dynamic store,
    dynamic conversationIds,
  ) => '';
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

dynamic databaseProvider = const _Stub();

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

dynamic sharedPreferencesProvider = const _Stub();
