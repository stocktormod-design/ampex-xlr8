import 'package:flutter/widgets.dart';

/// Responsiv strategi for Ampex.
///
/// Samme komponenter overalt – layout reflower per skjermstørrelse.
enum DeviceClass { mobile, tablet, desktop }

abstract final class AppBreakpoints {
  /// < 768: telefon (bottom nav)
  static const double tablet = 768;

  /// 768–1200: nettbrett (kompakt nav-rail)
  static const double desktop = 1200;

  static DeviceClass classify(double width) {
    if (width >= desktop) return DeviceClass.desktop;
    if (width >= tablet) return DeviceClass.tablet;
    return DeviceClass.mobile;
  }
}

extension ResponsiveContext on BuildContext {
  DeviceClass get deviceClass =>
      AppBreakpoints.classify(MediaQuery.sizeOf(this).width);

  bool get isMobile => deviceClass == DeviceClass.mobile;
  bool get isTablet => deviceClass == DeviceClass.tablet;
  bool get isDesktop => deviceClass == DeviceClass.desktop;

  /// Nav vises på siden (rail/sidebar) fra og med nettbrett.
  bool get hasSideNav => !isMobile;

  /// Antall kolonner for modul-/kortrutenett.
  int get gridColumns => switch (deviceClass) {
        DeviceClass.mobile => 2,
        DeviceClass.tablet => 3,
        DeviceClass.desktop => 4,
      };
}
