import 'dart:io';

import '../models/user.dart';

abstract class UserRepository {
  Stream<User?> getUserStream(String userId);
  Future<User> updateUser(User user, {File? newProfileImage});
  Future<List<User>> fetchUsers();
  Stream<List<User>> getUsersStream();
}

