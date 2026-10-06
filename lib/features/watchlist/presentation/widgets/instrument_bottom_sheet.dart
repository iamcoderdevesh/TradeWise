import 'package:flutter/material.dart';

import 'package:tradewise/app/theme/tw_colors.dart';
import 'package:tradewise/app/theme/tw_radii.dart';
import 'package:tradewise/app/theme/tw_spacing.dart';
import 'package:tradewise/features/watchlist/presentation/watchlist_number_format.dart';
import 'package:tradewise/features/watchlist/presentation/widgets/watchlist_preview_data.dart';

/// Sheet snap geometry as fractions of the available (safe-area-aware) height.
///
/// 0.7 initial reproduces the reference coverage (roughly three quarters of
/// the screen) while keeping the Watchlist recognisable behind the barrier;
/// the user can drag down to 0.5 or expand up to 0.92 toward the top of the
/// viewport. Values stay local: they describe this sheet's own drag range,
/// not a reusable design-system dimension.
const double _sheetInitialSize = 0.7;
const double _sheetMinSize = 0.5;
const double _sheetMaxSize = 0.92;

/// Shows the [InstrumentBottomSheet] for [instrument] as a modal layer above
/// the current screen (the Watchlist).
///
/// The modal sheet owns the barrier (dimming) and dismissal behaviour; the
/// Watchlist stays mounted and visible behind it. No route change happens:
/// dismissing the sheet returns to the Watchlist exactly as it was.
///
/// Content order reproduces the reference hierarchy
/// (`watchlist__bottomsheet__*`): instrument header → Buy/Sell → secondary
/// actions → market depth → "Show 20 depth". Every action is UI-only and
/// reports the project's temporary notice (ADR-010); no order, chart, alert,
/// note, GTT or depth expansion is created in this phase.
Future<void> showInstrumentBottomSheet(
  BuildContext context,
  WatchlistInstrument instrument,
) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) => DraggableScrollableSheet(
      initialChildSize: _sheetInitialSize,
      minChildSize: _sheetMinSize,
      maxChildSize: _sheetMaxSize,
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) =>
          InstrumentBottomSheet(
            instrument: instrument,
            scrollController: scrollController,
          ),
    ),
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(TWRadii.large)),
    ),
    barrierLabel: 'Close instrument details',
    // Scroll-controlled so the sheet can grow past the Material default 9/16
    // ratio toward the top of the viewport (the reference sheet covers roughly
    // three quarters of the screen). The [DraggableScrollableSheet] owns the
    // expand/drag behaviour while the Watchlist stays mounted behind the
    // barrier; `useRootNavigator` keeps the modal above the app shell so the
    // bottom navigation is dimmed behind the barrier instead of staying
    // interactive below the sheet.
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
  );
}

/// The instrument bottom sheet contents.
///
/// The instrument header ([_SheetHeader]) is pinned at the top of the sheet
/// while the trade/depth body scrolls beneath it: the layout is a fixed
/// header over an [Expanded] scroll view driven by the
/// [DraggableScrollableSheet]'s controller, so upward drags first expand the
/// sheet toward the top of the viewport and then scroll the body — the header
/// never scrolls away. A static preview composition; all interaction is
/// honest temporary behaviour via [_notice]-style notices (ADR-010).
class InstrumentBottomSheet extends StatefulWidget {
  const InstrumentBottomSheet({
    super.key,
    required this.instrument,
    this.depth = kInstrumentDepthPreview,
    this.scrollController,
  });

  final WatchlistInstrument instrument;

  /// Static preview rows for the bid/offer ladder. Defaults to the preview
  /// constant so the widget itself never owns mock data (ADR-004/005).
  final List<MarketDepthRow> depth;

  /// Scroll controller owned by the enclosing [DraggableScrollableSheet].
  /// Null in direct-widget usage, where the sheet owns its own controller;
  /// always provided by [showInstrumentBottomSheet].
  final ScrollController? scrollController;

  @override
  State<InstrumentBottomSheet> createState() => _InstrumentBottomSheetState();
}

class _InstrumentBottomSheetState extends State<InstrumentBottomSheet> {
  ScrollController? _ownedController;

  ScrollController get _effectiveController =>
      widget.scrollController ?? (_ownedController ??= ScrollController());

  @override
  void dispose() {
    _ownedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SheetHeader(instrument: widget.instrument),
        const Divider(height: 20),
        Expanded(
          child: CustomScrollView(
            controller: _effectiveController,
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: TWSpacing.l),
                    _TradeActions(onNotice: (String m) => _notice(context, m)),
                    const SizedBox(height: TWSpacing.l),
                    const Divider(height: 1),
                    const SizedBox(height: TWSpacing.l),
                    _SecondaryActions(
                      onNotice: (String m) => _notice(context, m),
                    ),
                    const SizedBox(height: TWSpacing.l),
                    _MarketDepthSection(
                      depth: widget.depth,
                      onNotice: (String m) => _notice(context, m),
                    ),
                    _ShowDepthAction(
                      onNotice: (String m) => _notice(context, m),
                    ),
                    const SizedBox(height: TWSpacing.xxl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _notice(BuildContext context, String message) {
    // Hide any current notice first so each tap surfaces exactly one
    // visible SnackBar; queued bars would otherwise leave duplicate
    // offstage texts that exact-match finders match twice.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Instrument identity: symbol over `exchange  price  change (+/-%)`.
///
/// The price carries the semantic positive/negative colour (flat/zero uses
/// primary text); the change pair stays tertiary muted, matching the Watchlist
/// hierarchy. Numbers use tabular figures.
class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.instrument});

  final WatchlistInstrument instrument;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final Color priceColor;
    if (instrument.change > 0) {
      priceColor = isDark ? TWColors.darkPositive : TWColors.lightPositive;
    } else if (instrument.change < 0) {
      priceColor = isDark ? TWColors.darkNegative : TWColors.lightNegative;
    } else {
      priceColor = isDark
          ? TWColors.darkTextPrimary
          : TWColors.lightTextPrimary;
    }
    final Color secondaryColor = isDark
        ? TWColors.darkTextSecondary
        : TWColors.lightTextSecondary;
    final Color mutedColor = isDark
        ? TWColors.darkTextTertiary
        : TWColors.lightTextTertiary;
    final String changeText =
        '${formatWatchlistSigned(instrument.change)} '
        '(${formatWatchlistPercent(instrument.changePercent)})';

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
            '${instrument.symbol}, ${instrument.exchange}, '
            'price ${formatWatchlistPrice(instrument.price)}, '
            'change $changeText',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              instrument.symbol,
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
                  instrument.exchange,
                  style: textTheme.bodySmall?.copyWith(
                    color: mutedColor,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                ),
                const SizedBox(width: TWSpacing.m),
                Text(
                  formatWatchlistPrice(instrument.price),
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
          ],
        ),
      ),
    );
  }
}

/// Side-by-side BUY / SELL filled buttons.
///
/// BUY uses the theme primary; SELL uses the semantic negative colour paired
/// with the new [TWColors.lightOnNegative]/[TWColors.darkOnNegative] so the
/// label stays readable in both themes. No order is placed: taps report the
/// project's temporary notice (ADR-010).
class _TradeActions extends StatelessWidget {
  const _TradeActions({required this.onNotice});

  final ValueChanged<String> onNotice;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ButtonStyle tradeButtonStyle = FilledButton.styleFrom(
      minimumSize: const Size(48, 52),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TWRadii.medium),
      ),
      textStyle: Theme.of(context).textTheme.labelLarge,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(TWSpacing.l, 0, TWSpacing.l, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: FilledButton(
              onPressed: () => onNotice('Buy is not available yet'),
              style: tradeButtonStyle,
              child: const Text('BUY'),
            ),
          ),
          const SizedBox(width: TWSpacing.m),
          Expanded(
            child: FilledButton(
              onPressed: () => onNotice('Sell is not available yet'),
              style: FilledButton.styleFrom(
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
              ),
              child: const Text('SELL'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Two rows of secondary actions: `View chart | Option chain` and the
/// wrapping `Set alert | Add notes | Create GTT` set.
///
/// Visual hierarchy only (reference `watchlist__bottomsheet__*`); each tap
/// reports the temporary notice instead of navigating or creating anything.
/// TradeWise uses its own Material outline glyphs, not reference artwork.
class _SecondaryActions extends StatelessWidget {
  const _SecondaryActions({required this.onNotice});

  final ValueChanged<String> onNotice;

  @override
  Widget build(BuildContext context) {
    final Color actionColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(TWSpacing.s, 0, TWSpacing.s, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: _ActionLink(
                  icon: Icons.bar_chart,
                  label: 'View chart',
                  color: actionColor,
                  onTap: () => onNotice('View chart is not available yet'),
                ),
              ),
              _ActionLink(
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
              Expanded(
                child: _ActionLink(
                  icon: Icons.notifications_none,
                  label: 'Set alert',
                  color: actionColor,
                  onTap: () => onNotice('Set alert is not available yet'),
                ),
              ),
              _ActionLink(
                icon: Icons.note_add,
                label: 'Add notes',
                color: actionColor,
                onTap: () => onNotice('Add notes is not available yet'),
              ),
              _ActionLink(
                icon: Icons.timer,
                label: 'Create GTT',
                color: actionColor,
                onTap: () => onNotice('Create GTT is not available yet'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One secondary action: outlined icon + primary label with a 48dp target.
class _ActionLink extends StatelessWidget {
  const _ActionLink({
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

    // A real button (not Semantics + InkWell) so the label is exposed as a
    // labelled button node in the semantics tree, exactly like BUY/SELL.
    // `TextButton.icon` lays out icon+label in a Row, so the label is a
    // plain (already shrink-wrapped) Text — no Flexible, which would write
    // FlexParentData through the icon-button's non-Flex slot.
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(
          horizontal: TWSpacing.s,
          vertical: TWSpacing.xs,
        ),
        alignment: Alignment.centerLeft,
      ),
      icon: Icon(icon, size: 18, color: color),
      label: Text(
        label,
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Static bid/offer market-depth ladder (preview only).
///
/// The column structure mirrors the reference's `Bid Orders Qty | Offer Orders
/// Qty` grid: three equal columns per side with a small gap between the sides.
/// Bid prices use the primary colour, offer prices the semantic negative, and
/// every value comes from [MarketDepthRow] preview rows (ADR-005). No
/// market-data source is involved.
class _MarketDepthSection extends StatelessWidget {
  const _MarketDepthSection({required this.depth, required this.onNotice});

  final List<MarketDepthRow> depth;
  final ValueChanged<String> onNotice;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final Color bidColor = Theme.of(context).colorScheme.primary;
    final Color offerColor = isDark
        ? TWColors.darkNegative
        : TWColors.lightNegative;
    final Color numberColor = isDark
        ? TWColors.darkTextSecondary
        : TWColors.lightTextSecondary;
    final TextStyle? headerStyle = textTheme.bodySmall?.copyWith(
      color: isDark ? TWColors.darkTextTertiary : TWColors.lightTextTertiary,
      fontWeight: FontWeight.w500,
    );
    final TextStyle? numberStyle = textTheme.bodyMedium?.copyWith(
      color: numberColor,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final TextStyle? totalStyle = textTheme.bodyMedium?.copyWith(
      color: numberColor,
      fontWeight: FontWeight.w600,
    );

    Widget headerCell(String label) => Expanded(
      child: Text(
        label,
        style: headerStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );

    Widget valueCell(String value, Color color) => Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: TWSpacing.xs),
        child: Text(
          value,
          style: numberStyle?.copyWith(color: color),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.right,
        ),
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
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Column headers: bid side, gap, offer side.
          Row(
            children: <Widget>[
              headerCell('Bid'),
              headerCell('Orders'),
              headerCell('Qty'),
              const SizedBox(width: TWSpacing.s),
              headerCell('Offer'),
              headerCell('Orders'),
              headerCell('Qty'),
            ],
          ),
          const SizedBox(height: TWSpacing.xs),
          for (final MarketDepthRow row in depth)
            Row(
              children: <Widget>[
                valueCell(formatWatchlistPrice(row.price), bidColor),
                valueCell('${row.orders}', numberColor),
                valueCell('${row.quantity}', numberColor),
                const SizedBox(width: TWSpacing.s),
                valueCell(formatWatchlistPrice(row.price), offerColor),
                valueCell('${row.orders}', numberColor),
                valueCell('${row.quantity}', numberColor),
              ],
            ),
          Row(
            children: <Widget>[
              Expanded(child: Text('Total', style: totalStyle, maxLines: 1)),
              Expanded(child: const SizedBox()),
              Expanded(
                child: Text(
                  '$_totalQuantity',
                  style: totalStyle,
                  maxLines: 1,
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: TWSpacing.s),
              Expanded(child: Text('Total', style: totalStyle, maxLines: 1)),
              Expanded(child: const SizedBox()),
              Expanded(
                child: Text(
                  '$_totalQuantity',
                  style: totalStyle,
                  maxLines: 1,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Sums the preview rows. Presentational arithmetic on mock values only —
  /// not real market data.
  int get _totalQuantity =>
      depth.fold(0, (int sum, MarketDepthRow row) => sum + row.quantity);
}

/// Bottom-most "Show 20 depth" action.
///
/// Visual placement only; the expanded 20-level depth is a later phase, so the
/// tap reports the temporary notice instead of opening anything.
class _ShowDepthAction extends StatelessWidget {
  const _ShowDepthAction({required this.onNotice});

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
