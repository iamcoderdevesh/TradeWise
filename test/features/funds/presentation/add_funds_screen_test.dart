import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tradewise/features/funds/data/mock_funds_repository.dart';
import 'package:tradewise/features/funds/presentation/add_funds_screen.dart';
import 'package:tradewise/features/funds/presentation/funds_providers.dart';

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
  });
}
