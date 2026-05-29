import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Primærknapp – én per skjerm.
///
/// [isLoading] viser spinner og disabler. Bruk [AmpexTextButton] for
/// sekundære handlinger.
class AmpexPrimaryButton extends StatelessWidget {
  const AmpexPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final disabled = isLoading || onPressed == null;

    return Opacity(
      opacity: disabled && !isLoading ? 0.5 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: AppRadius.buttonBorder,
          child: Ink(
            height: AppSpacing.minTouch + 8,
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: AppRadius.buttonBorder,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.32),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: isLoading
                    ? const SizedBox(
                        key: ValueKey('loading'),
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        key: const ValueKey('label'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (icon != null) ...[
                            Icon(icon, size: 18, color: Colors.white),
                            const SizedBox(width: AppSpacing.sm),
                          ],
                          Text(
                            label,
                            style: AppTypography.headline
                                .copyWith(color: Colors.white),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Sekundær / ghost tekst-knapp.
class AmpexTextButton extends StatelessWidget {
  const AmpexTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.destructive = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: destructive ? AppColors.destructive : AppColors.accent,
        minimumSize: const Size(0, AppSpacing.minTouch),
        textStyle: AppTypography.body,
      ),
      child: Text(label),
    );
  }
}
