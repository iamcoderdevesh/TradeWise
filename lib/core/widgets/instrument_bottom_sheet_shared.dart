/// Shared instrument bottom-sheet components used by both Watchlist and
/// Portfolio features.
library;

import 'package:flutter/material.dart';

import 'package:tradewise/app/theme/tw_colors.dart';
import 'package:tradewise/app/theme/tw_radii.dart';
import 'package:tradewise/app/theme/tw_spacing.dart';
import 'package:tradewise/features/watchlist/presentation/watchlist_number_format.dart';

/// One market-depth row for the bid/offer ladder.
class InstrumentDepthRow {
  const InstrumentDepthRow({
    required this.price,
    required this.orders,
    required this.quantity,
  });

  final double price;
  final int orders;
  final int quantity;
}

const double sheetInitialSize = 0.75;
const double sheetMinSize = 0.5;
const double sheetMaxSize = 0.8;

/// Instrument identity: symbol over `exchange  price  change` plus optional
/// product badge.
class InstrumentSheetHeader extends StatelessWidget {
  const InstrumentSheetHeader({
    super.key,
    required this.symbol,
    required this.exchange,
    required this.price,
    required this.change,
    required this.changePercent,
    this.badgeLabel,
    this.badgeHighlighted = false,
  });

  final String symbol;
  final String exchange;
  final double price;
  final double change;
  final double changePercent;
  final String? badgeLabel;
  final bool badgeHighlighted;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color mutedColor = isDark
        ? TWColors.darkTextTertiary
        : TWColors.lightTextTertiary;
    final Color priceColor;
    if (change > 0) {
      priceColor = isDark ? TWColors.darkPositive : TWColors.lightPositive;
    } else if (change < 0) {
      priceColor = isDark ? TWColors.darkNegative : TWColors.lightNegative;
    } else {
      priceColor = isDark
          ? TWColors.darkTextPrimary
          : TWColors.lightTextPrimary;
    }
    final String changeText =
        '${formatWatchlistSigned(change)} '
        '(${formatWatchlistPercent(changePercent)})';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TWSpacing.l,
        TWSpacing.l,
        TWSpacing.l,
        0,
      ),
      child: Semantics(
        header: true,
        label:
            '$symbol, $exchange, price ${_formatPrice(price)}, change $change',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              symbol,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: TWSpacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  exchange,
                  style: textTheme.bodySmall?.copyWith(
                    color: mutedColor,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                ),
                const SizedBox(width: TWSpacing.m),
                Text(
                  _formatPrice(price),
                  style: textTheme.bodySmall?.copyWith(color: priceColor),
                  maxLines: 1,
                ),
                const SizedBox(width: TWSpacing.m),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(right: TWSpacing.xs),
                    child: Text(
                      changeText,
                      style: textTheme.bodySmall?.copyWith(
                        color: mutedColor,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: TWSpacing.s),
            if (badgeLabel != null) ...<Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _ProductBadge(
                    label: badgeLabel!,
                    highlighted: badgeHighlighted,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatPrice(double value) {
    final String fixed = value.toStringAsFixed(2);
    final int dot = fixed.indexOf('.');
    final String whole = fixed.substring(0, dot);
    final String fraction = fixed.substring(dot);
    final bool isNegative = whole.startsWith('-');
    final String digits = isNegative ? whole.substring(1) : whole;
    final StringBuffer grouped = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) grouped.write(',');
      grouped.write(digits[i]);
    }
    return '${isNegative ? '-' : ''}$grouped$fraction';
  }
}

/// Small tinted product chip at the header's right side.
class _ProductBadge extends StatelessWidget {
  const _ProductBadge({required this.label, required this.highlighted});

  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color accent = isDark ? TWColors.darkPrimary : TWColors.lightPrimary;
    final Color background = highlighted
        ? accent.withValues(alpha: 0.14)
        : Theme.of(context).dividerColor.withValues(alpha: 0.5);
    final Color foreground = highlighted
        ? accent
        : (isDark ? TWColors.darkTextTertiary : TWColors.lightTextTertiary);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TWSpacing.s,
        vertical: TWSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(TWRadii.small),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: foreground, fontWeight: FontWeight.w500),
        maxLines: 1,
      ),
    );
  }
}

/// Side-by-side primary / negative filled buttons (e.g. BUY/SELL or ADD/EXIT).
class InstrumentSheetTradeActions extends StatelessWidget {
  const InstrumentSheetTradeActions({
    super.key,
    required this.primaryLabel,
    required this.negativeLabel,
    required this.onPrimaryPressed,
    required this.onNegativePressed,
    this.negativeEnabled = true,
  });

  final String primaryLabel;
  final String negativeLabel;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onNegativePressed;
  final bool negativeEnabled;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(TWSpacing.l, 0, TWSpacing.l, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: FilledButton(
              onPressed: onPrimaryPressed,
              style: _primaryStyle(context),
              child: Text(primaryLabel),
            ),
          ),
          const SizedBox(width: TWSpacing.m),
          Expanded(
            child: FilledButton(
              onPressed: negativeEnabled && onNegativePressed != null
                  ? onNegativePressed
                  : null,
              style: _negativeStyle(context, isDark),
              child: Text(negativeLabel),
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle _primaryStyle(BuildContext context) => FilledButton.styleFrom(
    minimumSize: const Size(48, 52),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(TWRadii.medium),
    ),
    textStyle: Theme.of(context).textTheme.labelLarge,
  );

  ButtonStyle _negativeStyle(BuildContext context, bool isDark) =>
      FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TWRadii.medium),
        ),
        textStyle: Theme.of(context).textTheme.labelLarge,
        backgroundColor: isDark
            ? TWColors.darkNegative
            : TWColors.lightNegative,
        foregroundColor: isDark
            ? TWColors.darkOnNegative
            : TWColors.lightOnNegative,
      );
}

/// Two rows of secondary actions: `View chart | Option chain` and
/// `Set alert | Create GTT` (plus `Add notes` when [showAddNotes] is true).
class InstrumentSheetSecondaryActions extends StatelessWidget {
  const InstrumentSheetSecondaryActions({
    super.key,
    required this.onNotice,
    this.showAddNotes = false,
  });

  final ValueChanged<String> onNotice;
  final bool showAddNotes;

  @override
  Widget build(BuildContext context) {
    final Color actionColor = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(TWSpacing.m, 0, TWSpacing.m, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: InstrumentSheetActionLink(
                  icon: Icons.bar_chart,
                  label: 'View chart',
                  color: actionColor,
                  onTap: () => onNotice('View chart is not available yet'),
                ),
              ),
              InstrumentSheetActionLink(
                icon: Icons.toll,
                label: 'Option chain',
                color: actionColor,
                onTap: () => onNotice('Option chain is not available yet'),
              ),
            ],
          ),
          const Divider(height: 10),
          Row(
            children: <Widget>[
              Flexible(
                child: InstrumentSheetActionLink(
                  icon: Icons.notifications_none,
                  label: 'Set alert',
                  color: actionColor,
                  onTap: () => onNotice('Set alert is not available yet'),
                ),
              ),
              if (showAddNotes)
                Flexible(
                  child: InstrumentSheetActionLink(
                    icon: Icons.note_add,
                    label: 'Add notes',
                    color: actionColor,
                    onTap: () => onNotice('Add notes is not available yet'),
                  ),
                ),
              Flexible(
                child: InstrumentSheetActionLink(
                  icon: Icons.timer,
                  label: 'Create GTT',
                  color: actionColor,
                  onTap: () => onNotice('Create GTT is not available yet'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One secondary action: outlined icon + primary label with a 48dp target.
class InstrumentSheetActionLink extends StatelessWidget {
  const InstrumentSheetActionLink({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(context).textTheme.bodyMedium
        ?.copyWith(color: color, fontWeight: FontWeight.w500);
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ExcludeSemantics(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(icon, size: 20, color: color),
                  const SizedBox(width: TWSpacing.m),
                  Text(
                    label,
                    style: style,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Market depth ladder beneath the secondary actions.
class InstrumentSheetMarketDepth extends StatelessWidget {
  const InstrumentSheetMarketDepth({
    super.key,
    required this.depth,
    required this.onNotice,
  });

  final List<InstrumentDepthRow> depth;
  final ValueChanged<String> onNotice;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bidColor = isDark
        ? TWColors.darkPositive
        : TWColors.lightPositive;
    final Color offerColor = isDark
        ? TWColors.darkNegative
        : TWColors.lightNegative;
    final Color numberColor = isDark
        ? TWColors.darkTextTertiary
        : TWColors.lightTextTertiary;
    final TextStyle totalStyle =
        Theme.of(context).textTheme.bodySmall ?? const TextStyle();

    Widget headerCell(String label, TextAlign align) => Expanded(
      child: Text(
        label,
        style: totalStyle.copyWith(color: numberColor),
        maxLines: 1,
        textAlign: align,
      ),
    );
    Widget valueCell(String value, Color color, TextAlign align) => Expanded(
      child: Text(
        value,
        style: totalStyle.copyWith(color: color),
        maxLines: 1,
        textAlign: align,
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TWSpacing.l,
        0,
        TWSpacing.l,
        TWSpacing.s,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: TWSpacing.l),
          Row(
            children: <Widget>[
              headerCell('Bid', TextAlign.start),
              headerCell('Orders', TextAlign.center),
              headerCell('Qty', TextAlign.end),
              const SizedBox(width: TWSpacing.s),
              headerCell('Offer', TextAlign.start),
              headerCell('Orders', TextAlign.center),
              headerCell('Qty', TextAlign.end),
            ],
          ),
          const SizedBox(height: TWSpacing.s),
          for (final InstrumentDepthRow row in depth)
            Padding(
              padding: const EdgeInsets.only(
                top: TWSpacing.xs,
                bottom: TWSpacing.xs,
              ),
              child: Row(
                children: <Widget>[
                  valueCell(_formatPrice(row.price), bidColor, TextAlign.start),
                  valueCell('${row.orders}', numberColor, TextAlign.center),
                  valueCell('${row.quantity}', numberColor, TextAlign.end),
                  const SizedBox(width: TWSpacing.s),
                  valueCell(
                    _formatPrice(row.price),
                    offerColor,
                    TextAlign.start,
                  ),
                  valueCell('${row.orders}', numberColor, TextAlign.center),
                  valueCell('${row.quantity}', numberColor, TextAlign.end),
                ],
              ),
            ),
          const SizedBox(height: TWSpacing.s),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Total',
                  style: totalStyle,
                  maxLines: 1,
                  textAlign: TextAlign.start,
                ),
              ),
              const Expanded(child: SizedBox()),
              Expanded(
                child: Text(
                  _totalQuantity.toString(),
                  style: totalStyle,
                  maxLines: 1,
                  textAlign: TextAlign.end,
                ),
              ),
              const SizedBox(width: TWSpacing.s),
              Expanded(
                child: Text(
                  'Total',
                  style: totalStyle,
                  maxLines: 1,
                  textAlign: TextAlign.start,
                ),
              ),
              const Expanded(child: SizedBox()),
              Expanded(
                child: Text(
                  _totalQuantity.toString(),
                  style: totalStyle,
                  maxLines: 1,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPrice(double value) {
    final String fixed = value.toStringAsFixed(2);
    final int dot = fixed.indexOf('.');
    final String whole = fixed.substring(0, dot);
    final String fraction = fixed.substring(dot);
    final bool isNegative = whole.startsWith('-');
    final String digits = isNegative ? whole.substring(1) : whole;
    final StringBuffer grouped = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) grouped.write(',');
      grouped.write(digits[i]);
    }
    return '${isNegative ? '-' : ''}$grouped$fraction';
  }

  int get _totalQuantity =>
      depth.fold(0, (int sum, InstrumentDepthRow row) => sum + row.quantity);
}

/// Bottom-most "Show 20 depth" action.
class InstrumentSheetShowDepth extends StatelessWidget {
  const InstrumentSheetShowDepth({super.key, required this.onNotice});

  final ValueChanged<String> onNotice;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () => onNotice('20-level market depth is not available yet'),
        child: const Text('Show 20 depth'),
      ),
    );
  }
}
