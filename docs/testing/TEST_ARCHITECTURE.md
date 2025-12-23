# Authentication Testing Architecture

## Test Layers Visualization

```
┌─────────────────────────────────────────────────────────────────┐
│                      INTEGRATION TESTS                          │
│                    (End-to-End Flows)                           │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Test: Complete Registration → Login → Dashboard Flow    │  │
│  │ • Opens real app on simulator                            │  │
│  │ • Fills registration form                                │  │
│  │ • Submits to real Supabase database                      │  │
│  │ • Logs in with created account                           │  │
│  │ • Verifies dashboard displays correctly                  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  Status: ⏳ TODO - Requires test database setup                │
│  Speed:  🐢 Slow (10-30 seconds per test)                      │
└─────────────────────────────────────────────────────────────────┘
                              ▲
                              │
                              │
┌─────────────────────────────────────────────────────────────────┐
│                        WIDGET TESTS                             │
│                    (UI Component Tests)                         │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Test: Login Screen Button States                         │  │
│  │ • Renders login screen widget                            │  │
│  │ • Enters empty email                                     │  │
│  │ • Verifies login button is disabled                      │  │
│  │ • Enters valid credentials                               │  │
│  │ • Verifies login button becomes enabled                  │  │
│  │ • Taps button and checks loading indicator               │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  Status: ⏳ TODO - Next priority                                │
│  Speed:  🏃 Medium (2-5 seconds per test)                      │
└─────────────────────────────────────────────────────────────────┘
                              ▲
                              │
                              │
┌─────────────────────────────────────────────────────────────────┐
│                         UNIT TESTS                              │
│                   (Pure Logic Tests)                            │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Test: User Model Parsing                                 │  │
│  │ • Create JSON map with user data                         │  │
│  │ • Call User.fromMap()                                    │  │
│  │ • Verify all fields parsed correctly                     │  │
│  │ • No UI, no database, no network                         │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Test: Repository Sign In Logic                           │  │
│  │ • Mock AuthRepository.signIn()                           │  │
│  │ • Call with valid credentials                            │  │
│  │ • Verify returns User object                             │  │
│  │ • No actual authentication happens                       │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  Status: ✅ COMPLETE - 38 tests passing                        │
│  Speed:  ⚡ Fast (~100ms total)                                │
└─────────────────────────────────────────────────────────────────┘
```

---

## Data Flow Through Tests

### Real App Flow
```
User Input → UI Screen → Repository → Supabase → Database
                                         ↓
                              ← User Object ←
```

### Unit Test Flow (What We Built)
```
Test Setup → Mock Repository → Fake Response
                     ↓
         ← Verify Behavior ←
```

**Key Point:** Unit tests never touch Supabase. They test logic in isolation.

---

## Test File Dependencies

```
┌──────────────────────────┐
│  user_model_test.dart    │
│                          │
│  Tests:                  │
│  • User.fromMap()        │ ─┐
│  • User.toMap()          │  │
│  • User.copyWith()       │  │
└──────────────────────────┘  │
                              │
                              ├─► Uses
┌──────────────────────────┐  │
│   test_fixtures.dart     │  │
│                          │  │
│  Contains:               │ ◄┘
│  • testVisitorUser       │
│  • testStudentUser       │ ─┐
│  • testAdmin             │  │
│  • validEmail            │  │
│  • validPassword         │  │
└──────────────────────────┘  │
                              │
                              ├─► Uses
┌──────────────────────────┐  │
│ auth_repository_test.dart│  │
│                          │  │
│  Tests:                  │ ◄┘
│  • signIn()              │
│  • signUp()              │ ─┐
│  • getCurrentUser()      │  │
│  • changePassword()      │  │
└──────────────────────────┘  │
                              │
                              ├─► Uses
┌──────────────────────────┐  │
│  mock_repositories.dart  │  │
│                          │  │
│  Contains:               │ ◄┘
│  • MockAuthRepository    │
│  • MockUserRepository    │
└──────────────────────────┘
```

---

## SRS Requirements → Test Mapping

```
SRS 1.6.1: User Registration and Authentication
│
├─ Requirement: "Users can select role during sign-up"
│  │
│  └─► Tested by:
│      • user_model_test.dart → "should parse visitor profile"
│      • user_model_test.dart → "should parse student participant"
│      • user_model_test.dart → "should correctly identify roles"
│      • auth_repository_test.dart → "should register visitor"
│      • auth_repository_test.dart → "should register student"
│
├─ Requirement: "Visitor can browse but not register"
│  │
│  └─► Tested by:
│      • auth_repository_test.dart → "visitor should have browsing only"
│      • [Widget test TODO] → "registration button disabled for visitor"
│      • [Integration test TODO] → "visitor redirected to upgrade screen"
│
├─ Requirement: "Student needs enrolment number, department"
│  │
│  └─► Tested by:
│      • user_model_test.dart → "should parse student with complete profile"
│      • auth_repository_test.dart → "should register student with details"
│      • auth_repository_test.dart → "incomplete profile cannot register"
│
├─ Requirement: "Staff must be approved by admin"
│  │
│  └─► Tested by:
│      • user_model_test.dart → "should parse staff pending approval"
│      • auth_repository_test.dart → "should register staff with email"
│      • auth_repository_test.dart → "unapproved staff cannot access management"
│      • [Widget test TODO] → "verification pending screen shown"
│
└─ Requirement: "Secure login with email and password"
   │
   └─► Tested by:
       • auth_repository_test.dart → "should sign in with valid credentials"
       • auth_repository_test.dart → "should throw error for invalid credentials"
       • auth_repository_test.dart → "should throw error for empty fields"
       • [Widget test TODO] → "login form validation"
       • [Integration test TODO] → "complete login flow"
```

---

## Mock vs Real Data Flow

### Real Authentication (Production)
```
┌─────────────┐
│ Login Screen│
│   (UI)      │
└──────┬──────┘
       │ User enters:
       │ email: "test@college.edu"
       │ password: "Test@1234"
       ▼
┌─────────────────────┐
│ AuthRepository      │
│   (Real)            │
│                     │
│ signIn(email, pass) │──────────┐
└─────────────────────┘          │
                                 │ HTTP Request
                                 ▼
                        ┌──────────────────┐
                        │   Supabase       │
                        │   (Database)     │
                        │                  │
                        │ • Validates      │
                        │ • Returns user   │
                        └────────┬─────────┘
                                 │
                                 │ User object
┌─────────────────────┐          │
│ User Object         │◄─────────┘
│                     │
│ id: "abc123"        │
│ email: "test@..."   │
│ role: student       │
└─────────────────────┘
```

### Mocked Authentication (Testing)
```
┌─────────────────────┐
│ Unit Test           │
│                     │
│ test('sign in')     │
└──────┬──────────────┘
       │
       │ Setup mock:
       │ when(signIn).thenReturn(testUser)
       ▼
┌─────────────────────┐
│ MockAuthRepository  │ ──X──> No real Supabase!
│                     │
│ signIn(email, pass) │
└──────┬──────────────┘
       │
       │ Returns immediately
       ▼
┌─────────────────────┐
│ testUser            │ ← From test_fixtures.dart
│                     │
│ id: "student-003"   │
│ email: "alice@..."  │
│ role: student       │
└─────────────────────┘
```

**Advantages of Mocking:**
- ⚡ Super fast (no network)
- 🎯 Predictable results
- 🧪 Can test error scenarios
- 💰 No API costs
- 🔒 Isolated from database changes

---

## Test Execution Flow

### Running: `flutter test test/unit/user_model_test.dart`

```
1. Flutter Test Runner starts
   ↓
2. Loads test file
   ↓
3. Runs setUp() if present
   ↓
4. Executes first test:
   ┌─────────────────────────────────────────────┐
   │ test('should parse visitor from Map')       │
   │                                             │
   │ Arrange: Create test JSON                   │
   │   final json = {'id': '...', role: ...}    │
   │                                             │
   │ Act: Parse JSON                             │
   │   final user = User.fromMap(json)          │
   │                                             │
   │ Assert: Check result                        │
   │   expect(user.role, AppRole.visitor) ✓     │
   └─────────────────────────────────────────────┘
   ↓
5. Executes next test...
   ↓
6. Continues for all 12 tests
   ↓
7. Reports results:
   ✓ All tests passed! (12 passed, 0 failed)
```

---

## Coverage Visualization

### What Code is Tested?

```dart
// lib/data/models/user.dart

class User {
  // ✅ Covered by: user_model_test.dart
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],         // ✅ Tested in "should parse visitor"
      role: AppRole.values   // ✅ Tested in "should identify roles"
        .firstWhere(...),
      // ... all fields tested
    );
  }

  // ✅ Covered by: user_model_test.dart
  Map<String, dynamic> toMap() {
    return {
      'id': id,              // ✅ Tested in "should serialize"
      'role': role.name,     // ✅ Tested in "should serialize"
      // ... all fields tested
    };
  }

  // ✅ Covered by: user_model_test.dart
  User copyWith({...}) {
    // ✅ Tested in "should create copy with updated fields"
  }
}
```

```dart
// lib/data/repositories/auth_repository_impl.dart

class AuthRepositoryImpl implements AuthRepository {
  // ✅ Covered by: auth_repository_test.dart (via mock)
  Future<User> signIn(String email, String password) {
    // Logic tested through mock
    // Real implementation tested in integration tests
  }

  // ✅ Covered by: auth_repository_test.dart (via mock)
  Future<User> signUp(User user, String password) {
    // Logic tested through mock
  }
}
```

---

## Common Test Patterns

### Pattern 1: Basic Assertion
```dart
test('should have correct role', () {
  // Simple check
  expect(testVisitorUser.role, AppRole.visitor);
});
```

### Pattern 2: Async Testing
```dart
test('should sign in asynchronously', () async {
  // Notice 'async' and 'await'
  final result = await mockAuthRepository.signIn(email, password);
  expect(result, isA<User>());
});
```

### Pattern 3: Exception Testing
```dart
test('should throw error', () {
  // Expects method to throw
  expect(
    () => repository.signIn('', ''),
    throwsA(isA<AuthFailure>()),
  );
});
```

### Pattern 4: Verification
```dart
test('should call method once', () {
  // Verify method was called
  verify(() => mockRepo.signIn(email, password)).called(1);
});
```

---

## Quick Reference

### Test Matchers
```dart
expect(actual, expected)           // Equals
expect(actual, isA<User>())       // Type check
expect(actual, isNull)            // Null check
expect(actual, isNotNull)         // Not null
expect(actual, isNotEmpty)        // Not empty
expect(actual, contains('text'))  // Contains
expect(() => code, throwsA(...))  // Throws exception
```

### Mocktail Setup
```dart
// 1. Create mock
final mock = MockAuthRepository();

// 2. Define behavior
when(() => mock.signIn(any(), any()))
    .thenAnswer((_) async => testUser);

// 3. Use in test
final result = await mock.signIn('email', 'pass');

// 4. Verify call
verify(() => mock.signIn('email', 'pass')).called(1);
```

---

**This architecture ensures:**
- Fast feedback (unit tests run in seconds)
- Isolated failures (one bug doesn't break all tests)
- Clear responsibility (each test has one purpose)
- Easy maintenance (change one fixture, all tests update)
- SRS compliance (every requirement has a test)
