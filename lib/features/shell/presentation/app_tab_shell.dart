import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ampex_glass.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/pro_sidebar.dart';

/// Adaptivt navigasjonsskall – pro mørk sidebar på desktop.
class AppTabShell extends StatelessWidget {
  const AppTabShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static final _sidebarItems = [
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
      icon: CupertinoIcons.checkmark_circle,
      label: 'Oppgaver',
      comingSoon: true,
    ),
    const ProNavItem(
      icon: CupertinoIcons.tray,
      label: 'Innboks',
      badge: '3',
      comingSoon: true,
    ),
    const ProNavItem(
      icon: CupertinoIcons.exclamationmark_triangle,
      label: 'Avvik',
      dotColor: AppColors.warning,
      comingSoon: true,
    ),
    const ProNavItem(
      icon: CupertinoIcons.folder,
      label: 'Dokumentasjon',
      comingSoon: true,
    ),
    const ProNavItem(
      icon: CupertinoIcons.cube_box,
      label: 'Lager',
      comingSoon: true,
    ),
    const ProNavItem(
      icon: CupertinoIcons.book,
      label: 'Prosedyrer',
      comingSoon: true,
    ),
    const ProNavItem(
      icon: CupertinoIcons.rosette,
      label: 'Kursbevis',
      comingSoon: true,
    ),
  ];

  static const _mobileDestinations = [
    _NavDest(
      icon: CupertinoIcons.house,
      activeIcon: CupertinoIcons.house_fill,
      label: 'Hjem',
    ),
    _NavDest(
      icon: CupertinoIcons.doc_text,
      activeIcon: CupertinoIcons.doc_text_fill,
      label: 'Ordre',
    ),
    _NavDest(
      icon: CupertinoIcons.square_stack_3d_up,
      activeIcon: CupertinoIcons.square_stack_3d_up_fill,
      label: 'Prosjekter',
    ),
  ];

  void _go(int i) => navigationShell.goBranch(
        i,
        initialLocation: i == navigationShell.currentIndex,
      );

  @override
  Widget build(BuildContext context) {
    if (context.hasSideNav) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            ProSidebar(
              items: _sidebarItems,
              activeBranchIndex: navigationShell.currentIndex,
              onSelectBranch: _go,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const DashboardHeader(),
                  Expanded(
                    child: AmpexBackdrop(child: navigationShell),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: AmpexBackdrop(child: navigationShell),
      bottomNavigationBar: _BottomBar(
        destinations: _mobileDestinations,
        currentIndex: navigationShell.currentIndex,
        onSelected: _go,
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.destinations,
    required this.currentIndex,
    required this.onSelected,
  });

  final List<_NavDest> destinations;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return AmpexBarBlur(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.barBackground,
          border: Border(
            top: BorderSide(color: AppColors.separator, width: 0.5),
          ),
        ),
        child: SizedBox(
          height: 54 + bottomPadding,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Row(
              children: [
                for (var i = 0; i < destinations.length; i++)
                  Expanded(
                    child: _BottomItem(
                      dest: destinations[i],
                      active: i == currentIndex,
                      onTap: () => onSelected(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.dest,
    required this.active,
    required this.onTap,
  });

  final _NavDest dest;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.accent : AppColors.labelTertiary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(active ? dest.activeIcon : dest.icon, size: 24, color: color),
          const SizedBox(height: 3),
          Text(
            dest.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavDest {
  const _NavDest({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}
