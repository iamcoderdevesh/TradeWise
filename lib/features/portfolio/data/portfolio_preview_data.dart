import 'package:tradewise/features/portfolio/data/portfolio_entry.dart';

/// UI preview seed data for the simulated Portfolio (ADR-005).
///
/// Values are plausible display data for TradeWise's own instruments (the
/// watchlist preview set), so a paper BUY from the Watchlist can merge with
/// an existing row the way a real add would. Nothing here is fetched,
/// computed from the market, or persisted.

/// Seed holdings for the Holdings tab. Two open deliveries; the Positions
/// list carries the closed example row instead.
const List<PortfolioEntry> kPreviewHoldings = <PortfolioEntry>[
  PortfolioEntry(
    symbol: 'IDFCFIRSTB',
    exchange: 'NSE',
    quantity: 10,
    averagePrice: 64.70,
    lastTradedPrice: 66.95,
  ),
  PortfolioEntry(
    symbol: 'TATASTEEL',
    exchange: 'NSE',
    quantity: 50,
    averagePrice: 172.40,
    lastTradedPrice: 178.00,
  ),
];

/// Seed positions for the Positions tab: one long, one short (preview data
/// only — paper SELL never creates shorts, it only reduces existing long
/// quantities) and one fully-exited row rendered under "Closed".
const List<PortfolioEntry> kPreviewPositions = <PortfolioEntry>[
  PortfolioEntry(
    symbol: 'HCLTECH',
    exchange: 'NSE',
    quantity: 20,
    averagePrice: 1210.00,
    lastTradedPrice: 1243.10,
  ),
  PortfolioEntry(
    symbol: 'ONGC',
    exchange: 'NSE',
    quantity: -50,
    averagePrice: 226.00,
    lastTradedPrice: 230.37,
  ),
  PortfolioEntry(
    symbol: 'VEDL',
    exchange: 'NSE',
    quantity: 0,
    averagePrice: 250.05,
    lastTradedPrice: 252.05,
    realizedPnl: 41.00,
  ),
];
