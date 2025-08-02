import 'package:tradewise/services/models/tradeModel.dart';
import 'package:tradewise/state/appState.dart';

class TradeState extends AppState {

  List<TradeModel> activeTrades = [];
  bool isLoading = true;

  late String action;
  late String assetName;
  late String perChange;
  late String price;

  void setTradeData({
    required String action,
    required String assetName,
    required String perChange,
    required String price,
  }) {
    this.action = action;
    this.assetName = assetName;
    this.perChange = perChange;
    this.price = price;
    notifyListeners();
  }

  void setActiveTrades(List<TradeModel> trades) {
    activeTrades = trades;
    isLoading = false;
    notifyListeners();
  }
}