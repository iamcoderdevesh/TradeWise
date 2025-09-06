import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradewise/helpers/helper.dart';
import 'package:tradewise/services/api/api.dart';
import 'package:tradewise/services/controllers/orderController.dart';
import 'package:tradewise/state/accountState.dart';
import 'package:tradewise/state/appState.dart';
import 'package:tradewise/widgets/widgets.dart';
import 'home.dart';

// ignore: must_be_immutable
class TradeScreen extends StatefulWidget {
  late String? tradeId;
  late String? quantity;
  late String? entryPrice;
  final bool isExit;
  final String assetName;
  final String action;
  final String marketSegment;

  TradeScreen({
    super.key,
    required this.assetName,
    required this.action,
    required this.isExit,
    required this.marketSegment,
    this.tradeId,
    this.quantity,
    this.entryPrice,
  });

  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen> with SingleTickerProviderStateMixin {
  late Timer _timer;

  final TextEditingController quantityController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController stopLossController = TextEditingController();
  final TextEditingController targetContorller = TextEditingController();

  late Helper helper = Helper();
  late TabController _tabController;

  final ApiService _apiService = ApiService();

  bool isLoading = false;
  bool isViewMore = false;
  bool stopLossSwitch = false;
  bool targetSwitch = false;

  late String orderType = "MARKET";
  late String currentPrice = '0.00';
  late String perChange = '0.00';
  late String availableMargin = '0.00';
  late String tradeMargin = '0.00';
  late String fees = '0.00';
  late String netPnl = '';

  @override
  void initState() {
    super.initState();
    late AccountState accountState = Provider.of<AccountState>(context, listen: false);
    availableMargin = accountState.totalBalance;

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.action == 'BUY' ? 0 : 1,
    );

    _tabController.addListener(() {
      setState(() {});
    });

    initTicker();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        title: Text(
          widget.assetName,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: widget.isExit ? tradeExitWidget(context) : tradeWidget(context),
    );
  }

  Widget tradeExitWidget(BuildContext context) {
    quantityController.text = widget.quantity ?? '0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          child: Stack(
            children: [
              curveAreaSection(context, 40),
              tradeFormSection(context: context, type: 'EXIT'),
            ],
          ),
        ),
      ],
    );
  }

  Widget tradeWidget(BuildContext context) {
    return Column(
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
              color: getPnlColor(value: widget.isExit ? netPnl : perChange),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            widget.isExit
                ? helper.formatNumber(value: netPnl, plusSign: true)
                : '${helper.formatNumber(value: perChange, plusSign: true)}%',
            style: TextStyle(
              color: getPnlColor(value: widget.isExit ? netPnl : perChange),
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

  Widget tradeFormSection({
    required BuildContext context,
    required String type,
    Color color = Colors.blue,
  }) {
    String tradeId = widget.tradeId ?? '';

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              children: [
                tradeForm(context: context, currentColor: color, type: type),
                const SizedBox(height: 20),
                isViewMore
                    ? addFieldsSection(context: context)
                    : const SizedBox.shrink(),
                tradeId.isNotEmpty
                    ? viewMore(context: context)
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        ),
        marginBox(context, color),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: SafeArea(
            top: false,
            child: elevatedButton(
              isLoading: isLoading,
              bgColor: color,
              buttonLabel: type,
              onPressed: () {
                handleTradeSubmit(
                    action: type == 'EXIT' ? widget.action : type);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget tradeForm({
    required BuildContext context,
    required Color currentColor,
    required String type,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Form(
        child: Column(
          children: [
            inputAreaSection(
              label: "Quantity",
              hintText: "0",
              currentColor: currentColor,
              controller: quantityController,
              onChanged: (p0) {
                handleCalculation();
              },
            ),
            inputAreaSection(
              label: orderType == "MARKET" ? "Market" : "Limit",
              hintText: "0.00",
              currentColor: currentColor,
              controller: amountController,
              readOnly: orderType == "MARKET" ? true : false,
              onChanged: (p0) {
                handleCalculation();
              },
              onActionButtonPressed: () {
                setState(() {
                  orderType = orderType == "MARKET" ? "LIMIT" : "MARKET";
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget inputAreaSection({
    required String label,
    required String hintText,
    bool readOnly = false,
    required Color currentColor,
    void Function(String)? onChanged,
    void Function()? onActionButtonPressed,
    void Function()? onEditingComplete,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.tertiary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: inputText(
                  label: label,
                  hintText: hintText,
                  context: context,
                  color: currentColor,
                  controller: controller,
                  onChanged: onChanged,
                  readOnly: readOnly,
                  onEditingComplete: onEditingComplete,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .tertiary
                          .withOpacity(0.5)),
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor:
                        Theme.of(context).colorScheme.tertiary.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: onActionButtonPressed,
                  child: Icon(
                    Icons.compare_arrows_outlined,
                    color: currentColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget viewMore({required BuildContext context}) {
    return Center(
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: () {
          setState(() {
            isViewMore = !isViewMore;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              isViewMore
                  ? const Icon(Icons.keyboard_arrow_up)
                  : const SizedBox.shrink(),
              const SizedBox(height: 4),
              Text(
                !isViewMore ? "More" : "Less",
              ),
              const SizedBox(height: 4),
              !isViewMore
                  ? const Icon(Icons.keyboard_arrow_down)
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget addFieldsSection({
    required BuildContext context,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Stoploss",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.tertiary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Transform.scale(
                scale: 0.65, // Adjust as needed (1.0 for original size)
                child: CupertinoSwitch(
                  value: stopLossSwitch,
                  activeColor: Colors.blue,
                  onChanged: (bool value) {
                    setState(() {
                      stopLossSwitch = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        stopLossSwitch
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
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
                    children: [
                      inputAreaSection(
                        label: "Trigger price",
                        hintText: "0.00",
                        currentColor: Colors.blue,
                        controller: stopLossController,
                        onEditingComplete: () {
                          handleSLAndTarget();
                        },
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox.shrink(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Target",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.tertiary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Transform.scale(
                scale: 0.65,
                child: CupertinoSwitch(
                  value: targetSwitch,
                  activeColor: Colors.blue,
                  onChanged: (bool value) {
                    setState(() {
                      targetSwitch = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        targetSwitch
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
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
                    children: [
                      inputAreaSection(
                        label: "Trigger price",
                        hintText: "0.00",
                        currentColor: Colors.blue,
                        controller: targetContorller,
                        onEditingComplete: () {
                          handleSLAndTarget();
                        },
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  Widget inputText({
    required BuildContext context,
    required String label,
    required String hintText,
    required Color color,
    required TextEditingController controller,
    bool readOnly = false,
    void Function(String)? onChanged,
    void Function()? onEditingComplete,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      readOnly: readOnly,
      onEditingComplete: onEditingComplete,
      onChanged: onChanged,
      cursorColor: color,
      decoration: InputDecoration(
          hintText: hintText,
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.tertiary,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.tertiary),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          focusColor: Theme.of(context).colorScheme.tertiary,
          border: OutlineInputBorder(
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.tertiary.withOpacity(0.5)),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.tertiary.withOpacity(0.5)),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.tertiary.withOpacity(0.5)),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          )),
    );
  }

  void handleCalculation() {
    final price = amountController.text;
    final quantity = quantityController.text;

    setState(() {
      tradeMargin =
          helper.calculateTradeMargin(quantity: quantity, price: price);
      fees = widget.isExit
          ? '0.00'
          : helper.calculateFees(
              segment: 'crypto', orderType: orderType, margin: tradeMargin);
    });
  }

  Future<void> handleTradeSubmit({required String action}) async {
    FocusScope.of(context).unfocus();

    String quantity = quantityController.text.trim();
    String amount = amountController.text.trim();

    if (quantity.isEmpty || amount.isEmpty) {
      showSnackbar(context,
          message: "Please fill all the fields.", type: SnackbarType.error);
    } else if (double.parse(tradeMargin) > double.parse(availableMargin)) {
      showSnackbar(context,
          message: "Insufficient Funds.", type: SnackbarType.error);
    } else if (!await helper.checkConnectivity(context)) {
      //do nothing
    } else {
      setState(() {
        isLoading = true;
      });

      final orderController = OrderController();
      // ignore: use_build_context_synchronously
      final response = await orderController.handleOrder(
        context: context,
        assetName: widget.assetName,
        ltp: amount,
        orderAction: action,
        orderPrice: amount,
        orderQuantity: quantity,
        marketSegment: widget.marketSegment,
        orderType: orderType,
        margin: '',
        tradeId: widget.tradeId ?? '',
        exitPrice: amount,
      );

      bool status = response["status"] as bool;
      String message = response["message"] as String;

      setState(() {
        isLoading = false;
      });

      if (status) {
        _timer.cancel();

        Future.delayed(const Duration(milliseconds: 200), () {
          showSnackbar(context, message: message, type: SnackbarType.success);

          final appState = Provider.of<AppState>(context, listen: false);
          appState.setPageIndex = 2;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        });
      }
    }
  }

  Future<void> handleSLAndTarget() async {
    if (await helper.checkConnectivity(context)) {
      String amount = amountController.text.trim();
      String quantity = quantityController.text.trim();
      String stopLoss = stopLossController.text.trim();
      String target = targetContorller.text.trim();

      final accountController = OrderController();
      // ignore: use_build_context_synchronously
      final response = await accountController.handleSLAndTargetOrders(
        context: context,
        assetName: widget.assetName,
        ltp: amount,
        orderAction: widget.action,
        orderPrice: amount,
        orderQuantity: quantity,
        marketSegment: 'Spot',
        orderType: 'LIMIT',
        margin: '',
        tradeId: widget.tradeId ?? '',
        stopLossPrice: stopLoss,
        targetPrice: target,
      );

      bool status = response["status"] as bool;
      String message = response["message"] as String;

      if (status) {
        Future.delayed(const Duration(milliseconds: 200), () {
          showSnackbar(context, message: message, type: SnackbarType.success);
        });
      }
    }
  }

  Future<void> initTicker() async {
    if (await helper.checkConnectivity(context)) {
      fetchTickerData();
      _timer = Timer.periodic(const Duration(seconds: 2), (Timer t) {
        fetchTickerData();
      });
    }
  }

  Future<void> fetchTickerData() async {
    try {
      String quantity = quantityController.text.trim();
      final data = await _apiService.getTickerPrice(widget.assetName, marketSegment: widget.marketSegment);

      setState(() {
        currentPrice = data['assetPrice'];
        perChange = data['assetPriceChange'];

        if (orderType == "MARKET") amountController.text = currentPrice;

        if (quantity.isNotEmpty) {
          handleCalculation();
          if (widget.isExit) {
            double pnl = helper.calculatePnL(
                action: widget.action,
                currentPrice: currentPrice,
                buyPrice: widget.entryPrice,
                quantity: widget.quantity);
            netPnl = helper.formatNumber(
                value: pnl.toString(), formatNumber: 2, plusSign: true);
          }
        }
      });
    } catch (e) {
      print('Error fetching ticker data: $e');
    }
  }
}
