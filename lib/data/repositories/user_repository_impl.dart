import '../../core/errors/app_failure.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';

// Import the mock database we just created
import '../../mock/mock_data.dart';

class UserRepositoryImpl implements UserRepository {

  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<List<User>> fetchUsers() async {
    await _simulateNetworkDelay();
    return mockUserDatabase.values.toList();
  }

  @override
  Future<User> updateUser(User user) async {
    await _simulateNetworkDelay();

    if (user.id.isEmpty) {
      throw AppFailure('Cannot update user with empty ID.');
    }

    // --- THE FIX IS HERE ---
    // Update the "Server" (Mock Database) with the new Role/Details
    mockUserDatabase[user.email] = user;

    return user;
  }
}