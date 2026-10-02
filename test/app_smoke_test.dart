import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tradewise/app/app.dart';
import 'package:tradewise/app/router/app_router.dart';
import 'package:tradewise/app/router/app_routes.dart';
import 'package:tradewise/app/theme/theme_mode_provider.dart';
import 'package:tradewise/core/widgets/tradewise_brand_mark.dart';
import 'package:tradewise/features/splash/presentation/splash_screen.dart';

void main() {
  testWidgets('app boots on the splash route then navigates to Welcome', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: TradeWiseApp()));
    await tester.pump();

    // `/` is the application entry route and renders the Splash screen, not
    // Welcome.
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(TradeWiseBrandMark), findsOneWidget);
    expect(find.text('Welcome to\nTradeWise'), findsNothing);

    // After the deterministic 1500 ms dwell the app navigates to Welcome.
    await tester.pump(SplashScreen.dwell);
    await tester.pumpAndSettle();
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.text('Welcome to\nTradeWise'), findsOneWidget);
    expect(tester.takeException(), isNull);
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
    await tester.pump();
    // `/` boots into the Splash screen (see app_router.dart).
    expect(find.byType(SplashScreen), findsOneWidget);

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
    await tester.pump();

    // `/` boots into the Splash screen; the theme is dark.
    expect(find.byType(SplashScreen), findsOneWidget);
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.dark);
    expect(tester.takeException(), isNull);
  });
}

class _DarkThemeModeNotifier extends ThemeModeNotifier {
  @override
  ThemeMode build() => ThemeMode.dark;
}
