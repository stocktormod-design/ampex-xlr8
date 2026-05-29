import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'app_startup.dart';
import 'bootstrap.dart';
import 'core/sync/sync_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint(details.toString());
  };

  await runZonedGuarded(
    () async {
      try {
        await loadEnvironment();
      } catch (e) {
        runApp(
          BootstrapErrorApp(
            message:
                'Kunne ikke laste .env.\n\n'
                'Kjør: cp .env.example .env\n'
                'Deretter: flutter pub get && flutter run\n\n$e',
          ),
        );
        return;
      }

      runApp(
        ProviderScope(
          child: AppStartup(
            child: const SyncOrchestrator(
              child: AmpexApp(),
            ),
          ),
        ),
      );
    },
    (error, stack) {
      debugPrint('Ufanget feil: $error\n$stack');
      runApp(
        BootstrapErrorApp(message: 'Oppstartsfeil:\n$error'),
      );
    },
  );
}
