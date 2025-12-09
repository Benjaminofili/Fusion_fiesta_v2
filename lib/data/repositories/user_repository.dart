import '../models/user.dart';

abstract class UserRepository {
  Future<User> updateUser(User user);
  Future<List<User>> fetchUsers();
  Stream<List<User>> getUsersStream();
}

