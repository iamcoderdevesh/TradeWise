import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'package:tradewise/app/theme/tw_radii.dart';
import 'package:tradewise/features/order/presentation/order_enums.dart';

/// Swipe-to-confirm CTA with a draggable thumb, side-styled.
///
/// Dragging the thumb past the completion threshold fires [onCompleted] once
/// and the thumb springs back; releasing early animates it home without
/// firing. A plain tap never completes: taps are absorbed so an accidental
/// touch cannot look like a confirmation. Assistive-technology users get an
/// equivalent semantic tap action that also fires exactly once.
///
/// Nothing is submitted here: the parent shows the temporary notice.
class SwipeToConfirm extends StatefulWidget {
  const SwipeToConfirm({
    super.key,
    required this.side,
    required this.accent,
    required this.onAccent,
    required this.enabled,
    required this.onCompleted,
  });

  final OrderSide side;
  final Color accent;
  final Color onAccent;

  /// Guards empty/zero/invalid drafts; the control dims and ignores input.
  final bool enabled;
  final VoidCallback onCompleted;

  /// Fraction of the track the thumb must cross to complete.
  static const double completionThreshold = 0.99;

  /// Fixed control geometry (measured from the reference; local to this
  /// control, not design-system tokens): a 56dp-tall pill with a 64dp thumb
  /// that slightly overshoots the track top/bottom.
  static const double height = 64;
  static const double thumbSize = 60;
  static const double horizontalInset = 4;

  /// Reference pill width ≈ 64% of the screen, capped for large widths.
  static const double trackWidthFraction = 0.75;
  static const double maxTrackWidth = 272;

  @override
  State<SwipeToConfirm> createState() => _SwipeToConfirmState();
}

class _SwipeToConfirmState extends State<SwipeToConfirm>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spring;
  Timer? _settleTimer;
  double _dragFraction = 0;
  bool _completed = false;

  String get _label =>
      widget.side == OrderSide.buy ? 'SWIPE TO BUY' : 'SWIPE TO SELL';

  @override
  void initState() {
    super.initState();
    _spring = AnimationController.unbounded(vsync: this)
      ..addListener(() {
        setState(() => _dragFraction = _spring.value);
      });
  }

  @override
  void dispose() {
    _settleTimer?.cancel();
    _spring.dispose();
    super.dispose();
  }

  double _maxTravel(double trackWidth) =>
      trackWidth -
      SwipeToConfirm.thumbSize -
      SwipeToConfirm.horizontalInset * 2;

  void _settle(double target) {
    _spring.animateWith(
      SpringSimulation(
        const SpringDescription(mass: 1, stiffness: 320, damping: 26),
        _spring.value,
        target,
        0,
      ),
    );
    // The spring never settles exactly; settle at rest explicitly so test
    // fakes (and real frames) finish cleanly with no pending simulation.
    _settleTimer?.cancel();
    _settleTimer = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) {
        return;
      }
      _spring.stop();
      setState(() {
        _dragFraction = 0;
        _completed = false;
      });
    });
  }

  void _completeOnce() {
    if (_completed) {
      return;
    }
    _completed = true;
    widget.onCompleted();
  }

  /// Accessible equivalent of a full swipe. Fires exactly once and leaves the
  /// thumb at rest; enabled-gating matches the drag path.
  void _onSemanticActivate() {
    if (!widget.enabled) {
      return;
    }
    _completeOnce();
    setState(() {
      _dragFraction = 0;
      _completed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double opacity = widget.enabled ? 1 : 0.5;
    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: _label,
      hint: 'Swipe right to preview, or activate to preview',
      onTap: _onSemanticActivate,
      child: Opacity(
        opacity: opacity,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            // Reference pill ≈ 64% of the screen width, centered.
            final double trackWidth =
                (constraints.maxWidth * SwipeToConfirm.trackWidthFraction)
                    .clamp(0.0, SwipeToConfirm.maxTrackWidth);
            final double travel = _maxTravel(trackWidth).clamp(0, trackWidth);
            final double thumbX =
                SwipeToConfirm.horizontalInset +
                (_dragFraction * travel).clamp(0, travel);
            return Center(
              child: GestureDetector(
                // Absorb taps so they never complete the control.
                onTap: () {},
                onHorizontalDragStart: widget.enabled
                    ? (_) => _spring.stop()
                    : null,
                onHorizontalDragUpdate: widget.enabled
                    ? (DragUpdateDetails details) {
                        setState(() {
                          final double span = travel == 0 ? 1 : travel;
                          _dragFraction =
                              ((_dragFraction * travel + details.delta.dx) /
                                      span)
                                  .clamp(0.0, 1.0);
                          if (_dragFraction >=
                              SwipeToConfirm.completionThreshold) {
                            _completeOnce();
                          }
                        });
                      }
                    : null,
                onHorizontalDragEnd: widget.enabled
                    ? (_) => _settle(_completed ? travel : 0)
                    : null,
                child: SizedBox(
                  width: trackWidth,
                  height: SwipeToConfirm.height,
                  child: Stack(
                    // The 64dp thumb intentionally overshoots the 56dp track.
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: widget.accent,
                            borderRadius: BorderRadius.circular(TWRadii.pill),
                          ),
                        ),
                      ),
                      // Label centered across the whole track, as in the
                      // reference. The outer Semantics carries the label;
                      // excluding the text keeps exactly one labelled node.
                      Center(
                        child: ExcludeSemantics(
                          child: Text(
                            _label,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: widget.onAccent,
                                  letterSpacing: 1.2,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Positioned(
                        left: thumbX,
                        top:
                            (SwipeToConfirm.height - SwipeToConfirm.thumbSize) /
                            2,
                        child: Container(
                          width: SwipeToConfirm.thumbSize,
                          height: SwipeToConfirm.thumbSize,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.chevron_right,
                            color: widget.accent,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
