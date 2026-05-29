import '../database/app_database.dart';

/// Prosesserer [SyncOutbox] mot Supabase når nett er tilgjengelig.
/// Grunnmur: skjelett uten entitets-spesifikk logikk.
class SyncEngine {
  SyncEngine(this._db);

  final AppDatabase _db;

  Future<SyncResult> runOnce() async {
    final pending = await _db.select(_db.syncOutbox).get();
    if (pending.isEmpty) {
      return const SyncResult(processed: 0, failed: 0);
    }
    // Entitets-synk implementeres i fase 1.
    return SyncResult(processed: 0, failed: 0, pending: pending.length);
  }
}

class SyncResult {
  const SyncResult({
    required this.processed,
    required this.failed,
    this.pending = 0,
  });

  final int processed;
  final int failed;
  final int pending;
}
