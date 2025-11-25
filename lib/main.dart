import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // 1. Import
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';

import 'app/app.dart';
import 'app/di/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await configureDependencies();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Optional: Lock orientation to portrait if desired
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // 2. Wrap App in ScreenUtilInit
  runApp(
    ScreenUtilInit(
      designSize: const Size(375, 812), // Standard design size (iPhone X)
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return const FusionFiestaApp();
      },
    ),
  );
}