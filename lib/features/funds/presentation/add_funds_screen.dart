library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:tradewise/app/router/app_routes.dart';
import 'package:tradewise/app/theme/tw_colors.dart';
import 'package:tradewise/app/theme/tw_spacing.dart';
import 'package:tradewise/core/widgets/tw_input_field.dart';
import 'package:tradewise/core/widgets/tw_notification.dart';
import 'package:tradewise/features/funds/presentation/funds_providers.dart';
import 'package:tradewise/features/order/presentation/order_enums.dart';
import 'package:tradewise/features/order/presentation/widgets/swipe_to_confirm.dart';

class AddFundsScreen extends ConsumerStatefulWidget {
  const AddFundsScreen({super.key});

  @override
  ConsumerState<AddFundsScreen> createState() => _AddFundsScreenState();
}

class _AddFundsScreenState extends ConsumerState<AddFundsScreen> {
  late final TextEditingController _amountController;

  /// Guards against duplicate submissions while a swipe completion is in
  /// progress.
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  /// Validates the amount text and returns an error message if invalid, or
  /// null when the amount is valid.
  String? _validateAmount(String text) {
    final String trimmed = text.trim();
    if (trimmed.isEmpty) {
      return 'Amount cannot be empty';
    }
    final double? value = double.tryParse(trimmed);
    if (value == null) {
      return 'Enter a valid amount';
    }
    if (!value.isFinite) {
      return 'Enter a valid amount';
    }
    if (value <= 0) {
      return 'Amount must be greater than zero';
    }
    // Guard against more than 2 decimal places (input formatter already
    // restricts this, but validate defensively).
    final int decimalPlaces = trimmed.contains('.')
        ? trimmed.split('.').last.length
        : 0;
    if (decimalPlaces > 2) {
      return 'Amount cannot exceed two decimal places';
    }
    return null;
  }

  double? _parseAmount(String text) {
    final String trimmed = text.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final double? value = double.tryParse(trimmed);
    if (value == null || !value.isFinite || value <= 0) {
      return null;
    }
    return value;
  }

  void _addFunds() {
    if (_isSubmitting) return;
    final String? error = _validateAmount(_amountController.text);
    if (error != null) {
      TWNotifications.showError(context, error);
      return;
    }
    final double? amount = _parseAmount(_amountController.text);
    if (amount == null) {
      TWNotifications.showError(context, 'Enter a valid amount');
      return;
    }
    _isSubmitting = true;
    final double beforeBalance = ref.read(fundsProvider).availableBalance;
    ref.read(fundsProvider.notifier).addFunds(amount);
    final double afterBalance = ref.read(fundsProvider).availableBalance;
    if (afterBalance > beforeBalance) {
      TWNotifications.showSuccess(
        context,
        '₹${amount.toStringAsFixed(2)} added',
      );
      _amountController.clear();
      // Navigate back to Funds only if a router is available (guards against
      // test environments without GoRouter, matching OrderPlacementScreen's
      // defensive navigation pattern).
      if (GoRouter.maybeOf(context) != null) {
        context.go(AppRoutes.fund);
      }
    }
    _isSubmitting = false;
  }

  @override
  Widget build(BuildContext context) {
    final funds = ref.watch(fundsProvider);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
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
          onPressed: () => context.go(AppRoutes.fund),
        ),
        centerTitle: true,
        title: Text(
          'Add Funds',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: TWSpacing.l),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: TWSpacing.l,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              'Balance',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: isDark
                                        ? TWColors.darkTextSecondary
                                        : TWColors.lightTextSecondary,
                                  ),
                            ),
                            const SizedBox(width: TWSpacing.s),
                            Text(
                              '₹${funds.availableBalance.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: balanceColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        const Divider(height: TWSpacing.xxl),
                      ],
                    ),
                  ),
                  const SizedBox(height: TWSpacing.xxl),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: TWSpacing.l,
                    ),
                    child: Text(
                      'Amount',
                      style: Theme.of(context).textTheme.labelLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: TWSpacing.s),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: TWSpacing.l,
                    ),
                    child: TwInputField(
                      controller: _amountController,
                      label: 'Enter Amount',
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(
                          left: TWSpacing.l,
                          right: TWSpacing.s,
                        ),
                        child: Text(
                          '₹',
                          style: TextStyle(
                            color: isDark
                                ? TWColors.darkTextSecondary
                                : TWColors.lightTextSecondary,
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.done,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: TWSpacing.xxl),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: TWSpacing.l),
              child: SwipeToConfirm(
                side: OrderSide.buy,
                accent: Theme.of(context).colorScheme.primary,
                onAccent: Colors.white,
                enabled: true,
                label: 'Swipe to Add Funds',
                onCompleted: _addFunds,
                trackWidthFraction: 0.99,
                maxTrackWidth: 300,
              ),
            ),
            const SizedBox(height: TWSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
