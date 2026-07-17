import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
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
        final String profileImageUrl = 'assets/images/profile.png';
        await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .set({
              'id': firebaseUser.uid.hashCode,
              'uid': firebaseUser.uid,
              'username': username,
              'email': firebaseUser.email,
              'firstName': firstName,
              'lastName': lastName,
              'gender': gender,
              'image': profileImageUrl,
              'createdAt': FieldValue.serverTimestamp(),
            });
        final token = await firebaseUser.getIdToken();

        final newUser = AuthModel(
          id: firebaseUser.uid.hashCode,
          email: firebaseUser.email ?? '',
          username: username,
          firstName: firstName,
          lastName: lastName,
          gender: gender,
          image: profileImageUrl,
          accessToken: token ?? '',
          refreshToken: firebaseUser.refreshToken ?? '',
        );
        final authBox = Hive.box('authBox');
        await authBox.put('current_user', newUser);

        state = AsyncValue.data(newUser);

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
      } else if (e.code == 'network-request-failed') {
        state = AsyncError(
          'No internet connection. Please check your network and try again.',
          StackTrace.current,
        );
      }

      state = AsyncValue.error(msg, StackTrace.current);
      rethrow;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<bool> checkEmailExists(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        throw 'No internet connection. Please check your network and try again.';
      }

      if (e.code == 'user-not-found') {
        return false;
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return true;
      }
      return true;
    } catch (e) {
      return true;
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

        final token = await firebaseUser.getIdToken();

        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        Map<String, dynamic> data = {};
        if (userDoc.exists && userDoc.data() != null) {
          data = userDoc.data() as Map<String, dynamic>;
        }

        final AuthModel newUser = AuthModel(
          id: intId,
          email: firebaseUser.email ?? email,
          username: data['username'] ?? email.split('@')[0],
          firstName: data['firstName'] ?? '',
          lastName: data['lastName'] ?? '',
          gender: data['gender'] ?? '',
          image: data['image'] ?? '',
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

  void updateUserState(AuthModel updatedUser) {
    state = AsyncValue.data(updatedUser);
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthModel?>(
  AuthNotifier.new,
);
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final tempRegisterProvider = StateProvider<Map<String, dynamic>?>((ref) {
  return null;
});
