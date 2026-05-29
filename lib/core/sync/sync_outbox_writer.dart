import 'dart:convert';

import '../database/app_database.dart';

/// Skriver ventende mutasjoner til [SyncOutbox].
class SyncOutboxWriter {
  SyncOutboxWriter(this._db);

  final AppDatabase _db;

  Future<void> enqueue({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    await _db.into(_db.syncOutbox).insert(
          SyncOutboxCompanion.insert(
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            payload: jsonEncode(payload),
          ),
        );
  }

  Future<int> pendingCount() async {
    final rows = await _db.select(_db.syncOutbox).get();
    return rows.length;
  }
}
