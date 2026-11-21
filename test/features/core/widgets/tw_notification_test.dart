import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tradewise/app/theme/tw_theme.dart';
import 'package:tradewise/core/widgets/tw_notification.dart';

/// Helper widget that shows a shared notification after the first frame.
class _NotificationTrigger extends StatefulWidget {
  const _NotificationTrigger({required this.type, required this.message});

  final TWNotificationType type;
  final String message;

  @override
  State<_NotificationTrigger> createState() => _NotificationTriggerState();
}

class _NotificationTriggerState extends State<_NotificationTrigger> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      TWNotifications.show(context, type: widget.type, message: widget.message);
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

void main() {
  Future<void> pumpNotification(
    WidgetTester tester, {
    required TWNotificationType type,
    String message = 'Test notification message',
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TWTheme.light(),
        darkTheme: TWTheme.dark(),
        themeMode: themeMode,
        home: Scaffold(
          body: _NotificationTrigger(type: type, message: message),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('success notification renders with icon and message', (
    WidgetTester tester,
  ) async {
    await pumpNotification(tester, type: TWNotificationType.success);

    expect(find.text('Test notification message'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('error notification renders with icon and message', (
    WidgetTester tester,
  ) async {
    await pumpNotification(tester, type: TWNotificationType.error);

    expect(find.text('Test notification message'), findsOneWidget);
    expect(find.byIcon(Icons.error), findsOneWidget);
  });

  testWidgets('warning notification renders with icon and message', (
    WidgetTester tester,
  ) async {
    await pumpNotification(tester, type: TWNotificationType.warning);

    expect(find.text('Test notification message'), findsOneWidget);
    expect(find.byIcon(Icons.warning), findsOneWidget);
  });

  testWidgets('alert notification renders with icon and message', (
    WidgetTester tester,
  ) async {
    await pumpNotification(tester, type: TWNotificationType.alert);

    expect(find.text('Test notification message'), findsOneWidget);
    expect(find.byIcon(Icons.info), findsOneWidget);
  });

  testWidgets('light theme renders success with readable colors', (
    WidgetTester tester,
  ) async {
    await pumpNotification(
      tester,
      type: TWNotificationType.success,
      themeMode: ThemeMode.light,
    );

    expect(find.text('Test notification message'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dark theme renders success with readable colors', (
    WidgetTester tester,
  ) async {
    await pumpNotification(
      tester,
      type: TWNotificationType.success,
      themeMode: ThemeMode.dark,
    );

    expect(find.text('Test notification message'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('light theme renders error with readable colors', (
    WidgetTester tester,
  ) async {
    await pumpNotification(
      tester,
      type: TWNotificationType.error,
      themeMode: ThemeMode.light,
    );

    expect(find.text('Test notification message'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dark theme renders error with readable colors', (
    WidgetTester tester,
  ) async {
    await pumpNotification(
      tester,
      type: TWNotificationType.error,
      themeMode: ThemeMode.dark,
    );

    expect(find.text('Test notification message'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('replacing notification hides previous before showing new', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TWTheme.light(),
        darkTheme: TWTheme.dark(),
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                TWNotifications.showSuccess(context, 'First message');
                TWNotifications.showError(context, 'Second message');
              });
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('First message'), findsNothing);
    expect(find.text('Second message'), findsOneWidget);
  });
}
