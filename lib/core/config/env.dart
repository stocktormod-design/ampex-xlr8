import 'package:flutter_dotenv/flutter_dotenv.dart';

enum AppEnvironment { dev, prod }

/// Leser konfigurasjon fra `.env` (gitignored) eller `--dart-define`.
class Env {
  static String get supabaseUrl =>
      _require('SUPABASE_URL', fallback: const String.fromEnvironment('SUPABASE_URL'));

  static String get supabaseAnonKey => _require(
        'SUPABASE_ANON_KEY',
        fallback: const String.fromEnvironment('SUPABASE_ANON_KEY'),
      );

  /// `dev` (standard) eller `prod`.
  static AppEnvironment get environment {
    final raw = (_optional('APP_ENV') ??
            const String.fromEnvironment('APP_ENV', defaultValue: 'dev'))
        .toLowerCase();
    return raw == 'prod' ? AppEnvironment.prod : AppEnvironment.dev;
  }

  static bool get isProd => environment == AppEnvironment.prod;

  /// Valgfritt – brukes når S3-opplasting implementeres.
  static String? get s3Endpoint => _optional('S3_ENDPOINT');
  static String? get s3Bucket => _optional('S3_BUCKET');
  static String? get s3AccessKey => _optional('S3_ACCESS_KEY');
  static String? get s3SecretKey => _optional('S3_SECRET_KEY');

  static bool get hasS3Config =>
      [s3Endpoint, s3Bucket, s3AccessKey, s3SecretKey].every(
        (v) => v != null && v.isNotEmpty,
      );

  static String _require(String key, {String fallback = ''}) {
    final value = _read(key, fallback: fallback);
    if (value == null || value.isEmpty) {
      throw StateError(
        'Mangler $key. Kopier .env.example → .env eller bruk --dart-define=$key=...',
      );
    }
    return value;
  }

  static String? _optional(String key) {
    final value = _read(key);
    if (value == null || value.isEmpty) return null;
    return value;
  }

  static String? _read(String key, {String fallback = ''}) {
    if (dotenv.isInitialized) {
      final fromFile = dotenv.env[key]?.trim();
      if (fromFile != null && fromFile.isNotEmpty) return fromFile;
    }
    if (fallback.isNotEmpty) return fallback;
    return null;
  }

  static bool get isConfigured {
    try {
      final url = supabaseUrl;
      final key = supabaseAnonKey;
      return url.isNotEmpty &&
          key.isNotEmpty &&
          !url.contains('your-project') &&
          !key.contains('your-anon');
    } catch (_) {
      return false;
    }
  }
}
