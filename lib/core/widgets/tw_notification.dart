library;

import 'package:flutter/material.dart';

import '../../app/theme/tw_colors.dart';

/// Severity of a shared TradeWise notification.
enum TWNotificationType {
  /// Successful operation (e.g. funds added, order filled).
  success,

  /// Failed operation or serious error (e.g. rejected sell order).
  error,

  /// Potentially problematic condition requiring attention.
  warning,

  /// General informational notice or unavailable feature.
  alert,
}

/// Default duration for shared notifications.
const Duration kTWNotificationDuration = Duration(seconds: 4);

/// Shared TradeWise notification component.
///
/// All screens route feedback through [TWNotifications.show] so that
/// notification styling, icons, semantic colors, duration, and dismissal
/// remain centralized in one place instead of being duplicated per screen.
///
/// Builds a themed TradeWise [SnackBar] for a given [TWNotificationType].
///
/// All screens route feedback through [TWNotifications] so that notification
/// styling, icons, semantic colors, duration, and dismissal remain centralized
/// in one place instead of being duplicated per screen.
///
/// The returned [SnackBar] uses [SnackBarBehavior.floating] so it does not
/// disrupt the underlying screen layout.
class TWSnackBar {
  TWSnackBar._();

  /// Builds a [SnackBar] with a leading icon, message text, and a background
  /// color resolved from the semantic color tokens for [type].
  static SnackBar build(
    BuildContext context, {
    required TWNotificationType type,
    required String message,
    Duration duration = kTWNotificationDuration,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SnackBar(
      content: _TWSnackBarContent(type: type, message: message),
      backgroundColor: _backgroundColor(type, isDark),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      duration: duration,
    );
  }

  static Color _backgroundColor(TWNotificationType type, bool isDark) {
    switch (type) {
      case TWNotificationType.success:
        return isDark ? TWColors.darkPositive : TWColors.lightPositive;
      case TWNotificationType.error:
        return isDark ? TWColors.darkNegative : TWColors.lightNegative;
      case TWNotificationType.warning:
        return isDark ? TWColors.darkWarning : TWColors.lightWarning;
      case TWNotificationType.alert:
        return isDark ? TWColors.darkAlert : TWColors.lightAlert;
    }
  }

  static IconData _icon(TWNotificationType type) {
    switch (type) {
      case TWNotificationType.success:
        return Icons.check_circle;
      case TWNotificationType.error:
        return Icons.error;
      case TWNotificationType.warning:
        return Icons.warning;
      case TWNotificationType.alert:
        return Icons.info;
    }
  }
}

/// Leading icon + message text for a shared notification.
///
/// Foreground color is resolved from the semantic `On*` token for the
/// notification type so that both light and dark themes remain readable.
/// Error reuses the existing `OnNegative` foreground since its background
/// reuses the existing negative color.
class _TWSnackBarContent extends StatelessWidget {
  const _TWSnackBarContent({required this.type, required this.message});

  final TWNotificationType type;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color foreground = switch (type) {
      TWNotificationType.success =>
        isDark ? TWColors.darkOnSuccess : TWColors.lightOnSuccess,
      TWNotificationType.error =>
        isDark ? TWColors.darkOnNegative : TWColors.lightOnNegative,
      TWNotificationType.warning =>
        isDark ? TWColors.darkOnWarning : TWColors.lightOnWarning,
      TWNotificationType.alert =>
        isDark ? TWColors.darkOnAlert : TWColors.lightOnAlert,
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Icon(TWSnackBar._icon(type), color: foreground, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(color: foreground),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Centralized notification API for TradeWise screens.
///
/// Use [TWNotifications.show] (or one of the typed convenience methods) to
/// surface a shared [TWSnackBar] above the current screen content. Each call
/// hides any currently visible snack bar first, so duplicate notifications
/// are never stacked.
class TWNotifications {
  TWNotifications._();

  /// Shows a shared notification of [type] with [message].
  ///
  /// Any currently visible snack bar is replaced so rapid actions report
  /// immediately without queuing duplicate bars.
  static void show(
    BuildContext context, {
    required TWNotificationType type,
    required String message,
    Duration duration = kTWNotificationDuration,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        TWSnackBar.build(
          context,
          type: type,
          message: message,
          duration: duration,
        ),
      );
  }

  /// Shows a success notification.
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = kTWNotificationDuration,
  }) {
    show(
      context,
      type: TWNotificationType.success,
      message: message,
      duration: duration,
    );
  }

  /// Shows an error notification.
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = kTWNotificationDuration,
  }) {
    show(
      context,
      type: TWNotificationType.error,
      message: message,
      duration: duration,
    );
  }

  /// Shows a warning notification.
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = kTWNotificationDuration,
  }) {
    show(
      context,
      type: TWNotificationType.warning,
      message: message,
      duration: duration,
    );
  }

  /// Shows an alert / information notification.
  static void showAlert(
    BuildContext context,
    String message, {
    Duration duration = kTWNotificationDuration,
  }) {
    show(
      context,
      type: TWNotificationType.alert,
      message: message,
      duration: duration,
    );
  }
}
