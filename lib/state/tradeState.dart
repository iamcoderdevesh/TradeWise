import 'dart:async';
import 'package:tradewise/helpers/helper.dart';
import 'package:tradewise/services/api/api.dart';
import 'package:tradewise/services/api/websocket.dart';
import 'package:tradewise/services/controllers/tradeController.dart';
import 'package:tradewise/state/appState.dart';

class TradeState extends AppState {
  Timer? _timer;
  late bool _isTradeScreenActive = false;
  List<Map<String, dynamic>> _openTrades = [];

  late Future<List<Map<String, dynamic>>> openedTradeList = Future.value([]);
  late Future<List<Map<String, dynamic>>> closeTradeList = Future.value([]);

  late WebSocketService _webSocketService;
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
    if (marketType == 'crypto') _webSocketService = WebSocketService(onTickerUpdate: _handleTickerUpdate);
  }

  /// api code starts.
  void initOpenPosition() {
    _isTradeScreenActive = true;
    openedTradeList = marketType == 'crypto'
        ? initSocketOpenPosition()
        : handleOpenTradePostion();
    if (marketType == 'stocks') updateTradePostion();
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

    if ((tradeList.isEmpty || !_isTradeScreenActive || !isOnline) &&
        isTimerCall) {
      _timer!.cancel();
      return result;
    }

    for (final pos in tradeList) {
      final currentTickerData = isOnline? await _apiService.getTickerPrice(pos.assetName ?? '', marketSegment: pos.marketSegment): pos.ltp;
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

      if (isOnline) {
        await tradeController.updateLtp(userId: pos.userId, tradeId: pos.tradeId, ltp: currentPrice);
      }
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
    if(_timer != null) {
      _timer?.cancel();
    }
    else {
      cancelWebSockets();
    }
  }
  /// api code ends.

  /// websocket code starts.
  Future<List<Map<String, dynamic>>> initSocketOpenPosition() async {
    _openedPnL = 0.00;
    if (!isOnline) return _openTrades;

    final trades = await tradeController.getTrades(status: "OPEN");

    _openTrades = trades.map((pos) {
      final currentPrice = pos.ltp ?? pos.entryPrice;
      return {
        'tradeId': pos.tradeId,
        'assetName': pos.assetName,
        'ltp': currentPrice,
        'quantity': pos.quantity,
        'entryPrice': pos.entryPrice,
        'action': pos.action,
        'status': "OPEN",
        'marketSegment': pos.marketSegment,
        'userId': pos.userId,
        'pnl': helper.formatNumber(
          value: helper
              .calculatePnL(
                action: pos.action,
                currentPrice: currentPrice,
                buyPrice: pos.entryPrice,
                quantity: pos.quantity,
              )
              .toString(),
          formatNumber: 2,
          plusSign: true,
        )
      };
    }).toList();

    for (final trade in _openTrades) {
      if (trade['assetName'] != null) {
        _webSocketService.subscribeToSymbol(symbol: trade['assetName'], isFuture: trade['marketSegment'] == "Spot" ? false : true);
      }
    }

    return _openTrades;
  }

  void _handleTickerUpdate(String symbol, double price) async {
    _openedPnL = 0.00;
    if (!_isTradeScreenActive || !isOnline) return;

    for (var i = 0; i < _openTrades.length; i++) {
      final trade = _openTrades[i];
      String currentPrice = helper.formatNumber(value: price.toString(), formatNumber: 4);

      if (trade['assetName'].toLowerCase() == symbol.toLowerCase()) {
        final pnl = helper.calculatePnL(
          action: trade['action'],
          currentPrice: currentPrice,
          buyPrice: trade['entryPrice'],
          quantity: trade['quantity'],
        );

        _openedPnL += pnl;

        _openTrades[i]['ltp'] = currentPrice;
        _openTrades[i]['pnl'] = helper.formatNumber(
          value: pnl.toString(),
          formatNumber: 2,
          plusSign: true,
        );

        await tradeController.updateLtp(
          userId: trade['userId'],
          tradeId: trade['tradeId'],
          ltp: currentPrice,
        );
      }
    }

    openedTradeList = Future.value(_openTrades);
    notifyListeners();
  }

  void cancelWebSockets() {
    _isTradeScreenActive = false;
    _webSocketService.disposeAll();
    print("WebSockets disposed");
  }
  /// websocket code ends.
}
