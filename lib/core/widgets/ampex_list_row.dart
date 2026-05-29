import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Én rad i en [AmpexGroupedSection] – iOS Settings-stil ikoner.
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
        ? AppTypography.headline.copyWith(color: AppColors.destructive)
        : AppTypography.headline;

    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 52),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.rowH,
          vertical: 11,
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              _SoftIcon(icon: leading!, color: leadingColor),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: titleStyle),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(subtitle!, style: AppTypography.footnote),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (value != null) ...[
              Text(
                value!,
                style: AppTypography.callout.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (effectiveShowChevron) ...[
                const SizedBox(width: 6),
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
    return Icon(
      CupertinoIcons.chevron_forward,
      size: 14,
      color: AppColors.labelTertiary.withValues(alpha: 0.9),
    );
  }
}

/// Gradient ikon-chip – samme uttrykk som hurtigkortene.
class _SoftIcon extends StatelessWidget {
  const _SoftIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.9),
            color.withValues(alpha: 0.65),
          ],
        ),
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, size: 18, color: Colors.white),
    );
  }
}
