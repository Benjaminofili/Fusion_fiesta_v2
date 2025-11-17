import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/di/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const FusionFiestaApp());
}

