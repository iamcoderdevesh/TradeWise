import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/widgets/tradewise_brand_mark.dart';

/// TradeWise launch (splash) screen.
///
/// Renders the shared [TradeWiseBrandMark] as a single centered focal point on
/// the themed scaffold background and, after a fixed [dwell] of 1500 ms,
/// navigates to [AppRoutes.welcome].
///
/// Reference analysis (`references/kite/splash`, `references/tradingview`,
/// `references/upstox`): every reference is a full-bleed solid background with a
/// single centered brand element, large negative space and no other content.
/// Three of the four show no loading indicator; only the Kite reference has a
/// progress bar, and that bar implies real load progress which this UI-first
/// phase does not have. TradeWise therefore follows the majority: a
/// deterministic branded dwell with no fake progress indicator. The background
/// is the theme scaffold colour (near-white light / navy-charcoal dark) rather
/// than another product's brand colour, so the launch reads as the same product
/// as Welcome, Login and Signup.
///
/// This is intentionally a UI + timed-navigation feature only. There is no
/// repository, ViewModel, provider, service, domain or data layer, and no
/// network, session, database or backend work: the delay is a deliberate,
/// deterministic branded dwell. The timer is owned by this widget and cancelled
/// in [dispose], and navigation is guarded by [State.mounted], so unmounting the
/// screen cannot produce timer errors, setState-after-dispose, or
/// navigation-after-dispose.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// Deterministic branded dwell before navigating to Welcome.
  ///
  /// Deliberately manual for the UI-first phase; it will be replaced by real
  /// startup work (e.g. session restore) once authentication exists.
  static const Duration dwell = Duration(milliseconds: 1500);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  /// Hero brand-mark scale. Intentionally larger than the 56dp Welcome/auth
  /// header mark so the launch reads as a single centered focal point, while
  /// staying restrained relative to the references' much larger brand marks.
  /// Screen-specific dimension, so it stays a documented literal rather than a
  /// global token (matching the Welcome screen's local-dimension convention).
  static const double _brandMarkSize = 96;

  /// Duration of the single, subtle brand reveal (fade + slight scale).
  ///
  /// Deliberately longer than a typical micro-transition: the reveal starts
  /// only after the first frame is on screen, and Flutter Web's first frames
  /// after startup can be slow enough to consume a shorter animation in a
  /// single step, which reads as "no animation at all".
  static const Duration _revealDuration = Duration(milliseconds: 600);

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  Timer? _dwellTimer;
  bool _revealStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _revealDuration);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _scale = Tween<double>(
      begin: 0.9,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _dwellTimer = Timer(SplashScreen.dwell, _goToWelcome);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_revealStarted) {
      return;
    }
    _revealStarted = true;

    // Respect reduced motion: show the finished brand treatment immediately
    // instead of animating. The dwell (and therefore the navigation timing) is
    // unaffected, so the 1500 ms behaviour stays deterministic either way.
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _controller.value = 1;
      return;
    }

    // Start the reveal only once the first frame is on screen. Beginning it
    // during the first build lets a slow startup frame swallow the whole
    // animation in one step, which is why the reveal could be imperceptible.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  void _goToWelcome() {
    if (!mounted) {
      return;
    }
    context.go(AppRoutes.welcome);
  }

  @override
  void dispose() {
    _dwellTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // No AppBar: the launch is a single brand element on the themed scaffold
    // background (which also avoids a colour flash, since Scaffold inherits the
    // theme's scaffoldBackgroundColor immediately).
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: const TradeWiseBrandMark(size: _brandMarkSize),
          ),
        ),
      ),
    );
  }
}
