import 'package:flutter/material.dart';

import 'package:tradewise/app/theme/tw_colors.dart';
import 'package:tradewise/app/theme/tw_radii.dart';
import 'package:tradewise/app/theme/tw_spacing.dart';

/// Static "Search & add" card.
///
/// Visual structure only: a search affordance, a `n/250` counter slot and a
/// decorative sort/filter glyph. Real search is a later phase; taps surface
/// the project's temporary notice via [onTap].
///
/// Alignment note: [Card] applies a default 4dp margin, which inset the surface
/// relative to the instrument rows. The margin is zeroed here so the card's
/// left/right edges line up exactly with the rows and the header above it.
class WatchlistSearchBar extends StatelessWidget {
  const WatchlistSearchBar({
    super.key,
    required this.count,
    required this.capacity,
    this.onTap,
  });

  final int count;
  final int capacity;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color mutedColor = isDark
        ? TWColors.darkTextTertiary
        : TWColors.lightTextTertiary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TWSpacing.l, vertical: TWSpacing.l),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TWRadii.medium),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(TWRadii.medium),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: TWSpacing.l,
              vertical: TWSpacing.m,
            ),
            child: Row(
              children: <Widget>[
                Icon(Icons.search, size: 20, color: mutedColor),
                const SizedBox(width: TWSpacing.s),
                Expanded(
                  child: Text(
                    'Search & add',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: mutedColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '$count/$capacity',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: mutedColor,
                  ),
                  maxLines: 1,
                ),
                const SizedBox(width: TWSpacing.m),
                Icon(Icons.sort, size: 22, color: mutedColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
