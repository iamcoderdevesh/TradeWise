import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey.shade500,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color.fromRGBO(23, 40, 55, 1),
  ),
  fontFamily: 'Inter',
  colorScheme: ColorScheme.dark(
    primary: Color(0xE4172837),
    secondary: Color(0xFF27445D),
    background: Color(0xCC27445D),
    tertiary: Colors.grey.shade500,
    onTertiary: Colors.grey.shade700,
    primaryContainer: Colors.blue.shade600,
  ),
);

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'Inter',
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black
  ),
  colorScheme: ColorScheme.light(
    primary: Colors.white,
    secondary: Colors.white,
    background: Colors.grey.shade200,
    tertiary: Colors.grey.shade500,
    onTertiary: Colors.grey.shade300,
    primaryContainer: Colors.blue.shade600,
  ),
);
