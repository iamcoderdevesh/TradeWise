import 'package:flutter/material.dart';

import 'package:tradewise/app/theme/tw_colors.dart';
import 'package:tradewise/app/theme/tw_spacing.dart';
import 'package:tradewise/core/models/index_quote.dart';
import 'package:tradewise/features/watchlist/presentation/watchlist_number_format.dart';

/// Market-index strip for the Profile screen.
///
/// Mirrors the Watchlist `IndexStrip` pattern: two index columns side by side,
/// each a two-line column (uppercase name over value + signed change), with a
/// trailing dropdown control. Reuses the shared [IndexQuote] model — no
/// coupling to Watchlist's presentation layer.
class ProfileMarketStrip extends StatelessWidget {
  const ProfileMarketStrip({
    super.key,
    this.indices = kProfileIndexStripPreview,
    this.onExpandTap,
  });

  final List<IndexQuote> indices;
  final VoidCallback? onExpandTap;

  static const List<IndexQuote> kProfileIndexStripPreview = <IndexQuote>[
    IndexQuote(
      name: 'NIFTY 50',
      value: 25144.30,
      change: -155.05,
      changePercent: -0.61,
    ),
    IndexQuote(
      name: 'NIFTY BANK',
      value: 61034.10,
      change: -484.40,
      changePercent: -0.79,
    ),
  ];

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
