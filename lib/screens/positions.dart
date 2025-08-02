import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradewise/services/controllers/tradeController.dart';
import 'package:tradewise/services/models/TradeModel.dart';
import 'package:tradewise/state/tradeState.dart';
import 'package:tradewise/widgets/widgets.dart';

class PositionsScreen extends StatefulWidget {
  const PositionsScreen({super.key});

  @override
  State<PositionsScreen> createState() => _PositionsScreenState();
}

class _PositionsScreenState extends State<PositionsScreen> {

  late TradeState tradeState = Provider.of<TradeState>(context, listen: true);
  final tradeController = TradeController();

  @override
  void initState() {
    tradeController.getActiveTrades(context: context);
    super.initState();
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
                const Center(
                  child: Text(
                    "+0.00",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          tradeState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ListView.builder(
                    itemCount: tradeState.activeTrades.length,
                    itemBuilder: (context, index) {
                      return postionItems(
                        shortName: tradeState.activeTrades[index].assetName ?? '',
                        price: tradeState.activeTrades[index].ltp ?? '',
                        pnl: '+0.00',
                        qty: tradeState.activeTrades[index].quantity ?? '',
                        context: context,
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
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.green,
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
}
