import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'offline_banner.dart';

/// Sideskall med large title og bouncing scroll – brukes på alle plattformer.
///
/// Produserer én konsistent side-layout uavhengig av om koden kjører på
/// iOS, Android eller web.
class AmpexScaffold extends StatelessWidget {
  const AmpexScaffold({
    super.key,
    required this.title,
    required this.slivers,
    this.actions,
    this.backgroundColor = AppColors.background,
  });

  final String title;
  final List<Widget> slivers;
  final List<Widget>? actions;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: OfflineBanner(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            _AmpexSliverHeader(
              title: title,
              backgroundColor: backgroundColor,
              actions: actions,
            ),
            ...slivers,
          ],
        ),
      ),
    );
  }
}

class _AmpexSliverHeader extends StatelessWidget {
  const _AmpexSliverHeader({
    required this.title,
    required this.backgroundColor,
    this.actions,
  });

  final String title;
  final Color backgroundColor;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: 96,
      backgroundColor: backgroundColor,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      actions: actions,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final isCollapsed = constraints.maxHeight <=
              kToolbarHeight + MediaQuery.paddingOf(context).top + 4;
          return FlexibleSpaceBar(
            titlePadding: EdgeInsetsDirectional.fromSTEB(
              AppSpacing.screenH,
              0,
              AppSpacing.screenH,
              isCollapsed ? 14 : 8,
            ),
            title: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 150),
              style: isCollapsed
                  ? AppTypography.headline
                  : AppTypography.title1,
              child: Text(title),
            ),
            background: const ColoredBox(color: AppColors.background),
          );
        },
      ),
    );
  }
}
