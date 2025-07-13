import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tradewise/widgets/widgets.dart';

class TradeScreen extends StatefulWidget {
  const TradeScreen({super.key});

  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        title: const Text(
          "Dogecoin",
          style: TextStyle(
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
                children: [priceBox(context)],
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
                    tradeFormSection(context: context, type: 'Buy'),
                  ],
                ),
                Stack(
                  children: [
                    curveAreaSection(context, 40),
                    tradeFormSection(
                        context: context, type: 'Sell', color: Colors.red),
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

Widget priceBox(context) {
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
        const Text(
          "\$",
          style: TextStyle(color: Colors.green),
        ),
        const SizedBox(
          width: 2,
        ),
        const Text(
          "0.5642",
          style: TextStyle(color: Colors.green),
        ),
        const SizedBox(
          width: 10,
        ),
        const Text(
          "+2.55%",
          style: TextStyle(color: Colors.green),
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
          "\$200.50",
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
          "\$0.40",
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
          "\$900.50",
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                        tradeForm(context: context, currentColor: color),
                      ],
                    ),
                  ),
                ),
                const Spacer(), // pushes the button to bottom
                marginBox(context, color),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: elevatedButton(
                    bgColor: color,
                    buttonLabel: type,
                    onPressed: () {},
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

Widget tradeForm({
  required BuildContext context, 
  required Color currentColor
}) {
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
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: Theme.of(context).colorScheme.tertiary),
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
                    color: currentColor),
              ),
              const SizedBox(
                width: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: Theme.of(context).colorScheme.tertiary),
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

Widget inputText(
    {required BuildContext context,
    required String label,
    required String hintText,
    required Color color}) {
  return TextFormField(
    keyboardType: TextInputType.number,
    inputFormatters: <TextInputFormatter>[
      FilteringTextInputFormatter.digitsOnly
    ], //
    onSaved: (password) {},
    onChanged: (password) {},
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
