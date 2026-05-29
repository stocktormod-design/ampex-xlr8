import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/network/supabase_provider.dart';
import '../domain/project.dart';

final projectsRepositoryProvider = Provider<ProjectsRepository>((ref) {
  return ProjectsRepository(
    ref.watch(supabaseClientProvider),
    ref.watch(appDatabaseProvider),
  );
});

class ProjectsRepository {
  ProjectsRepository(this._client, this._db);

  final SupabaseClient _client;
  final AppDatabase _db;

  static const _listSelect = '''
id,
name,
description,
status,
site_address,
created_at
''';

  Future<List<Project>> listProjects({required bool online}) async {
    if (online) {
      try {
        final remote = await _fetchAll();
        await _replaceCache(remote);
        return remote;
      } on PostgrestException catch (e) {
        final cached = await _readCache();
        if (cached.isNotEmpty) return cached;
        throw ProjectsException(e.message);
      } catch (e) {
        final cached = await _readCache();
        if (cached.isNotEmpty) return cached;
        throw ProjectsException('Kunne ikke laste prosjekter.');
      }
    }
    return _readCache();
  }

  Future<Project?> getProject(String id, {required bool online}) async {
    final cached = await _readOneFromCache(id);
    if (online) {
      try {
        final remote = await _fetchOne(id);
        if (remote != null) {
          await _upsertCache(remote);
          return remote;
        }
        return cached;
      } catch (_) {
        return cached;
      }
    }
    return cached;
  }

  Future<List<Project>> _fetchAll() async {
    final rows = await _client
        .from('projects')
        .select(_listSelect)
        .order('created_at', ascending: false)
        .limit(200);

    return (rows as List)
        .map((e) => Project.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<Project?> _fetchOne(String id) async {
    final row = await _client
        .from('projects')
        .select(_listSelect)
        .eq('id', id)
        .maybeSingle();

    if (row == null) return null;
    return Project.fromJson(Map<String, dynamic>.from(row));
  }

  Future<List<Project>> _readCache() async {
    final rows = await (_db.select(_db.localProjects)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();

    return rows.map(_projectFromLocal).toList();
  }

  Future<Project?> _readOneFromCache(String id) async {
    final row =
        await (_db.select(_db.localProjects)..where((t) => t.id.equals(id)))
            .getSingleOrNull();
    if (row == null) return null;
    return _projectFromLocal(row);
  }

  Project _projectFromLocal(LocalProject row) {
    if (row.detailJson != null) {
      try {
        return Project.fromJson(
          jsonDecode(row.detailJson!) as Map<String, dynamic>,
        );
      } catch (_) {
        // fall through
      }
    }
    return Project(
      id: row.id,
      name: row.name,
      status: row.status,
      description: row.description,
      siteAddress: row.siteAddress,
      createdAt: row.createdAt,
    );
  }

  Future<void> _replaceCache(List<Project> projects) async {
    await _db.transaction(() async {
      await _db.delete(_db.localProjects).go();
      for (final project in projects) {
        await _upsertCache(project);
      }
    });
  }

  Future<void> _upsertCache(Project project) async {
    final companion = LocalProjectsCompanion(
      id: Value(project.id),
      name: Value(project.name),
      status: Value(project.status),
      siteAddress: Value(project.siteAddress),
      description: Value(project.description),
      createdAt: Value(project.createdAt),
      detailJson: Value(jsonEncode(project.toJson())),
    );
    await _db.into(_db.localProjects).insertOnConflictUpdate(companion);
  }
}

class ProjectsException implements Exception {
  const ProjectsException(this.message);
  final String message;

  @override
  String toString() => message;
}
