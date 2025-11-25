import 'package:flutter/material.dart';
import 'package:hubo/core/routing/app_router.dart';
import 'package:hubo/core/routing/routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hubo/feature/health/data/sync/sync_service.dart';
import 'package:hubo/core/db/app_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Determine initial route by checking whether a user with a token exists.
  String initialRoute = AppRoute.login;
  try {
    final user = await appDb.userDao.getUser();
    if (user != null && (user.token != null && user.token!.isNotEmpty)) {
      initialRoute = AppRoute.dashboard;
    }
  } catch (e) {
    try {
      // ignore: avoid_print
      debugPrint('Error checking user during startup: $e');
    } catch (_) {}
  }

  // Create router with computed initial location
  final appRouter = AppRouter(initialRoute);
  // Create a ProviderContainer to allow reading providers before runApp.
  final container = ProviderContainer();

  // Ensure the SyncService provider is created so it starts automatically.
  container.read(syncServiceProvider);

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
