import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradewise/screens/watchlist.dart';
import 'package:tradewise/state/appState.dart';
import 'package:tradewise/widgets/widgets.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _marketType = '';

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _marketType = Provider.of<AppState>(context, listen: false).marketType;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        headerSection("Market"),
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: TabBar(
            indicatorPadding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            dividerColor: Theme.of(context).colorScheme.primaryContainer,
            labelColor: Theme.of(context).colorScheme.primaryContainer,
            indicatorColor: Theme.of(context).colorScheme.primaryContainer,
            unselectedLabelColor: Theme.of(context).colorScheme.tertiary,
            isScrollable: true,
            controller: _tabController,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            tabs: [
              const Tab(
                text: 'All',
              ),
              Tab(
                text: _marketType == "stocks" ? 'Options' : 'Spot',
              ),
              const Tab(
                text: 'Futures',
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              WatchlistScreen(),
              WatchlistScreen(),
              WatchlistScreen(isFuture: true),
            ],
          ),
        ),
      ],
    );
  }
}
