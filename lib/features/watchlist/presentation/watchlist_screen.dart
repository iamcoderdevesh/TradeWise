import 'package:flutter/material.dart';
import 'package:tradewise/app/theme/tw_spacing.dart';
import 'package:tradewise/core/widgets/tw_notification.dart';
import 'package:tradewise/features/watchlist/presentation/widgets/index_strip.dart';
import 'package:tradewise/features/watchlist/presentation/widgets/instrument_bottom_sheet.dart';
import 'package:tradewise/features/watchlist/presentation/widgets/watchlist_empty_state.dart';
import 'package:tradewise/features/watchlist/presentation/widgets/watchlist_instrument_tile.dart';
import 'package:tradewise/features/watchlist/presentation/widgets/watchlist_preview_data.dart';
import 'package:tradewise/features/watchlist/presentation/widgets/watchlist_search_bar.dart';
import 'package:tradewise/features/watchlist/presentation/widgets/watchlist_selector.dart';

/// Watchlist feature screen (Phase 3B, UI-only).
///
/// Composes the reference-derived hierarchy: index strip, watchlist
/// selector, search card, new-group row, then the list/empty region.
/// [instruments] is the seam for future real market data; the preview
/// constants it defaults to are temporary UI data (see
/// `watchlist_preview_data.dart`).
class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({
    super.key,
    this.instruments = kWatchlistPreviewMultiple,
  });

  final List<WatchlistInstrument> instruments;

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  static const int _capacity = 250;
  static const List<String> _tabs = <String>[
    'Watchlist 1',
    'Watchlist 2',
    'Watchlist 3',
  ];

  int _selectedTab = 0;

  /// Search query typed by the user; empty means no filtering.
  String _searchQuery = '';

  /// Controller for the search field; owned by this screen so the
  /// `TextEditingController` persists across rebuilds.
  late final TextEditingController _searchController;

  /// Instruments matching the current search query, filtered by symbol or
  /// exchange (case-insensitive). When the query is empty, the original
  /// watchlist is returned unchanged.
  List<WatchlistInstrument> get _filteredInstruments {
    if (_searchQuery.isEmpty) {
      return widget.instruments;
    }
    final String query = _searchQuery.toLowerCase();
    return widget.instruments.where((WatchlistInstrument instrument) {
      return instrument.symbol.toLowerCase().contains(query) ||
          instrument.exchange.toLowerCase().contains(query);
    }).toList();
  }

  /// Minimum horizontal distance (logical pixels) a swipe must travel to
  /// count as an intentional tab switch.
  static const double _swipeMinDistance = 50;

  /// Position where the current horizontal swipe began on the list body.
  Offset? _dragStartPosition;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
  }

  /// Records where a horizontal swipe began on the list body.
  void _onHorizontalDragStart(DragStartDetails details) {
    _dragStartPosition = details.globalPosition;
  }

  /// Switches tabs based on the horizontal drag direction, respecting
  /// first/last tab boundaries.
  void _switchTabFromDrag(DragEndDetails details) {
    if (_dragStartPosition == null) return;
    final double dx = details.globalPosition.dx - _dragStartPosition!.dx;
    _dragStartPosition = null;
    if (dx.abs() < _swipeMinDistance) return;
    setState(() {
      if (dx > 0) {
        // Swipe right → previous tab.
        _selectedTab = (_selectedTab - 1).clamp(0, _tabs.length - 1);
      } else {
        // Swipe left → next tab.
        _selectedTab = (_selectedTab + 1).clamp(0, _tabs.length - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            IndexStrip(
              onExpandTap: () => TWNotifications.showAlert(
                context,
                'Index details are not available yet',
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: _onHorizontalDragStart,
              onHorizontalDragEnd: (details) => _switchTabFromDrag(details),
              child: WatchlistSelector(
                tabs: _tabs,
                selectedIndex: _selectedTab,
                onTabSelected: (int index) =>
                    setState(() => _selectedTab = index),
                onAddTap: () => TWNotifications.showAlert(
                  context,
                  'Watchlist management is not available yet',
                ),
              ),
            ),
            WatchlistSearchBar(
              count: widget.instruments.length,
              capacity: _capacity,
              controller: _searchController,
              onChanged: _onSearchChanged,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => TWNotifications.showAlert(
                  context,
                  'Groups are not available yet',
                ),
                child: const Text('+ New group'),
              ),
            ),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // Unique tag: this FAB shares the shell route subtree with the
        // Portfolio FAB, so the default tag would collide once both
        // branches are built (see portfolio_screen.dart).
        heroTag: 'watchlist-charts-fab',
        onPressed: () =>
            TWNotifications.showAlert(context, 'Charts are not available yet'),
        tooltip: 'Charts',
        child: const Icon(Icons.show_chart),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final List<WatchlistInstrument> displayInstruments = _filteredInstruments;
    if (displayInstruments.isEmpty) {
      return const SingleChildScrollView(
        padding: EdgeInsets.only(bottom: TWSpacing.xxl),
        child: WatchlistEmptyState(),
      );
    }
    return ListView.separated(
      itemCount: displayInstruments.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (BuildContext context, int index) {
        final WatchlistInstrument instrument = displayInstruments[index];
        return WatchlistInstrumentTile(
          instrument: instrument,
          // Phase 3C: row tap opens the Instrument Bottom Sheet as a modal
          // layer above the Watchlist (no navigation).
          onTap: () => showInstrumentBottomSheet(context, instrument),
        );
      },
    );
  }
}
