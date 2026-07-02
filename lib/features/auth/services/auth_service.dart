import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_test/features/auth/models/auth_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final Dio _dio;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthService() : _dio = Dio() {
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
        enabled: kDebugMode,
      ),
    );
  }

  Future<bool> checkAndRefreshAuth() async {
    final authBox = Hive.box('authBox');
    final AuthModel? cachedUser = authBox.get('current_user');
    if (cachedUser == null) {
      if (kDebugMode) {
        print('ℹ️ [AuthService] No cached user found in Hive. Access Denied.');
      }
      return false;
    }

    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      if (kDebugMode) {
        print('ℹ️ [AuthService] No Firebase user found. Access Denied.');
      }
      await authBox.delete('current_user');
      return false;
    }
    try {
      if (kDebugMode) {
        print('🔄 [AuthService] Checking and refreshing Firebase ID Token...');
      }
      await firebaseUser.reload();
      final String? token = await firebaseUser.getIdToken(false);
      if (token != null) {
        if (kDebugMode) {
          print('🔑 [AuthService] Current Firebase ID Token: $token');
        }
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [AuthService] Error during token refresh: $e');
      }
      await authBox.delete('current_user');
      await _auth.signOut();
      return false;
    }
  }

  Future<void> logout() async {
    final authBox = Hive.box('authBox');
    await authBox.delete('current_user');
    await authBox.put('isLoggedIn', false);
  }

  Future<UserCredential> firebaseLogin({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> register({
    required String email,
    required String password,
    required String username,
    required String firstName,
    required String lastName,
    required String gender,
    required String image,
  }) async {
    final UserCredential userCredential = await _auth
        .createUserWithEmailAndPassword(email: email, password: password);

    final String? uid = userCredential.user?.uid;

    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'id': uid.hashCode,
        'uid': uid,
        'username': username,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'gender': gender,
        'image': image,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return userCredential;
  }

  Future<void> firebaselogout() async {
    await _auth.signOut();
    final authBox = Hive.box('authBox');
    await authBox.delete('current_user');
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authState => _auth.authStateChanges();
}
