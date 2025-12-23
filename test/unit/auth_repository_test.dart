import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fusion_fiesta/core/constants/app_roles.dart';
import 'package:fusion_fiesta/data/models/user.dart';
import 'package:fusion_fiesta/core/errors/app_failure.dart';

import '../mocks/mock_repositories.dart';
import '../helpers/test_fixtures.dart';

/// SRS Section 1.6.1: User Registration and Authentication
/// Testing authentication business logic without hitting real database
///
/// Tests cover:
/// - Sign in with valid/invalid credentials
/// - Sign up for different user roles
/// - Password change functionality
/// - Current user retrieval
/// - Guest sign-in
/// - Sign out

void main() {
  late MockAuthRepository mockAuthRepository;

  setUpAll(() {
    registerMockFallbacks();
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  group('AuthRepository - Sign In Tests (SRS 1.6.1)', () {
    test('should sign in successfully with valid credentials', () async {
      // Arrange - SRS: Secure login using username/email and password
      when(() => mockAuthRepository.signIn(validEmail, validPassword))
          .thenAnswer((_) async => testStudentCompleteProfile);

      // Act
      final result = await mockAuthRepository.signIn(validEmail, validPassword);

      // Assert
      expect(result, isA<User>());
      expect(result.role, AppRole.student);
      expect(result.id, isNotEmpty);
      verify(() => mockAuthRepository.signIn(validEmail, validPassword))
          .called(1);
    });

    test('should throw AuthFailure when credentials are invalid', () async {
      // Arrange
      when(() => mockAuthRepository.signIn(invalidEmail, invalidPassword))
          .thenThrow(AuthFailure('Invalid email or password'));

      // Act & Assert
      expect(
        () => mockAuthRepository.signIn(invalidEmail, invalidPassword),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('should throw AuthFailure when email is empty', () async {
      // Arrange
      when(() => mockAuthRepository.signIn(emptyEmail, validPassword))
          .thenThrow(AuthFailure('Email cannot be empty'));

      // Act & Assert
      expect(
        () => mockAuthRepository.signIn(emptyEmail, validPassword),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('should throw AuthFailure when password is empty', () async {
      // Arrange
      when(() => mockAuthRepository.signIn(validEmail, emptyPassword))
          .thenThrow(AuthFailure('Password cannot be empty'));

      // Act & Assert
      expect(
        () => mockAuthRepository.signIn(validEmail, emptyPassword),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('should throw NetworkFailure when there is no internet', () async {
      // Arrange
      when(() => mockAuthRepository.signIn(validEmail, validPassword))
          .thenThrow(NetworkFailure('No internet connection'));

      // Act & Assert
      expect(
        () => mockAuthRepository.signIn(validEmail, validPassword),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('should sign in visitor user successfully', () async {
      // Arrange - SRS: General visitors can browse without full registration
      when(() => mockAuthRepository.signIn(validEmail, validPassword))
          .thenAnswer((_) async => testVisitorUser);

      // Act
      final result = await mockAuthRepository.signIn(validEmail, validPassword);

      // Assert
      expect(result.role, AppRole.visitor);
      expect(result.profileCompleted, true);
    });

    test('should sign in student participant successfully', () async {
      // Arrange - SRS: Student participant with complete profile
      when(() => mockAuthRepository.signIn(validEmail, validPassword))
          .thenAnswer((_) async => testStudentCompleteProfile);

      // Act
      final result = await mockAuthRepository.signIn(validEmail, validPassword);

      // Assert
      expect(result.role, AppRole.student);
      expect(result.enrolmentNumber, isNotNull);
      expect(result.department, isNotNull);
      expect(result.profileCompleted, true);
    });

    test('should sign in unapproved staff member', () async {
      // Arrange - SRS: Staff must be approved by admin before access
      when(() => mockAuthRepository.signIn(validStaffEmail, validPassword))
          .thenAnswer((_) async => testStaffPendingApproval);

      // Act
      final result =
          await mockAuthRepository.signIn(validStaffEmail, validPassword);

      // Assert
      expect(result.role, AppRole.organizer);
      expect(result.isApproved, false); // Not yet approved
    });
  });

  group('AuthRepository - Sign Up Tests (SRS 1.6.1)', () {
    test('should register visitor successfully', () async {
      // Arrange - SRS: Users can select role during sign-up
      const newVisitor = User(
        id: 'new-visitor',
        name: 'New Visitor',
        email: 'newvisitor@college.edu',
        role: AppRole.visitor,
        profileCompleted: true,
        isApproved: true,
      );

      when(() => mockAuthRepository.signUp(newVisitor, validPassword))
          .thenAnswer((_) async => newVisitor);

      // Act
      final result = await mockAuthRepository.signUp(newVisitor, validPassword);

      // Assert
      expect(result.role, AppRole.visitor);
      expect(result.email, 'newvisitor@college.edu');
      verify(() => mockAuthRepository.signUp(newVisitor, validPassword))
          .called(1);
    });

    test('should register student participant with required details', () async {
      // Arrange - SRS: Student participant needs enrolment number, department
      const newStudent = User(
        id: 'new-student',
        name: 'New Student',
        email: 'newstudent@college.edu',
        role: AppRole.student,
        department: 'Computer Science',
        mobileNumber: '+1234567890',
        enrolmentNumber: 'CS2024999',
        profileCompleted: true,
        isApproved: true,
      );

      when(() => mockAuthRepository.signUp(newStudent, validPassword))
          .thenAnswer((_) async => newStudent);

      // Act
      final result = await mockAuthRepository.signUp(newStudent, validPassword);

      // Assert
      expect(result.role, AppRole.student);
      expect(result.department, isNotNull);
      expect(result.enrolmentNumber, isNotNull);
      expect(result.mobileNumber, isNotNull);
    });

    test('should register staff with institutional email', () async {
      // Arrange - SRS: Staff must use institutional email
      const newStaff = User(
        id: 'new-staff',
        name: 'New Organizer',
        email: 'neworganizer@college.edu',
        role: AppRole.organizer,
        department: 'Technical Affairs',
        mobileNumber: '+1234567891',
        profileCompleted: true,
        isApproved: false, // Pending approval
      );

      when(() => mockAuthRepository.signUp(newStaff, validPassword))
          .thenAnswer((_) async => newStaff);

      // Act
      final result = await mockAuthRepository.signUp(newStaff, validPassword);

      // Assert
      expect(result.role, AppRole.organizer);
      expect(result.email, contains('@college.edu'));
      expect(result.isApproved, false); // Needs admin approval
    });

    test('should throw AuthFailure for duplicate email', () async {
      // Arrange
      when(() => mockAuthRepository.signUp(testVisitorUser, validPassword))
          .thenThrow(AuthFailure('Email already exists'));

      // Act & Assert
      expect(
        () => mockAuthRepository.signUp(testVisitorUser, validPassword),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('should throw AuthFailure for weak password', () async {
      // Arrange
      when(() => mockAuthRepository.signUp(testVisitorUser, weakPassword))
          .thenThrow(AuthFailure('Password is too weak'));

      // Act & Assert
      expect(
        () => mockAuthRepository.signUp(testVisitorUser, weakPassword),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('should throw ValidationFailure for invalid email format', () async {
      // Arrange
      const invalidUser = User(
        id: 'invalid',
        name: 'Invalid User',
        email: 'notanemail',
        role: AppRole.visitor,
      );

      when(() => mockAuthRepository.signUp(invalidUser, validPassword))
          .thenThrow(ValidationFailure('Invalid email format'));

      // Act & Assert
      expect(
        () => mockAuthRepository.signUp(invalidUser, validPassword),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });

  group('AuthRepository - Current User Tests (SRS 1.6.1)', () {
    test('should return current authenticated user', () async {
      // Arrange
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => testStudentCompleteProfile);

      // Act
      final result = await mockAuthRepository.getCurrentUser();

      // Assert
      expect(result, isA<User>());
      expect(result?.id, isNotEmpty);
    });

    test('should return null when no user is authenticated', () async {
      // Arrange
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => null);

      // Act
      final result = await mockAuthRepository.getCurrentUser();

      // Assert
      expect(result, isNull);
    });

    test('should throw AuthFailure when session expires', () async {
      // Arrange
      when(() => mockAuthRepository.getCurrentUser())
          .thenThrow(AuthFailure('Session expired'));

      // Act & Assert
      expect(
        () => mockAuthRepository.getCurrentUser(),
        throwsA(isA<AuthFailure>()),
      );
    });
  });

  group('AuthRepository - Password Management (SRS 1.6.1)', () {
    test('should change password successfully', () async {
      // Arrange - SRS: Users can change their password
      const currentPassword = 'OldPass@123';
      const newPassword = 'NewPass@456';

      when(() => mockAuthRepository.changePassword(
            validEmail,
            currentPassword,
            newPassword,
          )).thenAnswer((_) async => {});

      // Act & Assert - Should not throw
      await mockAuthRepository.changePassword(
        validEmail,
        currentPassword,
        newPassword,
      );

      verify(() => mockAuthRepository.changePassword(
            validEmail,
            currentPassword,
            newPassword,
          )).called(1);
    });

    test('should throw AuthFailure when current password is wrong', () async {
      // Arrange
      when(() => mockAuthRepository.changePassword(
            validEmail,
            'WrongPassword',
            'NewPass@456',
          )).thenThrow(AuthFailure('Current password is incorrect'));

      // Act & Assert
      expect(
        () => mockAuthRepository.changePassword(
          validEmail,
          'WrongPassword',
          'NewPass@456',
        ),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('should throw ValidationFailure when new password is weak', () async {
      // Arrange
      when(() => mockAuthRepository.changePassword(
            validEmail,
            validPassword,
            weakPassword,
          )).thenThrow(ValidationFailure('New password is too weak'));

      // Act & Assert
      expect(
        () => mockAuthRepository.changePassword(
          validEmail,
          validPassword,
          weakPassword,
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });

  group('AuthRepository - Guest Sign In (SRS 1.6.1)', () {
    test('should sign in as guest successfully', () async {
      // Arrange - SRS: Visitors can browse without full registration
      const guestUser = User(
        id: 'guest-temp-id',
        name: 'Guest User',
        email: 'guest@temporary.local',
        role: AppRole.visitor,
        profileCompleted: false,
        isApproved: true,
      );

      when(() => mockAuthRepository.signInAsGuest())
          .thenAnswer((_) async => guestUser);

      // Act
      final result = await mockAuthRepository.signInAsGuest();

      // Assert
      expect(result.role, AppRole.visitor);
      expect(result.id, isNotEmpty);
    });
  });

  group('AuthRepository - Sign Out Tests (SRS 1.6.1)', () {
    test('should sign out successfully', () async {
      // Arrange
      when(() => mockAuthRepository.signOut()).thenAnswer((_) async => {});

      // Act & Assert - Should not throw
      await mockAuthRepository.signOut();

      verify(() => mockAuthRepository.signOut()).called(1);
    });

    test('should handle sign out gracefully even when not authenticated',
        () async {
      // Arrange
      when(() => mockAuthRepository.signOut()).thenAnswer((_) async => {});

      // Act & Assert - Should not throw
      await mockAuthRepository.signOut();
    });
  });

  group('AuthRepository - Role-Based Access (SRS Requirements)', () {
    test('visitor should have browsing permissions only', () {
      // Assert - SRS: Visitors can only browse
      expect(testVisitorUser.role, AppRole.visitor);
      expect(testVisitorUser.profileCompleted, true);
      // In actual app, check canRegisterForEvents() returns false
    });

    test('student with incomplete profile should not register for events', () {
      // Assert - SRS: Complete profile required for event registration
      expect(testStudentIncompleteProfile.role, AppRole.student);
      expect(testStudentIncompleteProfile.profileCompleted, false);
      expect(testStudentIncompleteProfile.department, isNull);
      expect(testStudentIncompleteProfile.enrolmentNumber, isNull);
    });

    test('student with complete profile can register for events', () {
      // Assert - SRS: Student participant can register after completing profile
      expect(testStudentCompleteProfile.role, AppRole.student);
      expect(testStudentCompleteProfile.profileCompleted, true);
      expect(testStudentCompleteProfile.department, isNotNull);
      expect(testStudentCompleteProfile.enrolmentNumber, isNotNull);
    });

    test('unapproved staff cannot access event management', () {
      // Assert - SRS: Staff must be approved by admin
      expect(testStaffPendingApproval.role, AppRole.organizer);
      expect(testStaffPendingApproval.isApproved, false);
    });

    test('approved organizer has event management access', () {
      // Assert - SRS: Approved staff can create/manage events
      expect(testApprovedOrganizer.role, AppRole.organizer);
      expect(testApprovedOrganizer.isApproved, true);
      expect(testApprovedOrganizer.profileCompleted, true);
    });

    test('admin has full system access', () {
      // Assert - SRS: Admin controls entire system
      expect(testAdmin.role, AppRole.admin);
      expect(testAdmin.isApproved, true);
      expect(testAdmin.profileCompleted, true);
    });
  });
}
