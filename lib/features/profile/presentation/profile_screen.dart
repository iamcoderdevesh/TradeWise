import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tradewise/app/theme/tw_colors.dart';
import 'package:tradewise/app/theme/tw_spacing.dart';
import 'package:tradewise/features/profile/presentation/profile_providers.dart';
import 'package:tradewise/features/profile/presentation/widgets/account_info_card.dart';
import 'package:tradewise/features/profile/presentation/widgets/profile_market_strip.dart';
import 'package:tradewise/features/profile/presentation/widgets/profile_menu_row.dart';
import 'package:tradewise/features/profile/presentation/widgets/profile_user_header.dart';

/// Profile screen.
///
/// Faithfully reproduces the supplied Kite Profile screen composition using
/// TradeWise branding and the existing TradeWise design system:
/// market indices strip, user header, account information card with Privacy
/// Mode, and the account menu (Funds, App Code, Profile, Settings, Connected
/// apps, Logout).
///
/// Privacy Mode is local UI behaviour only: toggling masks or restores the
/// account ID and email. It does not represent backend security or
/// authentication.
///
/// Menu items that have no corresponding destination yet show a specific
/// temporary notice (matching the established Watchlist/Orders/Portfolio
/// pattern); no fake navigation or backend integration is introduced.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  static const List<_MenuItem> _menuItems = <_MenuItem>[
    _MenuItem(label: 'Funds', icon: Icons.currency_rupee),
    _MenuItem(label: 'App Code', icon: Icons.lock_outline),
    _MenuItem(label: 'Profile', icon: Icons.person_outline),
    _MenuItem(label: 'Settings', icon: Icons.settings),
    _MenuItem(label: 'Connected apps', icon: Icons.corporate_fare),
    _MenuItem(label: 'Logout', icon: Icons.logout),
  ];

  void _showNotice(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? TWColors.darkBackgroundPrimary
          : TWColors.lightBackgroundSecondary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ProfileMarketStrip(
                onExpandTap: () =>
                    _showNotice('Index details are not available yet'),
              ),
              ProfileUserHeader(
                userName: ref.read(profileProvider).name,
                onBellTap: () =>
                    _showNotice('Notifications are not available yet'),
              ),
              const SizedBox(height: TWSpacing.l),
              const AccountInfoCard(),
              const SizedBox(height: TWSpacing.xxl),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: TWSpacing.l),
                child: Semantics(
                  header: true,
                  child: Text(
                    'Account',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? TWColors.darkTextTertiary
                          : TWColors.lightTextTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: TWSpacing.xl),
              const Divider(height: 1),
              for (int i = 0; i < _menuItems.length; i += 1) ...<Widget>[
                ProfileMenuRow(
                  label: _menuItems[i].label,
                  icon: _menuItems[i].icon,
                  onTap: () => _onMenuTap(_menuItems[i].label),
                ),
                if (i < _menuItems.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _onMenuTap(String label) {
    switch (label) {
      case 'Funds':
        _showNotice('Funds are not available yet');
        break;
      case 'App Code':
        _showNotice('App Code are not available yet');
        break;
      case 'Profile':
        _showNotice('Profile details are not available yet');
        break;
      case 'Settings':
        _showNotice('Settings are not available yet');
        break;
      case 'Connected apps':
        _showNotice('Connected apps are not available yet');
        break;
      case 'Logout':
        _showNotice('Logout are not available yet');
        break;
    }
  }
}

/// One menu item's static description.
class _MenuItem {
  const _MenuItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
