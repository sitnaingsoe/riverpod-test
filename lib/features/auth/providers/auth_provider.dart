import 'package:riverpod_test/features/auth/models/auth_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_test/features/auth/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthNotifier extends AsyncNotifier<AuthModel?> {
  late final AuthService _authService;
  @override
  Future<AuthModel?> build() async {
    _authService = AuthService();
    final accessToken = await _authService.getToken();

    if (accessToken != null) {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? '';
      return AuthModel(
        accessToken: accessToken,
        username: username,
        email: '',
        firstName: 'Welcome',
        lastName: 'Back',
        id: null,
        gender: '',
        image: '',
        refreshToken: '',
      );
    }
    return null;
  }

  Future<void> login(String username, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return await _authService.login(username, password);
    });
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    await _authService.logout();
    state = const AsyncValue.data(null);
  }

  void clearAuthState() {
    state = const AsyncValue.data(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthModel?>(
  AuthNotifier.new,
);
