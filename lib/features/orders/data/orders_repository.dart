import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/network/supabase_provider.dart';
import '../domain/order.dart';
import '../domain/order_detail.dart';

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepository(
    ref.watch(supabaseClientProvider),
    ref.watch(appDatabaseProvider),
  );
});

class OrdersRepository {
  OrdersRepository(this._client, this._db);

  final SupabaseClient _client;
  final AppDatabase _db;

  static const _listSelect = '''
id,
title,
description,
status,
type,
updated_at,
archive_reference,
order_customers ( name, phone, address )
''';

  static const _detailSelect = '''
id,
title,
description,
status,
type,
created_at,
updated_at,
archive_reference,
assigned_installer_id,
order_customers ( name, phone, address ),
assigned_installer:profiles!orders_assigned_installer_id_fkey ( full_name )
''';

  Future<List<Order>> listOrders({required bool online}) async {
    if (online) {
      try {
        final remote = await _fetchAll();
        await _replaceCache(remote);
        return remote;
      } on PostgrestException catch (e) {
        final cached = await _readCache();
        if (cached.isNotEmpty) return cached;
        throw OrdersException(e.message);
      } catch (e) {
        final cached = await _readCache();
        if (cached.isNotEmpty) return cached;
        throw OrdersException('Kunne ikke laste ordre.');
      }
    }
    return _readCache();
  }

  Future<Order?> getOrder(String id, {required bool online}) async {
    final detail = await getOrderDetail(id, online: online);
    return detail?.order;
  }

  Future<OrderDetail?> getOrderDetail(String id, {required bool online}) async {
    if (online) {
      try {
        final remote = await _fetchDetail(id);
        if (remote != null) {
          await _upsertDetailCache(remote);
          return remote;
        }
        return _readDetailCacheAsync(id);
      } catch (_) {
        return _readDetailCacheAsync(id);
      }
    }
    return _readDetailCacheAsync(id);
  }

  Future<OrderDetail?> _fetchDetail(String id) async {
    final row = await _client
        .from('orders')
        .select(_detailSelect)
        .eq('id', id)
        .maybeSingle();

    if (row == null) return null;

    final orderMap = Map<String, dynamic>.from(row);
    final hours = await _client
        .from('order_hours')
        .select('id, work_date, minutes, note, profiles(full_name)')
        .eq('order_id', id)
        .order('work_date', ascending: false);

    final materials = await _client
        .from('order_materials')
        .select('id, name, quantity, unit, note')
        .eq('order_id', id)
        .order('created_at', ascending: false);

    final documentation = await _client
        .from('order_documentation')
        .select('id, section_key, template_type, is_completed')
        .eq('order_id', id)
        .order('section_key');

    final photos = await _client
        .from('order_photos')
        .select('id, file_path, caption, photo_type, created_at')
        .eq('order_id', id)
        .order('created_at', ascending: false);

    orderMap['order_hours'] = hours;
    orderMap['order_materials'] = materials;
    orderMap['order_documentation'] = documentation;
    orderMap['order_photos'] = photos;

    return OrderDetail.fromJson(orderMap);
  }

  Future<List<Order>> _fetchAll() async {
    final rows = await _client
        .from('orders')
        .select(_listSelect)
        .order('updated_at', ascending: false)
        .limit(200);

    return (rows as List)
        .map((e) => Order.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> _upsertDetailCache(OrderDetail detail) async {
    final order = detail.order;
    final companion = LocalOrdersCompanion(
      id: Value(order.id),
      title: Value(order.title),
      status: Value(order.status),
      type: Value(order.type),
      customerName: Value(order.customer.name),
      customerPhone: Value(order.customer.phone),
      customerAddress: Value(order.customer.address),
      description: Value(order.description),
      updatedAt: Value(order.updatedAt),
      detailJson: Value(jsonEncode(detail.toJson())),
    );
    await _db.into(_db.localOrders).insertOnConflictUpdate(companion);
  }

  Future<OrderDetail?> _readDetailCacheAsync(String id) async {
    final row = await (_db.select(_db.localOrders)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row?.detailJson == null) return null;
    try {
      return OrderDetail.fromJson(
        jsonDecode(row!.detailJson!) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<Order>> _readCache() async {
    final rows = await (_db.select(_db.localOrders)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();

    return rows.map(_orderFromLocal).toList();
  }

  Order _orderFromLocal(LocalOrder row) {
    if (row.detailJson != null) {
      try {
        final map = jsonDecode(row.detailJson!) as Map<String, dynamic>;
        if (map.containsKey('order_hours') ||
            map.containsKey('order_materials')) {
          return OrderDetail.fromJson(map).order;
        }
        return Order.fromJson(map);
      } catch (_) {
        // fall through
      }
    }
    return Order(
      id: row.id,
      title: row.title,
      status: row.status,
      type: row.type,
      description: row.description,
      updatedAt: row.updatedAt,
      customer: OrderCustomer(
        name: row.customerName,
        phone: row.customerPhone,
        address: row.customerAddress,
      ),
    );
  }

  Future<void> _replaceCache(List<Order> orders) async {
    await _db.transaction(() async {
      await _db.delete(_db.localOrders).go();
      for (final order in orders) {
        await _upsertCache(order);
      }
    });
  }

  Future<void> _upsertCache(Order order) async {
    final companion = LocalOrdersCompanion(
      id: Value(order.id),
      title: Value(order.title),
      status: Value(order.status),
      type: Value(order.type),
      customerName: Value(order.customer.name),
      customerPhone: Value(order.customer.phone),
      customerAddress: Value(order.customer.address),
      description: Value(order.description),
      updatedAt: Value(order.updatedAt),
      detailJson: Value(jsonEncode(order.toJson())),
    );
    await _db.into(_db.localOrders).insertOnConflictUpdate(companion);
  }
}

class OrdersException implements Exception {
  const OrdersException(this.message);
  final String message;

  @override
  String toString() => message;
}
