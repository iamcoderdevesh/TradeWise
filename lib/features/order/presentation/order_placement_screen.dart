import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:tradewise/app/router/app_routes.dart';
import 'package:tradewise/app/theme/tw_colors.dart';
import 'package:tradewise/app/theme/tw_radii.dart';
import 'package:tradewise/app/theme/tw_spacing.dart';
import 'package:tradewise/features/portfolio/presentation/portfolio_providers.dart';
import 'package:tradewise/features/watchlist/presentation/watchlist_number_format.dart';

import 'order_enums.dart';
import 'order_launch_args.dart';
import 'order_math.dart';
import 'widgets/order_product_selector.dart';
import 'widgets/order_quantity_section.dart';
import 'widgets/price_type_section.dart';
import 'widgets/swipe_to_confirm.dart';

/// Buy/Sell order ticket (paper-trade simulation, Phase 5).
///
/// One shared screen driven by [OrderLaunchArgs.side]: buy accents resolve to
/// the theme primary, sell to the semantic negative pair. Market orders use
/// the instrument LTP as the estimate basis with a disabled price field;
/// Limit and Stop Loss take separate editable prices, each seeding from the
/// LTP only when empty or invalid. Quantity and Amount input modes convert
/// against the effective price with whole-share floor rounding (see
/// `order_math.dart`).
///
/// Completing the swipe applies one simulated order to the shared
/// [portfolioProvider] (no fees, margin or funds are computed):
///  * BUY always fills and lands on the matching Portfolio tab — Longterm
///    on Holdings, Intraday on Positions — which is also where the ticket
///    navigates to;
///  * SELL reduces or closes a matching open entry, and is rejected with a
///    notice when the portfolio holds no (or not enough) quantity to sell.
class OrderPlacementScreen extends ConsumerStatefulWidget {
  const OrderPlacementScreen({super.key, required this.args});

  final OrderLaunchArgs args;

  @override
  ConsumerState<OrderPlacementScreen> createState() =>
      _OrderPlacementScreenState();
}

class _OrderPlacementScreenState extends ConsumerState<OrderPlacementScreen> {
  OrderType _orderType = OrderType.market;
  OrderInputMode _inputMode = OrderInputMode.quantity;
  late OrderProduct _product;

  late final TextEditingController _quantityController;
  late final TextEditingController _amountController;
  late final TextEditingController _priceController;
  late final TextEditingController _stopLossController;

  @override
  void initState() {
    super.initState();
    _product = widget.args.initialProduct ?? OrderProduct.longterm;
    _quantityController = TextEditingController(
      text: widget.args.initialQuantity?.toString() ?? '1',
    )..addListener(_onFormChanged);
    _amountController = TextEditingController()..addListener(_onFormChanged);
    _priceController = TextEditingController(
      text: _formatMoneyInput(widget.args.instrument.price),
    )..addListener(_onFormChanged);
    _stopLossController = TextEditingController(
      text: _formatMoneyInput(widget.args.instrument.price),
    )..addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _amountController.dispose();
    _priceController.dispose();
    _stopLossController.dispose();
    super.dispose();
  }

  double get _ltp => widget.args.instrument.price;
  bool get _isBuy => widget.args.side == OrderSide.buy;

  /// Price the estimate is based on: LTP for Market, the entered price for
  /// Limit and Stop Loss. Null while an entered price is missing or invalid.
  double? get _effectivePrice {
    switch (_orderType) {
      case OrderType.market:
        return _ltp > 0 ? _ltp : null;
      case OrderType.limit:
        return parseOrderMoney(_priceController.text);
      case OrderType.stopLoss:
        return parseOrderMoney(_stopLossController.text);
    }
  }

  /// Whole-share quantity implied by the current inputs. In Amount mode this
  /// is the floored derivation; in Quantity mode it is the parsed input.
  int get _quantity {
    if (_inputMode == OrderInputMode.amount) {
      return indicativeQuantity(
        amount: parseOrderMoney(_amountController.text),
        price: _effectivePrice,
      );
    }
    return parseOrderQuantity(_quantityController.text) ?? 0;
  }

  /// Whether the ticket holds a draft the simulation can apply. The guard
  /// keeps the swipe control honest against empty/zero input.
  bool get _isValid {
    if (_quantity < 1) {
      return false;
    }
    // Market needs no price; the editable modes need a positive entered one.
    // No buy/sell trigger-direction check: the UI models no trigger semantics.
    if (_orderType != OrderType.market) {
      final double? price = _effectivePrice;
      if (price == null || price <= 0) {
        return false;
      }
    }
    return true;
  }

  double? get _estimate {
    final double? price = _effectivePrice;
    if (price == null || _quantity < 1) {
      return null;
    }
    return estimateOrderAmount(quantity: _quantity, price: price);
  }

  /// What the estimate is based on: the displayed LTP for Market, the entered
  /// price for Limit / Stop Loss. Only local values — no fees, margin, funds.
  String get _estimateBasis {
    switch (_orderType) {
      case OrderType.market:
        return 'at the displayed price';
      case OrderType.limit:
        return 'at your limit price';
      case OrderType.stopLoss:
        return 'at your stop loss price';
    }
  }

  void _onFormChanged() => setState(() {});

  void _onTypeChanged(OrderType type) {
    if (type == _orderType) {
      return;
    }
    setState(() {
      _orderType = type;
      // Seed the entered mode from the displayed LTP only when it holds no
      // usable price, so typed values survive switching away and back.
      if (type == OrderType.limit) {
        _seedPrice(_priceController);
      } else if (type == OrderType.stopLoss) {
        _seedPrice(_stopLossController);
      }
    });
  }

  /// Fills [controller] with the displayed LTP when its current text parses
  /// to nothing usable — typed entries always win over the seed.
  void _seedPrice(TextEditingController controller) {
    final double? current = parseOrderMoney(controller.text);
    if (current == null || current <= 0) {
      controller.text = _formatMoneyInput(_ltp);
    }
  }

  void _onInputModeChanged(OrderInputMode mode) {
    if (mode == _inputMode) {
      return;
    }
    setState(() {
      _inputMode = mode;
      if (mode == OrderInputMode.amount) {
        // Seed the amount from the current quantity so the derived quantity
        // stays continuous across the switch.
        final double? price = _effectivePrice;
        final int quantity = parseOrderQuantity(_quantityController.text) ?? 0;
        if (price != null && quantity > 0) {
          _amountController.text = _formatMoneyInput(quantity * price);
        } else {
          _amountController.clear();
        }
      } else {
        // Seed the quantity from the derived amount where one exists.
        final int derived = indicativeQuantity(
          amount: parseOrderMoney(_amountController.text),
          price: _effectivePrice,
        );
        if (derived > 0) {
          _quantityController.text = '$derived';
        }
      }
    });
  }

  void _onSwipeComplete() {
    final PaperOrderResult result = ref
        .read(portfolioProvider.notifier)
        .applyOrder(
          side: widget.args.side,
          product: _product,
          symbol: widget.args.instrument.symbol,
          exchange: widget.args.instrument.exchange,
          quantity: _quantity,
          price: _effectivePrice ?? 0,
          lastTradedPrice: _ltp,
        );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(result.message)));

    // A filled BUY lands on the tab it filled (Longterm → Holdings,
    // Intraday → Positions). SELL stays on the ticket so a rejected sell
    // can be corrected; the notice above explains the outcome either way.
    final bool isBuy = widget.args.side == OrderSide.buy;
    if (result.filled && isBuy && GoRouter.maybeOf(context) != null) {
      context.go(AppRoutes.portfolio);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color accent = _isBuy
        ? Theme.of(context).colorScheme.primary
        : (isDark ? TWColors.darkNegative : TWColors.lightNegative);
    final Color onAccent = _isBuy
        ? Theme.of(context).colorScheme.onPrimary
        : (isDark ? TWColors.darkOnNegative : TWColors.lightOnNegative);
    // Reference composition: gray page, white (dark: elevated) card with a
    // modest radius, tinted bands for the exchange strip and estimate row.
    final Color pageColor = isDark
        ? TWColors.darkBackgroundPrimary
        : TWColors.lightBackgroundSecondary;
    final Color cardColor = isDark
        ? TWColors.darkSurfaceElevated
        : TWColors.lightSurface;
    final Color bandColor = isDark
        ? TWColors.darkSurface
        : TWColors.lightSurfaceElevated;

    return Scaffold(
      backgroundColor: pageColor,
      appBar: AppBar(
        backgroundColor: pageColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          widget.args.instrument.symbol,
          maxLines: 1,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w400),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  top: TWSpacing.s,
                  bottom: TWSpacing.l,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _ExchangeStrip(
                      exchange: widget.args.instrument.exchange,
                      price: _ltp,
                      accent: accent,
                      color: bandColor,
                    ),
                    const SizedBox(height: TWSpacing.m),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: TWSpacing.l,
                      ),
                      child: Card(
                        margin: EdgeInsets.zero,
                        elevation: 0,
                        clipBehavior: Clip.antiAlias,
                        color: cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(TWRadii.medium),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(TWSpacing.l),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  OrderQuantitySection(
                                    inputMode: _inputMode,
                                    accent: accent,
                                    quantityController: _quantityController,
                                    amountController: _amountController,
                                    derivedQuantity:
                                        _inputMode == OrderInputMode.amount
                                        ? _quantity
                                        : null,
                                    onInputModeChanged: _onInputModeChanged,
                                  ),
                                  const SizedBox(height: TWSpacing.l),
                                  PriceTypeSection(
                                    orderType: _orderType,
                                    accent: accent,
                                    priceController: _priceController,
                                    stopLossController: _stopLossController,
                                    onOrderTypeChanged: _onTypeChanged,
                                  ),
                                ],
                              ),
                            ),
                            OrderProductSelector(
                              product: _product,
                              accent: accent,
                              onChanged: (OrderProduct product) =>
                                  setState(() => _product = product),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _EstimateBand(
              estimate: _estimate,
              estimateBasis: _estimateBasis,
              accent: accent,
              color: bandColor,
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: TWSpacing.s,
                bottom: TWSpacing.l,
              ),
              child: SwipeToConfirm(
                side: widget.args.side,
                accent: accent,
                onAccent: onAccent,
                enabled: _isValid,
                onCompleted: _onSwipeComplete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Read-only `● EXCHANGE ₹LTP` band flush under the app bar (reference:
/// a flat full-bleed strip with the selected exchange indicator).
///
/// Single-exchange only: the instrument model carries one exchange and one
/// quote, so no second (invented) exchange is shown.
class _ExchangeStrip extends StatelessWidget {
  const _ExchangeStrip({
    required this.exchange,
    required this.price,
    required this.accent,
    required this.color,
  });

  final String exchange;
  final double price;
  final Color accent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      padding: const EdgeInsets.symmetric(
        horizontal: TWSpacing.l,
        vertical: TWSpacing.m,
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.radio_button_checked, size: 20, color: accent),
          const SizedBox(width: TWSpacing.s),
          Text(
            exchange,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w300),
            maxLines: 1,
          ),
          const SizedBox(width: TWSpacing.s),
          Text(
            '₹${formatWatchlistPrice(price)}',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w400),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

/// Full-width information band directly above the swipe control (reference:
/// the footer band slot): the indicative estimate next to a static charges
/// line and an available-balance preview, with a trailing refresh
/// affordance. Every value is display-only — nothing is fetched, computed
/// or submitted (ADR-005) — and the value row scales down rather than
/// overflowing on narrow viewports.
class _EstimateBand extends StatelessWidget {
  const _EstimateBand({
    required this.estimate,
    required this.estimateBasis,
    required this.accent,
    required this.color,
  });

  final double? estimate;
  final String estimateBasis;
  final Color accent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (estimate == null) {
      return Container(
        color: color,
        padding: const EdgeInsets.symmetric(
          horizontal: TWSpacing.l,
          vertical: TWSpacing.m,
        ),
        child: Text(
          'Enter a valid quantity and price to see the estimated amount',
          style: Theme.of(context).textTheme.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
    return Container(
      color: color,
      padding: const EdgeInsets.symmetric(
        horizontal: TWSpacing.m,
        vertical: TWSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            // The fixed value row (Amount, charge, Avail.) measures wider
            // than a 320dp viewport allows, so the row scales down to fit
            // instead of overflowing the band.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Amount',
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                  ),
                  const SizedBox(width: TWSpacing.s),
                  Text(
                    '₹${formatWatchlistPrice(estimate!)}',
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: accent),
                    maxLines: 1,
                  ),
                  const SizedBox(width: TWSpacing.s),
                  Text('+', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(width: TWSpacing.s),
                  Text(
                    '₹0.08',
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: accent),
                    maxLines: 1,
                  ),
                  const SizedBox(width: TWSpacing.l),
                  Text(
                    'Avail.',
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                  ),
                  const SizedBox(width: TWSpacing.s),
                  Text(
                    '₹1000.00',
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: accent),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 36,
            width: 36,
            child: Center(
              child: IconButton(
                tooltip: 'Refresh',
                icon: Icon(
                  Icons.replay,
                  size: 18,
                  color: Theme.of(context).hintColor,
                ),
                onPressed: () => {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Editable money text without thousands grouping: grouping belongs to
/// display labels, not to typed input.
String _formatMoneyInput(double value) {
  if (!value.isFinite) {
    return '';
  }
  final String fixed = value.toStringAsFixed(2);
  final String trimmed = fixed.replaceAll(RegExp(r'0+$'), '');
  return trimmed.endsWith('.')
      ? trimmed.substring(0, trimmed.length - 1)
      : trimmed;
}
