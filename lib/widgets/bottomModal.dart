import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradewise/helpers/helper.dart';
import 'package:tradewise/screens/trade.dart';
import 'package:tradewise/state/tradeState.dart';
import 'package:tradewise/widgets/widgets.dart';

Future bottomModal({
  required BuildContext context,
  required String assetName,
  required String price,
  required String perChange,
  required String marketSegment,
  bool isExit = false,
  String action = '',
  String? quantity,
  String? entryPrice,
  String? tradeId,
}) {
  late String percentChange =
      Helper().formatNumber(value: perChange, formatNumber: 2);

  return showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(1),
    constraints: BoxConstraints.loose(
      Size(
        MediaQuery.of(context).size.width,
        250,
      ),
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(12),
      ),
    ),
    builder: (context) {
      return SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 75,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    assetName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        '$percentChange%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: getPnlColor(value: percentChange),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const Divider(
              height: 1.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            handleClick(
                              action: 'BUY',
                              context: context,
                              assetName: assetName,
                              isExit: isExit,
                              marketSegment: marketSegment,
                            );
                            // Provider.of<TradeState>(context, listen: false).cancelTimer();
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                            ),
                          ),
                          child: Text(isExit ? "ADD" : "BUY"),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Provider.of<TradeState>(context, listen: false).cancelTimer();
                            handleClick(
                              action: isExit ? action : 'SELL',
                              context: context,
                              assetName: assetName,
                              isExit: isExit,
                              quantity: quantity,
                              entryPrice: entryPrice,
                              tradeId: tradeId,
                              marketSegment: marketSegment,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                            ),
                          ),
                          child: Text(isExit ? 'EXIT' : 'SELL'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        style: const ButtonStyle(
                          foregroundColor:
                              MaterialStatePropertyAll(Colors.blue),
                        ),
                        onPressed: () {},
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bar_chart_rounded,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text("View chart"),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.arrow_forward_rounded,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1.0,
            ),
            const SizedBox(height: 25)
          ],
        ),
      );
    },
  );
}

void handleClick({
  required BuildContext context,
  required String action,
  required String assetName,
  required bool isExit,
  required String marketSegment,
  String? quantity,
  String? entryPrice,
  String? tradeId,
}) {
  Future.delayed(const Duration(milliseconds: 200), () {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TradeScreen(
          action: action,
          assetName: assetName,
          isExit: isExit,
          quantity: quantity,
          entryPrice: entryPrice,
          tradeId: tradeId,
          marketSegment: marketSegment,
        ),
      ),
    );
  });
}
