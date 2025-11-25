import 'package:get_it/get_it.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/storage_service.dart';

// Repositories (Interfaces)
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/event_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/notification_repository.dart';

// Implementations (Real & Mock)
import '../../data/repositories/auth_repository_impl.dart'; // NEW
import '../../data/repositories/user_repository_impl.dart'; // NEW
import '../../mock/mock_repositories.dart'; // Keeping MockEvent/Notification for now

final GetIt serviceLocator = GetIt.instance;

Future<void> configureDependencies() async {

  // 1. Core Services (Synchronous/Async Init)
  final storageService = StorageService();
  await storageService.init();
  serviceLocator.registerSingleton<StorageService>(storageService);

  // 2. REPOSITORIES
  // ---------------------------------------------------------------------------
  // AUTH: Switched to Real Impl (Simulated Network)
  serviceLocator.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(serviceLocator<StorageService>()),
  );

  // USER: Switched to Real Impl
  serviceLocator.registerLazySingleton<UserRepository>(
        () => UserRepositoryImpl(),
  );

  // EVENTS: Keeping Mock for now (Complex data, better mocked until backend exists)
  serviceLocator.registerLazySingleton<EventRepository>(
        () => MockEventRepository(),
  );

  // NOTIFICATIONS: Keeping Mock
  serviceLocator.registerLazySingleton<NotificationRepository>(
        () => MockNotificationRepository(),
  );
  // ---------------------------------------------------------------------------

  // 3. Application Services
  serviceLocator.registerLazySingleton<AuthService>(
        () => AuthService(
      serviceLocator<AuthRepository>(),
      serviceLocator<StorageService>(),
    ),
  );

  serviceLocator.registerLazySingleton<NotificationService>(NotificationService.new);
  serviceLocator.registerLazySingleton<ConnectivityService>(ConnectivityService.new);
}