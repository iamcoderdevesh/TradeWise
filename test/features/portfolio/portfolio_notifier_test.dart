import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tradewise/features/order/presentation/order_enums.dart';
import 'package:tradewise/features/portfolio/data/portfolio_entry.dart';
import 'package:tradewise/features/portfolio/data/portfolio_preview_data.dart';
import 'package:tradewise/features/portfolio/data/portfolio_repository.dart';
import 'package:tradewise/features/portfolio/presentation/portfolio_providers.dart';

ProviderContainer createContainer({
  List<PortfolioEntry> holdings = kPreviewHoldings,
  List<PortfolioEntry> positions = kPreviewPositions,
}) {
  final ProviderContainer container = ProviderContainer(
    overrides: [
      portfolioRepositoryProvider.overrideWith(
        (Ref ref) =>
            MockPortfolioRepository(holdings: holdings, positions: positions),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('seed and P&L calculations', () {
    test('repository seeds both tabs and the provider copies them', () {
      final container = createContainer();
      final PortfolioState state = container.read(portfolioProvider);

      expect(state.holdings, kPreviewHoldings);
      expect(state.positions, kPreviewPositions);
      expect(state.selectedTab, PortfolioTab.holdings);
      expect(state.activeCountFor(PortfolioTab.holdings), 2);
      // Two open positions plus the seeded closed VEDL row.
      expect(state.activeCountFor(PortfolioTab.positions), 2);
      expect(state.closedEntriesFor(PortfolioTab.positions).length, 1);
    });

    test('entry P&L is unrealised plus realised; closed keeps realised', () {
      const PortfolioEntry open = PortfolioEntry(
        symbol: 'X',
        exchange: 'NSE',
        quantity: 10,
        averagePrice: 100,
        lastTradedPrice: 105,
      );
      expect(open.unrealizedPnl, 50);
      expect(open.realizedPnl, 0);
      expect(open.pnl, 50);
      expect(open.isClosed, isFalse);

      const PortfolioEntry closed = PortfolioEntry(
        symbol: 'X',
        exchange: 'NSE',
        quantity: 0,
        averagePrice: 100,
        lastTradedPrice: 110,
        realizedPnl: -20,
      );
      expect(closed.unrealizedPnl, 0);
      expect(closed.pnl, -20);
      expect(closed.isClosed, isTrue);
    });

    test('total P&L sums every row of the tab including closed results', () {
      final container = createContainer();
      final PortfolioState state = container.read(portfolioProvider);

      // Holdings: 10×(66.95−64.70)=22.50 + 50×(178.00−172.40)=280.00.
      expect(state.totalPnlFor(PortfolioTab.holdings), closeTo(302.50, 1e-9));
      // Positions: 20×(1243.10−1210)=662 + (−50)×(230.37−226)=-218.50
      // + the closed VEDL realised 41.00.
      expect(state.totalPnlFor(PortfolioTab.positions), closeTo(484.50, 1e-9));
    });
  });

  group('tab selection', () {
    test('selectTab switches the selected tab', () {
      final container = createContainer();
      container
          .read(portfolioProvider.notifier)
          .selectTab(PortfolioTab.positions);
      expect(
        container.read(portfolioProvider).selectedTab,
        PortfolioTab.positions,
      );
    });
  });

  group('BUY simulation', () {
    test('longterm BUY merges into the matching holding with weighted avg', () {
      final container = createContainer();
      final PaperOrderResult result = container
          .read(portfolioProvider.notifier)
          .applyOrder(
            side: OrderSide.buy,
            product: OrderProduct.longterm,
            symbol: 'IDFCFIRSTB',
            exchange: 'NSE',
            quantity: 5,
            price: 70,
            lastTradedPrice: 71,
          );

      expect(result.filled, isTrue);
      expect(result.targetTab, PortfolioTab.holdings);
      expect(
        result.message,
        'Paper order filled: 5 × IDFCFIRSTB added to Holdings',
      );

      final PortfolioState state = container.read(portfolioProvider);
      expect(state.selectedTab, PortfolioTab.holdings);
      final PortfolioEntry merged = state.holdings.firstWhere(
        (PortfolioEntry e) => e.symbol == 'IDFCFIRSTB',
      );
      expect(merged.quantity, 15);
      // (10×64.70 + 5×70) / 15 = 66.466…
      expect(merged.averagePrice, closeTo(66.4666, 1e-3));
      expect(merged.lastTradedPrice, 71);
    });

    test('intraday BUY appends a new position and selects Positions', () {
      final container = createContainer();
      final PaperOrderResult result = container
          .read(portfolioProvider.notifier)
          .applyOrder(
            side: OrderSide.buy,
            product: OrderProduct.intraday,
            symbol: 'GOLDBEES',
            exchange: 'NSE',
            quantity: 3,
            price: 121.43,
            lastTradedPrice: 121.43,
          );

      expect(result.filled, isTrue);
      expect(result.targetTab, PortfolioTab.positions);
      expect(
        result.message,
        'Paper order filled: 3 × GOLDBEES added to Positions',
      );

      final PortfolioState state = container.read(portfolioProvider);
      expect(state.selectedTab, PortfolioTab.positions);
      final PortfolioEntry added = state.positions.firstWhere(
        (PortfolioEntry e) => e.symbol == 'GOLDBEES',
      );
      expect(added.quantity, 3);
      expect(added.averagePrice, 121.43);
      // The holdings tab is untouched.
      expect(
        state.holdings.any((PortfolioEntry e) => e.symbol == 'GOLDBEES'),
        isFalse,
      );
    });

    test('BUY against a closed entry re-opens it at the fill price', () {
      final container = createContainer();
      container
          .read(portfolioProvider.notifier)
          .applyOrder(
            side: OrderSide.buy,
            product: OrderProduct.intraday,
            symbol: 'VEDL',
            exchange: 'NSE',
            quantity: 10,
            price: 260,
            lastTradedPrice: 260,
          );

      final PortfolioState state = container.read(portfolioProvider);
      final PortfolioEntry reopened = state.positions.firstWhere(
        (PortfolioEntry e) => e.symbol == 'VEDL',
      );
      expect(reopened.quantity, 10);
      expect(reopened.averagePrice, 260);
      // The realised history is preserved through the re-open.
      expect(reopened.realizedPnl, 41.00);
      expect(state.closedEntriesFor(PortfolioTab.positions), isEmpty);
    });
  });

  group('SELL simulation', () {
    test('partial sell reduces the holding and realises P&L', () {
      final container = createContainer();
      final PaperOrderResult result = container
          .read(portfolioProvider.notifier)
          .applyOrder(
            side: OrderSide.sell,
            product: OrderProduct.longterm,
            symbol: 'IDFCFIRSTB',
            exchange: 'NSE',
            quantity: 4,
            price: 68,
            lastTradedPrice: 68,
          );

      expect(result.filled, isTrue);
      expect(result.message, 'Paper order filled: sold 4 × IDFCFIRSTB');

      final PortfolioEntry updated = container
          .read(portfolioProvider)
          .holdings
          .firstWhere((PortfolioEntry e) => e.symbol == 'IDFCFIRSTB');
      expect(updated.quantity, 6);
      // (68 − 64.70) × 4 = 13.20 realised.
      expect(updated.realizedPnl, closeTo(13.20, 1e-9));
      expect(updated.isClosed, isFalse);
    });

    test('full sell closes the holding and keeps the realised result', () {
      final container = createContainer();
      final PaperOrderResult result = container
          .read(portfolioProvider.notifier)
          .applyOrder(
            side: OrderSide.sell,
            product: OrderProduct.longterm,
            symbol: 'IDFCFIRSTB',
            exchange: 'NSE',
            quantity: 10,
            price: 70,
            lastTradedPrice: 70,
          );

      expect(result.filled, isTrue);

      final PortfolioState state = container.read(portfolioProvider);
      final PortfolioEntry closed = state.holdings.firstWhere(
        (PortfolioEntry e) => e.symbol == 'IDFCFIRSTB',
      );
      expect(closed.quantity, 0);
      expect(closed.isClosed, isTrue);
      // (70 − 64.70) × 10 = 53.00 realised.
      expect(closed.realizedPnl, closeTo(53.00, 1e-9));
      // The closed row moves to the Closed section, not out of the list.
      expect(
        state
            .closedEntriesFor(PortfolioTab.holdings)
            .map((PortfolioEntry e) => e.symbol),
        contains('IDFCFIRSTB'),
      );
      expect(state.activeCountFor(PortfolioTab.holdings), 1);
    });

    test('intraday sell reduces an open position', () {
      final container = createContainer();
      container
          .read(portfolioProvider.notifier)
          .applyOrder(
            side: OrderSide.sell,
            product: OrderProduct.intraday,
            symbol: 'HCLTECH',
            exchange: 'NSE',
            quantity: 5,
            price: 1250,
            lastTradedPrice: 1250,
          );

      final PortfolioEntry updated = container
          .read(portfolioProvider)
          .positions
          .firstWhere((PortfolioEntry e) => e.symbol == 'HCLTECH');
      expect(updated.quantity, 15);
      expect(updated.realizedPnl, closeTo(200, 1e-9));
    });

    test('sell without a matching holding is rejected', () {
      final container = createContainer();
      final PortfolioState before = container.read(portfolioProvider);
      final PaperOrderResult result = container
          .read(portfolioProvider.notifier)
          .applyOrder(
            side: OrderSide.sell,
            product: OrderProduct.longterm,
            symbol: 'TAPARIA',
            exchange: 'BSE',
            quantity: 1,
            price: 15.46,
            lastTradedPrice: 15.46,
          );

      expect(result.filled, isFalse);
      expect(result.targetTab, isNull);
      expect(result.message, 'Sell order rejected: no holding for TAPARIA');
      expect(container.read(portfolioProvider).holdings, before.holdings);
    });

    test('selling more than held is rejected and changes nothing', () {
      final container = createContainer();
      final PortfolioState before = container.read(portfolioProvider);
      final PaperOrderResult result = container
          .read(portfolioProvider.notifier)
          .applyOrder(
            side: OrderSide.sell,
            product: OrderProduct.longterm,
            symbol: 'IDFCFIRSTB',
            exchange: 'NSE',
            quantity: 11,
            price: 70,
            lastTradedPrice: 70,
          );

      expect(result.filled, isFalse);
      expect(
        result.message,
        'Sell order rejected: not enough holding quantity for IDFCFIRSTB',
      );
      expect(container.read(portfolioProvider).holdings, before.holdings);
    });

    test('selling a negative (short) preview position is rejected', () {
      final container = createContainer();
      final PaperOrderResult result = container
          .read(portfolioProvider.notifier)
          .applyOrder(
            side: OrderSide.sell,
            product: OrderProduct.intraday,
            symbol: 'ONGC',
            exchange: 'NSE',
            quantity: 1,
            price: 222.37,
            lastTradedPrice: 222.37,
          );

      expect(result.filled, isFalse);
      expect(
        result.message,
        'Sell order rejected: not enough position quantity for ONGC',
      );
    });

    test('invalid quantity or price is rejected', () {
      final container = createContainer();
      final PaperOrderResult result = container
          .read(portfolioProvider.notifier)
          .applyOrder(
            side: OrderSide.buy,
            product: OrderProduct.longterm,
            symbol: 'X',
            exchange: 'NSE',
            quantity: 0,
            price: 0,
            lastTradedPrice: 1,
          );

      expect(result.filled, isFalse);
      expect(
        result.message,
        'Order rejected: enter a valid quantity and price',
      );
    });
  });
}
