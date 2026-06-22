import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_test/features/auth/models/auth_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  final Dio _dio;

  ProfileService() : _dio = Dio() {
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
          if (options.path.contains('/posts')) return false;
          return !args.isResponse || !args.hasUint8ListData;
        },
      ),
    );
  }

  Future<AuthModel> getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null || token.isEmpty) {
        throw Exception('No access token found. Please login again.');
      }

      final response = await _dio.get(
        'https://dummyjson.com/auth/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        await prefs.setString('user', jsonEncode(response.data));

        return AuthModel.fromJson(response.data);
      } else {
        throw Exception('Failed to get profile');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to load profile';
      if (e.response != null && e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      throw Exception(errorMessage);
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }
  
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken'); // 💡 ဖျက်ပစ်မယ်
    await prefs.remove('username');
  }
}
