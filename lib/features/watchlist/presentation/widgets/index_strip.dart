import 'package:flutter/material.dart';

import 'package:tradewise/app/theme/tw_colors.dart';
import 'package:tradewise/app/theme/tw_spacing.dart';
import 'package:tradewise/features/watchlist/presentation/watchlist_number_format.dart';
import 'package:tradewise/features/watchlist/presentation/widgets/watchlist_preview_data.dart';

/// Static market-index strip shown above the watchlist selector.
///
/// Structure mirrors the reference (`watchlist__with_data__*`): each index is a
/// two-line column — uppercase index name over a semantic value and a muted
/// change pair — laid out side by side with a gap and a trailing chevron
/// affordance. Only the value takes the semantic positive/negative colour so a
/// falling index reads red exactly as it does in the row list; the change
/// pair stays tertiary grey, matching the reference hierarchy.
///
/// UI preview only: [indices] defaults to hard-coded display values, not live
/// index data. Nothing is fetched, computed or subscribed to. The chevron uses
/// the project's temporary-notice pattern when tapped.
class IndexStrip extends StatelessWidget {
  const IndexStrip({
    super.key,
    this.indices = kIndexStripPreview,
    this.onExpandTap,
  });

  final List<IndexQuote> indices;
  final VoidCallback? onExpandTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: TWSpacing.l,
        right: TWSpacing.xs,
        top: TWSpacing.s,
        bottom: TWSpacing.s,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          for (final IndexQuote quote in indices)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: TWSpacing.s),
                child: _IndexColumn(quote: quote),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, size: 22),
            onPressed: onExpandTap,
            tooltip: 'Indices',
          ),
        ],
      ),
    );
  }
}

/// One two-line index column: name over value + signed change.
class _IndexColumn extends StatelessWidget {
  const _IndexColumn({required this.quote});

  final IndexQuote quote;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color semanticColor;
    if (quote.change > 0) {
      semanticColor = isDark ? TWColors.darkPositive : TWColors.lightPositive;
    } else if (quote.change < 0) {
      semanticColor = isDark ? TWColors.darkNegative : TWColors.lightNegative;
    } else {
      semanticColor = isDark
          ? TWColors.darkTextPrimary
          : TWColors.lightTextPrimary;
    }
    final Color mutedColor = isDark
        ? TWColors.darkTextTertiary
        : TWColors.lightTextTertiary;
    final Color nameColor = isDark
        ? TWColors.darkTextSecondary
        : TWColors.lightTextSecondary;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String changeText =
        '${formatWatchlistSigned(quote.change)} '
        '(${formatWatchlistPercent(quote.changePercent)})';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          quote.name,
          style: textTheme.bodySmall?.copyWith(
            color: nameColor,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 5),
        // Two value+pct pairs cannot be guaranteed to fit at the narrowest
        // supported width, and the reference itself truncates there
        // (NIFTY BANK shows no percentage). A scale-down box keeps the pair on
        // one line and legible instead of ellipsising a number.
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                formatWatchlistPrice(quote.value),
                style: textTheme.bodyMedium?.copyWith(
                  color: semanticColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                maxLines: 1,
              ),
              const SizedBox(width: TWSpacing.xs),
              Text(
                changeText,
                style: textTheme.bodyMedium?.copyWith(
                  color: mutedColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
