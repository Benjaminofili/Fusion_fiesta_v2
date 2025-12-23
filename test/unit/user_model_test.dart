import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_fiesta/core/constants/app_roles.dart';
import 'package:fusion_fiesta/data/models/user.dart';

/// SRS Section 1.6.1: User Registration and Authentication
/// Testing User model to ensure proper data parsing and serialization
/// This is critical for maintaining data integrity across the app

void main() {
  group('User Model Tests - SRS 1.6.1 Requirements', () {
    test('should parse complete visitor profile from Map', () {
      // Arrange - SRS: Visitor can browse but not register
      final Map<String, dynamic> json = {
        'id': 'visitor-001',
        'name': 'John Visitor',
        'email': 'visitor@college.edu',
        'role': 'visitor',
        'profileCompleted': true,
        'isApproved': true,
      };

      // Act
      final user = User.fromMap(json);

      // Assert
      expect(user.id, 'visitor-001');
      expect(user.name, 'John Visitor');
      expect(user.email, 'visitor@college.edu');
      expect(user.role, AppRole.visitor);
      expect(user.profileCompleted, true);
      expect(user.isApproved, true);
    });

    test('should parse student participant with complete profile', () {
      // Arrange - SRS: Student participant needs additional details
      final Map<String, dynamic> json = {
        'id': 'student-001',
        'name': 'Alice Student',
        'email': 'alice@college.edu',
        'role': 'student',
        'department': 'Computer Science',
        'mobileNumber': '+1234567890',
        'enrolmentNumber': 'CS2024001',
        'profileCompleted': true,
        'isApproved': true,
      };

      // Act
      final user = User.fromMap(json);

      // Assert - Verify all required fields for student participant
      expect(user.role, AppRole.student);
      expect(user.department, 'Computer Science');
      expect(user.mobileNumber, '+1234567890');
      expect(user.enrolmentNumber, 'CS2024001');
      expect(user.profileCompleted, true);
    });

    test('should parse staff member pending approval', () {
      // Arrange - SRS: Staff must be approved by admin
      final Map<String, dynamic> json = {
        'id': 'staff-001',
        'name': 'Bob Organizer',
        'email': 'bob@college.edu',
        'role': 'organizer',
        'department': 'Cultural Affairs',
        'mobileNumber': '+1234567891',
        'profileCompleted': true,
        'isApproved': false, // Pending admin approval
      };

      // Act
      final user = User.fromMap(json);

      // Assert
      expect(user.role, AppRole.organizer);
      expect(user.isApproved, false);
      expect(user.profileCompleted, true);
    });

    test('should handle missing optional fields gracefully', () {
      // Arrange - Minimal user data
      final Map<String, dynamic> json = {
        'id': 'user-001',
        'name': 'Test User',
        'email': 'test@college.edu',
        'role': 'visitor',
      };

      // Act
      final user = User.fromMap(json);

      // Assert - Optional fields should be null
      expect(user.department, null);
      expect(user.mobileNumber, null);
      expect(user.enrolmentNumber, null);
      expect(user.profilePictureUrl, null);
      expect(user.collegeIdUrl, null);
      expect(user.profileCompleted, false); // Default value
      expect(user.isApproved, false); // Default value
    });

    test('should serialize user to Map correctly', () {
      // Arrange
      const user = User(
        id: 'student-002',
        name: 'Jane Student',
        email: 'jane@college.edu',
        role: AppRole.student,
        department: 'Electrical Engineering',
        mobileNumber: '+9876543210',
        enrolmentNumber: 'EE2024002',
        profileCompleted: true,
        isApproved: true,
      );

      // Act
      final map = user.toMap();

      // Assert
      expect(map['id'], 'student-002');
      expect(map['name'], 'Jane Student');
      expect(map['email'], 'jane@college.edu');
      expect(map['role'], 'student');
      expect(map['department'], 'Electrical Engineering');
      expect(map['mobileNumber'], '+9876543210');
      expect(map['enrolmentNumber'], 'EE2024002');
      expect(map['profileCompleted'], true);
      expect(map['isApproved'], true);
    });

    test('should convert to JSON string and back', () {
      // Arrange
      const originalUser = User(
        id: 'user-003',
        name: 'Test Admin',
        email: 'admin@college.edu',
        role: AppRole.admin,
        department: 'Administration',
        profileCompleted: true,
        isApproved: true,
      );

      // Act - Serialize and deserialize
      final jsonString = originalUser.toJson();
      final parsedUser = User.fromJson(jsonString);

      // Assert - Data should remain intact
      expect(parsedUser.id, originalUser.id);
      expect(parsedUser.name, originalUser.name);
      expect(parsedUser.email, originalUser.email);
      expect(parsedUser.role, originalUser.role);
      expect(parsedUser.department, originalUser.department);
      expect(parsedUser.profileCompleted, originalUser.profileCompleted);
      expect(parsedUser.isApproved, originalUser.isApproved);
    });

    test('should create copy with updated fields', () {
      // Arrange - SRS: Users should be able to update their profile
      const originalUser = User(
        id: 'student-004',
        name: 'Original Name',
        email: 'original@college.edu',
        role: AppRole.visitor,
        profileCompleted: false,
        isApproved: false,
      );

      // Act - Update role and profile completion (role upgrade scenario)
      final updatedUser = originalUser.copyWith(
        role: AppRole.student,
        department: 'Computer Science',
        enrolmentNumber: 'CS2024999',
        profileCompleted: true,
      );

      // Assert
      expect(updatedUser.id, originalUser.id); // Unchanged
      expect(updatedUser.email, originalUser.email); // Unchanged
      expect(updatedUser.role, AppRole.student); // Changed
      expect(updatedUser.department, 'Computer Science'); // Changed
      expect(updatedUser.enrolmentNumber, 'CS2024999'); // Changed
      expect(updatedUser.profileCompleted, true); // Changed
    });

    test('should handle invalid role gracefully with fallback', () {
      // Arrange - Invalid role in data
      final Map<String, dynamic> json = {
        'id': 'user-005',
        'name': 'Test User',
        'email': 'test@college.edu',
        'role': 'invalidRole', // Invalid role
      };

      // Act
      final user = User.fromMap(json);

      // Assert - Should fallback to visitor role
      expect(user.role, AppRole.visitor);
    });

    test('should correctly identify different user roles', () {
      // Test all role types per SRS requirements
      final roles = [
        {'name': 'visitor', 'expected': AppRole.visitor},
        {'name': 'student', 'expected': AppRole.student},
        {'name': 'organizer', 'expected': AppRole.organizer},
        {'name': 'admin', 'expected': AppRole.admin},
      ];

      for (final roleData in roles) {
        final json = {
          'id': 'test-user',
          'name': 'Test User',
          'email': 'test@college.edu',
          'role': roleData['name'],
        };

        final user = User.fromMap(json);
        expect(user.role, roleData['expected']);
      }
    });

    test('should maintain equality based on id, email, role, and status', () {
      // Arrange - Two users with same core data
      const user1 = User(
        id: 'user-001',
        name: 'Test User',
        email: 'test@college.edu',
        role: AppRole.student,
        profileCompleted: true,
        isApproved: true,
      );

      const user2 = User(
        id: 'user-001',
        name: 'Different Name', // Name doesn't affect equality
        email: 'test@college.edu',
        role: AppRole.student,
        profileCompleted: true,
        isApproved: true,
      );

      // Assert - Should be equal
      expect(user1, equals(user2));
    });

    test('should detect inequality when key fields differ', () {
      // Arrange
      const user1 = User(
        id: 'user-001',
        name: 'Test User',
        email: 'test@college.edu',
        role: AppRole.student,
        profileCompleted: true,
        isApproved: true,
      );

      const user2 = User(
        id: 'user-002', // Different ID
        name: 'Test User',
        email: 'test@college.edu',
        role: AppRole.student,
        profileCompleted: true,
        isApproved: true,
      );

      // Assert - Should NOT be equal
      expect(user1, isNot(equals(user2)));
    });
  });
}
