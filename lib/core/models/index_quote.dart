/// One market index's display data.
///
/// Shared between Watchlist and Profile for the market-indices strip.
/// UI preview only: values are hard-coded display data, not live market data.
/// Nothing here is fetched, subscribed to or computed.
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
