import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tradewise/constant/constant.dart';
import 'package:tradewise/helpers/sharedPreferences.dart';
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
    required String leverage,
  }) {
    late double margin = 0.00;
    margin = (quantity.isNotEmpty && quantity != '0') ? double.parse(quantity) * double.parse(price) : 0.00;
    margin = (leverage.isNotEmpty && leverage != '0') ? margin / double.parse(leverage) : margin;

    return margin.toStringAsFixed(2).toString();
  }

  String calculateFees({
    required String segment,
    String orderType = 'market',
    String margin = '0',
    String leverage = '0',
    String quantity = '0',
    String buyPrice = '0',
    String sellPrice = '0'
  }) {
    late double fees = 0.0;
    double marginValue = double.parse(margin);

    if (segment.toLowerCase() == 'crypto') {
      if(leverage.isNotEmpty && leverage != '0') {
        marginValue = marginValue * double.parse(leverage);
      }

      if (orderType.toLowerCase() == 'market') {
        fees = (marginValue * 0.05) / 100;
      } else if (orderType.toLowerCase() == 'limit') {
        fees = (marginValue * 0.02) / 100;
      }
    }
    else if(segment.toLowerCase() == 'stocks') {

      double buyValue = double.parse(buyPrice) * double.parse(quantity);
      double sellValue = double.parse(sellPrice) * double.parse(quantity);

      double brokerage = buyPrice != '0' && sellPrice != '0' ? 20.0 * 2 : 20.0;
      double transactionCharge = marginValue * 0.0005;
      double stt = sellPrice != '0' ? sellValue * 0.0005 : 0.00;
      double sebi = marginValue * 0.000001;
      double stampDuty = buyPrice != '0' ? buyValue * 0.00003 : 0.00;
      double gst = 0.18 * (brokerage + transactionCharge);

      fees = brokerage + transactionCharge + stt + sebi + stampDuty + gst;
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

  String convertDate({required String inputDate, String inputFormat = 'dd-MMM-yyyy', String outputFormat = 'yyyy-MM-dd'}) {

    DateFormat _inputFormat = DateFormat(inputFormat);
    DateFormat _outputFormat = DateFormat(outputFormat);

    DateTime parsedDate = _inputFormat.parse(inputDate);
    String newDate = _outputFormat.format(parsedDate);

    return newDate;
  }

  Future<void> cacheApiCallCount({required String cacheKey}) async {

    List<Map<String, dynamic>> data = await getCachedData(key: cacheKey);
    int apiCallCount = int.parse(data.isNotEmpty ? data[0][cacheKey].toString() : "0");
    apiCallCount++;
    
    await cacheData(key: cacheKey, data: [{cacheKey: apiCallCount}]);
  }

  String getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
