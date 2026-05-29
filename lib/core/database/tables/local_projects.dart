import 'package:drift/drift.dart';

/// Lokal cache av prosjekter for offline lesing (fase 1).
class LocalProjects extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get status => text()();
  TextColumn get siteAddress => text().nullable()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get detailJson => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
