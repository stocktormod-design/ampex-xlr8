import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'bootstrap.dart';
import 'core/config/app_config.dart';
import 'core/config/env.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';

/// Initialiserer Supabase etter at Flutter er oppe.
///
/// Flutter tegner første frame umiddelbart (HTML-loader fjernes).
/// Brukeren ser «Kobler til …» i Flutter-UI, ikke evig HTML-tekst.
class AppStartup extends StatefulWidget {
  const AppStartup({super.key, required this.child});

  final Widget child;

  @override
  State<AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<AppStartup> {
  _StartupPhase _phase = _StartupPhase.loading;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    if (!Env.isConfigured) {
      setState(() {
        _phase = _StartupPhase.error;
        _error =
            'Mangler Supabase-konfigurasjon i .env.\n\n'
            'Kopier .env.example → .env og fyll inn SUPABASE_URL og SUPABASE_ANON_KEY, '
            'deretter stopp og start flutter run på nytt.';
      });
      return;
    }

    try {
      await Supabase.initialize(
        url: Env.supabaseUrl,
        anonKey: Env.supabaseAnonKey,
        authOptions: FlutterAuthClientOptions(
          detectSessionInUri: !kIsWeb,
        ),
      ).timeout(const Duration(seconds: 20));
      if (!mounted) return;
      setState(() => _phase = _StartupPhase.ready);
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _phase = _StartupPhase.error;
        _error =
            'Supabase svarte ikke innen 20 sekunder.\n\n'
            'Sjekk nett og .env-verdier (SUPABASE_URL, SUPABASE_ANON_KEY).';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _StartupPhase.error;
        _error = 'Kunne ikke koble til Supabase.\n\n$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_phase) {
      _StartupPhase.loading => MaterialApp(
          theme: AppTheme.light(),
          home: const _StartupScreen(),
        ),
      _StartupPhase.error => BootstrapErrorApp(message: _error),
      _StartupPhase.ready => widget.child,
    };
  }
}

enum _StartupPhase { loading, ready, error }

class _StartupScreen extends StatelessWidget {
  const _StartupScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppConfig.appName, style: AppTypography.largeTitle),
            const SizedBox(height: 36),
            const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
              ),
            ),
            const SizedBox(height: 16),
            Text('Kobler til …', style: AppTypography.callout),
          ],
        ),
      ),
    );
  }
}
