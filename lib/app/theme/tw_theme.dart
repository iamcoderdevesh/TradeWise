import 'package:flutter/material.dart';

import 'tw_colors.dart';
import 'tw_radii.dart';
import 'tw_typography.dart';

/// Builds the TradeWise Material 3 light and dark themes from tokens.
abstract final class TWTheme {
  static ThemeData light() {
    final textTheme = TWTypography.textTheme(
      TWColors.lightTextPrimary,
      TWColors.lightTextSecondary,
    );
    final colorScheme = const ColorScheme.light(
      primary: TWColors.lightPrimary,
      onPrimary: Colors.white,
      primaryContainer: TWColors.lightPrimaryVariant,
      surface: TWColors.lightSurface,
      onSurface: TWColors.lightTextPrimary,
      error: TWColors.lightNegative,
    );
    return _build(colorScheme, textTheme, TWColors.lightBackgroundPrimary);
  }

  static ThemeData dark() {
    final textTheme = TWTypography.textTheme(
      TWColors.darkTextPrimary,
      TWColors.darkTextSecondary,
    );
    final colorScheme = const ColorScheme.dark(
      primary: TWColors.darkPrimary,
      onPrimary: Color(0xFF0B0F14),
      primaryContainer: TWColors.darkPrimaryVariant,
      surface: TWColors.darkSurface,
      onSurface: TWColors.darkTextPrimary,
      error: TWColors.darkNegative,
    );
    return _build(colorScheme, textTheme, TWColors.darkBackgroundPrimary);
  }

  static ThemeData _build(
    ColorScheme colorScheme,
    TextTheme textTheme,
    Color scaffoldBackground,
  ) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      textTheme: textTheme,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TWRadii.medium),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TWRadii.medium),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TWRadii.medium),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TWRadii.large),
        ),
      ),
    );
  }
}
