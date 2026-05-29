import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Ampex Pro – mørkt dashboard med hvite accenter.
class AppTheme {
  static ThemeData light() => dark();

  static ThemeData dark() {
    const cs = ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      surface: AppColors.surface,
      onSurface: AppColors.label,
      onSurfaceVariant: AppColors.labelSecondary,
      outline: AppColors.separator,
      outlineVariant: AppColors.separatorOpaque,
      error: AppColors.destructive,
      onError: Colors.white,
      surfaceContainerHighest: AppColors.surfaceElevated,
      surfaceContainerLow: AppColors.surfaceHighlight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: cs,
      scaffoldBackgroundColor: AppColors.background,
      splashFactory: InkRipple.splashFactory,
      splashColor: AppColors.pressed,
      highlightColor: Colors.transparent,
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.accent,
        scaffoldBackgroundColor: AppColors.background,
        barBackgroundColor: AppColors.barBackground,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.label,
        titleTextStyle: AppTypography.headline,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.largeTitle,
        displayMedium: AppTypography.title1,
        displaySmall: AppTypography.title2,
        titleLarge: AppTypography.headline,
        titleMedium: AppTypography.headline,
        bodyLarge: AppTypography.body,
        bodyMedium: AppTypography.callout,
        bodySmall: AppTypography.footnote,
        labelMedium: AppTypography.caption,
        labelSmall: AppTypography.tabLabel,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.onAccent,
          minimumSize: const Size.fromHeight(AppSpacing.minTouch + 6),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.buttonBorder),
          textStyle: AppTypography.headline.copyWith(color: AppColors.onAccent),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.label,
          textStyle: AppTypography.body,
          minimumSize: const Size(0, AppSpacing.minTouch),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.rowH,
          vertical: AppSpacing.rowV,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.sectionBorder,
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.sectionBorder,
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.sectionBorder,
          borderSide: const BorderSide(color: AppColors.accent, width: 1),
        ),
        hintStyle: AppTypography.body.copyWith(color: AppColors.labelPlaceholder),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.separator,
        thickness: 0.5,
        space: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.label,
        unselectedItemColor: AppColors.labelTertiary,
        selectedLabelStyle: AppTypography.tabLabel,
        unselectedLabelStyle: AppTypography.tabLabel,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
