import 'dart:io';

import '../models/user.dart';

abstract class UserRepository {
  Future<User> getUser(String userId);
  Stream<User?> getUserStream(String userId);
  Future<User> updateUser(User user,
      {File? newProfileImage, File? newCollegeIdImage});
  Future<List<User>> fetchUsers();
  Stream<List<User>> getUsersStream();
}
