import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tradewise/app/theme/tw_theme.dart';
import 'package:tradewise/features/watchlist/presentation/watchlist_screen.dart';
import 'package:tradewise/features/watchlist/presentation/widgets/watchlist_instrument_tile.dart';
import 'package:tradewise/features/watchlist/presentation/widgets/watchlist_preview_data.dart';
import 'package:tradewise/features/watchlist/presentation/widgets/watchlist_selector.dart';

Future<void> pumpWatchlist(
  WidgetTester tester, {
  List<WatchlistInstrument> instruments = kWatchlistPreviewMultiple,
  ThemeMode themeMode = ThemeMode.light,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: TWTheme.light(),
      darkTheme: TWTheme.dark(),
      themeMode: themeMode,
      home: Scaffold(body: WatchlistScreen(instruments: instruments)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('empty state renders title and helper', (tester) async {
    await pumpWatchlist(tester, instruments: kWatchlistPreviewEmpty);
    expect(find.text('Nothing here'), findsOneWidget);
    expect(find.textContaining('search bar'), findsOneWidget);
    expect(find.byType(WatchlistInstrumentTile), findsNothing);
    expect(find.text('0/250'), findsOneWidget);
  });

  testWidgets('single item renders one tile', (tester) async {
    await pumpWatchlist(tester, instruments: kWatchlistPreviewSingle);
    expect(find.byType(WatchlistInstrumentTile), findsOneWidget);
    expect(find.text('GOLDBEES'), findsOneWidget);
    expect(find.text('1/250'), findsOneWidget);
  });

  testWidgets('multiple items render and scroll', (tester) async {
    await pumpWatchlist(tester);
    // The list is lazy, so assert presence plus the whole-list counter, then
    // prove scrolling actually reaches the final row.
    expect(find.byType(WatchlistInstrumentTile), findsWidgets);
    expect(
      find.text('${kWatchlistPreviewMultiple.length}/250'),
      findsOneWidget,
    );
    expect(find.text('IDFCFIRSTB'), findsOneWidget);
    await tester.drag(
      find.byWidgetPredicate(
        (Widget w) => w is ListView && w.scrollDirection == Axis.vertical,
      ),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();
    expect(find.text('VEDL'), findsOneWidget);
  });

  testWidgets('row tap opens the instrument bottom sheet', (tester) async {
    await pumpWatchlist(tester, instruments: kWatchlistPreviewSingle);
    await tester.tap(find.text('GOLDBEES'));
    await tester.pumpAndSettle();
    expect(find.text('BUY'), findsOneWidget);
    expect(find.text('SELL'), findsOneWidget);
  });

  testWidgets('holding metadata renders when present', (tester) async {
    await pumpWatchlist(tester);
    expect(find.textContaining('10'), findsWidgets);
  });

  testWidgets('index strip renders both indices with grouped values', (
    tester,
  ) async {
    await pumpWatchlist(tester, instruments: kWatchlistPreviewEmpty);
    expect(find.text('NIFTY 50'), findsOneWidget);
    expect(find.text('NIFTY BANK'), findsOneWidget);
    expect(find.text('24,812.30'), findsOneWidget);
    expect(find.textContaining('(-0.42%)'), findsOneWidget);
  });

  testWidgets('instrument row groups thousands in the price', (tester) async {
    await pumpWatchlist(tester);
    expect(find.text('1,243.10'), findsOneWidget);
  });

  testWidgets('dark theme and small viewport safe', (tester) async {
    await pumpWatchlist(tester, themeMode: ThemeMode.dark);
    expect(tester.takeException(), isNull);
    tester.view.physicalSize = const Size(640, 1136);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
    await pumpWatchlist(tester, instruments: kWatchlistPreviewEmpty);
    expect(tester.takeException(), isNull);
  });

  group('Watchlist search filter', () {
    testWidgets('search by symbol filters instruments', (
      WidgetTester tester,
    ) async {
      await pumpWatchlist(tester);

      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'IDFC');
      await tester.pumpAndSettle();

      expect(find.text('IDFCFIRSTB'), findsOneWidget);
      expect(find.text('TAPARIA'), findsNothing);
      expect(find.text('TMPV'), findsNothing);
      expect(find.text('ONGC'), findsNothing);
    });

    testWidgets('search by exchange filters instruments', (
      WidgetTester tester,
    ) async {
      await pumpWatchlist(tester);

      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'BSE');
      await tester.pumpAndSettle();

      expect(find.text('TAPARIA'), findsOneWidget);
      expect(find.text('IDFCFIRSTB'), findsNothing);
      expect(find.text('TMPV'), findsNothing);
      expect(find.text('ONGC'), findsNothing);
    });

    testWidgets('search is case-insensitive', (WidgetTester tester) async {
      await pumpWatchlist(tester);

      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'idfcfirstb');
      await tester.pumpAndSettle();

      expect(find.text('IDFCFIRSTB'), findsOneWidget);
    });

    testWidgets('clearing search restores full watchlist', (
      WidgetTester tester,
    ) async {
      await pumpWatchlist(tester);

      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'IDFC');
      await tester.pumpAndSettle();
      expect(find.text('IDFCFIRSTB'), findsOneWidget);
      expect(find.text('TAPARIA'), findsNothing);

      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();

      expect(find.text('IDFCFIRSTB'), findsOneWidget);
      expect(find.text('TAPARIA'), findsOneWidget);
      expect(find.text('TMPV'), findsOneWidget);
    });

    testWidgets('total count preserved while filtering', (
      WidgetTester tester,
    ) async {
      await pumpWatchlist(tester);

      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'IDFC');
      await tester.pumpAndSettle();

      // Total count/capacity still shows full list count, not filtered count.
      expect(
        find.text('${kWatchlistPreviewMultiple.length}/250'),
        findsOneWidget,
      );
    });

    testWidgets('no matching results shows empty state', (
      WidgetTester tester,
    ) async {
      await pumpWatchlist(tester);

      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'ZZZZZ');
      await tester.pumpAndSettle();

      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.byType(WatchlistInstrumentTile), findsNothing);
    });
  });

  group('Watchlist swipe navigation', () {
    testWidgets('left swipe moves to next tab', (WidgetTester tester) async {
      await pumpWatchlist(tester);

      // Drag left on the tab selector (matching Portfolio's approach).
      await tester.drag(find.byType(WatchlistSelector), const Offset(-150, 0));
      await tester.pumpAndSettle();

      expect(find.text('Watchlist 2'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('right swipe moves to previous tab', (
      WidgetTester tester,
    ) async {
      await pumpWatchlist(tester);

      // Swipe left to Watchlist 2 first.
      await tester.drag(find.byType(WatchlistSelector), const Offset(-150, 0));
      await tester.pumpAndSettle();

      // Swipe right back to Watchlist 1.
      await tester.drag(find.byType(WatchlistSelector), const Offset(150, 0));
      await tester.pumpAndSettle();

      expect(find.text('Watchlist 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('left swipe on last tab stays on last tab', (
      WidgetTester tester,
    ) async {
      await pumpWatchlist(tester);

      // Swipe left twice to reach Watchlist 3 (last).
      await tester.drag(find.byType(WatchlistSelector), const Offset(-150, 0));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(WatchlistSelector), const Offset(-150, 0));
      await tester.pumpAndSettle();

      // Swipe left again — should stay on Watchlist 3.
      await tester.drag(find.byType(WatchlistSelector), const Offset(-150, 0));
      await tester.pumpAndSettle();

      expect(find.text('Watchlist 3'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('right swipe on first tab stays on first tab', (
      WidgetTester tester,
    ) async {
      await pumpWatchlist(tester);

      // Swipe right on first tab — should stay on Watchlist 1.
      await tester.drag(find.byType(WatchlistSelector), const Offset(150, 0));
      await tester.pumpAndSettle();

      expect(find.text('Watchlist 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('vertical scrolling still works with swipe gesture', (
      WidgetTester tester,
    ) async {
      await pumpWatchlist(tester);

      // Vertical drag should scroll the list, not switch tabs.
      await tester.drag(
        find.byWidgetPredicate(
          (Widget w) => w is ListView && w.scrollDirection == Axis.vertical,
        ),
        const Offset(0, -400),
      );
      await tester.pumpAndSettle();

      expect(find.text('VEDL'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('left swipe on list body moves to next tab', (
      WidgetTester tester,
    ) async {
      await pumpWatchlist(tester);

      // Drag left on the vertical ListView body to switch tabs.
      await tester.drag(
        find.byWidgetPredicate(
          (Widget w) => w is ListView && w.scrollDirection == Axis.vertical,
        ),
        const Offset(-150, 0),
      );
      await tester.pumpAndSettle();

      expect(find.text('Watchlist 2'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('right swipe on list body moves to previous tab', (
      WidgetTester tester,
    ) async {
      await pumpWatchlist(tester);

      // Swipe left to Watchlist 2 first via the body.
      await tester.drag(
        find.byWidgetPredicate(
          (Widget w) => w is ListView && w.scrollDirection == Axis.vertical,
        ),
        const Offset(-150, 0),
      );
      await tester.pumpAndSettle();
      expect(find.text('Watchlist 2'), findsOneWidget);

      // Swipe right on the body back to Watchlist 1.
      await tester.drag(
        find.byWidgetPredicate(
          (Widget w) => w is ListView && w.scrollDirection == Axis.vertical,
        ),
        const Offset(150, 0),
      );
      await tester.pumpAndSettle();

      expect(find.text('Watchlist 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('left swipe on list body respects last tab boundary', (
      WidgetTester tester,
    ) async {
      await pumpWatchlist(tester);

      // Swipe left twice on the body to reach Watchlist 3 (last).
      await tester.drag(
        find.byWidgetPredicate(
          (Widget w) => w is ListView && w.scrollDirection == Axis.vertical,
        ),
        const Offset(-150, 0),
      );
      await tester.pumpAndSettle();
      await tester.drag(
        find.byWidgetPredicate(
          (Widget w) => w is ListView && w.scrollDirection == Axis.vertical,
        ),
        const Offset(-150, 0),
      );
      await tester.pumpAndSettle();

      // Swipe left again — should stay on Watchlist 3.
      await tester.drag(
        find.byWidgetPredicate(
          (Widget w) => w is ListView && w.scrollDirection == Axis.vertical,
        ),
        const Offset(-150, 0),
      );
      await tester.pumpAndSettle();

      expect(find.text('Watchlist 3'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('right swipe on list body respects first tab boundary', (
      WidgetTester tester,
    ) async {
      await pumpWatchlist(tester);

      // Swipe right on the body on first tab — should stay on Watchlist 1.
      await tester.drag(
        find.byWidgetPredicate(
          (Widget w) => w is ListView && w.scrollDirection == Axis.vertical,
        ),
        const Offset(150, 0),
      );
      await tester.pumpAndSettle();

      expect(find.text('Watchlist 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
