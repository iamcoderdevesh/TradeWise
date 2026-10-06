import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tradewise/app/theme/tw_theme.dart';
import 'package:tradewise/features/watchlist/presentation/watchlist_screen.dart';
import 'package:tradewise/features/watchlist/presentation/widgets/watchlist_instrument_tile.dart';
import 'package:tradewise/features/watchlist/presentation/widgets/watchlist_preview_data.dart';

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
}
