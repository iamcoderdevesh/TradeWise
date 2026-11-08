import 'package:flutter/material.dart';

import 'package:tradewise/app/theme/tw_colors.dart';
import 'package:tradewise/app/theme/tw_radii.dart';
import 'package:tradewise/app/theme/tw_spacing.dart';
import 'package:tradewise/features/order/presentation/order_enums.dart';
import 'package:tradewise/features/orders/domain/order.dart';

/// One order-history row.
///
/// Mirrors the Watchlist instrument tile's structural pattern
/// (`Padding(h: l, v: m)` / `ConstrainedBox(minHeight: 48)` / `Row` /
/// `Expanded Column(left)` / `SizedBox(l)` / `Column(right)`) but with
/// order-specific information: side pill + symbol, exchange • product,
/// quantity, price, time, status pill.
class OrderTile extends StatelessWidget {
  const OrderTile({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color mutedColor = isDark
        ? TWColors.darkTextTertiary
        : TWColors.lightTextTertiary;
    final textTheme = Theme.of(context).textTheme;

    final Color statusColor;
    switch (order.status) {
      case OrderStatus.executed:
        statusColor = isDark ? TWColors.darkPositive : TWColors.lightPositive;
        break;
      case OrderStatus.open:
        statusColor = mutedColor;
        break;
    }

    final String timeText =
        '${order.executedAt.hour.toString().padLeft(2, '0')}:'
        '${order.executedAt.minute.toString().padLeft(2, '0')}:'
        '${order.executedAt.second.toString().padLeft(2, '0')}';

    final String statusText = order.status == OrderStatus.executed
        ? 'EXECUTED'
        : 'OPEN';

    return Semantics(
      label:
          '${order.side.name} ${order.quantity} × ${order.symbol}, '
          '${order.exchange} • ${order.product}, '
          'price ${_formatPrice(order.price)}, '
          '$statusText',
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TWSpacing.l,
            vertical: TWSpacing.m,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          _ProductBadge(
                            label: order.side == OrderSide.buy ? 'BUY' : 'SELL',
                            highlighted: true,
                          ),
                          const SizedBox(width: TWSpacing.s),
                          Text(
                            '${order.filledQuantity}/${order.quantity}',
                            style: textTheme.bodySmall?.copyWith(
                              color: mutedColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(height: TWSpacing.s),
                      Text(
                        order.symbol,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: TWSpacing.s),
                      Text(
                        '${order.exchange}   ${order.product}',
                        style: textTheme.bodySmall?.copyWith(color: mutedColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: TWSpacing.l),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.schedule, size: 14, color: mutedColor),
                        const SizedBox(width: TWSpacing.xs),
                        Text(
                          timeText,
                          style: textTheme.bodySmall?.copyWith(
                            color: mutedColor,
                          ),
                          maxLines: 1,
                        ),
                        const SizedBox(width: TWSpacing.s),
                        _ProductBadge(
                          label: statusText,
                          highlighted: true,
                          accentColor: statusColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: TWSpacing.s),
                    Text(
                      _formatPrice(order.price),
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(height: TWSpacing.s),
                    Text(
                      '${order.productCode}   ${_formatOrderType(order.orderType)}',
                      style: textTheme.bodySmall?.copyWith(color: mutedColor),
                      maxLines: 1,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatPrice(double value) {
    final String fixed = value.toStringAsFixed(2);
    final int dot = fixed.indexOf('.');
    final String whole = fixed.substring(0, dot);
    final String fraction = fixed.substring(dot);
    final bool isNegative = whole.startsWith('-');
    final String digits = isNegative ? whole.substring(1) : whole;

    final StringBuffer grouped = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        grouped.write(',');
      }
      grouped.write(digits[i]);
    }

    return '${isNegative ? '-' : ''}$grouped$fraction';
  }

  static String _formatOrderType(OrderType type) {
    switch (type) {
      case OrderType.market:
        return 'MARKET';
      case OrderType.limit:
        return 'LIMIT';
      case OrderType.stopLoss:
        return 'STOP LOSS';
    }
  }
}

/// Small tinted product chip at the row's top right.
class _ProductBadge extends StatelessWidget {
  const _ProductBadge({
    required this.label,
    required this.highlighted,
    this.accentColor,
  });

  final String label;
  final bool highlighted;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color accent =
        accentColor ?? (isDark ? TWColors.darkPrimary : TWColors.lightPrimary);

    final Color background = highlighted
        ? accent.withValues(alpha: 0.14)
        : Theme.of(context).dividerColor.withValues(alpha: 0.5);

    final Color foreground = highlighted
        ? accent
        : (isDark ? TWColors.darkTextTertiary : TWColors.lightTextTertiary);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TWSpacing.s,
        vertical: TWSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(TWRadii.small),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: foreground, fontWeight: FontWeight.w500),
        maxLines: 1,
      ),
    );
  }
}
