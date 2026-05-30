import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'inbox_models.dart';

final inboxProvider =
    StateNotifierProvider<InboxNotifier, List<InboxMessage>>((ref) {
  return InboxNotifier();
});

final inboxUnreadCountProvider = Provider<int>((ref) {
  return ref.watch(inboxProvider).where((m) => !m.read).length;
});

class InboxNotifier extends StateNotifier<List<InboxMessage>> {
  InboxNotifier() : super(const []);

  final _uuid = const Uuid();

  void push({
    required String title,
    required String body,
    InboxMessageKind kind = InboxMessageKind.info,
  }) {
    state = [
      InboxMessage(
        id: _uuid.v4(),
        title: title,
        body: body,
        createdAt: DateTime.now(),
        kind: kind,
      ),
      ...state,
    ];
  }

  void markRead(String id) {
    state = [
      for (final m in state)
        if (m.id == id) InboxMessage(
              id: m.id,
              title: m.title,
              body: m.body,
              createdAt: m.createdAt,
              read: true,
              kind: m.kind,
            )
        else
          m,
    ];
  }
}
