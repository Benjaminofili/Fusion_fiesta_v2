import 'dart:async'; // Add this
import '../../core/errors/app_failure.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';
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

  // --- NEW: Real-time Stream Implementation ---
  @override
  Stream<List<User>> getUsersStream() async* {
    // 1. Emit current data immediately
    yield mockUserDatabase.values.toList();

    // 2. Poll mock database every 2 seconds to simulate real-time updates
    // This ensures updates from AuthRepository (Sign Up) are reflected here.
    await for (final _ in Stream.periodic(const Duration(seconds: 2))) {
      yield mockUserDatabase.values.toList();
    }
  }

  @override
  Future<User> updateUser(User user) async {
    await _simulateNetworkDelay();

    if (user.id.isEmpty) {
      throw AppFailure('Cannot update user with empty ID.');
    }

    mockUserDatabase[user.email] = user;
    return user;
  }
}