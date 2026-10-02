import 'package:flutter/material.dart';

import 'package:tradewise/app/theme/tw_spacing.dart';

/// TradeWise-original empty state.
///
/// Deliberately icon-based and geometric: a dashed-outline style rounded
/// container with a bookmark glyph, a bold title and a two-line helper. No
/// reference artwork is reproduced.
class WatchlistEmptyState extends StatelessWidget {
  const WatchlistEmptyState({super.key});

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
                Icons.bookmark_add_outlined,
                size: 48,
                color: theme.colorScheme.primary,
                semanticLabel: 'Empty watchlist illustration',
              ),
            ),
            const SizedBox(height: TWSpacing.l),
            Text(
              'Nothing here',
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TWSpacing.s),
            Text(
              'Use the search bar to add instruments to your watchlist',
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
