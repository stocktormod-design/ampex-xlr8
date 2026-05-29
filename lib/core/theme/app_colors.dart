import 'package:flutter/cupertino.dart';

/// Ampex palette tuned to the referenced web dashboard.
abstract final class AppColors {
  static const background = Color(0xFF060C18);
  static const surface = Color(0xFF0B1528);
  static const surfaceElevated = Color(0xFF101B30);
  static const surfaceHighlight = Color(0xFF14233D);

  static const label = Color(0xFFF3F7FF);
  static const labelSecondary = Color(0xFF9FB0CD);
  static const labelTertiary = Color(0xFF6F7F9A);
  static const labelPlaceholder = Color(0xFF7382A1);

  static const accent = Color(0xFF2F7BFF);
  static const accentSecondary = Color(0xFF59A2FF);
  static const accentPressed = Color(0x332F7BFF);
  static const accentSoft = Color(0x1A2F7BFF);
  static const onAccent = Color(0xFFF8FBFF);

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3D8BFF), Color(0xFF1D61F1)],
  );

  static const statusNeutral = Color(0xFF8B9BBC);
  static const statusActive = Color(0xFF2F7BFF);
  static const statusWaiting = Color(0xFFFFA53D);
  static const statusDone = Color(0xFF3DDC84);

  static const destructive = Color(0xFFFF6E7A);
  static const success = Color(0xFF3DDC84);
  static const warning = Color(0xFFFFA53D);

  static const separator = Color(0x2A6B88B3);
  static const border = Color(0x2D7FA2D9);
  static const borderGlow = Color(0x337CA9FF);
  static const separatorOpaque = Color(0xFF1A2944);

  static const cardHighlight = Color(0xFF11203A);
  static const shadow = Color(0x50030B1A);

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F1A2F), Color(0xFF091326)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF152A4D), Color(0xFF0A1224)],
  );

  static const pressed = Color(0x1A2F7BFF);
  static const hover = Color(0x142F7BFF);
  static const selected = Color(0x262F7BFF);

  static const barBackground = Color(0xE60B1528);
  static const sidebarBackground = Color(0xFF050C1A);

  static const glassSurface = surface;
  static const glassBar = barBackground;
  static const glassBorder = border;

  static const LinearGradient backdropGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF061024), Color(0xFF040A16)],
  );
}
