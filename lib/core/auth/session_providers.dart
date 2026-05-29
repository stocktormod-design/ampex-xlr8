import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_repository.dart';
import 'models/session_context.dart';
import 'profile_repository.dart';

/// Laster profil + firma for innlogget bruker. Null når utlogget.
final sessionContextProvider = FutureProvider<SessionContext?>((ref) async {
  ref.watch(authStateProvider);

  final user = ref.read(authRepositoryProvider).currentUser;
  if (user == null) return null;

  return ref.read(profileRepositoryProvider).fetchSessionContext(user.id);
});
