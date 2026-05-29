import 'company_summary.dart';
import 'user_profile.dart';

class SessionContext {
  const SessionContext({
    required this.profile,
    required this.company,
  });

  final UserProfile profile;
  final CompanySummary company;

  String get displayName =>
      profile.fullName.isNotEmpty ? profile.fullName : 'Bruker';

  String get companyName =>
      company.name.isNotEmpty ? company.name : 'Firma';
}
