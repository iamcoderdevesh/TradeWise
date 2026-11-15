library;

import 'package:tradewise/features/funds/domain/funds.dart';
import 'package:tradewise/features/funds/domain/funds_repository.dart';

/// In-memory implementation of [FundsRepository] (UI phase).
///
/// Seeds with ₹10,000 available balance and ₹0 used margin. State persists
/// in memory for the app session; repeated additions accumulate correctly.
class MockFundsRepository extends FundsRepository {
  const MockFundsRepository({
    this.initialAvailableBalance = 10000.0,
    this.initialUsedMargin = 0.0,
  });

  final double initialAvailableBalance;
  final double initialUsedMargin;

  @override
  Funds loadInitialFunds() {
    return Funds(
      availableBalance: initialAvailableBalance,
      usedMargin: initialUsedMargin,
    );
  }

  @override
  Funds addFunds(Funds current, double amount) {
    if (!amount.isFinite || amount <= 0) {
      return current;
    }
    return current.copyWith(
      availableBalance: current.availableBalance + amount,
    );
  }
}
