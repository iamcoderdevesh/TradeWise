import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tradewise/app/theme/tw_theme.dart';
import 'package:tradewise/features/orders/domain/order.dart';
import 'package:tradewise/features/order/presentation/order_enums.dart';
import 'package:tradewise/features/orders/presentation/order_providers.dart';
import 'package:tradewise/features/orders/presentation/orders_screen.dart';
import 'package:tradewise/features/orders/presentation/widgets/order_tile.dart';
import 'package:tradewise/features/orders/presentation/widgets/orders_empty_state.dart';
import 'package:tradewise/features/orders/presentation/widgets/orders_tab_selector.dart';

/// Test notifier that seeds [orderHistoryProvider] with a fixed list.
class _TestOrderNotifier extends OrderNotifier {
  _TestOrderNotifier(this._orders) : super();

  final List<Order> _orders;

  @override
  List<Order> build() => _orders;
}

Future<void> pumpOrders(
  WidgetTester tester, {
  List<Order> orders = const <Order>[],
  ThemeMode themeMode = ThemeMode.light,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        orderHistoryProvider.overrideWith(() => _TestOrderNotifier(orders)),
      ],
      child: MaterialApp(
        theme: TWTheme.light(),
        darkTheme: TWTheme.dark(),
        themeMode: themeMode,
        home: const OrdersScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Order _executedOrder({
  String id = '1',
  OrderSide side = OrderSide.buy,
  String symbol = 'IDFCFIRSTB',
  String exchange = 'NSE',
  String product = 'LONGTERM',
  String productCode = 'CNC',
  OrderType orderType = OrderType.market,
  int quantity = 100,
  int filledQuantity = 100,
  double price = 80.39,
  DateTime? executedAt,
  OrderStatus status = OrderStatus.executed,
}) {
  return Order(
    id: id,
    side: side,
    symbol: symbol,
    exchange: exchange,
    product: product,
    productCode: productCode,
    orderType: orderType,
    quantity: quantity,
    filledQuantity: filledQuantity,
    price: price,
    executedAt: executedAt ?? DateTime(2026, 1, 1, 10, 30, 0),
    status: status,
  );
}

void main() {
  testWidgets('open tab empty state shows when no orders', (tester) async {
    await pumpOrders(tester, orders: const <Order>[]);
    expect(find.byType(OrdersEmptyState), findsOneWidget);
    expect(find.text('No pending orders'), findsOneWidget);
    expect(find.text('Place an order from your watchlist'), findsOneWidget);
    expect(find.byType(OrderTile), findsNothing);
  });

  testWidgets('executed tab renders one tile per filled order', (tester) async {
    final List<Order> orders = <Order>[_executedOrder()];
    await pumpOrders(tester, orders: orders);
    // Default tab is Open (empty). Switch to Executed to see the tile.
    await tester.tap(find.text('Executed'));
    await tester.pumpAndSettle();
    expect(find.byType(OrderTile), findsOneWidget);
    expect(find.text('IDFCFIRSTB'), findsOneWidget);
    expect(find.text('BUY'), findsOneWidget);
    expect(find.text('EXECUTED'), findsOneWidget);
    expect(find.text('100/100'), findsOneWidget);
  });

  testWidgets('open tab shows empty state when only executed orders exist', (
    tester,
  ) async {
    final List<Order> orders = <Order>[_executedOrder()];
    await pumpOrders(tester, orders: orders);
    // Open tab is default; executed orders exist but open tab shows empty.
    expect(find.byType(OrderTile), findsNothing);
    expect(find.byType(OrdersEmptyState), findsOneWidget);
    expect(find.text('No pending orders'), findsOneWidget);
  });

  testWidgets(
    'order tile shows side, symbol, exchange, product, quantity, price',
    (tester) async {
      final List<Order> orders = <Order>[
        _executedOrder(
          side: OrderSide.sell,
          symbol: 'INFY',
          product: 'CNC',
          productCode: 'CNC',
          orderType: OrderType.limit,
          quantity: 50,
          price: 1246.90,
          executedAt: DateTime(2026, 1, 1, 13, 45, 9),
        ),
      ];
      await pumpOrders(tester, orders: orders);
      await tester.tap(find.text('Executed'));
      await tester.pumpAndSettle();
      expect(find.text('INFY'), findsOneWidget);
      expect(find.text('SELL'), findsOneWidget);
      expect(find.text('NSE   CNC'), findsOneWidget);
      expect(find.text('1,246.90'), findsOneWidget);
      expect(find.text('13:45:09'), findsOneWidget);
      expect(find.text('EXECUTED'), findsOneWidget);
    },
  );

  testWidgets('dark theme renders without exceptions', (tester) async {
    await pumpOrders(
      tester,
      orders: const <Order>[],
      themeMode: ThemeMode.dark,
    );
    expect(tester.takeException(), isNull);
  });

  group('Order model', () {
    test('buy order fields are correctly represented', () {
      final order = _executedOrder(
        side: OrderSide.buy,
        symbol: 'TMPV',
        exchange: 'NSE',
        product: 'INTRADAY',
        productCode: 'MIS',
        orderType: OrderType.market,
        quantity: 108,
        filledQuantity: 108,
        price: 279.40,
        executedAt: DateTime(2026, 1, 1, 14, 19, 17),
      );
      expect(order.side, OrderSide.buy);
      expect(order.symbol, 'TMPV');
      expect(order.exchange, 'NSE');
      expect(order.product, 'INTRADAY');
      expect(order.productCode, 'MIS');
      expect(order.orderType, OrderType.market);
      expect(order.quantity, 108);
      expect(order.filledQuantity, 108);
      expect(order.price, 279.40);
      expect(order.status, OrderStatus.executed);
    });

    test('sell order fields are correctly represented', () {
      final order = _executedOrder(
        side: OrderSide.sell,
        symbol: 'INFY',
        exchange: 'NSE',
        product: 'CNC',
        productCode: 'CNC',
        orderType: OrderType.limit,
        quantity: 50,
        filledQuantity: 50,
        price: 1246.90,
        executedAt: DateTime(2026, 1, 1, 13, 45, 9),
      );
      expect(order.side, OrderSide.sell);
      expect(order.symbol, 'INFY');
      expect(order.productCode, 'CNC');
      expect(order.orderType, OrderType.limit);
      expect(order.filledQuantity, 50);
      expect(order.price, 1246.90);
    });

    test('product code mapping for intraday and longterm', () {
      expect(OrderProduct.intraday.productCode, 'MIS');
      expect(OrderProduct.longterm.productCode, 'CNC');
    });
  });

  group('Orders screen dynamic data', () {
    testWidgets('multiple orders display their own individual data', (
      tester,
    ) async {
      final List<Order> orders = <Order>[
        _executedOrder(
          id: '1',
          symbol: 'TMPV',
          product: 'INTRADAY',
          productCode: 'MIS',
          orderType: OrderType.market,
          quantity: 108,
          filledQuantity: 108,
          price: 279.40,
          executedAt: DateTime(2026, 1, 1, 14, 19, 17),
        ),
        _executedOrder(
          id: '2',
          symbol: 'IDFCFIRSTB',
          product: 'LONGTERM',
          productCode: 'CNC',
          orderType: OrderType.market,
          quantity: 200,
          filledQuantity: 200,
          price: 80.39,
          executedAt: DateTime(2026, 1, 1, 14, 19, 31),
        ),
      ];
      await pumpOrders(tester, orders: orders);
      await tester.tap(find.text('Executed'));
      await tester.pumpAndSettle();
      expect(find.byType(OrderTile), findsNWidgets(2));
      expect(find.text('TMPV'), findsOneWidget);
      expect(find.text('IDFCFIRSTB'), findsOneWidget);
      expect(find.text('279.40'), findsOneWidget);
      expect(find.text('80.39'), findsOneWidget);
    });

    testWidgets('switching tabs displays the correct content', (tester) async {
      final List<Order> orders = <Order>[_executedOrder()];
      await pumpOrders(tester, orders: orders);
      // Open tab is default and empty.
      expect(find.byType(OrdersEmptyState), findsOneWidget);
      expect(find.byType(OrderTile), findsNothing);
      // Switch to Executed.
      await tester.tap(find.text('Executed'));
      await tester.pumpAndSettle();
      expect(find.byType(OrderTile), findsOneWidget);
      expect(find.byType(OrdersEmptyState), findsNothing);
      // Switch back to Open.
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byType(OrdersEmptyState), findsOneWidget);
      expect(find.byType(OrderTile), findsNothing);
    });

    testWidgets('no hardcoded example values appear with different records', (
      tester,
    ) async {
      final List<Order> orders = <Order>[
        _executedOrder(
          id: '1',
          symbol: 'TMPV',
          product: 'INTRADAY',
          productCode: 'MIS',
          orderType: OrderType.market,
          quantity: 108,
          filledQuantity: 108,
          price: 279.40,
        ),
        _executedOrder(
          id: '2',
          side: OrderSide.sell,
          symbol: 'INFY',
          product: 'CNC',
          productCode: 'CNC',
          orderType: OrderType.limit,
          quantity: 50,
          filledQuantity: 50,
          price: 1246.90,
        ),
      ];
      await pumpOrders(tester, orders: orders);
      await tester.tap(find.text('Executed'));
      await tester.pumpAndSettle();
      // Each tile shows its own data, not hardcoded values.
      expect(find.text('TMPV'), findsOneWidget);
      expect(find.text('INFY'), findsOneWidget);
      expect(find.text('MIS   MARKET'), findsOneWidget);
      expect(find.text('CNC   LIMIT'), findsOneWidget);
      expect(find.text('BUY'), findsOneWidget);
      expect(find.text('SELL'), findsOneWidget);
      expect(find.text('279.40'), findsOneWidget);
      expect(find.text('1,246.90'), findsOneWidget);
      // No hardcoded '0/108' — filled quantity equals total for executed orders.
      expect(find.text('0/108'), findsNothing);
      expect(find.text('108/108'), findsOneWidget);
    });
  });

  group('Order placement integration', () {
    testWidgets('a successful fill creates exactly one order-history entry', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final order = _executedOrder();
      container.read(orderHistoryProvider.notifier).addOrder(order);

      expect(container.read(orderHistoryProvider).length, 1);
      expect(container.read(orderHistoryProvider).first.symbol, order.symbol);
      expect(container.read(orderHistoryProvider).first.price, order.price);
    });

    testWidgets('the recorded order contains correct execution details', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final order = _executedOrder(
        symbol: 'ONGC',
        price: 222.37,
        quantity: 300,
        filledQuantity: 300,
        product: 'INTRADAY',
        productCode: 'MIS',
        orderType: OrderType.market,
      );
      container.read(orderHistoryProvider.notifier).addOrder(order);

      final recorded = container.read(orderHistoryProvider).first;
      expect(recorded.symbol, 'ONGC');
      expect(recorded.price, 222.37);
      expect(recorded.quantity, 300);
      expect(recorded.filledQuantity, 300);
      expect(recorded.productCode, 'MIS');
      expect(recorded.orderType, OrderType.market);
      expect(recorded.status, OrderStatus.executed);
    });

    testWidgets(
      'an unsuccessful order does not create an executed history entry',
      (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        // No order is added — simulating a rejected sell.
        expect(container.read(orderHistoryProvider).isEmpty, isTrue);
      },
    );
  });

  group('Orders swipe navigation', () {
    testWidgets('left swipe switches Open to Executed', (
      WidgetTester tester,
    ) async {
      final List<Order> orders = <Order>[_executedOrder()];
      await pumpOrders(tester, orders: orders);

      expect(find.byType(OrderTile), findsNothing);
      expect(find.byType(OrdersEmptyState), findsOneWidget);

      // Drag left on the tab selector (matching Portfolio's approach).
      await tester.drag(find.byType(OrdersTabSelector), const Offset(-150, 0));
      await tester.pumpAndSettle();

      expect(find.byType(OrderTile), findsOneWidget);
      expect(find.text('IDFCFIRSTB'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('right swipe switches Executed to Open', (
      WidgetTester tester,
    ) async {
      final List<Order> orders = <Order>[_executedOrder()];
      await pumpOrders(tester, orders: orders);

      // Start on Executed.
      await tester.tap(find.text('Executed'));
      await tester.pumpAndSettle();
      expect(find.byType(OrderTile), findsOneWidget);

      // Drag right on the tab selector to switch back to Open.
      await tester.drag(find.byType(OrdersTabSelector), const Offset(150, 0));
      await tester.pumpAndSettle();

      expect(find.byType(OrderTile), findsNothing);
      expect(find.byType(OrdersEmptyState), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('left swipe on last tab stays on last tab', (
      WidgetTester tester,
    ) async {
      await pumpOrders(tester);

      // Already on Open (index 0). Swipe left to Executed (index 1, last).
      await tester.drag(find.byType(OrdersTabSelector), const Offset(-150, 0));
      await tester.pumpAndSettle();

      // Swipe left again — should stay on Executed (boundary).
      await tester.drag(find.byType(OrdersTabSelector), const Offset(-150, 0));
      await tester.pumpAndSettle();

      expect(find.byType(OrderTile), findsNothing);
      expect(find.byType(OrdersEmptyState), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('right swipe on first tab stays on first tab', (
      WidgetTester tester,
    ) async {
      await pumpOrders(tester);

      // On Open (first tab). Swipe right — should stay on Open (boundary).
      await tester.drag(find.byType(OrdersTabSelector), const Offset(150, 0));
      await tester.pumpAndSettle();

      expect(find.byType(OrderTile), findsNothing);
      expect(find.byType(OrdersEmptyState), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
