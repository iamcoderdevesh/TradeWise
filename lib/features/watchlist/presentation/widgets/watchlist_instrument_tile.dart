import 'package:flutter/material.dart';

import 'package:tradewise/app/theme/tw_colors.dart';
import 'package:tradewise/app/theme/tw_spacing.dart';
import 'package:tradewise/features/watchlist/presentation/watchlist_number_format.dart';
import 'package:tradewise/features/watchlist/presentation/widgets/watchlist_preview_data.dart';

/// One watchlist list row: symbol/exchange left, price/change right.
///
/// Reference: `watchlist__single_item__*` — a two-line left column (uppercase
/// symbol over muted exchange) and a right-aligned two-line right column
/// (tabular price over signed change + percentage). The price carries the
/// semantic positive/negative colour (flat/zero uses primary text); the change
/// line stays muted rather than repeating the semantic colour.
///
/// Visual-review refinements applied here:
///  * symbol and price use the medium `titleMedium` / `titleSmall` roles so
///    the numerals lead instead of the weight;
///  * the exchange line and the change line share one muted `bodyMedium` style,
///    matching the reference's grey secondary rows;
///  * both columns use matching line-box heights, so the price/change pair
///    aligns exactly with the symbol/exchange pair instead of drifting by
///    their differing intrinsic metrics.
class WatchlistInstrumentTile extends StatelessWidget {
  const WatchlistInstrumentTile({
    super.key,
    required this.instrument,
    required this.onTap,
  });

  final WatchlistInstrument instrument;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color priceColor;
    if (instrument.change > 0) {
      priceColor = isDark ? TWColors.darkPositive : TWColors.lightPositive;
    } else if (instrument.change < 0) {
      priceColor = isDark ? TWColors.darkNegative : TWColors.lightNegative;
    } else {
      priceColor = isDark
          ? TWColors.darkTextPrimary
          : TWColors.lightTextPrimary;
    }
    final Color mutedColor = isDark
        ? TWColors.darkTextTertiary
        : TWColors.lightTextTertiary;
    final textTheme = Theme.of(context).textTheme;

    // The primary line (symbol / price) and the secondary line
    // (exchange / change) each share one line-box height so both columns align
    // on both rows. `titleSmall` is nudged to the `titleMedium` height for the
    // price, which is what keeps the two top lines on the same baseline.
    final TextStyle? symbolStyle = textTheme.bodyMedium;
    final TextStyle? priceStyle = textTheme.bodyMedium?.copyWith(
      color: priceColor,
      height: symbolStyle?.height,
    );
    final TextStyle? secondaryStyle = textTheme.bodySmall?.copyWith(
      color: mutedColor,
    );

    final String changeText =
        '${formatWatchlistSigned(instrument.change)}'
        '  (${formatWatchlistPercent(instrument.changePercent)})';

    return Semantics(
      button: true,
      label:
          '${instrument.symbol}, ${instrument.exchange}, '
          'price ${formatWatchlistPrice(instrument.price)}, change $changeText',
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TWSpacing.l,
            vertical: TWSpacing.m,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        instrument.symbol,
                        style: symbolStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      _ExchangeLine(
                        instrument: instrument,
                        style: secondaryStyle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: TWSpacing.l),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      formatWatchlistPrice(instrument.price),
                      style: priceStyle,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 8),
                    Text(changeText, style: secondaryStyle, maxLines: 1),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Exchange label plus optional passive holding badge (`NSE  10` in reference).
class _ExchangeLine extends StatelessWidget {
  const _ExchangeLine({required this.instrument, required this.style});

  final WatchlistInstrument instrument;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    
    if (instrument.holdingQuantity == null) {
      return Text(
        instrument.exchange,
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          child: Text(
            instrument.exchange,
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 6),
        Icon(Icons.work_outline, size: 15, color: style?.color),
        const SizedBox(width: 2),
        Text('${instrument.holdingQuantity}', style: style, maxLines: 1),
      ],
    );
  }
}
