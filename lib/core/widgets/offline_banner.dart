import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../sync/sync_providers.dart';
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
    final pendingSync = ref.watch(pendingSyncCountProvider).valueOrNull ?? 0;

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
                      pendingSync > 0
                          ? 'Offline – $pendingSync endring(er) venter på synk.'
                          : 'Offline – endringer lagres og synkroniseres når du er på nett.',
                      style: AppTypography.footnote
                          .copyWith(color: AppColors.destructive),
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (pendingSync > 0)
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.statusWaiting.withValues(alpha: 0.12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.arrow_clockwise,
                    size: 16,
                    color: AppColors.statusWaiting,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Synkroniserer $pendingSync ventende endring(er)…',
                      style: AppTypography.footnote.copyWith(
                        color: AppColors.statusWaiting,
                      ),
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
