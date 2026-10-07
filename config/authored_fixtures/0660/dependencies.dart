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

VoidCallback fixtureOnStartNewChat = () {};

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

Conversation fixtureConversation = Conversation();

String? fixtureErrorMessage = null;

// DECLARATION-ONLY STAND-INS -- repo-local declarations that build no UI, and
// third-party ones the transplant does not inline. Supertypes are mirrored so a
// widget still reads as a widget; everything else is `dynamic`, because none of it
// is measured.

class ConsumerWidget extends StatelessWidget {
  const ConsumerWidget({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class Conversation {
  Conversation({
    dynamic id,
    dynamic title,
    dynamic createdAt,
    dynamic updatedAt,
    dynamic isPinned,
    dynamic personaId,
    dynamic serverId,
    dynamic modelId,
    dynamic messageCount,
    dynamic lastMessagePreview,
    dynamic systemPrompt,
    dynamic temperature,
    dynamic topP,
    dynamic maxTokens,
    dynamic contextLength,
    dynamic mcpEnabled,
    dynamic smartReplies,
    dynamic smartRepliesLastMessageId,
  });
  dynamic get id => 'conversation';
  dynamic get title => 'Untitled conversation';
  dynamic get createdAt => DateTime.fromMillisecondsSinceEpoch(0);
  dynamic get updatedAt => DateTime.fromMillisecondsSinceEpoch(0);
  dynamic get isPinned => false;
  dynamic get personaId => null;
  dynamic get serverId => null;
  dynamic get modelId => null;
  dynamic get messageCount => 0;
  dynamic get lastMessagePreview => null;
  dynamic get systemPrompt => null;
  dynamic copyWith({
    dynamic id,
    dynamic title,
    dynamic createdAt,
    dynamic updatedAt,
    dynamic isPinned,
    dynamic personaId,
    dynamic clearPersona,
    dynamic serverId,
    dynamic modelId,
    dynamic messageCount,
    dynamic lastMessagePreview,
    dynamic systemPrompt,
    dynamic clearSystemPrompt,
    dynamic temperature,
    dynamic clearTemperature,
    dynamic topP,
    dynamic clearTopP,
    dynamic maxTokens,
    dynamic clearMaxTokens,
    dynamic contextLength,
    dynamic clearContextLength,
    dynamic mcpEnabled,
    dynamic clearMcpEnabled,
    dynamic smartReplies,
    dynamic clearSmartReplies,
    dynamic smartRepliesLastMessageId,
    dynamic clearSmartRepliesLastMessageId,
  }) => Conversation();
  dynamic get temperature => null;
  dynamic get topP => null;
  dynamic get maxTokens => null;
  dynamic get contextLength => null;
  dynamic get mcpEnabled => null;
  dynamic get smartReplies => null;
  dynamic get smartRepliesLastMessageId => null;
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
  dynamic get app_name => 'LocalMind';
  dynamic get app_tagline => 'Your AI. Your Device. Your Rules.';
  dynamic get app_version => '1.0.0';
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
  dynamic get copied => 'Copied!';
  dynamic get copied_to_clipboard => 'Copied to clipboard';
  dynamic get select => 'Select';
  dynamic get active => 'Active';
  dynamic get all => 'All';
  dynamic get none => 'None';
  dynamic get none_selected => 'None selected';
  dynamic get online => 'Online';
  dynamic get offline => 'Offline';
  dynamic get error => 'Error';
  dynamic get unknown_error => 'Unknown error';
  dynamic get not_now => 'Not Now';
  dynamic get enable => 'Enable';
  dynamic get proceed_anyway => 'Proceed Anyway';
  dynamic get test_connection => 'Test Connection';
  dynamic get testing => 'Testing...';
  dynamic get connection_successful => 'Connection successful!';
  dynamic get connection_failed => 'Connection failed. Check your settings.';
  dynamic get save_continue => 'Save & Continue';
  dynamic get save_changes => 'Save Changes';
  dynamic get finish_setup => 'Finish Setup';
  dynamic get start_new_chat => 'Start New Chat';
  dynamic get cannot_undo => 'This action cannot be undone.';
  dynamic get ram_warning => 'RAM Warning';
  dynamic get recommended => 'RECOMMENDED';
  dynamic get may_be_large => 'May be too large for this device';
  dynamic get calculating => 'Calculating...';
  dynamic get download_failed => 'Download failed';
  dynamic get downloaded => 'Downloaded';
  dynamic get not_downloaded => 'Not downloaded';
  dynamic get installed => 'Installed';
  dynamic get not_installed => 'Not installed';
  dynamic get loading => 'Loading...';
  dynamic get thinking => 'Thinking';
  dynamic get processing => 'Processing...';
  dynamic get initializing => 'Initializing...';
  dynamic get ready => 'Ready';
  dynamic get preparing_app => 'Preparing app...';
  dynamic get initializing_services => 'Initializing services...';
  dynamic get configuring_server => 'Configuring server...';
  dynamic get startup_failed => 'Startup failed';
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
  dynamic get no_model_loaded => 'No model loaded';
  dynamic get delete_conversation => 'Delete conversation?';
  dynamic get nav_history => 'History';
  dynamic get nav_servers => 'Servers';
  dynamic get nav_local_models => 'Local Models';
  dynamic get nav_tts => 'Text To Speech';
  dynamic get nav_personas => 'Personas';
  dynamic get nav_settings => 'Settings';
  dynamic get nav_new_chat => 'New Chat';
  dynamic get search_hint => 'Search conversations...';
  dynamic get no_server_selected => 'No server selected';
  dynamic get switch_server => 'Switch Server';
  dynamic get switch_server_subtitle => 'Choose a server to connect to';
  dynamic get manage_servers => 'Manage Servers';
  dynamic get open_source => 'Open Source';
  dynamic get open_source_desc => 'LocalMind is free and open source.';
  dynamic get star_on_github => 'Star on GitHub';
  dynamic get settings_title => 'Settings';
  dynamic get settings_appearance => 'Appearance';
  dynamic get settings_language => 'Language';
  dynamic get language_system_default => 'System Default';
  dynamic get settings_tts => 'Text-to-Speech';
  dynamic get settings_behavior => 'Behavior';
  dynamic get settings_on_device => 'On-Device Inference';
  dynamic get settings_default_server => 'Default Server';
  dynamic get settings_default_persona => 'Default Persona';
  dynamic get settings_privacy => 'Privacy';
  dynamic get settings_data_management => 'Data Management';
  dynamic get settings_about => 'About';
  dynamic get theme => 'Theme';
  dynamic get theme_system => 'System';
  dynamic get theme_light => 'Light';
  dynamic get theme_dark => 'Dark';
  dynamic get theme_claude => 'Claude';
  dynamic get font_size => 'Font Size';
  dynamic get font_size_desc => 'Adjust text size in chat.';
  dynamic get font_preview => 'The quick brown fox jumps over the lazy dog.';
  dynamic get code_theme_dark => 'Code Theme (Dark)';
  dynamic get code_theme_light => 'Code Theme (Light)';
  dynamic get code_theme_desc => 'Syntax highlighting theme for code blocks.';
  dynamic get tts_engine => 'TTS Engine';
  dynamic get tts_engine_system => 'System TTS';
  dynamic get tts_engine_kitten => 'Kitten TTS';
  dynamic get voice => 'Voice';
  dynamic get voice_female => 'Female';
  dynamic get voice_male => 'Male';
  dynamic get voice_other => 'Other';
  dynamic get tts_speed => 'TTS Speed';
  dynamic get tts_speed_desc => 'Adjust the playback rate.';
  dynamic get manage_tts_models => 'Manage TTS Models';
  dynamic get manage_on_device_models => 'Manage On-Device Models';
  dynamic get streaming_responses => 'Streaming Responses';
  dynamic get auto_generate_titles => 'Auto-generate Titles';
  dynamic get send_on_enter => 'Send on Enter';
  dynamic get show_system_messages => 'Show System Messages';
  dynamic get haptic_feedback => 'Haptic Feedback';
  dynamic get enable_mcp => 'Enable MCP';
  dynamic get new_chat_mcp_default => 'New Chat MCP Default';
  dynamic get show_data_indicator => 'Show Data Indicator';
  dynamic get privacy_info => '"LocalMind never sees your data"';
  dynamic get delete_all_conversations => 'Delete All Conversations';
  dynamic get reset_settings_defaults => 'Reset Settings to Defaults';
  dynamic get chat_title => 'LocalMind';
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
  dynamic get quick_debug => 'Debug this for me';
  dynamic get quick_async => 'How do I use async/await?';
  dynamic get history_missing_title => 'History Missing';
  dynamic get history_missing_desc => 'Either the messages in this chat were deleted or the history record is corrupted.';
  dynamic get technical_details => 'Technical Details';
  dynamic get last_error => 'Last Error:';
  dynamic get copy_info => 'Copy Info';
  dynamic get conversation_id => 'Conversation ID';
  dynamic get created_at => 'Created At';
  dynamic get expected_messages => 'Expected Messages';
  dynamic get debug_dialog_desc => 'Include these details when you report the issue.';
  dynamic get chat_input_hint => 'Ask anything';
  dynamic get send_message_tooltip => 'Send message';
  dynamic get stop_generation_tooltip => 'Stop generation';
  dynamic get attach_images_tooltip => 'Attach images';
  dynamic get tool_unknown => 'Tool: Unknown';
  dynamic get message_options => 'Message options';
  dynamic get copy_markdown => 'Copy as Markdown';
  dynamic get copied_markdown => 'Copied as Markdown';
  dynamic get read_aloud => 'Read Aloud';
  dynamic get stop_reading => 'Stop Reading';
  dynamic get more => 'More';
  dynamic get edit_message => 'Edit message';
  dynamic get edit_message_desc => 'Editing this message removes every reply after it.';
  dynamic get save_regenerate => 'Save & regenerate';
  dynamic get chat_settings_title => 'Chat Settings';
  dynamic get reset_defaults => 'Reset Defaults';
  dynamic get parameters_tab => 'Parameters';
  dynamic get mcp_tab => 'MCP';
  dynamic get temperature => 'Temperature';
  dynamic get temperature_desc => 'Higher values make replies more creative.';
  dynamic get top_p => 'Top P';
  dynamic get top_p_desc => 'Nucleus sampling threshold';
  dynamic get max_tokens => 'Max Tokens';
  dynamic get max_tokens_desc => 'Response limit';
  dynamic get context_length => 'Context Length';
  dynamic get context_length_desc => 'History window';
  dynamic get mcp_disabled_warning => 'MCP is turned off in Settings.';
  dynamic get mcp_enable_chat => 'Enable MCP for this chat';
  dynamic get auto_execute_tools => 'Auto-execute tools';
  dynamic get add_ephemeral_mcp => 'Add Ephemeral MCP Server';
  dynamic get mcp_label_placeholder => 'Label';
  dynamic get mcp_url_placeholder => 'URL (https://...)';
  dynamic get active_integrations => 'Active Integrations';
  dynamic get enable_notifications => 'Enable Notifications';
  dynamic get enable_notifications_desc => 'Get notified when downloads and replies finish.';
  dynamic get chat_history_title => 'Chat History';
  dynamic get conversation_just_now => 'Just now';
  dynamic get conversation_yesterday => 'Yesterday';
  dynamic get options_tooltip => 'Options';
  dynamic get no_results_found => 'No results found';
  dynamic get no_conversations_yet => 'No conversations yet';
  dynamic get try_different_search => 'Try a different search term';
  dynamic get start_new_conversation => 'Start a new conversation';
  dynamic get rename_conversation => 'Rename conversation';
  dynamic get enter_new_title => 'Enter new title';
  dynamic get pinned_section => 'PINNED';
  dynamic get today_section => 'TODAY';
  dynamic get yesterday_section => 'YESTERDAY';
  dynamic get previous_7_days => 'PREVIOUS 7 DAYS';
  dynamic get previous_30_days => 'PREVIOUS 30 DAYS';
  dynamic get older_section => 'OLDER';
  dynamic get onboarding_localmind => 'LOCALMIND';
  dynamic get onboarding_connect_server => 'Connect Your\nServer';
  dynamic get onboarding_connect_desc => 'Choose where your models run. You can change this later.';
  dynamic get server_type_on_device => 'On-Device';
  dynamic get server_type_on_device_sub => 'NO SERVER NEEDED';
  dynamic get server_type_lm_studio => 'LM Studio';
  dynamic get server_type_lm_studio_sub => 'LOCAL API';
  dynamic get server_type_ollama => 'Ollama';
  dynamic get server_type_ollama_sub => 'CLI ENGINE';
  dynamic get server_type_openrouter => 'OpenRouter';
  dynamic get server_type_openrouter_sub => 'UNIFIED CLOUD';
  dynamic get ready_continue => 'READY TO CONTINUE';
  dynamic get waiting_selection => 'WAITING FOR SELECTION';
  dynamic get setup_connection => 'Setup Connection';
  dynamic get server_name => 'Server Name';
  dynamic get name_required => 'Name required';
  dynamic get name_max_50 => 'Max 50 characters';
  dynamic get host_label => 'Host / IP Address';
  dynamic get host_required => 'Host required';
  dynamic get port_label => 'Port';
  dynamic get port_required => 'Port required';
  dynamic get port_invalid => 'Must be a number';
  dynamic get port_range => 'Enter a valid port (1-65535)';
  dynamic get api_key_required => 'API Key *';
  dynamic get api_key_optional => 'API Key (Optional)';
  dynamic get api_key_required_openrouter => 'API Key required for OpenRouter';
  dynamic get api_key_format => 'OpenRouter API keys start with sk-';
  dynamic get my_server_hint => 'My Server';
  dynamic get name_length_validation => 'Name must be 50 characters or less';
  dynamic get host_valid => 'Enter a valid hostname or IP address';
  dynamic get api_key_hint_openrouter => 'sk-...';
  dynamic get api_key_hint_generic => 'For authenticated servers';
  dynamic get update_server => 'Update Server';
  dynamic get save_server => 'Save Server';
  dynamic get server_updated => 'Server updated';
  dynamic get server_added => 'Server added';
  dynamic get download_model_title => 'Download a Model';
  dynamic get download_model_desc => 'Download a model to chat without a server.';
  dynamic get on_device_android_only => 'On-device inference is Android only for now.';
  dynamic get total_ram => 'Total RAM';
  dynamic get available => 'Available';
  dynamic get choose_theme => 'Choose Theme';
  dynamic get choose_theme_desc => 'You can change this later in Settings.';
  dynamic get theme_card_system => 'System';
  dynamic get theme_card_system_sub => 'Matches your device settings';
  dynamic get theme_card_light => 'Light';
  dynamic get theme_card_light_sub => 'Clean and bright';
  dynamic get theme_card_dark => 'Dark';
  dynamic get theme_card_dark_sub => 'Easy on the eyes';
  dynamic get theme_card_claude => 'Claude';
  dynamic get theme_card_claude_sub => 'A warm, peach-tinted theme';
  dynamic get stay_updated => 'Stay Updated';
  dynamic get stay_updated_desc => 'Allow notifications so you do not have to keep the app open.';
  dynamic get notification_benefit_downloads => 'Model download progress';
  dynamic get notification_benefit_completions => 'Generation completions';
  dynamic get notification_benefit_background => 'Background tasks status';
  dynamic get allow_notifications => 'Allow Notifications';
  dynamic get servers_title => 'Servers';
  dynamic get no_servers_yet => 'No Servers Yet';
  dynamic get no_servers_desc => 'Add a server to start chatting.';
  dynamic get add_server => 'Add Server';
  dynamic get edit_server => 'Edit Server';
  dynamic get add_server_title => 'Add Server';
  dynamic get server_type_label => 'Server Type';
  dynamic get server_icon_label => 'Server Icon';
  dynamic get default_icon => 'Default icon';
  dynamic get server_type_lm_studio_display => 'LM Studio';
  dynamic get server_type_openai_display => 'OpenAI Compatible';
  dynamic get server_type_ollama_display => 'Ollama';
  dynamic get server_type_openrouter_display => 'OpenRouter';
  dynamic get server_type_on_device_display => 'On-Device';
  dynamic get server_address_openrouter => 'openrouter.ai';
  dynamic get server_address_on_device => 'Local inference';
  dynamic get default_badge => 'Default';
  dynamic get set_as_default => 'Set as Default';
  dynamic get select_icon => 'Select Icon';
  dynamic get select_icon_desc => 'Choose an icon for your server';
  dynamic get search_icons_hint => 'Search icons...';
  dynamic get server_icon_stack => 'Server Stack';
  dynamic get server_icon_stack2 => 'Server Stack 02';
  dynamic get server_icon_stack3 => 'Server Stack 03';
  dynamic get server_icon_cloud => 'Cloud';
  dynamic get server_icon_cloud_server => 'Cloud Server';
  dynamic get server_icon_mcp => 'MCP Server';
  dynamic get server_icon_database => 'Database';
  dynamic get server_icon_database1 => 'Database 01';
  dynamic get server_icon_database2 => 'Database 02';
  dynamic get server_icon_cpu => 'CPU';
  dynamic get server_icon_chip => 'Chip';
  dynamic get server_icon_chip2 => 'Chip 02';
  dynamic get server_icon_computer => 'Computer';
  dynamic get server_icon_laptop => 'Laptop';
  dynamic get server_icon_terminal => 'Computer Terminal';
  dynamic get server_icon_code => 'Code';
  dynamic get server_icon_ai_brain => 'AI Brain';
  dynamic get server_icon_ai_brain2 => 'AI Brain 02';
  dynamic get server_icon_ai_cloud => 'AI Cloud';
  dynamic get server_icon_ai_network => 'AI Network';
  dynamic get server_icon_ai_chat => 'AI Chat';
  dynamic get server_icon_cellular => 'Cellular Network';
  dynamic get server_icon_plug1 => 'Plug 01';
  dynamic get server_icon_plug2 => 'Plug 02';
  dynamic get server_icon_bot => 'Bot';
  dynamic get server_icon_bot2 => 'Bot 02';
  dynamic get server_icon_robotic => 'Robotic';
  dynamic get server_icon_rocket => 'Rocket';
  dynamic get server_icon_star => 'Star';
  dynamic get server_icon_settings1 => 'Settings 01';
  dynamic get server_icon_settings2 => 'Settings 02';
  dynamic get server_icon_home1 => 'Home 01';
  dynamic get server_icon_home2 => 'Home 02';
  dynamic get server_icon_folder1 => 'Folder 01';
  dynamic get server_icon_folder2 => 'Folder 02';
  dynamic get server_icon_file1 => 'File 01';
  dynamic get server_icon_lock => 'Lock';
  dynamic get server_icon_key => 'Key 01';
  dynamic get server_icon_link => 'Link 01';
  dynamic get server_icon_globe => 'Globe';
  dynamic get server_icon_api => 'API';
  dynamic get server_icon_arrow_right => 'Arrow Right 01';
  dynamic get server_icon_check => 'Check Circle';
  dynamic get server_icon_alert => 'Alert Circle';
  dynamic get server_icon_info => 'Info Circle';
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
  dynamic get persona_builtin_section => 'BUILT-IN';
  dynamic get persona_my_section => 'MY PERSONAS';
  dynamic get clone_edit => 'Clone & Edit';
  dynamic get builtin_badge => 'Built-in';
  dynamic get no_personas_found => 'No personas found';
  dynamic get no_personas_desc => 'Create a persona to give the assistant a role.';
  dynamic get edit_persona => 'Edit Persona';
  dynamic get create_persona => 'Create Persona';
  dynamic get create_persona_button => 'Create';
  dynamic get emoji_label => 'Emoji';
  dynamic get name_label => 'Name';
  dynamic get my_persona_hint => 'My Persona';
  dynamic get category_label => 'Category';
  dynamic get description_optional => 'Description (optional)';
  dynamic get description_hint => 'What this persona does...';
  dynamic get system_prompt => 'System Prompt';
  dynamic get no_prompt_placeholder => 'No prompt yet...';
  dynamic get prompt_hint => 'You are a helpful assistant...';
  dynamic get prompt_required => 'System prompt is required';
  dynamic get prompt_max_chars => 'Max 4000 characters';
  dynamic get advanced_settings => 'Advanced Settings';
  dynamic get temperature_label => 'Temperature (0.0-2.0)';
  dynamic get top_p_label => 'Top P (0.0-1.0)';
  dynamic get temp_hint => '0.7';
  dynamic get top_p_hint => '0.9';
  dynamic get range_0_2 => '0.0-2.0';
  dynamic get range_0_1 => '0.0-1.0';
  dynamic get persona_updated => 'Persona updated';
  dynamic get persona_created => 'Persona created';
  dynamic get tts_models_title => 'Text To Speech Models';
  dynamic get always_available => 'Always available';
  dynamic get tts_system_desc => 'Uses the voices already installed on your device.';
  dynamic get downloading_status => 'Downloading...';
  dynamic get on_device_models_title => 'On-Device Models';
  dynamic get available_models => 'Available Models';
  dynamic get device_memory => 'Device Memory';
  dynamic get ram_usage => 'RAM Usage';
  dynamic get memory_healthy => 'Healthy';
  dynamic get memory_critical => 'Critical';
  dynamic get memory_low => 'Low';
  dynamic get available_ram => 'Available RAM';
  dynamic get total_capacity => 'Total Capacity';
  dynamic get loaded_status => 'Loaded';
  dynamic get inference_backend => 'Inference Backend';
  dynamic get backend_ios_notice => 'Only CPU backend is available on iOS.';
  dynamic get backend_cpu_desc => 'Works on all devices. Most compatible.';
  dynamic get backend_gpu_desc => 'Faster on supported GPUs. Uses more battery.';
  dynamic get backend_npu_desc => 'Lowest power draw. Requires a compatible NPU.';
  dynamic get select_model_title => 'Select Model';
  dynamic get refresh_models => 'Refresh models';
  dynamic get search_models_hint => 'Search models...';
  dynamic get no_server_connected => 'No server connected';
  dynamic get add_server_first => 'Add a server first to see available models.';
  dynamic get failed_load_models => 'Failed to load models';
  dynamic get no_models_available => 'No models available';
  dynamic get unload_from_server => 'Unload from server';
  dynamic get download_complete_notification => 'Download complete!';
  dynamic get engine_name_system => 'System TTS';
  dynamic get engine_tagline_system => 'Built-in device engine';
  dynamic get engine_name_kitten => 'Kitten TTS';
  dynamic get engine_tagline_kitten => 'High-speed neural TTS';
  dynamic get engine_name_sherpa => 'Sherpa ONNX VITS';
  dynamic get engine_tagline_sherpa => 'Offline Piper voices';
  dynamic get voice_jasper => 'Jasper';
  dynamic get voice_bella => 'Bella';
  dynamic get voice_bruno => 'Bruno';
  dynamic get voice_luna => 'Luna';
  dynamic get voice_hugo => 'Hugo';
  dynamic get voice_rosie => 'Rosie';
  dynamic get voice_leo => 'Leo';
  dynamic get voice_kiki => 'Kiki';
  dynamic get voice_lessac => 'Lessac (US)';
  dynamic get voice_ryan => 'Ryan (US)';
  dynamic get model_qwen_3 => 'Qwen 3 0.6B';
  dynamic get model_qwen_3_desc => 'Compact general-purpose model. A good default.';
  dynamic get model_license_apache => 'Apache-2.0';
  dynamic get model_qwen_25 => 'Qwen 2.5 1.5B Instruct';
  dynamic get model_qwen_25_desc => 'Balanced instruct model for longer chats.';
  dynamic get model_deepseek => 'DeepSeek R1 Distill Qwen 1.5B';
  dynamic get model_deepseek_desc => 'Reasoning-focused distill. Slower replies.';
  dynamic get model_license_mit => 'MIT';
  dynamic get model_gemma => 'Gemma 4 E2B Instruct';
  dynamic get model_gemma_desc => 'Lightweight instruct model tuned for mobile.';
  dynamic get export_role_user => '## 👤 User';
  dynamic get export_role_assistant => '## 🤖 Assistant';
  dynamic get export_role_system => '## ⚙️ System';
  dynamic get export_role_tool => '## 🔧 Tool';
  dynamic get export_text_user => '[USER]';
  dynamic get export_text_assistant => '[ASSISTANT]';
  dynamic get export_text_system => '[SYSTEM]';
  dynamic get export_text_tool => '[TOOL]';
  dynamic get export_label_user => 'USER';
  dynamic get export_label_assistant => 'ASSISTANT';
  dynamic get export_label_system => 'SYSTEM';
  dynamic get export_label_tool => 'TOOL';
  dynamic get select_model_hint => 'Select a model to start chatting';
  dynamic get test_notification_title => 'Test notification';
  dynamic get test_notification_body => 'Notifications are working.';
  static dynamic of(dynamic context) => const AppLocalizations('en');
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
  dynamic get enable_smart_reply => 'On-Device Smart Replies';
  dynamic get onboarding_choose_language => 'Choose Language';
  dynamic get onboarding_choose_language_desc => 'You can change this later in Settings.';
  dynamic get onboarding_welcome => 'Welcome to LocalMind';
  dynamic get beta_label => 'Beta';
  dynamic get experimental_label => 'Experimental';
  dynamic get add_more => 'Add more';
  dynamic get on_github => 'On GitHub';
  dynamic get could_not_open_github => 'Could not open GitHub';
  dynamic get openai_compatible_api => 'OpenAI-compatible API';
  dynamic get https_requires_ssl => 'HTTPS requires a valid SSL certificate.';
  dynamic get most_local_setups_use_http => 'Most local setups use HTTP.';
  dynamic get tts_supports_background => 'Supports background playback';
  dynamic get tts_other_services_background_note => 'Other engines stop when the app leaves the foreground.';
  dynamic get start_listening_tooltip => 'Start listening';
  dynamic get stop_listening_tooltip => 'Stop listening';
  dynamic get settings_huggingface_token => 'Hugging Face Token';
  dynamic get settings_huggingface_token_desc => 'Required for gated model downloads.';
  dynamic get settings_huggingface_token_set => 'Token saved';
  dynamic get settings_huggingface_token_cleared => 'Token cleared';
  dynamic get model_requires_huggingface_token => 'This model requires a Hugging Face token.';
  dynamic get model_missing_huggingface_token => 'Add a Hugging Face token to download this model.';
  dynamic get set_huggingface_token => 'Set token';
  dynamic get clear_huggingface_token => 'Clear token';
  dynamic get edit_huggingface_token_dialog_title => 'Hugging Face Token';
  dynamic get huggingface_token_dialog_hint => 'hf_...';
  dynamic get server_type_ollama_desc => 'Connect to an Ollama instance on your network.';
  dynamic get server_type_on_device_desc => 'Run models directly on this device.';
  dynamic get server_type_lm_studio_desc => 'Connect to the LM Studio local server.';
}
