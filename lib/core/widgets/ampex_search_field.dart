import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Søkefelt for lister – iOS-inspirert, rent uttrykk.
class AmpexSearchField extends StatelessWidget {
  const AmpexSearchField({
    super.key,
    required this.controller,
    this.hint = 'Søk',
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: AppTypography.body,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.body.copyWith(color: AppColors.labelPlaceholder),
        prefixIcon: const Icon(
          CupertinoIcons.search,
          size: 20,
          color: AppColors.labelTertiary,
        ),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              onPressed: () {
                controller.clear();
                onChanged?.call('');
              },
              icon: const Icon(
                CupertinoIcons.xmark_circle_fill,
                size: 20,
                color: AppColors.labelTertiary,
              ),
            );
          },
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm + 2,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent),
        ),
      ),
    );
  }
}
