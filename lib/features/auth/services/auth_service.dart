import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // 💡 kDebugMode အတွက် လိုအပ်ပါတယ်
import 'package:pretty_dio_logger/pretty_dio_logger.dart'; // 💡 logger package ကို import လုပ်ပါ
import 'package:riverpod_test/features/auth/models/auth_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        filter: (options, args) {
          if (options.path.contains('/posts')) {
            return false;
          }
          return !args.isResponse || !args.hasUint8ListData;
        },
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshToken = await getRefreshToken();
            if (refreshToken != null) {
              final newAccessToken = await refreshTheToken(refreshToken);

              if (newAccessToken != null) {
                error.requestOptions.headers['Authorization'] =
                    'Bearer $newAccessToken';

                final cloneReq = await _dio.fetch(error.requestOptions);
                return handler.resolve(cloneReq);
              }
            } else {
              await logout();

              return handler.next(error);
            }
          }
          return handler.next(error);
        },
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
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', authData.accessToken);
        await prefs.setString(
          'refreshToken',
          response.data['refreshToken'] ?? '',
        );

        await prefs.setString('username', authData.username);

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

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken'); // 💡 ဖျက်ပစ်မယ်
    await prefs.remove('username');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken');
  }

  Future<String?> refreshTheToken(String? refreshToken) async {
    try {
      final response = await _dio.post(
        'https://dummyjson.com/auth/refresh',
        data: {'refreshToken': refreshToken, 'expiresInMins': 30},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken'];
        final newRefreshToken = response.data['refreshToken'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', newAccessToken);
        await prefs.setString('refreshToken', newRefreshToken);
        return newAccessToken;
      }
    } catch (e) {
      debugPrint('Refresh Token Error: $e');
    }
    return null;
  }
}
