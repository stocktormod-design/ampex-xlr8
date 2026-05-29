import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ampex_empty_state.dart';
import '../../../core/widgets/ampex_scaffold.dart';

/// Erstattes med prosjektliste i fase 1.
class ProjectsPlaceholderScreen extends StatelessWidget {
  const ProjectsPlaceholderScreen({super.key, this.id});

  final String? id;

  @override
  Widget build(BuildContext context) {
    if (id != null) return _ProjectDetailPlaceholder(id: id!);

    return AmpexScaffold(
      title: 'Prosjekter',
      slivers: [
        const SliverFillRemaining(
          hasScrollBody: false,
          child: AmpexEmptyState(
            icon: CupertinoIcons.building_2_fill,
            title: 'Ingen prosjekter ennå',
            body: 'Prosjektliste med tegninger,\nPDF og fremdrift kommer i fase 1.',
          ),
        ),
      ],
    );
  }
}

class _ProjectDetailPlaceholder extends StatelessWidget {
  const _ProjectDetailPlaceholder({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Prosjekter', style: AppTypography.headline),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => context.pop(),
        ),
      ),
      body: AmpexEmptyState(
        icon: CupertinoIcons.building_2_fill,
        title: 'Prosjektdetalj',
        body: 'Detaljer for prosjekt $id\nkommer i fase 1.',
      ),
    );
  }
}
