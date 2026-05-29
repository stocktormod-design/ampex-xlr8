import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ampex_empty_state.dart';
import '../../../core/widgets/ampex_scaffold.dart';

/// Erstattes med ordreliste i fase 1.
class OrdersPlaceholderScreen extends StatelessWidget {
  const OrdersPlaceholderScreen({super.key, this.id});

  final String? id;

  @override
  Widget build(BuildContext context) {
    if (id != null) return _OrderDetailPlaceholder(id: id!);

    return AmpexScaffold(
      title: 'Ordre',
      slivers: [
        const SliverFillRemaining(
          hasScrollBody: false,
          child: AmpexEmptyState(
            icon: CupertinoIcons.doc_text,
            title: 'Ingen ordre ennå',
            body: 'Ordreliste og dokumentasjon\nkommer i fase 1.',
          ),
        ),
      ],
    );
  }
}

class _OrderDetailPlaceholder extends StatelessWidget {
  const _OrderDetailPlaceholder({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Ordre', style: AppTypography.headline),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => context.pop(),
        ),
      ),
      body: AmpexEmptyState(
        icon: CupertinoIcons.doc_text,
        title: 'Ordredetalj',
        body: 'Detaljer for ordre $id\nkommer i fase 1.',
      ),
    );
  }
}
