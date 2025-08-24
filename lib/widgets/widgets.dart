import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tradewise/helpers/helper.dart';
import 'package:tradewise/widgets/bottomModal.dart';
import 'package:swipeable_button_view/swipeable_button_view.dart';

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
}) {
  late String price =
      Helper().formatNumber(value: currentPrice, formatNumber: 4);
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
                                fontWeight: FontWeight.w500),
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
            onChanged: onChanged,
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

Widget textFormField(
    {required BuildContext context,
    required String hintText,
    required String labelText,
    required TextInputType keyboardType,
    TextEditingController? controller,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffix,
    bool obscureText = false}) {
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

Widget swipeButton({
  required bool isFinished,
  required String message,
  required String buttonText,
  required Function() onWaitingProcess,
  required void Function() onFinish,
}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
          child: SwipeableButtonView(
            buttonText: buttonText,
            buttonWidget: Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.blue.shade600,
            ),
            activeColor: Colors.blue.shade600,
            isFinished: isFinished,
            onWaitingProcess: onWaitingProcess,
            onFinish: onFinish,
          ),
        ),
        if (isFinished)
          Text(
            message,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
      ],
    ),
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
    duration: const Duration(seconds: 3),
  );

  // Show the snackbar
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
