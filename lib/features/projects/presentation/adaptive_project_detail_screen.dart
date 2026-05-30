import 'package:flutter/material.dart';

import '../../../core/platform/app_product_provider.dart';
import '../desktop/presentation/desktop_project_detail_workspace.dart';
import 'project_detail_screen.dart';

/// Prosjektdetalj — Mobile: én kolonne. Desktop: tegning + inspector.
class AdaptiveProjectDetailScreen extends StatelessWidget {
  const AdaptiveProjectDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    if (context.isAmpexMobile) {
      return ProjectDetailScreen(id: id);
    }
    return DesktopProjectDetailWorkspace(projectId: id);
  }
}
