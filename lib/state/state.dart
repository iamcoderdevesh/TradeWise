import 'package:flutter/material.dart';
import 'package:tradewise/theme/theme.dart';

class TradeWiseProvider extends ChangeNotifier {
  late ThemeData themeData;

  String theme = 'sys';

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
}