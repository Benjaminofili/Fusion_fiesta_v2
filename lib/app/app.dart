import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/services/auth_service.dart';
import '../app/di/service_locator.dart';
import 'router/app_router.dart';

class FusionFiestaApp extends StatefulWidget {
  const FusionFiestaApp({super.key});

  @override
  State<FusionFiestaApp> createState() => _FusionFiestaAppState();
}

class _FusionFiestaAppState extends State<FusionFiestaApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(serviceLocator<AuthService>());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'FusionFiesta',
      theme: AppTheme.light,
      routerConfig: _appRouter.router,
    );
  }
}
