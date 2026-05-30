import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../platform/app_product_provider.dart';
import '../theme/app_breakpoints.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'ampex_glass.dart';
import 'offline_banner.dart';

/// Sideskall: flat bakgrunn + stor tittel + responsiv innholdsbredde.
///
/// Én sannhet for alle skjermer. Innholdet får en lesbar maks-bredde og
/// fyller bredden på mobil – aldri en tynn boks som flyter midt på skjermen.
class AmpexScaffold extends StatelessWidget {
  const AmpexScaffold({
    super.key,
    required this.title,
    required this.slivers,
    this.trailing,
    this.subtitle,
    this.eyebrow,
    this.onBack,
    this.onRefresh,
    this.maxContentWidth = 1040,
  });

  final String title;
  final List<Widget> slivers;
  final Widget? trailing;
  final Widget? subtitle;
  final String? eyebrow;
  final VoidCallback? onBack;
  final Future<void> Function()? onRefresh;
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    final isMobile = context.isMobile;
    final simPhone = context.isSimulatedAmpexMobile;
    final hPad = isMobile ? AppSpacing.screenH : AppSpacing.xl;

    final scrollContent = _scrollBody(
                  topPad: topPad,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          hPad,
                          topPad + (simPhone ? 16 : (isMobile ? 52 : 28)),
                          hPad,
                          AppSpacing.md,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (onBack != null) ...[
                              Padding(
                                padding: const EdgeInsets.only(top: 2, right: 4),
                                child: IconButton(
                                  onPressed: onBack,
                                  icon: const Icon(CupertinoIcons.back, size: 26),
                                  color: AppColors.accent,
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 36,
                                    minHeight: 36,
                                  ),
                                ),
                              ),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (eyebrow != null) ...[
                                    Text(
                                      eyebrow!.toUpperCase(),
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.labelTertiary,
                                        letterSpacing: 1.2,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                  ],
                                  Text(title, style: AppTypography.largeTitle),
                                  if (subtitle != null) ...[
                                    const SizedBox(height: AppSpacing.xs + 2),
                                    subtitle!,
                                  ],
                                ],
                              ),
                            ),
                            if (trailing != null) ...[
                              const SizedBox(width: AppSpacing.md),
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: trailing!,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    ...slivers,
                    SliverToBoxAdapter(
                      child: SizedBox(height: isMobile ? 96 : AppSpacing.xl),
                    ),
                  ],
                );

    return AmpexBackdrop(
      child: OfflineBanner(
        child: Stack(
          children: [
            if (simPhone)
              scrollContent
            else
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: scrollContent,
                ),
              ),
            if (topPad > 0 && !simPhone)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AmpexBarBlur(
                  child: Container(
                    height: topPad,
                    color: AppColors.barBackground.withValues(alpha: 0.6),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _scrollBody({
    required double topPad,
    required List<Widget> slivers,
  }) {
    final scrollView = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: slivers,
    );

    if (onRefresh == null) return scrollView;

    return RefreshIndicator(
      onRefresh: onRefresh!,
      color: AppColors.accent,
      edgeOffset: topPad + 48,
      child: scrollView,
    );
  }
}
