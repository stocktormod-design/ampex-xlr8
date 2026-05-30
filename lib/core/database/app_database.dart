import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';

import 'tables/cached_files.dart';
import 'tables/local_drawing_markups.dart';
import 'tables/local_orders.dart';
import 'tables/local_projects.dart';
import 'tables/sync_outbox.dart';
import 'tables/sync_state.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    SyncOutbox,
    SyncStates,
    CachedFiles,
    LocalOrders,
    LocalProjects,
    LocalDrawingMarkups,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(localOrders);
        await m.createTable(localProjects);
      }
      if (from < 3) {
        await m.createTable(localDrawingMarkups);
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'ampex',
      web: kIsWeb
          ? DriftWebOptions(
              sqlite3Wasm: Uri.parse('sqlite3.wasm'),
              driftWorker: Uri.parse('drift_worker.dart.js'),
            )
          : null,
    );
  }
}
