import 'package:flutter/material.dart';
import 'package:tradewise/theme/theme.dart';

class AppState extends ChangeNotifier {
  late ThemeData themeData = darkTheme;
  String theme = 'sys';
  int _pageIndex = 0;

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

  int get pageIndex {
    return _pageIndex;
  }

  set setPageIndex(int index) {
    _pageIndex = index;
    notifyListeners();
  }
}
