import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradewise/helpers/helper.dart';
import 'package:tradewise/services/api/api.dart';
import 'package:tradewise/services/controllers/tradeController.dart';
import 'package:tradewise/state/tradeState.dart';
import 'package:tradewise/widgets/widgets.dart';

class PositionsScreen extends StatefulWidget {
  const PositionsScreen({super.key});

  @override
  State<PositionsScreen> createState() => _PositionsScreenState();
}

class _PositionsScreenState extends State<PositionsScreen> {
  late Timer _timer;
  late Future<List<Map<String, dynamic>>> tradeList;

  final Helper helper = Helper();
  final ApiService _apiService = ApiService();
  final tradeController = TradeController();

  late TradeState tradeState = Provider.of<TradeState>(context, listen: true);
  late double totalPnL = 0.00;

  @override
  void initState() {
    tradeController.getActiveTrades(context: context);
    tradeList = handleTradePostion();
    updateTradePostion();
    super.initState();
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer.cancel();
    super.dispose();
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
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
                    '+${helper.formatNumber(value: totalPnL.toString(), formatNumber: 2)}',
                    style: TextStyle(
                      fontSize: 20,
                      color: getPnlColor(value: totalPnL.toString()),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          tradeState.isLoading
              ? Center(child: circularLoader())
              : Expanded(
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
                            shortName: tradeData['assetName'] ?? 'null',
                            price: tradeData['ltp'] ?? 'null',
                            pnl: tradeData['pnl'] ?? 'null',
                            qty: tradeData['quantity'] ?? 'null',
                            context: context,
                          );
                        },
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget postionItems({
    required String shortName,
    required String price,
    required String pnl,
    required String qty,
    required BuildContext context,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.onTertiary),
      ),
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
    );
  }

  void updateTradePostion() {
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer t) {
      setState(() {
        tradeList = handleTradePostion();
      });
    });
  }

  Future<List<Map<String, dynamic>>> handleTradePostion() async {
    double totalPnl = 0.00;
    List<Map<String, dynamic>> result = [];
    bool isLoading = tradeState.isLoading;

    if (isLoading) return result;

    final activeTradeList = tradeState.activeTrades;

    for (final pos in activeTradeList) {
      final currentTickerData =
          await _apiService.getTickerPrice(pos.assetName ?? '');
      final currentPrice = currentTickerData['assetPrice'];
      final pnl = calculatePnL(
          double.parse(currentPrice ?? '0.00'),
          double.parse(pos.entryPrice ?? '0.00'),
          double.parse(pos.quantity ?? '0.00'));

      totalPnl += pnl;

      result.add({
        'assetName': pos.assetName,
        'ltp': currentPrice,
        'quantity': pos.quantity,
        'pnl': helper.formatNumber(value: pnl.toString(), formatNumber: 2)
      });
    }
    
    setState(() {
      totalPnL = totalPnl;
    });

    return result;
  }

  double calculatePnL(double currentPrice, double buyPrice, double quantity) {
    return (currentPrice - buyPrice) * quantity;
  }
}
