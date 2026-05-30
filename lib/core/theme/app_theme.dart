import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../platform/app_product.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';
import 'tokens/design_tokens.dart';

/// Tema per opplevelse – begge er lyse og profesjonelle.
class AppTheme {
  static ThemeData forProduct(AmpexProduct product) {
    return switch (product) {
      AmpexProduct.mobile => _mobile(),
      AmpexProduct.desktop => _desktop(),
    };
  }

  static ThemeData light() => _desktop();

  static ThemeData dark() => _desktop();

  static ThemeData _mobile() => _base(
        minTouch: DesignTokens.mobileMinTouch,
        horizontalPadding: DesignTokens.mobileScreenPadding,
      );

  static ThemeData _desktop() => _base(
        minTouch: DesignTokens.desktopMinTouch,
        horizontalPadding: DesignTokens.desktopScreenPadding,
      );

  static ThemeData _base({
    required double minTouch,
    required double horizontalPadding,
  }) {
    const cs = ColorScheme.light(
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      surface: AppColors.surface,
      onSurface: AppColors.label,
      onSurfaceVariant: AppColors.labelSecondary,
      outline: AppColors.border,
      outlineVariant: AppColors.separatorOpaque,
      error: AppColors.destructive,
      onError: Colors.white,
      surfaceContainerHighest: AppColors.surfaceHighlight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: cs,
      scaffoldBackgroundColor: AppColors.background,
      splashFactory: InkRipple.splashFactory,
      splashColor: AppColors.pressed,
      highlightColor: Colors.transparent,
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.accent,
        scaffoldBackgroundColor: AppColors.background,
        barBackgroundColor: AppColors.barBackground,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.label,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.headline,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.sectionBorder,
          side: const BorderSide(color: AppColors.border),
        ),
        shadowColor: AppColors.shadow,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.largeTitle.copyWith(color: AppColors.label),
        displayMedium: AppTypography.title1.copyWith(color: AppColors.label),
        displaySmall: AppTypography.title2.copyWith(color: AppColors.label),
        titleLarge: AppTypography.headline.copyWith(color: AppColors.label),
        titleMedium: AppTypography.headline.copyWith(color: AppColors.label),
        bodyLarge: AppTypography.body.copyWith(color: AppColors.label),
        bodyMedium: AppTypography.callout.copyWith(color: AppColors.labelSecondary),
        bodySmall: AppTypography.footnote.copyWith(color: AppColors.labelSecondary),
        labelMedium: AppTypography.caption.copyWith(color: AppColors.labelSecondary),
        labelSmall: AppTypography.tabLabel.copyWith(color: AppColors.labelTertiary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.onAccent,
          minimumSize: Size.fromHeight(minTouch),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding / 2),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.buttonBorder),
          textStyle: AppTypography.headline.copyWith(color: AppColors.onAccent),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          textStyle: AppTypography.body,
          minimumSize: Size(0, minTouch),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceHighlight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.rowH,
          vertical: AppSpacing.rowV,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.sectionBorder,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.sectionBorder,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.sectionBorder,
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        hintStyle: AppTypography.body.copyWith(color: AppColors.labelPlaceholder),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.separator,
        thickness: 1,
        space: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.labelTertiary,
        selectedLabelStyle: AppTypography.tabLabel,
        unselectedLabelStyle: AppTypography.tabLabel,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.sidebarBackground,
        selectedIconTheme: const IconThemeData(color: AppColors.accent),
        unselectedIconTheme: const IconThemeData(color: AppColors.labelTertiary),
        selectedLabelTextStyle:
            AppTypography.caption.copyWith(color: AppColors.accent),
        unselectedLabelTextStyle:
            AppTypography.caption.copyWith(color: AppColors.labelTertiary),
      ),
    );
  }
}
