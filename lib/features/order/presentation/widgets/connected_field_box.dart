import 'package:flutter/material.dart';

import 'package:tradewise/app/theme/tw_radii.dart';

/// One outlined input box split into an input area and a trailing action
/// segment — the reference's connected field-and-swap construction (a single
/// border with one internal divider, not two separate boxes).
class ConnectedFieldBox extends StatelessWidget {
  const ConnectedFieldBox({
    super.key,
    required this.input,
    required this.segmentIcon,
    required this.segmentColor,
    required this.segmentTooltip,
    required this.onSegmentTap,
  });

  final Widget input;
  final IconData segmentIcon;
  final Color segmentColor;
  final String segmentTooltip;
  final VoidCallback onSegmentTap;

  /// Field height measured from the reference (~50dp content); local to this
  /// construction, not a design-system dimension.
  static const double height = 52;

  /// Trailing segment width (reference ≈57dp; keeps the ≥48dp touch target).
  static const double segmentWidth = 56;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).focusColor),
        borderRadius: BorderRadius.circular(TWRadii.medium),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(child: input),
          Container(width: 1, color: Theme.of(context).focusColor),
          SizedBox(
            width: segmentWidth,
            child: IconButton(
              tooltip: segmentTooltip,
              onPressed: onSegmentTap,
              icon: Icon(segmentIcon, color: segmentColor),
            ),
          ),
        ],
      ),
    );
  }
}
