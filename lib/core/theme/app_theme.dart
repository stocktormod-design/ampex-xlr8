import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Ampex designsystem – lys modus.
///
/// Én ThemeData brukt på alle plattformer (iOS, Android, web).
/// Cupertino-widgets arver farger via [cupertinoOverrideTheme].
class AppTheme {
  static ThemeData light() {
    const cs = ColorScheme.light(
      primary: AppColors.accent,
      onPrimary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.label,
      onSurfaceVariant: AppColors.labelSecondary,
      outline: AppColors.separator,
      outlineVariant: AppColors.separatorOpaque,
      error: AppColors.destructive,
      onError: Colors.white,
      surfaceContainerHighest: AppColors.background,
      surfaceContainerLow: AppColors.accentSoft,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: AppColors.background,
      splashFactory: InkRipple.splashFactory,
      splashColor: AppColors.pressed,
      highlightColor: Colors.transparent,

      // ── Cupertino overlay ───────────────────────────────────────────────────
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.accent,
        scaffoldBackgroundColor: AppColors.background,
        barBackgroundColor: AppColors.surfaceElevated,
      ),

      // ── AppBar ──────────────────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.label,
        titleTextStyle: AppTypography.headline,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      // ── Text ────────────────────────────────────────────────────────────────
      textTheme: const TextTheme(
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

      // ── Buttons ─────────────────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(AppSpacing.minTouch + 6),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.buttonBorder),
          textStyle: AppTypography.headline,
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          textStyle: AppTypography.body,
          minimumSize: const Size(0, AppSpacing.minTouch),
        ),
      ),

      // ── Input ───────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.rowH,
          vertical: AppSpacing.rowV,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.sectionBorder,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.sectionBorder,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.sectionBorder,
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.sectionBorder,
          borderSide: const BorderSide(color: AppColors.destructive, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.sectionBorder,
          borderSide: const BorderSide(color: AppColors.destructive, width: 1.5),
        ),
        hintStyle: AppTypography.body.copyWith(color: AppColors.labelPlaceholder),
        errorStyle: AppTypography.footnote.copyWith(color: AppColors.destructive),
      ),

      // ── Divider ─────────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.separator,
        thickness: 0.5,
        space: 0,
      ),

      // ── BottomNavigation ────────────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.labelSecondary,
        selectedLabelStyle: AppTypography.tabLabel,
        unselectedLabelStyle: AppTypography.tabLabel,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  /// CupertinoThemeData for rene Cupertino-komponenter.
  static CupertinoThemeData cupertino() {
    return const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.accent,
      scaffoldBackgroundColor: AppColors.background,
      barBackgroundColor: Color(0xF2F9F9FC),
    );
  }
}
