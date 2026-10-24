import 'package:flutter/material.dart';

import 'package:tradewise/app/theme/tw_colors.dart';
import 'package:tradewise/app/theme/tw_radii.dart';
import 'package:tradewise/app/theme/tw_spacing.dart';
import 'package:tradewise/features/portfolio/data/portfolio_entry.dart';
import 'package:tradewise/features/watchlist/presentation/watchlist_number_format.dart';

/// One Portfolio list row (reference: qty/average line with a product badge,
/// symbol with signed P&L, exchange with LTP).
///
/// Closed rows keep their realised P&L but render dimmed, matching the
/// reference's exited-positions treatment. The badge labels are
/// TradeWise's own product vocabulary (HOLDING / INTRADAY), not the
/// reference product's product codes.
class PortfolioEntryTile extends StatelessWidget {
  const PortfolioEntryTile({
    super.key,
    required this.entry,
    required this.badgeLabel,
    required this.onTap,
  });

  final PortfolioEntry entry;
  final String badgeLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color qtyColor;
    final Color mutedColor = isDark
        ? TWColors.darkTextTertiary
        : TWColors.lightTextTertiary;
    if (entry.quantity > 0) {
      qtyColor = theme.colorScheme.primary;
    } else if (entry.quantity < 0) {
      qtyColor = isDark ? TWColors.darkNegative : TWColors.lightNegative;
    } else {
      qtyColor = theme.textTheme.bodySmall?.color ?? theme.disabledColor;
    }
    final Color pnlColor;
    if (entry.pnl > 0) {
      pnlColor = isDark ? TWColors.darkPositive : TWColors.lightPositive;
    } else if (entry.pnl < 0) {
      pnlColor = isDark ? TWColors.darkNegative : TWColors.lightNegative;
    } else {
      pnlColor = theme.textTheme.bodySmall?.color ?? theme.disabledColor;
    }

    final Widget content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: TWSpacing.l,
        vertical: TWSpacing.m,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: _QtyAvgLine(
                  qtyColor: qtyColor,
                  entry: entry,
                  mutedColor: mutedColor,
                ),
              ),
              _ProductBadge(label: badgeLabel, highlighted: !entry.isClosed),
            ],
          ),
          const SizedBox(height: TWSpacing.s),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  entry.symbol,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                formatWatchlistSigned(entry.pnl),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: pnlColor,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
              ),
            ],
          ),
          const SizedBox(height: TWSpacing.s),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  entry.exchange,
                  style: theme.textTheme.bodySmall!.copyWith(color: mutedColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: theme.textTheme.bodySmall,
                  children: <TextSpan>[
                    TextSpan(
                      text: 'LTP ',
                      style: TextStyle(color: mutedColor),
                    ),
                    TextSpan(text: formatWatchlistPrice(entry.lastTradedPrice)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return Semantics(
      button: true,
      label:
          '${entry.symbol}, ${entry.exchange}, quantity ${entry.quantity}, '
          'P&L ${formatWatchlistSigned(entry.pnl)}, '
          'LTP ${formatWatchlistPrice(entry.lastTradedPrice)}',
      child: InkWell(
        onTap: onTap,
        child: Opacity(opacity: entry.isClosed ? 0.6 : 1, child: content),
      ),
    );
  }
}

/// `Qty. 10  Avg. 64.70` line; the quantity carries the positive/negative
/// accent, the rest stays muted.
class _QtyAvgLine extends StatelessWidget {
  const _QtyAvgLine({
    required this.qtyColor,
    required this.mutedColor,
    required this.entry,
  });

  final Color qtyColor;
  final Color mutedColor;
  final PortfolioEntry entry;

  @override
  Widget build(BuildContext context) {
    final TextStyle? muted = Theme.of(context).textTheme.bodySmall;
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: muted,
        children: <TextSpan>[
          TextSpan(
            text: 'Qty. ',
            style: TextStyle(color: mutedColor),
          ),
          TextSpan(
            text: '${entry.quantity}',
            style: TextStyle(color: qtyColor),
          ),
          const TextSpan(text: '   '),
          TextSpan(
            text: 'Avg. ',
            style: TextStyle(color: mutedColor),
          ),
          TextSpan(text: formatWatchlistPrice(entry.averagePrice)),
        ],
      ),
    );
  }
}

/// Small tinted product chip at the row's top right.
class _ProductBadge extends StatelessWidget {
  const _ProductBadge({required this.label, required this.highlighted});

  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color accent = isDark ? TWColors.darkPrimary : TWColors.lightPrimary;
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
