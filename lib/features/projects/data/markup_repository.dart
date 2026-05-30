import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../domain/drawing_markup.dart';

final markupRepositoryProvider = Provider<MarkupRepository>((ref) {
  return MarkupRepository(ref.watch(appDatabaseProvider));
});

class MarkupRepository {
  MarkupRepository(this._db);

  final AppDatabase _db;

  Future<DrawingMarkupDocument> load(String drawingId) async {
    final row = await (_db.select(_db.localDrawingMarkups)
          ..where((t) => t.drawingId.equals(drawingId)))
        .getSingleOrNull();
    if (row == null) {
      return DrawingMarkupDocument(drawingId: drawingId, elements: []);
    }
    return DrawingMarkupDocument.decode(drawingId, row.payloadJson);
  }

  Future<void> save(DrawingMarkupDocument doc) async {
    await _db.into(_db.localDrawingMarkups).insertOnConflictUpdate(
          LocalDrawingMarkupsCompanion.insert(
            drawingId: doc.drawingId,
            payloadJson: doc.encode(),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
  }
}
