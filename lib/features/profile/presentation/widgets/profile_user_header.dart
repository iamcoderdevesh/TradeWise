import 'package:flutter/material.dart';

import 'package:tradewise/app/theme/tw_colors.dart';
import 'package:tradewise/app/theme/tw_spacing.dart';

/// User header row: the user's name with a notification action.
///
/// Mirrors the reference: name left-aligned in a large primary-colour style,
/// bell icon right-aligned and vertically centred with the name.
class ProfileUserHeader extends StatelessWidget {
  const ProfileUserHeader({super.key, required this.userName, this.onBellTap});

  final String userName;
  final VoidCallback? onBellTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TWSpacing.l),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              userName,
              style: textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: TWSpacing.s),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 24),
            color: isDark
                ? TWColors.darkTextTertiary
                : TWColors.lightTextTertiary,
            onPressed: onBellTap,
            tooltip: 'Notifications',
          ),
        ],
      ),
    );
  }
}
