import 'package:flutter/material.dart';

import '../../../../app/theme/tw_spacing.dart';

/// Signup phone input: a fixed country-code segment, a hairline divider, and
/// the number input, matching the reference's segmented phone field.
///
/// The country code is display-only and is never part of the field value — no
/// parsing, formatting, or validation is implemented in this UI-only phase.
class AuthPhoneField extends StatelessWidget {
  const AuthPhoneField({super.key, required this.controller, this.onSubmitted});

  /// Copy taken from the reference; TradeWise does not invent its own
  /// numbering or labelling here.
  static const String countryCode = '+91';
  static const String label = 'Phone number';

  /// Divider height inside the field. Control-specific, so it stays a local
  /// constant instead of becoming a global dimension token (same convention as
  /// the Welcome screen's compact demo CTA).
  static const double _segmentHeight = TWSpacing.xxxxl + TWSpacing.l; // 56

  final TextEditingController controller;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return TextField(
      controller: controller,
      // The reference opens a plain numeric keypad (digits plus separators).
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.done,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: TWSpacing.m),
              child: Text(countryCode, style: textTheme.bodyLarge),
            ),
            Container(
              width: 1,
              height: _segmentHeight,
              color: Theme.of(context).dividerColor,
            ),
          ],
        ),
        // The segment is content-sized, not an icon slot.
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );
  }
}
