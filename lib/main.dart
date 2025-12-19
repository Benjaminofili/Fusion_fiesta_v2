import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fusion_fiesta/core/services/auth_service.dart';
import 'package:fusion_fiesta/data/repositories/notification_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/app.dart';
import 'app/di/service_locator.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Hive.initFlutter();

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  await setupLocator();

  // Initialize Notifications
  final notifService = serviceLocator<NotificationService>();
  await notifService.init(); // This is now fast and non-blocking

  // Fire permission request without awaiting it, so runApp proceeds immediately
  notifService.requestPermissions();

  // --- START MONITORING ---
  final authService = serviceLocator<AuthService>();
  final notifRepo = serviceLocator<NotificationRepository>();

  // 1. Check if user is ALREADY logged in (Synchronous check)
  if (authService.currentUser != null) {
    notifService.monitorNotifications(
        notifRepo,
        authService.currentUser!.id
    );
  }

  // 2. Listen for FUTURE login/logout events
  authService.userStream.listen((user) {
    if (user != null) {
      notifService.monitorNotifications(notifRepo, user.id);
    } else {
      notifService.stopMonitoring();
    }
  });

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return const FusionFiestaApp();
      },
    ),
  );
}