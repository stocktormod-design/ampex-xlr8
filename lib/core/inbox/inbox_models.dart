/// Lokal innboks (erstattes med Supabase + push senere).
class InboxMessage {
  const InboxMessage({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.read = false,
    this.kind = InboxMessageKind.info,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;
  final InboxMessageKind kind;
}

enum InboxMessageKind { info, lidarRequest, alert }
