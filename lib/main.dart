import 'package:flutter/material.dart';
import 'package:hubo/core/routing/app_router.dart';
import 'package:hubo/core/routing/routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hubo/feature/health/data/providers.dart';
import 'package:hubo/feature/health/data/sync/sync_service.dart';

void main() {
  // Create router with initial location set to the login route
  final appRouter = AppRouter(AppRoute.login);
  // Create a ProviderContainer to allow reading providers before runApp.
  final container = ProviderContainer();

  // Start sync service using the repository from providers (can be overridden in tests).
  final repo = container.read(vitalsRepositoryProvider);
  final syncService = SyncService(repo);
  syncService.start();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MyApp(appRouter: appRouter),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.appRouter});

  final AppRouter appRouter;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Hubo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: appRouter.router,
    );
  }
}
