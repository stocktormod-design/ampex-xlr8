import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/models/session_context.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ampex_cards.dart';
import '../../../../core/widgets/ampex_scaffold.dart';
import '../../../orders/presentation/orders_providers.dart';
import '../../../projects/presentation/projects_providers.dart';

/// Ampex Mobile – hjem: «Hvor skal jeg?» Store snarveier, ett steg om gangen.
class MobileHomeScreen extends ConsumerWidget {
  const MobileHomeScreen({super.key, required this.session});

  final SessionContext session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersListProvider).valueOrNull?.length;
    final projects = ref.watch(projectsListProvider).valueOrNull?.length;

    return AmpexScaffold(
      title: 'Hei, ${session.displayName.split(' ').first}',
      subtitle: Text(
        'Hvor skal du? Hvilket rom? Hva mangler?',
        style: AppTypography.callout,
      ),
      maxContentWidth: double.infinity,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH,
            AppSpacing.md,
            AppSpacing.screenH,
            AppSpacing.xxl,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              AmpexModuleTile(
                icon: CupertinoIcons.doc_text_fill,
                label: 'Ordre',
                subtitle: orders != null ? '$orders aktive' : null,
                onTap: () => context.go(Routes.orders),
              ),
              const SizedBox(height: AppSpacing.sm),
              AmpexModuleTile(
                icon: CupertinoIcons.square_stack_3d_up_fill,
                label: 'Prosjekter',
                subtitle: projects != null ? '$projects prosjekter' : null,
                onTap: () => context.go(Routes.projects),
              ),
              const SizedBox(height: AppSpacing.sm),
              AmpexModuleTile(
                icon: CupertinoIcons.tray_fill,
                label: 'Innboks',
                subtitle: 'Kommer snart',
                coming: true,
                onTap: () {},
              ),
            ]),
          ),
        ),
      ],
    );
  }
}
