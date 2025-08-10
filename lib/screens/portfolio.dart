import 'package:flutter/material.dart';
import 'package:tradewise/screens/orders.dart';
import 'package:tradewise/screens/positions.dart';
import 'package:tradewise/widgets/widgets.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        headerSection("Portfolio"),
        Center(
          child: TabBar(
            isScrollable: true,
            controller: _tabController,
            dividerColor: Theme.of(context).colorScheme.primaryContainer,
            labelColor: Theme.of(context).colorScheme.primaryContainer,
            indicatorColor: Theme.of(context).colorScheme.primaryContainer,
            unselectedLabelColor: Theme.of(context).colorScheme.tertiary,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            tabs: const [
              Tab(text: 'Orders'),
              Tab(text: 'Positions'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [OrderScreen(), PositionsScreen()],
          ),
        ),
      ],
    );
  }
}
