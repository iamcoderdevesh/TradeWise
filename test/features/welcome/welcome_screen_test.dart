import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:tradewise/app/theme/tw_theme.dart';
import 'package:tradewise/features/welcome/presentation/welcome_screen.dart';
import 'package:tradewise/features/welcome/presentation/widgets/tradewise_brand_mark.dart';

/// Pumps [WelcomeScreen] inside the real app theme + router harness.
Future<void> pumpWelcomeScreen(
  WidgetTester tester, {
  ThemeMode themeMode = ThemeMode.light,
  GoRouter? router,
}) async {
  final testRouter =
      router ??
      GoRouter(
        initialLocation: '/welcome',
        routes: [
          GoRoute(
            path: '/welcome',
            builder: (context, state) => const WelcomeScreen(),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) =>
                const Scaffold(body: Text('Login placeholder')),
          ),
        ],
      );
  addTearDown(testRouter.dispose);

  final theme = themeMode == ThemeMode.dark ? TWTheme.dark() : TWTheme.light();
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp.router(
        theme: theme,
        darkTheme: TWTheme.dark(),
        themeMode: themeMode,
        routerConfig: testRouter,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Welcome content renders', (WidgetTester tester) async {
    await pumpWelcomeScreen(tester);

    expect(find.text('Welcome to\nTradeWise'), findsOneWidget);
    expect(find.text('Try demo'), findsOneWidget);
    expect(find.text('Open a free account'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.textContaining('paper-trading'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Welcome renders in light theme', (WidgetTester tester) async {
    await pumpWelcomeScreen(tester, themeMode: ThemeMode.light);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, isNull); // Uses theme scaffold color.
    expect(find.text('Welcome to\nTradeWise'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Welcome renders in dark theme', (WidgetTester tester) async {
    await pumpWelcomeScreen(tester, themeMode: ThemeMode.dark);

    expect(find.text('Welcome to\nTradeWise'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Log in navigates to /login', (WidgetTester tester) async {
    await pumpWelcomeScreen(tester);

    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Login placeholder'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Unavailable actions report a temporary notice', (
    WidgetTester tester,
  ) async {
    await pumpWelcomeScreen(tester);

    await tester.tap(find.text('Open a free account'));
    await tester.pump();

    const notice = 'Account opening is not available yet';
    expect(find.text(notice), findsOneWidget);

    // Finish the entrance animation, let the notice auto-dismiss, then finish
    // the exit animation so no timers stay pending after the test.
    await tester.pump(const Duration(milliseconds: 750));
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text(notice), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Interactive elements have semantics and touch targets', (
    WidgetTester tester,
  ) async {
    await pumpWelcomeScreen(tester);

    // Semantics are user-visible labels, not widget-type assertions.
    expect(find.bySemanticsLabel(RegExp('Log in')), findsWidgets);
    expect(find.bySemanticsLabel('Try demo'), findsOneWidget);

    for (final label in ['Try demo', 'Open a free account', 'Log in']) {
      final size = tester.getSize(find.bySemanticsLabel(RegExp(label)));
      expect(size.height, greaterThanOrEqualTo(48));
      expect(size.width, greaterThanOrEqualTo(48));
    }

    // Both action rows are live controls; "Open a free account" communicates
    // its unavailable state through its semantics label instead of being inert.
    final openAccount = tester.getSemantics(
      find.bySemanticsLabel(RegExp('Open a free account')),
    );
    // ignore: deprecated_member_use
    expect(openAccount.hasFlag(SemanticsFlag.isButton), isTrue);
    // ignore: deprecated_member_use
    expect(openAccount.hasFlag(SemanticsFlag.isEnabled), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Reference vertical rhythm is preserved', (
    WidgetTester tester,
  ) async {
    await pumpWelcomeScreen(tester);

    final button = tester.getRect(find.byType(OutlinedButton));
    final brandMark = tester.getRect(find.byType(TradeWiseBrandMark));
    final heading = tester.getRect(find.text('Welcome to\nTradeWise'));
    final footerTop = tester.getTopLeft(find.text('TRADEWISE')).dy;

    expect(find.byType(Divider), findsNWidgets(3));
    final dividerRects = <Rect>[
      tester.getRect(find.byType(Divider).at(0)),
      tester.getRect(find.byType(Divider).at(1)),
      tester.getRect(find.byType(Divider).at(2)),
    ];

    // Gaps are sums of TWSpacing tokens; values documented in
    // WelcomeScreen and derived from references/kite/welcome/.
    expect(brandMark.top - button.bottom, closeTo(72, 0.01)); // _topToBrandMark
    expect(
      heading.top - brandMark.bottom,
      closeTo(32, 0.01),
    ); // _brandMarkToHeading
    expect(
      dividerRects[0].top - heading.bottom,
      closeTo(64, 0.01),
    ); // _headingToActions

    // Row rhythm: 72dp row + 1dp divider (reference measures 71.4 pitch).
    expect(dividerRects[1].top - dividerRects[0].top, closeTo(73, 0.01));
    expect(dividerRects[2].top - dividerRects[1].top, closeTo(73, 0.01));
    expect(
      footerTop - dividerRects[2].bottom,
      closeTo(84, 0.01),
    ); // _actionsToFooter
  });

  testWidgets('Constrained small viewport does not overflow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await pumpWelcomeScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('Welcome to\nTradeWise'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
