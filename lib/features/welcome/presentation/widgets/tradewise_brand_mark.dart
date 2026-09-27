import 'package:flutter/material.dart';

import '../../../../app/theme/tw_typography.dart';

/// Deliberately temporary TradeWise brand mark placeholder.
///
/// A neutral "TW" monogram so the Welcome screen reads as TradeWise.
/// NOT the final logo — replace during visual-identity work.
class TradeWiseBrandMark extends StatelessWidget {
  const TradeWiseBrandMark({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'TradeWise',
      image: true,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(size / 4),
        ),
        alignment: Alignment.center,
        child: Text(
          'TW',
          style: TextStyle(
            fontFamily: TWTypography.fontFamily,
            fontSize: size * 0.36,
            fontWeight: FontWeight.w700,
            color: colorScheme.onPrimary,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
