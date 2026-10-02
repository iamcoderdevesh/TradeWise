import 'package:flutter/material.dart';

import 'package:tradewise/app/theme/tw_spacing.dart';

/// Horizontal watchlist tab selector.
///
/// UI-only: [tabs] are static labels, [selectedIndex] is local display state
/// lifted to the screen. Creating/renaming/deleting watchlists, persistence
/// and backend state are explicitly out of scope for Phase 3.
class WatchlistSelector extends StatelessWidget {
  const WatchlistSelector({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.onAddTap,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback? onAddTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: <Widget>[
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: TWSpacing.l),
              itemCount: tabs.length,
              separatorBuilder: (_, _) => const SizedBox(width: TWSpacing.l),
              itemBuilder: (BuildContext context, int index) {
                final bool selected = index == selectedIndex;
                return _SelectorTab(
                  label: tabs[index],
                  selected: selected,
                  onTap: () => onTabSelected(index),
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.layers_outlined, size: 22),
            onPressed: onAddTap,
            tooltip: 'Manage watchlists',
          ),
          const SizedBox(width: TWSpacing.s),
        ],
      ),
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
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color textColor = selected
        ? theme.colorScheme.primary
        : theme.textTheme.bodySmall?.color ?? theme.disabledColor;
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: TWSpacing.xs),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textColor,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}
