import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tradewise/assets/svg.dart';
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
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
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              tabs: const [
                Tab(
                  text: 'Orders',
                ),
                Tab(
                  text: 'Positions',
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                orderSection(context),
                Stack(
                  children: [
                    curveAreaSection(context, 40),
                    postionSection(context),
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
            const SizedBox(
              height: 20,
            ),
            ordersItems('BTCUSDT.P', 'SELL', '05:40 PM', "60", "CLOSED",
                "95,000.25", Icons.arrow_downward_rounded, Colors.red, context),
            const SizedBox(
              height: 10,
            ),
            ordersItems('BTCUSDT.P', 'BUY', '05:35 PM', "60", "OPEN",
                "95,000.25", Icons.arrow_upward_rounded, Colors.green, context),
            const SizedBox(
              height: 10,
            ),
            ordersItems('BTCUSDT.P', 'SELL', '05:40 PM', "60", "CLOSED",
                "95,000.25", Icons.arrow_downward_rounded, Colors.red, context),
            const SizedBox(
              height: 10,
            ),
            ordersItems('BTCUSDT.P', 'BUY', '05:35 PM', "60", "OPEN",
                "95,000.25", Icons.arrow_upward_rounded, Colors.green, context),
          ],
        ),
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
              const SizedBox(
                height: 5,
              ),
              const Center(
                child: Text(
                  "+\$6500.60",
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
        const SizedBox(
          height: 20,
        ),
        postionItems(
            'BTCUSDT.P', '\$100000.20', '+\$6000.00', "1", btcIcon, context),
        const SizedBox(
          height: 10,
        ),
        postionItems(
            'DOGEUSDT.P', '\$0.56', '+\$500.60', "100", dogeIcon, context),
      ],
    ),
  );
}

Widget postionItems(String shortName, String price, String pnl, String qty,
    String icon, BuildContext context) {
  return Container(
    padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Theme.of(context).colorScheme.onTertiary),
    ),
    child: Row(
      children: [
        Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: SvgPicture.string(icon),
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                shortName,
                style: const TextStyle(fontSize: 13),
              ),
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
                      color: Theme.of(context).colorScheme.tertiary),
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

Widget ordersItems(
    String shortName,
    String type,
    String datetime,
    String quantity,
    String status,
    String price,
    IconData icon,
    Color selectedColor,
    BuildContext context) {
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
                child: Icon(
                  size: 22,
                  icon,
                  color: selectedColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$shortName $type",
                style: TextStyle(
                    fontSize: 14,
                    color: selectedColor,
                    fontWeight: FontWeight.w500),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onTertiary,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      status,
                      style: const TextStyle(
                        fontSize: 11,
                      ),
                    ),
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
