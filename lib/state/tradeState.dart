import 'package:tradewise/state/appState.dart';

class TradeState extends AppState {
  bool _isRefresh = false;

  bool get isRefresh => _isRefresh;

  set setIsRefresh(bool isRefresh) {
    _isRefresh = isRefresh;
    notifyListeners();
  }
}
