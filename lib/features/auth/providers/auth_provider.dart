import 'dart:convert';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
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

  Future<void> register({
    required String email,
    required String password,
    required String username,
    required String firstName,
    required String lastName,
    required String gender,
    required String image,
  }) async {
    state = const AsyncLoading();
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        await firebaseUser.sendEmailVerification();

        state = AsyncValue.data(
          AuthModel(
            id: firebaseUser.uid.hashCode,
            email: firebaseUser.email ?? email,
            username: username.trim(),
            firstName: firstName.trim(),
            lastName: lastName.trim(),
            gender: gender.trim(),
            image: image,
            accessToken: 'PENDING_VERIFICATION',
            refreshToken: '',
          ),
        );

        developer.log(
          '🎉 Register, Firestore Storage & Hive Update Successful!',
          name: 'AUTH_NOTIFIER',
        );
      } else {
        throw Exception('User creation failed on Firebase.');
      }
    } on FirebaseAuthException catch (e) {
      String msg = e.message ?? 'An error occurred';

      if (e.code == 'email-already-in-use') {
        msg = ' This email account has already been opened.';
      } else if (e.code == 'weak-password') {
        msg = '🔑 The password must be at least 6 characters long.';
      }

      state = AsyncValue.error(msg, StackTrace.current);
      rethrow;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
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
        await firebaseUser.reload();
        final int intId = firebaseUser.uid.hashCode;
        if (kDebugMode) {
          print('✅ [AuthNotifier] Firebase User ID: ${firebaseUser.uid}');
          print('✅ [AuthNotifier] Firebase User ID (hashed): $intId');
        }

        final token = await firebaseUser.getIdToken();

        if (!firebaseUser.emailVerified) {
          final pendingUser = AuthModel(
            id: intId,
            email: firebaseUser.email ?? email,
            username: email.split('@')[0],
            firstName: 'Jhon',
            lastName: 'Smith',
            gender: 'unknown',
            image: '',
            accessToken: 'PENDING_VERIFICATION',
            refreshToken: '',
          );
          state = AsyncValue.data(pendingUser);
          developer.log(
            '⚠️ Login blocked: Email not verified yet.',
            name: 'AUTH_NOTIFIER',
          );
          return;
        } else {
          final DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .get();

          final data = userDoc.data() as Map<String, dynamic>;
          final AuthModel newUser = AuthModel(
            id: intId,
            email: firebaseUser.email ?? email,
            username: data['username'] ?? email.split('@')[0],
            firstName: data['firstName'] ?? 'Jhon',
            lastName: data['lastName'] ?? 'Smith',
            gender: data['gender'] ?? 'unknown',
            image: data['image'] ?? '',
            accessToken: token ?? '',
            refreshToken: firebaseUser.refreshToken ?? '',
          );

          final authBox = Hive.box('authBox');
          await authBox.put('current_user', newUser);

          state = AsyncValue.data(newUser);
        }
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

  Future<bool> checkEmailVerified({
    required String username,
    required String firstName,
    required String lastName,
    required String gender,
    required String image,
  }) async {
    await _firebaseAuth.currentUser?.reload();
    final user = _firebaseAuth.currentUser;

    if (user != null && user.emailVerified) {
      final token = await user.getIdToken();
      final String profileImageUrl = 'assets/images/profile.png';
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'id': user.uid.hashCode,
        'uid': user.uid,
        'username': username,
        'email': user.email,
        'firstName': firstName,
        'lastName': lastName,
        'gender': gender,
        'image': profileImageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final newUser = AuthModel(
        id: user.uid.hashCode,
        email: user.email ?? '',
        username: username,
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        image: profileImageUrl,
        accessToken: token ?? '',
        refreshToken: user.refreshToken ?? '',
      );
      final authBox = Hive.box('authBox');
      await authBox.put('current_user', newUser);

      state = AsyncValue.data(newUser);
      return true;
    }
    return false;
  }

  void updateUserState(AuthModel updatedUser) {
    state = AsyncValue.data(updatedUser);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthModel?>(
  AuthNotifier.new,
);
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

String getGravatarUrl(String email) {
  final cleanedEmail = email.trim().toLowerCase();

  final bytes = utf8.encode(cleanedEmail);

  final hash = md5.convert(bytes).toString();

  return 'https://www.gravatar.com/avatar/$hash?s=200&d=identicon';
}
