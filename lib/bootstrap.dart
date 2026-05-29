import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/env.dart';

/// Satt hvis oppstart feiler før [runApp] (vises i [BootstrapErrorApp]).
String? bootstrapErrorMessage;

Future<void> bootstrap(Future<void> Function() runApp) async {
  WidgetsFlutterBinding.ensureInitialized();
  bootstrapErrorMessage = null;

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    bootstrapErrorMessage =
        'Kunne ikke laste .env. Kjør «flutter pub get» og start appen på nytt.\n\n$e';
  }

  if (bootstrapErrorMessage == null && Env.isConfigured) {
    try {
      await Supabase.initialize(
        url: Env.supabaseUrl,
        anonKey: Env.supabaseAnonKey,
      );
    } catch (e) {
      bootstrapErrorMessage =
          'Kunne ikke koble til Supabase. Sjekk SUPABASE_URL og SUPABASE_ANON_KEY i .env.\n\n$e';
    }
  }

  await runApp();
}

/// Vises når [bootstrapErrorMessage] er satt.
class BootstrapErrorApp extends StatelessWidget {
  const BootstrapErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ampex',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Text(bootstrapErrorMessage ?? 'Ukjent oppstartsfeil.'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
