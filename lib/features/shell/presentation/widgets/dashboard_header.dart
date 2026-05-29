import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/session_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionContextProvider).valueOrNull;
    final name = session?.displayName ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.search,
                    size: 18,
                    color: AppColors.labelSecondary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Søk',
                    style: AppTypography.callout.copyWith(
                      color: AppColors.labelPlaceholder,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentSoft,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text('⌘ K', style: AppTypography.caption),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const _HeaderIcon(icon: CupertinoIcons.moon),
          const SizedBox(width: AppSpacing.sm),
          Stack(
            clipBehavior: Clip.none,
            children: [
              const _HeaderIcon(icon: CupertinoIcons.bell),
              Positioned(
                right: 5,
                top: -2,
                child: Container(
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '3',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onAccent,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.surfaceHighlight,
            child: Text(
              _initials(name),
              style: AppTypography.caption.copyWith(
                color: AppColors.label,
                fontWeight: FontWeight.w700,
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

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(icon, size: 20, color: AppColors.labelSecondary),
    );
  }
}
