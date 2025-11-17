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

Future<void> configureDependencies() async {
  serviceLocator
    ..registerLazySingleton<AuthRepository>(() => MockAuthRepository())
    ..registerLazySingleton<UserRepository>(() => MockUserRepository())
    ..registerLazySingleton<EventRepository>(() => MockEventRepository())
    ..registerLazySingleton<AuthService>(
      () => AuthService(serviceLocator<AuthRepository>()),
    )
    ..registerLazySingleton<NotificationService>(NotificationService.new)
    ..registerLazySingleton<StorageService>(StorageService.new)
    ..registerLazySingleton<ConnectivityService>(ConnectivityService.new);
}

