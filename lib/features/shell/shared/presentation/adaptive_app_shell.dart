import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/platform/app_product.dart';
import '../../../../core/platform/app_product_provider.dart';
import '../../desktop/presentation/desktop_app_shell.dart';
import '../../mobile/presentation/mobile_tab_shell.dart';

/// Velger felt- eller kontor-skall – aldri skalert versjon av det andre.
class AdaptiveAppShell extends ConsumerWidget {
  const AdaptiveAppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (context.ampexProduct) {
      AmpexProduct.mobile => MobileTabShell(navigationShell: navigationShell),
      AmpexProduct.desktop => DesktopAppShell(navigationShell: navigationShell),
    };
  }
}
