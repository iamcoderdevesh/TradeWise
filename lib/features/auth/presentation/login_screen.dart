import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/tw_spacing.dart';
import '../../../core/widgets/tradewise_disclaimer.dart';
import '../../../core/widgets/tw_button.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/auth_text_field.dart';

/// Login screen — UI only.
///
/// Mirrors the hierarchy of `references/kite/login/` with TradeWise branding and
/// tokens: back affordance + brand mark, the "Login" heading, a user-ID field, a
/// password field with a local visibility toggle, the primary CTA, a secondary
/// recovery link, and the shared TradeWise disclaimer.
///
/// No authentication is implemented. The CTA and the recovery link report the
/// established temporary "not available yet" notice instead of faking a session,
/// and no validation/error states are invented (the reference contains none).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Vertical rhythm measured from `references/kite/login/` (360x792dp frame)
  /// and snapped to the 4pt token scale as sums of existing tokens (ADR-009).
  static const double _titleToFirstField = TWSpacing.xxxxl + TWSpacing.s; // 48
  static const double _fieldGap = TWSpacing.xxl; // 24
  static const double _fieldsToCta = TWSpacing.xxxl; // 32
  static const double _ctaToRecoveryLink = TWSpacing.xxxl; // 32
  static const double _recoveryLinkToFooter =
      TWSpacing.xxxxl + TWSpacing.xxxxl + TWSpacing.xxxl; // 112

  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
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
    final colorScheme = Theme.of(context).colorScheme;

    return AuthScaffold(
      onBack: () => context.go(AppRoutes.welcome),
      children: <Widget>[
        Semantics(
          header: true,
          child: Text('Login', style: textTheme.displayLarge),
        ),
        const SizedBox(height: _titleToFirstField),
        AuthTextField(
          controller: _userIdController,
          label: 'Phone or User ID',
          textInputAction: TextInputAction.next,
          // Decorative reference glyph: hidden from assistive technology so the
          // field is announced by its label only.
          suffixIcon: const ExcludeSemantics(child: Icon(Icons.person_outline)),
        ),
        const SizedBox(height: _fieldGap),
        AuthTextField(
          controller: _passwordController,
          label: 'Password',
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          suffixIcon: IconButton(
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            tooltip: _obscurePassword ? 'Show password' : 'Hide password',
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
        ),
        const SizedBox(height: _fieldsToCta),
        TWButton(
          label: 'Log in',
          onPressed: () => _showNotAvailableYet('Login'),
        ),
        const SizedBox(height: _ctaToRecoveryLink),
        // The reference right-aligns this link with the form edge. The default
        // (padded) button style is kept so the target stays accessible; the
        // resulting few dp of inset are accepted per ADR-009.
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => _showNotAvailableYet('Password recovery'),
            style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
            child: const Text('Forgot user ID or password?'),
          ),
        ),
        const SizedBox(height: _recoveryLinkToFooter),
        const TradeWiseDisclaimer(),
      ],
    );
  }
}
