import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:tradewise/app/theme/tw_theme.dart';
import 'package:tradewise/core/widgets/tradewise_brand_mark.dart';
import 'package:tradewise/features/auth/presentation/signup_screen.dart';
import 'package:tradewise/features/auth/presentation/widgets/signup_illustration.dart';
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

/// The phone input, located by its user-visible label rather than by index.
TextField phoneField(WidgetTester tester) {
  return tester.widget<TextField>(
    find.byWidgetPredicate(
      (Widget widget) =>
          widget is TextField && widget.decoration?.labelText == 'Phone number',
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
    expect(find.text('+91'), findsOneWidget);
    expect(find.text('Phone number'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.textContaining('terms and conditions'), findsOneWidget);
    expect(find.byType(SignupIllustration), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('verification code message')),
      findsOneWidget,
    );
    expect(find.byType(TradeWiseBrandMark), findsOneWidget);
    expect(find.text('TRADEWISE'), findsOneWidget);
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

  testWidgets('Phone field uses the reference numeric keypad', (
    WidgetTester tester,
  ) async {
    await pumpSignupScreen(tester);

    final keyboardType = phoneField(tester).keyboardType;
    expect(keyboardType, isNotNull);
    // Digits plus separators, matching the reference keypad.
    expect(
      keyboardType.index,
      TextInputType.numberWithOptions(decimal: true).index,
    );
    // The country code is display-only.
    expect(phoneField(tester).controller?.text, isEmpty);
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
