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
    return _build(
      colorScheme,
      textTheme,
      TWColors.lightBackgroundPrimary,
      TWColors.lightDivider,
    );
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
    return _build(
      colorScheme,
      textTheme,
      TWColors.darkBackgroundPrimary,
      TWColors.darkDivider,
    );
  }

  static ThemeData _build(
    ColorScheme colorScheme,
    TextTheme textTheme,
    Color scaffoldBackground,
    Color dividerColor,
  ) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      dividerColor: dividerColor,
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
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
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
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
      // Main application shell bottom navigation. Colour-only active state
      // (no Material 3 indicator pill) so the selected destination reads the
      // same way as the TradeWise references: primary-tinted icon + label.
      // TradeWise destination names and Material icons are its own; nothing
      // is copied from the reference product's navigation.
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          return IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? colorScheme.primary
                : textTheme.labelMedium?.color,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((
          Set<WidgetState> states,
        ) {
          final base = textTheme.labelMedium;
          return states.contains(WidgetState.selected)
              ? base?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                )
              : base;
        }),
      ),
    );
  }
}
