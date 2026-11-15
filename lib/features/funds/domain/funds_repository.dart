library;

import 'package:tradewise/features/funds/domain/funds.dart';

/// Source of paper-trading account funds (UI phase).
///
/// Abstracted behind a repository so the mock below can be swapped for a
/// real data source without touching the notifier or any widget.
abstract class FundsRepository {
  const FundsRepository();

  /// Load the initial funds state (seed balance for the session).
  Funds loadInitialFunds();

  /// Add [amount] to the available balance and return the updated state.
  /// Returns unchanged state for invalid amounts (<= 0, non-finite).
  Funds addFunds(Funds current, double amount);
}
