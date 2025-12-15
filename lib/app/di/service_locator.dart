import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/storage_service.dart';

// Repositories (Interfaces)
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/event_repository.dart';
import '../../data/repositories/event_repository_impl.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/repositories/gallery_repository.dart';
import '../../data/repositories/admin_repository.dart';

// Implementations (Real & Mock)
import '../../data/repositories/auth_repository_impl.dart'; // NEW
import '../../data/repositories/user_repository_impl.dart'; // NEW
import '../../mock/mock_notification_repository.dart'; // Keeping MockEvent/Notification for now
import '../../mock/mock_event_repository.dart'; // Keeping MockEvent/Notification for now
import '../../mock/mock_gallery_repository.dart';
import '../../mock/mock_admin_repository.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> configureDependencies() async {

  // 1. Core Services (Synchronous/Async Init)
  final storageService = StorageService();
  await storageService.init();
  serviceLocator.registerSingleton<StorageService>(storageService);
  final supabaseClient = Supabase.instance.client;

  // 2. REPOSITORIES
  // ---------------------------------------------------------------------------

  // 2. Register Repository
  serviceLocator.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(supabaseClient),
  );

  // USER: Switched to Real Impl
  serviceLocator.registerLazySingleton<UserRepository>(
        () => UserRepositoryImpl(),
  );

  // EVENTS: Keeping Mock for now (Complex data, better mocked until backend exists)
  serviceLocator.registerLazySingleton<EventRepository>(
        () => EventRepositoryImpl(),
  );

  // NOTIFICATIONS: Keeping Mock
  serviceLocator.registerLazySingleton<NotificationRepository>(
        () => MockNotificationRepository(),
  );

  serviceLocator.registerLazySingleton<GalleryRepository>(
        () => MockGalleryRepository(),
  );
  // ---------------------------------------------------------------------------

  // 3. Application Services
  // 3. Application Services
  final authService = AuthService(
    serviceLocator<AuthRepository>(),
    serviceLocator<StorageService>(),
  );
  await authService.init(); // <--- Make sure this is called!

  serviceLocator.registerLazySingleton<AuthService>(() => authService);

  // ADMIN REPO
  serviceLocator.registerLazySingleton<AdminRepository>(
        () => MockAdminRepository(),
  );

  serviceLocator.registerLazySingleton<NotificationService>(NotificationService.new);
  serviceLocator.registerLazySingleton<ConnectivityService>(ConnectivityService.new);
}