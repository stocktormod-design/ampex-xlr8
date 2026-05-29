import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../network/supabase_provider.dart';
import 'models/company_summary.dart';
import 'models/session_context.dart';
import 'models/user_profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(supabaseClientProvider));
});

class ProfileRepository {
  ProfileRepository(this._client);

  final SupabaseClient _client;

  Future<SessionContext> fetchSessionContext(String userId) async {
    final row = await _client
        .from('profiles')
        .select('id, full_name, role, company_id, companies(id, name)')
        .eq('id', userId)
        .maybeSingle();

    if (row == null) {
      throw const ProfileException('Fant ingen brukerprofil for denne kontoen.');
    }

    final companyJson = row['companies'];
    if (companyJson is! Map<String, dynamic>) {
      throw const ProfileException('Fant ikke firmatilknytning for brukeren.');
    }

    return SessionContext(
      profile: UserProfile.fromJson(row),
      company: CompanySummary.fromJson(companyJson),
    );
  }
}

class ProfileException implements Exception {
  const ProfileException(this.message);
  final String message;

  @override
  String toString() => message;
}
