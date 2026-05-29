/// Ampex design tokens – spacing.
///
/// Basert på 4pt grid. Minimale touch targets ≥ 44pt (felt-bruk, sollys).
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Horisontal sidepadding (screen edge → content)
  static const double screenH = 20;

  /// Vertikal padding mellom seksjoner
  static const double sectionGap = 28;

  /// Minimum touch target (44pt – iOS HIG)
  static const double minTouch = 44;

  /// Row indre vertikal padding
  static const double rowV = 13;

  /// Row indre horisontal padding
  static const double rowH = 16;
}
