import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/routes.dart';
import '../../../core/theme/app_breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/ampex_empty_state.dart';
import '../../../core/widgets/ampex_error_banner.dart';
import '../../../core/widgets/ampex_grouped_section.dart';
import '../../../core/widgets/ampex_list_row.dart';
import '../../../core/widgets/ampex_scaffold.dart';
import '../../../core/widgets/ampex_search_field.dart';
import '../../shared/status_labels.dart';
import '../../shared/status_pill.dart';
import '../data/orders_repository.dart';
import '../domain/order.dart';
import 'orders_providers.dart';

class OrdersListScreen extends ConsumerStatefulWidget {
  const OrdersListScreen({super.key});

  @override
  ConsumerState<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends ConsumerState<OrdersListScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Order> _filter(List<Order> orders, OrderStatusFilter statusFilter) {
    var result = orders.where((o) => statusFilter.matches(o.status));
    if (_query.isEmpty) return result.toList();
    final q = _query.toLowerCase();
    return result
        .where(
          (o) =>
              o.displayTitle.toLowerCase().contains(q) ||
              (o.subtitle?.toLowerCase().contains(q) ?? false) ||
              orderStatusLabel(o.status).toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersListProvider);
    final statusFilter = ref.watch(orderStatusFilterProvider);
    final hPad = context.isMobile ? AppSpacing.screenH : AppSpacing.xl;

    return AmpexScaffold(
      title: 'Ordre',
      onRefresh: () => ref.refresh(ordersListProvider.future),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(hPad, 0, hPad, AppSpacing.sm),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: OrderStatusFilter.values.map((f) {
                  final selected = statusFilter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: FilterChip(
                      label: Text(f.label),
                      selected: selected,
                      onSelected: (_) =>
                          ref.read(orderStatusFilterProvider.notifier).state = f,
                      selectedColor: AppColors.accentSoft,
                      checkmarkColor: AppColors.accent,
                      side: BorderSide(
                        color: selected ? AppColors.accent : AppColors.border,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(hPad, 0, hPad, AppSpacing.md),
            child: AmpexSearchField(
              controller: _searchController,
              hint: 'Søk ordre, kunde, adresse…',
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
          ),
        ),
        ordersAsync.when(
          loading: () => const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (e, _) => SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.all(hPad),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AmpexErrorBanner(
                    message: e is OrdersException
                        ? e.message
                        : 'Kunne ikke laste ordre.',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    onPressed: () => ref.invalidate(ordersListProvider),
                    child: const Text('Prøv igjen'),
                  ),
                ],
              ),
            ),
          ),
          data: (orders) {
            final filtered = _filter(orders, statusFilter);

            if (orders.isEmpty) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: AmpexEmptyState(
                  icon: CupertinoIcons.doc_text,
                  title: 'Ingen ordre',
                  body: 'Ordre du har tilgang til\nvises her.',
                ),
              );
            }

            if (filtered.isEmpty) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: AmpexEmptyState(
                  icon: CupertinoIcons.search,
                  title: 'Ingen treff',
                  body: 'Prøv et annet søkeord.',
                ),
              );
            }

            return SliverToBoxAdapter(
              child: AmpexGroupedSection(
                margin: EdgeInsets.symmetric(horizontal: hPad),
                dividerIndent: AppSpacing.rowH,
                children: [
                  for (final order in filtered)
                    AmpexListRow(
                      title: order.displayTitle,
                      subtitle: order.subtitle,
                      trailing: StatusPill(
                        label: orderStatusLabel(order.status),
                        color: orderStatusColor(order.status),
                      ),
                      showChevron: false,
                      onTap: () => context.push('${Routes.orders}/${order.id}'),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
