import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Main TradeWise application shell.
///
/// Hosts the persistent bottom navigation for the five shell destinations
/// (Home, Watchlist, Orders, Portfolio, Profile) and renders the currently
/// active branch through [navigationShell] (`StatefulShellRoute.indexedStack`,
/// see `app_router.dart`).
///
/// The selected destination is read from `navigationShell.currentIndex`, which
/// the router owns, so there is no second source of truth (no Riverpod
/// provider for the selected tab). Because the router uses an `IndexedStack`,
/// each branch keeps its own navigation stack and scroll position while the
/// other branches are offstage.
///
/// Destination names and icons are TradeWise's own (Material outline glyphs);
/// nothing is copied from the reference product's navigation, which uses
/// different destinations entirely.
class TradeWiseShell extends StatelessWidget {
  const TradeWiseShell({super.key, required this.navigationShell});

  /// The router-owned shell state (branch index + branch navigators).
  final StatefulNavigationShell navigationShell;

  /// Icon size, kept local: it is this component's own measurement rather than
  /// a reusable design-system dimension.
  static const double _iconSize = 24;

  @override
  Widget build(BuildContext context) {
    final dividerColor = Theme.of(context).dividerColor;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: dividerColor)),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onDestinationSelected,
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.home_outlined, size: _iconSize),
              selectedIcon: Icon(Icons.home, size: _iconSize),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_border, size: _iconSize),
              selectedIcon: Icon(Icons.bookmark, size: _iconSize),
              label: 'Watchlist',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined, size: _iconSize),
              selectedIcon: Icon(Icons.receipt_long, size: _iconSize),
              label: 'Orders',
            ),
            NavigationDestination(
              icon: Icon(Icons.work_outline, size: _iconSize),
              selectedIcon: Icon(Icons.work, size: _iconSize),
              label: 'Portfolio',
            ),
            NavigationDestination(
              icon: Icon(Icons.person, size: _iconSize),
              selectedIcon: Icon(Icons.person, size: _iconSize),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  void _onDestinationSelected(int index) {
    // `initialLocation: true` when the already-active destination is tapped
    // again, so a second tap returns that branch to its initial location
    // (standard shell behaviour); otherwise the branch's last location is
    // restored, preserving its navigation stack.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
