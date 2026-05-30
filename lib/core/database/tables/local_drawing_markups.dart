import 'package:drift/drift.dart';

/// Lokale markeringer på tegninger (linje, detektor, rom, osv.).
class LocalDrawingMarkups extends Table {
  TextColumn get drawingId => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {drawingId};
}
