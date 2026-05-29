import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Inline feilmelding – ikke dialog, ikke SnackBar.
///
/// Brukes i skjemaskjermer (login, redigering). Rød bakgrunn kun ved
/// kritisk feil; ellers gul/oransje (advarsel).
class AmpexErrorBanner extends StatelessWidget {
  const AmpexErrorBanner({
    super.key,
    required this.message,
    this.severity = AmpexErrorSeverity.error,
  });

  final String message;
  final AmpexErrorSeverity severity;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (severity) {
      AmpexErrorSeverity.error => (
          AppColors.destructive.withValues(alpha: 0.10),
          AppColors.destructive,
          CupertinoIcons.exclamationmark_circle_fill,
        ),
      AmpexErrorSeverity.warning => (
          AppColors.warning.withValues(alpha: 0.12),
          AppColors.warning,
          CupertinoIcons.exclamationmark_triangle_fill,
        ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.sm + 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 4,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: fg, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppTypography.callout.copyWith(color: fg),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum AmpexErrorSeverity { error, warning }
