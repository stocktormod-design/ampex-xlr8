import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get supabaseUrl => _require('SUPABASE_URL');
  static String get supabaseAnonKey => _require('SUPABASE_ANON_KEY');

  static String _require(String key) {
    if (!dotenv.isInitialized) {
      throw StateError('DotEnv er ikke lastet. Kjør bootstrap først.');
    }
    final value = dotenv.env[key]?.trim();
    if (value == null || value.isEmpty) {
      throw StateError(
        'Mangler $key i .env. Kopier .env.example og fyll inn Supabase-verdier.',
      );
    }
    return value;
  }

  static bool get isConfigured {
    if (!dotenv.isInitialized) return false;
    final url = dotenv.env['SUPABASE_URL']?.trim();
    final key = dotenv.env['SUPABASE_ANON_KEY']?.trim();
    return url != null &&
        url.isNotEmpty &&
        key != null &&
        key.isNotEmpty &&
        !url.contains('your-project');
  }
}
