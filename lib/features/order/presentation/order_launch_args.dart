import 'package:tradewise/features/order/presentation/order_enums.dart';
import 'package:tradewise/features/watchlist/presentation/widgets/watchlist_preview_data.dart';

/// Typed arguments for the `/order` route.
///
/// Carries the selected instrument's display data (symbol, exchange, LTP) and
/// the side chosen in the Instrument Bottom Sheet. The order screen never
/// fetches anything: these values are its only inputs.
class OrderLaunchArgs {
  const OrderLaunchArgs({required this.instrument, required this.side});

  final WatchlistInstrument instrument;
  final OrderSide side;
}
