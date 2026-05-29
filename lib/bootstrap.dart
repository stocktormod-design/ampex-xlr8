import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Last .env fra assets. Supabase init skjer i [AppStartup] etter [runApp].
Future<void> loadEnvironment() async {
  await dotenv.load(fileName: '.env');
}

/// Vises ved feil før hovedappen starter.
class BootstrapErrorApp extends StatelessWidget {
  const BootstrapErrorApp({super.key, this.message});

  final String? message;

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
                Text(message ?? 'Ukjent oppstartsfeil.'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
