import 'package:flutter/material.dart';

import '../../app/theme/tw_typography.dart';

/// Deliberately temporary TradeWise brand mark placeholder.
///
/// A neutral "TW" monogram so brand-bearing screens read as TradeWise.
/// NOT the final logo — replace during visual-identity work.
///
/// Shared by Welcome (hero size) and the auth screens (compact header size);
/// extracted from the Welcome feature so Auth does not depend on it.
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
