/// Portfolio instrument bottom sheet.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tradewise/app/router/app_routes.dart';
import 'package:tradewise/app/theme/tw_radii.dart';
import 'package:tradewise/app/theme/tw_spacing.dart';
import 'package:tradewise/core/widgets/instrument_bottom_sheet_shared.dart';
import 'package:tradewise/features/order/presentation/order_enums.dart';
import 'package:tradewise/features/order/presentation/order_launch_args.dart';
import 'package:tradewise/features/portfolio/data/portfolio_entry.dart';
import 'package:tradewise/features/portfolio/presentation/portfolio_providers.dart';
import 'package:tradewise/features/watchlist/presentation/widgets/watchlist_preview_data.dart';

/// Shows the Portfolio instrument bottom sheet for [entry] on [tab].
Future<void> showPortfolioInstrumentBottomSheet(
  BuildContext context,
  PortfolioEntry entry,
  PortfolioTab tab,
) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) => DraggableScrollableSheet(
      initialChildSize: sheetInitialSize,
      minChildSize: sheetMinSize,
      maxChildSize: sheetMaxSize,
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) =>
          ScaffoldMessenger(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: _PortfolioInstrumentBottomSheet(
                entry: entry,
                tab: tab,
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
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
  );
}

class _PortfolioInstrumentBottomSheet extends StatefulWidget {
  const _PortfolioInstrumentBottomSheet({
    required this.entry,
    required this.tab,
    this.scrollController,
  });

  final PortfolioEntry entry;
  final PortfolioTab tab;
  final ScrollController? scrollController;

  @override
  State<_PortfolioInstrumentBottomSheet> createState() =>
      _PortfolioInstrumentBottomSheetState();
}

class _PortfolioInstrumentBottomSheetState
    extends State<_PortfolioInstrumentBottomSheet> {
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
          symbol: widget.entry.symbol,
          exchange: widget.entry.exchange,
          price: widget.entry.lastTradedPrice,
          change: 1.12,
          changePercent: 0.53,
          badgeLabel: widget.tab == PortfolioTab.holdings
              ? 'HOLDING'
              : 'INTRADAY',
          badgeHighlighted: widget.entry.quantity > 0,
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
                      primaryLabel: 'ADD',
                      negativeLabel: 'EXIT',
                      onPrimaryPressed: () =>
                          _openOrder(context, OrderSide.buy),
                      onNegativePressed: widget.entry.quantity > 0
                          ? () => _openOrder(context, OrderSide.sell)
                          : null,
                      negativeEnabled: widget.entry.quantity > 0,
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

  void _openOrder(BuildContext context, OrderSide side) {
    Navigator.of(context).pop();

    final WatchlistInstrument instrument = WatchlistInstrument(
      symbol: widget.entry.symbol,
      exchange: widget.entry.exchange,
      price: widget.entry.lastTradedPrice,
      change: 0,
      changePercent: 0,
      holdingQuantity: widget.entry.quantity,
    );

    int? initialQuantity;
    OrderProduct? initialProduct;

    if (side == OrderSide.sell) {
      initialQuantity = widget.entry.quantity;
      initialProduct = widget.tab == PortfolioTab.holdings
          ? OrderProduct.longterm
          : OrderProduct.intraday;
    }

    GoRouter.of(context).push(
      AppRoutes.order,
      extra: OrderLaunchArgs(
        instrument: instrument,
        side: side,
        initialQuantity: initialQuantity,
        initialProduct: initialProduct,
      ),
    );
  }

  void _notice(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
