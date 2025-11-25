import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hubo/core/routing/routes.dart';
import 'package:hubo/feature/auth/presentation/screens/login_screen.dart';
import 'package:hubo/feature/auth/presentation/screens/signup_screen.dart';
import 'package:hubo/feature/health/presentation/screens/daily_vitals_screen.dart';
import 'package:hubo/feature/health/presentation/screens/dashboard_screen.dart';

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
          builder: (context, state) {
            String? email;
            final extra = state.extra;
            if (extra is Map<String, dynamic> && extra['email'] is String) {
              email = extra['email'] as String;
            }
            return LoginScreen(initialEmail: email);
          },
        ),
        GoRoute(
          path: '/${AppRoute.signup}',
          name: AppRoute.signup,
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: '/${AppRoute.dailyVitals}',
          name: AppRoute.dailyVitals,
          builder: (context, state) => const DailyVitalsScreen(),
        ),
        GoRoute(
          path: '/${AppRoute.dashboard}',
          name: AppRoute.dashboard,
          builder: (context, state) => const DashboardScreen(),
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
