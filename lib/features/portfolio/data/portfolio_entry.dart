import 'package:flutter/foundation.dart';

/// One portfolio row's simulated state (paper trading, UI phase).
///
/// Immutable by convention: the [PortfolioNotifier] replaces entries with
/// updated copies instead of mutating them. [quantity] is signed for
/// positions (negative = short preview data) and `0` marks a closed entry,
/// which keeps its [realizedPnl] (and its average price) for display while
/// contributing no unrealised P&L.
@immutable
class PortfolioEntry {
  const PortfolioEntry({
    required this.symbol,
    required this.exchange,
    required this.quantity,
    required this.averagePrice,
    required this.lastTradedPrice,
    this.realizedPnl = 0,
  });

  final String symbol;
  final String exchange;

  /// Signed share quantity. `0` means the entry is closed (see [isClosed]).
  final int quantity;

  /// Average entry price of the currently open quantity.
  final double averagePrice;

  /// Last traded price used for unrealised P&L display. Simulated only:
  /// nothing is fetched while the app is UI-first (ADR-005).
  final double lastTradedPrice;

  /// P&L realised by (partial) sells so far. Preserved when an entry closes
  /// so a fully-exited row keeps showing its result.
  final double realizedPnl;

  /// Whether the entry has been fully exited (no open quantity).
  bool get isClosed => quantity == 0;

  /// (LTP − avg) × qty; zero for closed entries.
  double get unrealizedPnl =>
      quantity == 0 ? 0 : (lastTradedPrice - averagePrice) * quantity;

  /// Displayed P&L: unrealised plus everything realised so far.
  double get pnl => unrealizedPnl + realizedPnl;

  PortfolioEntry copyWith({
    String? symbol,
    String? exchange,
    int? quantity,
    double? averagePrice,
    double? lastTradedPrice,
    double? realizedPnl,
  }) {
    return PortfolioEntry(
      symbol: symbol ?? this.symbol,
      exchange: exchange ?? this.exchange,
      quantity: quantity ?? this.quantity,
      averagePrice: averagePrice ?? this.averagePrice,
      lastTradedPrice: lastTradedPrice ?? this.lastTradedPrice,
      realizedPnl: realizedPnl ?? this.realizedPnl,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PortfolioEntry &&
      other.symbol == symbol &&
      other.exchange == exchange &&
      other.quantity == quantity &&
      other.averagePrice == averagePrice &&
      other.lastTradedPrice == lastTradedPrice &&
      other.realizedPnl == realizedPnl;

  @override
  int get hashCode => Object.hash(
    symbol,
    exchange,
    quantity,
    averagePrice,
    lastTradedPrice,
    realizedPnl,
  );
}
