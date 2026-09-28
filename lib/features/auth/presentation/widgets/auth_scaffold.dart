import 'package:flutter/material.dart';

import '../../../../app/theme/tw_spacing.dart';
import '../../../../core/widgets/tradewise_brand_mark.dart';

/// Shared chrome for the auth screens (`Login`, `Signup`).
///
/// Mirrors the reference composition shared by both screens: a back affordance
/// at the top-left, the TradeWise brand mark at the top-right, and a
/// width-capped, scrollable body.
///
/// The body is top-anchored, which reproduces the reference keyboard behaviour:
/// content stays in place while the focused field remains visible (Login), and
/// the body scrolls when the viewport becomes too short (the reference shows
/// this on Signup after the keyboard opens). Screens supply their own body
/// children, so screen-specific rhythm stays owned by the screen.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.onBack, required this.children});

  /// Vertical rhythm measured from `references/kite/login` and
  /// `references/kite/signup` (360x792dp frame) and snapped to the 4pt token
  /// scale as sums of existing tokens (ADR-009).
  static const double _topInset = TWSpacing.l; // 32
  static const double _headerToBody = TWSpacing.xxxxl + TWSpacing.s; // 48

  /// Compact header mark. The reference uses a small wordmark in the header,
  /// rather than the Welcome screen's hero mark.
  static const double _brandMarkSize = TWSpacing.xxxl; // 32

  final VoidCallback onBack;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
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
                      children: <Widget>[
                        const SizedBox(height: _topInset),
                        Row(
                          children: <Widget>[
                            IconButton(
                              alignment: Alignment.topLeft,
                              onPressed: onBack,
                              tooltip: 'Back',
                              icon: const Icon(Icons.arrow_back_ios),
                            ),
                            const Spacer(),
                            const TradeWiseBrandMark(size: _brandMarkSize),
                          ],
                        ),
                        const SizedBox(height: _headerToBody),
                        ...children,
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
