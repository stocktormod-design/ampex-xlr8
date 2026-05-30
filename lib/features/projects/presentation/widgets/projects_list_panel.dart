import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ampex_empty_state.dart';
import '../../../../core/widgets/ampex_error_banner.dart';
import '../../../../core/widgets/ampex_list_row.dart';
import '../../../../core/widgets/ampex_search_field.dart';
import '../../../shared/status_labels.dart';
import '../../../shared/status_pill.dart';
import '../../data/projects_repository.dart';
import '../../domain/project.dart';
import '../projects_providers.dart';

/// Prosjektliste for Desktop split-view (venstre kolonne).
class ProjectsListPanel extends ConsumerStatefulWidget {
  const ProjectsListPanel({
    super.key,
    this.selectedProjectId,
    this.compact = true,
  });

  final String? selectedProjectId;
  final bool compact;

  @override
  ConsumerState<ProjectsListPanel> createState() => _ProjectsListPanelState();
}

class _ProjectsListPanelState extends ConsumerState<ProjectsListPanel> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Project> _filter(List<Project> projects) {
    if (_query.isEmpty) return projects;
    final q = _query.toLowerCase();
    return projects
        .where(
          (p) =>
              p.displayName.toLowerCase().contains(q) ||
              (p.subtitle?.toLowerCase().contains(q) ?? false) ||
              projectStatusLabel(p.status).toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsListProvider);

    return Material(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Prosjekter', style: AppTypography.title2),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: AmpexSearchField(
              controller: _searchController,
              hint: 'Søk…',
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: projectsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AmpexErrorBanner(
                      message: e is ProjectsException
                          ? e.message
                          : 'Kunne ikke laste prosjekter.',
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => ref.invalidate(projectsListProvider),
                      child: const Text('Prøv igjen'),
                    ),
                  ],
                ),
              ),
              data: (projects) {
                final filtered = _filter(projects);
                if (filtered.isEmpty) {
                  return const AmpexEmptyState(
                    icon: CupertinoIcons.building_2_fill,
                    title: 'Ingen prosjekter',
                    body: 'Prosjekter vises her.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (context, i) {
                    final project = filtered[i];
                    final selected = project.id == widget.selectedProjectId;
                    return Material(
                      color: selected
                          ? AppColors.accentSoft
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      child: AmpexListRow(
                        title: project.displayName,
                        subtitle: project.subtitle,
                        trailing: StatusPill(
                          label: projectStatusLabel(project.status),
                          color: projectStatusColor(project.status),
                        ),
                        showChevron: false,
                        onTap: () => context.go(
                          '${Routes.projects}/${project.id}',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
