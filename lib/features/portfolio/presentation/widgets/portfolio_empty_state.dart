import 'package:flutter/material.dart';

import 'package:tradewise/app/theme/tw_spacing.dart';
import 'package:tradewise/features/portfolio/presentation/portfolio_providers.dart';

/// TradeWise-original empty state for a Portfolio tab.
///
/// Deliberately icon-based and geometric like the Watchlist empty state: a
/// rounded outlined container with a portfolio glyph, a tab-specific title
/// and the shared helper pointing back at the Watchlist. No reference
/// artwork is reproduced (rules: original visual identity only).
class PortfolioEmptyState extends StatelessWidget {
  const PortfolioEmptyState({super.key, required this.tab});

  final PortfolioTab tab;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final String title = tab == PortfolioTab.holdings
        ? 'No holdings'
        : 'No positions';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TWSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.dividerColor, width: 2),
                color: theme.colorScheme.surface,
              ),
              child: Icon(
                Icons.pie_chart_outline,
                size: 48,
                color: theme.colorScheme.primary,
                semanticLabel: tab == PortfolioTab.holdings
                    ? 'Empty holdings illustration'
                    : 'Empty positions illustration',
              ),
            ),
            const SizedBox(height: TWSpacing.l),
            Text(
              title,
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TWSpacing.s),
            Text(
              'Place an order from your watchlist',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
