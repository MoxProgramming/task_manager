import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_manager/features/auth/data/models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth;

  AuthRepository(this._auth);

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return 'The email address is badly formatted.';
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        default:
          return 'Authentication failed. Please try again.';
      }
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  Future<String?> register(
    String email,
    String password,
    String nickname,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        final userModel = UserModel(
          email: user.email ?? '',
          nickname: nickname,
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(userModel.toJson());
      }
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'This email is already in use.';
        case 'invalid-email':
          return 'The email address is badly formatted.';
        case 'weak-password':
          return 'The password is too weak.';
        default:
          return 'Registration failed. Please try again.';
      }
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserModel?> getUserModel(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (doc.exists) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  Future<bool> isNicknameTaken(String nickname) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('nickname', isEqualTo: nickname)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }
}
