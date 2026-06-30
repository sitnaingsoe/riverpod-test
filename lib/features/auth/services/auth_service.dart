import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_test/features/auth/models/auth_model.dart';

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
    if (_auth.currentUser != null) {
      if (kDebugMode) print('✅ [AuthService] Firebase User Session is Active.');
      return true;
    }
    if (cachedUser.accessToken.isEmpty) {
      if (kDebugMode) print('Do not Authorized');
      return false;
    }

    String accessToken = cachedUser.accessToken;
    final refreshToken = cachedUser.refreshToken;

    try {
      bool isTokenExpired = JwtDecoder.isExpired(accessToken);
      if (isTokenExpired) {
        if (kDebugMode) print('Access Token expired. Attempting refresh...');

        if (refreshToken.isNotEmpty) {
          final response = await _dio.post(
            'https://dummyjson.com/auth/refresh',
            data: {'refreshToken': refreshToken},
          );

          if (response.statusCode == 200) {
            final newAccessToken = response.data['accessToken'];
            final newRefreshToken =
                response.data['refreshToken'] ?? refreshToken;

            final updatedUser = AuthModel(
              id: cachedUser.id,
              username: cachedUser.username,
              email: cachedUser.email,
              firstName: cachedUser.firstName,
              lastName: cachedUser.lastName,
              gender: cachedUser.gender,
              image: cachedUser.image,
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );
            await authBox.put('current_user', updatedUser);
            if (kDebugMode) {
              print('✅ [AuthService] API Token refreshed successfully!');
            }
            return true;
          } else {
            throw Exception('Failed to refresh token from API');
          }
        } else {
          throw Exception('Refresh token field is empty');
        }
      }
      if (kDebugMode) print('✅ [AuthService] API Access Token is still valid.');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ [AuthService] Session Expired or Error: $e');
      await authBox.delete('current_user');
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
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> firebaselogout() async {
    await _auth.signOut();
    final authBox = Hive.box('authBox');
    await authBox.delete(
      'current_user',
    ); // Firebase ထွက်ရင် Hive ထဲက ဒေတာပါ ရှင်းပေးခြင်း
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authState => _auth.authStateChanges();
}
