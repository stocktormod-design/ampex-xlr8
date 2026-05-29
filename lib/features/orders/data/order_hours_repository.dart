import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/network/is_online_provider.dart';
import '../../../core/network/supabase_provider.dart';
import '../../../core/sync/sync_outbox_writer.dart';
import '../../../core/sync/sync_providers.dart';

final orderHoursRepositoryProvider = Provider<OrderHoursRepository>((ref) {
  return OrderHoursRepository(
    ref.watch(supabaseClientProvider),
    ref.watch(syncOutboxWriterProvider),
    () => ref.read(isOnlineProvider),
  );
});

class RegisterOrderHourInput {
  const RegisterOrderHourInput({
    required this.orderId,
    required this.userId,
    required this.workDate,
    required this.minutes,
    this.note,
  });

  final String orderId;
  final String userId;
  final DateTime workDate;
  final int minutes;
  final String? note;
}

class OrderHoursRepository {
  OrderHoursRepository(
    this._client,
    this._outbox,
    this._isOnline,
  );

  final SupabaseClient _client;
  final SyncOutboxWriter _outbox;
  final bool Function() _isOnline;

  static const _uuid = Uuid();

  Future<void> registerHour(RegisterOrderHourInput input) async {
    if (input.minutes <= 0) {
      throw const OrderHoursException('Angi varighet over 0 minutter.');
    }

    final payload = <String, dynamic>{
      'order_id': input.orderId,
      'user_id': input.userId,
      'work_date': _dateOnly(input.workDate),
      'minutes': input.minutes,
      if (input.note != null && input.note!.trim().isNotEmpty)
        'note': input.note!.trim(),
    };

    if (_isOnline()) {
      try {
        await _client.from('order_hours').insert(payload);
        return;
      } on PostgrestException catch (e) {
        throw OrderHoursException(e.message);
      }
    }

    await _outbox.enqueue(
      entityType: 'order_hours',
      entityId: _uuid.v4(),
      operation: 'insert',
      payload: payload,
    );
  }

  String _dateOnly(DateTime date) {
    final local = DateTime(date.year, date.month, date.day);
    return local.toIso8601String().split('T').first;
  }
}

class OrderHoursException implements Exception {
  const OrderHoursException(this.message);
  final String message;

  @override
  String toString() => message;
}
