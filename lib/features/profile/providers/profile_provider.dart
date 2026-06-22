import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_test/features/auth/models/auth_model.dart';
import 'package:riverpod_test/features/auth/services/auth_service.dart';
import 'package:riverpod_test/features/profile/services/profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final profileProvider = AsyncNotifierProvider<ProfileNotifier, AuthModel?>(() {
  return ProfileNotifier();
});

class ProfileNotifier extends AsyncNotifier<AuthModel?> {
  final _profileService = ProfileService();
  final _authService = AuthService();
  @override
  FutureOr<AuthModel?> build() async {
    final prefs = await SharedPreferences.getInstance();
    final localUserData = prefs.getString('user') ?? '';
    AuthModel? localUser;

    if (localUserData.isNotEmpty) {
      localUser = AuthModel.fromJson(jsonDecode(localUserData));
    }
    try {
      final token = await _profileService.getToken();
      if (token != null) {
        final freshUser = await _profileService.getProfile();
        return freshUser;
      }
    } catch (e) {
      if (localUser != null) return localUser;
      rethrow;
    }
    return null;
  }

  Future<void> logout() async {
    await _authService.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    state = const AsyncData(null);
  }
}
