import 'dart:async';
import 'package:tradewise/helpers/helper.dart';
import 'package:tradewise/services/api/api.dart';
import 'package:tradewise/services/controllers/tradeController.dart';
import 'package:tradewise/state/appState.dart';

class TradeState extends AppState {
  late Timer _timer;
  late bool _isTradeScreenActive = false;

  late Future<List<Map<String, dynamic>>> openedTradeList;
  late Future<List<Map<String, dynamic>>> closeTradeList;

  final Helper helper = Helper();
  final ApiService _apiService = ApiService();
  final tradeController = TradeController();

  late double _openedPnL = 0.00;
  late double _closedPnL = 0.00;

  double get openedPnl => _openedPnL;
  double get closedPnL => _closedPnL;

  TradeState() {
    _openedPnL = 0.00;
    _closedPnL = 0.00;
  }

  void initOpenPosition() {
    _isTradeScreenActive = true;
    openedTradeList = handleOpenTradePostion();
    updateTradePostion();
    notifyListeners();
  }

  void initClosedPosition() {
    _isTradeScreenActive = true;
    closeTradeList = handleClosedTradePostion();
    notifyListeners();
  }

  void updateTradePostion() {
    if (isOnline) {
      _timer = Timer.periodic(const Duration(seconds: 2), (Timer t) {
        openedTradeList = handleOpenTradePostion(isTimerCall: true);
        notifyListeners();
      });
    }
  }

  Future<List<Map<String, dynamic>>> handleOpenTradePostion({
    bool isTimerCall = false,
  }) async {
    double totalPnL = 0.00;
    dynamic tradeList;
    List<Map<String, dynamic>> result = [];

    tradeList = await tradeController.getTrades(status: "OPEN");


    if ((tradeList.isEmpty && isTimerCall) || !_isTradeScreenActive || !isOnline) {
      _timer.cancel();
      return result;
    }

    for (final pos in tradeList) {
      final currentTickerData = isOnline ? await _apiService.getTickerPrice(pos.assetName ?? '', marketSegment: pos.marketSegment) : pos.ltp;
      final currentPrice = isOnline ? currentTickerData['assetPrice'] : pos.ltp;

      final pnl = helper.calculatePnL(
        action: pos.action,
        currentPrice: currentPrice,
        buyPrice: pos.entryPrice,
        quantity: pos.quantity,
      );

      totalPnL += pnl;

      result.add({
        'tradeId': pos.tradeId,
        'assetName': pos.assetName,
        'ltp': currentPrice,
        'quantity': pos.quantity,
        'entryPrice': pos.entryPrice,
        'action': pos.action,
        'status': "OPEN",
        'marketSegment': pos.marketSegment,
        'pnl': helper.formatNumber(
            value: pnl.toString(), formatNumber: 2, plusSign: true)
      });

      await tradeController.updateLtp(
          userId: pos.userId, tradeId: pos.tradeId, ltp: currentPrice);
    }

    _openedPnL = totalPnL;

    notifyListeners();
    return result;
  }

  Future<List<Map<String, dynamic>>> handleClosedTradePostion() async {
    double totalPnL = 0.00;
    List<Map<String, dynamic>> result = [];

    dynamic tradeList = await tradeController.getTrades(status: "CLOSED");

    for (final pos in tradeList) {
      result.add({
        'tradeId': pos.tradeId,
        'assetName': pos.assetName,
        'ltp': pos.ltp,
        'quantity': pos.quantity,
        'entryPrice': pos.entryPrice,
        'action': pos.action,
        'status': "CLOSED",
        'marketSegment': pos.marketSegment,
        'pnl': helper.formatNumber(
            value: pos.netPnl.toString(), formatNumber: 2, plusSign: true)
      });

      totalPnL += double.parse(pos.netPnl);
    }

    _closedPnL = totalPnL;

    notifyListeners();
    return result;
  }

  void cancelTimer() {
    _isTradeScreenActive = false;
    _timer.cancel();
  }
}
