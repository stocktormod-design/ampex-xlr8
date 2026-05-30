import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'app_startup.dart';
import 'bootstrap.dart';
import 'core/config/app_config.dart';
import 'core/sync/sync_providers.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint(details.toString());
  };

  // runApp først så HTML-loader fjernes og brukeren ser Flutter-UI.
  runApp(
    const ProviderScope(
      child: _RootBootstrap(),
    ),
  );
}

/// Laster .env og starter resten av appen uten å blokkere første frame.
class _RootBootstrap extends StatefulWidget {
  const _RootBootstrap();

  @override
  State<_RootBootstrap> createState() => _RootBootstrapState();
}

class _RootBootstrapState extends State<_RootBootstrap> {
  _BootPhase _phase = _BootPhase.loadingEnv;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_loadEnv());
  }

  Future<void> _loadEnv() async {
    try {
      await loadEnvironment();
      if (!mounted) return;
      setState(() => _phase = _BootPhase.ready);
    } catch (e, stack) {
      debugPrint('Env load failed: $e\n$stack');
      if (!mounted) return;
      setState(() {
        _phase = _BootPhase.error;
        _error =
            'Kunne ikke laste .env.\n\n'
            'Kjør: cp .env.example .env\n'
            'Deretter: flutter pub get && flutter run\n\n$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_phase) {
      _BootPhase.loadingEnv => MaterialApp(
          theme: AppTheme.light(),
          home: const _HtmlHandoffScreen(),
        ),
      _BootPhase.error => BootstrapErrorApp(message: _error),
      _BootPhase.ready => AppStartup(
          child: const SyncOrchestrator(
            child: AmpexApp(),
          ),
        ),
    };
  }
}

enum _BootPhase { loadingEnv, ready, error }

/// Vises mens .env lastes – erstatter HTML «Laster appen …».
class _HtmlHandoffScreen extends StatelessWidget {
  const _HtmlHandoffScreen();

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
            Text('Starter …', style: AppTypography.callout),
          ],
        ),
      ),
    );
  }
}
