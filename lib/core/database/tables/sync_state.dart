import 'package:drift/drift.dart';

class SyncStates extends Table {
  TextColumn get entityType => text()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  TextColumn get cursor => text().nullable()();

  @override
  Set<Column> get primaryKey => {entityType};
}
