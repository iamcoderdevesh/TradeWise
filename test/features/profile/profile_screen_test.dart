import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tradewise/app/router/app_router.dart';
import 'package:tradewise/app/theme/tw_theme.dart';
import 'package:tradewise/features/profile/data/profile_preview_data.dart';
import 'package:tradewise/features/profile/data/profile_repository.dart';
import 'package:tradewise/features/profile/domain/profile.dart';
import 'package:tradewise/features/profile/presentation/profile_providers.dart';
import 'package:tradewise/features/profile/presentation/profile_screen.dart';
import 'package:tradewise/features/profile/presentation/widgets/profile_menu_row.dart';

Future<ProviderContainer> pumpProfile(
  WidgetTester tester, {
  ThemeMode themeMode = ThemeMode.light,
  UserProfile? profile,
}) async {
  final ProviderContainer container = ProviderContainer(
    overrides: [
      profileRepositoryProvider.overrideWith(
        (Ref ref) => MockProfileRepository(profile: profile ?? kPreviewProfile),
      ),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: TWTheme.light(),
        darkTheme: TWTheme.dark(),
        themeMode: themeMode,
        home: const ProfileScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  group('Profile screen rendering', () {
    testWidgets('renders all sections in light theme', (tester) async {
      await pumpProfile(tester, themeMode: ThemeMode.light);

      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.text('TradeWise User'), findsOneWidget);
      expect(find.text('TW123456'), findsOneWidget);
      expect(find.text('user@tradewise.app'), findsOneWidget);
      expect(find.text('TW'), findsOneWidget);
      expect(find.text('Privacy mode'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
      expect(find.byType(ProfileMenuRow), findsNWidgets(6));
      expect(find.text('Funds'), findsOneWidget);
      expect(find.text('App Code'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Connected apps'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders all sections in dark theme', (tester) async {
      await pumpProfile(tester, themeMode: ThemeMode.dark);

      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.text('TradeWise User'), findsOneWidget);
      expect(find.text('TW123456'), findsOneWidget);
      expect(find.text('user@tradewise.app'), findsOneWidget);
      expect(find.text('Privacy mode'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Funds'), findsOneWidget);
      expect(find.text('App Code'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Connected apps'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('market indices strip renders both indices', (tester) async {
      await pumpProfile(tester);

      expect(find.text('NIFTY 50'), findsOneWidget);
      expect(find.text('NIFTY BANK'), findsOneWidget);
      expect(find.text('25,144.30'), findsOneWidget);
      expect(find.text('61,034.10'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('notification bell is present', (tester) async {
      await pumpProfile(tester);

      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Privacy Mode', () {
    testWidgets('masks ID and email when switched ON', (tester) async {
      await pumpProfile(tester);

      expect(find.text('TW123456'), findsOneWidget);
      expect(find.text('user@tradewise.app'), findsOneWidget);

      final Finder switchFinder = find.byType(AnimatedContainer);
      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(find.text('TW123456'), findsNothing);
      expect(find.text('user@tradewise.app'), findsNothing);
      expect(find.text('TW1***'), findsOneWidget);
      expect(find.text('u****r@tradewise.app'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('restores ID and email when switched OFF again', (
      tester,
    ) async {
      await pumpProfile(tester);

      await tester.tap(find.byType(AnimatedContainer));
      await tester.pumpAndSettle();

      expect(find.text('TW123456'), findsNothing);
      expect(find.text('user@tradewise.app'), findsNothing);

      await tester.tap(find.byType(AnimatedContainer));
      await tester.pumpAndSettle();

      expect(find.text('TW123456'), findsOneWidget);
      expect(find.text('user@tradewise.app'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('initial state is OFF in both themes', (tester) async {
      for (final ThemeMode mode in <ThemeMode>[
        ThemeMode.light,
        ThemeMode.dark,
      ]) {
        await pumpProfile(tester, themeMode: mode);

        expect(find.text('TW123456'), findsOneWidget);
        expect(find.text('user@tradewise.app'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('Menu rows', () {
    testWidgets('all six menu rows are present with correct icons', (
      tester,
    ) async {
      await pumpProfile(tester);

      expect(find.byType(ProfileMenuRow), findsNWidgets(6));
      expect(find.byIcon(Icons.currency_rupee), findsOneWidget);
      expect(find.text('Funds'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.text('App Code'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.byIcon(Icons.corporate_fare), findsOneWidget);
      expect(find.text('Connected apps'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Funds row shows its notice', (tester) async {
      await pumpProfile(tester);

      await tester.tap(find.text('Funds'));
      await tester.pumpAndSettle();

      expect(find.text('Funds are not available yet'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('App Code row shows its notice', (tester) async {
      await pumpProfile(tester);

      await tester.tap(find.text('App Code'));
      await tester.pumpAndSettle();

      expect(find.text('App Code are not available yet'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Profile row shows its notice', (tester) async {
      await pumpProfile(tester);

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      expect(
        find.text('Profile details are not available yet'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('Settings row shows its notice', (tester) async {
      await pumpProfile(tester);

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Settings are not available yet'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Connected apps row shows its notice', (tester) async {
      await pumpProfile(tester);

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -400),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Connected apps'));
      await tester.pumpAndSettle();

      expect(find.text('Connected apps are not available yet'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Logout row shows its notice', (tester) async {
      await pumpProfile(tester);

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(find.text('Logout are not available yet'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Interactions', () {
    testWidgets('notification bell shows temporary notice', (tester) async {
      await pumpProfile(tester);

      await tester.tap(find.byIcon(Icons.notifications_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Notifications are not available yet'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('market indices dropdown shows temporary notice', (
      tester,
    ) async {
      await pumpProfile(tester);

      await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
      await tester.pumpAndSettle();

      expect(find.text('Index details are not available yet'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Scrolling and viewport', () {
    testWidgets('content scrolls without overflow', (tester) async {
      await pumpProfile(tester);

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      expect(find.text('Logout'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('no overflow on narrow viewport (320px)', (tester) async {
      tester.view.physicalSize = const Size(640, 1136);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      await pumpProfile(tester);

      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.text('TradeWise User'), findsOneWidget);
      expect(find.text('Funds'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Bottom navigation integration', () {
    testWidgets('/profile route renders ProfileScreen with tab selected', (
      tester,
    ) async {
      final router = buildAppRouter(initialLocation: '/profile');
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            theme: TWTheme.light(),
            darkTheme: TWTheme.dark(),
            themeMode: ThemeMode.light,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.text('Profile'), findsWidgets);
      final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(bar.selectedIndex, 4);
      expect(tester.takeException(), isNull);
    });
  });
}
