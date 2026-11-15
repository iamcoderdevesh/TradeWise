library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:tradewise/app/router/app_routes.dart';
import 'package:tradewise/app/theme/tw_colors.dart';
import 'package:tradewise/app/theme/tw_radii.dart';
import 'package:tradewise/app/theme/tw_spacing.dart';
import 'package:tradewise/features/funds/presentation/funds_providers.dart';

class FundsScreen extends ConsumerWidget {
  const FundsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final funds = ref.watch(fundsProvider);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark
        ? TWColors.darkSurfaceElevated
        : TWColors.lightSurfaceElevated;
    final Color balanceColor = isDark
        ? TWColors.darkPrimary
        : TWColors.lightPrimary;

    return Scaffold(
      backgroundColor: isDark
          ? TWColors.darkBackgroundPrimary
          : TWColors.lightBackgroundSecondary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go(AppRoutes.profile),
        ),
        centerTitle: true,
        title: Text(
          'Funds',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: TWSpacing.l),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: TWSpacing.l),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(TWSpacing.l),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(TWRadii.large),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Available balance',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? TWColors.darkTextTertiary
                            : TWColors.lightTextTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: TWSpacing.s),
                    Text(
                      '₹${funds.availableBalance.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: balanceColor,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: TWSpacing.l),
                    FilledButton(
                      onPressed: () {
                        context.go(AppRoutes.addFund);
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(TWRadii.medium),
                        ),
                      ),
                      child: const Text('Add Funds'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: TWSpacing.l),
            const Divider(height: 1),
            const SizedBox(height: TWSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: TWSpacing.l),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Available cash',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: isDark
                                    ? TWColors.darkTextTertiary
                                    : TWColors.lightTextTertiary,
                              ),
                        ),
                        const SizedBox(height: TWSpacing.m),
                        Text(
                          '₹${funds.availableBalance.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: TWSpacing.l),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Used margin',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: isDark
                                    ? TWColors.darkTextTertiary
                                    : TWColors.lightTextTertiary,
                              ),
                        ),
                        const SizedBox(height: TWSpacing.m),
                        Text(
                          '₹${funds.usedMargin.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TWSpacing.xxl),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }
}
