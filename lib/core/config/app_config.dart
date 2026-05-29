import 'env.dart';

/// App-wide constants (non-secrets).
class AppConfig {
  static const String appName = 'Ampex';
  static const String defaultLocale = 'nb';

  static bool get isDev => Env.environment == AppEnvironment.dev;
}
