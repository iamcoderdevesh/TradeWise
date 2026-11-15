library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tradewise/features/funds/data/mock_funds_repository.dart';
import 'package:tradewise/features/funds/domain/funds.dart';
import 'package:tradewise/features/funds/domain/funds_repository.dart';

/// Seeds the simulated funds. The single seam replaced by a real data
/// source later; tests override it with custom seed lists.
final fundsRepositoryProvider = Provider<FundsRepository>((Ref ref) {
  return const MockFundsRepository();
});

/// Simulated funds state (paper trading).
///
/// A single Riverpod [Notifier] seeded from the mock [FundsRepository].
/// There is no persistence, no backend, and no real account data — this is
/// UI-only state so the screen can be exercised end-to-end.
class FundsNotifier extends Notifier<Funds> {
  late final FundsRepository _repository;

  @override
  Funds build() {
    _repository = ref.read(fundsRepositoryProvider);
    return _repository.loadInitialFunds();
  }

  /// Adds [amount] to the available balance.
  ///
  /// Invalid amounts (<= 0, non-finite) are rejected and state is unchanged.
  /// Repeated additions accumulate correctly.
  Future<void> addFunds(double amount) async {
    final updated = _repository.addFunds(state, amount);
    if (updated == state) {
      return;
    }
    state = updated;
  }
}

/// Read-only stream of the current paper-trading funds.
final fundsProvider = NotifierProvider<FundsNotifier, Funds>(FundsNotifier.new);
