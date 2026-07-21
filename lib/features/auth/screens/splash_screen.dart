import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_test/features/auth/services/auth_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
    _checkAuth();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted || !context.mounted) return;
    bool isAuthenticated = false;

    try {
      isAuthenticated = await _authService.checkAndRefreshAuth().timeout(
        const Duration(seconds: 5),
      );
    } catch (e) {
      debugPrint("Offline or Auth check timed out: $e");
    }

    if (!mounted || !context.mounted) return;

    if (isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF00796B), // Deep Teal
              Color(0xFF004D40), // Darker Teal
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          size: 90,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'MY  Shop',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 3.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your ultimate shopping partner',
                        style: TextStyle(
                          fontSize: 14,
                          // ignore: deprecated_member_use
                          color: Colors.white.withOpacity(0.7),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    SizedBox(
                      width: 120,
                      child: LinearProgressIndicator(
                        // ignore: deprecated_member_use
                        backgroundColor: Colors.white.withOpacity(0.2),
                        color: Colors.white,
                        minHeight: 3,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'v 1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'POWERED BY YOUR BRAND',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.6),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
