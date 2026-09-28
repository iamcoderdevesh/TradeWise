import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Signup terms line: copy plus an inline "terms and conditions" action.
///
/// The action has no real destination in this UI-only phase, so it reports the
/// established TradeWise temporary "not available yet" notice rather than
/// pretending to open legal content.
class SignupTermsNote extends StatefulWidget {
  const SignupTermsNote({super.key});

  static const String copy = 'By continuing, you agree to the ';
  static const String linkLabel = 'terms and conditions';

  /// Temporary notice shown because no legal content exists yet.
  static const String unavailableNotice =
      'Terms and conditions are not available yet';

  @override
  State<SignupTermsNote> createState() => _SignupTermsNoteState();
}

class _SignupTermsNoteState extends State<SignupTermsNote> {
  late final TapGestureRecognizer _termsRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()..onTap = _showUnavailable;
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    super.dispose();
  }

  void _showUnavailable() {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text(SignupTermsNote.unavailableNotice)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    // The reference shows a body-size note in the secondary text colour;
    // bodyMedium carries the primary colour, so the secondary role's colour is
    // applied explicitly instead of introducing a new token.
    final noteStyle = textTheme.bodyMedium?.copyWith(
      color: textTheme.bodySmall?.color,
    );

    return Text.rich(
      TextSpan(
        style: noteStyle,
        children: <InlineSpan>[
          const TextSpan(text: SignupTermsNote.copy),
          TextSpan(
            text: SignupTermsNote.linkLabel,
            style: noteStyle?.copyWith(color: colorScheme.primary),
            recognizer: _termsRecognizer,
          ),
        ],
      ),
    );
  }
}
