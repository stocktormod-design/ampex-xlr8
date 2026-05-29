import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'ampex_glass.dart';

/// Gruppert seksjon på frostet glass (iOS Settings + glassmorfisme).
class AmpexGroupedSection extends StatelessWidget {
  const AmpexGroupedSection({
    super.key,
    this.header,
    this.footer,
    required this.children,
    this.margin = const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
    this.dividerIndent = 64,
  });

  final String? header;
  final String? footer;
  final List<Widget> children;
  final EdgeInsets margin;
  final double dividerIndent;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i < children.length - 1) {
        rows.add(Divider(
          height: 0.5,
          thickness: 0.5,
          indent: dividerIndent,
          color: AppColors.separator,
        ));
      }
    }

    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null)
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                bottom: AppSpacing.sm,
              ),
              child: Text(
                header!,
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                  color: AppColors.labelSecondary,
                ),
              ),
            ),
          AmpexGlass(
            elevated: true,
            child: Column(mainAxisSize: MainAxisSize.min, children: rows),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                top: AppSpacing.sm,
              ),
              child: Text(footer!, style: AppTypography.footnote),
            ),
        ],
      ),
    );
  }
}
