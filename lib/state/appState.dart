import 'package:flutter/material.dart';
import 'package:tradewise/theme/theme.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AppState extends ChangeNotifier {
  late ThemeData themeData = darkTheme;
  String theme = 'sys';
  String _marketType = 'crypto';
  int _pageIndex = 0;
  bool _isOnline = true;
  final Connectivity _connectivity = Connectivity();

  AppState() {
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  String get marketType => _marketType;
  bool get isOnline => _isOnline;
  int get pageIndex => _pageIndex;

  void _initConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);
  }

  void _updateStatus(ConnectivityResult result) {
    _isOnline = result != ConnectivityResult.none;
    notifyListeners();
  }

  void toggleTheme({required String mode, String? isSys}) {
    if (mode == 'dark' && isSys == null) {
      theme = mode;
      themeData = darkTheme;
    } else if (mode == 'light' && isSys == null) {
      theme = mode;
      themeData = lightTheme;
    } else {
      themeData = mode == 'light' ? lightTheme : darkTheme;
      theme = isSys!;
    }

    notifyListeners();
  }

  set setPageIndex(int index) {
    _pageIndex = index;
    notifyListeners();
  }
}
