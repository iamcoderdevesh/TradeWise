import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/tw_radii.dart';
import '../../../../app/theme/tw_spacing.dart';
import '../../../../core/widgets/tradewise_brand_mark.dart';
import '../../../../core/widgets/tradewise_disclaimer.dart';
import 'widgets/welcome_action_row.dart';

/// First real TradeWise feature screen.
///
/// Mirrors the layout/hierarchy of `references/kite/welcome/` with
/// TradeWise placeholder branding and copy. "Log in" navigates to
/// [AppRoutes.login] and "Open a free account" to [AppRoutes.signup]; "Try
/// demo" is a temporary UI-only development entry point into the shell
/// ([AppRoutes.watchlist]) until real authentication exists.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // Vertical rhythm measured from `references/kite/welcome/` (360x792dp):
  //   safe-top -> button 32 | button->mark 72 | mark->heading 32 |
  //   heading->first divider 64 | divider pitch 72 | divider->footer 84 |
  //   footer->safe-bottom 24 (footer sits ~49dp above the safe-area edge).
  // Expressed as sums of existing spacing tokens so no new magic numbers
  // are introduced.
  static const double _topInset = TWSpacing.xxxl;
  static const double _topToBrandMark = TWSpacing.xxxxl + TWSpacing.xxxl;
  static const double _brandMarkToHeading = TWSpacing.xxxl;
  static const double _headingToActions = TWSpacing.xxxxl + TWSpacing.xxl;
  static const double _actionsToFooter =
      TWSpacing.xxxxl + TWSpacing.xxxl + TWSpacing.m;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TWSpacing.xxl,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: _topInset),
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton(
                            onPressed: () => context.go(AppRoutes.watchlist),
                            // Compact outline CTA sized for the reference's
                            // header placement. The 42dp height, 18dp
                            // horizontal padding and 1.2dp hairline stroke are
                            // specific to this control, so they stay literals
                            // instead of becoming global tokens.
                            // TEMPORARY (Phase 3): direct entry into the shell
                            // for UI development/testing until real
                            // authentication exists. Not a demo/auth flow.
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 42),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: TWSpacing.xs,
                              ),
                              foregroundColor: colorScheme.primary,
                              side: BorderSide(
                                color: colorScheme.primary,
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  TWRadii.small,
                                ),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Try demo'),
                                SizedBox(width: TWSpacing.s),
                                Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: _topToBrandMark),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: TradeWiseBrandMark(),
                        ),
                        const SizedBox(height: _brandMarkToHeading),
                        Semantics(
                          header: true,
                          child: Text(
                            'Welcome to\nTradeWise',
                            style: textTheme.displayLarge,
                          ),
                        ),
                        const SizedBox(height: _headingToActions),
                        const Divider(height: 1),
                        WelcomeActionRow(
                          label: 'Open a free account',
                          icon: Icons.person_outline,
                          semanticsLabel: 'Open a free account',
                          onTap: () => context.go(AppRoutes.signup),
                        ),
                        const Divider(height: 1),
                        WelcomeActionRow(
                          label: 'Log in',
                          icon: Icons.login,
                          semanticsLabel: 'Log in',
                          onTap: () => context.go(AppRoutes.login),
                        ),
                        const Divider(height: 1),
                        // Fixed spacer: keeps the reference's airy gap while the
                        // surrounding scroll view protects shorter viewports.
                        const SizedBox(height: _actionsToFooter),
                        const TradeWiseDisclaimer(),
                        const SizedBox(height: TWSpacing.xxl),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
