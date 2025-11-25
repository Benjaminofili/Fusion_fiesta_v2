import 'package:get_it/get_it.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/storage_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/event_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/notification_repository.dart'; // Required import
import '../../mock/mock_repositories.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> configureDependencies() async {

  // 1. Initialize and register StorageService FIRST
  // We do this separately because it requires 'await' to be ready
  final storageService = StorageService();
  await storageService.init();
  serviceLocator.registerSingleton<StorageService>(storageService);

  // 2. Register all other services and repositories
  serviceLocator
    ..registerLazySingleton<AuthRepository>(() => MockAuthRepository())
    ..registerLazySingleton<UserRepository>(() => MockUserRepository())
    ..registerLazySingleton<EventRepository>(() => MockEventRepository())

  // --- NEW: Register the Notification Repository ---
    ..registerLazySingleton<NotificationRepository>(() => MockNotificationRepository())

  // Services
    ..registerLazySingleton<AuthService>(
          () => AuthService(
        serviceLocator<AuthRepository>(),
        serviceLocator<StorageService>(),
      ),
    )
    ..registerLazySingleton<NotificationService>(NotificationService.new)
    ..registerLazySingleton<ConnectivityService>(ConnectivityService.new);
}