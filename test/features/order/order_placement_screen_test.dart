import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tradewise/app/router/app_router.dart';
import 'package:tradewise/app/router/app_routes.dart';
import 'package:tradewise/app/theme/tw_colors.dart';
import 'package:tradewise/app/theme/tw_theme.dart';
import 'package:tradewise/features/order/presentation/order_enums.dart';
import 'package:tradewise/features/order/presentation/order_launch_args.dart';
import 'package:tradewise/features/order/presentation/order_placement_screen.dart';
import 'package:tradewise/features/order/presentation/widgets/swipe_to_confirm.dart';
import 'package:tradewise/features/order/presentation/widgets/order_quantity_section.dart';
import 'package:tradewise/features/order/presentation/widgets/price_type_section.dart';
import 'package:tradewise/features/portfolio/data/portfolio_entry.dart';
import 'package:tradewise/features/portfolio/presentation/portfolio_providers.dart';
import 'package:tradewise/features/portfolio/presentation/portfolio_screen.dart';
import 'package:tradewise/features/watchlist/presentation/watchlist_screen.dart';
import 'package:tradewise/features/watchlist/presentation/widgets/watchlist_preview_data.dart';

const WatchlistInstrument _instrument = WatchlistInstrument(
  symbol: 'IDFCFIRSTB',
  exchange: 'NSE',
  price: 80.39,
  change: -1.05,
  changePercent: -1.28,
);

/// An instrument with no seeded portfolio row, for sell-rejection paths.
const WatchlistInstrument _unheldInstrument = WatchlistInstrument(
  symbol: 'TAPARIA',
  exchange: 'BSE',
  price: 15.46,
  change: 0,
  changePercent: 0,
);

/// Pumps the real router at the order ticket with typed launch arguments.
Future<ProviderContainer> pumpOrder(
  WidgetTester tester, {
  OrderSide side = OrderSide.buy,
  ThemeMode themeMode = ThemeMode.light,
  WatchlistInstrument instrument = _instrument,
}) async {
  final router = buildAppRouter(initialLocation: AppRoutes.watchlist);
  addTearDown(router.dispose);
  final container = ProviderContainer();
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: TWTheme.light(),
        darkTheme: TWTheme.dark(),
        themeMode: themeMode,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
  router.push(
    AppRoutes.order,
    extra: OrderLaunchArgs(instrument: instrument, side: side),
  );
  await tester.pumpAndSettle();
  return container;
}

/// Pumps the order screen directly (no router) for focused state tests.
Future<ProviderContainer> pumpOrderDirect(
  WidgetTester tester, {
  OrderSide side = OrderSide.buy,
  ThemeMode themeMode = ThemeMode.light,
  WatchlistInstrument instrument = _instrument,
}) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: TWTheme.light(),
        darkTheme: TWTheme.dark(),
        themeMode: themeMode,
        home: Scaffold(
          body: OrderPlacementScreen(
            args: OrderLaunchArgs(instrument: instrument, side: side),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

/// Completes the swipe and lets the spring-back + SnackBar settle.
Future<void> fullSwipe(WidgetTester tester) async {
  final Finder swipe = find.byType(SwipeToConfirm);
  // Drag the full track width so the gesture always clears the 80%
  // completion threshold regardless of the test viewport size.
  final double width = tester.getSize(swipe).width;
  await tester.drag(swipe, Offset(width, 0));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('buy ticket shows symbol, side styling and estimate', (
    WidgetTester tester,
  ) async {
    await pumpOrder(tester, side: OrderSide.buy);

    expect(find.text('IDFCFIRSTB'), findsOneWidget);
    expect(find.text('NSE'), findsOneWidget);
    expect(find.textContaining('80.39'), findsWidgets);
    expect(find.text('SWIPE TO BUY'), findsOneWidget);
    // Default draft: quantity 1 × LTP 80.39.
    expect(find.textContaining('₹80.39'), findsWidgets);
    expect(find.text('Longterm'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sell ticket uses the semantic negative accent', (
    WidgetTester tester,
  ) async {
    await pumpOrder(tester, side: OrderSide.sell);

    expect(find.text('SWIPE TO SELL'), findsOneWidget);
    final swipe = tester.widget<SwipeToConfirm>(find.byType(SwipeToConfirm));
    expect(swipe.accent, TWColors.lightNegative);
    expect(swipe.onAccent, TWColors.lightOnNegative);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sell ticket resolves dark negative tokens in dark theme', (
    WidgetTester tester,
  ) async {
    await pumpOrder(tester, side: OrderSide.sell, themeMode: ThemeMode.dark);

    final swipe = tester.widget<SwipeToConfirm>(find.byType(SwipeToConfirm));
    expect(swipe.accent, TWColors.darkNegative);
    expect(swipe.onAccent, TWColors.darkOnNegative);
    expect(tester.takeException(), isNull);
  });

  testWidgets('back navigation returns to the watchlist', (
    WidgetTester tester,
  ) async {
    await pumpOrder(tester, side: OrderSide.buy);

    expect(find.text('IDFCFIRSTB'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.byType(WatchlistScreen), findsOneWidget);
    expect(find.text('SWIPE TO BUY'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bottom-sheet BUY opens the buy ticket', (
    WidgetTester tester,
  ) async {
    final router = buildAppRouter(initialLocation: AppRoutes.watchlist);
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

    await tester.tap(find.text('IDFCFIRSTB'));
    await tester.pumpAndSettle();
    expect(find.text('BUY'), findsOneWidget);

    await tester.tap(find.text('BUY'));
    await tester.pumpAndSettle();

    expect(find.text('SWIPE TO BUY'), findsOneWidget);
    expect(find.text('SWIPE TO SELL'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bottom-sheet SELL opens the sell ticket', (
    WidgetTester tester,
  ) async {
    final router = buildAppRouter(initialLocation: AppRoutes.watchlist);
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

    await tester.tap(find.text('IDFCFIRSTB'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SELL'));
    await tester.pumpAndSettle();

    expect(find.text('SWIPE TO SELL'), findsOneWidget);
    expect(find.text('SWIPE TO BUY'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('missing route arguments fall back to the watchlist', (
    WidgetTester tester,
  ) async {
    final router = buildAppRouter(initialLocation: AppRoutes.watchlist);
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

    router.go(AppRoutes.order);
    await tester.pumpAndSettle();

    expect(find.byType(OrderPlacementScreen), findsNothing);
    expect(find.byType(WatchlistScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('market shows the disabled hatched price field', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    try {
      await pumpOrderDirect(tester);

      // The Market state renders a non-editable hatched field with a muted
      // 0.00 placeholder — only the quantity input is an editable TextField.
      // (The field also carries a descriptive semantics label for assistive
      // technology; that is verified in the widget, not via a finder, since a
      // bare container-semantics node has no widget mapping.)
      expect(find.text('0.00'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(1));
      // The tappable label row names the current type.
      expect(find.bySemanticsLabel('Market'), findsOneWidget);
      expect(tester.takeException(), isNull);
    } finally {
      handle.dispose();
    }
  });

  testWidgets('switching to limit via label seeds price from LTP', (
    WidgetTester tester,
  ) async {
    await pumpOrderDirect(tester);

    // Tap the tappable "Market" label row to toggle to Limit.
    await tester.tap(find.bySemanticsLabel('Market'));
    await tester.pumpAndSettle();

    expect(find.text('0.00'), findsNothing);
    final Finder priceField = find.descendant(
      of: find.byType(PriceTypeSection),
      matching: find.byType(TextField),
    );
    expect(priceField, findsOneWidget);
    expect(tester.widget<TextField>(priceField).controller?.text, '80.39');
    expect(tester.takeException(), isNull);
  });

  testWidgets('swap segment cycles Market → Limit → Stop Loss → Market', (
    WidgetTester tester,
  ) async {
    await pumpOrderDirect(tester);

    // The connected price box's swap segment is the reference's second
    // affordance alongside the label row; both advance the same cycle.
    await tester.tap(find.byTooltip('Switch to limit order'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Limit'), findsOneWidget);
    expect(find.byTooltip('Switch to stop loss order'), findsOneWidget);

    await tester.tap(find.byTooltip('Switch to stop loss order'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Stop Loss'), findsOneWidget);
    expect(find.text('0.00'), findsNothing);
    expect(find.byTooltip('Switch to market order'), findsOneWidget);

    await tester.tap(find.byTooltip('Switch to market order'));
    await tester.pumpAndSettle();
    expect(find.text('0.00'), findsOneWidget);
    expect(find.bySemanticsLabel('Market'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('label row advances the same three-mode cycle', (
    WidgetTester tester,
  ) async {
    await pumpOrderDirect(tester);

    await tester.tap(find.bySemanticsLabel('Market'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Limit'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Limit'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Stop Loss'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Stop Loss'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Market'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('limit estimate follows the entered price', (
    WidgetTester tester,
  ) async {
    await pumpOrderDirect(tester);

    await tester.tap(find.bySemanticsLabel('Market'));
    await tester.pump();
    final Finder priceField = find.descendant(
      of: find.byType(PriceTypeSection),
      matching: find.byType(TextField),
    );
    await tester.enterText(priceField, '80');
    await tester.pump();

    // Quantity 1 × ₹80.00 rendered by the estimate band: the entered limit
    // price drives it (the displayed LTP is 80.39, so this value cannot
    // come from the quote).
    expect(find.text('₹80.00'), findsOneWidget);
    expect(find.text('Avail.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('stop loss seeds from LTP and drives the estimate', (
    WidgetTester tester,
  ) async {
    await pumpOrderDirect(tester);

    // Market → Limit → Stop Loss through the swap segments.
    await tester.tap(find.byTooltip('Switch to limit order'));
    await tester.pump();
    await tester.tap(find.byTooltip('Switch to stop loss order'));
    await tester.pump();

    // The Stop Loss field opens editable, seeded from the displayed LTP.
    final Finder priceField = find.descendant(
      of: find.byType(PriceTypeSection),
      matching: find.byType(TextField),
    );
    expect(priceField, findsOneWidget);
    expect(tester.widget<TextField>(priceField).controller?.text, '80.39');
    // The band previews at the seeded LTP: qty 1 × ₹80.39.
    expect(find.textContaining('₹80.39'), findsWidgets);
    expect(find.text('Avail.'), findsOneWidget);

    await tester.enterText(priceField, '70');
    await tester.pump();

    // Quantity 1 × ₹70.00 at the entered stop loss price.
    expect(find.textContaining('₹70.00'), findsWidgets);
    expect(
      tester.widget<SwipeToConfirm>(find.byType(SwipeToConfirm)).enabled,
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('typed limit and stop loss prices survive mode switching', (
    WidgetTester tester,
  ) async {
    await pumpOrderDirect(tester);

    // Market → Limit: type a price, then advance to Stop Loss and type one.
    await tester.tap(find.bySemanticsLabel('Market'));
    await tester.pump();
    final Finder priceField = find.descendant(
      of: find.byType(PriceTypeSection),
      matching: find.byType(TextField),
    );
    await tester.enterText(priceField, '10');
    await tester.pump();

    await tester.tap(find.byTooltip('Switch to stop loss order'));
    await tester.pump();
    await tester.enterText(priceField, '70');
    await tester.pump();
    expect(find.textContaining('₹70.00'), findsWidgets);

    // Back through Market to Limit: the typed ₹10 is still there, so the
    // estimate returns to it instead of the LTP seed.
    await tester.tap(find.byTooltip('Switch to market order'));
    await tester.pumpAndSettle();
    expect(find.text('0.00'), findsOneWidget);
    expect(find.textContaining('₹80.39'), findsWidgets);

    await tester.tap(find.bySemanticsLabel('Market'));
    await tester.pump();
    expect(tester.widget<TextField>(priceField).controller?.text, '10');
    expect(find.textContaining('₹10.00'), findsWidgets);

    // And the typed ₹70 is still waiting in Stop Loss.
    await tester.tap(find.byTooltip('Switch to stop loss order'));
    await tester.pump();
    expect(tester.widget<TextField>(priceField).controller?.text, '70');
    expect(find.textContaining('₹70.00'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an emptied editable price reseeds from LTP on revisit', (
    WidgetTester tester,
  ) async {
    await pumpOrderDirect(tester);

    // Market → Limit → Stop Loss through the swap segments.
    await tester.tap(find.byTooltip('Switch to limit order'));
    await tester.pump();
    await tester.tap(find.byTooltip('Switch to stop loss order'));
    await tester.pump();
    final Finder priceField = find.descendant(
      of: find.byType(PriceTypeSection),
      matching: find.byType(TextField),
    );
    await tester.enterText(priceField, '');
    await tester.pump();

    // Empty price: nothing to preview, and the control is guarded off.
    expect(
      tester.widget<SwipeToConfirm>(find.byType(SwipeToConfirm)).enabled,
      isFalse,
    );
    expect(
      find.text('Enter a valid quantity and price to see the estimated amount'),
      findsOneWidget,
    );

    // Leave and revisit: the empty field reseeds from the displayed LTP.
    await tester.tap(find.byTooltip('Switch to market order'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Switch to limit order'));
    await tester.pump();
    await tester.tap(find.byTooltip('Switch to stop loss order'));
    await tester.pump();
    expect(tester.widget<TextField>(priceField).controller?.text, '80.39');
    expect(tester.takeException(), isNull);
  });

  testWidgets('invalid stop loss prices disable the preview control', (
    WidgetTester tester,
  ) async {
    await pumpOrderDirect(tester);

    // Market → Limit → Stop Loss through the swap segments.
    await tester.tap(find.byTooltip('Switch to limit order'));
    await tester.pump();
    await tester.tap(find.byTooltip('Switch to stop loss order'));
    await tester.pump();
    final Finder priceField = find.descendant(
      of: find.byType(PriceTypeSection),
      matching: find.byType(TextField),
    );

    for (final String bad in <String>['0', '-5', 'abc']) {
      await tester.enterText(priceField, bad);
      await tester.pump();
      expect(
        tester.widget<SwipeToConfirm>(find.byType(SwipeToConfirm)).enabled,
        isFalse,
        reason: 'stop loss price "$bad" must not enable the control',
      );
    }

    // A valid price re-enables the control.
    await tester.enterText(priceField, '70');
    await tester.pump();
    expect(
      tester.widget<SwipeToConfirm>(find.byType(SwipeToConfirm)).enabled,
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('switching back to market clears the limit price', (
    WidgetTester tester,
  ) async {
    await pumpOrderDirect(tester);

    await tester.tap(find.bySemanticsLabel('Market'));
    await tester.pump();
    final Finder priceField = find.descendant(
      of: find.byType(PriceTypeSection),
      matching: find.byType(TextField),
    );
    await tester.enterText(priceField, '10');
    await tester.pump();
    // Limit → Stop Loss → Market through the swap segments.
    await tester.ensureVisible(find.byTooltip('Switch to stop loss order'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Switch to stop loss order'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('Switch to market order'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Switch to market order'));
    await tester.pumpAndSettle();

    expect(find.text('0.00'), findsOneWidget);
    // Estimate returns to the LTP basis, not the entered ₹10.
    expect(find.textContaining('₹80.39'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('quantity drives the estimate', (WidgetTester tester) async {
    await pumpOrderDirect(tester);

    final Finder quantityField = find.descendant(
      of: find.byType(OrderQuantitySection),
      matching: find.byType(TextField),
    );
    await tester.enterText(quantityField, '10');
    await tester.pump();

    // 10 × ₹80.39 = ₹803.90.
    expect(find.textContaining('₹803.90'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('amount mode derives a floored whole-share quantity', (
    WidgetTester tester,
  ) async {
    await pumpOrderDirect(tester);

    await tester.tap(find.byTooltip('Switch to amount input'));
    await tester.pump();
    final Finder amountField = find.descendant(
      of: find.byType(OrderQuantitySection),
      matching: find.byType(TextField),
    );
    await tester.enterText(amountField, '1000');
    await tester.pump();

    // ₹1000 at ₹80.39 → 12 whole shares, never fractional.
    expect(find.text('12 Qty.'), findsOneWidget);
    expect(find.textContaining('₹964.68'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an amount below one share shows zero quantity', (
    WidgetTester tester,
  ) async {
    await pumpOrderDirect(tester);

    await tester.tap(find.byTooltip('Switch to amount input'));
    await tester.pump();
    final Finder amountField = find.descendant(
      of: find.byType(OrderQuantitySection),
      matching: find.byType(TextField),
    );
    await tester.enterText(amountField, '50');
    await tester.pump();

    expect(find.text('0 Qty.'), findsOneWidget);
    expect(
      find.text('Enter a valid quantity and price to see the estimated amount'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('switching back to quantity seeds the derived value', (
    WidgetTester tester,
  ) async {
    await pumpOrderDirect(tester);

    await tester.tap(find.byTooltip('Switch to amount input'));
    await tester.pump();
    final Finder amountField = find.descendant(
      of: find.byType(OrderQuantitySection),
      matching: find.byType(TextField),
    );
    await tester.enterText(amountField, '1000');
    await tester.pump();
    await tester.tap(find.byTooltip('Switch to quantity input'));
    await tester.pump();

    final Finder quantityField = find.descendant(
      of: find.byType(OrderQuantitySection),
      matching: find.byType(TextField),
    );
    expect(tester.widget<TextField>(quantityField).controller?.text, '12');
    expect(tester.takeException(), isNull);
  });

  testWidgets('product defaults to longterm and switches to intraday', (
    WidgetTester tester,
  ) async {
    await pumpOrderDirect(tester);

    await tester.tap(find.text('Intraday'));
    await tester.pump();

    // Selection is visual-only local state; the control stays consistent.
    expect(find.text('Intraday'), findsOneWidget);
    expect(find.text('Longterm'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty quantity disables the preview control', (
    WidgetTester tester,
  ) async {
    await pumpOrderDirect(tester);

    final Finder quantityField = find.descendant(
      of: find.byType(OrderQuantitySection),
      matching: find.byType(TextField),
    );
    await tester.enterText(quantityField, '');
    await tester.pump();

    final swipe = tester.widget<SwipeToConfirm>(find.byType(SwipeToConfirm));
    expect(swipe.enabled, isFalse);
    expect(
      find.text('Enter a valid quantity and price to see the estimated amount'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('tap on the swipe control never fills', (
    WidgetTester tester,
  ) async {
    await pumpOrderDirect(tester);

    await tester.tap(find.text('SWIPE TO BUY'));
    await tester.pump();

    expect(find.byType(SnackBar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('full swipe fills a paper BUY once and springs back', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = await pumpOrderDirect(tester);

    final Finder swipe = find.byType(SwipeToConfirm);
    // Drag the full track width so the gesture always clears the 80%
    // completion threshold regardless of the test viewport size.
    final double width = tester.getSize(swipe).width;
    await tester.drag(swipe, Offset(width, 0));
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.text('Paper order filled: 1 × IDFCFIRSTB added to Holdings'),
      findsOneWidget,
    );
    // The default longterm draft merged into the seeded holding.
    final PortfolioState state = container.read(portfolioProvider);
    expect(
      state.holdings
          .firstWhere((PortfolioEntry e) => e.symbol == 'IDFCFIRSTB')
          .quantity,
      11,
    );
    // Let the spring-back timer settle the thumb at rest, then let the
    // SnackBar time out so it cannot cover the track for the second drag.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);

    // Reset: a second swipe fills again exactly once (11 + 1).
    await tester.drag(swipe, Offset(width, 0));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(
      container
          .read(portfolioProvider)
          .holdings
          .firstWhere((PortfolioEntry e) => e.symbol == 'IDFCFIRSTB')
          .quantity,
      12,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('short swipe does not fill', (WidgetTester tester) async {
    await pumpOrderDirect(tester);

    await tester.drag(find.byType(SwipeToConfirm), const Offset(20, 0));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsNothing);
    // The spring-back timer from drag end must expire cleanly.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('semantic activation fills without a drag', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    try {
      await pumpOrderDirect(tester);

      final Finder swipe = find.bySemanticsLabel('SWIPE TO BUY');
      expect(swipe, findsOneWidget);
      // The accessible activation path: dispatch the semantic tap action
      // exactly as assistive technology would — no pointer drag involved.
      final SemanticsNode node = tester.getSemantics(swipe);
      final SemanticsOwner? owner =
          RendererBinding.instance.renderViews.first.owner?.semanticsOwner;
      expect(owner, isNotNull);
      owner!.performAction(node.id, SemanticsAction.tap);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Paper order filled: 1 × IDFCFIRSTB added to Holdings'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    } finally {
      handle.dispose();
    }
  });

  testWidgets('controls meet touch and semantics expectations', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    try {
      await pumpOrderDirect(tester);

      // Only the active type label exists at a time (Market initially).
      for (final label in ['Market', 'SWIPE TO BUY']) {
        expect(find.bySemanticsLabel(label), findsWidgets);
      }
      // The tappable Market label row keeps a ≥48dp target.
      final Size marketSize = tester.getSize(find.bySemanticsLabel('Market'));
      expect(marketSize.height, greaterThanOrEqualTo(48));
      // The Stop Loss label row keeps the same target once active.
      await tester.tap(find.bySemanticsLabel('Market'));
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Limit'));
      await tester.pump();
      expect(find.bySemanticsLabel('Stop Loss'), findsOneWidget);
      final Size stopLossSize = tester.getSize(
        find.bySemanticsLabel('Stop Loss'),
      );
      expect(stopLossSize.height, greaterThanOrEqualTo(48));
      // The swap control's accessible name comes from its tooltip.
      final Finder swap = find.byTooltip('Switch to amount input');
      expect(swap, findsOneWidget);
      final Size swapSize = tester.getSize(swap);
      expect(swapSize.height, greaterThanOrEqualTo(48));
      expect(swapSize.width, greaterThanOrEqualTo(48));
      final Size swipeSize = tester.getSize(
        find.bySemanticsLabel('SWIPE TO BUY'),
      );
      expect(swipeSize.height, greaterThanOrEqualTo(48));
      expect(tester.takeException(), isNull);
    } finally {
      handle.dispose();
    }
  });

  testWidgets('estimate band renders directly above the swipe control', (
    WidgetTester tester,
  ) async {
    await pumpOrderDirect(tester);

    // The reference anchors the info band immediately above the CTA.
    final Finder estimate = find.text('Amount');
    expect(estimate, findsOneWidget);
    final double estimateBottom = tester.getBottomRight(estimate).dy;
    final double swipeTop = tester.getTopLeft(find.byType(SwipeToConfirm)).dy;
    expect(estimateBottom, lessThanOrEqualTo(swipeTop));
    expect(tester.takeException(), isNull);
  });

  testWidgets('CTA is not pushed up by a doubled keyboard inset', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(640, 1000);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
    // Simulate a keyboard covering the lower part of the screen (logical px).
    tester.view.viewInsets = const FakeViewPadding(bottom: 200);
    addTearDown(tester.view.reset);

    await pumpOrderDirect(tester);

    // With resizeToAvoidBottomInset, the Scaffold already insets the body
    // above the keyboard. The CTA must sit just above it — not float near the
    // top from a second, manual inset. (FakeViewPadding is in physical px.)
    final double dpr = tester.view.devicePixelRatio;
    final double screenHeight = tester.view.physicalSize.height / dpr;
    final double keyboardLogical = 200 / dpr;
    final double keyboardTop = screenHeight - keyboardLogical;
    final double swipeBottom = tester
        .getBottomRight(find.byType(SwipeToConfirm))
        .dy;
    // CTA bottom is just above the keyboard top (its own bottom padding of
    // slack). A doubled inset would push it a full keyboard higher.
    expect(swipeBottom, lessThanOrEqualTo(keyboardTop));
    expect(swipeBottom, greaterThan(keyboardTop - 60));
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders in dark theme without overflow', (
    WidgetTester tester,
  ) async {
    await pumpOrderDirect(tester, themeMode: ThemeMode.dark);

    expect(find.text('IDFCFIRSTB'), findsOneWidget);
    expect(find.text('SWIPE TO BUY'), findsOneWidget);
    // The hatched Market field and the Stop Loss field both render in dark.
    expect(find.text('0.00'), findsOneWidget);
    await tester.tap(find.byTooltip('Switch to limit order'));
    await tester.pump();
    await tester.tap(find.byTooltip('Switch to stop loss order'));
    await tester.pump();
    expect(find.bySemanticsLabel('Stop Loss'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('small viewport does not overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(640, 900);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
    await pumpOrderDirect(tester);

    expect(find.text('SWIPE TO BUY'), findsOneWidget);
    // The longer Stop Loss label and the whole estimate band must not
    // overflow either.
    await tester.ensureVisible(find.byTooltip('Switch to limit order'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Switch to limit order'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('Switch to stop loss order'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Switch to stop loss order'));
    await tester.pump();
    expect(find.bySemanticsLabel('Stop Loss'), findsOneWidget);
    expect(find.text('Amount'), findsOneWidget);
    expect(find.text('Avail.'), findsOneWidget);
    expect(find.text('SWIPE TO BUY'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group('paper-trade portfolio integration', () {
    testWidgets('BUY fill navigates to Portfolio Holdings tab', (
      WidgetTester tester,
    ) async {
      final ProviderContainer container = await pumpOrder(tester);
      await fullSwipe(tester);

      // Filled BUY lands on Portfolio with the Holdings tab active.
      expect(find.byType(PortfolioScreen), findsOneWidget);
      expect(find.text('Holdings'), findsOneWidget);
      expect(
        container
            .read(portfolioProvider)
            .holdings
            .firstWhere((PortfolioEntry e) => e.symbol == 'IDFCFIRSTB')
            .quantity,
        11,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('intraday BUY fill navigates to the Positions tab', (
      WidgetTester tester,
    ) async {
      final ProviderContainer container = await pumpOrder(tester);

      await tester.tap(find.text('Intraday'));
      await tester.pumpAndSettle();
      await fullSwipe(tester);

      expect(find.byType(PortfolioScreen), findsOneWidget);
      final PortfolioState state = container.read(portfolioProvider);
      expect(state.selectedTab, PortfolioTab.positions);
      // No seeded holding for IDFCFIRSTB under intraday; the BUY appended
      // a new position entry.
      expect(
        state.positions
            .firstWhere((PortfolioEntry e) => e.symbol == 'IDFCFIRSTB')
            .quantity,
        1,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('SELL fill reduces the holding in place', (
      WidgetTester tester,
    ) async {
      final ProviderContainer container = await pumpOrderDirect(
        tester,
        side: OrderSide.sell,
      );
      await fullSwipe(tester);

      // SELL stays on the order screen; only the portfolio state changes.
      expect(find.byType(PortfolioScreen), findsNothing);
      expect(
        find.text('Paper order filled: sold 1 × IDFCFIRSTB'),
        findsOneWidget,
      );
      final PortfolioEntry updated = container
          .read(portfolioProvider)
          .holdings
          .firstWhere((PortfolioEntry e) => e.symbol == 'IDFCFIRSTB');
      expect(updated.quantity, 9);
      expect(tester.takeException(), isNull);
    });

    testWidgets('SELL of an unheld symbol is rejected with a notice', (
      WidgetTester tester,
    ) async {
      final ProviderContainer container = await pumpOrderDirect(
        tester,
        side: OrderSide.sell,
        instrument: _unheldInstrument,
      );
      await fullSwipe(tester);

      expect(
        find.text('Sell order rejected: no holding for TAPARIA'),
        findsOneWidget,
      );
      // State untouched.
      expect(
        container
            .read(portfolioProvider)
            .holdings
            .any((PortfolioEntry e) => e.symbol == 'TAPARIA'),
        isFalse,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('SELL of the full holding closes the entry', (
      WidgetTester tester,
    ) async {
      final ProviderContainer container = await pumpOrderDirect(
        tester,
        side: OrderSide.sell,
      );

      // Sell the whole seeded position: 10 @ avg 64.70, LTP 80.39.
      final Finder quantityField = find.descendant(
        of: find.byType(OrderQuantitySection),
        matching: find.byType(TextField),
      );
      await tester.enterText(quantityField, '10');
      await tester.pump();
      await fullSwipe(tester);

      expect(
        find.text('Paper order filled: sold 10 × IDFCFIRSTB'),
        findsOneWidget,
      );
      final PortfolioEntry updated = container
          .read(portfolioProvider)
          .holdings
          .firstWhere((PortfolioEntry e) => e.symbol == 'IDFCFIRSTB');
      expect(updated.quantity, 0);
      expect(updated.isClosed, isTrue);
      // (80.39 − 64.70) × 10 = 156.90 realised.
      expect(updated.realizedPnl, closeTo(156.90, 0.0001));
      expect(tester.takeException(), isNull);
    });
  });
}
