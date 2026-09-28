import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/welcome/presentation/welcome_screen.dart';
import 'app_routes.dart';

/// Builds the application [GoRouter].
///
/// `/welcome` resolves to the real [WelcomeScreen]. `/` renders
/// [WelcomeScreen] too, so the app boots into the implemented screen while
/// Splash does not exist yet. `/login` and `/signup` resolve to the implemented
/// auth screens ([LoginScreen], [SignupScreen]).
///
/// Extension point: a future auth redirect can be added via [redirect]
/// without changing route declarations. Bottom navigation
/// (StatefulShellRoute) and trading routes are intentionally out of scope.
GoRouter buildAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    // Future auth-guard seam: return a location to redirect, or null
    // to allow navigation. Always null during the UI-only phase.
    redirect: (BuildContext context, GoRouterState state) => null,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splashName,
        // Temporary: Splash does not exist yet, so the boot route renders the
        // implemented Welcome screen.
        builder: (BuildContext context, GoRouterState state) {
          return const WelcomeScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.welcome,
        name: AppRoutes.welcomeName,
        builder: (BuildContext context, GoRouterState state) {
          return const WelcomeScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.loginName,
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: AppRoutes.signupName,
        builder: (BuildContext context, GoRouterState state) {
          return const SignupScreen();
        },
      ),
    ],
  );
}

/// Provides the shared [GoRouter] instance.
final routerProvider = Provider<GoRouter>((Ref ref) {
  return buildAppRouter();
});
