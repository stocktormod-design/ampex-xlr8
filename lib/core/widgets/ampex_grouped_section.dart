import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// iOS Settings / Spotify-list-seksjon.
///
/// Hvit avrundet boks på grå bakgrunn, med valgfri overskrift og fotnote.
/// Brukes overalt der innhold er gruppert – aldri løse Cards med ramme.
class AmpexGroupedSection extends StatelessWidget {
  const AmpexGroupedSection({
    super.key,
    this.header,
    this.footer,
    required this.children,
    this.margin = const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
    this.dividerIndent = 62,
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
        rows.add(Divider(height: 0.5, indent: dividerIndent));
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
                left: AppSpacing.sm,
                bottom: AppSpacing.xs + 2,
              ),
              child: Text(
                header!.toUpperCase(),
                style: AppTypography.caption.copyWith(
                  letterSpacing: 0.4,
                ),
              ),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.sectionBorder,
            ),
            child: ClipRRect(
              borderRadius: AppRadius.sectionBorder,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: rows,
              ),
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.sm,
                top: AppSpacing.xs + 2,
              ),
              child: Text(footer!, style: AppTypography.footnote),
            ),
        ],
      ),
    );
  }
}
