import 'package:flutter/material.dart';

import 'package:tradewise/app/theme/tw_colors.dart';
import 'package:tradewise/app/theme/tw_radii.dart';
import 'package:tradewise/app/theme/tw_spacing.dart';
import 'package:tradewise/features/order/presentation/order_enums.dart';

import 'connected_field_box.dart';

/// Market / Limit / Stop Loss price section reproducing the reference's
/// compact label-and-icon interaction.
///
/// The tappable label row (mode name + icon) and the connected box's swap
/// segment are the two mode affordances; both advance Market → Limit →
/// Stop Loss → Market. Market shows a non-editable diagonally hatched field
/// with a muted `0.00` placeholder; Limit and Stop Loss show separate
/// editable decimal price fields, each preserved while switching modes.
class PriceTypeSection extends StatelessWidget {
  const PriceTypeSection({
    super.key,
    required this.orderType,
    required this.accent,
    required this.priceController,
    required this.stopLossController,
    required this.onOrderTypeChanged,
  });

  final OrderType orderType;
  final Color accent;
  final TextEditingController priceController;
  final TextEditingController stopLossController;
  final ValueChanged<OrderType> onOrderTypeChanged;

  /// Mode shown after [orderType]; shared by the label row and the swap
  /// segment so both affordances advance the same way.
  static OrderType nextAfter(OrderType orderType) {
    final List<OrderType> values = OrderType.values;
    return values[(orderType.index + 1) % values.length];
  }

  @override
  Widget build(BuildContext context) {
    final bool isMarket = orderType == OrderType.market;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color mutedColor = isDark
        ? TWColors.darkTextTertiary
        : TWColors.lightTextTertiary;
    final OrderType target = nextAfter(orderType);
    final Color textColor = isDark
        ? TWColors.darkTextTertiary
        : TWColors.lightTextPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(
          button: true,
          label: _labelFor(orderType),
          child: InkWell(
            onTap: () => onOrderTypeChanged(target),
            borderRadius: BorderRadius.circular(6),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Align(
                alignment: Alignment.centerLeft,
                // The explicit semantics label above names this control;
                // excluding the visible text keeps exactly one unambiguous
                // node for finders and assistive technology.
                child: ExcludeSemantics(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        _labelFor(orderType),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w400,
                              color: textColor,
                            ),
                      ),
                      const SizedBox(width: TWSpacing.m),
                      Icon(
                        _iconFor(orderType),
                        size: 20,
                        color: isMarket ? mutedColor : accent,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: TWSpacing.s),
        if (isMarket)
          _MarketPriceField(
            mutedColor: mutedColor,
            accent: accent,
            onSwap: () => onOrderTypeChanged(OrderType.limit),
          )
        else
          _PriceFieldBox(
            controller: orderType == OrderType.limit
                ? priceController
                : stopLossController,
            accent: accent,
            segmentTooltip: _tooltipFor(orderType),
            onSwap: () => onOrderTypeChanged(nextAfter(orderType)),
          ),
      ],
    );
  }
}

/// Visible name of a price mode, also used as the label row's accessible
/// label (Market, Limit, Stop Loss).
String _labelFor(OrderType orderType) {
  switch (orderType) {
    case OrderType.market:
      return 'Market';
    case OrderType.limit:
      return 'Limit';
    case OrderType.stopLoss:
      return 'Stop Loss';
  }
}

/// Label-row icon per mode: Market is read-only (muted eye-off); the
/// editable modes carry the accent pencil / stop glyph.
IconData _iconFor(OrderType orderType) {
  switch (orderType) {
    case OrderType.market:
      return Icons.visibility_off_outlined;
    case OrderType.limit:
      return Icons.edit_outlined;
    case OrderType.stopLoss:
      return Icons.warning_amber_outlined;
  }
}

/// Swap-segment tooltip naming the mode it leads to.
String _tooltipFor(OrderType orderType) {
  return 'Switch to ${_labelFor(PriceTypeSection.nextAfter(orderType)).toLowerCase()} order';
}

/// Non-editable Market price: diagonal hatch fill with a muted placeholder,
/// so the field reads as intentionally unset rather than broken. The hatch is
/// clipped to the input area's interior (left corners rounded like the field,
/// right edge flush at the divider) so strokes never cross the border,
/// overlap the rounded corners, or leak into the swap segment. The connected
/// swap segment still advances to the next mode.
class _MarketPriceField extends StatelessWidget {
  const _MarketPriceField({
    required this.mutedColor,
    required this.accent,
    required this.onSwap,
  });

  final Color mutedColor;
  final Color accent;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    // CustomPaint does not clip its painter: strokes drawn at and beyond the
    // canvas edges would overlap the border and rounded corners and continue
    // into the swap segment. The clip keeps them inside the input area.
    final BorderRadius hatchClip = BorderRadius.only(
      topLeft: Radius.circular(TWRadii.medium),
      bottomLeft: Radius.circular(TWRadii.medium),
    );
    return Semantics(
      // Container so the descriptive label stays its own node instead of
      // concatenating into the surrounding scrollable's merged label.
      container: true,
      label: 'Market price: executes at the market price, no price to enter',
      child: ConnectedFieldBox(
        input: ClipRRect(
          borderRadius: hatchClip,
          child: CustomPaint(
            painter: _HatchPainter(color: Theme.of(context).dividerColor),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: TWSpacing.m),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '0.00',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: mutedColor,
                  ),
                ),
              ),
            ),
          ),
        ),
        segmentIcon: Icons.swap_horiz,
        segmentColor: accent,
        segmentTooltip: _tooltipFor(OrderType.market),
        // The disabled input itself is inert; the swap segment advances to
        // the next mode, matching the reference's active accent glyph.
        onSegmentTap: onSwap,
      ),
    );
  }
}

/// Editable price input shared by Limit and Stop Loss, differing only by
/// controller and swap target. Typing is preserved while switching modes —
/// each controller seeds from the displayed LTP only when empty or invalid.
class _PriceFieldBox extends StatelessWidget {
  const _PriceFieldBox({
    required this.controller,
    required this.accent,
    required this.segmentTooltip,
    required this.onSwap,
  });

  final TextEditingController controller;
  final Color accent;
  final String segmentTooltip;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    return ConnectedFieldBox(
      input: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(border: InputBorder.none),
        style: Theme.of(context).textTheme.headlineSmall
            ?.copyWith(fontWeight: FontWeight.w400),
      ),
      segmentIcon: Icons.swap_horiz,
      segmentColor: accent,
      segmentTooltip: segmentTooltip,
      onSegmentTap: onSwap,
    );
  }
}

/// Low-contrast 45° stripes for the disabled Market field.
class _HatchPainter extends CustomPainter {
  const _HatchPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const double spacing = 7;
    for (double x = -size.height; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_HatchPainter oldDelegate) => oldDelegate.color != color;
}
