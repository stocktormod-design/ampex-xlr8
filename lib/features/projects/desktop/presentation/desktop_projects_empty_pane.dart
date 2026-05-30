import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Desktop: høyre panel når ingen prosjekt er valgt.
class DesktopProjectsEmptyPane extends StatelessWidget {
  const DesktopProjectsEmptyPane({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.building_2_fill,
                size: 48,
                color: AppColors.labelTertiary.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 16),
              Text(
                'Velg et prosjekt',
                style: AppTypography.title2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Se tegning, rom, oppgaver og fremdrift — alt på ett sted.',
                style: AppTypography.callout.copyWith(
                  color: AppColors.labelSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
