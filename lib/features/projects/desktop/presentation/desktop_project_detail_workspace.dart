import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens/design_tokens.dart';
import '../../../../core/widgets/ampex_empty_state.dart';
import '../../../../core/widgets/ampex_grouped_section.dart';
import '../../../../core/widgets/ampex_list_row.dart';
import '../../../shared/status_labels.dart';
import '../../presentation/project_drawings_section.dart';
import '../../presentation/projects_providers.dart';

/// Ampex Desktop – prosjektdetalj: tegning + rom/oppgaver/fremdrift samtidig.
class DesktopProjectDetailWorkspace extends ConsumerWidget {
  const DesktopProjectDetailWorkspace({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectDetailProvider(projectId));
    final dateFmt = DateFormat('d. MMM yyyy', 'nb');

    return projectAsync.when(
      loading: () => const ColoredBox(
        color: AppColors.background,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => const ColoredBox(
        color: AppColors.background,
        child: AmpexEmptyState(
          icon: CupertinoIcons.exclamationmark_triangle,
          title: 'Kunne ikke laste',
          body: 'Prosjektet finnes ikke eller du har ikke tilgang.',
        ),
      ),
      data: (project) {
        if (project == null) {
          return const ColoredBox(
            color: AppColors.background,
            child: AmpexEmptyState(
              icon: CupertinoIcons.building_2_fill,
              title: 'Ikke funnet',
              body: 'Prosjektet finnes ikke.',
            ),
          );
        }

        return ColoredBox(
          color: AppColors.background,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: _DrawingPane(
                  projectId: projectId,
                  projectName: project.displayName,
                  address: project.siteAddress,
                  status: projectStatusLabel(project.status),
                  created: dateFmt.format(project.createdAt.toLocal()),
                ),
              ),
              const VerticalDivider(width: 1, color: AppColors.border),
              SizedBox(
                width: DesignTokens.desktopInspectorWidth,
                child: _InspectorPane(projectId: projectId),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DrawingPane extends StatelessWidget {
  const _DrawingPane({
    required this.projectId,
    required this.projectName,
    required this.status,
    required this.created,
    this.address,
  });

  final String projectId;
  final String projectName;
  final String? address;
  final String status;
  final String created;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(projectName, style: AppTypography.title1),
                if (address != null && address!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(address!, style: AppTypography.callout),
                ],
                const SizedBox(height: 16),
                AmpexGroupedSection(
                  header: 'Oversikt',
                  dividerIndent: AppSpacing.rowH,
                  children: [
                    AmpexListRow(
                      title: 'Status',
                      value: status,
                      showChevron: false,
                    ),
                    AmpexListRow(
                      title: 'Opprettet',
                      value: created,
                      showChevron: false,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Tegninger', style: AppTypography.headline),
                const SizedBox(height: 8),
                Text(
                  'Åpne tegning i stort vindu for markering og sløyfer.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.labelSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                ProjectDrawingsSection(projectId: projectId),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InspectorPane extends StatelessWidget {
  const _InspectorPane({required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Rom', style: AppTypography.headline),
          const SizedBox(height: 8),
          Text(
            'Rom, oppgaver og fremdrift vises her når hierarkiet er koblet til Supabase.',
            style: AppTypography.caption.copyWith(
              color: AppColors.labelSecondary,
            ),
          ),
          const SizedBox(height: 24),
          _placeholderSection('Oppgaver', CupertinoIcons.checkmark_circle),
          const SizedBox(height: 16),
          _placeholderSection('Fremdrift', CupertinoIcons.chart_bar),
          const SizedBox(height: 16),
          _placeholderSection('Avvik', CupertinoIcons.exclamationmark_triangle),
        ],
      ),
    );
  }

  Widget _placeholderSection(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceHighlight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.labelTertiary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: AppTypography.callout.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text('Kommer', style: AppTypography.caption),
        ],
      ),
    );
  }
}
