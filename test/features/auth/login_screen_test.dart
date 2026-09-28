import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:tradewise/app/theme/tw_theme.dart';
import 'package:tradewise/core/widgets/tradewise_brand_mark.dart';
import 'package:tradewise/features/auth/presentation/login_screen.dart';

/// Pumps [LoginScreen] inside the real app theme + router harness.
Future<void> pumpLoginScreen(
  WidgetTester tester, {
  ThemeMode themeMode = ThemeMode.light,
}) async {
  final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/welcome',
        builder: (context, state) =>
            const Scaffold(body: Text('Welcome placeholder')),
      ),
    ],
  );
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

/// The password input, located by its user-visible label rather than by index.
TextField passwordField(WidgetTester tester) {
  return tester.widget<TextField>(
    find.byWidgetPredicate(
      (Widget widget) =>
          widget is TextField && widget.decoration?.labelText == 'Password',
    ),
  );
}

/// Runs a snackbar-based temporary notice out of the test without leaving
/// pending timers behind (same approach as the Welcome screen tests).
Future<void> drainNotice(WidgetTester tester, String notice) async {
  await tester.pump();
  expect(find.text(notice), findsOneWidget);

  await tester.pump(const Duration(milliseconds: 750));
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
  expect(find.text(notice), findsNothing);
}

void main() {
  testWidgets('Login content renders', (WidgetTester tester) async {
    await pumpLoginScreen(tester);

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Phone or User ID'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Forgot user ID or password?'), findsOneWidget);
    expect(find.byType(TradeWiseBrandMark), findsOneWidget);
    expect(find.textContaining('paper-trading'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Login renders in light theme', (WidgetTester tester) async {
    await pumpLoginScreen(tester, themeMode: ThemeMode.light);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, isNull); // Uses theme scaffold color.
    expect(find.text('Login'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Login renders in dark theme', (WidgetTester tester) async {
    await pumpLoginScreen(tester, themeMode: ThemeMode.dark);

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Back returns to Welcome', (WidgetTester tester) async {
    await pumpLoginScreen(tester);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome placeholder'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Password visibility toggle is local UI state', (
    WidgetTester tester,
  ) async {
    await pumpLoginScreen(tester);

    expect(passwordField(tester).obscureText, isTrue);

    await tester.tap(find.byTooltip('Show password'));
    await tester.pumpAndSettle();
    expect(passwordField(tester).obscureText, isFalse);
    expect(find.byTooltip('Hide password'), findsOneWidget);

    await tester.tap(find.byTooltip('Hide password'));
    await tester.pumpAndSettle();
    expect(passwordField(tester).obscureText, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Login CTA does not fake a session', (WidgetTester tester) async {
    await pumpLoginScreen(tester);

    await tester.tap(find.text('Log in'));
    await drainNotice(tester, 'Login is not available yet');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Forgot user ID reports a temporary notice', (
    WidgetTester tester,
  ) async {
    await pumpLoginScreen(tester);

    await tester.tap(find.text('Forgot user ID or password?'));
    await drainNotice(tester, 'Password recovery is not available yet');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Interactive elements have semantics and touch targets', (
    WidgetTester tester,
  ) async {
    await pumpLoginScreen(tester);

    expect(
      find.bySemanticsLabel(RegExp('Forgot user ID or password')),
      findsOneWidget,
    );

    for (final finder in <Finder>[
      find.byTooltip('Back'),
      find.bySemanticsLabel(RegExp('Log in')),
      find.byTooltip('Show password'),
      find.bySemanticsLabel(RegExp('Forgot user ID or password')),
    ]) {
      final size = tester.getSize(finder);
      expect(size.height, greaterThanOrEqualTo(48));
      expect(size.width, greaterThanOrEqualTo(48));
    }

    expect(tester.takeException(), isNull);
  });

  testWidgets('Constrained small viewport does not overflow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await pumpLoginScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
