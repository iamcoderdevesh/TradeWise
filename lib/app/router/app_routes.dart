/// Route path and name constants.
///
/// Single source of truth for navigation targets. Feature screens add their
/// own constants here as they are implemented.
///
/// The five shell destinations are the branches of the main application shell
/// (`StatefulShellRoute.indexedStack` in `app_router.dart`). They are declared
/// as flat top-level paths (no nested `/watchlist/:id` style routes yet) so the
/// shell stays simple until the corresponding features exist.
abstract final class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';

  // Order placement ticket. A top-level route (outside the shell) so it
  // pushes full-screen over the Watchlist with a standard back affordance.
  static const String order = '/order';

  // Main application shell destinations.
  static const String home = '/home';
  static const String watchlist = '/watchlist';
  static const String orders = '/orders';
  static const String portfolio = '/portfolio';
  static const String profile = '/profile';

  static const String splashName = 'splash';
  static const String welcomeName = 'welcome';
  static const String loginName = 'login';
  static const String signupName = 'signup';

  static const String orderName = 'order';

  static const String homeName = 'home';
  static const String watchlistName = 'watchlist';
  static const String ordersName = 'orders';
  static const String portfolioName = 'portfolio';
  static const String profileName = 'profile';
}
