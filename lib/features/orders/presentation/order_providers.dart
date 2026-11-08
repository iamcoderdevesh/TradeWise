import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/order.dart';

/// In-memory order history.
///
/// Only successful fills are ever appended. There is no persistence, no
/// backend, and no fabricated data — the list starts empty and grows only
/// when the order-placement ticket records a genuine fill (see
/// `order_placement_screen.dart`).
class OrderNotifier extends Notifier<List<Order>> {
  @override
  List<Order> build() => <Order>[];

  /// Appends one order entry to history.
  ///
  /// Called exactly once per successful fill so one fill creates exactly one
  /// history entry. Failed orders are never recorded here.
  void addOrder(Order order) {
    state = <Order>[...state, order];
  }
}

/// Read-only stream of recorded orders.
final orderHistoryProvider = NotifierProvider<OrderNotifier, List<Order>>(
  OrderNotifier.new,
);
