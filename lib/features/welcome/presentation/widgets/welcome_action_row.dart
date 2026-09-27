import 'package:flutter/material.dart';

import '../../../../app/theme/tw_spacing.dart';

/// A full-width Welcome action row: label on the left, icon on the right.
///
/// Interaction is a plain [InkWell]; the button role and label are declared
/// through [Semantics] so assistive technology and tests read the row rather
/// than depending on the gesture implementation.
class WelcomeActionRow extends StatelessWidget {
  const WelcomeActionRow({
    super.key,
    required this.label,
    required this.icon,
    required this.semanticsLabel,
    this.onTap,
  });

  /// Divider-to-divider pitch measured from `references/kite/welcome/`
  /// (71.4dp), rounded to the 4pt scale. Keeps the reference's airy rhythm
  /// while staying above the 48dp minimum touch target.
  static const double _minHeight = TWSpacing.xxxl + TWSpacing.xxxxl;

  /// Trailing icon size. Specific to this row, so it stays local instead of
  /// becoming a global dimension token.
  static const double _iconSize = 28;

  final String label;
  final IconData icon;
  final String semanticsLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      enabled: onTap != null,
      label: semanticsLabel,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _minHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: TWSpacing.l),
            child: Row(
              children: [
                Expanded(child: Text(label, style: textTheme.displaySmall)),
                Icon(icon, size: _iconSize, color: colorScheme.onSurface),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
