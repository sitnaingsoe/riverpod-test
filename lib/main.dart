import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_test/features/auth/models/auth_model.dart';
import 'package:riverpod_test/features/auth/screens/otp_verification_screen.dart';
import 'package:riverpod_test/features/auth/screens/profile_setup_screen.dart';
import 'package:riverpod_test/features/auth/screens/register_screen.dart';
import 'package:riverpod_test/features/auth/services/notification_service.dart';
import 'package:riverpod_test/features/favorites/screens/favorites_screen.dart';
import 'package:riverpod_test/features/orders/screens/orders_history_screen.dart';
import 'package:riverpod_test/features/products/models/product_model.dart';
import 'package:riverpod_test/features/auth/screens/login.dart';
import 'package:riverpod_test/features/auth/screens/splash_screen.dart';
import 'package:riverpod_test/features/navigation/screens/bottom_navigation_screen.dart';
import 'package:riverpod_test/features/products/screens/product_detail_screen.dart';
import 'package:riverpod_test/features/profile/models/address_model.dart';
import 'package:riverpod_test/features/profile/screens/address_screen.dart';
import 'package:riverpod_test/features/profile/screens/edit_profile_screen.dart';
import 'package:riverpod_test/features/profile/screens/map_setup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    throw (("❌ Firebase initialization failed: $e"));
  }
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(AuthModelAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(AddressModelAdapter());
  }
  await Hive.openBox('orders_box');
  await Hive.openBox('user_addresses_box');
  await Hive.openBox('user_cart_box');
  await Hive.openBox<ProductModel>('products_box');
  await Hive.openBox('user_favorites_box');
  await Hive.openBox('authBox');
  await Hive.openBox('offline_tasks_queue');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'My Store',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const BottomNavigationScreen(),
        '/favorite': (context) => const FavoritesScreen(),
        '/product-detail': (context) => const ProductDetailScreen(),
        '/history-order': (context) => const OrdersHistoryScreen(),
        '/profile-setup': (context) => const ProfileSetupScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/map-setup': (context) => const MapSetupScreen(),
        '/address': (context) => const AddressScreen(),
        '/otp-verification': (context) => const OtpVerificationScreen(),
      },
    );
  }
}
