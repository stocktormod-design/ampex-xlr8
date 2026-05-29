import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';

/// Last .env fra assets. Supabase init skjer i [AppStartup] etter [runApp].
Future<void> loadEnvironment() async {
  await dotenv.load(fileName: '.env');
}

/// Vises ved kritisk feil før eller under oppstart.
class BootstrapErrorApp extends StatelessWidget {
  const BootstrapErrorApp({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ampex', style: AppTypography.largeTitle),
                const SizedBox(height: 16),
                Text(message ?? 'Ukjent oppstartsfeil.', style: AppTypography.callout),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
