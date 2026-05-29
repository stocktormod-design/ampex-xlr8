import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Én rad i en [AmpexGroupedSection].
///
/// Samme API på alle plattformer. Chevron vises automatisk ved [onTap].
/// Komfortabel høyde (min 56pt) for felt-bruk og «glide»-følelse.
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

  final IconData? leading;
  final Color leadingColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final String? value;
  final VoidCallback? onTap;
  final bool destructive;
  final bool? showChevron;

  @override
  Widget build(BuildContext context) {
    final effectiveShowChevron =
        showChevron ?? (onTap != null && trailing == null && value == null);

    final titleStyle = destructive
        ? AppTypography.body.copyWith(color: AppColors.destructive)
        : AppTypography.body;

    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.rowH,
          vertical: 10,
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              _LeadingIcon(icon: leading!, color: leadingColor),
              const SizedBox(width: AppSpacing.md - 2),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: titleStyle),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTypography.footnote.copyWith(fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (value != null) ...[
              Text(value!, style: AppTypography.callout),
              if (effectiveShowChevron) ...[
                const SizedBox(width: AppSpacing.sm),
                const _Chevron(),
              ],
            ] else if (effectiveShowChevron)
              const _Chevron(),
          ],
        ),
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

class _Chevron extends StatelessWidget {
  const _Chevron();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      CupertinoIcons.chevron_forward,
      size: 15,
      color: AppColors.labelTertiary,
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: Colors.white),
    );
  }
}
