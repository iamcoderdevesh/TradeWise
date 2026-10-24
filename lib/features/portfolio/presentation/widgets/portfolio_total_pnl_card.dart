import 'package:flutter/material.dart';

import 'package:tradewise/app/theme/tw_colors.dart';
import 'package:tradewise/app/theme/tw_radii.dart';
import 'package:tradewise/app/theme/tw_spacing.dart';
import 'package:tradewise/features/watchlist/presentation/watchlist_number_format.dart';

/// "Total P&L" summary card under the Portfolio tabs (reference: a rounded
/// card with a centred caption over a large signed total, coloured by the
/// semantic positive/negative pair).
class PortfolioTotalPnlCard extends StatelessWidget {
  const PortfolioTotalPnlCard({super.key, required this.totalPnl});

  final double totalPnl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color cardColor = isDark
        ? TWColors.darkSurfaceElevated
        : TWColors.lightSurface;
    final Color valueColor;
    if (totalPnl > 0) {
      valueColor = isDark ? TWColors.darkPositive : TWColors.lightPositive;
    } else if (totalPnl < 0) {
      valueColor = isDark ? TWColors.darkNegative : TWColors.lightNegative;
    } else {
      valueColor = theme.colorScheme.onSurface;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TWSpacing.l,
        TWSpacing.s,
        TWSpacing.l,
        TWSpacing.m,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TWSpacing.l,
          vertical: TWSpacing.xxl,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(TWRadii.small),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Total P&L',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: TWColors.darkTextTertiary,
              ),
              maxLines: 1,
            ),
            const SizedBox(height: TWSpacing.s),
            Text(
              formatWatchlistSigned(totalPnl),
              style: theme.textTheme.titleLarge?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
