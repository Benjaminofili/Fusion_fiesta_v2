import 'package:get_it/get_it.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/storage_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/event_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../mock/mock_repositories.dart';

final GetIt serviceLocator = GetIt.instance;

// 1. Make your function async
Future<void> configureDependencies() async {

  // 2. Initialize and register StorageService FIRST
  final storageService = StorageService();
  await storageService.init();
  serviceLocator.registerSingleton<StorageService>(storageService);

  // 3. Your existing cascade, with two modifications
  serviceLocator
    ..registerLazySingleton<AuthRepository>(() => MockAuthRepository())
    ..registerLazySingleton<UserRepository>(() => MockUserRepository())
    ..registerLazySingleton<EventRepository>(() => MockEventRepository())

  // 4. MODIFIED: Inject both Repository and StorageService
    ..registerLazySingleton<AuthService>(
          () => AuthService(
        serviceLocator<AuthRepository>(),
        serviceLocator<StorageService>(), // Added new dependency
      ),
    )

    ..registerLazySingleton<NotificationService>(NotificationService.new)
  // 5. REMOVED: This is now registered above as an initialized singleton
  // ..registerLazySingleton<StorageService>(StorageService.new)
    ..registerLazySingleton<ConnectivityService>(ConnectivityService.new);
}