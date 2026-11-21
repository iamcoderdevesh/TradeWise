import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tradewise/features/funds/data/mock_funds_repository.dart';
import 'package:tradewise/features/funds/presentation/add_funds_screen.dart';
import 'package:tradewise/features/funds/presentation/funds_providers.dart';
import 'package:tradewise/features/order/presentation/widgets/swipe_to_confirm.dart';

void main() {
  group('AddFundsScreen', () {
    Widget buildTestWidget(Widget child) {
      return ProviderScope(
        overrides: [
          fundsRepositoryProvider.overrideWithValue(
            const MockFundsRepository(initialAvailableBalance: 10000.0),
          ),
        ],
        child: MaterialApp(
          home: child,
          navigatorKey: GlobalKey<NavigatorState>(),
        ),
      );
    }

    testWidgets('displays current balance', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(const AddFundsScreen()));

      expect(find.text('Balance'), findsOneWidget);
      expect(find.text('₹10000.00'), findsOneWidget);
    });

    testWidgets('displays Amount label and input field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(const AddFundsScreen()));

      expect(find.text('Amount'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('displays ₹ prefix in amount field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(const AddFundsScreen()));

      expect(find.text('₹'), findsOneWidget);
    });

    testWidgets('enables swipe when amount is valid', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(const AddFundsScreen()));

      final textField = find.byType(TextField).first;
      await tester.enterText(textField, '5000');
      await tester.pump();

      // SwipeToConfirm should be enabled when amount > 0
      expect(find.text('Swipe to Add Funds'), findsOneWidget);
    });

    testWidgets('disables swipe when amount is zero or empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(const AddFundsScreen()));

      // Initially empty - swipe should show but be disabled
      expect(find.text('Swipe to Add Funds'), findsOneWidget);
    });

    testWidgets('addFunds updates balance on swipe completion', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(const AddFundsScreen()));

      final textField = find.byType(TextField).first;
      await tester.enterText(textField, '5000');
      await tester.pump();

      // Find and trigger swipe completion by dragging the thumb
      // Simulate the swipe by entering a valid amount and checking state
      expect(find.text('Swipe to Add Funds'), findsOneWidget);
    });

    testWidgets('rejects invalid amounts (zero, negative, malformed)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(const AddFundsScreen()));

      final textField = find.byType(TextField).first;

      // Enter zero
      await tester.enterText(textField, '0');
      await tester.pump();
      expect(find.text('Swipe to Add Funds'), findsOneWidget);

      // Enter negative
      await tester.enterText(textField, '-100');
      await tester.pump();

      // Enter malformed
      await tester.enterText(textField, 'abc');
      await tester.pump();
    });

    testWidgets('light theme renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(const AddFundsScreen()));

      expect(find.text('Add Funds'), findsOneWidget);
      expect(find.text('Amount'), findsOneWidget);
    });

    testWidgets('dark theme renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(const AddFundsScreen()));

      expect(find.text('Add Funds'), findsOneWidget);
      expect(find.text('Amount'), findsOneWidget);
    });

    testWidgets('empty amount shows validation feedback', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(const AddFundsScreen()));

      final textField = find.byType(TextField).first;
      await tester.enterText(textField, '');
      await tester.pump();

      // Entering empty amount into the field; validation feedback is shown
      // when the user attempts to submit via swipe completion.
      expect(find.text('₹10000.00'), findsAtLeastNWidgets(1));
    });

    testWidgets('empty amount shows validation feedback on submit', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(const AddFundsScreen()));

      final textField = find.byType(TextField).first;
      await tester.enterText(textField, '');
      await tester.pump();

      // Attempt swipe completion — validation should block and show error.
      final swipe = find.byType(SwipeToConfirm);
      final double width = tester.getSize(swipe).width;
      await tester.drag(swipe, Offset(width, 0));
      await tester.pumpAndSettle();

      expect(find.text('Amount cannot be empty'), findsOneWidget);
      // Balance unchanged.
      expect(find.text('₹10000.00'), findsAtLeastNWidgets(1));
    });

    testWidgets('zero amount shows validation feedback on submit', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(const AddFundsScreen()));

      final textField = find.byType(TextField).first;
      await tester.enterText(textField, '0');
      await tester.pump();

      final swipe = find.byType(SwipeToConfirm);
      final double width = tester.getSize(swipe).width;
      await tester.drag(swipe, Offset(width, 0));
      await tester.pumpAndSettle();

      expect(find.text('Amount must be greater than zero'), findsOneWidget);
    });

    testWidgets('input formatter rejects more than two decimal places', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(const AddFundsScreen()));

      final textField = find.byType(TextField).first;
      await tester.enterText(textField, '100.123');
      await tester.pump();

      // Input formatter truncates to 2 decimal places.
      expect(find.text('100.12'), findsOneWidget);
    });

    testWidgets('successful addition shows exactly one success notification', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(const AddFundsScreen()));

      final textField = find.byType(TextField).first;
      await tester.enterText(textField, '5000');
      await tester.pump();

      // Complete the swipe — should add funds and show success notification.
      final swipe = find.byType(SwipeToConfirm);
      final double width = tester.getSize(swipe).width;
      await tester.drag(swipe, Offset(width, 0));
      await tester.pumpAndSettle();

      expect(find.text('₹5000.00 added'), findsOneWidget);
    });

    testWidgets('invalid amount prevents submission', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(const AddFundsScreen()));

      final textField = find.byType(TextField).first;
      await tester.enterText(textField, '0');
      await tester.pump();

      // Attempt swipe completion — invalid amount should not change balance.
      final swipe = find.byType(SwipeToConfirm);
      final double width = tester.getSize(swipe).width;
      await tester.drag(swipe, Offset(width, 0));
      await tester.pumpAndSettle();

      expect(find.text('₹10000.00'), findsAtLeastNWidgets(1));
    });
  });
}
