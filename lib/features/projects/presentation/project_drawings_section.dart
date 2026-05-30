import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/storage/file_cache_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/ampex_grouped_section.dart';
import '../../../core/widgets/ampex_list_row.dart';
import '../domain/drawing.dart';
import 'drawings_providers.dart';

final drawingCachedProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, remotePath) {
  return ref.watch(fileCacheServiceProvider).isCached(remotePath);
});

/// Tegningsliste på prosjektdetalj.
class ProjectDrawingsSection extends ConsumerWidget {
  const ProjectDrawingsSection({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawingsAsync = ref.watch(projectDrawingsProvider(projectId));

    return drawingsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, _) => AmpexGroupedSection(
        header: 'Tegninger',
        footer: 'Kunne ikke laste tegninger.',
        dividerIndent: AppSpacing.rowH,
        children: const [
          AmpexListRow(
            leading: CupertinoIcons.exclamationmark_triangle,
            title: 'Feil ved lasting',
            showChevron: false,
          ),
        ],
      ),
      data: (drawings) {
        if (drawings.isEmpty) {
          return AmpexGroupedSection(
            header: 'Tegninger',
            footer: 'Publiserte tegninger vises her.',
            dividerIndent: AppSpacing.rowH,
            children: const [
              AmpexListRow(
                leading: CupertinoIcons.doc,
                title: 'Ingen tegninger',
                showChevron: false,
              ),
            ],
          );
        }

        final published =
            drawings.where((d) => d.isPublished).toList(growable: false);
        final drafts =
            drawings.where((d) => !d.isPublished).toList(growable: false);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (published.isNotEmpty)
              _DrawingGroup(
                header: 'Publisert',
                projectId: projectId,
                drawings: published,
              ),
            if (drafts.isNotEmpty) ...[
              if (published.isNotEmpty)
                const SizedBox(height: AppSpacing.sectionGap),
              _DrawingGroup(
                header: 'Utkast',
                projectId: projectId,
                drawings: drafts,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _DrawingGroup extends ConsumerWidget {
  const _DrawingGroup({
    required this.header,
    required this.projectId,
    required this.drawings,
  });

  final String header;
  final String projectId;
  final List<Drawing> drawings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AmpexGroupedSection(
      header: header,
      footer:
          'Åpne tegning for markering: linje, punkt, detektor, tekst og rom. Lagres lokalt.',
      dividerIndent: 64,
      children: [
        for (final drawing in drawings)
          _DrawingRow(projectId: projectId, drawing: drawing),
      ],
    );
  }
}

class _DrawingRow extends ConsumerWidget {
  const _DrawingRow({required this.projectId, required this.drawing});

  final String projectId;
  final Drawing drawing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cachedAsync = ref.watch(drawingCachedProvider(drawing.filePath));

    final trailing = cachedAsync.when(
      data: (cached) => Icon(
        cached ? CupertinoIcons.checkmark_circle : CupertinoIcons.cloud_download,
        size: 20,
        color: cached ? AppColors.statusDone : AppColors.labelTertiary,
      ),
      loading: () => const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );

    return AmpexListRow(
      leading: CupertinoIcons.doc_fill,
      leadingColor: AppColors.accent,
      title: drawing.displayName,
      subtitle: drawing.revisionLabel,
      trailing: trailing,
      showChevron: false,
      onTap: () => context.push('/prosjekter/$projectId/tegning/${drawing.id}'),
    );
  }
}
