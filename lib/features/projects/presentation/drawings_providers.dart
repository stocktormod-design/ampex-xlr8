import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/drawings_repository.dart';
import '../domain/drawing.dart';

final projectDrawingsProvider =
    FutureProvider.autoDispose.family<List<Drawing>, String>((ref, projectId) {
  return ref.watch(drawingsRepositoryProvider).listForProject(projectId);
});

final drawingProvider =
    FutureProvider.autoDispose.family<Drawing?, String>((ref, drawingId) {
  return ref.watch(drawingsRepositoryProvider).getById(drawingId);
});
