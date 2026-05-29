class UserProfile {
  const UserProfile({
    required this.id,
    required this.companyId,
    required this.fullName,
    required this.role,
  });

  final String id;
  final String companyId;
  final String fullName;
  final String role;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      fullName: (json['full_name'] as String?)?.trim() ?? '',
      role: json['role'] as String,
    );
  }
}
