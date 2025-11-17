class AppFailure implements Exception {
  AppFailure(this.message);

  final String message;

  @override
  String toString() => 'AppFailure($message)';
}

