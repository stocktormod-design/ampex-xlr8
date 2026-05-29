import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/routes.dart';
import '../../../core/theme/app_breakpoints.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/ampex_empty_state.dart';
import '../../../core/widgets/ampex_error_banner.dart';
import '../../../core/widgets/ampex_grouped_section.dart';
import '../../../core/widgets/ampex_list_row.dart';
import '../../../core/widgets/ampex_scaffold.dart';
import '../../../core/widgets/ampex_search_field.dart';
import '../../shared/status_labels.dart';
import '../../shared/status_pill.dart';
import '../data/projects_repository.dart';
import '../domain/project.dart';
import 'projects_providers.dart';

class ProjectsListScreen extends ConsumerStatefulWidget {
  const ProjectsListScreen({super.key});

  @override
  ConsumerState<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends ConsumerState<ProjectsListScreen> {
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
    final hPad = context.isMobile ? AppSpacing.screenH : AppSpacing.xl;

    return AmpexScaffold(
      title: 'Prosjekter',
      onRefresh: () => ref.refresh(projectsListProvider.future),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(hPad, 0, hPad, AppSpacing.md),
            child: AmpexSearchField(
              controller: _searchController,
              hint: 'Søk prosjekt, adresse…',
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
          ),
        ),
        projectsAsync.when(
          loading: () => const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (e, _) => SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.all(hPad),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AmpexErrorBanner(
                    message: e is ProjectsException
                        ? e.message
                        : 'Kunne ikke laste prosjekter.',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    onPressed: () => ref.invalidate(projectsListProvider),
                    child: const Text('Prøv igjen'),
                  ),
                ],
              ),
            ),
          ),
          data: (projects) {
            final filtered = _filter(projects);

            if (projects.isEmpty) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: AmpexEmptyState(
                  icon: CupertinoIcons.building_2_fill,
                  title: 'Ingen prosjekter',
                  body: 'Prosjekter du har tilgang til\nvises her.',
                ),
              );
            }

            if (filtered.isEmpty) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: AmpexEmptyState(
                  icon: CupertinoIcons.search,
                  title: 'Ingen treff',
                  body: 'Prøv et annet søkeord.',
                ),
              );
            }

            return SliverToBoxAdapter(
              child: AmpexGroupedSection(
                margin: EdgeInsets.symmetric(horizontal: hPad),
                dividerIndent: AppSpacing.rowH,
                children: [
                  for (final project in filtered)
                    AmpexListRow(
                      title: project.displayName,
                      subtitle: project.subtitle,
                      trailing: StatusPill(
                        label: projectStatusLabel(project.status),
                        color: projectStatusColor(project.status),
                      ),
                      showChevron: false,
                      onTap: () =>
                          context.push('${Routes.projects}/${project.id}'),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
