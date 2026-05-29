import 'package:flutter/painting.dart';

/// Ampex design tokens – avrunding.
abstract final class AppRadius {
  /// Grouped sections / lister
  static const double section = 16;

  /// Knapper, tekstfelter
  static const double button = 14;

  /// Chips / badges
  static const double chip = 8;

  /// Modaler / sheets (topp)
  static const double sheet = 20;

  static const BorderRadius sectionBorder =
      BorderRadius.all(Radius.circular(section));
  static const BorderRadius buttonBorder =
      BorderRadius.all(Radius.circular(button));
}
