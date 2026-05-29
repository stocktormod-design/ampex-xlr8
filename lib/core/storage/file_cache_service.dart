import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../network/supabase_provider.dart';

final fileCacheServiceProvider = Provider<FileCacheService>((ref) {
  return FileCacheService(
    ref.watch(supabaseClientProvider),
    ref.watch(appDatabaseProvider),
  );
});

/// Laster ned og cacher PDF/filer fra Supabase Storage (mobil/desktop).
class FileCacheService {
  FileCacheService(this._client, this._db);

  final SupabaseClient _client;
  final AppDatabase _db;

  /// Returnerer lokal filsti, eller signer URL på web.
  Future<CachedFileHandle> resolvePdf({
    required String bucket,
    required String remotePath,
    required String entityType,
    required String entityId,
    required bool online,
  }) async {
    if (kIsWeb) {
      if (!online) {
        throw FileCacheException(
          'PDF er ikke tilgjengelig offline i nettleseren. Bruk mobilappen.',
        );
      }
      final bytes = await _client.storage.from(bucket).download(remotePath);
      return CachedFileHandle.bytes(bytes);
    }

    final cached = await _findCached(remotePath);
    if (cached != null) {
      final file = File(cached.localPath);
      if (await file.exists()) {
        return CachedFileHandle.file(cached.localPath, fromCache: true);
      }
    }

    if (!online) {
      throw FileCacheException(
        'PDF er ikke lastet ned. Koble til nett for å åpne tegningen.',
      );
    }

    final bytes = await _client.storage.from(bucket).download(remotePath);
    final localPath = await _writePdf(remotePath, bytes);
    await _register(
      remotePath: remotePath,
      localPath: localPath,
      entityType: entityType,
      entityId: entityId,
      sizeBytes: bytes.length,
    );
    return CachedFileHandle.file(localPath, fromCache: false);
  }

  Future<CachedFile?> _findCached(String remotePath) async {
    return (_db.select(_db.cachedFiles)
          ..where((t) => t.remotePath.equals(remotePath)))
        .getSingleOrNull();
  }

  Future<String> _writePdf(String remotePath, List<int> bytes) async {
    final dir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory(p.join(dir.path, 'pdf_cache'));
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    final safeName = remotePath.replaceAll(RegExp(r'[^\w\-.]'), '_');
    final file = File(p.join(cacheDir.path, safeName));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<void> _register({
    required String remotePath,
    required String localPath,
    required String entityType,
    required String entityId,
    required int sizeBytes,
  }) async {
    await _db.into(_db.cachedFiles).insertOnConflictUpdate(
          CachedFilesCompanion(
            remotePath: Value(remotePath),
            localPath: Value(localPath),
            mimeType: const Value('application/pdf'),
            entityType: Value(entityType),
            entityId: Value(entityId),
            openedAt: Value(DateTime.now().toUtc()),
            sizeBytes: Value(sizeBytes),
          ),
        );
  }

  Future<bool> isCached(String remotePath) async {
    if (kIsWeb) return false;
    final row = await _findCached(remotePath);
    if (row == null) return false;
    return File(row.localPath).exists();
  }
}

class CachedFileHandle {
  const CachedFileHandle._({
    this.localPath,
    this.bytes,
    this.fromCache = false,
  });

  factory CachedFileHandle.file(String path, {required bool fromCache}) =>
      CachedFileHandle._(localPath: path, fromCache: fromCache);

  factory CachedFileHandle.bytes(List<int> bytes) =>
      CachedFileHandle._(bytes: bytes);

  final String? localPath;
  final List<int>? bytes;
  final bool fromCache;

  bool get isInMemory => bytes != null;
}

class FileCacheException implements Exception {
  const FileCacheException(this.message);
  final String message;

  @override
  String toString() => message;
}
