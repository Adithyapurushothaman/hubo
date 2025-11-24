import 'package:flutter/material.dart';
import 'package:hubo/core/routing/app_router.dart';
import 'package:hubo/core/routing/routes.dart';

void main() {
  // Create router with initial location set to the login route
  final appRouter = AppRouter(AppRoute.login);
  runApp(MyApp(appRouter: appRouter));
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
