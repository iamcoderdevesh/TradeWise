import 'package:flutter/material.dart';

import 'package:tradewise/app/theme/tw_spacing.dart';

/// Orders empty state.
///
/// Mirrors the Watchlist empty state's anatomy: `Center` + `Padding(xxl)` +
/// `Column(mainAxisSize.min)` + rounded icon container + `titleLarge` title +
/// centered `bodyMedium` helper. Copy is order-specific ("No pending orders")
/// because there is currently no pending-order functionality.
class OrdersEmptyState extends StatelessWidget {
  const OrdersEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
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
                Icons.access_time,
                size: 48,
                color: theme.colorScheme.primary,
                semanticLabel: 'Empty orders illustration',
              ),
            ),
            const SizedBox(height: TWSpacing.l),
            Text(
              'No pending orders',
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
