import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Standard mørkt dashboard-kort.
class DashboardCard extends StatelessWidget {
  const DashboardCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.header,
    this.trailingLink,
    this.onTrailingTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final String? header;
  final String? trailingLink;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.sectionBorder,
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (header != null) ...[
              Row(
                children: [
                  Text(
                    header!,
                    style: AppTypography.headline.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (trailingLink != null)
                    GestureDetector(
                      onTap: onTrailingTap,
                      child: Text(
                        trailingLink!,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.labelSecondary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

/// Hvit primærknapp (erstatter blå i mockup).
class DashboardPrimaryButton extends StatelessWidget {
  const DashboardPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.accent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTypography.headline.copyWith(
                  color: AppColors.onAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 6),
                Icon(icon, size: 16, color: AppColors.onAccent),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardLinkButton extends StatelessWidget {
  const DashboardLinkButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTypography.callout.copyWith(
                  color: AppColors.label,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.label),
            ],
          ),
        ),
      ),
    );
  }
}
