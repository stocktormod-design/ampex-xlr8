import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';
import 'core/config/env.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
class AmpexApp extends ConsumerWidget {
  const AmpexApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!Env.isConfigured) {
      return MaterialApp(
        title: AppConfig.appName,
        theme: AppTheme.light(),
        home: const _EnvMissingScreen(),
      );
    }

    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConfig.appName,
      theme: AppTheme.light(),
      locale: const Locale('nb'),
      supportedLocales: const [Locale('nb')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}

class _EnvMissingScreen extends StatelessWidget {
  const _EnvMissingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConfig.appName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              const Text(
                'Mangler Supabase-konfigurasjon.\n\n'
                'Kopier .env.example til .env og fyll inn SUPABASE_URL og SUPABASE_ANON_KEY.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
