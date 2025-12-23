class AppFailure implements Exception {
  AppFailure(this.message);

  final String message;

  @override
  String toString() => 'AppFailure($message)';
}

/// Authentication-related failures
class AuthFailure extends AppFailure {
  AuthFailure(super.message);

  @override
  String toString() => 'AuthFailure($message)';
}

/// Network-related failures
class NetworkFailure extends AppFailure {
  NetworkFailure(super.message);

  @override
  String toString() => 'NetworkFailure($message)';
}

/// Validation-related failures
class ValidationFailure extends AppFailure {
  ValidationFailure(super.message);

  @override
  String toString() => 'ValidationFailure($message)';
}

/// Database-related failures
class DatabaseFailure extends AppFailure {
  DatabaseFailure(super.message);

  @override
  String toString() => 'DatabaseFailure($message)';
}

/// Storage-related failures (file uploads, etc.)
class StorageFailure extends AppFailure {
  StorageFailure(super.message);

  @override
  String toString() => 'StorageFailure($message)';
}

/// Permission-related failures
class PermissionFailure extends AppFailure {
  PermissionFailure(super.message);

  @override
  String toString() => 'PermissionFailure($message)';
}
