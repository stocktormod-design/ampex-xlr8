import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/offline_banner.dart';

/// Om appen har nett (brukes av repositories for synk vs. kun cache).
final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider).maybeWhen(
        data: (results) =>
            results.isNotEmpty &&
            results.any((r) => r != ConnectivityResult.none),
        orElse: () => true,
      );
});
