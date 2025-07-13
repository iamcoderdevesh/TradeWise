import 'package:flutter/material.dart';
import 'package:tradewise/assets/svg.dart';
import 'package:tradewise/widgets/widgets.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerSection("Watchlist"),
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
              tabs: const [
                Tab(
                  text: 'All',
                ),
                Tab(
                  text: 'Spot',
                ),
                Tab(
                  text: 'Futures',
                ),
                Tab(
                  text: 'Watchlist',
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Stack(
                  children: [
                    curveAreaSection(context,40),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: searchBox(context),
                    ),
                    trendingSection(context)
                  ],
                ),
                Stack(
                  children: [
                    curveAreaSection(context, 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: searchBox(context),
                    ),
                    trendingSection(context)
                  ],
                ),
                Stack(
                  children: [
                    curveAreaSection(context, 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: searchBox(context),
                    ),
                    trendingSection(context)
                  ],
                ),
                Stack(
                  children: [
                    curveAreaSection(context, 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: searchBox(context),
                    ),
                    trendingSection(context)
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget trendingSection(context) {
  return Padding(
    padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
    child: ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      physics: const BouncingScrollPhysics(),
      children: [
        trendingItems(context, 'Bitcoin', 'BTC', '\$100000.20', '+1.72%', btcIcon),
        const SizedBox(height: 8),
        trendingItems(context, 'Ethereum', 'ETH', '\$26535.56', '+0.88%', ethIcon),
        const SizedBox(height: 8),
        trendingItems(context, 'Dogecoin', 'DOGE', '\$0.56', '+2.55%', dogeIcon),
        const SizedBox(height: 8),
        trendingItems(context, 'XRP', 'XRP', '\$1.56', '+3.42%', xrpIcon),
        const SizedBox(height: 8),
        trendingItems(context, 'Solana', 'SOL', '\$2464.20', '+1.43%', solIcon),
        const SizedBox(height: 8),
        trendingItems(context, 'Bitcoin', 'BTC', '\$100000.20', '+1.72%', btcIcon),
        const SizedBox(height: 8),
        trendingItems(context, 'Ethereum', 'ETH', '\$26535.56', '+0.88%', ethIcon),
        const SizedBox(height: 8),
        trendingItems(context, 'Dogecoin', 'DOGE', '\$0.56', '+2.55%', dogeIcon),
      ],
    ),
  );
}
