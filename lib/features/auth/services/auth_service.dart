import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_test/features/auth/models/auth_model.dart';

class AuthService {
  final Dio _dio;

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

  Future<AuthModel> login(String username, String password) async {
    try {
      final response = await _dio.post(
        'https://dummyjson.com/auth/login',
        data: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        final authData = AuthModel.fromJson(response.data);
        final authBox = Hive.box('authBox');

        await authBox.put('current_user', authData);

        return authData;
      } else {
        throw Exception('Failed to login');
      }
    } on DioException catch (e) {
      String errorMessage = 'Login Fail';
      if (e.response != null && e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      throw Exception(errorMessage);
    }
  }

  Future<bool> checkAndRefreshAuth() async {
    final authBox = Hive.box('authBox');
    final AuthModel? cachedUser = authBox.get('current_user');
    if (cachedUser == null || cachedUser.accessToken.isEmpty) {
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
            'https://dummyjson.com/auth/refresh', // သင့် API URL အတိုင်း ပြင်ရန်
            data: {'refreshToken': refreshToken, 'expiresInMins': 30},
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
              print('✅ [AuthService] Token refreshed successfully!');
            }
            return true; //
          } else {
            throw Exception('Failed to refresh token from API');
          }
        } else {
          throw Exception('Refresh token field is empty');
        }
      }
      if (kDebugMode) print('✅ [AuthService] Access Token is still valid.');
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
}
