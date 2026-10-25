import 'package:flutter/material.dart';

import 'package:tradewise/app/theme/tw_spacing.dart';
import 'package:tradewise/features/portfolio/data/portfolio_entry.dart';
import 'package:tradewise/features/portfolio/presentation/portfolio_providers.dart';
import 'package:tradewise/features/portfolio/presentation/widgets/portfolio_empty_state.dart';
import 'package:tradewise/features/portfolio/presentation/widgets/portfolio_entry_tile.dart';

/// Scrollable region under the toolbar: the active rows of the selected
/// tab, an optional "Closed" section header, then the exited rows — or the
/// tab's empty state when there is nothing at all (reference structure).
class PortfolioEntryList extends StatelessWidget {
  const PortfolioEntryList({
    super.key,
    required this.state,
    this.tab,
    this.onEntryTap,
  });

  final PortfolioState state;

  /// The tab this list renders. Defaults to [state.selectedTab]; a non-null
  /// value lets a swipeable tab bar show each tab's content independently.
  final PortfolioTab? tab;

  /// Row tap hook; passes the tapped [PortfolioEntry] so the screen can open
  /// the instrument bottom sheet for that instrument. When null the rows are
  /// non-interactive (details do not exist yet in this phase).
  final ValueChanged<PortfolioEntry>? onEntryTap;

  @override
  Widget build(BuildContext context) {
    final PortfolioTab activeTab = tab ?? state.selectedTab;
    final List<PortfolioEntry> active = state.activeEntriesFor(activeTab);
    final List<PortfolioEntry> closed = state.closedEntriesFor(activeTab);

    if (active.isEmpty && closed.isEmpty) {
      return PortfolioEmptyState(tab: activeTab);
    }

    // `null` marks the "Closed" section header slot.
    final List<PortfolioEntry?> rows = <PortfolioEntry?>[
      ...active,
      if (closed.isNotEmpty) null,
      ...closed,
    ];

    return ListView.separated(
      itemCount: rows.length,
      separatorBuilder: (BuildContext context, int _) =>
          const Divider(height: 1),
      itemBuilder: (BuildContext context, int index) {
        final PortfolioEntry? entry = rows[index];
        if (entry == null) {
          return const _ClosedSectionHeader();
        }
        return PortfolioEntryTile(
          entry: entry,
          badgeLabel: activeTab == PortfolioTab.holdings
              ? 'HOLDING'
              : 'INTRADAY',
          onTap: () => onEntryTap?.call(entry),
        );
      },
    );
  }
}

/// Section label above the fully exited rows.
class _ClosedSectionHeader extends StatelessWidget {
  const _ClosedSectionHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: TWSpacing.l,
        vertical: TWSpacing.s,
      ),
      child: Text(
        'Closed',
        style: Theme.of(context).textTheme.labelLarge
            ?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
        maxLines: 1,
      ),
    );
  }
}
