/// Pure input parsing and estimate helpers for the order ticket.
///
/// UI-only arithmetic on display values (ADR-005): nothing here places an
/// order, computes brokerage, or touches funds. Kept free of widgets so the
/// edge cases stay unit-testable without pumping anything.
library;

/// Parses a whole-share quantity. Returns null for empty, fractional,
/// non-numeric or overflowing input; zero and negatives parse (callers decide
/// validity with `>= 1`).
int? parseOrderQuantity(String text) {
  final String trimmed = text.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  if (!RegExp(r'^\d+$').hasMatch(trimmed)) {
    return null;
  }
  return int.tryParse(trimmed);
}

/// Parses a rupee amount or limit price. Returns null for empty, malformed,
/// NaN or infinite input; zero and negatives parse (callers require `> 0`).
double? parseOrderMoney(String text) {
  final double? value = double.tryParse(text.trim());
  if (value == null || value.isNaN || !value.isFinite) {
    return null;
  }
  return value;
}

/// Derives an indicative whole-share quantity from a rupee amount.
///
/// Rounds **down** (floor): an amount that cannot buy a full share at the
/// effective price yields zero, never a fractional share. Returns 0 when the
/// amount or price is missing, non-positive or non-finite, so division by
/// zero is impossible by construction.
int indicativeQuantity({required double? amount, required double? price}) {
  if (amount == null ||
      price == null ||
      amount <= 0 ||
      price <= 0 ||
      !amount.isFinite ||
      !price.isFinite) {
    return 0;
  }
  return (amount / price).floor();
}

/// Quantity × price estimate. Both operands must already be validated.
double estimateOrderAmount({required int quantity, required double price}) {
  return quantity * price;
}
