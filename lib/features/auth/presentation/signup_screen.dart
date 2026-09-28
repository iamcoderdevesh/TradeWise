import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/tw_spacing.dart';
import '../../../core/widgets/tradewise_disclaimer.dart';
import '../../../core/widgets/tw_button.dart';
import 'widgets/auth_phone_field.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/signup_illustration.dart';
import 'widgets/signup_terms_note.dart';

/// Signup / "Open your account" screen — UI only.
///
/// Mirrors the hierarchy of `references/kite/signup/` with TradeWise branding,
/// an original TradeWise illustration, a `+91` phone field on a numeric keypad,
/// the primary CTA, the terms note, and the shared TradeWise disclaimer.
///
/// No account creation is implemented: the CTA reports the established
/// temporary "not available yet" notice, and no validation is applied.
/// The reference shows this screen scrolling once the keyboard opens, which the
/// shared [AuthScaffold] body already provides.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  /// Vertical rhythm measured from `references/kite/signup/` (360x792dp frame)
  /// and snapped to the 4pt token scale as sums of existing tokens (ADR-009).
  static const double _titleToIllustration = TWSpacing.xxxxl; // 40
  static const double _illustrationToField = TWSpacing.xxl; // 24
  static const double _fieldToCta = TWSpacing.xxxl; // 32
  static const double _ctaToTerms = TWSpacing.xxl; // 24
  static const double _termsToFooter = TWSpacing.xxxxl + TWSpacing.l; // 56

  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _showNotAvailableYet(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$feature is not available yet')));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AuthScaffold(
      onBack: () => context.go(AppRoutes.welcome),
      children: <Widget>[
        Semantics(
          header: true,
          child: Text('Open your account', style: textTheme.displayLarge),
        ),
        const SizedBox(height: _titleToIllustration),
        const Center(child: SignupIllustration()),
        const SizedBox(height: _illustrationToField),
        AuthPhoneField(controller: _phoneController),
        const SizedBox(height: _fieldToCta),
        TWButton(
          label: 'Continue',
          onPressed: () => _showNotAvailableYet('Account creation'),
        ),
        const SizedBox(height: _ctaToTerms),
        const SignupTermsNote(),
        const SizedBox(height: _termsToFooter),
        const TradeWiseDisclaimer(),
      ],
    );
  }
}
