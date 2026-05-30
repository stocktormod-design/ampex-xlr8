import 'package:flutter/material.dart';

import '../../../../core/platform/app_product_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/tokens/design_tokens.dart';
import '../../presentation/widgets/projects_list_panel.dart';

/// Ampex Desktop – prosjekter: liste + innhold side om side (aldri mobil-liste strukket ut).
class DesktopProjectsSplitShell extends StatelessWidget {
  const DesktopProjectsSplitShell({
    super.key,
    required this.child,
    this.selectedProjectId,
  });

  final Widget child;
  final String? selectedProjectId;

  @override
  Widget build(BuildContext context) {
    if (context.isAmpexMobile) return child;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: DesignTokens.desktopProjectsListWidth,
          child: ProjectsListPanel(selectedProjectId: selectedProjectId),
        ),
        const VerticalDivider(width: 1, color: AppColors.border),
        Expanded(child: child),
      ],
    );
  }
}
