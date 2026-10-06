/// UI preview data only. Not production market data.
///
/// Temporary, presentation-layer constants used to reproduce the three
/// reference Watchlist states (empty, single item, multiple items) while
/// TradeWise is UI-only (ADR-005). Values are transcribed from
/// `references/kite/watchlist/`; nothing is fetched, computed or persisted.
///
/// This is the single seam to replace when real market data exists: the screen
/// already takes its instruments as a parameter, so the lists below become the
/// output of a repository/provider without any change to the presentation
/// widgets.
library;

/// One watchlist row's display data.
///
/// Fields are limited to what the references and `docs/UI_SPECIFICATION.md`
/// establish: symbol, exchange, last traded price, absolute change, percentage
/// change, and an optional held-quantity badge.
class WatchlistInstrument {
  const WatchlistInstrument({
    required this.symbol,
    required this.exchange,
    required this.price,
    required this.change,
    required this.changePercent,
    this.holdingQuantity,
  });

  final String symbol;
  final String exchange;
  final double price;
  final double change;
  final double changePercent;

  /// Passive metadata only: the reference shows a small briefcase badge with a
  /// number next to the exchange for one held instrument. No order/position
  /// semantics are inferred from it.
  final int? holdingQuantity;
}

/// Empty watchlist (`watchlist__empty_default__*`): no rows at all.
const List<WatchlistInstrument> kWatchlistPreviewEmpty =
    <WatchlistInstrument>[];

/// Multiple-item watchlist (`watchlist__with_data__*`).
///
/// Every instrument listed here has a fully legible symbol, exchange, price and
/// change in the reference; the final partially visible row (COALINDIA, only its
/// price is legible) is omitted rather than invented. The list is long enough to
/// scroll on a phone-class viewport, which is the behaviour the reference
/// establishes. The reference's own counter reads `10/250`; TradeWise derives the
/// counter from this list's length instead of copying a numeral it cannot
/// reproduce.
const List<WatchlistInstrument> kWatchlistPreviewMultiple =
    <WatchlistInstrument>[
      WatchlistInstrument(
        symbol: 'IDFCFIRSTB',
        exchange: 'NSE',
        price: 80.39,
        change: -1.05,
        changePercent: -1.28,
        holdingQuantity: 10,
      ),
      WatchlistInstrument(
        symbol: 'TAPARIA',
        exchange: 'BSE',
        price: 15.46,
        change: 0,
        changePercent: 0,
      ),
      WatchlistInstrument(
        symbol: 'TMPV',
        exchange: 'NSE',
        price: 279.40,
        change: -4.10,
        changePercent: -1.44,
      ),
      WatchlistInstrument(
        symbol: 'ONGC',
        exchange: 'NSE',
        price: 222.37,
        change: -3.43,
        changePercent: -1.51,
      ),
      WatchlistInstrument(
        symbol: 'HCLTECH',
        exchange: 'NSE',
        price: 1243.10,
        change: 13.10,
        changePercent: 1.06,
      ),
      WatchlistInstrument(
        symbol: 'TATASTEEL',
        exchange: 'NSE',
        price: 178.00,
        change: -6.30,
        changePercent: -3.41,
      ),
      WatchlistInstrument(
        symbol: 'VEDL',
        exchange: 'NSE',
        price: 252.05,
        change: -6.95,
        changePercent: -2.68,
      ),
    ];

/// Single-item watchlist (`watchlist__single_item__*`).
const List<WatchlistInstrument> kWatchlistPreviewSingle = <WatchlistInstrument>[
  WatchlistInstrument(
    symbol: 'GOLDBEES',
    exchange: 'NSE',
    price: 121.43,
    change: -0.16,
    changePercent: -0.13,
  ),
];

/// One market index's display data for [IndexStrip].
///
/// UI preview only: the strip is hard-coded display data, not live index data,
/// and nothing here is fetched, subscribed to or computed.
class IndexQuote {
  const IndexQuote({
    required this.name,
    required this.value,
    required this.change,
    required this.changePercent,
  });

  final String name;
  final double value;
  final double change;
  final double changePercent;
}

/// Index strip preview (`watchlist__with_data__*`): the reference shows two
/// indices side by side, each with its uppercase name over a value and
/// change/percentage pair.
const List<IndexQuote> kIndexStripPreview = <IndexQuote>[
  IndexQuote(
    name: 'NIFTY 50',
    value: 24812.30,
    change: -104.62,
    changePercent: -0.42,
  ),
  IndexQuote(
    name: 'NIFTY BANK',
    value: 51203.10,
    change: 92.11,
    changePercent: 0.18,
  ),
];

/// One bid/offer market-depth row's display data for the instrument bottom
/// sheet.
///
/// UI preview only: a depth ladder is static placeholder data (ADR-005).
/// Nothing is fetched, computed or subscribed to, and the values must never be
/// presented as live market data.
class MarketDepthRow {
  const MarketDepthRow({
    required this.price,
    required this.orders,
    required this.quantity,
  });

  final double price;
  final int orders;
  final int quantity;
}

/// 5-level bid/offer depth preview (`watchlist__bottomsheet__*`).
///
/// The reference's depth rows are all-zero placeholder values; TradeWise
/// reproduces the visual ladder only, with clearly mock values.
const List<MarketDepthRow> kInstrumentDepthPreview = <MarketDepthRow>[
  MarketDepthRow(price: 0, orders: 0, quantity: 0),
  MarketDepthRow(price: 0, orders: 0, quantity: 0),
  MarketDepthRow(price: 0, orders: 0, quantity: 0),
  MarketDepthRow(price: 0, orders: 0, quantity: 0),
  MarketDepthRow(price: 0, orders: 0, quantity: 0),
];
