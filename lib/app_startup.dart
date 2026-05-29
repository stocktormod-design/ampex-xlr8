import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'bootstrap.dart';
import 'core/config/app_config.dart';
import 'core/config/env.dart';
import 'core/theme/app_theme.dart';

/// Initialiserer Supabase etter at Flutter er oppe (unngår evig HTML «Laster …»).
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
          // Unngår at web henter session fra URL ved localhost-dev.
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
            'Sjekk nett, .env-verdier og at redirect-URL er satt i Supabase Auth '
            '(http://localhost:8080 for lokal web).';
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
          home: const _StartupLoadingScreen(),
        ),
      _StartupPhase.error => BootstrapErrorApp(message: _error),
      _StartupPhase.ready => widget.child,
    };
  }
}

enum _StartupPhase { loading, ready, error }

class _StartupLoadingScreen extends StatelessWidget {
  const _StartupLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppConfig.appName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Kobler til Ampex …',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
