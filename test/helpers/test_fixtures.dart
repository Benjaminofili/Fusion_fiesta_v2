import 'package:fusion_fiesta/core/constants/app_roles.dart';
import 'package:fusion_fiesta/data/models/user.dart';

/// Test fixtures - Reusable test data that represents various user states
/// These match the SRS requirements for different user types

/// SRS Requirement: Student Visitor (can only browse)
const User testVisitorUser = User(
  id: 'visitor-001',
  name: 'John Visitor',
  email: 'visitor@college.edu',
  role: AppRole.visitor,
  profileCompleted: true,
  isApproved: true,
);

/// SRS Requirement: Student Participant (incomplete profile)
/// Should have all required fields for event registration
const User testStudentIncompleteProfile = User(
  id: 'student-002',
  name: 'Jane Student',
  email: 'jane@college.edu',
  role: AppRole.student,
  profileCompleted: false,
  isApproved: true,
  // Missing: department, mobileNumber, enrolmentNumber
);

/// SRS Requirement: Student Participant (complete profile)
/// Can register for events and download certificates
const User testStudentCompleteProfile = User(
  id: 'student-003',
  name: 'Alice Participant',
  email: 'alice@college.edu',
  role: AppRole.student,
  department: 'Computer Science',
  mobileNumber: '+1234567890',
  enrolmentNumber: 'CS2024001',
  profileCompleted: true,
  isApproved: true,
);

/// SRS Requirement: Staff member pending approval
/// Staff must be approved before accessing event management
const User testStaffPendingApproval = User(
  id: 'staff-004',
  name: 'Bob Organizer',
  email: 'bob@college.edu',
  role: AppRole.organizer,
  department: 'Cultural Affairs',
  mobileNumber: '+1234567891',
  profileCompleted: true,
  isApproved: false, // Waiting for admin approval
);

/// SRS Requirement: Approved Organizer
/// Can create and manage events
const User testApprovedOrganizer = User(
  id: 'organizer-005',
  name: 'Carol Organizer',
  email: 'carol@college.edu',
  role: AppRole.organizer,
  department: 'Technical Affairs',
  mobileNumber: '+1234567892',
  profileCompleted: true,
  isApproved: true,
);

/// SRS Requirement: Admin user
/// Has full system access
const User testAdmin = User(
  id: 'admin-006',
  name: 'Admin User',
  email: 'admin@college.edu',
  role: AppRole.admin,
  department: 'Administration',
  mobileNumber: '+1234567893',
  profileCompleted: true,
  isApproved: true,
);

/// User data for role upgrade scenario
/// Visitor wanting to become Participant
const User testUserForRoleUpgrade = User(
  id: 'visitor-007',
  name: 'David Visitor',
  email: 'david@college.edu',
  role: AppRole.visitor,
  profileCompleted: true,
  isApproved: true,
);

/// Updated user after role upgrade
const User testUpgradedUser = User(
  id: 'visitor-007',
  name: 'David Visitor',
  email: 'david@college.edu',
  role: AppRole.student,
  department: 'Mechanical Engineering',
  mobileNumber: '+1234567894',
  enrolmentNumber: 'ME2024002',
  profileCompleted: true,
  isApproved: true,
);

/// Valid test credentials
const String validEmail = 'test@college.edu';
const String validPassword = 'Test@1234';

/// Invalid credentials for negative testing
const String invalidEmail = 'notfound@college.edu';
const String invalidPassword = 'wrongpassword';
const String weakPassword = '123';
const String emptyEmail = '';
const String emptyPassword = '';

/// SRS Requirement: Institutional email for staff
const String validStaffEmail = 'staff@college.edu';
const String invalidStaffEmail = 'staff@gmail.com'; // Not institutional
