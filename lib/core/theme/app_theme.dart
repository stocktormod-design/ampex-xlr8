import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Ampex designsystem – DARK MODUS.
///
/// Én ThemeData brukt på alle plattformer (iOS, Android, web).
class AppTheme {
  static ThemeData light() {
    return dark(); // Tvinger dyp Spotify-tema overalt, uansett systeminnstilling.
  }

  static ThemeData dark() {
    const cs = ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: Colors.white,
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
      colorScheme: cs,
      scaffoldBackgroundColor: AppColors.background,
      splashFactory: InkRipple.splashFactory,
      splashColor: AppColors.pressed,
      highlightColor: Colors.transparent,

      // ── Cupertino overlay ───────────────────────────────────────────────────
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.accent,
        scaffoldBackgroundColor: AppColors.background,
        barBackgroundColor: AppColors.background,
      ),

      // ── AppBar ──────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.label,
        titleTextStyle: AppTypography.headline,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
      ),

      // ── Text (Inter via AppTypography) ───────────────────────────────────────
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
          foregroundColor: AppColors.label, // Hvit i mørkt tema for renhet
          textStyle: AppTypography.body,
          minimumSize: const Size(0, AppSpacing.minTouch),
        ),
      ),

      // ── Input ───────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceHighlight, // Viser inputfeltet i mørket
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
          borderSide: const BorderSide(color: AppColors.labelSecondary, width: 1),
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
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.label,
        unselectedItemColor: AppColors.labelSecondary,
        selectedLabelStyle: AppTypography.tabLabel,
        unselectedLabelStyle: AppTypography.tabLabel,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
