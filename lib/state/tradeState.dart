import 'package:tradewise/services/models/tradeModel.dart';
import 'package:tradewise/state/appState.dart';

class TradeState extends AppState {
  List<TradeModel> activeTrades = [];
  bool _isLoading = true;

  void setActiveTrades(List<TradeModel> trades) {
    activeTrades = trades;
    _isLoading = false;
    notifyListeners();
  }

  bool get isLoading => _isLoading;

  set setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }
}
