import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/tw_spacing.dart';
import '../../../core/widgets/tradewise_disclaimer.dart';
import '../../../core/widgets/tw_button.dart';
import '../../../core/widgets/tw_input_field.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/signup_terms_note.dart';

/// Signup / "Open your account" screen — UI only.
///
/// Mirrors the hierarchy of `references/kite/signup/` with TradeWise branding,
/// name, email, password, and confirm-password fields, the primary CTA, a login
/// navigation link, the terms note, and the shared TradeWise disclaimer.
///
/// No account creation is implemented: the CTA reports the established
/// temporary "not available yet" notice, and no validation is applied.
/// The shared [AuthScaffold] body scrolls when the keyboard reduces usable
/// height, matching the reference behaviour.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  /// Vertical rhythm measured from `references/kite/signup/` (360x792dp frame)
  /// and snapped to the 4pt token scale as sums of existing tokens (ADR-009).
  static const double _titleToFirstField = TWSpacing.xxxl + TWSpacing.s; // 48
  static const double _fieldGap = TWSpacing.xxl; // 24
  static const double _fieldsToCta = TWSpacing.xxxl; // 32
  static const double _ctaToLoginLink = TWSpacing.xl; // 24
  static const double _loginLinkToTerms = TWSpacing.xxl; // 24
  static const double _termsToFooter = TWSpacing.xxxxl + TWSpacing.l; // 56

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
  }

  void _showNotAvailableYet(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$feature is not available yet')));
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
    required String tooltip,
    required IconData icon,
  }) {
    return TwInputField(
      controller: controller,
      label: label,
      obscureText: obscureText,
      textInputAction: TextInputAction.next,
      suffixIcon: IconButton(
        onPressed: onToggle,
        tooltip: tooltip,
        icon: Icon(icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AuthScaffold(
      onBack: () => context.go(AppRoutes.welcome),
      children: <Widget>[
        Semantics(
          header: true,
          child: Text('Open your account', style: textTheme.headlineMedium),
        ),
        const SizedBox(height: _titleToFirstField),
        TwInputField(
          controller: _nameController,
          label: 'Name',
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: _fieldGap),
        TwInputField(
          controller: _emailController,
          label: 'Email',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: _fieldGap),
        _buildPasswordField(
          controller: _passwordController,
          label: 'Password',
          obscureText: _obscurePassword,
          onToggle: _togglePasswordVisibility,
          tooltip: _obscurePassword ? 'Show password' : 'Hide password',
          icon: _obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
        ),
        const SizedBox(height: _fieldGap),
        _buildPasswordField(
          controller: _confirmPasswordController,
          label: 'Confirm Password',
          obscureText: _obscureConfirmPassword,
          onToggle: _toggleConfirmPasswordVisibility,
          tooltip: _obscureConfirmPassword ? 'Show password' : 'Hide password',
          icon: _obscureConfirmPassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
        ),
        const SizedBox(height: _fieldsToCta),
        TWButton(
          label: 'Continue',
          onPressed: () => _showNotAvailableYet('Account creation'),
        ),
        const SizedBox(height: _ctaToLoginLink),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => context.go(AppRoutes.login),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('Already have an account? Log in'),
          ),
        ),
        const SizedBox(height: _loginLinkToTerms),
        const SignupTermsNote(),
        const SizedBox(height: _termsToFooter),
        const TradeWiseDisclaimer(),
      ],
    );
  }
}
