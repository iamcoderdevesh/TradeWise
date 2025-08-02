class Helper {
  Helper();

  String getFirstLetter({required String value}) =>
      value.toString().substring(0, 1);

  String formatNumber({required String value}) =>
      double.parse(value).toStringAsFixed(2);

  String calculateTradeMargin({
    required String quantity,
    required String price,
  }) {
    late double margin = 0.00;
    margin = (quantity.isNotEmpty && quantity != '0')
        ? double.parse(quantity) * double.parse(price)
        : 0.00;

    return margin.toStringAsFixed(2).toString();
  }

  String calculateFees({
    required String segment,
    required String orderType,
    required String margin,
  }) {
    late double fees = 0.0;
    double marginValue = double.parse(margin);

    if (segment.toLowerCase() == 'crypto') {
      if (orderType.toLowerCase() == 'market') {
        fees = (marginValue * 0.05) / 100;
      } else if (orderType.toLowerCase() == 'limit') {
        fees = (marginValue * 0.02) / 100;
      }
    }

    return fees.toStringAsFixed(2).toString();
  }
}
