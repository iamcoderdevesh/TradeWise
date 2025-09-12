import 'package:flutter/material.dart';
import 'package:tradewise/helpers/helper.dart';
import 'package:tradewise/state/tradeState.dart';
import 'package:tradewise/widgets/bottomModal.dart';
import 'package:tradewise/widgets/widgets.dart';
import 'package:provider/provider.dart';

class PositionsScreen extends StatefulWidget {
  const PositionsScreen({super.key});

  @override
  State<PositionsScreen> createState() => _PositionsScreenState();
}

class _PositionsScreenState extends State<PositionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TradeState tradeState = Provider.of<TradeState>(context, listen: false);
  final Helper helper = Helper();

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initPosition();
    });

    _tabController.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tabController.index == 0
            ? Provider.of<TradeState>(context, listen: false).initOpenPosition()
            : Provider.of<TradeState>(context, listen: false).initClosedPosition();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    tradeState.cancelTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        curveAreaSection(context, 40),
        Positioned.fill(
          child: postionSection(context),
        ),
      ],
    );
  }

  Widget postionSection(context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          totalPnlBox(context),
          const SizedBox(height: 10),
          TabBar(
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
              Tab(text: 'Open'),
              Tab(text: 'Closed'),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                postionList(isOpenPostion: true),
                postionList(isOpenPostion: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget totalPnlBox(context) {
    late TradeState state = Provider.of<TradeState>(context, listen: true);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "Total P&L",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Center(
            child: Text(
              helper.formatNumber(
                  value: _tabController.index == 0 ? state.openedPnl.toString() : state.closedPnL.toString(), formatNumber: 2, plusSign: true),
              style: TextStyle(
                fontSize: 20,
                color: getPnlColor(value: _tabController.index == 0 ? state.openedPnl.toString() : state.closedPnL.toString()),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget postionList({required bool isOpenPostion}) {
    late TradeState state = Provider.of<TradeState>(context, listen: true);

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: isOpenPostion ? state.openedTradeList : state.closeTradeList,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: circularLoader());
        }

        final data = snapshot.data!;
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final tradeData = data[index];

            return postionItems(
              shortName: tradeData['assetName'] ?? '',
              price: tradeData['ltp'] ?? '',
              pnl: tradeData['pnl'] ?? '',
              qty: tradeData['quantity'] ?? '',
              entryPrice: tradeData['entryPrice'] ?? '',
              tradeId: tradeData['tradeId'] ?? '',
              status: tradeData['status'] ?? '',
              action: tradeData['action'] ?? '',
              marketSegment: tradeData['marketSegment'] ?? '',
              context: context,
            );
          },
        );
      },
    );
  }

  Widget postionItems({
    required BuildContext context,
    required String shortName,
    required String price,
    required String status,
    required String pnl,
    required String qty,
    required String action,
    required String entryPrice,
    required String tradeId,
    required String marketSegment,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.onTertiary),
      ),
      child: Opacity(
        opacity: status == 'CLOSED' ? 0.6 : 1.0,
        child: TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () {
            status == 'CLOSED'
                ? null
                : bottomModal(
                    context: context,
                    assetName: shortName,
                    perChange: '0.00',
                    price: price,
                    quantity: qty,
                    entryPrice: entryPrice,
                    tradeId: tradeId,
                    isExit: true,
                    action: action,
                    marketSegment: marketSegment,
                  );
          },
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Center(
                    child: Stack(
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade700,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                shortName.substring(0, 1),
                                style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(shortName, style: const TextStyle(fontSize: 13)),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            "Qty: ",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                          Text(
                            qty,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      pnl,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: getPnlColor(value: pnl),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          "LTP ",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        Text(
                          price,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void initPosition() {
    Provider.of<TradeState>(context, listen: false).initOpenPosition();
    Provider.of<TradeState>(context, listen: false).initClosedPosition();
  }
}
