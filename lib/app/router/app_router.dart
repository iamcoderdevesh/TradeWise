import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/foundation_placeholder_screen.dart';
import 'app_routes.dart';

/// Builds the application [GoRouter].
///
/// Foundation scope: `/`, `/welcome`, and `/login` all resolve to the
/// temporary [FoundationPlaceholderScreen], which is removed when Welcome
/// is implemented.
///
/// Extension point: a future auth redirect can be added via [redirect]
/// without changing route declarations. Bottom navigation
/// (StatefulShellRoute) and trading routes are intentionally out of scope.
GoRouter buildAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    // Future auth-guard seam: return a location to redirect, or null
    // to allow navigation. Always null during foundation.
    redirect: (BuildContext context, GoRouterState state) => null,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splashName,
        builder: (BuildContext context, GoRouterState state) {
          return const FoundationPlaceholderScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.welcome,
        name: AppRoutes.welcomeName,
        builder: (BuildContext context, GoRouterState state) {
          return const FoundationPlaceholderScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.loginName,
        builder: (BuildContext context, GoRouterState state) {
          return const FoundationPlaceholderScreen();
        },
      ),
    ],
  );
}

/// Provides the shared [GoRouter] instance.
final routerProvider = Provider<GoRouter>((Ref ref) {
  return buildAppRouter();
});
