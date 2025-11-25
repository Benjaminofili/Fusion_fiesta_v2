import '../../core/errors/app_failure.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {

  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<List<User>> fetchUsers() async {
    await _simulateNetworkDelay();
    // Return empty list for now, or mock users if needed for Admin
    return [];
  }

  @override
  Future<User> updateUser(User user) async {
    await _simulateNetworkDelay();

    // REAL WORLD: Validation before sending to server
    if (user.id.isEmpty) {
      throw AppFailure('Cannot update user with empty ID.');
    }

    // In production: PUT /api/users/{id}
    // Return the updated user object
    return user;
  }
}