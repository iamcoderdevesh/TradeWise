import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tradewise/app/theme/tw_colors.dart';
import 'package:tradewise/app/theme/tw_radii.dart';
import 'package:tradewise/app/theme/tw_spacing.dart';
import 'package:tradewise/features/portfolio/presentation/portfolio_providers.dart';
import 'package:tradewise/features/portfolio/presentation/widgets/portfolio_entry_list.dart';
import 'package:tradewise/features/portfolio/presentation/widgets/portfolio_tabs.dart';
import 'package:tradewise/features/portfolio/presentation/widgets/portfolio_toolbar.dart';
import 'package:tradewise/features/portfolio/presentation/widgets/portfolio_total_pnl_card.dart';

/// Portfolio screen (Phase 5, paper-trade simulation).
///
/// Mirrors the reference hierarchy with TradeWise tokens: header, the
/// Holdings/Positions tab pair with live counts, a Total P&L card (hidden
/// when the active tab holds no rows, matching the reference empty state),
/// then a rounded content sheet containing the toolbar and a swipeable
/// Holdings/Positions tab view kept in sync with [PortfolioState.selectedTab].
/// The toolbar actions and the analytics FAB report the established temporary
/// notice (ADR-010); nothing here fetches, groups or analyses real data.
class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  /// Drives the swipeable Holdings/Positions pages and is kept in sync with
  /// [PortfolioState.selectedTab] whether the user swipes or taps.
  late final PageController _pageController;

  /// Index of the tab last synced to the swipeable page view. Used to detect
  /// external tab changes (a tap or a filled order) and animate the page to
  /// match, without reacting to the page's own position updates.
  int? _lastSelectedTabIndex;

  /// Minimum horizontal distance (logical pixels) a swipe must travel to
  /// count as an intentional tab switch.
  static const double _swipeMinDistance = 50;

  /// Position where the current horizontal swipe began on the P&L card or
  /// toolbar; compared with the end position to decide the swipe direction.
  Offset? _dragStartPosition;

  /// Records where a horizontal swipe began on the P&L card or toolbar.
  void _onHorizontalDragStart(DragStartDetails details) {
    _dragStartPosition = details.globalPosition;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: ref.read(portfolioProvider).selectedTab.index,
    );
    _pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  /// Animates the swipeable pages to [index] when the selected tab changes
  /// from outside the page view (a tap or a filled order). No-ops when the
  /// page is already there, so a user swipe cannot loop back into itself.
  void _syncPage(int index) {
    if (_pageController.hasClients && _pageController.page!.round() != index) {
      _pageController.animateToPage(
        index,
        duration: kTabScrollDuration,
        curve: Curves.ease,
      );
    }
  }

  /// Reacts to user-initiated tab swipes: updates [PortfolioState.selectedTab]
  /// so the indicator, Total P&L card and entry list follow. When the page is
  /// being animated programmatically (see [_syncPage]), the resulting
  /// [selectTab] call is a no-op because the tab is already set.
  void _onPageChanged() {
    final PortfolioTab tab = _pageController.page!.round() == 0
        ? PortfolioTab.holdings
        : PortfolioTab.positions;
    if (ref.read(portfolioProvider).selectedTab != tab) {
      ref.read(portfolioProvider.notifier).selectTab(tab);
    }
  }

  /// Switches tabs in response to a horizontal swipe that began outside the
  /// swipeable page view (for example on the Total P&L card or toolbar), so
  /// the P&L/Filters section participates in the same left→Positions /
  /// right→Holdings navigation as the page content itself. Taps are not
  /// affected: the drag recognisers only fire after a deliberate drag past
  /// the slop threshold.
  void _switchTabFromDrag(DragEndDetails details) {
    final start = _dragStartPosition;
    _dragStartPosition = null;
    if (start == null) {
      return;
    }
    final dx = details.globalPosition.dx - start.dx;
    if (dx > _swipeMinDistance) {
      ref.read(portfolioProvider.notifier).selectTab(PortfolioTab.holdings);
    } else if (dx < -_swipeMinDistance) {
      ref.read(portfolioProvider.notifier).selectTab(PortfolioTab.positions);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color pageColor = isDark
        ? TWColors.darkBackgroundPrimary
        : TWColors.lightBackgroundSecondary;
    final Color sheetColor = isDark
        ? TWColors.darkBackgroundPrimary
        : TWColors.lightSurface;
    final PortfolioState state = ref.watch(portfolioProvider);

    // Keep the swipeable page in sync with the selected tab when it changes
    // externally (a tap or a filled paper order landing its tab). The
    // callback runs after build so animateToPage is invoked outside of build;
    // [_syncPage] no-ops if the page is already on target, so a user swipe
    // cannot loop back into itself.
    final int targetTabIndex = state.selectedTab.index;
    if (_lastSelectedTabIndex != targetTabIndex) {
      _lastSelectedTabIndex = targetTabIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _syncPage(targetTabIndex);
        }
      });
    }

    return Scaffold(
      backgroundColor: pageColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                TWSpacing.l,
                TWSpacing.m,
                TWSpacing.l,
                TWSpacing.s,
              ),
              child: Semantics(
                header: true,
                child: Text(
                  'Portfolio',
                  style: theme.textTheme.titleLarge,
                  maxLines: 1,
                ),
              ),
            ),
            PortfolioTabs(
              selected: state.selectedTab,
              holdingsCount: state.activeCountFor(PortfolioTab.holdings),
              positionsCount: state.activeCountFor(PortfolioTab.positions),
              onSelected: (PortfolioTab tab) =>
                  ref.read(portfolioProvider.notifier).selectTab(tab),
            ),
            if (state.entriesFor(state.selectedTab).isNotEmpty)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: _onHorizontalDragStart,
                onHorizontalDragEnd: (details) => _switchTabFromDrag(details),
                child: PortfolioTotalPnlCard(
                  totalPnl: state.totalPnlFor(state.selectedTab),
                ),
              ),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: sheetColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(TWRadii.large),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragStart: _onHorizontalDragStart,
                      onHorizontalDragEnd: (details) =>
                          _switchTabFromDrag(details),
                      child: PortfolioToolbar(
                        onNotice: (String message) =>
                            _showNotice(context, message),
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        children: <Widget>[
                          PortfolioEntryList(
                            state: state,
                            tab: PortfolioTab.holdings,
                            onEntryTap: () => _showNotice(
                              context,
                              'Instrument details are not available yet',
                            ),
                          ),
                          PortfolioEntryList(
                            state: state,
                            tab: PortfolioTab.positions,
                            onEntryTap: () => _showNotice(
                              context,
                              'Instrument details are not available yet',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // Unique tag: the shell keeps the Watchlist branch (its own FAB)
        // alive alongside this branch, so the default tag would collide
        // during any route transition with both branches built.
        heroTag: 'portfolio-analytics-fab',
        tooltip: 'Portfolio analytics',
        onPressed: () =>
            _showNotice(context, 'Portfolio analytics are not available yet'),
        child: const Icon(Icons.trending_up),
      ),
    );
  }

  void _showNotice(BuildContext context, String message) {
    // Replace the visible notice instead of queueing behind it — matches
    // the order ticket's pattern so rapid actions report immediately.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
