import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tradewise/app/router/app_router.dart';
import 'package:tradewise/app/theme/tw_theme.dart';

Future<void> pumpShell(
  WidgetTester tester, {
  String initialLocation = '/watchlist',
  ThemeMode themeMode = ThemeMode.light,
}) async {
  final router = buildAppRouter(initialLocation: initialLocation);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp.router(
        theme: TWTheme.light(),
        darkTheme: TWTheme.dark(),
        themeMode: themeMode,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shell renders five destinations', (tester) async {
    await pumpShell(tester);
    expect(find.byType(NavigationBar), findsOneWidget);
    for (final label in [
      'Home',
      'Watchlist',
      'Orders',
      'Portfolio',
      'Profile',
    ]) {
      expect(find.text(label), findsWidgets);
    }
  });

  testWidgets('tapping destinations switches branch', (tester) async {
    await pumpShell(tester);
    await tester.tap(find.text('Orders'));
    await tester.pumpAndSettle();
    expect(find.text('Orders'), findsWidgets);
    expect(find.text('Temporary placeholder'), findsOneWidget);
    await tester.tap(find.text('Portfolio'));
    await tester.pumpAndSettle();
    expect(find.text('Temporary placeholder'), findsOneWidget);
  });

  testWidgets('direct route selects correct tab', (tester) async {
    await pumpShell(tester, initialLocation: '/orders');
    expect(find.text('Orders'), findsWidgets);
    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(bar.selectedIndex, 2);
  });

  testWidgets('shell renders in dark theme without overflow', (tester) async {
    await pumpShell(tester, themeMode: ThemeMode.dark);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('constrained viewport does not overflow', (tester) async {
    tester.view.physicalSize = const Size(640, 1136);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
    await pumpShell(tester);
    expect(tester.takeException(), isNull);
  });
}
