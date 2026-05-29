/// Tegning fra `public.drawings`.
class Drawing {
  const Drawing({
    required this.id,
    required this.projectId,
    required this.name,
    required this.filePath,
    this.revision,
    required this.isPublished,
    required this.createdAt,
    this.isArchived = false,
  });

  final String id;
  final String projectId;
  final String name;
  final String filePath;
  final String? revision;
  final bool isPublished;
  final DateTime createdAt;
  final bool isArchived;

  String get displayName {
    final n = name.trim();
    return n.isNotEmpty ? n : 'Uten navn';
  }

  String? get revisionLabel {
    final r = revision?.trim();
    if (r == null || r.isEmpty) return null;
    return 'Rev. $r';
  }

  factory Drawing.fromJson(Map<String, dynamic> json) {
    return Drawing(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      name: (json['name'] as String?)?.trim() ?? '',
      filePath: json['file_path'] as String,
      revision: (json['revision'] as String?)?.trim(),
      isPublished: json['is_published'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      isArchived: json['is_archived'] as bool? ?? false,
    );
  }
}
