import 'package:flutter/material.dart';
import 'package:tradewise/helpers/helper.dart';
import 'package:tradewise/services/controllers/orderController.dart';
import 'package:tradewise/widgets/widgets.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late Future<List<Map<String, dynamic>>> orderList;

  final Helper helper = Helper();
  final orderController = OrderController();

  @override
  void initState() {
    orderList = orderController.getOrders(context: context);
    super.initState();
  }

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
              Flexible(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: orderList,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: circularLoader());
                    }

                    final data = snapshot.data!;
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final orders = data[index];

                        return ordersItems(
                          context: context,
                          shortName: orders['assetName'],
                          price: orders['ltp'],
                          quantity: orders['orderQuantity'],
                          status: orders['orderStatus'],
                          type: orders['orderType'],
                          action: orders['orderAction'],
                          datetime: helper.convertTimestampToTime(orders['createdOn']),
                          icon: orders['orderAction'] == 'SELL'
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          selectedColor: orders['orderAction'] == 'SELL'
                              ? Colors.red
                              : Colors.green,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget ordersItems({
    required String shortName,
    required String action,
    required String type,
    required String datetime,
    required String quantity,
    required String status,
    required String price,
    required IconData icon,
    required Color selectedColor,
    required BuildContext context,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
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
                  "$shortName $action",
                  style: TextStyle(
                    fontSize: 14,
                    color: selectedColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      datetime,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      type,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
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
