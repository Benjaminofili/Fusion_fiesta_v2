import 'dart:async';
import 'package:uuid/uuid.dart';
import '../core/constants/app_roles.dart';
import '../data/models/user.dart';
import '../data/repositories/user_repository.dart';

class MockUserRepository implements UserRepository {
  final List<User> _users = [
    User(
      id: const Uuid().v4(),
      name: 'Student Demo',
      email: 'student@fusionfiesta.dev',
      role: AppRole.student,
      profileCompleted: true,
    ),
  ];

  @override
  Future<List<User>> fetchUsers() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _users;
  }

  @override
  Future<User> updateUser(User user) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return user;
  }
}