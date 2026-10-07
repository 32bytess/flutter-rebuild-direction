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

AppProvider fixtureAppProvider = AppProvider();

Widget fixtureChild = const SizedBox.shrink();

// DECLARATION-ONLY STAND-INS -- repo-local declarations that build no UI, and
// third-party ones the transplant does not inline. Supertypes are mirrored so a
// widget still reads as a widget; everything else is `dynamic`, because none of it
// is measured.

class AppConstants {
  AppConstants();
  static const dynamic appName = 'AI Chat';
  static const dynamic appVersion = '1.2.0';
  static const dynamic appDescription = '跨平台 AI 对话客户端';
  static const dynamic serverHostKey = 'server_host';
  static const dynamic serverPortKey = 'server_port';
  static const dynamic apiKeyKey = 'api_key';
  static const dynamic selectedProviderKey = 'selected_provider';
  static const dynamic selectedModelKey = 'selected_model';
  static const dynamic themeKey = 'theme_mode';
  static const dynamic lastSessionIdKey = 'last_session_id';
  static const dynamic defaultTheme = 'system';
  static const dynamic maxMessageLength = 4000;
  static const dynamic maxFileSize = 10485760;
  static const dynamic defaultPadding = 16.0;
  static const dynamic smallPadding = 8.0;
  static const dynamic largePadding = 24.0;
  static const dynamic borderRadius = 12.0;
  static const dynamic smallBorderRadius = 8.0;
  static const dynamic shortAnimation = Duration(milliseconds: 150);
  static const dynamic mediumAnimation = Duration(milliseconds: 300);
  static const dynamic longAnimation = Duration(milliseconds: 500);
  static const dynamic networkError = '网络连接失败，请检查网络设置';
  static const dynamic serverError = '服务器内部错误，请稍后重试';
  static const dynamic unknownError = '发生未知错误';
  static const dynamic connectionTimeout = '连接超时，请重试';
  static const dynamic invalidResponse = '服务器返回了无效的响应';
}

class AppInfo {
  const AppInfo({dynamic hostname, dynamic git, dynamic path, dynamic time});
  dynamic get hostname => 'macbook-pro.local';
  dynamic get git => false;
  dynamic get path => const _Stub();
  dynamic get time => null;
  dynamic get props => <Object?>[];
}

class AppProvider extends ChangeNotifier {
  AppProvider({
    dynamic getAppInfo,
    dynamic checkConnection,
    dynamic updateServerConfig,
  });
  dynamic get status => const _Stub();
  dynamic get appInfo => null;
  dynamic get errorMessage => '无法连接到服务器';
  dynamic get serverHost => 'localhost';
  dynamic get serverPort => 8080;
  dynamic get isConnected => false;
  dynamic get serverUrl => 'http://localhost:8080';
  dynamic getAppInfo() => const _Stub();
  dynamic checkConnection() => const _Stub();
  dynamic updateServerConfig(dynamic host, dynamic port) =>
      Future<bool>.value(false);
  void setServerConfig(dynamic host, dynamic port) {}
  void clearError() {}
  void reset() {}
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
