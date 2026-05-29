import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'offline_banner.dart';

/// Sideskall for alle listeskjermer.
///
/// – Venstrejustert large title (iOS HIG), aldri sentrert.
/// – Innhold sentreres med maks bredde på brede skjermer (web/nettbrett),
///   full bredde på telefon → samme produkt overalt.
/// – Bouncing scroll + offline-banner.
class AmpexScaffold extends StatelessWidget {
  const AmpexScaffold({
    super.key,
    required this.title,
    required this.slivers,
    this.subtitle,
    this.actions,
    this.maxContentWidth = 640,
    this.backgroundColor = AppColors.background,
  });

  /// Stor venstrejustert tittel. Kan være en hilsen (hjem) eller skjermnavn.
  final String title;

  /// Valgfri rad rett under tittelen (firma, status, rolle …).
  final Widget? subtitle;

  final List<Widget> slivers;
  final List<Widget>? actions;
  final double maxContentWidth;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: OfflineBanner(
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(child: _Header(
                    title: title,
                    subtitle: subtitle,
                    actions: actions,
                  )),
                  ...slivers,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, this.subtitle, this.actions});

  final String title;
  final Widget? subtitle;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.md,
        AppSpacing.screenH,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.largeTitle,
                ),
              ),
              if (actions != null) ...[
                const SizedBox(width: AppSpacing.sm),
                ...actions!,
              ],
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.sm),
            subtitle!,
          ],
        ],
      ),
    );
  }
}
