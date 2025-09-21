import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tradewise/state/appState.dart';
import 'package:tradewise/widgets/widgets.dart';

class Helper {
  Helper();

  Future<bool> checkConnectivity(BuildContext context) async {
    final isOnline = Provider.of<AppState>(context, listen: false).isOnline;
    if (!isOnline) {
      Future.delayed(const Duration(milliseconds: 500), () {
        showSnackbar(context, message: "No internet connection. Please try again later.", type: SnackbarType.error);
      });
      return false;
    }

    return true;
  }

  String getFirstLetter({required String value}) =>
      value.toString().substring(0, 1);

  String formatNumber(
          {required String value,
          int formatNumber = 2,
          bool plusSign = false}) =>
      plusSign
          ? (double.parse(value) > 0
              ? '+${double.parse(value).toStringAsFixed(formatNumber)}'
              : double.parse(value).toStringAsFixed(formatNumber))
          : double.parse(value).toStringAsFixed(formatNumber);

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

  double calculatePnL({
    required String? action,
    required String? currentPrice,
    required String? buyPrice,
    required String? quantity,
  }) {
    double _currentPrice = double.parse(currentPrice ?? '0.00');
    double _buyPrice = double.parse(buyPrice ?? '0.00');
    double _quantity = double.parse(quantity ?? '0.00');

    late double pnl = action == 'SELL' ? (_buyPrice - _currentPrice) * _quantity : (_currentPrice - _buyPrice) * _quantity;
    return pnl;
  }

  String convertTimestampToTime(Timestamp timestamp) {
    try {
      // Convert Firebase Timestamp to DateTime
      DateTime dateTime = timestamp.toDate();

      // Format the DateTime to "hh:mm a" format (12-hour format with AM/PM)
      return DateFormat("hh:mm a").format(dateTime);
    } catch (e) {
      return "Invalid timestamp";
    }
  }
}
