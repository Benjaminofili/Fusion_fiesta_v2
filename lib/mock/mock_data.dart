import '../core/constants/app_roles.dart';
import '../data/models/user.dart';

// --- SHARED MOCK DATABASE ---
// Accessed by AuthRepositoryImpl and UserRepositoryImpl

final Map<String, User> mockUserDatabase = {
  'student@fusionfiesta.dev': const User(
    id: 'student-1',
    name: 'Student Demo',
    email: 'student@fusionfiesta.dev',
    role: AppRole.student,
    profileCompleted: true,
    isApproved: true,
  ),
  'organizer@fusionfiesta.dev': const User(
    id: 'organizer-1',
    name: 'Tech Club Lead',
    email: 'organizer@fusionfiesta.dev',
    role: AppRole.organizer,
    profileCompleted: true,
    isApproved: true,
    department: 'Computer Science',
  ),
};

final Map<String, String> mockPasswords = {
  'student@fusionfiesta.dev': 'password',
  'organizer@fusionfiesta.dev': 'password',
};