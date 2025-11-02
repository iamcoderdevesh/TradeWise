import 'package:action_slider/action_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tradewise/helpers/helper.dart';
import 'package:tradewise/helpers/sharedPreferences.dart';
import 'package:tradewise/state/appState.dart';
import 'package:tradewise/widgets/bottomModal.dart';

const authOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFF757575)),
  borderRadius: BorderRadius.all(Radius.circular(100)),
);

enum SnackbarType { success, error, info }

Widget circularLoader() {
  return const CircularProgressIndicator(
    color: Color(0xFF287BFF),
  );
}

Widget headerSection(String title) {
  return Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 10, left: 20, right: 20),
    child: Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ],
    ),
  );
}

Widget curveAreaSection(BuildContext context, double topPadding) {
  return Padding(
    padding: EdgeInsets.only(top: topPadding),
    child: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    ),
  );
}

Widget tickerItems({
  required BuildContext context,
  required String assetName,
  required String shortName,
  required String currentPrice,
  required String perChange,
  required String marketSegment,
  required String identifier,
  int formatNumber = 2,
}) {
  late String price =
      Helper().formatNumber(value: currentPrice, formatNumber: formatNumber);
  late String percentChange =
      Helper().formatNumber(value: perChange, formatNumber: 2, plusSign: true);

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 5),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Theme.of(context).colorScheme.onTertiary),
    ),
    child: TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      onPressed: () {
        FocusScope.of(context).unfocus();
        bottomModal(
          context: context,
          assetName: assetName,
          perChange: percentChange,
          price: price,
          marketSegment: marketSegment,
          identifier: identifier,
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 5, top: 5, bottom: 5, right: 5),
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
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
                    assetName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    shortName,
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.tertiary),
                  )
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$percentChange%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: getPnlColor(value: percentChange),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget cardItems({
  required String assetName,
  required Color bgColor,
  required String currentPrice,
  required String gains,
}) {
  late String price = Helper().formatNumber(value: currentPrice, formatNumber: 2);
  late String percentChange = Helper().formatNumber(value: gains, formatNumber: 2, plusSign: true);

  return Padding(
    padding: const EdgeInsets.only(bottom: 20, top: 5, right: 15),
    child: Container(
      width: 125,
      height: 150,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: Colors.black.withOpacity(.05),
            style: BorderStyle.solid,
            strokeAlign: BorderSide.strokeAlignInside),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      assetName.substring(0, 1),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                assetName.replaceAll("USDT", ""),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              price,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              children: [
                Text(
                  '$percentChange%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: getPnlColor(value: percentChange),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  double.parse(percentChange) > 0 ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  size: 26,
                  color: getPnlColor(value: percentChange),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget tickerSection({
  required BuildContext context,
  required Future<List<Map<String, dynamic>>>? tickerList,
  List<String>? tickerSymbols,
  String searchQuery = '',
  bool isFuture = false,
  bool isHomeFeatured = false,
  Axis scrollDirection = Axis.vertical,
}) {
  late AppState state = Provider.of<AppState>(context, listen: false);

  return FutureBuilder<List<Map<String, dynamic>>>(
    future: tickerList,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: circularLoader());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Center(child: Text("No data available"));
      }

      List<Map<String, dynamic>> filteredData = snapshot.data!;

      if (searchQuery.isNotEmpty) {
        filteredData = filteredData
            .where((item) => item['symbol']
                .toString()
                .toUpperCase()
                .contains(searchQuery.toUpperCase()))
            .toList();
      }

      if (tickerSymbols!.isNotEmpty && state.marketType == "crypto") {
        filteredData = filteredData
            .where((item) => tickerSymbols.contains(item['symbol']))
            .toList();
      }

      return ListView.builder(
        scrollDirection: scrollDirection,
        physics: const BouncingScrollPhysics(),
        itemCount: filteredData.length,
        itemBuilder: (context, index) {
          final data = filteredData[index];
          return isHomeFeatured
              ? cardItems(
                  assetName: data['symbol'],
                  bgColor: const Color(0xE4E8FDFF),
                  currentPrice: data['lastPrice'].toString(),
                  gains: data['priceChangePercent'].toString(),
                )
              : tickerItems(
                  context: context,
                  perChange: data['priceChangePercent'].toString(),
                  currentPrice: data['lastPrice'].toString(),
                  assetName: data['symbol'],
                  shortName: data['symbol'],
                  identifier: data['identifier'] ?? '',
                  marketSegment: isFuture ? "Futures" : "Spot",
                  formatNumber: state.marketType == "stocks" ? 2 : 4,
                );
        },
      );
    },
  );
}

Widget searchBox(
  BuildContext context, {
  TextEditingController? controller,
  void Function(String)? onChanged,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    child: Row(
      children: [
        Icon(
          Icons.search_rounded,
          color: Theme.of(context).colorScheme.tertiary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            // onChanged: onChanged,
            onSubmitted: onChanged,
            style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
            ),
            decoration: InputDecoration(
              hintText: "Search e.g: Btc, Xrp",
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.tertiary.withOpacity(0.6),
              ),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget textFormField({
  required BuildContext context,
  required String hintText,
  required String labelText,
  required TextInputType keyboardType,
  TextEditingController? controller,
  List<TextInputFormatter>? inputFormatters,
  Widget? suffix,
  bool obscureText = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textInputAction: TextInputAction.next,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.tertiary,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintStyle: const TextStyle(color: Color(0xFF757575)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        focusColor: Theme.of(context).colorScheme.tertiary,
        border: authOutlineInputBorder,
        enabledBorder: authOutlineInputBorder,
        focusedBorder: authOutlineInputBorder.copyWith(
          borderSide: const BorderSide(
            color: Colors.blue,
          ),
        ),
        suffix: suffix,
      ),
    ),
  );
}

Widget elevatedButton({
  Color bgColor = Colors.blue,
  bool isLoading = false,
  required String buttonLabel,
  required VoidCallback onPressed,
}) {
  return ElevatedButton(
    onPressed: isLoading ? null : onPressed,
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: bgColor,
      disabledBackgroundColor: bgColor,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 48),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    child: isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Text(buttonLabel),
  );
}

Color getPnlColor({required String value}) {
  final double number = double.tryParse(value) ?? 0.0;
  return (number > 0)
      ? const Color(0xE215CC8A)
      : (number < 0)
          ? Colors.red
          : Colors.grey.shade500;
}

Widget slideButton(
    {required String buttonText,
    required dynamic Function(ActionSliderController)? onSlide,
    Color backgroundColor = Colors.blue}) {
  return ActionSlider.standard(
    icon: Icon(
      size: 30,
      Icons.chevron_right,
      color: backgroundColor,
    ),
    loadingIcon: SizedBox(
      width: 24.0,
      height: 24.0,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        color: backgroundColor,
      ),
    ),
    successIcon: Icon(
      Icons.check_rounded,
      color: backgroundColor,
    ),
    failureIcon: Icon(
      Icons.close_rounded,
      color: backgroundColor,
    ),
    reverseSlideAnimationCurve: Curves.easeInExpo,
    backgroundColor: backgroundColor,
    toggleColor: Colors.white,
    action: onSlide,
    child: Text(buttonText),
  );
}

void showSnackbar(
  BuildContext context, {
  required String message,
  required SnackbarType type,
}) {
  // Determine background color based on type
  Color backgroundColor;

  switch (type) {
    case SnackbarType.success:
      backgroundColor = const Color(0xE215CC8A);
      break;
    case SnackbarType.error:
      backgroundColor = const Color(0xFFFF6467);
      break;
    case SnackbarType.info:
    default:
      backgroundColor = Colors.blue;
      break;
  }

  // Create the snackbar
  final snackBar = SnackBar(
    content: Text(
      message,
      style: const TextStyle(color: Colors.white),
    ),
    backgroundColor: backgroundColor,
    // behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 2),
  );

  // Show the snackbar
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
