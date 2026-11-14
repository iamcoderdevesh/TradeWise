import 'package:flutter/material.dart';

import 'package:tradewise/app/theme/tw_colors.dart';
import 'package:tradewise/app/theme/tw_spacing.dart';

/// One tappable account menu row.
///
/// Mirrors the reference: label left-aligned, trailing icon right-aligned,
/// ~48dp minimum height, 16dp horizontal padding, 12dp vertical padding.
/// No divider is included here; the screen places a Divider between rows.
class ProfileMenuRow extends StatelessWidget {
  const ProfileMenuRow({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TWSpacing.l,
            vertical: TWSpacing.m,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 36),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    label,
                    style: textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? TWColors.darkTextPrimary
                          : TWColors.lightTextPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: TWSpacing.s),
                Icon(
                  icon,
                  size: 22,
                  color: isDark
                      ? TWColors.darkTextTertiary
                      : TWColors.lightTextTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
