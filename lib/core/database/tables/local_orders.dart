import 'package:drift/drift.dart';

/// Lokal cache av ordre for offline lesing (fase 1).
class LocalOrders extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get status => text()();
  TextColumn get type => text().nullable()();
  TextColumn get customerName => text().nullable()();
  TextColumn get customerPhone => text().nullable()();
  TextColumn get customerAddress => text().nullable()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get detailJson => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
