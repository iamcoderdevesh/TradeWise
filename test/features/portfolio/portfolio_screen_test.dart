import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tradewise/app/theme/tw_theme.dart';
import 'package:tradewise/features/portfolio/data/portfolio_entry.dart';
import 'package:tradewise/features/portfolio/data/portfolio_preview_data.dart';
import 'package:tradewise/features/portfolio/data/portfolio_repository.dart';
import 'package:tradewise/features/portfolio/presentation/portfolio_providers.dart';
import 'package:tradewise/features/portfolio/presentation/portfolio_screen.dart';
import 'package:tradewise/features/portfolio/presentation/widgets/portfolio_empty_state.dart';
import 'package:tradewise/features/portfolio/presentation/widgets/portfolio_total_pnl_card.dart';
import 'package:tradewise/features/portfolio/presentation/widgets/portfolio_toolbar.dart';

Future<ProviderContainer> pumpPortfolio(
  WidgetTester tester, {
  ThemeMode themeMode = ThemeMode.light,
  List<PortfolioEntry> holdings = kPreviewHoldings,
  List<PortfolioEntry> positions = kPreviewPositions,
}) async {
  final ProviderContainer container = ProviderContainer(
    overrides: [
      portfolioRepositoryProvider.overrideWith(
        (Ref ref) =>
            MockPortfolioRepository(holdings: holdings, positions: positions),
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
        home: const PortfolioScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('holdings tab shows rows, counts and total P&L', (
    WidgetTester tester,
  ) async {
    await pumpPortfolio(tester);

    expect(find.text('Portfolio'), findsOneWidget);
    expect(find.text('Holdings'), findsOneWidget);
    expect(find.text('Positions'), findsOneWidget);
    expect(find.text('Total P&L'), findsOneWidget);
    // 22.50 + 280.00 from the seeded holdings.
    expect(find.text('+302.50'), findsOneWidget);
    // Seeded rows with qty/avg/P&L/LTP.
    expect(find.text('IDFCFIRSTB'), findsOneWidget);
    expect(find.text('TATASTEEL'), findsOneWidget);
    expect(find.text('HOLDING'), findsNWidgets(2));
    // Closed section belongs to the Positions tab only in the seed data.
    expect(find.text('Closed'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('positions tab shows open rows plus the Closed section', (
    WidgetTester tester,
  ) async {
    await pumpPortfolio(tester);

    await tester.tap(find.text('Positions'));
    await tester.pumpAndSettle();

    expect(find.text('HCLTECH'), findsOneWidget);
    expect(find.text('ONGC'), findsOneWidget);
    expect(find.text('Closed'), findsOneWidget);
    expect(find.text('VEDL'), findsOneWidget);
    // 662 + (-218.50) + 41.00.
    expect(find.text('+484.50'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('swiping left switches Holdings to Positions', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = await pumpPortfolio(tester);

    // Holdings is the initial tab; the Positions page is not rendered yet.
    expect(
      container.read(portfolioProvider).selectedTab,
      PortfolioTab.holdings,
    );
    expect(find.text('IDFCFIRSTB'), findsOneWidget);
    expect(find.text('HCLTECH'), findsNothing);

    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();

    // The swipe selects Positions: the indicator, Total P&L and content follow.
    expect(
      container.read(portfolioProvider).selectedTab,
      PortfolioTab.positions,
    );
    expect(find.text('HCLTECH'), findsOneWidget);
    expect(find.text('ONGC'), findsOneWidget);
    expect(find.text('+484.50'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('swiping right switches Positions to Holdings', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = await pumpPortfolio(tester);

    await tester.tap(find.text('Positions'));
    await tester.pumpAndSettle();
    expect(
      container.read(portfolioProvider).selectedTab,
      PortfolioTab.positions,
    );

    await tester.drag(find.byType(PageView), const Offset(500, 0));
    await tester.pumpAndSettle();

    // The swipe selects Holdings: the indicator, Total P&L and content follow.
    expect(
      container.read(portfolioProvider).selectedTab,
      PortfolioTab.holdings,
    );
    expect(find.text('IDFCFIRSTB'), findsOneWidget);
    expect(find.text('TATASTEEL'), findsOneWidget);
    expect(find.text('+302.50'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty portfolio renders both tab empty states', (
    WidgetTester tester,
  ) async {
    await pumpPortfolio(tester, holdings: const [], positions: const []);

    // No rows means no Total P&L card (reference empty state).
    expect(find.byType(PortfolioTotalPnlCard), findsNothing);
    expect(find.byType(PortfolioEmptyState), findsOneWidget);
    expect(find.text('No holdings'), findsOneWidget);
    expect(find.text('Place an order from your watchlist'), findsOneWidget);

    await tester.tap(find.text('Positions'));
    await tester.pumpAndSettle();
    expect(find.text('No positions'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('toolbar actions and analytics FAB report notices', (
    WidgetTester tester,
  ) async {
    await pumpPortfolio(tester);

    await tester.tap(find.byTooltip('Search portfolio'));
    await tester.pumpAndSettle();
    expect(find.text('Search is not available yet'), findsOneWidget);

    await tester.tap(find.byTooltip('Portfolio filters'));
    await tester.pumpAndSettle();
    expect(find.text('Filters are not available yet'), findsOneWidget);

    await tester.tap(find.text('Group'));
    await tester.pumpAndSettle();
    expect(find.text('Grouping is not available yet'), findsOneWidget);

    await tester.tap(find.text('P&L'));
    await tester.pumpAndSettle();
    expect(find.text('P&L charts are not available yet'), findsOneWidget);

    await tester.tap(find.byTooltip('Portfolio analytics'));
    await tester.pumpAndSettle();
    expect(
      find.text('Portfolio analytics are not available yet'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders in dark theme without overflow', (
    WidgetTester tester,
  ) async {
    await pumpPortfolio(tester, themeMode: ThemeMode.dark);

    expect(find.text('IDFCFIRSTB'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('constrained viewport does not overflow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(640, 1000);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await pumpPortfolio(tester);
    expect(find.text('Portfolio'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Positions'));
    await tester.pumpAndSettle();
    expect(find.text('Closed'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('swiping left on the Total P&L card switches to Positions', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = await pumpPortfolio(tester);

    expect(find.byType(PortfolioTotalPnlCard), findsOneWidget);
    expect(
      container.read(portfolioProvider).selectedTab,
      PortfolioTab.holdings,
    );
    expect(find.text('HCLTECH'), findsNothing);

    await tester.drag(
      find.byType(PortfolioTotalPnlCard),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();

    expect(
      container.read(portfolioProvider).selectedTab,
      PortfolioTab.positions,
    );
    expect(find.text('HCLTECH'), findsOneWidget);
    expect(find.text('Closed'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('swiping right on the Total P&L card switches to Holdings', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = await pumpPortfolio(tester);

    await tester.tap(find.text('Positions'));
    await tester.pumpAndSettle();
    expect(
      container.read(portfolioProvider).selectedTab,
      PortfolioTab.positions,
    );

    await tester.drag(find.byType(PortfolioTotalPnlCard), const Offset(500, 0));
    await tester.pumpAndSettle();

    expect(
      container.read(portfolioProvider).selectedTab,
      PortfolioTab.holdings,
    );
    expect(find.text('IDFCFIRSTB'), findsOneWidget);
    expect(find.text('TATASTEEL'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('swiping left on the Filters toolbar switches to Positions', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = await pumpPortfolio(tester);

    expect(find.byType(PortfolioToolbar), findsOneWidget);
    expect(
      container.read(portfolioProvider).selectedTab,
      PortfolioTab.holdings,
    );

    await tester.drag(find.byType(PortfolioToolbar), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(
      container.read(portfolioProvider).selectedTab,
      PortfolioTab.positions,
    );
    expect(find.text('HCLTECH'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('swiping right on the Filters toolbar switches to Holdings', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = await pumpPortfolio(tester);

    await tester.tap(find.text('Positions'));
    await tester.pumpAndSettle();
    expect(
      container.read(portfolioProvider).selectedTab,
      PortfolioTab.positions,
    );

    await tester.drag(find.byType(PortfolioToolbar), const Offset(500, 0));
    await tester.pumpAndSettle();

    expect(
      container.read(portfolioProvider).selectedTab,
      PortfolioTab.holdings,
    );
    expect(find.text('IDFCFIRSTB'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
