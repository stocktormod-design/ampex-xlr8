import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Tab bar – Cupertino-ikoner, ren typografi.
class AppTabShell extends StatelessWidget {
  const AppTabShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _tabs = [
    _TabItem(
      icon: CupertinoIcons.house,
      activeIcon: CupertinoIcons.house_fill,
      label: 'Hjem',
    ),
    _TabItem(
      icon: CupertinoIcons.doc_text,
      activeIcon: CupertinoIcons.doc_text_fill,
      label: 'Ordre',
    ),
    _TabItem(
      icon: CupertinoIcons.building_2_fill,
      activeIcon: CupertinoIcons.building_2_fill,
      label: 'Prosjekter',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: _AmpexTabBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
        tabs: _tabs,
      ),
    );
  }
}

class _AmpexTabBar extends StatelessWidget {
  const _AmpexTabBar({
    required this.currentIndex,
    required this.onTap,
    required this.tabs,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<_TabItem> tabs;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.98),
        border: Border(
          top: BorderSide(
            color: AppColors.separator.withValues(alpha: 0.8),
            width: 0.5,
          ),
        ),
      ),
      child: SizedBox(
        height: 49 + bottomPadding,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Row(
            children: List.generate(tabs.length, (i) {
              final tab = tabs[i];
              final active = i == currentIndex;
              return Expanded(
                child: _TabTile(
                  item: tab,
                  active: active,
                  onTap: () => onTap(i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _TabTile extends StatelessWidget {
  const _TabTile({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final _TabItem item;
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
          Icon(
            active ? item.activeIcon : item.icon,
            size: 23,
            color: color,
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            style: AppTypography.tabLabel.copyWith(
              color: color,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItem {
  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}
