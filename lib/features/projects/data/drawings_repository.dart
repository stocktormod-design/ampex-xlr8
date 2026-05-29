import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_provider.dart';
import '../domain/drawing.dart';

final drawingsRepositoryProvider = Provider<DrawingsRepository>((ref) {
  return DrawingsRepository(ref.watch(supabaseClientProvider));
});

class DrawingsRepository {
  DrawingsRepository(this._client);

  final SupabaseClient _client;

  static const _select = '''
id,
project_id,
name,
file_path,
revision,
is_published,
is_archived,
created_at
''';

  Future<List<Drawing>> listForProject(String projectId) async {
    final rows = await _client
        .from('drawings')
        .select(_select)
        .eq('project_id', projectId)
        .eq('is_archived', false)
        .order('created_at', ascending: false);

    return (rows as List)
        .map((e) => Drawing.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<Drawing?> getById(String drawingId) async {
    final row = await _client
        .from('drawings')
        .select(_select)
        .eq('id', drawingId)
        .maybeSingle();

    if (row == null) return null;
    return Drawing.fromJson(Map<String, dynamic>.from(row));
  }
}
