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
        return _HomeContent(session: session);
      },
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({required this.session});

  final SessionContext session;

  String get _firstName {
    final name = session.displayName.trim();
    if (name.isEmpty || name == 'Bruker') return 'der';
    return name.split(' ').first;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = session.profile;
    final company = session.company;

    return AmpexScaffold(
      title: '${_greeting()}, $_firstName',
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH, AppSpacing.sm,
              AppSpacing.screenH, AppSpacing.lg,
            ),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    company.name,
                    style: AppTypography.callout.copyWith(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _RoleBadge(label: roleLabelNorwegian(profile.role)),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: AmpexGroupedSection(
            header: 'Arbeid',
            children: [
              AmpexListRow(
                leading: CupertinoIcons.doc_text_fill,
                leadingColor: AppColors.accent,
                title: 'Ordre',
                subtitle: 'Oppfølging og dokumentasjon',
                onTap: () => context.go(Routes.orders),
              ),
              AmpexListRow(
                leading: CupertinoIcons.building_2_fill,
                leadingColor: AppColors.success,
                title: 'Prosjekter',
                subtitle: 'Tegninger, rom og fremdrift',
                onTap: () => context.go(Routes.projects),
              ),
            ],
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sectionGap)),
        SliverToBoxAdapter(
          child: AmpexGroupedSection(
            header: 'Konto',
            footer: 'Deler innlogging med Ampex web.',
            children: [
              AmpexListRow(
                leading: CupertinoIcons.person_fill,
                leadingColor: AppColors.labelSecondary,
                title: profile.fullName.isNotEmpty ? profile.fullName : 'Profil',
                value: roleLabelNorwegian(profile.role),
                showChevron: false,
              ),
              AmpexListRow(
                title: 'Logg ut',
                destructive: true,
                showChevron: false,
                onTap: () => ref.read(authRepositoryProvider).signOut(),
              ),
            ],
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
      ],
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'God natt';
    if (hour < 11) return 'God morgen';
    if (hour < 18) return 'God dag';
    return 'God kveld';
  }
}

// ── Hjelpere ───────────────────────────────────────────────────────────────────

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
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
                textAlign: TextAlign.center, style: AppTypography.callout),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(onPressed: onRetry, child: const Text('Prøv igjen')),
          ],
        ),
      ),
    );
  }
}
