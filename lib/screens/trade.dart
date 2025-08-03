import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tradewise/helpers/helper.dart';
import 'package:tradewise/screens/portfolio.dart';
import 'package:tradewise/services/api/api.dart';
import 'package:tradewise/services/controllers/orderController.dart';
import 'package:tradewise/state/accountState.dart';
import 'package:tradewise/state/tradeState.dart';
import 'package:tradewise/widgets/widgets.dart';

class TradeScreen extends StatefulWidget {
  const TradeScreen({super.key});

  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen>
    with SingleTickerProviderStateMixin {
  late Timer _timer;

  final TextEditingController quantityController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  late Helper helper = Helper();
  late TabController _tabController;

  late TradeState tradeState = Provider.of<TradeState>(context, listen: false);
  final ApiService _apiService = ApiService();

  bool isLoading = false;
  late String currentPrice = '0.00';
  late String perChange = '0.00';
  late String availableMargin = '0.00';
  late String tradeMargin = '0.00';
  late String fees = '0.00';

  @override
  void initState() {
    super.initState();
    fetchTickerData();
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer t) {
      fetchTickerData();
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    late TradeState tradeState =
        Provider.of<TradeState>(context, listen: false);
    late AccountState accountState =
        Provider.of<AccountState>(context, listen: false);
    availableMargin = accountState.totalBalance;

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: tradeState.action == 'BUY' ? 0 : 1,
    );

    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        title: Text(
          tradeState.assetName,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(
                  24,
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    24,
                  ),
                  color: _tabController.index == 0
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Colors.red,
                ),
                indicatorPadding:
                    const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                unselectedLabelColor: Theme.of(context).colorScheme.tertiary,
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                tabs: const [
                  Tab(
                    text: 'Buy',
                  ),
                  Tab(
                    text: 'Sell',
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [priceBox(context: context)],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Stack(
                  children: [
                    curveAreaSection(context, 40),
                    tradeFormSection(context: context, type: 'BUY'),
                  ],
                ),
                Stack(
                  children: [
                    curveAreaSection(context, 40),
                    tradeFormSection(
                        context: context, type: 'SELL', color: Colors.red),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget priceBox({required BuildContext context}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
          ),
          Text(
            "Price",
            style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            currentPrice,
            style: TextStyle(
              color: getPnlColor(value: perChange),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            perChange,
            style: TextStyle(
              color: getPnlColor(value: perChange),
            ),
          ),
        ],
      ),
    );
  }

  Widget marginBox(context, currentColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 5,
          ),
          const Text(
            "Margin",
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            "\$$tradeMargin",
            style: TextStyle(color: currentColor),
          ),
          const SizedBox(
            width: 5,
          ),
          const Text(
            "+",
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            "\$$fees",
            style: TextStyle(color: currentColor),
          ),
          const SizedBox(
            width: 15,
          ),
          const Text(
            "Avail.",
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            "\$$availableMargin",
            style: TextStyle(color: currentColor),
          ),
        ],
      ),
    );
  }

  Widget tradeFormSection(
      {required BuildContext context,
      required String type,
      Color color = Colors.blue}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: Container(
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
                          tradeForm(
                              context: context,
                              currentColor: color,
                              type: type),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(), // pushes the button to bottom
                  marginBox(context, color),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: elevatedButton(
                      isLoading: isLoading,
                      bgColor: color,
                      buttonLabel: type,
                      onPressed: () {
                        handleTradeSubmit(action: type);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget tradeForm(
      {required BuildContext context,
      required Color currentColor,
      required String type}) {
    return Form(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: inputText(
                    label: "Quantity",
                    hintText: "0",
                    context: context,
                    color: currentColor,
                    controller: quantityController,
                    onChanged: (text) => {
                      handleCalculation(price: currentPrice, quantity: text)
                    },
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Theme.of(context).colorScheme.tertiary),
                  ),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.tertiary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {},
                    child: const Icon(
                      Icons.compare_arrows_rounded,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 25,
            ),
            Row(
              children: [
                Expanded(
                  child: inputText(
                    label: "Market",
                    hintText: "0.00",
                    context: context,
                    color: currentColor,
                    controller: amountController,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Theme.of(context).colorScheme.tertiary),
                  ),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.tertiary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {},
                    child: const Icon(
                      Icons.compare_arrows_rounded,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget inputText({
    required BuildContext context,
    required String label,
    required String hintText,
    required Color color,
    required TextEditingController controller,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ], //
      onSaved: (password) {},
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: label,
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.tertiary,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.tertiary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        focusColor: Theme.of(context).colorScheme.tertiary,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ).copyWith(
          borderSide: BorderSide(color: color),
        ),
      ),
    );
  }

  void handleCalculation({
    required String price,
    required String quantity,
  }) {
    setState(() {
      tradeMargin =
          helper.calculateTradeMargin(quantity: quantity, price: price);
      fees = helper.calculateFees(
          segment: 'crypto', orderType: 'market', margin: tradeMargin);
    });
  }

  Future<void> handleTradeSubmit({required String action}) async {
    String quantity = quantityController.text.trim();
    String amount = amountController.text.trim();

    if (quantity.isEmpty || amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill all the fields.")));
    } else {
      setState(() {
        isLoading = true;
      });

      final accountController = OrderController();
      final response = await accountController.createOrder(
        context: context,
        assetName: tradeState.assetName,
        ltp: currentPrice,
        orderAction: action,
        orderName: tradeState.assetName + tradeState.action,
        orderPrice: currentPrice,
        orderQuantity: quantity,
        marketSegment: 'Spot',
        orderStatus: 'OPEN',
        orderType: 'MARKET',
        totalFees: fees,
        margin: '0',
      );

      bool status = response["status"] as bool;

      setState(() {
        isLoading = false;
      });

      if (status) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Order Placed successfully.")));

        Future.delayed(const Duration(milliseconds: 200), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PortfolioScreen(),
            ),
          );
        });
      }
    }
  }

  Future<void> fetchTickerData() async {
    try {
      String quantity = quantityController.text.trim();
      final data = await _apiService.getTickerPrice(tradeState.assetName);

      setState(() {
        currentPrice = data['assetPrice'];
        perChange = data['assetPriceChange'];
        amountController.text = currentPrice;
        if (quantity.isNotEmpty) {
          handleCalculation(price: currentPrice, quantity: quantity);
        }
      });
    } catch (e) {
      print('Error fetching ticker data: $e');
    }
  }
}
