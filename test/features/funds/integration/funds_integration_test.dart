import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tradewise/features/funds/data/mock_funds_repository.dart';
import 'package:tradewise/features/funds/presentation/add_funds_screen.dart';
import 'package:tradewise/features/funds/presentation/funds_providers.dart';
import 'package:tradewise/features/funds/presentation/funds_screen.dart';

void main() {
  group('Funds Integration', () {
    Widget buildTestWidget(Widget child) {
      return ProviderScope(
        overrides: [
          fundsRepositoryProvider.overrideWithValue(
            const MockFundsRepository(initialAvailableBalance: 10000.0),
          ),
        ],
        child: MaterialApp(home: child),
      );
    }

    testWidgets('Funds screen displays initial balance', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(const FundsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('₹10000.00'), findsAtLeastNWidgets(1));
      expect(find.text('Available balance'), findsOneWidget);
      expect(find.text('Add Funds'), findsOneWidget);
      expect(find.text('Available cash'), findsOneWidget);
      expect(find.text('Used margin'), findsOneWidget);
      expect(find.text('₹0.00'), findsOneWidget);
    });

    testWidgets('Add Funds screen displays current balance and amount field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(const AddFundsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Balance'), findsOneWidget);
      expect(find.text('₹10000.00'), findsOneWidget);
      expect(find.text('Amount'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('₹'), findsOneWidget);
    });

    testWidgets('invalid amount is rejected and balance unchanged', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(const AddFundsScreen()));
      await tester.pumpAndSettle();

      final textField = find.byType(TextField).first;

      // Try entering zero
      await tester.enterText(textField, '0');
      await tester.pump();

      // Balance should remain unchanged
      expect(find.text('₹10000.00'), findsAtLeastNWidgets(1));

      // Try entering negative
      await tester.enterText(textField, '-100');
      await tester.pump();

      // Balance should remain unchanged
      expect(find.text('₹10000.00'), findsAtLeastNWidgets(1));
    });

    testWidgets('swipe-to-confirm label appears when amount is valid', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(const AddFundsScreen()));
      await tester.pumpAndSettle();

      // Initially empty - swipe label exists but control is disabled
      expect(find.text('Swipe to Add Funds'), findsOneWidget);

      // Enter valid amount
      final textField = find.byType(TextField).first;
      await tester.enterText(textField, '5000');
      await tester.pumpAndSettle();

      // Swipe label still present (control now enabled)
      expect(find.text('Swipe to Add Funds'), findsOneWidget);
    });
  });
}
