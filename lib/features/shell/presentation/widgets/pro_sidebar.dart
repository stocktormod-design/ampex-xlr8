import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_repository.dart';
import '../../../../core/auth/role_labels.dart';
import '../../../../core/auth/session_providers.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class ProNavItem {
  const ProNavItem({
    required this.icon,
    required this.label,
    this.branchIndex,
    this.badge,
    this.dotColor,
    this.comingSoon = false,
  });

  final IconData icon;
  final String label;
  final int? branchIndex;
  final String? badge;
  final Color? dotColor;
  final bool comingSoon;
}

class ProSidebar extends ConsumerWidget {
  const ProSidebar({
    super.key,
    required this.items,
    required this.activeBranchIndex,
    required this.onSelectBranch,
  });

  final List<ProNavItem> items;
  final int activeBranchIndex;
  final ValueChanged<int> onSelectBranch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionContextProvider).valueOrNull;
    final name = session?.displayName ?? 'Ampex';
    final role = session != null
        ? roleLabelNorwegian(session.profile.role)
        : '';

    return Container(
      width: 270,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBackground,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.bolt_fill,
                  color: AppColors.accent,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  AppConfig.appName,
                  style: AppTypography.title1.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.7,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final item in items)
                  _SidebarItem(
                    item: item,
                    active: item.branchIndex == activeBranchIndex,
                    onTap: () {
                      if (item.comingSoon || item.branchIndex == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item.label} kommer snart'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.surfaceElevated,
                          ),
                        );
                        return;
                      }
                      onSelectBranch(item.branchIndex!);
                    },
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.surfaceHighlight,
                    child: Text(
                      _initials(name),
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppTypography.footnote.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.label,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          role,
                          style: AppTypography.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => ref.read(authRepositoryProvider).signOut(),
                    icon: const Icon(
                      CupertinoIcons.chevron_right,
                      size: 16,
                      color: AppColors.labelSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return 'A';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final ProNavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.accentSecondary : AppColors.labelSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Material(
        color: active ? AppColors.selected : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          hoverColor: AppColors.hover,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Icon(item.icon, size: 20, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: AppTypography.callout.copyWith(
                      color: color,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (item.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item.badge!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onAccent,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                if (item.dotColor != null)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: item.dotColor,
                      shape: BoxShape.circle,
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
