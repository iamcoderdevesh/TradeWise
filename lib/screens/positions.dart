import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tradewise/helpers/helper.dart';
import 'package:tradewise/services/api/api.dart';
import 'package:tradewise/services/controllers/tradeController.dart';
import 'package:tradewise/state/tradeState.dart';
import 'package:tradewise/widgets/bottomModal.dart';
import 'package:tradewise/widgets/widgets.dart';
import 'package:provider/provider.dart';

class PositionsScreen extends StatefulWidget {
  const PositionsScreen({super.key});

  @override
  State<PositionsScreen> createState() => _PositionsScreenState();
}

class _PositionsScreenState extends State<PositionsScreen> {
  late Timer _timer;
  bool _hasHandledRefresh = false;

  dynamic activeTradeList;
  dynamic inActiveTradeList;

  late Future<List<Map<String, dynamic>>> openedTradeList;
  late Future<List<Map<String, dynamic>>> closeTradeList;

  late Future<List<Map<String, dynamic>>> tradeList;

  final Helper helper = Helper();
  final ApiService _apiService = ApiService();
  final tradeController = TradeController();

  late double _totalPnL = 0.00;
  late double _closedPnL = 0.00;

  @override
  void initState() {
    initPosition();
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final tradeState = Provider.of<TradeState>(context);

    if (tradeState.isRefresh && !_hasHandledRefresh) {
      _hasHandledRefresh = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        initPosition();
        tradeState.setIsRefresh = false;
        _hasHandledRefresh = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        curveAreaSection(context, 40),
        postionSection(context),
      ],
    );
  }

  Widget postionSection(context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        children: [
          totalPnlBox(context),
          const SizedBox(height: 10),
          postionList(),
        ],
      ),
    );
  }

  Widget totalPnlBox(context) {
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
                  value: _totalPnL.toString(), formatNumber: 2, plusSign: true),
              style: TextStyle(
                fontSize: 20,
                color: getPnlColor(value: _totalPnL.toString()),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget postionList() {
    return Flexible(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: tradeList,
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
                context: context,
              );
            },
          );
        },
      ),
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
    closeTradeList = handleTradePostion(status: 'CLOSED');
    openedTradeList = handleTradePostion(status: 'OPEN');
    tradeList = getCombineTrades();
    updateTradePostion();
  }

  void updateTradePostion() {
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer t) {
      setState(() {
        openedTradeList = handleTradePostion(isTimerCall: true, status: 'OPEN');
        tradeList = getCombineTrades();
      });
    });
  }

  Future<List<Map<String, dynamic>>> handleTradePostion({
    required String status,
    bool isTimerCall = false,
  }) async {
    dynamic tradeList;
    double totalPnl = 0.00;
    List<Map<String, dynamic>> result = [];

    if (activeTradeList != null && status == 'OPEN') {
      tradeList = activeTradeList;
    } else if (inActiveTradeList != null && status == 'CLOSED') {
      tradeList = inActiveTradeList;
    } else {
      tradeList =
          await tradeController.getTrades(context: context, status: status);
      status == 'CLOSED' ? inActiveTradeList = tradeList : null;
      status == 'OPEN' ? activeTradeList = tradeList : null;
    }

    if (tradeList.isEmpty && isTimerCall && status == 'OPEN') {
      _timer.cancel();
      return result;
    }

    for (final pos in tradeList) {
      final currentTickerData = status == 'CLOSED'
          ? null
          : await _apiService.getTickerPrice(pos.assetName ?? '');

      final currentPrice =
          status == 'CLOSED' ? pos.exitPrice : currentTickerData?['assetPrice'];
      final pnl = status == 'CLOSED'
          ? double.parse(pos.netPnl ?? '0.00')
          : helper.calculatePnL(
              action: pos.action,
              currentPrice: currentPrice,
              buyPrice: pos.entryPrice,
              quantity: pos.quantity,
            );

      totalPnl += pnl;

      result.add({
        'tradeId': pos.tradeId,
        'assetName': pos.assetName,
        'ltp': currentPrice,
        'quantity': pos.quantity,
        'entryPrice': pos.entryPrice,
        'action': pos.action,
        'status': status,
        'pnl': helper.formatNumber(
            value: pnl.toString(), formatNumber: 2, plusSign: true)
      });
    }

    setState(() {
      _totalPnL = totalPnl + _closedPnL;
    });

    if (status == 'CLOSED') {
      _closedPnL = totalPnl;
    }

    return result;
  }

  Future<List<Map<String, dynamic>>> getCombineTrades() async {
    final results = await Future.wait([openedTradeList, closeTradeList]);
    return [...results[0], ...results[1]];
  }
}
