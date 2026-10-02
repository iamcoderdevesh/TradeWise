import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/watchlist/presentation/watchlist_screen.dart';
import '../../features/welcome/presentation/welcome_screen.dart';
import '../shell/placeholder_destination_screen.dart';
import '../shell/tradewise_shell.dart';
import 'app_routes.dart';

/// Builds the application [GoRouter].
///
/// `/` is the application entry route and renders [SplashScreen], which after a
/// deterministic 1500 ms dwell navigates to `/welcome`
/// ([WelcomeScreen]). `/login` and `/signup` resolve to the implemented auth
/// screens ([LoginScreen], [SignupScreen]).
///
/// Extension point: a future auth redirect can be added via [redirect]
/// without changing route declarations (that is where a real session check
/// will live later; today Splash always leads to Welcome). Bottom navigation
/// (StatefulShellRoute) and trading routes are intentionally out of scope.
GoRouter buildAppRouter({String initialLocation = AppRoutes.splash}) {
  return GoRouter(
    initialLocation: initialLocation,
    // Future auth-guard seam: return a location to redirect, or null
    // to allow navigation. Always null during the UI-only phase.
    redirect: (BuildContext context, GoRouterState state) => null,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splashName,
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
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
      // Main application shell. Splash, Welcome, Login and Signup stay outside
      // it (they are not bottom-navigation destinations), so the existing
      // startup and auth flow is untouched.
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) {
              return TradeWiseShell(navigationShell: navigationShell);
            },
        branches: <StatefulShellBranch>[
          _shellBranch(
            path: AppRoutes.home,
            name: AppRoutes.homeName,
            child: const PlaceholderDestinationScreen(title: 'Home'),
          ),
          _shellBranch(
            path: AppRoutes.watchlist,
            name: AppRoutes.watchlistName,
            child: const WatchlistScreen(),
          ),
          _shellBranch(
            path: AppRoutes.orders,
            name: AppRoutes.ordersName,
            child: const PlaceholderDestinationScreen(title: 'Orders'),
          ),
          _shellBranch(
            path: AppRoutes.portfolio,
            name: AppRoutes.portfolioName,
            child: const PlaceholderDestinationScreen(title: 'Portfolio'),
          ),
          _shellBranch(
            path: AppRoutes.profile,
            name: AppRoutes.profileName,
            child: const PlaceholderDestinationScreen(title: 'Profile'),
          ),
        ],
      ),
    ],
  );
}

/// Builds one shell branch wrapping a single top-level [GoRoute].
///
/// Nested sub-routes (for example `/watchlist/:id`) are intentionally not
/// declared yet; they are added when the corresponding feature exists.
StatefulShellBranch _shellBranch({
  required String path,
  required String name,
  required Widget child,
}) {
  return StatefulShellBranch(
    routes: <RouteBase>[
      GoRoute(
        path: path,
        name: name,
        builder: (BuildContext context, GoRouterState state) => child,
      ),
    ],
  );
}

/// Provides the shared [GoRouter] instance.
final routerProvider = Provider<GoRouter>((Ref ref) {
  return buildAppRouter();
});
