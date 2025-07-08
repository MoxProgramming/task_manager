import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_manager/features/auth/data/models/user_model.dart';
import 'package:task_manager/features/auth/domain/auth_repository.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(firebaseAuthProvider));
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final userModelProvider = FutureProvider<UserModel?>((ref) async {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return null;
  return ref.read(authRepositoryProvider).getUserModel(user.uid);
});

final nicknameCheckProvider = FutureProvider.family<bool, String>((
  ref,
  nickname,
) async {
  return ref.watch(authRepositoryProvider).isNicknameTaken(nickname);
});
