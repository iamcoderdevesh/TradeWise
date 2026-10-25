import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tradewise/app/router/app_routes.dart';
import 'package:tradewise/app/theme/tw_radii.dart';
import 'package:tradewise/app/theme/tw_spacing.dart';
import 'package:tradewise/features/order/presentation/order_enums.dart';
import 'package:tradewise/features/order/presentation/order_launch_args.dart';
import 'package:tradewise/core/widgets/instrument_bottom_sheet_shared.dart';
import 'package:tradewise/features/watchlist/presentation/widgets/watchlist_preview_data.dart';

/// Sheet snap geometry as fractions of the available (safe-area-aware) height.
///
/// 0.7 initial reproduces the reference coverage (roughly three quarters of
/// the screen) while keeping the Watchlist recognisable behind the barrier;
/// the user can drag down to 0.5 or expand up to 0.92 toward the top of the
/// viewport. Values stay local: they describe this sheet's own drag range,
/// not a reusable design-system dimension.
const double _sheetInitialSize = 0.75;
const double _sheetMinSize = 0.5;
const double _sheetMaxSize = 0.8;

/// Shows the [InstrumentBottomSheet] for [instrument] as a modal layer above
/// the current screen (the Watchlist).
///
/// The modal sheet owns the barrier (dimming) and dismissal behaviour; the
/// Watchlist stays mounted and visible behind it. No route change happens:
/// dismissing the sheet returns to the Watchlist exactly as it was.
///
/// Content order reproduces the reference hierarchy
/// (`watchlist__bottomsheet__*`): instrument header → Buy/Sell → secondary
/// actions → market depth → "Show 20 depth". Every action is UI-only and
/// reports the project's temporary notice (ADR-010); no order, chart, alert,
/// note, GTT or depth expansion is created in this phase.
Future<void> showInstrumentBottomSheet(
  BuildContext context,
  WatchlistInstrument instrument,
) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) => DraggableScrollableSheet(
      initialChildSize: _sheetInitialSize,
      minChildSize: _sheetMinSize,
      maxChildSize: _sheetMaxSize,
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) =>
          // Scoped messenger + local Scaffold so temporary notices surface
          // *inside* the sheet. Without the inner Scaffold, the notice lands
          // on the Watchlist Scaffold behind the modal barrier (invisible
          // until the sheet is dismissed). Without the scoped messenger, the
          // root messenger would fan the SnackBar out to every registered
          // Scaffold (nested-Scaffold duplicate). Transparent so the modal's
          // own surface + rounded top keep painting the sheet background.
          ScaffoldMessenger(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: InstrumentBottomSheet(
                instrument: instrument,
                scrollController: scrollController,
              ),
            ),
          ),
    ),
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(TWRadii.large)),
    ),
    barrierLabel: 'Close instrument details',
    // Scroll-controlled so the sheet can grow past the Material default 9/16
    // ratio toward the top of the viewport (the reference sheet covers roughly
    // three quarters of the screen). The [DraggableScrollableSheet] owns the
    // expand/drag behaviour while the Watchlist stays mounted behind the
    // barrier; `useRootNavigator` keeps the modal above the app shell so the
    // bottom navigation is dimmed behind the barrier instead of staying
    // interactive below the sheet.
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
  );
}

/// The instrument bottom sheet contents.
///
/// The instrument header ([_SheetHeader]) is pinned at the top of the sheet
/// while the trade/depth body scrolls beneath it: the layout is a fixed
/// header over an [Expanded] scroll view driven by the
/// [DraggableScrollableSheet]'s controller, so upward drags first expand the
/// sheet toward the top of the viewport and then scroll the body — the header
/// never scrolls away. A static preview composition; all interaction is
/// honest temporary behaviour via [_notice]-style notices (ADR-010).
class InstrumentBottomSheet extends StatefulWidget {
  const InstrumentBottomSheet({
    super.key,
    required this.instrument,
    this.depth = kInstrumentDepthPreview,
    this.scrollController,
  });

  final WatchlistInstrument instrument;

  /// Static preview rows for the bid/offer ladder. Defaults to the preview
  /// constant so the widget itself never owns mock data (ADR-004/005).
  final List<MarketDepthRow> depth;

  /// Scroll controller owned by the enclosing [DraggableScrollableSheet].
  /// Null in direct-widget usage, where the sheet owns its own controller;
  /// always provided by [showInstrumentBottomSheet].
  final ScrollController? scrollController;

  @override
  State<InstrumentBottomSheet> createState() => _InstrumentBottomSheetState();
}

class _InstrumentBottomSheetState extends State<InstrumentBottomSheet> {
  ScrollController? _ownedController;

  ScrollController get _effectiveController =>
      widget.scrollController ?? (_ownedController ??= ScrollController());

  @override
  void dispose() {
    _ownedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        InstrumentSheetHeader(
          symbol: widget.instrument.symbol,
          exchange: widget.instrument.exchange,
          price: widget.instrument.price,
          change: widget.instrument.change,
          changePercent: widget.instrument.changePercent,
        ),
        const Divider(height: 20),
        Expanded(
          child: CustomScrollView(
            controller: _effectiveController,
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: TWSpacing.l),
                    InstrumentSheetTradeActions(
                      primaryLabel: 'BUY',
                      negativeLabel: 'SELL',
                      onPrimaryPressed: () =>
                          _openOrder(context, OrderSide.buy),
                      onNegativePressed: () =>
                          _openOrder(context, OrderSide.sell),
                    ),
                    const SizedBox(height: TWSpacing.l),
                    const Divider(height: 1),
                    const SizedBox(height: TWSpacing.l),
                    InstrumentSheetSecondaryActions(
                      onNotice: (String m) => _notice(context, m),
                      showAddNotes: true,
                    ),
                    InstrumentSheetMarketDepth(
                      depth: kInstrumentDepthPreview
                          .map(
                            (e) => InstrumentDepthRow(
                              price: e.price,
                              orders: e.orders,
                              quantity: e.quantity,
                            ),
                          )
                          .toList(),
                      onNotice: (String m) => _notice(context, m),
                    ),
                    InstrumentSheetShowDepth(
                      onNotice: (String m) => _notice(context, m),
                    ),
                    const SizedBox(height: TWSpacing.xxl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _notice(BuildContext context, String message) {
    // Hide any current notice first so each tap surfaces exactly one
    // visible SnackBar; queued bars would otherwise leave duplicate
    // offstage texts that exact-match finders match twice.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _openOrder(BuildContext context, OrderSide side) {
    Navigator.of(context).pop();
    GoRouter.of(context).push(
      AppRoutes.order,
      extra: OrderLaunchArgs(instrument: widget.instrument, side: side),
    );
  }
}
