import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_test/features/auth/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController(text: 'sitnaingsoe@gmail.com');
  final _passwordController = TextEditingController(text: 'sit123');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AsyncValue>(authProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          final errorString = error.toString();
          String errorMessage = 'Login failed. Please try again.';

          if (errorString.contains('user-not-found') ||
              errorString.contains('no user record')) {
            errorMessage = 'Account not found! Please register first.';
          } else if (errorString.contains('wrong-password') ||
              errorString.contains('INVALID_LOGIN_CREDENTIALS')) {
            errorMessage = 'Incorrect password. Please try again.';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        data: (user) {
          if (user != null) {
            Navigator.pushReplacementNamed(context, '/home');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login Success!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      );
    });
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.lock, size: 80, color: Colors.teal),
                const SizedBox(height: 16),
                const Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to continue',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email must be filled';
                    }
                    if (!value.contains('@')) return 'Invalid Email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                    hintText: 'emilyspass',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter Password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                authState.maybeMap(
                  loading: (_) => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(color: Colors.teal),
                    ),
                  ),
                  orElse: () => ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final email = _emailController.text.trim();
                        final password = _passwordController.text.trim();

                        try {
                          await ref
                              .read(authProvider.notifier)
                              .login(email, password);
                        } catch (e) {
                          e.toString();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),

                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),

                      elevation: 3,
                      // ignore: deprecated_member_use
                      shadowColor: Colors.teal.withOpacity(0.4),

                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'LOGIN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/register');
                  },
                  child: const Text('Do you want to register? Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
