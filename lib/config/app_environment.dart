enum AppFlavor { dev, staging, prod }

/// Build-time configuration from `--dart-define` / `--dart-define-from-file=env/<flavor>.json`.
///
/// Values are compiled into the app binary: fine for URLs and feature flags,
/// NEVER for secrets (anyone can extract them from the APK/IPA/JS).
///
/// `fromEnvironment` only works in a **const** context — keep every field `static const`.
abstract final class AppEnvironment {
  static const flavorName = String.fromEnvironment('APP_FLAVOR', defaultValue: 'dev');
  static const apiBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'https://dev.api.example.com');
  static const enableLogging = bool.fromEnvironment('ENABLE_LOGGING', defaultValue: true);

  /// Empty = crash reporting disabled.
  static const sentryDsn = String.fromEnvironment('SENTRY_DSN');

  /// `true` when the build passed APP_FLAVOR explicitly (not relying on the default).
  static const isConfigured = bool.hasEnvironment('APP_FLAVOR');

  static AppFlavor get flavor => parseFlavor(flavorName);
  static bool get isProduction => flavor == AppFlavor.prod;

  static AppFlavor parseFlavor(String name) =>
      AppFlavor.values.firstWhere((flavor) => flavor.name == name, orElse: () => AppFlavor.dev);
}
