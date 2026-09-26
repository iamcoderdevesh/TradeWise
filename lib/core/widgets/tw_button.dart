import 'package:flutter/material.dart';

import '../../app/theme/tw_radii.dart';
import '../../app/theme/tw_spacing.dart';

/// Foundation primary/secondary button used by upcoming auth screens.
///
/// Simple on purpose: variant, disabled, and loading states with a minimum
/// 48dp touch target. Not a general component library.
enum TWButtonVariant { primary, secondary }

class TWButton extends StatelessWidget {
  const TWButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = TWButtonVariant.primary,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final TWButtonVariant variant;
  final bool isLoading;

  bool get _disabled => onPressed == null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? SizedBox.square(
            dimension: TWSpacing.xl,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == TWButtonVariant.primary
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.primary,
            ),
          )
        : Text(label);
    final handler = (isLoading || _disabled) ? null : onPressed;

    switch (variant) {
      case TWButtonVariant.primary:
        return FilledButton(
          onPressed: handler,
          style: FilledButton.styleFrom(
            minimumSize: const Size(48, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(TWRadii.medium),
            ),
          ),
          child: child,
        );
      case TWButtonVariant.secondary:
        return OutlinedButton(
          onPressed: handler,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(48, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(TWRadii.medium),
            ),
          ),
          child: child,
        );
    }
  }
}
