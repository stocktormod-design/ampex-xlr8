import 'package:drift/drift.dart';

class CachedFiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get remotePath => text().unique()();
  TextColumn get localPath => text()();
  TextColumn get mimeType => text().nullable()();
  TextColumn get entityType => text().nullable()();
  TextColumn get entityId => text().nullable()();
  DateTimeColumn get openedAt => dateTime()();
  IntColumn get sizeBytes => integer().nullable()();
}
