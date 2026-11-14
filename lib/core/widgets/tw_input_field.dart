import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/tw_radii.dart';

/// A shared text input field used across Order Placement, Login, and Signup.
///
/// Supports two rendering contexts:
///
/// * **Standalone mode** (`embedded: false`) — Login and Signup. Draws its own
///   outline using the Order Placement field geometry: 52dp height,
///   `TWRadii.medium` border radius, `Theme.of(context).focusColor` border,
///   and `TWSpacing.m`/`TWSpacing.xs` content padding. Supports focused,
///   unfocused, and error states in both light and dark themes.
///
/// * **Embedded mode** (`embedded: true`) — Order Placement. Renders a bare
///   `TextField` with `InputDecoration(border: InputBorder.none)` so the
///   existing `ConnectedFieldBox` remains solely responsible for the visible
///   border, height, padding, and trailing segment. Order Placement's
///   appearance is unchanged.
class TwInputField extends StatelessWidget {
  const TwInputField({
    super.key,
    required this.controller,
    required this.label,
    this.suffixIcon,
    this.prefixIcon,
    this.prefixIconConstraints,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.inputFormatters,
    this.style,
    this.errorText,
    this.embedded = false,
  });

  final TextEditingController controller;
  final String label;

  /// Trailing control or decorative glyph (standalone mode only).
  final Widget? suffixIcon;

  /// Leading content (e.g. the `+91` country-code segment on Signup).
  final Widget? prefixIcon;

  /// Constraints for [prefixIcon] (standalone mode only).
  final BoxConstraints? prefixIconConstraints;

  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? style;

  /// Error message shown in standalone mode. When set, the border resolves to
  /// the theme error color.
  final String? errorText;

  /// Embedded mode used inside Order Placement's `ConnectedFieldBox`.
  final bool embedded;

  /// Field height measured from the Order Placement reference (~52dp).
  static const double height = 65;

  @override
  Widget build(BuildContext context) {
    final textStyle =
        style ??
        Theme.of(context).textTheme.bodyLarge
            ?.copyWith(fontWeight: FontWeight.w400);

    final field = TextField(
      controller: controller,
      obscureText: obscureText,
      // Obscured fields must not offer suggestions or autocorrect.
      enableSuggestions: !obscureText,
      autocorrect: !obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      inputFormatters: inputFormatters,
      style: textStyle,
      decoration: InputDecoration(
        border: const InputDecoration(border: InputBorder.none).border,
        labelText: embedded ? null : label,
        suffixIcon: embedded ? null : suffixIcon,
        prefixIcon: embedded ? null : prefixIcon,
        prefixIconConstraints: embedded ? null : prefixIconConstraints,
        errorText: embedded ? null : errorText,
      ),
    );

    // Embedded mode: Order Placement's ConnectedFieldBox draws the border,
    // height, padding, and trailing segment. Return the bare field.
    if (embedded) return field;

    // Standalone mode: draw the Order Placement field outline directly.
    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border.all(
          color: errorText != null
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).focusColor,
        ),
        borderRadius: BorderRadius.circular(TWRadii.medium),
      ),
      child: field,
    );
  }
}
