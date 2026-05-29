import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Ampex typografi – Inter for en stram, profesjonell SaaS-følelse.
abstract final class AppTypography {
  static TextStyle _font({
    required double size,
    required FontWeight weight,
    required Color color,
    double height = 1.35,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle get largeTitle => _font(
        size: 28,
        weight: FontWeight.w600,
        color: AppColors.label,
        height: 1.2,
        letterSpacing: -0.6,
      );

  static TextStyle get title1 => _font(
        size: 24,
        weight: FontWeight.w600,
        color: AppColors.label,
        height: 1.2,
        letterSpacing: -0.5,
      );

  static TextStyle get title2 => _font(
        size: 18,
        weight: FontWeight.w600,
        color: AppColors.label,
        height: 1.3,
        letterSpacing: -0.3,
      );

  static TextStyle get headline => _font(
        size: 14,
        weight: FontWeight.w600,
        color: AppColors.label,
        height: 1.4,
        letterSpacing: -0.1,
      );

  static TextStyle get body => _font(
        size: 14,
        weight: FontWeight.w500,
        color: AppColors.label,
        height: 1.5,
        letterSpacing: -0.1,
      );

  static TextStyle get callout => _font(
        size: 14,
        weight: FontWeight.w400,
        color: AppColors.labelSecondary,
        height: 1.5,
        letterSpacing: 0,
      );

  static TextStyle get footnote => _font(
        size: 13,
        weight: FontWeight.w400,
        color: AppColors.labelSecondary,
        height: 1.4,
        letterSpacing: 0,
      );

  static TextStyle get caption => _font(
        size: 12,
        weight: FontWeight.w500,
        color: AppColors.labelSecondary,
        height: 1.3,
        letterSpacing: 0.2,
      );

  static TextStyle get tabLabel => _font(
        size: 11,
        weight: FontWeight.w500,
        color: AppColors.labelSecondary,
        height: 1.2,
        letterSpacing: 0.2,
      );
}
