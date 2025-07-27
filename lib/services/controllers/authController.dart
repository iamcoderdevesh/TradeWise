import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationController {
  AuthenticationController();

  Future<Map<String, dynamic>> handleSignup({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null && fullName.isNotEmpty) {
        await user.updateDisplayName(fullName);
        await user.reload();
      }

      return {"status": true, "message": "Signup Successful."};
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return {
          "status": false,
          "message": "The password provided is too weak."
        };
      } else if (e.code == 'email-already-in-use') {
        return {
          "status": false,
          "message": "The account already exists for that email."
        };
      }
    } catch (e) {
      return {"status": false, "message": e.toString()};
    }

    return {"status": false, "message": "Unknown error occurred."};
  }

  Future<Map<String, dynamic>> handleSignIn({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return {"status": false, "message": "No user found for that email."};
      } else if (e.code == 'wrong-password') {
        return {"status": false, "message": "Incorrect password."};
      } else if (e.code == 'invalid-credential') {
        return {"status": false, "message": "Incorrect email or password."};
      }
    } catch (e) {
      return {"status": false, "message": e.toString()};
    }

    return {"status": true, "message": "Signin Successfully."};
  }
}
