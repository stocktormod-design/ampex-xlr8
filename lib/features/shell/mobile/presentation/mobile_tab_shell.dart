import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Felt-app: bottom navigation (Home, Ordre, Prosjekter, Innboks, Mer).
class MobileTabShell extends StatelessWidget {
  const MobileTabShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    _Tab(CupertinoIcons.house, CupertinoIcons.house_fill, 'Hjem'),
    _Tab(CupertinoIcons.doc_text, CupertinoIcons.doc_text_fill, 'Ordre'),
    _Tab(
      CupertinoIcons.square_stack_3d_up,
      CupertinoIcons.square_stack_3d_up_fill,
      'Prosjekter',
    ),
    _Tab(CupertinoIcons.tray, CupertinoIcons.tray_fill, 'Innboks'),
    _Tab(CupertinoIcons.ellipsis_circle, CupertinoIcons.ellipsis_circle_fill, 'Mer'),
  ];

  void _go(int index) {
    if (index >= 3) {
      // Innboks / Mer – placeholder til modulene finnes
      return;
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final current = navigationShell.currentIndex.clamp(0, 2);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 12,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: AppSpacing.minTouch + 4 + bottom,
            child: Row(
              children: [
                for (var i = 0; i < _destinations.length; i++)
                  Expanded(
                    child: _TabItem(
                      tab: _destinations[i],
                      active: i == current || (i < 3 && i == navigationShell.currentIndex),
                      enabled: i < 3,
                      onTap: () => _go(i),
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

class _Tab {
  const _Tab(this.icon, this.activeIcon, this.label);
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.tab,
    required this.active,
    required this.enabled,
    required this.onTap,
  });

  final _Tab tab;
  final bool active;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = !enabled
        ? AppColors.labelTertiary.withValues(alpha: 0.5)
        : active
            ? AppColors.accent
            : AppColors.labelTertiary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: SizedBox(
          height: AppSpacing.minTouch,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(active ? tab.activeIcon : tab.icon, size: 24, color: color),
              const SizedBox(height: 2),
              Text(
                tab.label,
                style: AppTypography.tabLabel.copyWith(
                  color: color,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
