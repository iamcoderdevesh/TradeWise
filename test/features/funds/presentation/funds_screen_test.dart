import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tradewise/features/funds/data/mock_funds_repository.dart';
import 'package:tradewise/features/funds/presentation/funds_providers.dart';
import 'package:tradewise/features/funds/presentation/funds_screen.dart';

void main() {
  group('FundsScreen', () {
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

    testWidgets('displays initial available balance of ₹10000.00', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(const FundsScreen()));

      expect(find.text('₹10000.00'), findsAtLeastNWidgets(1));
      expect(find.text('Available balance'), findsOneWidget);
      expect(find.text('Add Funds'), findsOneWidget);
    });

    testWidgets('displays available cash and used margin', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(const FundsScreen()));

      expect(find.text('Available cash'), findsOneWidget);
      expect(find.text('Used margin'), findsOneWidget);
      expect(find.text('₹0.00'), findsOneWidget);
    });

    testWidgets('Add Funds button is present', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(const FundsScreen()));

      expect(find.text('Add Funds'), findsOneWidget);
    });

    testWidgets('light theme renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(const FundsScreen()));

      expect(find.text('₹10000.00'), findsAtLeastNWidgets(1));
    });

    testWidgets('dark theme renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(const FundsScreen()));

      expect(find.text('₹10000.00'), findsAtLeastNWidgets(1));
    });
  });
}
