/// Abstraksjon for S3-kompatibel objektlagring.
/// Implementeres når opplasting/nedlasting av filer bygges (fase 1+).
abstract class ObjectStorage {
  Future<String> downloadToCache({
    required String remotePath,
    required String localPath,
  });

  Future<void> upload({
    required String remotePath,
    required String localPath,
    required String mimeType,
  });
}

class UnconfiguredObjectStorage implements ObjectStorage {
  @override
  Future<String> downloadToCache({
    required String remotePath,
    required String localPath,
  }) {
    throw UnimplementedError('S3 er ikke konfigurert ennå.');
  }

  @override
  Future<void> upload({
    required String remotePath,
    required String localPath,
    required String mimeType,
  }) {
    throw UnimplementedError('S3 er ikke konfigurert ennå.');
  }
}
