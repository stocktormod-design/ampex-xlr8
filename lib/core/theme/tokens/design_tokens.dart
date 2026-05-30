import 'package:flutter/material.dart';

/// Delte design tokens – premium, nøytral, profesjonell.
abstract final class DesignTokens {
  // Surfaces
  static const background = Color(0xFFF5F6F8);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF1F3F6);
  static const surfaceElevated = Color(0xFFFFFFFF);

  // Text
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);

  // Accent & status
  static const accent = Color(0xFF2563EB);
  static const accentSoft = Color(0xFFEFF6FF);
  static const onAccent = Color(0xFFFFFFFF);
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFD97706);
  static const destructive = Color(0xFFDC2626);

  // Borders & shadows
  static const border = Color(0xFFE5E7EB);
  static const borderStrong = Color(0xFFD1D5DB);
  static const shadow = Color(0x14000000);

  // Ampex Mobile (touch, sunlight, gloves)
  static const mobileMinTouch = 48.0;
  static const mobileScreenPadding = 20.0;

  // Ampex Desktop (density, split views)
  static const desktopMinTouch = 40.0;
  static const desktopScreenPadding = 24.0;
  static const desktopSidebarWidth = 240.0;
  static const desktopSidebarCollapsed = 64.0;
  static const desktopProjectsListWidth = 300.0;
  static const desktopInspectorWidth = 320.0;
}
