# FusionFiesta Testing Checklist

## Authentication Feature Testing Progress

### Phase 1: Unit Tests ✅ COMPLETE
- [x] Create mock infrastructure
  - [x] MockAuthRepository
  - [x] MockUserRepository
  - [x] Fallback value registration
- [x] Create test fixtures
  - [x] Test users for all roles
  - [x] Test credentials (valid/invalid)
  - [x] Edge case data
- [x] User Model Tests (12 tests)
  - [x] Parse visitor profile
  - [x] Parse student complete profile
  - [x] Parse staff pending approval
  - [x] Handle missing fields
  - [x] Serialize to Map
  - [x] JSON conversion
  - [x] copyWith functionality
  - [x] Invalid role fallback
  - [x] Role identification
  - [x] Equality checks
- [x] Auth Repository Tests (26 tests)
  - [x] Sign in valid credentials
  - [x] Sign in invalid credentials
  - [x] Sign in empty fields
  - [x] Sign in network failure
  - [x] Sign in different roles
  - [x] Sign up visitor
  - [x] Sign up student
  - [x] Sign up staff
  - [x] Sign up duplicate email
  - [x] Sign up weak password
  - [x] Sign up invalid email
  - [x] Get current user
  - [x] Get current user (null)
  - [x] Get current user (session expired)
  - [x] Change password success
  - [x] Change password wrong current
  - [x] Change password weak new
  - [x] Sign in as guest
  - [x] Sign out success
  - [x] Sign out when not authenticated
  - [x] Role-based access checks (6 tests)
- [x] Documentation
  - [x] AUTH_TESTING_GUIDE.md
  - [x] IMPLEMENTATION_SUMMARY.md
  - [x] TEST_ARCHITECTURE.md
  - [x] README.md

**Status:** ✅ 38/38 tests passing | Coverage: ~46%

---

### Phase 2: Widget Tests ⏳ TODO (Next Priority)

#### Login Screen Tests
- [ ] Create `test/widget/login_screen_test.dart`
- [ ] Test: Email field validation
- [ ] Test: Password field validation
- [ ] Test: Login button disabled when fields empty
- [ ] Test: Login button enabled when fields valid
- [ ] Test: Loading indicator shown during sign in
- [ ] Test: Error message displayed on failure
- [ ] Test: Navigate to dashboard on success
- [ ] Test: Navigate to register screen
- [ ] Test: Navigate to forgot password
- [ ] Test: Password visibility toggle

#### Register Screen Tests
- [ ] Create `test/widget/register_screen_test.dart`
- [ ] Test: Role selection dropdown
- [ ] Test: Conditional field rendering (visitor vs student)
- [ ] Test: Email validation
- [ ] Test: Password strength indicator
- [ ] Test: Confirm password matching
- [ ] Test: Student fields appear for student role
- [ ] Test: Staff fields appear for staff role
- [ ] Test: Submit button validation
- [ ] Test: Navigate to login after success
- [ ] Test: Show institutional email requirement for staff

#### Forgot Password Screen Tests
- [ ] Create `test/widget/forgot_password_screen_test.dart`
- [ ] Test: Email field validation
- [ ] Test: Submit button states
- [ ] Test: Success message shown
- [ ] Test: Error handling
- [ ] Test: Navigate back to login

#### Role Upgrade Screen Tests
- [ ] Create `test/widget/role_upgrade_screen_test.dart`
- [ ] Test: Display current role
- [ ] Test: Show upgrade options
- [ ] Test: Render additional fields
- [ ] Test: Form validation
- [ ] Test: Submit upgrade request
- [ ] Test: Navigate after success

#### Verification Pending Screen Tests
- [ ] Create `test/widget/verification_pending_screen_test.dart`
- [ ] Test: Display pending message
- [ ] Test: Show contact information
- [ ] Test: Sign out button works
- [ ] Test: Cannot navigate to protected routes

**Estimated Time:** 2-3 hours  
**Target Coverage:** +30% = 76% total

---

### Phase 3: Integration Tests ⏳ TODO

#### Setup Infrastructure
- [ ] Create test Supabase project
- [ ] Setup test database schema
- [ ] Create data seeding scripts
- [ ] Create cleanup utilities
- [ ] Configure .env.test file
- [ ] Add integration_test folder

#### Complete Authentication Flow Test
- [ ] Create `integration_test/auth_complete_flow_test.dart`
- [ ] Test: Launch app
- [ ] Test: Navigate to register
- [ ] Test: Fill registration form
- [ ] Test: Submit registration
- [ ] Test: Verify user created in database
- [ ] Test: Log out
- [ ] Test: Log in with new credentials
- [ ] Test: Verify dashboard displays
- [ ] Test: Profile displays correct data

#### Role Upgrade Flow Test
- [ ] Create `integration_test/role_upgrade_flow_test.dart`
- [ ] Test: Login as visitor
- [ ] Test: Navigate to event catalog
- [ ] Test: Attempt to register for event
- [ ] Test: Redirected to upgrade screen
- [ ] Test: Fill upgrade form
- [ ] Test: Submit upgrade
- [ ] Test: Verify database updated
- [ ] Test: Successfully register for event

#### Staff Approval Flow Test
- [ ] Create `integration_test/staff_approval_flow_test.dart`
- [ ] Test: Register as staff
- [ ] Test: Verification pending screen shown
- [ ] Test: Cannot access organizer features
- [ ] Test: Admin approves in database
- [ ] Test: Log out and log back in
- [ ] Test: Access organizer dashboard
- [ ] Test: Create event successfully

#### Password Reset Flow Test
- [ ] Create `integration_test/password_reset_flow_test.dart`
- [ ] Test: Navigate to forgot password
- [ ] Test: Submit email
- [ ] Test: Check test email inbox
- [ ] Test: Click reset link
- [ ] Test: Enter new password
- [ ] Test: Verify password updated
- [ ] Test: Log in with new password

**Estimated Time:** 3-4 hours  
**Target Coverage:** +9% = 85% total

---

## Other Features Testing (After Auth is Complete)

### Event Management Tests
- [ ] Event model tests
- [ ] Event repository tests
- [ ] Event catalog widget tests
- [ ] Event detail widget tests
- [ ] Event registration flow integration test
- [ ] Event creation flow integration test

### Certificate Management Tests
- [ ] Certificate model tests
- [ ] Certificate repository tests
- [ ] Certificate download widget tests
- [ ] Certificate upload integration test
- [ ] Payment → certificate flow integration test

### Gallery Tests
- [ ] Gallery item model tests
- [ ] Gallery repository tests
- [ ] Gallery widget tests
- [ ] Media upload integration test
- [ ] Gallery filtering integration test

### Feedback Tests
- [ ] Feedback model tests
- [ ] Feedback repository tests
- [ ] Feedback form widget tests
- [ ] Feedback submission integration test

### Admin Dashboard Tests
- [ ] Dashboard statistics tests
- [ ] Event approval widget tests
- [ ] User management widget tests
- [ ] Reports generation tests

### Notification Tests
- [ ] Notification model tests
- [ ] Notification service tests
- [ ] Push notification integration tests

---

## Testing Milestones

### Milestone 1: Authentication Complete ✅
- [x] All unit tests passing
- [ ] All widget tests passing ⏳
- [ ] All integration tests passing ⏳
- [ ] Documentation updated ✅
- [ ] Coverage > 85% ⏳

### Milestone 2: Core Features (Events, Registration)
- [ ] Event browsing tested
- [ ] Event registration tested
- [ ] Role-based access tested
- [ ] Coverage > 80%

### Milestone 3: Secondary Features (Certificates, Gallery)
- [ ] Certificate management tested
- [ ] Gallery upload tested
- [ ] Feedback system tested
- [ ] Coverage > 75%

### Milestone 4: Admin Features
- [ ] User management tested
- [ ] Event approval tested
- [ ] Reports tested
- [ ] Coverage > 70%

### Milestone 5: Production Ready
- [ ] All features tested
- [ ] CI/CD pipeline configured
- [ ] Automated test runs on PR
- [ ] Overall coverage > 80%

---

## Daily Testing Routine

### Before Starting Development
```bash
# Run existing tests to ensure nothing broke
flutter test test/unit/
```

### After Adding New Feature
1. [ ] Write unit tests first (TDD)
2. [ ] Implement feature
3. [ ] Run unit tests
4. [ ] Write widget tests
5. [ ] Run widget tests
6. [ ] Update integration tests if needed
7. [ ] Run full test suite

### Before Committing Code
```bash
# Run all tests
flutter test

# Check coverage
flutter test --coverage

# Verify no new warnings
flutter analyze
```

---

## Coverage Targets by Feature

| Feature | Unit | Widget | Integration | Total Target |
|---------|------|--------|-------------|--------------|
| Auth | 90% ✅ | 0% ⏳ | 0% ⏳ | 85% |
| Events | - | - | - | 80% |
| Certificates | - | - | - | 75% |
| Gallery | - | - | - | 75% |
| Feedback | - | - | - | 70% |
| Admin | - | - | - | 70% |
| Profile | - | - | - | 75% |
| Overall | - | - | - | 80% |

---

## Test Execution Commands Reference

```bash
# Run all tests
flutter test

# Run specific directory
flutter test test/unit/
flutter test test/widget/
flutter test integration_test/

# Run specific file
flutter test test/unit/user_model_test.dart

# Run tests matching name
flutter test --name "sign in"

# Run with coverage
flutter test --coverage

# Watch mode
flutter test --watch test/unit/

# Integration tests on device
flutter test integration_test/auth_complete_flow_test.dart \
  --dart-define=SUPABASE_URL=$TEST_SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$TEST_SUPABASE_KEY

# Verbose output
flutter test --verbose

# Update golden files (for visual tests)
flutter test --update-goldens
```

---

## Notes

### When to Skip Tests
- Never skip for production code
- Only skip temporarily during development
- Always mark with TODO comment
- Track skipped tests in this checklist

### Test Maintenance
- Review tests monthly
- Update fixtures when models change
- Refactor slow tests
- Remove duplicate tests
- Update documentation

### CI/CD Integration
- Tests run on every PR
- Block merge if tests fail
- Generate coverage reports
- Notify team of coverage drops

---

**Last Updated:** December 2024  
**Current Phase:** Widget Tests (Phase 2)  
**Overall Progress:** 38/150+ tests (25%)  
**Next Action:** Create login_screen_test.dart
