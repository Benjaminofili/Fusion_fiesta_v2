class StorageService {
  Future<String> uploadFile(String path, {required String destination}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return 'https://storage.local/$destination';
  }
}

