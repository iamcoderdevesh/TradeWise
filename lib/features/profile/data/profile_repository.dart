import 'package:tradewise/features/profile/data/profile_preview_data.dart';
import 'package:tradewise/features/profile/domain/profile.dart';

/// Source of the user's profile data (UI phase).
///
/// Abstracted behind a repository so the mock below can be swapped for a real
/// data source without touching the notifier or any widget.
abstract class ProfileRepository {
  const ProfileRepository();

  /// Loads the current user's profile.
  UserProfile loadProfile();
}

/// In-memory preview implementation (UI-only phase).
///
/// Defaults to TradeWise-appropriate preview data; tests pass custom profiles
/// (or empty ones) to exercise the populated and masked states.
class MockProfileRepository extends ProfileRepository {
  const MockProfileRepository({this.profile = kPreviewProfile});

  final UserProfile profile;

  @override
  UserProfile loadProfile() => profile;
}
