import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:tradewise/app/router/app_router.dart';
import 'package:tradewise/app/theme/tw_theme.dart';
import 'package:tradewise/core/widgets/tradewise_brand_mark.dart';
import 'package:tradewise/features/splash/presentation/splash_screen.dart';

const String welcomeHeading = 'Welcome to\nTradeWise';

/// Pumps the real application router (so `/` boots into [SplashScreen]) inside
/// the real TradeWise themes, mirroring the other feature test harnesses.
Future<GoRouter> pumpSplashApp(
  WidgetTester tester, {
  ThemeMode themeMode = ThemeMode.light,
}) async {
  final router = buildAppRouter();
  addTearDown(router.dispose);
  await tester.pumpWidget(
    MaterialApp.router(
      theme: TWTheme.light(),
      darkTheme: TWTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    ),
  );
  return router;
}

/// The brand mark's reveal transition, located through the mark itself.
FadeTransition brandMarkFade(WidgetTester tester) {
  return tester.widget<FadeTransition>(
    find.ancestor(
      of: find.byType(TradeWiseBrandMark),
      matching: find.byType(FadeTransition),
    ),
  );
}

void main() {
  test('Splash dwell is a deterministic 1500 ms', () {
    expect(SplashScreen.dwell, const Duration(milliseconds: 1500));
  });

  group('Splash rendering', () {
    testWidgets('renders the TradeWise brand mark and no other content', (
      WidgetTester tester,
    ) async {
      await pumpSplashApp(tester);
      await tester.pump();

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(TradeWiseBrandMark), findsOneWidget);
      expect(find.text('TW'), findsOneWidget);
      // A launch screen: no Welcome copy, no interactive controls.
      expect(find.text(welcomeHeading), findsNothing);
      expect(find.byType(TextField), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('uses the themed scaffold background (no colour override)', (
      WidgetTester tester,
    ) async {
      await pumpSplashApp(tester);
      await tester.pump();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, isNull);
      expect(find.byType(AppBar), findsNothing);
    });

    testWidgets('renders without overflow in light and dark', (
      WidgetTester tester,
    ) async {
      for (final themeMode in <ThemeMode>[ThemeMode.light, ThemeMode.dark]) {
        await pumpSplashApp(tester, themeMode: themeMode);
        await tester.pump();

        expect(
          find.byType(TradeWiseBrandMark),
          findsOneWidget,
          reason: 'brand mark missing in $themeMode',
        );
        expect(tester.takeException(), isNull, reason: 'error in $themeMode');
      }
    });

    testWidgets('renders without overflow on small, large and landscape '
        'viewports', (WidgetTester tester) async {
      const sizes = <Size>[
        Size(320, 568), // small phone
        Size(412, 915), // standard/large phone
        Size(834, 1112), // tablet portrait
        Size(915, 412), // phone landscape
      ];

      for (final size in sizes) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await pumpSplashApp(tester);
        await tester.pump();

        expect(
          find.byType(TradeWiseBrandMark),
          findsOneWidget,
          reason: 'brand mark missing at $size',
        );
        expect(tester.takeException(), isNull, reason: 'overflow at $size');

        // The mark stays centered on every viewport size.
        final markRect = tester.getRect(find.byType(TradeWiseBrandMark));
        final screenCenter = Offset(size.width / 2, size.height / 2);
        expect(markRect.center.dx, closeTo(screenCenter.dx, 0.5));
        expect(markRect.center.dy, closeTo(screenCenter.dy, 0.5));
      }
    });

    testWidgets('shows the brand mark without transition when reduced motion '
        'is enabled', (WidgetTester tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );

      await pumpSplashApp(tester);
      await tester.pump();

      expect(brandMarkFade(tester).opacity.value, 1.0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('plays a brand reveal that starts after the first frame', (
      WidgetTester tester,
    ) async {
      await pumpSplashApp(tester);
      await tester.pump();

      // Not already finished: the reveal is scheduled for after the first
      // frame, so a slow startup frame cannot swallow it in one step.
      expect(brandMarkFade(tester).opacity.value, lessThan(1.0));
      expect(find.byType(SplashScreen), findsOneWidget);

      // It completes well inside the dwell, so navigation timing is unchanged.
      await tester.pumpAndSettle();
      expect(brandMarkFade(tester).opacity.value, 1.0);
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Splash navigation timing', () {
    testWidgets('does not navigate before the 1500 ms dwell, then shows '
        'Welcome', (WidgetTester tester) async {
      await pumpSplashApp(tester);
      await tester.pump();

      // Not immediate: still on Splash right after the first frame.
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text(welcomeHeading), findsNothing);

      // Still on Splash shortly before the dwell elapses.
      await tester.pump(const Duration(milliseconds: 1400));
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text(welcomeHeading), findsNothing);

      // At the dwell the app navigates to Welcome.
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.text(welcomeHeading), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('navigates deterministically when the dwell elapses in one '
        'step', (WidgetTester tester) async {
      await pumpSplashApp(tester);
      await tester.pump();

      await tester.pump(SplashScreen.dwell);
      await tester.pumpAndSettle();

      expect(find.text(welcomeHeading), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Splash lifecycle safety', () {
    testWidgets('disposing before the dwell elapses cancels the timer safely', (
      WidgetTester tester,
    ) async {
      await pumpSplashApp(tester);
      await tester.pump();

      // Unmount Splash while its dwell timer is still pending.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      // No setState-after-dispose, navigation-after-dispose or timer errors.
      expect(tester.takeException(), isNull);

      // Advancing time past the (now cancelled) dwell must not navigate.
      await tester.pump(const Duration(milliseconds: 2000));
      expect(tester.takeException(), isNull);
    });
  });
}
