// ignore_for_file: curly_braces_in_flow_control_structures, deprecated_member_use, use_build_context_synchronously, unused_local_variable, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_test/features/auth/providers/auth_provider.dart';
import 'package:riverpod_test/features/auth/providers/otp_provider.dart';
import 'package:riverpod_test/features/auth/services/notification_service.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({
    super.key,
  }); // 💡 Typo 'RegisterScreeen' ကို ပြင်ဆင်ထားပါသည်
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'test4@gmail.com');
  final _passwordController = TextEditingController(text: 'sit123');
  final _usernameController = TextEditingController(text: 'sitnaing');
  final _firstNameController = TextEditingController(text: 'sitnaing');
  final _lastNameController = TextEditingController(text: 'soe');
  final _genderController = TextEditingController(text: 'male');

  String _selectedGender = 'Male';
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.teal.shade600, size: 22),
      labelStyle: TextStyle(color: Colors.blueGrey.shade600),
      floatingLabelStyle: const TextStyle(
        color: Colors.teal,
        fontWeight: FontWeight.bold,
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.teal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(authProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration Failed ${error.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        data: (user) {
          if (user != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(' Successful Account Created! '),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 24.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_add_rounded,
                      size: 56,
                      color: Colors.teal.shade400,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Create an Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign up to get started',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  const SizedBox(height: 36),

                  TextFormField(
                    controller: _usernameController,
                    decoration: _buildInputDecoration(
                      'Username',
                      Icons.account_circle_outlined,
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter your username'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstNameController,
                          decoration: _buildInputDecoration(
                            'First Name',
                            Icons.badge_outlined,
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Required'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _lastNameController,
                          decoration: _buildInputDecoration(
                            'Last Name',
                            Icons.badge_outlined,
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Required'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: _buildInputDecoration(
                      'Gender',
                      Icons.wc_outlined,
                    ),
                    items: ['Male', 'Female', 'Other'].map((String gender) {
                      return DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedGender = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _buildInputDecoration(
                      'Email Address',
                      Icons.email_outlined,
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter your email';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value))
                        return 'Please enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: _buildInputDecoration(
                      'Password',
                      Icons.lock_outline,
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter your password';
                      if (value.length < 6)
                        return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                final email = _emailController.text.trim();

                                setState(() {
                                  _isLoading = true;
                                });

                                try {
                                  final isExist = await ref
                                      .read(authProvider.notifier)
                                      .checkEmailExists(
                                        email,
                                        _passwordController.text.trim(),
                                      );

                                  if (isExist) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          '⚠️ This email is already registered! Please login.',
                                        ),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    return;
                                  }

                                  ref
                                      .read(tempRegisterProvider.notifier)
                                      .state = {
                                    // Ensure this matches your provider name
                                    'email': _emailController.text.trim(),
                                    'password': _passwordController.text.trim(),
                                    'username': _usernameController.text.trim(),
                                    'firstName': _firstNameController.text
                                        .trim(),
                                    'lastName': _lastNameController.text.trim(),
                                    'gender': _selectedGender,
                                    'image': '',
                                  };

                                  final newOtp = ref
                                      .read(otpProvider.notifier)
                                      .generateOtp();
                                  NotificationService.showOtpNotification(
                                    newOtp,
                                  );

                                  setState(() {
                                    _isLoading = false;
                                  });

                                  Navigator.pushNamed(
                                    context,
                                    '/otp-verification',
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('🌐 $e'),
                                      backgroundColor: Colors.orange.shade800,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        disabledBackgroundColor: Colors.teal.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            Navigator.pushNamed(context, '/login');
                          },
                    child: Text.rich(
                      TextSpan(
                        text: "Already have an account? ",
                        style: const TextStyle(color: Colors.grey),
                        children: [
                          TextSpan(
                            text: "Login",
                            style: TextStyle(
                              color: Colors.teal.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
