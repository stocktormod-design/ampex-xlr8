import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/profile_repository.dart';
import '../../../core/auth/session_providers.dart';
import '../../../core/platform/app_product_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ampex_scaffold.dart';
import '../mobile/presentation/mobile_home_screen.dart';
import 'home_dashboard_screen.dart';

/// Adaptivt hjem – felt vs kontor.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionContextProvider);

    return sessionAsync.when(
      loading: () => const AmpexScaffold(
        title: 'Hjem',
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        ],
      ),
      error: (e, _) => AmpexScaffold(
        title: 'Hjem',
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: _SessionError(
              message: e is ProfileException
                  ? e.message
                  : 'Kunne ikke laste profilen din.',
              onRetry: () => ref.invalidate(sessionContextProvider),
            ),
          ),
        ],
      ),
      data: (session) {
        if (session == null) {
          return const AmpexScaffold(
            title: 'Hjem',
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('Du er ikke innlogget.')),
              ),
            ],
          );
        }

        if (context.isAmpexDesktop) {
          return HomeDashboardScreen(session: session);
        }

        return MobileHomeScreen(session: session);
      },
    );
  }
}

class _SessionError extends StatelessWidget {
  const _SessionError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.person_crop_circle_badge_xmark,
              size: 48,
              color: AppColors.labelTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.callout,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(onPressed: onRetry, child: const Text('Prøv igjen')),
          ],
        ),
      ),
    );
  }
}
