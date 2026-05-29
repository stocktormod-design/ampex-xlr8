import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/is_online_provider.dart';
import '../data/orders_repository.dart';
import '../domain/order.dart';
import '../domain/order_detail.dart';

final ordersListProvider = FutureProvider.autoDispose<List<Order>>((ref) async {
  final repo = ref.watch(ordersRepositoryProvider);
  final online = ref.watch(isOnlineProvider);
  return repo.listOrders(online: online);
});

final orderDetailProvider =
    FutureProvider.autoDispose.family<OrderDetail?, String>((ref, id) async {
  final repo = ref.watch(ordersRepositoryProvider);
  final online = ref.watch(isOnlineProvider);
  return repo.getOrderDetail(id, online: online);
});

/// Ordre som trenger oppmerksomhet (aktiv / venter montør).
enum OrderStatusFilter {
  all,
  active,
  waiting,
  finished,
}

extension OrderStatusFilterX on OrderStatusFilter {
  String get label => switch (this) {
        OrderStatusFilter.all => 'Alle',
        OrderStatusFilter.active => 'Pågår',
        OrderStatusFilter.waiting => 'Venter',
        OrderStatusFilter.finished => 'Ferdig',
      };

  bool matches(String status) => switch (this) {
        OrderStatusFilter.all => true,
        OrderStatusFilter.active => status == 'active',
        OrderStatusFilter.waiting => status == 'awaiting_installer',
        OrderStatusFilter.finished =>
          status == 'finished' || status == 'approved',
      };
}

final orderStatusFilterProvider =
    StateProvider<OrderStatusFilter>((ref) => OrderStatusFilter.all);

final attentionOrdersProvider = Provider<List<Order>>((ref) {
  return ref.watch(ordersListProvider).maybeWhen(
        data: (orders) => orders
            .where((o) =>
                o.status == 'active' || o.status == 'awaiting_installer')
            .take(5)
            .toList(),
        orElse: () => const [],
      );
});

final ordersCountProvider = Provider<int>((ref) {
  return ref.watch(ordersListProvider).maybeWhen(
        data: (orders) => orders.length,
        orElse: () => 0,
      );
});
