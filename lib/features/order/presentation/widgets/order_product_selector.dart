import 'package:flutter/material.dart';

import 'package:tradewise/app/theme/tw_colors.dart';
import 'package:tradewise/app/theme/tw_radii.dart';
import 'package:tradewise/app/theme/tw_spacing.dart';
import 'package:tradewise/features/order/presentation/order_enums.dart';

/// Intraday / Longterm selector rendered as the order card's bottom band
/// (reference: a tinted footer strip inside the card, top divider, centered
/// radio pair). Local UI state only.
class OrderProductSelector extends StatelessWidget {
  const OrderProductSelector({
    super.key,
    required this.product,
    required this.accent,
    required this.onChanged,
  });

  final OrderProduct product;
  final Color accent;
  final ValueChanged<OrderProduct> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? TWColors.darkSurface : TWColors.lightSurfaceElevated,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: TWSpacing.s),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: _ProductOption(
                label: 'Intraday',
                selected: product == OrderProduct.intraday,
                accent: accent,
                onTap: () => onChanged(OrderProduct.intraday),
              ),
            ),
            const SizedBox(width: TWSpacing.xxl),
            Flexible(
              child: _ProductOption(
                label: 'Longterm',
                selected: product == OrderProduct.longterm,
                accent: accent,
                onTap: () => onChanged(OrderProduct.longterm),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One radio-style product option with a ≥48dp tap target.
class _ProductOption extends StatelessWidget {
  const _ProductOption({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TWRadii.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TWSpacing.s,
            vertical: TWSpacing.m,
          ),
          // The explicit semantics label above names this control; excluding
          // the visible text keeps exactly one unambiguous node.
          child: ExcludeSemantics(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 24,
                  color: selected ? accent : Theme.of(context).disabledColor,
                ),
                const SizedBox(width: TWSpacing.s),
                Flexible(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
