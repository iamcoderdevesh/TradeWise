class Helper {
  Helper();

  String formatNumber({required String value}) =>
      "\$${double.parse(value).toStringAsFixed(2)}";
}
