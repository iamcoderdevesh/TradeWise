import 'package:flutter/material.dart';
import 'package:tradewise/app/theme/tw_colors.dart';
import 'package:tradewise/app/theme/tw_radii.dart';
import 'package:tradewise/app/theme/tw_spacing.dart';

/// Open / Executed tab selector.
///
/// Each tab occupies exactly 50% of the available width. The selected tab is
/// primary-coloured with a centered bottom underline; the inactive tab is
/// muted. Follows the Watchlist selector's InkWell-based tab pattern.
class OrdersTabSelector extends StatelessWidget {
  const OrdersTabSelector({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (int index = 0; index < tabs.length; index += 1)
          Expanded(
            child: _SelectorTab(
              label: tabs[index],
              selected: index == selectedIndex,
              onTap: () => onTabSelected(index),
            ),
          ),
      ],
    );
  }
}

class _SelectorTab extends StatelessWidget {
  const _SelectorTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count = 0;
  final bool selected;
  final VoidCallback onTap;

  /// Local component measurement: the reference underline is ~40dp wide.
  static const double _indicatorWidth = 40;
  static const double _indicatorHeight = 3;
  static const double _badgeSize = 24;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color activeColor = theme.colorScheme.primary;
    final Color inactiveColor = isDark
        ? TWColors.darkTextTertiary
        : TWColors.lightTextTertiary;
    final Color color = selected ? activeColor : inactiveColor;

    return Semantics(
      button: true,
      selected: selected,
      label: count > 0 ? '$label, $count items' : label,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: TWSpacing.s),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Flexible so the label ellipsizes instead of overflowing
                  // the 160dp tab slot on 320dp screens / large text scale.
                  Flexible(
                    child: Text(
                      label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (count > 0) ...<Widget>[
                    const SizedBox(width: TWSpacing.s),
                    Container(
                      width: _badgeSize,
                      height: _badgeSize,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (selected ? activeColor : inactiveColor)
                            .withValues(alpha: 0.16),
                      ),
                      child: Text(
                        '$count',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: color,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: TWSpacing.xs),
              Container(
                width: _indicatorWidth,
                height: _indicatorHeight,
                decoration: BoxDecoration(
                  color: selected ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(TWRadii.pill),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
