import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/is_online_provider.dart';
import '../data/projects_repository.dart';
import '../domain/project.dart';

final projectsListProvider =
    FutureProvider.autoDispose<List<Project>>((ref) async {
  final repo = ref.watch(projectsRepositoryProvider);
  final online = ref.watch(isOnlineProvider);
  return repo.listProjects(online: online);
});

final projectDetailProvider =
    FutureProvider.autoDispose.family<Project?, String>((ref, id) async {
  final repo = ref.watch(projectsRepositoryProvider);
  final online = ref.watch(isOnlineProvider);
  return repo.getProject(id, online: online);
});

final projectsCountProvider = Provider<int>((ref) {
  return ref.watch(projectsListProvider).maybeWhen(
        data: (projects) => projects.length,
        orElse: () => 0,
      );
});
