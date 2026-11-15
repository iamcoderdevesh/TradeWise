import 'package:flutter_test/flutter_test.dart';

import 'package:tradewise/features/funds/domain/funds.dart';

void main() {
  group('Funds model', () {
    test('creates with availableBalance and usedMargin', () {
      const funds = Funds(availableBalance: 10000.0, usedMargin: 0.0);
      expect(funds.availableBalance, 10000.0);
      expect(funds.usedMargin, 0.0);
    });

    test('totalFunds derives from availableBalance + usedMargin', () {
      const funds = Funds(availableBalance: 15000.0, usedMargin: 2000.0);
      expect(funds.totalFunds, 17000.0);
    });

    test('copyWith produces updated values', () {
      const original = Funds(availableBalance: 10000.0, usedMargin: 0.0);
      final updated = original.copyWith(availableBalance: 15000.0);
      expect(updated.availableBalance, 15000.0);
      expect(updated.usedMargin, 0.0);
      expect(updated.totalFunds, 15000.0);
    });

    test('equality works correctly', () {
      const a = Funds(availableBalance: 10000.0, usedMargin: 0.0);
      const b = Funds(availableBalance: 10000.0, usedMargin: 0.0);
      const c = Funds(availableBalance: 15000.0, usedMargin: 0.0);
      expect(a, b);
      expect(a != c, true);
    });

    test('hashCode works correctly', () {
      const a = Funds(availableBalance: 10000.0, usedMargin: 0.0);
      const b = Funds(availableBalance: 10000.0, usedMargin: 0.0);
      expect(a.hashCode, b.hashCode);
    });
  });
}
