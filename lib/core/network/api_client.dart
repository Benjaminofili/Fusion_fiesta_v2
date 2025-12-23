class ApiClient {
  Future<Map<String, dynamic>> get(String path) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return {'path': path};
  }
}
