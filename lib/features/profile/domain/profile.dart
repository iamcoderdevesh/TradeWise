import 'package:flutter/foundation.dart';

/// One user's profile display data.
///
/// Immutable by convention: the [UserProfile] holds the authoritative values
/// that the UI displays. Privacy-mode masking is a presentational concern
/// handled by the widget layer, not by this model.
@immutable
class UserProfile {
  const UserProfile({
    required this.userId,
    required this.name,
    required this.email,
    required this.avatarInitials,
  });

  /// TradeWise account identifier (e.g. "TW123456").
  final String userId;

  /// Display name shown in the user header.
  final String name;

  /// Email address shown under the account ID.
  final String email;

  /// Initials rendered inside the avatar circle.
  final String avatarInitials;
}
