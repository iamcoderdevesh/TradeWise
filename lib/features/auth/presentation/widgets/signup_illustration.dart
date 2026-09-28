import 'package:flutter/material.dart';

import '../../../../app/theme/tw_radii.dart';
import '../../../../app/theme/tw_spacing.dart';

/// Original TradeWise illustration for the Signup heading.
///
/// Reproduces the reference's *visual weight* — a message card carrying a code
/// badge — from TradeWise tokens and stock Material glyphs. It is deliberately
/// abstract and shares no artwork with the proprietary reference illustration.
/// Self-contained on purpose: final brand artwork can replace this one widget
/// without touching the screen.
class SignupIllustration extends StatelessWidget {
  const SignupIllustration({super.key});

  /// Approximate reference footprint (~200x160dp) snapped to the token scale.
  static const double _width = TWSpacing.xxxxl * 5; // 200
  static const double _height = TWSpacing.xxxxl * 4; // 160
  static const double _cardWidth = TWSpacing.xxxxl * 4; // 160
  static const double _cardHeight = TWSpacing.xxxxl * 2 + TWSpacing.l; // 96

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dividerColor = Theme.of(context).dividerColor;

    return Semantics(
      image: true,
      label: 'Illustration of a verification code message',
      child: SizedBox(
        width: _width,
        height: _height,
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Container(
                width: _cardWidth,
                height: _cardHeight,
                padding: const EdgeInsets.symmetric(
                  horizontal: TWSpacing.l,
                  vertical: TWSpacing.m,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(TWRadii.large),
                  border: Border.all(color: dividerColor),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.mark_email_unread_outlined,
                      size: TWSpacing.xxl,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: TWSpacing.m),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _bar(color: colorScheme.primary, widthFactor: 0.85),
                          const SizedBox(height: TWSpacing.s),
                          _bar(color: dividerColor, widthFactor: 1),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: TWSpacing.m,
                  vertical: TWSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(TWRadii.pill),
                ),
                child: Text(
                  'OTP',
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// A rounded placeholder bar standing in for a line of message text.
  Widget _bar({required Color color, required double widthFactor}) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor,
      child: Container(
        height: TWSpacing.s,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(TWRadii.pill),
        ),
      ),
    );
  }
}
