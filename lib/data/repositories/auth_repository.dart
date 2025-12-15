import '../models/user.dart';

abstract class AuthRepository {
  Future<User?> getCurrentUser();
  Future<User> signIn(String email, String password);
  Future<User> signUp(User user, String password);
  Future<void> signOut();
  Future<void> changePassword(String email, String currentPassword, String newPassword);
  Future<User> signInAsGuest();

}

