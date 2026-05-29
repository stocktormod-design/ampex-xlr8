import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Én rad i en [AmpexGroupedSection].
///
/// Samme API på alle plattformer. Chevron vises automatisk ved onTap.
class AmpexListRow extends StatelessWidget {
  const AmpexListRow({
    super.key,
    this.leading,
    this.leadingColor = AppColors.accent,
    required this.title,
    this.subtitle,
    this.trailing,
    this.value,
    this.onTap,
    this.destructive = false,
    this.showChevron,
  });

  /// Ikon vist til venstre i avrundet firkant.
  final IconData? leading;
  final Color leadingColor;
  final String title;
  final String? subtitle;

  /// Widget lengst til høyre (overstyrer [value] og standard chevron).
  final Widget? trailing;

  /// Tekst lengst til høyre (f.eks. verdi / status).
  final String? value;

  final VoidCallback? onTap;
  final bool destructive;

  /// Null = auto (vises hvis onTap er satt og ingen trailing/value).
  final bool? showChevron;

  @override
  Widget build(BuildContext context) {
    final effectiveShowChevron =
        showChevron ?? (onTap != null && trailing == null && value == null);

    final titleStyle = destructive
        ? AppTypography.body.copyWith(color: AppColors.destructive)
        : AppTypography.body;

    final row = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.rowH,
        vertical: AppSpacing.rowV,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            _LeadingIcon(icon: leading!, color: leadingColor),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: titleStyle),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: AppTypography.callout),
                ],
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          else if (value != null)
            Text(value!, style: AppTypography.callout)
          else if (effectiveShowChevron)
            const Icon(
              CupertinoIcons.chevron_forward,
              size: 16,
              color: AppColors.labelTertiary,
            ),
        ],
      ),
    );

    if (onTap == null) return row;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.pressed,
        highlightColor: AppColors.pressed,
        child: row,
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 17, color: Colors.white),
      ),
    );
  }
}
