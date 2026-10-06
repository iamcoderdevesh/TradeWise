import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tradewise/app/theme/tw_theme.dart';
import 'package:tradewise/features/watchlist/presentation/watchlist_screen.dart';
import 'package:tradewise/features/watchlist/presentation/widgets/instrument_bottom_sheet.dart';
import 'package:tradewise/features/watchlist/presentation/widgets/watchlist_preview_data.dart';

/// Pumps the Watchlist screen in the real app theme harness.
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

/// Taps the instrument row for [symbol] and settles the modal animation.
Future<void> openSheet(WidgetTester tester, String symbol) async {
  await tester.tap(find.text(symbol));
  await tester.pumpAndSettle();
}

/// Scrolls the sheet body until [target] is visible.
///
/// The sheet body is the [CustomScrollView] inside [InstrumentBottomSheet],
/// driven by the [DraggableScrollableSheet] controller — so the scroll must
/// run against that inner scrollable, not the Watchlist list behind the
/// barrier.
Future<void> scrollSheetTo(WidgetTester tester, Finder target) async {
  final Finder sheetBody = find.descendant(
    of: find.byType(InstrumentBottomSheet),
    matching: find.byType(Scrollable),
  );
  await tester.scrollUntilVisible(target, 200, scrollable: sheetBody);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('tapping a watchlist instrument opens the bottom sheet', (
    WidgetTester tester,
  ) async {
    await pumpWatchlist(tester);
    await openSheet(tester, 'TMPV');

    // Sheet-only controls prove the modal is open.
    expect(find.text('BUY'), findsOneWidget);
    expect(find.text('SELL'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sheet header shows symbol, exchange, price, change and pct', (
    WidgetTester tester,
  ) async {
    await pumpWatchlist(tester);
    await openSheet(tester, 'TMPV');

    // Each value appears in the row and again in the sheet header.
    expect(find.text('TMPV'), findsWidgets);
    expect(find.text('NSE'), findsWidgets);
    expect(find.text('279.40'), findsWidgets);
    expect(find.textContaining('-4.10'), findsWidgets);
    expect(find.textContaining('(-1.44%)'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('BUY reports a temporary notice', (WidgetTester tester) async {
    await pumpWatchlist(tester);
    await openSheet(tester, 'TMPV');

    await tester.tap(find.text('BUY'));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Buy is not available yet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('SELL reports a temporary notice', (WidgetTester tester) async {
    await pumpWatchlist(tester);
    await openSheet(tester, 'TMPV');

    await tester.tap(find.text('SELL'));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Sell is not available yet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('secondary actions exist and report temporary notices', (
    WidgetTester tester,
  ) async {
    await pumpWatchlist(tester);
    await openSheet(tester, 'TMPV');

    for (final label in [
      'View chart',
      'Option chain',
      'Set alert',
      'Add notes',
      'Create GTT',
    ]) {
      expect(find.text(label), findsOneWidget);
    }

    expect(find.text('Create GTT'), findsOneWidget);

    // Dismiss the open SnackBar before tapping again; otherwise the
    // tap would hit the still-visible SnackBar and open a queued one that
    // only animates in on later pumps.
    await tester.tap(find.text('View chart'));
    await tester.pump();
    expect(
      find.textContaining('View chart is not available yet'),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await scrollSheetTo(tester, find.text('Create GTT'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create GTT'));
    // Settle the full SnackBar entrance animation instead of a single pump.
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Create GTT is not available yet'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('market depth header, rows and totals render', (
    WidgetTester tester,
  ) async {
    await pumpWatchlist(tester);
    await openSheet(tester, 'TMPV');

    expect(find.text('Bid'), findsOneWidget);
    expect(find.text('Offer'), findsOneWidget);
    expect(find.text('Orders'), findsNWidgets(2));
    expect(find.text('Qty'), findsNWidgets(2));
    // 5 preview rows x 2 sides, all clearly placeholder zeros. The exact-text
    // match keeps the TAPARIA row behind the sheet ('0.00 (0.00%)') out of
    // scope while still proving all ten depth cells render.
    expect(find.text('0.00'), findsNWidgets(10));
    expect(find.text('Total'), findsNWidgets(2));
    expect(find.text('Show 20 depth'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Show 20 depth reports a temporary notice', (
    WidgetTester tester,
  ) async {
    await pumpWatchlist(tester);
    await openSheet(tester, 'TMPV');

    await scrollSheetTo(tester, find.text('Show 20 depth'));
    expect(find.text('Show 20 depth'), findsOneWidget);
    await tester.tap(find.text('Show 20 depth'));
    await tester.pump();
    expect(
      find.textContaining('20-level market depth is not available yet'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('sheet dismisses and the watchlist remains usable', (
    WidgetTester tester,
  ) async {
    await pumpWatchlist(tester);
    await openSheet(tester, 'TMPV');
    expect(find.text('BUY'), findsOneWidget);

    // Tap the modal barrier at the top-left corner, above the sheet.
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('BUY'), findsNothing);
    expect(find.text('SELL'), findsNothing);

    // The Watchlist is intact and can open the sheet for another row.
    await openSheet(tester, 'ONGC');
    expect(find.text('BUY'), findsOneWidget);
    expect(find.textContaining('222.37'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders in light theme without overflow', (
    WidgetTester tester,
  ) async {
    await pumpWatchlist(tester, themeMode: ThemeMode.light);
    await openSheet(tester, 'TMPV');
    expect(find.text('BUY'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders in dark theme without overflow', (
    WidgetTester tester,
  ) async {
    await pumpWatchlist(tester, themeMode: ThemeMode.dark);
    await openSheet(tester, 'TMPV');
    expect(find.text('BUY'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sheet fits and scrolls on a 360x800 viewport', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await pumpWatchlist(tester);
    await openSheet(tester, 'TMPV');
    expect(find.text('BUY'), findsOneWidget);
    await scrollSheetTo(tester, find.text('Show 20 depth'));
    expect(find.text('Show 20 depth'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sheet stays usable at 320x568 without overflow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await pumpWatchlist(tester);
    await openSheet(tester, 'TMPV');
    expect(find.text('BUY'), findsOneWidget);
    await scrollSheetTo(tester, find.text('Show 20 depth'));
    await tester.tap(find.text('Show 20 depth'));
    await tester.pump();
    expect(
      find.textContaining('20-level market depth is not available yet'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('header stays pinned while the body scrolls', (
    WidgetTester tester,
  ) async {
    await pumpWatchlist(tester);
    await openSheet(tester, 'TMPV');
    final headerBox = tester.getTopLeft(find.text('TMPV').last);
    await scrollSheetTo(tester, find.text('Show 20 depth'));
    final headerAfter = tester.getTopLeft(find.text('TMPV').last);
    expect((headerAfter.dy - headerBox.dy).abs(), lessThan(2.0));
    expect(find.text('Show 20 depth'), findsOneWidget);
    expect(find.text('BUY'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sheet is draggable-expandable with a bounded initial size', (
    WidgetTester tester,
  ) async {
    await pumpWatchlist(tester);
    await openSheet(tester, 'TMPV');
    final sheet = find.byType(DraggableScrollableSheet);
    expect(sheet, findsOneWidget);
    final dss = tester.widget<DraggableScrollableSheet>(sheet);
    expect(dss.initialChildSize, lessThan(dss.maxChildSize));
    expect(dss.minChildSize, lessThanOrEqualTo(dss.initialChildSize));
    await tester.drag(sheet, const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('TMPV'), findsWidgets);
    expect(find.text('BUY'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('sheet controls expose meaningful semantics', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    try {
      await pumpWatchlist(tester);
      await openSheet(tester, 'TMPV');
      await tester.pumpAndSettle();

      for (final label in ['BUY', 'SELL', 'Show 20 depth']) {
        expect(find.bySemanticsLabel(label), findsOneWidget);
      }
      for (final label in [
        'View chart',
        'Option chain',
        'Set alert',
        'Add notes',
        'Create GTT',
      ]) {
        expect(find.bySemanticsLabel(label), findsWidgets);
      }

      // Touch targets meet the 48dp minimum: measure the full tappable button
      // (not the bare label Text, whose line box is shorter).
      for (final label in ['BUY', 'SELL']) {
        final Size size = tester.getSize(find.bySemanticsLabel(label));
        expect(size.height, greaterThanOrEqualTo(48));
      }
      expect(find.byType(TextButton), findsWidgets);
      for (final label in ['View chart', 'Option chain', 'Add notes']) {
        final Finder button = find.ancestor(
          of: find.text(label),
          matching: find.byType(TextButton),
        );
        final Size size = tester.getSize(button);
        expect(size.height, greaterThanOrEqualTo(48));
        expect(size.width, greaterThanOrEqualTo(48));
      }
      expect(tester.takeException(), isNull);
    } finally {
      handle.dispose();
    }
  });
}
