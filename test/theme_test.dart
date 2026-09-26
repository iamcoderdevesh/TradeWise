import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tradewise/app/theme/tw_colors.dart';
import 'package:tradewise/app/theme/tw_radii.dart';
import 'package:tradewise/app/theme/tw_spacing.dart';
import 'package:tradewise/app/theme/tw_theme.dart';
import 'package:tradewise/app/theme/tw_typography.dart';

void main() {
  test('light theme uses Inter and light tokens', () {
    final theme = TWTheme.light();

    expect(theme.useMaterial3, isTrue);
    expect(theme.textTheme.bodyMedium?.fontFamily, TWTypography.fontFamily);
    expect(theme.scaffoldBackgroundColor, TWColors.lightBackgroundPrimary);
    expect(theme.colorScheme.brightness, Brightness.light);
  });

  test('dark theme uses Inter and dark tokens', () {
    final theme = TWTheme.dark();

    expect(theme.useMaterial3, isTrue);
    expect(theme.textTheme.bodyMedium?.fontFamily, TWTypography.fontFamily);
    expect(theme.scaffoldBackgroundColor, TWColors.darkBackgroundPrimary);
    expect(theme.colorScheme.brightness, Brightness.dark);
  });

  test('light and dark schemes differ', () {
    final light = TWTheme.light();
    final dark = TWTheme.dark();

    expect(light.colorScheme.primary, isNot(dark.colorScheme.primary));
    expect(light.scaffoldBackgroundColor, isNot(dark.scaffoldBackgroundColor));
  });

  test('spacing and radii scales are ordered', () {
    expect(TWSpacing.xs, lessThan(TWSpacing.s));
    expect(TWSpacing.s, lessThan(TWSpacing.m));
    expect(TWSpacing.m, lessThan(TWSpacing.l));
    expect(TWSpacing.l, lessThan(TWSpacing.xl));
    expect(TWSpacing.xl, lessThan(TWSpacing.xxl));
    expect(TWSpacing.xxl, lessThan(TWSpacing.xxxl));
    expect(TWSpacing.xxxl, lessThan(TWSpacing.xxxxl));

    expect(TWRadii.small, lessThan(TWRadii.medium));
    expect(TWRadii.medium, lessThan(TWRadii.large));
    expect(TWRadii.large, lessThan(TWRadii.pill));
  });
}
