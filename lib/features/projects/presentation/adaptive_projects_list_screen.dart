import 'package:flutter/material.dart';

import '../../../core/platform/app_product_provider.dart';
import '../desktop/presentation/desktop_projects_empty_pane.dart';
import 'projects_list_screen.dart';

/// /prosjekter — Mobile: full liste. Desktop: tom høyre panel (liste er i split).
class AdaptiveProjectsListScreen extends StatelessWidget {
  const AdaptiveProjectsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isAmpexMobile) {
      return const ProjectsListScreen();
    }
    return const DesktopProjectsEmptyPane();
  }
}
