import 'package:firebase_auth/firebase_auth.dart';
import 'package:tradewise/state/appState.dart';

class AuthState extends AppState {
  late String? userId;
  late User? user = FirebaseAuth.instance.currentUser;

  bool authStatus = false;

  void updateAuthStatus({required bool authStatus}) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      this.authStatus = authStatus;
      userId = user.uid;
    }
    notifyListeners();
  }

  bool checkAuthStatus() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      authStatus = true;
      userId = user.uid;
    }

    return authStatus;
  }

  Future<void> singOut() async {
    await FirebaseAuth.instance.signOut();
    authStatus = false;
    userId = null;
  }
}
