import 'package:flutter/material.dart';

import 'package:tradewise/app/theme/tw_colors.dart';
import 'package:tradewise/app/theme/tw_radii.dart';
import 'package:tradewise/app/theme/tw_spacing.dart';

/// Functional search card for the Watchlist screen.
///
/// Displays a search input field with the `n/250` capacity counter and a
/// decorative sort/filter glyph. As the user types, [onChanged] reports the
/// current query so the parent can filter the instrument list.
///
/// The counter always reflects the total watchlist capacity
/// (`count / capacity`), not the filtered result count, per the preservation
/// requirement.
///
/// Alignment note: [Card] applies a default 4dp margin, which inset the surface
/// relative to the instrument rows. The margin is zeroed here so the card's
/// left/right edges line up exactly with the rows and the header above it.
class WatchlistSearchBar extends StatelessWidget {
  const WatchlistSearchBar({
    super.key,
    required this.count,
    required this.capacity,
    required this.controller,
    required this.onChanged,
  });

  final int count;
  final int capacity;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color mutedColor = isDark
        ? TWColors.darkTextTertiary
        : TWColors.lightTextTertiary;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: TWSpacing.l,
        vertical: TWSpacing.l,
      ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TWRadii.medium),
        ),
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
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search & add',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: mutedColor,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isCollapsed: true,
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                  maxLines: 1,
                  controller: controller,
                  onChanged: onChanged,
                  onTap: () {},
                ),
              ),
              Text(
                '$count/$capacity',
                style: theme.textTheme.bodyMedium?.copyWith(color: mutedColor),
                maxLines: 1,
              ),
              const SizedBox(width: TWSpacing.m),
              Icon(Icons.sort, size: 22, color: mutedColor),
            ],
          ),
        ),
      ),
    );
  }
}
