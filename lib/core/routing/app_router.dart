import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hubo/core/routing/routes.dart';
import 'package:hubo/feature/auth/presentation/screens/login_screen.dart';
import 'package:hubo/feature/auth/presentation/screens/signup_screen.dart';

class AppRouter {
  static final navKey = GlobalKey<NavigatorState>(debugLabel: 'navigatorKey');

  late final GoRouter router;

  /// [initialLocation] should be the route name defined in `AppRoute`, e.g. 'login'.
  AppRouter(String initialLocation) {
    router = _createRouter(initialLocation);
  }

  static GoRouter _createRouter(String initialLocation) {
    final initial = initialLocation.startsWith('/')
        ? initialLocation
        : '/$initialLocation';

    return GoRouter(
      initialLocation: initial,
      routes: [
        // Define your routes here
        GoRoute(
          path: '/${AppRoute.login}',
          name: AppRoute.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/${AppRoute.signup}',
          name: AppRoute.signup,
          builder: (context, state) => const SignupScreen(),
        ),
      ],

      debugLogDiagnostics: true,
      navigatorKey: navKey,
    );
  }

  void dispose() {
    router.dispose();
  }
}
