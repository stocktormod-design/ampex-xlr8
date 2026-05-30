import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/platform/app_product_provider.dart';
import '../../desktop/presentation/desktop_projects_split_shell.dart';

/// Wrapper rundt prosjekt-ruter: Mobile = fullskjerm child, Desktop = split view.
class AdaptiveProjectsShell extends StatelessWidget {
  const AdaptiveProjectsShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (context.isAmpexMobile) return child;

    final id = GoRouterState.of(context).pathParameters['id'];
    return DesktopProjectsSplitShell(
      selectedProjectId: id,
      child: child,
    );
  }
}
