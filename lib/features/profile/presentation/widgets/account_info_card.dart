import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tradewise/app/theme/tw_colors.dart';
import 'package:tradewise/app/theme/tw_radii.dart';
import 'package:tradewise/app/theme/tw_spacing.dart';
import 'package:tradewise/features/profile/presentation/profile_providers.dart';

/// Account information card.
///
/// Mirrors the reference: account ID and email stacked on the left, a large
/// circular avatar on the right, and a Privacy Mode row in a separate lower
/// section. When Privacy Mode is ON, the ID and email are masked visually
/// (local UI behaviour only — no backend security).
class AccountInfoCard extends ConsumerWidget {
  const AccountInfoCard({super.key});

  static const double _avatarSize = 64;

  String _maskUserId(String userId) {
    if (userId.length <= 3) {
      return userId;
    }
    return '${userId.substring(0, 3)}***';
  }

  String _maskEmail(String email) {
    final int at = email.indexOf('@');
    if (at <= 1) {
      return '***@example.com';
    }
    return '${email[0]}****${email.substring(at - 1)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final bool privacyOn = ref.watch(privacyModeProvider);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark
        ? TWColors.darkSurface
        : TWColors.lightSurface;
    final Color idColor = isDark
        ? TWColors.darkTextPrimary
        : TWColors.lightTextPrimary;
    final Color emailColor = isDark
        ? TWColors.darkTextTertiary
        : TWColors.lightTextTertiary;
    final Color avatarBg = isDark
        ? const Color(0xFF3B82F6).withValues(alpha: 0.25)
        : const Color(0xFF2563EB).withValues(alpha: 0.15);
    final Color avatarText = isDark
        ? const Color(0xFF60A5FA)
        : const Color(0xFF2563EB);

    final String displayId = privacyOn
        ? _maskUserId(profile.userId)
        : profile.userId;
    final String displayEmail = privacyOn
        ? _maskEmail(profile.email)
        : profile.email;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TWSpacing.l),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(
          TWSpacing.l,
          TWSpacing.xl,
          TWSpacing.l,
          TWSpacing.xl,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(TWRadii.medium),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        displayId,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: idColor,
                              fontWeight: FontWeight.w500,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: TWSpacing.xs),
                      Text(
                        displayEmail,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: emailColor),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: TWSpacing.l),
                Container(
                  width: _avatarSize,
                  height: _avatarSize,
                  decoration: BoxDecoration(
                    color: avatarBg,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    profile.avatarInitials,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: avatarText,
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: TWSpacing.xxl),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  child: Text(
                    'Privacy mode',
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: idColor),
                  ),
                ),
                const SizedBox(width: TWSpacing.xxl),
                _customSwitchButton(ref, privacyOn),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _customSwitchButton(WidgetRef ref, bool privacyOn) {
    return Flexible(
      child: GestureDetector(
        onTap: () => ref.read(privacyModeProvider.notifier).toggle(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: 36,
          height: 20,
          padding: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            color: privacyOn
                ? const Color(0xFF3478C7)
                : const Color(0xFF465562),
            borderRadius: BorderRadius.circular(20),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: privacyOn ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 19,
              height: 19,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget _customPrivacySwitch(BuildContext context, List<Order> activeOrders) {
  //   return GestureDetector(
  //     onTap: toggleSwitch,
  //     child: AnimatedContainer(
  //       duration: const Duration(milliseconds: 200),
  //       curve: Curves.easeInOut,
  //       width: 40,
  //       height: 22,
  //       padding: const EdgeInsets.all(1.5),
  //       decoration: BoxDecoration(
  //         color: isEnabled ? const Color(0xFF3478C7) : const Color(0xFF465562),
  //         borderRadius: BorderRadius.circular(20),
  //       ),
  //       child: AnimatedAlign(
  //         duration: const Duration(milliseconds: 200),
  //         curve: Curves.easeInOut,
  //         alignment: isEnabled ? Alignment.centerRight : Alignment.centerLeft,
  //         child: Container(
  //           width: 19,
  //           height: 19,
  //           decoration: const BoxDecoration(
  //             color: Colors.white,
  //             shape: BoxShape.circle,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
