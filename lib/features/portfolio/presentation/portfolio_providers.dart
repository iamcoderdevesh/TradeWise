import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tradewise/features/order/presentation/order_enums.dart';
import 'package:tradewise/features/portfolio/data/portfolio_entry.dart';
import 'package:tradewise/features/portfolio/data/portfolio_repository.dart';

/// Which Portfolio tab is on screen (and where a filled paper order lands).
///
/// Locked mapping (Phase 5): a Longterm BUY fills the Holdings tab, an
/// Intraday BUY fills the Positions tab.
enum PortfolioTab { holdings, positions }

/// Immutable snapshot of the simulated portfolio plus the selected tab.
@immutable
class PortfolioState {
  const PortfolioState({
    required this.holdings,
    required this.positions,
    this.selectedTab = PortfolioTab.holdings,
  });

  final List<PortfolioEntry> holdings;
  final List<PortfolioEntry> positions;
  final PortfolioTab selectedTab;

  List<PortfolioEntry> entriesFor(PortfolioTab tab) =>
      tab == PortfolioTab.holdings ? holdings : positions;

  /// Rows with open quantity for [tab] (closed rows are excluded from the
  /// tab count, matching the reference's "Holdings 17" badges).
  List<PortfolioEntry> activeEntriesFor(PortfolioTab tab) =>
      entriesFor(tab).where((PortfolioEntry e) => !e.isClosed).toList();

  /// Fully-exited rows for [tab], rendered under the "Closed" section.
  List<PortfolioEntry> closedEntriesFor(PortfolioTab tab) =>
      entriesFor(tab).where((PortfolioEntry e) => e.isClosed).toList();

  int activeCountFor(PortfolioTab tab) => activeEntriesFor(tab).length;

  /// Sum of displayed P&L (unrealised + realised) across every row of
  /// [tab] — the reference's "Total P&L" card value.
  double totalPnlFor(PortfolioTab tab) =>
      entriesFor(tab)
          .fold<double>(0, (double sum, PortfolioEntry e) => sum + e.pnl);

  PortfolioState copyWith({
    List<PortfolioEntry>? holdings,
    List<PortfolioEntry>? positions,
    PortfolioTab? selectedTab,
  }) {
    return PortfolioState(
      holdings: holdings ?? this.holdings,
      positions: positions ?? this.positions,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }
}

/// Outcome of one simulated paper order.
///
/// [filled] orders carry the tab they landed on; [rejected] orders never
/// touch the portfolio state.
@immutable
class PaperOrderResult {
  const PaperOrderResult.filled(String message, PortfolioTab targetTab)
    : this._(filled: true, message: message, targetTab: targetTab);

  const PaperOrderResult.rejected(String message)
    : this._(filled: false, message: message, targetTab: null);

  const PaperOrderResult._({
    required this.filled,
    required this.message,
    this.targetTab,
  });

  final bool filled;
  final String message;
  final PortfolioTab? targetTab;
}

/// Simulated portfolio state (Phase 5, paper trading).
///
/// Lightweight by design (locked decision Q2-a-lite): a single Riverpod
/// [Notifier] seeded from the mock [PortfolioRepository]. There is no
/// persistence, no market data and no order routing — BUY/SELL only mutate
/// this in-memory state so the UI can be exercised end-to-end (ADR-005,
/// ADR-010).
class PortfolioNotifier extends Notifier<PortfolioState> {
  @override
  PortfolioState build() {
    final PortfolioRepository repository = ref.read(
      portfolioRepositoryProvider,
    );
    return PortfolioState(
      holdings: List<PortfolioEntry>.unmodifiable(repository.loadHoldings()),
      positions: List<PortfolioEntry>.unmodifiable(repository.loadPositions()),
    );
  }

  void selectTab(PortfolioTab tab) {
    if (state.selectedTab == tab) {
      return;
    }
    state = state.copyWith(selectedTab: tab);
  }

  /// Applies one simulated order.
  ///
  /// BUY always fills: it merges into the matching row (weighted-average
  /// price) or appends a new one, in Holdings for [OrderProduct.longterm]
  /// and Positions for [OrderProduct.intraday], and selects that tab.
  ///
  /// SELL only reduces an existing row with enough open quantity: a partial
  /// sell keeps the entry open (realised P&L accumulates), a full sell
  /// closes it (quantity 0, realised result retained for the Closed
  /// section). A missing or insufficient entry is rejected without any
  /// state change.
  PaperOrderResult applyOrder({
    required OrderSide side,
    required OrderProduct product,
    required String symbol,
    required String exchange,
    required int quantity,
    required double price,
    required double lastTradedPrice,
  }) {
    if (quantity < 1 || price <= 0) {
      return PaperOrderResult.rejected(
        'Order rejected: enter a valid quantity and price',
      );
    }

    final PortfolioTab tab = product == OrderProduct.longterm
        ? PortfolioTab.holdings
        : PortfolioTab.positions;
    final String targetLabel = tab == PortfolioTab.holdings
        ? 'holding'
        : 'position';
    final List<PortfolioEntry> entries = state.entriesFor(tab);
    final int index = entries.indexWhere(
      (PortfolioEntry e) => e.symbol == symbol && e.exchange == exchange,
    );

    if (side == OrderSide.sell) {
      final PortfolioEntry? entry = index == -1 ? null : entries[index];
      if (entry == null) {
        return PaperOrderResult.rejected(
          'Sell order rejected: no $targetLabel for $symbol',
        );
      }
      if (entry.quantity < quantity) {
        return PaperOrderResult.rejected(
          'Sell order rejected: not enough $targetLabel quantity for $symbol',
        );
      }
      final PortfolioEntry updated = entry.copyWith(
        quantity: entry.quantity - quantity,
        lastTradedPrice: lastTradedPrice,
        realizedPnl:
            entry.realizedPnl + (price - entry.averagePrice) * quantity,
      );
      final List<PortfolioEntry> updatedEntries = List<PortfolioEntry>.of(
        entries,
      )..[index] = updated;
      _commit(tab, updatedEntries);
      return PaperOrderResult.filled(
        'Paper order filled: sold $quantity × $symbol',
        tab,
      );
    }

    // BUY: merge into the matching row or append a new one.
    final List<PortfolioEntry> updatedEntries = List<PortfolioEntry>.of(
      entries,
    );
    final PortfolioEntry updated;
    if (index == -1) {
      updated = PortfolioEntry(
        symbol: symbol,
        exchange: exchange,
        quantity: quantity,
        averagePrice: price,
        lastTradedPrice: lastTradedPrice,
      );
      updatedEntries.add(updated);
    } else {
      final PortfolioEntry entry = entries[index];
      final int totalQuantity = entry.quantity + quantity;
      // Weighted average; with a closed (qty 0) entry this collapses to the
      // fill price, which is what re-opening a closed row should average at.
      final double averagePrice =
          (entry.averagePrice * entry.quantity + price * quantity) /
          totalQuantity;
      updated = entry.copyWith(
        quantity: totalQuantity,
        averagePrice: averagePrice,
        lastTradedPrice: lastTradedPrice,
      );
      updatedEntries[index] = updated;
    }
    _commit(tab, updatedEntries);

    final String tabLabel = tab == PortfolioTab.holdings
        ? 'Holdings'
        : 'Positions';
    return PaperOrderResult.filled(
      'Paper order filled: $quantity × $symbol added to $tabLabel',
      tab,
    );
  }

  void _commit(PortfolioTab tab, List<PortfolioEntry> entries) {
    state = state.copyWith(
      holdings: tab == PortfolioTab.holdings ? entries : null,
      positions: tab == PortfolioTab.positions ? entries : null,
      // Every fill also lands its tab, so the result is what the user sees
      // next (Positions after an intraday order, Holdings after longterm).
      selectedTab: tab,
    );
  }
}

/// Seeds the simulated portfolio. The single seam replaced by a real data
/// source later; tests override it with empty/custom seed lists.
final portfolioRepositoryProvider = Provider<PortfolioRepository>(
  (Ref ref) => const MockPortfolioRepository(),
);

final portfolioProvider = NotifierProvider<PortfolioNotifier, PortfolioState>(
  PortfolioNotifier.new,
);
