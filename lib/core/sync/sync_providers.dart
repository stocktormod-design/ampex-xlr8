import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database_provider.dart';
import '../network/is_online_provider.dart';
import '../network/supabase_provider.dart';
import '../widgets/offline_banner.dart';
import 'sync_engine.dart';
import 'sync_outbox_writer.dart';

final syncOutboxWriterProvider = Provider<SyncOutboxWriter>((ref) {
  return SyncOutboxWriter(ref.watch(appDatabaseProvider));
});

final syncEngineProvider = Provider<SyncEngine>((ref) {
  return SyncEngine(
    ref.watch(appDatabaseProvider),
    ref.watch(supabaseClientProvider),
  );
});

final pendingSyncCountProvider = FutureProvider<int>((ref) async {
  return ref.watch(syncOutboxWriterProvider).pendingCount();
});

/// Kjører synk når nett kommer tilbake.
class SyncOrchestrator extends ConsumerStatefulWidget {
  const SyncOrchestrator({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SyncOrchestrator> createState() => _SyncOrchestratorState();
}

class _SyncOrchestratorState extends ConsumerState<SyncOrchestrator> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncIfOnline());
  }

  Future<void> _syncIfOnline() async {
    if (!ref.read(isOnlineProvider)) return;
    try {
      await ref.read(syncEngineProvider).runOnce().timeout(
            const Duration(seconds: 15),
          );
      if (mounted) ref.invalidate(pendingSyncCountProvider);
    } catch (e, stack) {
      debugPrint('SyncOrchestrator: $e\n$stack');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(connectivityProvider, (previous, next) {
      next.whenData((results) {
        final online =
            results.isNotEmpty && results.any((r) => r != ConnectivityResult.none);
        if (online) _syncIfOnline();
      });
    });

    return widget.child;
  }
}
