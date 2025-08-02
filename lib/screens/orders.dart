import 'package:flutter/material.dart';
import 'package:tradewise/widgets/widgets.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  Widget build(BuildContext context) {
    return orderSection(context);
  }

  Widget orderSection(context) {
    return Stack(
      children: [
        curveAreaSection(context, 30),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              searchBox(context),
              const SizedBox(height: 20),
              ordersItems(
                'BTCUSDT.P',
                'SELL',
                '05:40 PM',
                "60",
                "CLOSED",
                "95,000.25",
                Icons.arrow_downward_rounded,
                Colors.red,
                context,
              ),
              const SizedBox(height: 10),
              ordersItems(
                'BTCUSDT.P',
                'BUY',
                '05:35 PM',
                "60",
                "OPEN",
                "95,000.25",
                Icons.arrow_upward_rounded,
                Colors.green,
                context,
              ),
              const SizedBox(height: 10),
              ordersItems(
                'BTCUSDT.P',
                'SELL',
                '05:40 PM',
                "60",
                "CLOSED",
                "95,000.25",
                Icons.arrow_downward_rounded,
                Colors.red,
                context,
              ),
              const SizedBox(height: 10),
              ordersItems(
                'BTCUSDT.P',
                'BUY',
                '05:35 PM',
                "60",
                "OPEN",
                "95,000.25",
                Icons.arrow_upward_rounded,
                Colors.green,
                context,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget ordersItems(
    String shortName,
    String type,
    String datetime,
    String quantity,
    String status,
    String price,
    IconData icon,
    Color selectedColor,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.onTertiary),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 36,
            width: 36,
            child: Stack(
              children: [
                CircleAvatar(
                  backgroundColor: selectedColor.withOpacity(0.1),
                  child: Icon(size: 22, icon, color: selectedColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$shortName $type",
                  style: TextStyle(
                    fontSize: 14,
                    color: selectedColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "$datetime  LIMIT",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "0 / $quantity",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onTertiary,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(status, style: const TextStyle(fontSize: 11)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Text(
                    "LTP: ",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.tertiary,
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
