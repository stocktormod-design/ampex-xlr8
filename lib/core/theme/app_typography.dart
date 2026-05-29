import 'package:flutter/cupertino.dart';

import 'app_colors.dart';

/// Ampex design tokens – typografi.
///
/// Scale inspirert av iOS HIG.
abstract final class AppTypography {
  /// Inter lastes på web via index.html; SF/system på native.
  static const String _fontFamily = 'Inter';
  static const List<String> _fontFallback = [
    '.SF Pro Text',
    '-apple-system',
    'BlinkMacSystemFont',
    'system-ui',
    'Roboto',
    'sans-serif',
  ];

  /// 34 · Bold · Large Title (skjermoverskrift)
  static const largeTitle = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFallback,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.37,
    color: AppColors.label,
    height: 1.2,
  );

  /// 28 · SemiBold · Title 1
  static const title1 = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFallback,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.36,
    color: AppColors.label,
    height: 1.25,
  );

  /// 22 · SemiBold · Title 2
  static const title2 = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFallback,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.35,
    color: AppColors.label,
    height: 1.3,
  );

  /// 17 · SemiBold · Navigation / list title
  static const headline = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFallback,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
    color: AppColors.label,
    height: 1.35,
  );

  /// 17 · Regular · Body
  static const body = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFallback,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.41,
    color: AppColors.label,
    height: 1.35,
  );

  /// 15 · Regular · Callout / subtitle
  static const callout = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFallback,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.24,
    color: AppColors.labelSecondary,
    height: 1.4,
  );

  /// 13 · Regular · Footnote / caption
  static const footnote = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFallback,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.08,
    color: AppColors.labelSecondary,
    height: 1.4,
  );

  /// 13 · Medium · Section header / caption2
  static const caption = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFallback,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.06,
    color: AppColors.labelSecondary,
    height: 1.4,
  );

  /// 11 · SemiBold · Tab bar label
  static const tabLabel = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFallback,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.07,
    height: 1.2,
  );
}
