import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:tradewise/app/theme/tw_colors.dart';
import 'package:tradewise/app/theme/tw_spacing.dart';
import 'package:tradewise/features/order/presentation/order_enums.dart';

import 'connected_field_box.dart';

/// Quantity / Amount size input with the reference's single section label and
/// connected swap segment.
///
/// Quantity mode takes whole shares (`FilteringTextInputFormatter.digitsOnly`
/// + numeric keyboard). Amount mode takes a rupee value and shows the derived
/// whole-share quantity (`N Qty.`) floored at the effective price, so a
/// fractional share is never implied as tradeable.
class OrderQuantitySection extends StatelessWidget {
  const OrderQuantitySection({
    super.key,
    required this.inputMode,
    required this.accent,
    required this.quantityController,
    required this.amountController,
    required this.derivedQuantity,
    required this.onInputModeChanged,
  });

  final OrderInputMode inputMode;
  final Color accent;
  final TextEditingController quantityController;
  final TextEditingController amountController;

  /// Floored whole-share derivation, shown only in Amount mode.
  final int? derivedQuantity;

  final ValueChanged<OrderInputMode> onInputModeChanged;

  @override
  Widget build(BuildContext context) {
    final bool isAmount = inputMode == OrderInputMode.amount;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    // Reference: the quantity-mode swap glyph is muted; the amount-mode
    // glyph carries the accent colour.
    final Color segmentColor = isAmount
        ? accent
        : (isDark ? TWColors.darkTextTertiary : TWColors.lightTextTertiary);
    final Color textColor = isDark
        ? TWColors.darkTextTertiary
        : TWColors.lightTextPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                isAmount ? 'Amount' : 'Quantity',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w400, color: textColor),
                maxLines: 1,
              ),
            ),
            if (isAmount)
              Text(
                '$derivedQuantity Qty.',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: textColor),
                maxLines: 1,
              ),
          ],
        ),
        const SizedBox(height: TWSpacing.m),
        ConnectedFieldBox(
          input: isAmount
              ? _MoneyField(controller: amountController)
              : _QuantityField(controller: quantityController),
          segmentIcon: Icons.swap_horiz,
          segmentColor: segmentColor,
          segmentTooltip: isAmount
              ? 'Switch to quantity input'
              : 'Switch to amount input',
          onSegmentTap: () => onInputModeChanged(
            isAmount ? OrderInputMode.quantity : OrderInputMode.amount,
          ),
        ),
      ],
    );
  }
}

/// Whole-share quantity input: digits only, numeric keyboard.
class _QuantityField extends StatelessWidget {
  const _QuantityField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(border: InputBorder.none),
      style: Theme.of(context).textTheme.headlineSmall
          ?.copyWith(fontWeight: FontWeight.w400),
    );
  }
}

/// Rupee amount input: decimal with at most two fraction digits, numeric
/// keyboard with decimal support. No currency prefix — the section label and
/// the estimate band provide the unit, as in the reference.
class _MoneyField extends StatelessWidget {
  const _MoneyField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(border: InputBorder.none),
      style: Theme.of(context).textTheme.titleLarge
          ?.copyWith(fontWeight: FontWeight.w400),
    );
  }
}
