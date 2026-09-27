import 'package:flutter/material.dart';

import '../../app/theme/tw_spacing.dart';
import 'tw_button.dart';

/// Temporary foundation screen verifying ProviderScope → app → theme →
/// router → rendering. Only `/login` still uses it (`/` renders
/// WelcomeScreen); removed once Login is implemented.
class FoundationPlaceholderScreen extends StatelessWidget {
  const FoundationPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('TradeWise')),
      body: Padding(
        padding: const EdgeInsets.all(TWSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Foundation ready', style: textTheme.titleLarge),
            const SizedBox(height: TWSpacing.s),
            Text(
              'Router, theme, and Riverpod are wired. '
              'Welcome will replace this screen.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: TWSpacing.l),
            TWButton(label: 'Continue', onPressed: () {}),
            const SizedBox(height: TWSpacing.s),
            const TWButton(
              label: 'Secondary',
              variant: TWButtonVariant.secondary,
              onPressed: null,
            ),
          ],
        ),
      ),
    );
  }
}
