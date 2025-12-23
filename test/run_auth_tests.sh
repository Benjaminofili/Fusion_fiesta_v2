# Run all authentication unit tests
flutter test test/unit/ --verbose

# Or run individual test files:
# flutter test test/unit/user_model_test.dart
# flutter test test/unit/auth_repository_test.dart

# Generate coverage report:
# flutter test test/unit/ --coverage
# genhtml coverage/lcov.info -o coverage/html
# open coverage/html/index.html
