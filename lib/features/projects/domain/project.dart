/// Prosjekt fra `public.projects`.
class Project {
  const Project({
    required this.id,
    required this.name,
    required this.status,
    this.description,
    this.siteAddress,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String status;
  final String? description;
  final String? siteAddress;
  final DateTime createdAt;

  String get displayName {
    final n = name.trim();
    return n.isNotEmpty ? n : 'Prosjekt uten navn';
  }

  String? get subtitle {
    final addr = siteAddress?.trim();
    if (addr != null && addr.isNotEmpty) return addr;
    return description?.trim();
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      name: (json['name'] as String?)?.trim() ?? '',
      status: json['status'] as String,
      description: (json['description'] as String?)?.trim(),
      siteAddress: (json['site_address'] as String?)?.trim(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'status': status,
        'description': description,
        'site_address': siteAddress,
        'created_at': createdAt.toUtc().toIso8601String(),
      };
}
