import 'package:flutter/material.dart';

import 'package:tradewise/app/theme/tw_spacing.dart';

/// Row of Orders list actions between the Total P&L card and the list
/// (reference: search, filters, Group on the left; P&L chart on the right).
///
/// Phase 5: every action reports the established temporary notice
/// (ADR-010) — no search, grouping or chart view exists yet — and the
/// reference product's partner-brand action is deliberately not reproduced.
class OrdersToolbar extends StatelessWidget {
  const OrdersToolbar({super.key, required this.onNotice});

  final ValueChanged<String> onNotice;

  @override
  Widget build(BuildContext context) {
    final Color accent = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: TWSpacing.s,
        vertical: TWSpacing.xs,
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            height: 36,
            width: 36,
            child: Center(
              child: IconButton(
                tooltip: 'Search Orders',
                icon: const Icon(Icons.search, size: 22),
                color: accent,
                onPressed: () => onNotice('Search is not available yet'),
              ),
            ),
          ),
          SizedBox(
            height: 36,
            width: 36,
            child: Center(
              child: IconButton(
                tooltip: 'Orders filters',
                icon: const Icon(Icons.tune, size: 22),
                color: accent,
                onPressed: () => onNotice('Filters are not available yet'),
              ),
            ),
          ),
          const SizedBox(width: TWSpacing.l),
          const Spacer(),
          TextButton.icon(
            onPressed: () => onNotice('Tradebook are not available yet'),
            icon: const Icon(Icons.donut_large),
            label: const Text('Tradebook'),
            style: TextButton.styleFrom(
              foregroundColor: accent,
              padding: const EdgeInsets.symmetric(horizontal: TWSpacing.xs),
            ),
          ),
        ],
      ),
    );
  }
}
