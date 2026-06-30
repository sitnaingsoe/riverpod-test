import 'dart:developer' as developer;

import 'package:hive/hive.dart';
import 'package:riverpod_test/features/auth/models/auth_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_test/features/auth/services/auth_service.dart';

class AuthNotifier extends AsyncNotifier<AuthModel?> {
  late final AuthService _authService;
  late final FirebaseAuth _firebaseAuth;
  @override
  Future<AuthModel?> build() async {
    _authService = AuthService();
    _firebaseAuth = ref.read(firebaseAuthProvider);

    final authBox = Hive.box('authBox');
    final AuthModel? cachedUser = authBox.get('current_user');
    if (cachedUser != null) {
      return cachedUser;
    }
    return null;
  }

  Future<void> register(String email, String password) async {
    state = const AsyncLoading();
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        final token = await firebaseUser.getIdToken();
        final RegExp digitRegex = RegExp(r'\d+');
        digitRegex.allMatches(firebaseUser.uid).map((m) => m.group(0)).join();
        final newUser = AuthModel(
          id: firebaseUser.uid.hashCode,
          email: firebaseUser.email ?? email,
          username: email.split('@')[0],
          firstName: '',
          lastName: '',
          gender: 'unknown',
          image: '',
          accessToken: token ?? '',
          refreshToken: '',
        );

        final authBox = Hive.box('authBox');
        await authBox.put('current_user', newUser);
        state = AsyncValue.data(newUser);
        developer.log(
          '🎉 Register & State Update Successful with int ID!',
          name: 'AUTH_NOTIFIER',
        );
      } else {
        throw Exception('User creation failed on Firebase.');
      }
    } on FirebaseAuthException catch (e) {
      String msg = e.message ?? 'An error occured';
      if (e.code == 'emial-already-in-use') msg = 'emial-already-in-use';
      state = AsyncValue.error(msg, StackTrace.current);
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      final userCredential = await _authService.firebaseLogin(
        email: email,
        password: password,
      );
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final token = await firebaseUser.getIdToken();
        final RegExp digitRegex = RegExp(r'\d+');
        final String digitsOnly = digitRegex
            .allMatches(firebaseUser.uid)
            .map((m) => m.group(0))
            .join();
        final int intId =
            int.tryParse(digitsOnly) ?? DateTime.now().millisecondsSinceEpoch;
        final newUser = AuthModel(
          id: intId,
          email: firebaseUser.email ?? email,
          username: email.split('@')[0],
          firstName: '',
          lastName: '',
          gender: 'unknown',
          image: '',
          accessToken: token ?? '',
          refreshToken: firebaseUser.refreshToken ?? '',
        );
        final authBox = Hive.box('authBox');
        await authBox.put('current_user', newUser);

        state = AsyncValue.data(newUser);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();

    try {
      final authBox = Hive.box('authBox');

      await authBox.delete('current_user');

      await _authService.firebaselogout();

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clearAuthState() {
    state = const AsyncValue.data(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthModel?>(
  AuthNotifier.new,
);
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);
