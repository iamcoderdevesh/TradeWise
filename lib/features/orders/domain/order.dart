library;

import 'package:tradewise/features/order/presentation/order_enums.dart';

/// Order domain model and status enum.
///
/// Represents one successfully executed paper trade recorded in order history.
/// Only genuine fills are stored — there are no sample, preview, or fabricated
/// orders, and failed orders never become history entries.
///
/// All displayed fields derive from the authoritative application data: the
/// order-placement launch args, the portfolio simulation result, and the
/// order ticket's local form state. Nothing is hardcoded or fabricated.
/// The lifecycle status of an order.
///
/// Only statuses the application genuinely produces are modelled: an order
/// that is still open while pending, or one that has executed. Rejected and
/// cancelled outcomes are not recorded because the current paper-trading flow
/// either fills immediately (buy) or reports rejection inline (sell).
enum OrderStatus { open, executed }

/// One order-history entry.
///
/// Fields are populated from genuine application data:
/// - [side], [symbol], [exchange] come from the order-placement launch args
/// - [product], [productCode], [orderType] come from the ticket's form state
/// - [quantity] is the total order quantity from the ticket
/// - [filledQuantity] is the actually executed quantity (equals [quantity] in
///   the current immediate-fill simulation)
/// - [price] is the authoritative execution price used by the portfolio
///   simulation (LTP for Market, entered price for Limit/Stop Loss)
/// - [executedAt] is the fill timestamp
/// - [status] reflects the order's lifecycle state
class Order {
  const Order({
    required this.id,
    required this.side,
    required this.symbol,
    required this.exchange,
    required this.product,
    required this.productCode,
    required this.orderType,
    required this.quantity,
    required this.filledQuantity,
    required this.price,
    required this.executedAt,
    required this.status,
  });

  /// Stable identifier for the entry.
  final String id;
  final OrderSide side;
  final String symbol;
  final String exchange;
  final String product;
  final String productCode;
  final OrderType orderType;
  final int quantity;
  final int filledQuantity;
  final double price;
  final DateTime executedAt;
  final OrderStatus status;
}
