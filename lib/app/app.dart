import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import 'theme/theme_mode_provider.dart';
import 'theme/tw_theme.dart';

/// Root TradeWise application widget.
class TradeWiseApp extends ConsumerWidget {
  const TradeWiseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'TradeWise',
      theme: TWTheme.light(),
      darkTheme: TWTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
