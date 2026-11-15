import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tradewise/features/funds/data/mock_funds_repository.dart';
import 'package:tradewise/features/funds/presentation/funds_providers.dart';

void main() {
  group('FundsNotifier', () {
    test('initial state loads seed balance from repository', () {
      final container = ProviderContainer(
        overrides: [
          fundsRepositoryProvider.overrideWithValue(
            const MockFundsRepository(initialAvailableBalance: 10000.0),
          ),
        ],
      );

      final funds = container.read(fundsProvider);
      expect(funds.availableBalance, 10000.0);
      expect(funds.usedMargin, 0.0);

      container.dispose();
    });

    test('addFunds accumulates correctly', () async {
      final container = ProviderContainer(
        overrides: [
          fundsRepositoryProvider.overrideWithValue(
            const MockFundsRepository(initialAvailableBalance: 10000.0),
          ),
        ],
      );

      await container.read(fundsProvider.notifier).addFunds(5000.0);
      expect(container.read(fundsProvider).availableBalance, 15000.0);

      await container.read(fundsProvider.notifier).addFunds(2000.0);
      expect(container.read(fundsProvider).availableBalance, 17000.0);

      container.dispose();
    });

    test('addFunds rejects invalid amounts', () async {
      final container = ProviderContainer(
        overrides: [
          fundsRepositoryProvider.overrideWithValue(
            const MockFundsRepository(initialAvailableBalance: 10000.0),
          ),
        ],
      );

      await container.read(fundsProvider.notifier).addFunds(0.0);
      expect(container.read(fundsProvider).availableBalance, 10000.0);

      await container.read(fundsProvider.notifier).addFunds(-100.0);
      expect(container.read(fundsProvider).availableBalance, 10000.0);

      await container.read(fundsProvider.notifier).addFunds(double.infinity);
      expect(container.read(fundsProvider).availableBalance, 10000.0);

      container.dispose();
    });

    test('balance persists for session', () async {
      final container = ProviderContainer(
        overrides: [
          fundsRepositoryProvider.overrideWithValue(
            const MockFundsRepository(initialAvailableBalance: 10000.0),
          ),
        ],
      );

      await container.read(fundsProvider.notifier).addFunds(5000.0);
      final firstRead = container.read(fundsProvider);
      expect(firstRead.availableBalance, 15000.0);

      final secondRead = container.read(fundsProvider);
      expect(secondRead.availableBalance, 15000.0);

      container.dispose();
    });
  });
}
