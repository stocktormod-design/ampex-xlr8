import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';

/// Prosesserer [SyncOutbox] mot Supabase når nett er tilgjengelig.
class SyncEngine {
  SyncEngine(this._db, this._client);

  final AppDatabase _db;
  final SupabaseClient _client;

  Future<SyncResult> runOnce() async {
    final pending = await _db.select(_db.syncOutbox).get();
    if (pending.isEmpty) {
      return const SyncResult(processed: 0, failed: 0);
    }

    var processed = 0;
    var failed = 0;

    for (final row in pending) {
      try {
        await _processRow(row);
        await (_db.delete(_db.syncOutbox)..where((t) => t.id.equals(row.id)))
            .go();
        processed++;
      } catch (_) {
        await (_db.update(_db.syncOutbox)..where((t) => t.id.equals(row.id)))
            .write(
          SyncOutboxCompanion(
            retryCount: Value(row.retryCount + 1),
          ),
        );
        failed++;
      }
    }

    return SyncResult(
      processed: processed,
      failed: failed,
      pending: pending.length - processed,
    );
  }

  Future<void> _processRow(SyncOutboxData row) async {
    final payload = jsonDecode(row.payload) as Map<String, dynamic>;

    switch (row.entityType) {
      case 'order_hours':
        if (row.operation == 'insert') {
          await _client.from('order_hours').insert(payload);
          return;
        }
        break;
    }

    throw UnsupportedError(
      'Ustøttet synk: ${row.entityType}.${row.operation}',
    );
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
