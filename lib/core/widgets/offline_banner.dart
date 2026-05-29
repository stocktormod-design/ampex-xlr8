import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  if (kIsWeb) {
    return Stream.value([ConnectivityResult.wifi]);
  }
  return Connectivity().onConnectivityChanged;
});

/// Viser diskret offline-banner øverst når nettforbindelsen er borte.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(connectivityProvider).maybeWhen(
          data: (r) => r.isEmpty || r.every((x) => x == ConnectivityResult.none),
          orElse: () => false,
        );

    return Column(
      children: [
        if (isOffline)
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.destructive.withValues(alpha: 0.10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.wifi_slash,
                    size: 16,
                    color: AppColors.destructive,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Offline – endringer lagres og synkroniseres når du er på nett.',
                      style: AppTypography.footnote
                          .copyWith(color: AppColors.destructive),
                    ),
                  ),
                ],
              ),
            ),
          ),
        Expanded(child: child),
      ],
    );
  }
}
