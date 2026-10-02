import 'package:flutter_test/flutter_test.dart';
import 'package:tradewise/features/watchlist/presentation/watchlist_number_format.dart';

void main() {
  test('formats prices with grouped thousands and two decimals', () {
    expect(formatWatchlistPrice(1243.1), '1,243.10');
    expect(formatWatchlistPrice(15.46), '15.46');
    expect(formatWatchlistPrice(24812.3), '24,812.30');
    expect(formatWatchlistPrice(121.43), '121.43');
    expect(formatWatchlistPrice(178), '178.00');
    expect(formatWatchlistPrice(-1234567.891), '-1,234,567.89');
  });

  test('signs gains explicitly and keeps losses negative', () {
    expect(formatWatchlistSigned(13.1), '+13.10');
    expect(formatWatchlistSigned(-3.43), '-3.43');
    expect(formatWatchlistSigned(0), '0.00');
  });

  test('formats signed percentages', () {
    expect(formatWatchlistPercent(1.06), '+1.06%');
    expect(formatWatchlistPercent(-1.51), '-1.51%');
    expect(formatWatchlistPercent(0), '0.00%');
  });
}
