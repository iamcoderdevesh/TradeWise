import 'package:tradewise/features/order/presentation/order_enums.dart';
import 'package:tradewise/features/watchlist/presentation/widgets/watchlist_preview_data.dart';

/// Typed arguments for the `/order` route.
///
/// Carries the selected instrument's display data (symbol, exchange, LTP) and
/// the side chosen in the Instrument Bottom Sheet. The order screen never
/// fetches anything: these values are its only inputs.
///
/// [initialQuantity] pre-fills the quantity field (used by Portfolio Exit to
/// default to the full holding/position quantity). [initialProduct] pre-selects
/// the product (used by Portfolio Exit to match the holding/position product).
/// Both are optional and only consulted by Portfolio-initiated launches;
/// Watchlist-initiated launches omit them, preserving existing defaults.
class OrderLaunchArgs {
  const OrderLaunchArgs({
    required this.instrument,
    required this.side,
    this.initialQuantity,
    this.initialProduct,
  });

  final WatchlistInstrument instrument;
  final OrderSide side;

  /// Default quantity pre-filled in the ticket (e.g. full holding for Exit).
  final int? initialQuantity;

  /// Default product pre-selected in the ticket (e.g. match holding product
  /// for Exit).
  final OrderProduct? initialProduct;
}
