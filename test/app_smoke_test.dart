import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tradewise/app/app.dart';
import 'package:tradewise/app/router/app_router.dart';
import 'package:tradewise/app/router/app_routes.dart';
import 'package:tradewise/app/theme/theme_mode_provider.dart';

void main() {
  testWidgets('app boots on the root route and renders Welcome', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: TradeWiseApp()));
    await tester.pumpAndSettle();

    // `/` renders WelcomeScreen until the Splash screen is implemented.
    expect(find.text('Welcome to\nTradeWise'), findsOneWidget);
  });

  test('router resolves foundation route paths', () {
    final router = buildAppRouter();
    const paths = [
      AppRoutes.splash,
      AppRoutes.welcome,
      AppRoutes.login,
      AppRoutes.signup,
    ];

    for (final path in paths) {
      final match = router.configuration.findMatch(Uri.parse(path));
      expect(match.matches, isNotEmpty, reason: 'no match for $path');
    }
    expect(AppRoutes.splash, '/');
  });

  test('router exposes well-known named routes', () {
    final router = buildAppRouter();
    expect(
      router.namedLocation(
        AppRoutes.welcomeName,
        pathParameters: const <String, String>{},
      ),
      AppRoutes.welcome,
    );
    expect(
      router.namedLocation(
        AppRoutes.loginName,
        pathParameters: const <String, String>{},
      ),
      AppRoutes.login,
    );
    expect(
      router.namedLocation(
        AppRoutes.signupName,
        pathParameters: const <String, String>{},
      ),
      AppRoutes.signup,
    );
  });

  testWidgets('welcome, login, and signup routes resolve without errors', (
    WidgetTester tester,
  ) async {
    final router = buildAppRouter();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [routerProvider.overrideWithValue(router)],
        child: const TradeWiseApp(),
      ),
    );
    await tester.pumpAndSettle();
    // `/` temporarily renders WelcomeScreen (see app_router.dart).
    expect(find.text('Welcome to\nTradeWise'), findsOneWidget);

    router.go(AppRoutes.welcome);
    await tester.pumpAndSettle();
    expect(find.text('Welcome to\nTradeWise'), findsOneWidget);

    router.go(AppRoutes.login);
    await tester.pumpAndSettle();
    expect(find.text('Login'), findsOneWidget);

    router.go(AppRoutes.signup);
    await tester.pumpAndSettle();
    expect(find.text('Open your account'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dark theme mode renders without errors', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          themeModeProvider.overrideWith(() => _DarkThemeModeNotifier()),
        ],
        child: const TradeWiseApp(),
      ),
    );
    await tester.pumpAndSettle();

    // `/` temporarily renders WelcomeScreen (see app_router.dart).
    expect(find.text('Welcome to\nTradeWise'), findsOneWidget);
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.dark);
    expect(tester.takeException(), isNull);
  });
}

class _DarkThemeModeNotifier extends ThemeModeNotifier {
  @override
  ThemeMode build() => ThemeMode.dark;
}
