import 'package:hive/hive.dart';
import 'package:riverpod_test/features/auth/models/auth_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_test/features/auth/services/auth_service.dart';

class AuthNotifier extends AsyncNotifier<AuthModel?> {
  late final AuthService _authService;
  @override
  Future<AuthModel?> build() async {
    _authService = AuthService();
    final authBox = Hive.box('authBox');
    final AuthModel? cachedUser = authBox.get('current_user');
    if (cachedUser != null) {
      return cachedUser;
    }
    return null;
  }

  Future<void> login(String username, String password) async {
    state = const AsyncLoading();
    try {
      final user = await _authService.login(username, password);
      final authBox = Hive.box('authBox');
      await authBox.put('current_user', user);

      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();

    final authBox = Hive.box('authBox');
    await authBox.delete('current_user'); // Hive ဖျက်ခြင်း
    await _authService.logout(); // Service ရှင်းခြင်း

    state = const AsyncValue.data(null);
  }

  void clearAuthState() {
    state = const AsyncValue.data(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthModel?>(
  AuthNotifier.new,
);
