import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // 1. Import Hive
import 'app/app.dart';
import 'app/di/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Hive
  await Hive.initFlutter();

  // 3. Call your async config function
  await configureDependencies();

  runApp(const FusionFiestaApp());
}