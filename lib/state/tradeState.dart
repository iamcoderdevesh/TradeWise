import 'package:tradewise/services/models/tradeModel.dart';
import 'package:tradewise/state/appState.dart';

class TradeState extends AppState {

  List<TradeModel> activeTrades = [];
  bool isLoading = true;

  late String action;
  late String assetName;

  void setTradeData({
    required String action,
    required String assetName,
  }) {
    this.action = action;
    this.assetName = assetName;
    notifyListeners();
  }

  void setActiveTrades(List<TradeModel> trades) {
    activeTrades = trades;
    isLoading = false;
    notifyListeners();
  }
}