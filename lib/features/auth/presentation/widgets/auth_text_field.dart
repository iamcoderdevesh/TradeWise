import 'package:flutter/material.dart';

/// Shared outlined auth input.
///
/// Styling intentionally comes from `TWTheme`'s `inputDecorationTheme`
/// (outlined border, `TWRadii.medium`, 16/14 content padding) so the auth
/// screens reuse the existing design system instead of defining their own.
///
/// The reference's label behaviour is Material's floating label: the label sits
/// inside the field while it is empty and unfocused, and notches into the
/// border once the field is focused or filled. That is exactly what
/// [InputDecoration.labelText] provides, so nothing custom is needed here.
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;

  /// Trailing control or decorative glyph (reference shows a person glyph on
  /// the user-ID field and a visibility toggle on the password field).
  final Widget? suffixIcon;

  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      // Obscured fields must not offer suggestions or autocorrect.
      enableSuggestions: !obscureText,
      autocorrect: !obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(labelText: label, suffixIcon: suffixIcon),
    );
  }
}
