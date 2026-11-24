/// Runtime configuration. This is the ONLY file that reads compile-time
/// defines (`--dart-define-from-file=config/<flavor>.json`). Everything else
/// receives an [AppConfig] by injection.
library;

/// Build flavor, selected by the entry point (`main_<flavor>.dart`).
enum Flavor {
  dev('dev'),
  staging('staging'),
  production('production');

  const Flavor(this.envName);

  /// Value expected in `APP_ENV`.
  final String envName;

  bool get isProduction => this == Flavor.production;

  static Flavor? fromEnvName(String value) {
    for (final flavor in values) {
      if (flavor.envName == value) return flavor;
    }
    return null;
  }
}

class ConfigException implements Exception {
  const ConfigException(this.message);

  final String message;

  @override
  String toString() => 'ConfigException: $message';
}

final class AppConfig {
  const AppConfig({required this.flavor, required this.apiBaseUrl});

  final Flavor flavor;

  /// Absolute base URL without a trailing slash, e.g.
  /// `https://api.example.com/api/v1`.
  final String apiBaseUrl;

  /// Network logging is enabled for dev only.
  bool get enableNetworkLogging => flavor == Flavor.dev;

  /// Reads `APP_ENV` / `API_BASE_URL` from `--dart-define(-from-file)` and
  /// validates them against the flavor of the entry point.
  factory AppConfig.fromEnvironment({required Flavor expectedFlavor}) =>
      AppConfig.parse(
        expectedFlavor: expectedFlavor,
        appEnv: const String.fromEnvironment('APP_ENV'),
        apiBaseUrl: const String.fromEnvironment('API_BASE_URL'),
      );

  /// Pure validation, unit-testable. Throws [ConfigException].
  factory AppConfig.parse({
    required Flavor expectedFlavor,
    required String appEnv,
    required String apiBaseUrl,
  }) {
    const hint =
        'Run with --dart-define-from-file=config/<flavor>.json '
        '(see README).';
    if (appEnv.trim().isEmpty) {
      throw const ConfigException('APP_ENV is missing. $hint');
    }
    final flavor = Flavor.fromEnvName(appEnv.trim());
    if (flavor == null) {
      throw ConfigException(
        'APP_ENV "$appEnv" is invalid; expected one of '
        '${Flavor.values.map((f) => f.envName).join(', ')}.',
      );
    }
    if (flavor != expectedFlavor) {
      throw ConfigException(
        'APP_ENV "$appEnv" does not match the "${expectedFlavor.envName}" '
        'entry point. Use config/${expectedFlavor.envName}.json.',
      );
    }

    final trimmedUrl = apiBaseUrl.trim();
    if (trimmedUrl.isEmpty) {
      throw const ConfigException('API_BASE_URL is missing. $hint');
    }
    final uri = Uri.tryParse(trimmedUrl);
    if (uri == null ||
        !(uri.isScheme('http') || uri.isScheme('https')) ||
        uri.host.isEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw ConfigException(
        'API_BASE_URL "$apiBaseUrl" must be an absolute http(s) URL.',
      );
    }
    if (flavor != Flavor.dev && !uri.isScheme('https')) {
      throw ConfigException(
        'API_BASE_URL must use https for the ${flavor.envName} flavor.',
      );
    }

    return AppConfig(
      flavor: flavor,
      apiBaseUrl: trimmedUrl.replaceFirst(RegExp(r'/+$'), ''),
    );
  }

  @override
  String toString() =>
      'AppConfig(flavor: ${flavor.envName}, apiBaseUrl: $apiBaseUrl)';
}
