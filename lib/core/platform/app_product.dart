import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../theme/app_breakpoints.dart';

/// Én plattform, to produkter — som iOS og macOS over samme økosystem.
///
/// **Ampex Mobile** — arbeidsverktøy på byggeplass (native iOS/Android).
/// **Ampex Desktop** — kontrollsenter på kontoret (web bred skjerm, macOS, Windows).
///
/// Deler: Supabase, modeller, providers, repositories.
/// Deler ikke: layouts, navigasjon, informasjonstetthet.
enum AmpexProduct {
  mobile,
  desktop,
}

abstract final class AmpexProductResolver {
  /// Native iOS/Android er alltid Mobile — aldri «responsiv desktop».
  static bool get isNativeMobile {
    if (kIsWeb) return false;
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.android => true,
      _ => false,
    };
  }

  static AmpexProduct resolve(double width) {
    if (isNativeMobile) return AmpexProduct.mobile;
    // Smal nettleser → Mobile-opplevelse (én ting av gangen).
    if (width < AppBreakpoints.tablet) return AmpexProduct.mobile;
    return AmpexProduct.desktop;
  }
}

