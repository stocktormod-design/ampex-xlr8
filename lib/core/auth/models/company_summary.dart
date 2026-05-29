class CompanySummary {
  const CompanySummary({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  factory CompanySummary.fromJson(Map<String, dynamic> json) {
    return CompanySummary(
      id: json['id'] as String,
      name: (json['name'] as String?)?.trim() ?? '',
    );
  }
}
