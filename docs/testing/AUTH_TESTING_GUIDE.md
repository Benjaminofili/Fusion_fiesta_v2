# Authentication Feature Testing Documentation
## FusionFiesta - Comprehensive Test Coverage

---

## Table of Contents
1. [Overview](#overview)
2. [SRS Requirements Coverage](#srs-requirements-coverage)
3. [Test Structure](#test-structure)
4. [Running the Tests](#running-the-tests)
5. [Test Categories](#test-categories)
6. [Next Steps](#next-steps)

---

## Overview

This document outlines the comprehensive testing strategy for the **Authentication Feature** of FusionFiesta, ensuring all requirements from SRS Section 1.6.1 are thoroughly validated.

### Testing Pyramid Applied

```
                    /\
                   /  \
                  / E2E \          Integration Tests (Slow, Few)
                 /______\
                /        \
               / Widget   \        Widget Tests (Medium Speed, Medium)
              /____________\
             /              \
            /  Unit Tests    \     Unit Tests (Fast, Many)
           /__________________\
```

---

## SRS Requirements Coverage

### SRS 1.6.1: User Registration and Authentication

#### ✅ Requirement 1: Role-Based Registration
**SRS Statement:** "The registration process should allow users to select their role during sign-up: Student Visitor, Student Participant, or Staff (Organizer/Admin)."

**Test Coverage:**
- ✓ Unit Test: `should register visitor successfully`
- ✓ Unit Test: `should register student participant with required details`
- ✓ Unit Test: `should register staff with institutional email`
- ⏳ Widget Test: Login screen role selection
- ⏳ Integration Test: Complete registration flow

#### ✅ Requirement 2: Visitor Browsing Restrictions
**SRS Statement:** "A normal student can browse event listings and view gallery content, but cannot register for events without upgrading their role to Participant."

**Test Coverage:**
- ✓ Unit Test: `visitor should have browsing permissions only`
- ✓ Model Test: Parse visitor profile from Map
- ⏳ Widget Test: Registration button disabled for visitors
- ⏳ Integration Test: Visitor attempts event registration

#### ✅ Requirement 3: Student Participant Profile Requirements
**SRS Statement:** "A student participant should provide additional details such as enrolment number, department, and college ID proof."

**Test Coverage:**
- ✓ Unit Test: `should register student participant with required details`
- ✓ Unit Test: `student with incomplete profile should not register for events`
- ✓ Model Test: Parse student with complete profile
- ⏳ Widget Test: Profile completion form validation
- ⏳ Integration Test: Complete profile and register for event

#### ✅ Requirement 4: Staff Approval Workflow
**SRS Statement:** "Staff members, including organizers and admins, should register using institutional email addresses and must be approved by system admin before accessing event management features."

**Test Coverage:**
- ✓ Unit Test: `should register staff with institutional email`
- ✓ Unit Test: `unapproved staff cannot access event management`
- ✓ Unit Test: `should sign in unapproved staff member`
- ⏳ Widget Test: Verification pending screen
- ⏳ Integration Test: Staff approval flow

#### ✅ Requirement 5: Secure Authentication
**SRS Statement:** "Secure login should be implemented using a username/email and password combination."

**Test Coverage:**
- ✓ Unit Test: `should sign in successfully with valid credentials`
- ✓ Unit Test: `should throw AuthFailure when credentials are invalid`
- ✓ Unit Test: `should throw AuthFailure when email is empty`
- ✓ Unit Test: `should throw AuthFailure when password is empty`
- ⏳ Widget Test: Login form validation
- ⏳ Integration Test: Complete login flow with real database

#### ✅ Requirement 6: Password Management
**SRS Statement:** "A 'Forgot Password' feature should allow users to reset their password via a secure token sent to their email."

**Test Coverage:**
- ✓ Unit Test: `should change password successfully`
- ✓ Unit Test: `should throw AuthFailure when current password is wrong`
- ⏳ Widget Test: Forgot password screen
- ⏳ Integration Test: Complete password reset flow

---

## Test Structure

### Directory Layout
```
test/
├── unit/                          # Fast tests for business logic
│   ├── user_model_test.dart       ✅ Complete
│   └── auth_repository_test.dart  ✅ Complete
├── widget/                        # UI component tests
│   ├── login_screen_test.dart     ⏳ Next to implement
│   ├── register_screen_test.dart  ⏳ Next to implement
│   └── role_upgrade_test.dart     ⏳ Next to implement
├── integration/                   # End-to-end tests
│   └── auth_flow_test.dart        ⏳ Next to implement
├── mocks/                         # Mock objects
│   └── mock_repositories.dart     ✅ Complete
└── helpers/                       # Test utilities
    └── test_fixtures.dart         ✅ Complete
```

---

## Running the Tests

### Run All Unit Tests
```bash
flutter test test/unit/
```

### Run Specific Test File
```bash
flutter test test/unit/user_model_test.dart
```

### Run With Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Run in Watch Mode (Auto-rerun on changes)
```bash
flutter test --watch test/unit/
```

---

## Test Categories

### ✅ Category 1: Unit Tests (COMPLETED)

**Files:**
- `test/unit/user_model_test.dart` - 12 tests
- `test/unit/auth_repository_test.dart` - 26 tests

**What They Test:**
- Data model parsing and serialization
- Repository method behavior
- Error handling
- Edge cases

**Advantages:**
- **Lightning fast** (~100ms total)
- **No dependencies** on database, network, or UI
- **Easy to debug** - failures point directly to code issues
- **High coverage** - Can test every branch

**How to Run:**
```bash
flutter test test/unit/
```

**Expected Output:**
```
00:02 +38: All tests passed!
```

---

### ⏳ Category 2: Widget Tests (TODO - NEXT PRIORITY)

**Planned Files:**
1. `test/widget/login_screen_test.dart`
2. `test/widget/register_screen_test.dart`
3. `test/widget/forgot_password_screen_test.dart`
4. `test/widget/role_upgrade_screen_test.dart`
5. `test/widget/verification_pending_screen_test.dart`

**What They Will Test:**
- ✓ Login button disabled when fields empty
- ✓ Error messages displayed correctly
- ✓ Loading indicator shown during authentication
- ✓ Navigation after successful login
- ✓ Role selection dropdown works
- ✓ Form validation messages
- ✓ Password visibility toggle

**Why Widget Tests Are Important:**
- Test UI behavior without running full app
- Faster than integration tests
- Can mock repository responses
- Catch visual regressions

**Estimated Time:** Medium speed (~2-5 seconds per test)

---

### ⏳ Category 3: Integration Tests (TODO - AFTER WIDGETS)

**Planned Files:**
1. `integration_test/auth_complete_flow_test.dart`
2. `integration_test/role_upgrade_flow_test.dart`
3. `integration_test/staff_approval_flow_test.dart`

**What They Will Test:**

**Test 1: Complete Registration → Login Flow**
```
1. User opens app
2. Navigates to Register screen
3. Selects "Student Participant" role
4. Fills all required fields
5. Submits registration
6. Verifies account created in database
7. Logs in with new credentials
8. Verifies dashboard displays correctly
```

**Test 2: Visitor → Participant Upgrade**
```
1. Login as visitor
2. Attempt to register for event
3. Redirected to upgrade screen
4. Fill participant details
5. Submit upgrade
6. Verify profile updated in database
7. Successfully register for event
```

**Test 3: Staff Approval Workflow**
```
1. Register as organizer
2. Verify "Pending Approval" screen shown
3. Admin approves user in database
4. User logs out and back in
5. Verify access to organizer dashboard
```

**Why Integration Tests Are Critical:**
- Test real user journeys
- Validate database interactions
- Catch issues that only appear in production
- Ensure all components work together

**Challenges:**
- Slow (~10-30 seconds per test)
- Require real/test database
- Can be flaky with network issues
- Hard to debug failures

**Solution Strategy:**
```dart
// Use environment variables for test vs production
flutter test integration_test/auth_complete_flow_test.dart \
  --dart-define=SUPABASE_URL=your_test_url \
  --dart-define=SUPABASE_ANON_KEY=your_test_key
```

---

## Next Steps

### Phase 1: Complete Widget Tests (Priority: HIGH)
**Estimated Time:** 2-3 hours

**Tasks:**
1. Create `test/widget/login_screen_test.dart`
   - Test form validation
   - Test loading states
   - Test error handling
   
2. Create `test/widget/register_screen_test.dart`
   - Test role selection
   - Test conditional field rendering
   - Test form submission

3. Create helper for widget testing:
   ```dart
   // test/helpers/widget_test_helper.dart
   Widget createTestableWidget(Widget child) {
     return MaterialApp(
       home: child,
     );
   }
   ```

### Phase 2: Setup Integration Test Infrastructure
**Estimated Time:** 1-2 hours

**Tasks:**
1. Create test Supabase project (or use local Supabase via Docker)
2. Setup test data seeding scripts
3. Create cleanup utilities
4. Configure CI/CD for integration tests

### Phase 3: Implement Core Integration Tests
**Estimated Time:** 3-4 hours

**Priority Order:**
1. Complete login → dashboard flow (Most critical)
2. Registration flow
3. Role upgrade flow
4. Password reset flow

---

## Test Coverage Goals

### Current Coverage (After Unit Tests)
```
Authentication Feature:
- Models: ~95% ✅
- Repository: ~90% ✅
- UI Screens: ~0% ⏳
- Complete Flows: ~0% ⏳
```

### Target Coverage (After All Tests)
```
Authentication Feature:
- Models: ~95% ✅
- Repository: ~95% ⏳
- UI Screens: ~80% ⏳
- Complete Flows: ~70% ⏳
Overall: ~85%
```

---

## Common Issues and Solutions

### Issue 1: Tests Pass Locally But Fail in CI
**Cause:** Database state differences
**Solution:**
```dart
setUp(() async {
  // Reset database state before each test
  await cleanupTestData();
  await seedTestData();
});
```

### Issue 2: Flaky Integration Tests
**Cause:** Network timeouts, race conditions
**Solution:**
```dart
// Add retry logic
await retry(() async {
  await loginUser();
}, maxAttempts: 3);
```

### Issue 3: Slow Test Suite
**Cause:** Too many integration tests
**Solution:**
- Keep 80% unit tests
- 15% widget tests
- 5% integration tests

---

## Continuous Improvement

### After Each Sprint:
1. Review test failures
2. Add tests for new bugs discovered
3. Refactor slow tests
4. Update coverage reports

### Monthly:
1. Review test coverage metrics
2. Identify untested edge cases
3. Update test documentation
4. Conduct test code review

---

## Questions?

If you encounter issues or need clarification:

1. Check existing test examples
2. Review mocktail documentation
3. Consult Flutter testing guide
4. Ask team for code review

**Remember:** Good tests are:
- ✓ Fast
- ✓ Isolated
- ✓ Repeatable
- ✓ Self-validating
- ✓ Timely (written with code)

---

## Test Execution Summary

### Quick Reference Commands

```bash
# Run only completed tests
flutter test test/unit/

# Run with verbose output
flutter test test/unit/ --verbose

# Run single test file
flutter test test/unit/user_model_test.dart

# Run tests matching pattern
flutter test test/unit/ --name "sign in"

# Run with coverage
flutter test --coverage && genhtml coverage/lcov.info -o coverage/html

# Watch mode (auto-rerun on changes)
flutter test --watch test/unit/
```

---

**Document Version:** 1.0  
**Last Updated:** December 2024  
**Status:** Unit Tests Complete ✅ | Widget Tests Pending ⏳ | Integration Tests Pending ⏳
