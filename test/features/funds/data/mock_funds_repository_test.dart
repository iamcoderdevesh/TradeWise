import 'package:flutter_test/flutter_test.dart';

import 'package:tradewise/features/funds/data/mock_funds_repository.dart';

void main() {
  group('MockFundsRepository', () {
    test('loadInitialFunds returns seed balance of ₹10,000', () {
      const repository = MockFundsRepository();
      final funds = repository.loadInitialFunds();
      expect(funds.availableBalance, 10000.0);
      expect(funds.usedMargin, 0.0);
    });

    test('addFunds accumulates correctly', () {
      const repository = MockFundsRepository();
      final initial = repository.loadInitialFunds();
      expect(initial.availableBalance, 10000.0);

      final afterFirst = repository.addFunds(initial, 5000.0);
      expect(afterFirst.availableBalance, 15000.0);
      expect(afterFirst.usedMargin, 0.0);
      expect(afterFirst.totalFunds, 15000.0);

      final afterSecond = repository.addFunds(afterFirst, 2000.0);
      expect(afterSecond.availableBalance, 17000.0);
      expect(afterSecond.usedMargin, 0.0);
      expect(afterSecond.totalFunds, 17000.0);
    });

    test('addFunds rejects zero amount', () {
      const repository = MockFundsRepository();
      final initial = repository.loadInitialFunds();
      final result = repository.addFunds(initial, 0.0);
      expect(result, initial);
    });

    test('addFunds rejects negative amount', () {
      const repository = MockFundsRepository();
      final initial = repository.loadInitialFunds();
      final result = repository.addFunds(initial, -100.0);
      expect(result, initial);
    });

    test('addFunds rejects non-finite amount', () {
      const repository = MockFundsRepository();
      final initial = repository.loadInitialFunds();
      final result = repository.addFunds(initial, double.infinity);
      expect(result, initial);
    });

    test('custom seed balance works', () {
      const repository = MockFundsRepository(
        initialAvailableBalance: 5000.0,
        initialUsedMargin: 1000.0,
      );
      final funds = repository.loadInitialFunds();
      expect(funds.availableBalance, 5000.0);
      expect(funds.usedMargin, 1000.0);
      expect(funds.totalFunds, 6000.0);
    });
  });
}
