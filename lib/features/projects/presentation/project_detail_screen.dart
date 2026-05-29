import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_breakpoints.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/ampex_empty_state.dart';
import '../../../core/widgets/ampex_grouped_section.dart';
import '../../../core/widgets/ampex_list_row.dart';
import '../../../core/widgets/ampex_scaffold.dart';
import '../../shared/status_labels.dart';
import 'drawings_providers.dart';
import 'project_drawings_section.dart';
import 'projects_providers.dart';

class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectDetailProvider(id));
    final hPad = context.isMobile ? AppSpacing.screenH : AppSpacing.xl;
    final dateFmt = DateFormat('d. MMM yyyy', 'nb');

    return projectAsync.when(
      loading: () => AmpexScaffold(
        title: 'Prosjekt',
        onBack: () => context.pop(),
        slivers: const [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        ],
      ),
      error: (_, _) => AmpexScaffold(
        title: 'Prosjekt',
        onBack: () => context.pop(),
        slivers: const [
          SliverFillRemaining(
            hasScrollBody: false,
            child: AmpexEmptyState(
              icon: CupertinoIcons.exclamationmark_triangle,
              title: 'Kunne ikke laste',
              body: 'Prosjektet finnes ikke eller du har ikke tilgang.',
            ),
          ),
        ],
      ),
      data: (project) {
        if (project == null) {
          return AmpexScaffold(
            title: 'Prosjekt',
            onBack: () => context.pop(),
            slivers: const [
              SliverFillRemaining(
                hasScrollBody: false,
                child: AmpexEmptyState(
                  icon: CupertinoIcons.building_2_fill,
                  title: 'Ikke funnet',
                  body: 'Prosjektet finnes ikke.',
                ),
              ),
            ],
          );
        }

        return AmpexScaffold(
          title: project.displayName,
          subtitle: project.siteAddress != null
              ? Text(project.siteAddress!, style: const TextStyle(fontSize: 15))
              : null,
          onBack: () => context.pop(),
          onRefresh: () async {
            ref.invalidate(projectDetailProvider(id));
            ref.invalidate(projectDrawingsProvider(id));
          },
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AmpexGroupedSection(
                    margin: EdgeInsets.symmetric(horizontal: hPad),
                    header: 'Oversikt',
                    dividerIndent: AppSpacing.rowH,
                    children: [
                      AmpexListRow(
                        title: 'Status',
                        value: projectStatusLabel(project.status),
                        showChevron: false,
                      ),
                      AmpexListRow(
                        title: 'Opprettet',
                        value: dateFmt.format(project.createdAt.toLocal()),
                        showChevron: false,
                      ),
                    ],
                  ),
                  if (project.siteAddress != null &&
                      project.siteAddress!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sectionGap),
                    AmpexGroupedSection(
                      margin: EdgeInsets.symmetric(horizontal: hPad),
                      header: 'Anlegg',
                      dividerIndent: AppSpacing.rowH,
                      children: [
                        AmpexListRow(
                          title: 'Adresse',
                          value: project.siteAddress,
                          showChevron: false,
                        ),
                      ],
                    ),
                  ],
                  if (project.description != null &&
                      project.description!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sectionGap),
                    AmpexGroupedSection(
                      margin: EdgeInsets.symmetric(horizontal: hPad),
                      header: 'Beskrivelse',
                      dividerIndent: AppSpacing.rowH,
                      children: [
                        AmpexListRow(
                          title: project.description!,
                          showChevron: false,
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sectionGap),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: hPad),
                    child: ProjectDrawingsSection(projectId: id),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
