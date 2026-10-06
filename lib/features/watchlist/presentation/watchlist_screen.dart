import 'package:flutter/material.dart';
import 'package:tradewise/app/theme/tw_spacing.dart';
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

  void _notice(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            IndexStrip(
              onExpandTap: () => _notice('Index details are not available yet'),
            ),
            WatchlistSelector(
              tabs: _tabs,
              selectedIndex: _selectedTab,
              onTabSelected: (int index) =>
                  setState(() => _selectedTab = index),
              onAddTap: () =>
                  _notice('Watchlist management is not available yet'),
            ),
            WatchlistSearchBar(
              count: widget.instruments.length,
              capacity: _capacity,
              onTap: () => _notice('Search is not available yet'),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _notice('Groups are not available yet'),
                child: const Text('+ New group'),
              ),
            ),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _notice('Charts are not available yet'),
        tooltip: 'Charts',
        child: const Icon(Icons.show_chart),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (widget.instruments.isEmpty) {
      return const SingleChildScrollView(
        padding: EdgeInsets.only(bottom: TWSpacing.xxl),
        child: WatchlistEmptyState(),
      );
    }
    return ListView.separated(
      itemCount: widget.instruments.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (BuildContext context, int index) {
        final WatchlistInstrument instrument = widget.instruments[index];
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
