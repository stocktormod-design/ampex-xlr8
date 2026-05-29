import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_repository.dart';
import '../../../core/auth/models/session_context.dart';
import '../../../core/auth/profile_repository.dart';
import '../../../core/auth/role_labels.dart';
import '../../../core/auth/session_providers.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ampex_grouped_section.dart';
import '../../../core/widgets/ampex_list_row.dart';
import '../../../core/widgets/ampex_scaffold.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionContextProvider);

    return sessionAsync.when(
      loading: () => AmpexScaffold(
        title: 'Hjem',
        slivers: const [
          SliverFillRemaining(
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        ],
      ),
      error: (e, _) => AmpexScaffold(
        title: 'Hjem',
        slivers: [
          SliverFillRemaining(
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
          return AmpexScaffold(
            title: 'Hjem',
            slivers: const [
              SliverFillRemaining(
                child: Center(child: Text('Du er ikke innlogget.')),
              ),
            ],
          );
        }
        return _HomeContent(session: session);
      },
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({required this.session});

  final SessionContext session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = session.profile;
    final company = session.company;

    return AmpexScaffold(
      title: 'Hjem',
      slivers: [
        // ── Velkomst ──────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH, AppSpacing.sm,
              AppSpacing.screenH, AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'God dag, ${session.displayName}',
                  style: AppTypography.title2,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Text(company.name, style: AppTypography.callout),
                    const SizedBox(width: AppSpacing.sm),
                    _RoleBadge(label: roleLabelNorwegian(profile.role)),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ── Arbeid ────────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: AmpexGroupedSection(
            header: 'Arbeid',
            children: [
              AmpexListRow(
                leading: Icons.description_rounded,
                leadingColor: AppColors.accent,
                title: 'Ordre',
                subtitle: 'Oppfølging og dokumentasjon',
                onTap: () => context.go(Routes.orders),
              ),
              AmpexListRow(
                leading: Icons.business_rounded,
                leadingColor: const Color(0xFF1E8A4C),
                title: 'Prosjekter',
                subtitle: 'Tegninger, rom og fremdrift',
                onTap: () => context.go(Routes.projects),
              ),
            ],
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sectionGap)),

        // ── Konto ─────────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: AmpexGroupedSection(
            header: 'Konto',
            footer: 'Deler innlogging med Ampex web.',
            children: [
              AmpexListRow(
                leading: Icons.person_rounded,
                leadingColor: AppColors.labelSecondary,
                title: profile.fullName.isNotEmpty ? profile.fullName : 'Profil',
                value: roleLabelNorwegian(profile.role),
                showChevron: false,
              ),
              AmpexListRow(
                title: 'Logg ut',
                destructive: true,
                showChevron: false,
                onTap: () async {
                  await ref.read(authRepositoryProvider).signOut();
                },
              ),
            ],
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
      ],
    );
  }
}

// ── Hjelpere ───────────────────────────────────────────────────────────────────

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(AppSpacing.xs + 2),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: AppColors.accent,
          fontWeight: FontWeight.w600,
        ),
      ),
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
            const Icon(CupertinoIcons.person_crop_circle_badge_xmark,
                size: 48, color: AppColors.labelTertiary),
            const SizedBox(height: AppSpacing.md),
            Text(message,
                textAlign: TextAlign.center,
                style: AppTypography.callout),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Prøv igjen'),
            ),
          ],
        ),
      ),
    );
  }
}
