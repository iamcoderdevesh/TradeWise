import 'package:tradewise/state/appState.dart';

class AccountState extends AppState {
  late String? accountId;
  late String totalBalance = '0';

  void setAccountData({
    String? accountId,
    required String totalBalance,
  }) {
    this.accountId = accountId;
    this.totalBalance = totalBalance;
    notifyListeners();
  }
}
