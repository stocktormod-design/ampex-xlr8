import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint(details.toString());
  };

  await runZonedGuarded(
    () async {
      await bootstrap(() async {
        if (bootstrapErrorMessage != null) {
          runApp(const BootstrapErrorApp());
          return;
        }
        runApp(const ProviderScope(child: AmpexApp()));
      });
    },
    (error, stack) {
      debugPrint('Ufanget feil: $error\n$stack');
      runApp(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Oppstartsfeil:\n$error'),
              ),
            ),
          ),
        ),
      );
    },
  );
}
