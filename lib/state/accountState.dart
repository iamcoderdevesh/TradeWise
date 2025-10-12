import 'package:tradewise/state/appState.dart';

class AccountState extends AppState {
  late String? accountId;
  late String totalBalance = '0';
  late String accountType = '';

  void setAccountData({
    String? accountId,
    required String totalBalance,
    required String accountType,
  }) {
    this.accountId = accountId;
    this.totalBalance = totalBalance;
    this.accountType = accountType;
    notifyListeners();
  }
}
