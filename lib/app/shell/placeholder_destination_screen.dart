import 'package:flutter/material.dart';

import '../theme/tw_spacing.dart';

/// Temporary body for the shell destinations that do not have a real screen
/// yet (`/home`, `/orders`, `/portfolio`, `/profile`).
///
/// Deliberately minimal and obviously temporary: a title, a plain "temporary
/// placeholder" line and a one-line note about when the screen arrives. It
/// contains no trading functionality of any kind, uses TradeWise theme tokens
/// only, and is meant to be replaced wholesale by the real feature screen
/// without touching the shell or the router.
class PlaceholderDestinationScreen extends StatelessWidget {
  const PlaceholderDestinationScreen({
    super.key,
    required this.title,
    this.message = 'This screen will be implemented in a later phase.',
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(TWSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: TWSpacing.s),
                Text(
                  'Temporary placeholder',
                  style: textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: TWSpacing.l),
                Text(
                  message,
                  style: textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
