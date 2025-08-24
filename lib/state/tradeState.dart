import 'dart:async';

import 'package:tradewise/helpers/helper.dart';
import 'package:tradewise/services/api/api.dart';
import 'package:tradewise/services/controllers/tradeController.dart';
import 'package:tradewise/state/appState.dart';

class TradeState extends AppState {
  late Timer _timer;
  late bool _isTradeScreenActive = false;

  dynamic activeTradeList;
  dynamic inActiveTradeList;

  late Future<List<Map<String, dynamic>>> openedTradeList;
  late Future<List<Map<String, dynamic>>> closeTradeList;

  late Future<List<Map<String, dynamic>>> tradeList;

  final Helper helper = Helper();
  final ApiService _apiService = ApiService();
  final tradeController = TradeController();

  late double _totalPnL = 0.00;
  late double _closedPnL = 0.00;

  double get totalPnl => _totalPnL;

  void initPosition() {
    activeTradeList = null;
    inActiveTradeList = null;
    _isTradeScreenActive = true;
    closeTradeList = handleTradePostion(status: 'CLOSED');
    openedTradeList = handleTradePostion(status: 'OPEN');
    tradeList = getCombineTrades();
    updateTradePostion();
    notifyListeners();
  }

  void updateTradePostion() {
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer t) {
      openedTradeList = handleTradePostion(isTimerCall: true, status: 'OPEN');
      tradeList = getCombineTrades();
      notifyListeners();
    });
  }

  Future<List<Map<String, dynamic>>> handleTradePostion({
    required String status,
    bool isTimerCall = false,
  }) async {
    dynamic tradeList;
    double totalPnl = 0.00;
    List<Map<String, dynamic>> result = [];

    if (activeTradeList != null && status == 'OPEN') {
      tradeList = activeTradeList;
    } else if (inActiveTradeList != null && status == 'CLOSED') {
      tradeList = inActiveTradeList;
    } else {
      tradeList = await tradeController.getTrades(status: status);
      status == 'CLOSED' ? inActiveTradeList = tradeList : null;
      status == 'OPEN' ? activeTradeList = tradeList : null;
    }

    if ((tradeList.isEmpty && isTimerCall && status == 'OPEN') || !_isTradeScreenActive) {
      _timer.cancel();
      return result;
    }

    for (final pos in tradeList) {
      final currentTickerData = status == 'CLOSED'
          ? null
          : await _apiService.getTickerPrice(pos.assetName ?? '',
              marketSegment: pos.marketSegment);

      final currentPrice =
          status == 'CLOSED' ? pos.exitPrice : currentTickerData?['assetPrice'];
      final pnl = status == 'CLOSED'
          ? double.parse(pos.netPnl ?? '0.00')
          : helper.calculatePnL(
              action: pos.action,
              currentPrice: currentPrice,
              buyPrice: pos.entryPrice,
              quantity: pos.quantity,
            );

      totalPnl += pnl;

      result.add({
        'tradeId': pos.tradeId,
        'assetName': pos.assetName,
        'ltp': currentPrice,
        'quantity': pos.quantity,
        'entryPrice': pos.entryPrice,
        'action': pos.action,
        'status': status,
        'marketSegment': pos.marketSegment,
        'pnl': helper.formatNumber(
            value: pnl.toString(), formatNumber: 2, plusSign: true)
      });
    }

    _totalPnL = totalPnl + _closedPnL;

    if (status == 'CLOSED') {
      _closedPnL = totalPnl;
    }

    return result;
  }

  Future<List<Map<String, dynamic>>> getCombineTrades() async {
    final results = await Future.wait([openedTradeList, closeTradeList]);
    return [...results[0], ...results[1]];
  }

  void cancelTimer() {
    _isTradeScreenActive = false;
    _timer.cancel();
  }
}
