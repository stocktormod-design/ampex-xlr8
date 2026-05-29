import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Ampex typografi – Inter på alle plattformer (lastes riktig på web).
abstract final class AppTypography {
  static TextStyle _inter({
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

  /// 32 · Bold · Skjermoverskrift / hilsen
  static TextStyle get largeTitle => _inter(
        size: 32,
        weight: FontWeight.w700,
        color: AppColors.label,
        height: 1.12,
        letterSpacing: -0.6,
      );

  static TextStyle get title1 => _inter(
        size: 26,
        weight: FontWeight.w600,
        color: AppColors.label,
        height: 1.2,
        letterSpacing: -0.4,
      );

  static TextStyle get title2 => _inter(
        size: 20,
        weight: FontWeight.w600,
        color: AppColors.label,
        height: 1.25,
        letterSpacing: -0.3,
      );

  /// Rad-tittel, knapper
  static TextStyle get headline => _inter(
        size: 16,
        weight: FontWeight.w600,
        color: AppColors.label,
        height: 1.3,
        letterSpacing: -0.2,
      );

  static TextStyle get body => _inter(
        size: 16,
        weight: FontWeight.w400,
        color: AppColors.label,
        height: 1.35,
        letterSpacing: -0.15,
      );

  static TextStyle get callout => _inter(
        size: 14,
        weight: FontWeight.w400,
        color: AppColors.labelSecondary,
        height: 1.4,
        letterSpacing: -0.1,
      );

  static TextStyle get footnote => _inter(
        size: 13,
        weight: FontWeight.w400,
        color: AppColors.labelSecondary,
        height: 1.35,
      );

  static TextStyle get caption => _inter(
        size: 12,
        weight: FontWeight.w500,
        color: AppColors.labelSecondary,
        height: 1.3,
        letterSpacing: 0.2,
      );

  static TextStyle get tabLabel => _inter(
        size: 11,
        weight: FontWeight.w500,
        color: AppColors.labelSecondary,
        height: 1.2,
        letterSpacing: 0,
      );
}
