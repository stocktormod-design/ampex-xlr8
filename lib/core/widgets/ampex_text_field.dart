import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Tekstfelt som følger Ampex-designsystemet.
///
/// Brukes inni [AmpexGroupedSection] – dekorasjon settes av seksjon,
/// ikke av feltet selv (ingen synlig ramme/bakgrunn).
class AmpexTextField extends StatelessWidget {
  const AmpexTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.autocorrect = true,
    this.autofillHints,
    this.onSubmitted,
    this.validator,
    this.suffix,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String hint;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool autocorrect;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final Widget? suffix;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      autocorrect: autocorrect,
      autofillHints: autofillHints,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      inputFormatters: inputFormatters,
      style: AppTypography.body,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.body.copyWith(color: AppColors.labelPlaceholder),
        suffixIcon: suffix,
        // Fjern all dekorasjon – seksjon-bakgrunnen er rammen
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.rowH,
          vertical: AppSpacing.rowV,
        ),
        filled: false,
        errorStyle: AppTypography.footnote.copyWith(
          color: AppColors.destructive,
          height: 0.1,
        ),
      ),
    );
  }
}
