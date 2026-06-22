import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_test/features/auth/providers/auth_provider.dart';
import 'package:riverpod_test/features/favorites/screens/favorites_screen.dart';
import 'package:riverpod_test/features/navigation/screens/bottom_navigation_screen.dart';
import 'package:riverpod_test/features/products/models/product_model.dart';
import 'package:riverpod_test/features/auth/screens/login.dart';
import 'package:riverpod_test/features/auth/screens/splash_screen.dart';
import 'package:riverpod_test/features/products/screens/product_detail_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  return GoRouter(
    initialLocation: '/splash',

    redirect: (context, state) {
      final isLoggedIn = authState.value != null;

      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      if (isLoggedIn && isLoggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/home',
        builder: (context, state) => const BottomNavigationScreen(),
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) {
          return FavoritesScreen();
        },
      ),
      GoRoute(
        path: '/product-detail',
        builder: (context, state) {
          final product = state.extra as ProductModel;
          return ProductDetailScreen(product: product);
        },
      ),
    ],
  );
});
