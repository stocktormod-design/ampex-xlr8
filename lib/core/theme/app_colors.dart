import 'package:flutter/cupertino.dart';

import 'tokens/design_tokens.dart';

/// Semantiske farger – bygger på [DesignTokens].
abstract final class AppColors {
  static const background = DesignTokens.background;
  static const surface = DesignTokens.surface;
  static const surfaceElevated = DesignTokens.surfaceElevated;
  static const surfaceHighlight = DesignTokens.surfaceMuted;

  static const label = DesignTokens.textPrimary;
  static const labelSecondary = DesignTokens.textSecondary;
  static const labelTertiary = DesignTokens.textTertiary;
  static const labelPlaceholder = DesignTokens.textTertiary;

  static const accent = DesignTokens.accent;
  static const accentSecondary = Color(0xFF3B82F6);
  static const accentPressed = Color(0x1A2563EB);
  static const accentSoft = DesignTokens.accentSoft;
  static const onAccent = DesignTokens.onAccent;

  static const statusNeutral = DesignTokens.textTertiary;
  static const statusActive = DesignTokens.accent;
  static const statusWaiting = DesignTokens.warning;
  static const statusDone = DesignTokens.success;

  static const destructive = DesignTokens.destructive;
  static const success = DesignTokens.success;
  static const warning = DesignTokens.warning;

  static const separator = Color(0xFFE5E7EB);
  static const border = DesignTokens.border;
  static const borderGlow = Color(0x332563EB);
  static const separatorOpaque = DesignTokens.borderStrong;

  static const cardHighlight = DesignTokens.surfaceMuted;
  static const shadow = DesignTokens.shadow;

  static const pressed = accentPressed;
  static const hover = Color(0x0F2563EB);
  static const selected = Color(0x1A2563EB);

  static const barBackground = surface;
  static const sidebarBackground = surface;

  // CAD-tegning (mørk flate – kun tegningsmodus)
  static const cadCanvas = Color(0xFF0E1118);
  static const cadPaper = Color(0xFFF4F4F0);

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [surface, surfaceHighlight],
  );
}
