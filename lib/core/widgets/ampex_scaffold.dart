import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'ampex_glass.dart';
import 'offline_banner.dart';

/// Sideskall: gradient-bakteppe + glass-navbar + stor tittel.
///
/// Én sannhet for alle skjermer (iOS/Android/web føles likt).
class AmpexScaffold extends StatelessWidget {
  const AmpexScaffold({
    super.key,
    required this.title,
    required this.slivers,
    this.trailing,
    this.maxContentWidth = 440,
  });

  final String title;
  final List<Widget> slivers;
  final Widget? trailing;
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;

    return AmpexBackdrop(
      child: OfflineBanner(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Stack(
              children: [
                // Innhold scroller under den frostede baren.
                CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.screenH,
                          topPad + 64,
                          AppSpacing.screenH,
                          AppSpacing.md,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(title, style: AppTypography.largeTitle),
                            ),
                            ?trailing,
                          ],
                        ),
                      ),
                    ),
                    ...slivers,
                  ],
                ),
                // Frostet status-bar-stripe øverst.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        height: topPad + 8,
                        color: AppColors.glassBar.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
