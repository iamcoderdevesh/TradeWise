library;

import 'package:flutter/foundation.dart';

/// Paper-trading account funds state.
///
/// The authoritative owner of available cash for trading.
/// [availableBalance] is the cash available to place orders.
/// [usedMargin] is margin consumed by open positions (₹0 in this phase).
/// [totalFunds] is derived (availableBalance + usedMargin) and not stored
/// separately to avoid inconsistency.
@immutable
class Funds {
  const Funds({required this.availableBalance, required this.usedMargin});

  /// Cash available for trading.
  final double availableBalance;

  /// Margin consumed by open positions. Always ₹0.00 in this phase.
  final double usedMargin;

  /// Total funds = availableBalance + usedMargin (derived, not stored).
  double get totalFunds => availableBalance + usedMargin;

  Funds copyWith({double? availableBalance, double? usedMargin}) {
    return Funds(
      availableBalance: availableBalance ?? this.availableBalance,
      usedMargin: usedMargin ?? this.usedMargin,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Funds &&
        other.availableBalance == availableBalance &&
        other.usedMargin == usedMargin;
  }

  @override
  int get hashCode => Object.hash(availableBalance, usedMargin);

  @override
  String toString() {
    return 'Funds(availableBalance: $availableBalance, usedMargin: $usedMargin)';
  }
}
