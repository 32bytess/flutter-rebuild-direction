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

late TextEditingController fixtureCustomCtrl = TextEditingController(
  text: '1.1.1.1',
);

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

String fixtureSelectedPreset = '';

DnsType fixtureCustomType = DnsType.udp;

// DECLARATION-ONLY STAND-INS -- repo-local declarations that build no UI, and
// third-party ones the transplant does not inline. Supertypes are mirrored so a
// widget still reads as a widget; everything else is `dynamic`, because none of it
// is measured.

class AppColors {
  AppColors();
  static const dynamic bg = Color(0xFF0D0F14);
  static const dynamic surface = Color(0xFF141821);
  static const dynamic surfaceElevated = Color(0xFF1B202B);
  static const dynamic surfaceHighlight = Color(0xFF232936);
  static const dynamic primary = Color(0xFF4C8DFF);
  static const dynamic primaryDim = Color(0xFF2F5FB0);
  static const dynamic connected = Color(0xFF3DDC84);
  static const dynamic connectedDim = Color(0xFF248F55);
  static const dynamic disconnected = Color(0xFF6B7280);
  static const dynamic connecting = Color(0xFFFFB020);
  static const dynamic error = Color(0xFFE5484D);
  static const dynamic textPrimary = Color(0xFFE8EAED);
  static const dynamic textSecondary = Color(0xFF9AA0A6);
  static const dynamic textDisabled = Color(0xFF5F6368);
  static const dynamic border = Color(0xFF2A303C);
  static const dynamic borderAccent = Color(0xFF3B5A8F);
  static const dynamic logDebug = Color(0xFF7E8794);
  static const dynamic logInfo = Color(0xFF4C8DFF);
  static const dynamic logWarning = Color(0xFFFFB020);
  static const dynamic logError = Color(0xFFE5484D);
  static const dynamic chartUpload = Color(0xFF4C8DFF);
  static const dynamic chartDownload = Color(0xFF3DDC84);
  static const dynamic protoVless = Color(0xFF7C5CFF);
  static const dynamic protoVmess = Color(0xFF00B8D9);
  static const dynamic protoTrojan = Color(0xFFFF7A45);
  static const dynamic protoShadowsocks = Color(0xFF22C55E);
  static const dynamic protoHysteria2 = Color(0xFFEC4899);
}

class ConsumerState<WidgetT> {
  ConsumerState();
  dynamic get ref => WidgetRef();
}

class DnsServerConfig {
  const DnsServerConfig({
    dynamic type,
    dynamic address,
    dynamic port,
    dynamic domain,
    dynamic fallbackIp,
  });
  dynamic get type => DnsType.udp;
  dynamic get address => '1.1.1.1';
  dynamic get port => 53;
  dynamic get domain => 'cloudflare-dns.com';
  static const dynamic cloudflare = DnsServerConfig(
    type: DnsType.udp,
    address: '1.1.1.1',
    port: 53,
  );
  static const dynamic cloudflareDoH = DnsServerConfig(
    type: DnsType.doh,
    address: 'https://cloudflare-dns.com/dns-query',
    port: 443,
    domain: 'cloudflare-dns.com',
    fallbackIp: '1.1.1.1',
  );
  static const dynamic cloudflareDoT = DnsServerConfig(
    type: DnsType.dot,
    address: 'one.one.one.one',
    port: 853,
    domain: 'one.one.one.one',
    fallbackIp: '1.1.1.1',
  );
  static const dynamic google = DnsServerConfig(
    type: DnsType.udp,
    address: '8.8.8.8',
    port: 53,
  );
  static const dynamic googleDoH = DnsServerConfig(
    type: DnsType.doh,
    address: 'https://dns.google/dns-query',
    port: 443,
    domain: 'dns.google',
    fallbackIp: '8.8.8.8',
  );
  static const dynamic googleDoT = DnsServerConfig(
    type: DnsType.dot,
    address: 'dns.google',
    port: 853,
    domain: 'dns.google',
    fallbackIp: '8.8.8.8',
  );
  static const dynamic quad9 = DnsServerConfig(
    type: DnsType.udp,
    address: '9.9.9.9',
    port: 53,
  );
  static const dynamic quad9DoH = DnsServerConfig(
    type: DnsType.doh,
    address: 'https://dns.quad9.net/dns-query',
    port: 443,
    domain: 'dns.quad9.net',
    fallbackIp: '9.9.9.9',
  );
  static const dynamic adguard = DnsServerConfig(
    type: DnsType.udp,
    address: '94.140.14.14',
    port: 53,
  );
  static const dynamic adguardDoH = DnsServerConfig(
    type: DnsType.doh,
    address: 'https://dns.adguard-dns.com/dns-query',
    port: 443,
    domain: 'dns.adguard-dns.com',
    fallbackIp: '94.140.14.14',
  );
  // Cardinality 3 -- `config/fixture_policy.json`. The same three rows mount for
  // every role in this group, so preset-list length is not a difference between
  // any pair of revisions.
  static const dynamic presets = <Map<String, String>>[
    {'value': 'cloudflare', 'label': 'Cloudflare (1.1.1.1)'},
    {'value': 'google', 'label': 'Google (8.8.8.8)'},
    {'value': 'adguard', 'label': 'AdGuard (94.140.14.14)'},
  ];
  dynamic get displayName => 'Cloudflare (1.1.1.1)';
  static dynamic fromPreset(
    dynamic preset, {
    dynamic customAddress,
    dynamic customType,
  }) => DnsServerConfig();
  dynamic get fallbackIp => '1.1.1.1';
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

class AppTheme {
  AppTheme();
  static dynamic get dark => const _Stub();
  static dynamic mono({
    dynamic size,
    dynamic weight,
    dynamic color,
    dynamic letterSpacing,
    dynamic height,
  }) => const _Stub();
  static dynamic sans({
    dynamic size,
    dynamic weight,
    dynamic color,
    dynamic letterSpacing,
    dynamic height,
  }) => const _Stub();
  static dynamic build(dynamic brightness, dynamic accent) => const _Stub();
}

class TeapodTokens {
  const TeapodTokens({
    dynamic bg,
    dynamic bgElev,
    dynamic bgSunken,
    dynamic line,
    dynamic lineSoft,
    dynamic text,
    dynamic textDim,
    dynamic textMuted,
    dynamic accent,
    dynamic accentSoft,
    dynamic accentFade,
    dynamic danger,
  });
  TeapodTokens.dark(dynamic accent);
  TeapodTokens.light(dynamic accent);
  dynamic get bg => const _Stub();
  dynamic get bgElev => const _Stub();
  dynamic get bgSunken => const _Stub();
  dynamic get line => const _Stub();
  dynamic get lineSoft => const _Stub();
  dynamic get text => const _Stub();
  dynamic get textDim => const _Stub();
  dynamic get textMuted => const _Stub();
  dynamic get accent => const _Stub();
  dynamic get accentSoft => const _Stub();
  dynamic get accentFade => const _Stub();
  dynamic get danger => const _Stub();
  dynamic copyWith({
    dynamic bg,
    dynamic bgElev,
    dynamic bgSunken,
    dynamic line,
    dynamic lineSoft,
    dynamic text,
    dynamic textDim,
    dynamic textMuted,
    dynamic accent,
    dynamic accentSoft,
    dynamic accentFade,
    dynamic danger,
  }) => TeapodTokens();
  dynamic lerp(dynamic other, dynamic t) => TeapodTokens();
}

// UNRESOLVED-REFERENCE STAND-INS -- reconstructed from the call sites, because the
// symbol lives in a package this file may not import or the source project's own
// dependencies were never installed. Every type here is `dynamic`.

extension _SpmPaintShim on Paint {
  dynamic get color => const _Stub();
  dynamic get strokeWidth => const _Stub();
  dynamic get style => const _Stub();
}
