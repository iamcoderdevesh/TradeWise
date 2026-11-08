import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tradewise/app/theme/tw_colors.dart';

import 'package:tradewise/app/theme/tw_spacing.dart';
import 'package:tradewise/features/orders/domain/order.dart';
import 'package:tradewise/features/orders/presentation/order_providers.dart';
import 'package:tradewise/features/orders/presentation/widgets/order_tile.dart';
import 'package:tradewise/features/orders/presentation/widgets/orders_empty_state.dart';
import 'package:tradewise/features/orders/presentation/widgets/orders_tab_selector.dart';
import 'package:tradewise/features/orders/presentation/widgets/orders_toolbar.dart';

/// Orders screen.
///
/// Mirrors the Watchlist page structure (Scaffold → SafeArea → Column →
/// [header, tab selector, divider, Expanded(list/empty)]) while displaying
/// order-specific information: side pill, symbol, exchange • product,
/// quantity, price, time, status.
///
/// Reads [orderHistoryProvider] and splits entries between the Open and
/// Executed tabs. With no pending-order functionality yet, the Open tab
/// genuinely shows its empty state.
class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  static const List<String> _tabs = <String>['Open', 'Executed'];

  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final List<Order> orders = ref.watch(orderHistoryProvider);
    final List<Order> openOrders = orders
        .where((Order order) => order.status == OrderStatus.open)
        .toList();
    final List<Order> executedOrders = orders
        .where((Order order) => order.status == OrderStatus.executed)
        .toList();

    final List<Order> activeOrders = _selectedTab == 0
        ? openOrders
        : executedOrders;
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color pageColor = isDark
        ? TWColors.darkBackgroundPrimary
        : TWColors.lightBackgroundSecondary;

    return Scaffold(
      backgroundColor: pageColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                TWSpacing.l,
                TWSpacing.m,
                TWSpacing.l,
                TWSpacing.s,
              ),
              child: Semantics(
                header: true,
                child: Text(
                  'Orders',
                  style: theme.textTheme.titleLarge,
                  maxLines: 1,
                ),
              ),
            ),
            OrdersTabSelector(
              tabs: _tabs,
              selectedIndex: _selectedTab,
              onTabSelected: (int index) =>
                  setState(() => _selectedTab = index),
            ),
            OrdersToolbar(
              onNotice: (String message) => _showNotice(context, message),
            ),
            const Divider(height: 1),
            Expanded(child: _buildBody(context, activeOrders)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<Order> activeOrders) {
    if (activeOrders.isEmpty) {
      return const OrdersEmptyState();
    }
    return ListView.separated(
      itemCount: activeOrders.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (BuildContext context, int index) {
        final Order order = activeOrders[index];
        return OrderTile(order: order);
      },
    );
  }

  void _showNotice(BuildContext context, String message) {
    // Replace the visible notice instead of queueing behind it — matches
    // the order ticket's pattern so rapid actions report immediately.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
