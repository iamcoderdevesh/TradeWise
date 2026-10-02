/// Display formatting for watchlist market values.
///
/// UI-only helpers shared by [WatchlistInstrumentTile] and `IndexStrip`.
/// Deliberately dependency-free (no `intl`): the project's dependency policy
/// prefers built-in capability, and grouping a thousands separator plus a
/// signed variant are the only two cases needed here.
library;

/// Groups the integer part in threes and fixes two decimals,
/// e.g. `1243.1` -> `1,243.10` (matching the reference rows).
String formatWatchlistPrice(double value) {
  final String fixed = value.toStringAsFixed(2);
  final int dot = fixed.indexOf('.');
  final String whole = fixed.substring(0, dot);
  final String fraction = fixed.substring(dot);
  final bool isNegative = whole.startsWith('-');
  final String digits = isNegative ? whole.substring(1) : whole;

  final StringBuffer grouped = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      grouped.write(',');
    }
    grouped.write(digits[i]);
  }

  return '${isNegative ? '-' : ''}$grouped$fraction';
}

/// Signed variant: gains carry an explicit `+` (e.g. `+13.10`, `+1.06%`),
/// losses already carry `-`. Used for change and percentage values.
String formatWatchlistSigned(double value) {
  if (value == 0) {
    return formatWatchlistPrice(0);
  }
  return value > 0
      ? '+${formatWatchlistPrice(value)}'
      : formatWatchlistPrice(value);
}

/// Signed percentage string, e.g. `+1.06%` / `-1.28%` / `0.00%`.
String formatWatchlistPercent(double value) =>
    '${formatWatchlistSigned(value)}%';
