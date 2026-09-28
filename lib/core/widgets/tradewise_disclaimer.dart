import 'package:flutter/material.dart';

import '../../app/theme/tw_spacing.dart';

/// Shared TradeWise footer/disclaimer block.
///
/// Placeholder product copy only — NOT final legal language. No external
/// links or routes; underlined spans are visual only and non-interactive.
///
/// Extracted from the Welcome screen so Welcome, Login, and Signup share one
/// footer instead of Auth depending on the Welcome feature. Appearance and
/// behaviour are unchanged from the Welcome-only version.
class TradeWiseDisclaimer extends StatelessWidget {
  const TradeWiseDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final muted = textTheme.bodySmall;
    final linkStyle = muted?.copyWith(decoration: TextDecoration.underline);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TRADEWISE',
          style: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: TWSpacing.s),
        Text.rich(
          TextSpan(
            style: muted,
            children: [
              const TextSpan(
                text:
                    'TradeWise is a paper-trading learning experience. '
                    'Prices shown during development are illustrative mock data. ',
              ),
              TextSpan(text: 'Learn more', style: linkStyle),
              const TextSpan(text: '  |  '),
              TextSpan(text: 'Disclosures', style: linkStyle),
            ],
          ),
        ),
      ],
    );
  }
}
