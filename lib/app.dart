import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';
import 'core/config/env.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_typography.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/ampex_web_frame.dart';

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
      scrollBehavior: _AmpexScrollBehavior(),
      locale: const Locale('nb'),
      supportedLocales: const [Locale('nb')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) =>
          AmpexWebFrame(child: child ?? const SizedBox.shrink()),
      routerConfig: router,
    );
  }
}

/// Bouncing scroll på alle plattformer (iOS-feeling).
class _AmpexScrollBehavior extends MaterialScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
}

class _EnvMissingScreen extends StatelessWidget {
  const _EnvMissingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppConfig.appName, style: AppTypography.largeTitle),
              const SizedBox(height: 16),
              Text(
                'Mangler Supabase-konfigurasjon.\n\n'
                '1. cp .env.example .env\n'
                '2. Fyll inn SUPABASE_URL og SUPABASE_ANON_KEY\n'
                '3. Stopp appen og kjør flutter run på nytt',
                style: AppTypography.callout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
