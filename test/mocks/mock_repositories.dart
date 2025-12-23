import 'dart:io';
import 'package:mocktail/mocktail.dart';
import 'package:fusion_fiesta/data/repositories/auth_repository.dart';
import 'package:fusion_fiesta/data/repositories/user_repository.dart';

/// Mock AuthRepository for testing
/// Used to simulate authentication operations without hitting real Supabase
class MockAuthRepository extends Mock implements AuthRepository {}

/// Mock UserRepository for testing
/// Used to simulate user data operations
class MockUserRepository extends Mock implements UserRepository {}

/// Register fallback values for mocktail
/// This is required for methods that take non-primitive parameters
void registerMockFallbacks() {
  // Register File fallback for image upload tests
  registerFallbackValue(File(''));

  // If you have custom objects that are passed to methods, register them here
  // Example: registerFallbackValue(YourCustomObject());
}
