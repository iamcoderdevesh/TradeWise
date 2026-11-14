import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tradewise/features/profile/data/profile_repository.dart';
import 'package:tradewise/features/profile/domain/profile.dart';

/// Seeds the simulated profile. The single seam replaced by a real data
/// source later; tests override it with custom profiles.
final profileRepositoryProvider = Provider<ProfileRepository>(
  (Ref ref) => const MockProfileRepository(),
);

/// Simulated profile state (UI phase).
///
/// A single Riverpod [Notifier] seeded from the mock [ProfileRepository].
/// There is no persistence, no backend, and no real account data — this is
/// UI-only state so the screen can be exercised end-to-end.
class ProfileNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    final ProfileRepository repository = ref.read(profileRepositoryProvider);
    return repository.loadProfile();
  }
}

/// Read-only stream of the current user's profile.
final profileProvider = NotifierProvider<ProfileNotifier, UserProfile>(
  ProfileNotifier.new,
);

/// Privacy Mode state (UI phase).
///
/// `build() => false` in both light and dark themes. Toggling masks or
/// restores the account ID and email in the AccountInfoCard. This is local
/// UI behavior only — it does not represent actual backend security,
/// authentication, or data protection.
class PrivacyModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

/// Privacy Mode switch state.
final privacyModeProvider = NotifierProvider<PrivacyModeNotifier, bool>(
  PrivacyModeNotifier.new,
);
