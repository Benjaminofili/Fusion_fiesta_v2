import 'package:fusion_fiesta/data/repositories/admin_repository_impl.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/storage_service.dart';

// Repositories
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/event_repository.dart';
import '../../data/repositories/event_repository_impl.dart';
import '../../data/repositories/gallery_repository.dart';
import '../../data/repositories/gallery_repository_impl.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/repositories/notification_repository_impl.dart'; // Import Real Impl
import '../../data/repositories/admin_repository.dart';

final GetIt serviceLocator = GetIt.instance;

// Renamed to setupLocator for consistency
Future<void> setupLocator() async {
  // 1. Core Services
  final storageService = StorageService();
  await storageService.init();
  serviceLocator.registerSingleton<StorageService>(storageService);

  // Register SupabaseClient globally (Critical for other services to find it)
  serviceLocator
      .registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // 2. Repositories
  serviceLocator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(serviceLocator<SupabaseClient>()),
  );

  serviceLocator.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(),
  );

  serviceLocator.registerLazySingleton<EventRepository>(
    () => EventRepositoryImpl(),
  );

  serviceLocator.registerLazySingleton<GalleryRepository>(
    () => GalleryRepositoryImpl(serviceLocator<SupabaseClient>()),
  );

  // SWITCH TO REAL REPOSITORY FOR TESTING
  serviceLocator.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(serviceLocator<SupabaseClient>()),
  );

  serviceLocator.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(serviceLocator<SupabaseClient>()),
  );

  // 3. Application Services
  final authService = AuthService(
    serviceLocator<AuthRepository>(),
    serviceLocator<StorageService>(),
  );
  await authService.init();
  serviceLocator.registerSingleton<AuthService>(authService);

  serviceLocator
      .registerLazySingleton<NotificationService>(NotificationService.new);
  serviceLocator
      .registerLazySingleton<ConnectivityService>(ConnectivityService.new);
}
