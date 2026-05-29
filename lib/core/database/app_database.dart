import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/cached_files.dart';
import 'tables/local_orders.dart';
import 'tables/local_projects.dart';
import 'tables/sync_outbox.dart';
import 'tables/sync_state.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  SyncOutbox,
  SyncStates,
  CachedFiles,
  LocalOrders,
  LocalProjects,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(localOrders);
            await m.createTable(localProjects);
          }
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'ampex');
  }
}
