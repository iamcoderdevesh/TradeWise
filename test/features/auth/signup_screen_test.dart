import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:tradewise/app/theme/tw_theme.dart';
import 'package:tradewise/core/widgets/tradewise_brand_mark.dart';
import 'package:tradewise/features/auth/presentation/signup_screen.dart';
import 'package:tradewise/features/auth/presentation/widgets/signup_terms_note.dart';

/// Pumps [SignupScreen] inside the real app theme + router harness.
Future<void> pumpSignupScreen(
  WidgetTester tester, {
  ThemeMode themeMode = ThemeMode.light,
}) async {
  final router = GoRouter(
    initialLocation: '/signup',
    routes: [
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            const Scaffold(body: Text('Login placeholder')),
      ),
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

/// The field located by its user-visible label.
TextField fieldByLabel(WidgetTester tester, String label) {
  return tester.widget<TextField>(
    find.byWidgetPredicate(
      (Widget widget) =>
          widget is TextField && widget.decoration?.labelText == label,
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
  testWidgets('Signup content renders', (WidgetTester tester) async {
    await pumpSignupScreen(tester);

    expect(find.text('Open your account'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Already have an account? Log in'), findsOneWidget);
    expect(find.textContaining('terms and conditions'), findsOneWidget);
    expect(find.byType(TradeWiseBrandMark), findsOneWidget);
    expect(find.text('TRADEWISE'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Signup fields are in the correct order', (
    WidgetTester tester,
  ) async {
    await pumpSignupScreen(tester);

    // Locators for each field by label.
    final nameLocator = find.byWidgetPredicate(
      (Widget widget) =>
          widget is TextField && widget.decoration?.labelText == 'Name',
    );
    final emailLocator = find.byWidgetPredicate(
      (Widget widget) =>
          widget is TextField && widget.decoration?.labelText == 'Email',
    );
    final passwordLocator = find.byWidgetPredicate(
      (Widget widget) =>
          widget is TextField && widget.decoration?.labelText == 'Password',
    );
    final confirmPasswordLocator = find.byWidgetPredicate(
      (Widget widget) =>
          widget is TextField &&
          widget.decoration?.labelText == 'Confirm Password',
    );

    expect(nameLocator, findsOneWidget);
    expect(emailLocator, findsOneWidget);
    expect(passwordLocator, findsOneWidget);
    expect(confirmPasswordLocator, findsOneWidget);

    // Verify vertical order: Name < Email < Password < Confirm Password
    expect(
      tester.getTopLeft(nameLocator).dy,
      lessThan(tester.getTopLeft(emailLocator).dy),
    );
    expect(
      tester.getTopLeft(emailLocator).dy,
      lessThan(tester.getTopLeft(passwordLocator).dy),
    );
    expect(
      tester.getTopLeft(passwordLocator).dy,
      lessThan(tester.getTopLeft(confirmPasswordLocator).dy),
    );
  });

  testWidgets('Signup illustration is no longer displayed', (
    WidgetTester tester,
  ) async {
    await pumpSignupScreen(tester);

    expect(find.text('Phone number'), findsNothing);
    expect(find.text('+91'), findsNothing);
  });

  testWidgets('Password visibility toggle works', (WidgetTester tester) async {
    await pumpSignupScreen(tester);

    final passwordField = fieldByLabel(tester, 'Password');
    expect(passwordField.obscureText, isTrue);

    await tester.tap(find.byTooltip('Show password').first);
    await tester.pumpAndSettle();
    expect(fieldByLabel(tester, 'Password').obscureText, isFalse);
    expect(find.byTooltip('Hide password').first, findsOneWidget);

    await tester.tap(find.byTooltip('Hide password').first);
    await tester.pumpAndSettle();
    expect(fieldByLabel(tester, 'Password').obscureText, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Confirm password visibility toggle works', (
    WidgetTester tester,
  ) async {
    await pumpSignupScreen(tester);

    final confirmField = fieldByLabel(tester, 'Confirm Password');
    expect(confirmField.obscureText, isTrue);

    await tester.tap(find.byTooltip('Show password').last);
    await tester.pumpAndSettle();
    expect(fieldByLabel(tester, 'Confirm Password').obscureText, isFalse);
    expect(find.byTooltip('Hide password').last, findsOneWidget);

    await tester.tap(find.byTooltip('Hide password').last);
    await tester.pumpAndSettle();
    expect(fieldByLabel(tester, 'Confirm Password').obscureText, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Login link navigates to Login', (WidgetTester tester) async {
    await pumpSignupScreen(tester);

    // The link sits below the fold in the default viewport; scroll it into view.
    await tester.ensureVisible(find.text('Already have an account? Log in'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Already have an account? Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Login placeholder'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Signup renders in light theme', (WidgetTester tester) async {
    await pumpSignupScreen(tester, themeMode: ThemeMode.light);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, isNull); // Uses theme scaffold color.
    expect(find.text('Open your account'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Signup renders in dark theme', (WidgetTester tester) async {
    await pumpSignupScreen(tester, themeMode: ThemeMode.dark);

    expect(find.text('Open your account'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Back returns to Welcome', (WidgetTester tester) async {
    await pumpSignupScreen(tester);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome placeholder'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Continue CTA does not fake account creation', (
    WidgetTester tester,
  ) async {
    await pumpSignupScreen(tester);

    // The CTA sits below the fold in the default viewport; scroll it into view.
    await tester.ensureVisible(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await drainNotice(tester, 'Account creation is not available yet');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Terms link reports a temporary notice', (
    WidgetTester tester,
  ) async {
    await pumpSignupScreen(tester);

    // The note sits below the fold in the default test viewport, so the user
    // scrolls it into view before tapping the inline link.
    await tester.ensureVisible(find.byType(SignupTermsNote));
    await tester.pumpAndSettle();

    await tester.tapOnText(find.textRange.ofSubstring('terms and conditions'));
    await drainNotice(tester, 'Terms and conditions are not available yet');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Body scrolls when the viewport is short', (
    WidgetTester tester,
  ) async {
    // The reference shows this screen scrolling once the keyboard reduces the
    // usable height; a short viewport reproduces that constraint.
    tester.view.physicalSize = const Size(360, 520);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await pumpSignupScreen(tester);

    final scrollView = find.byType(SingleChildScrollView);
    expect(scrollView, findsOneWidget);
    await tester.dragUntilVisible(
      find.text('TRADEWISE'),
      scrollView,
      const Offset(0, -100),
    );
    expect(find.text('TRADEWISE'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Interactive elements have semantics and touch targets', (
    WidgetTester tester,
  ) async {
    await pumpSignupScreen(tester);

    for (final finder in <Finder>[
      find.byTooltip('Back'),
      find.bySemanticsLabel(RegExp('Continue')),
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

    await pumpSignupScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('Open your account'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
