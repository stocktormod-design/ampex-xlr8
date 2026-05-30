import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/tokens/design_tokens.dart';
import '../../presentation/widgets/pro_sidebar.dart';

/// Kontor/web: collapsible sidebar + innholdsflate.
class DesktopAppShell extends ConsumerStatefulWidget {
  const DesktopAppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<DesktopAppShell> createState() => _DesktopAppShellState();
}

class _DesktopAppShellState extends ConsumerState<DesktopAppShell> {
  bool _collapsed = false;

  static final _items = [
    const ProNavItem(
      icon: CupertinoIcons.house,
      label: 'Hjem',
      branchIndex: 0,
    ),
    const ProNavItem(
      icon: CupertinoIcons.doc_text,
      label: 'Ordre',
      branchIndex: 1,
    ),
    const ProNavItem(
      icon: CupertinoIcons.square_stack_3d_up,
      label: 'Prosjekter',
      branchIndex: 2,
    ),
    const ProNavItem(
      icon: CupertinoIcons.cube_box,
      label: 'Lager',
      comingSoon: true,
    ),
    const ProNavItem(
      icon: CupertinoIcons.folder,
      label: 'Dokumentasjon',
      comingSoon: true,
    ),
    const ProNavItem(
      icon: CupertinoIcons.book,
      label: 'Prosedyrer',
      comingSoon: true,
    ),
    const ProNavItem(
      icon: CupertinoIcons.exclamationmark_triangle,
      label: 'Avvik',
      dotColor: AppColors.warning,
      comingSoon: true,
    ),
    const ProNavItem(
      icon: CupertinoIcons.chart_bar,
      label: 'Rapporter',
      comingSoon: true,
    ),
    const ProNavItem(
      icon: CupertinoIcons.gear,
      label: 'Innstillinger',
      comingSoon: true,
    ),
  ];

  void _go(int branch) {
    widget.navigationShell.goBranch(
      branch,
      initialLocation: branch == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _collapsed
                ? DesignTokens.desktopSidebarCollapsed
                : DesignTokens.desktopSidebarWidth,
            child: ProSidebar(
              items: _items,
              activeBranchIndex: widget.navigationShell.currentIndex,
              onSelectBranch: _go,
              collapsed: _collapsed,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Material(
                  color: AppColors.surface,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColors.border)),
                    ),
                    child: SizedBox(
                      height: 52,
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: _collapsed ? 'Utvid meny' : 'Skjul meny',
                            onPressed: () =>
                                setState(() => _collapsed = !_collapsed),
                            icon: Icon(
                              _collapsed
                                  ? CupertinoIcons.sidebar_left
                                  : CupertinoIcons.sidebar_right,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(child: widget.navigationShell),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
