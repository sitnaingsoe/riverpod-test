// ignore_for_file: unused_field

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:riverpod_test/features/auth/providers/auth_provider.dart';
import 'package:riverpod_test/features/auth/providers/otp_provider.dart';
import 'package:riverpod_test/features/auth/services/notification_service.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  String? _pinErrorText;
  bool _isOtpSent = true;

  Timer? _timer;
  int _remainingSeconds = 0;
  final int _otpValidDuration = 60;

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = _otpValidDuration;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  Future<bool> _hasInternet() async {
    final connectivityResults = await Connectivity().checkConnectivity();
    final isOffline = connectivityResults.contains(ConnectivityResult.none);

    if (isOffline) {
      return false;
    }

    return true;
  }

  String get _formattedTime {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _requestOtp() async {
    if (!await _hasInternet()) {
      _showMessage(
        '🌐 No internet connection. Please try again.',
        Colors.orange.shade800,
      );
      return;
    }
    final newOtp = ref.read(otpProvider.notifier).generateOtp();
    NotificationService.showOtpNotification(newOtp);
    setState(() {
      _isOtpSent = true;
    });
    _startTimer();
    _showMessage('OTP sent successfully!', Colors.teal);
  }

  void _verifyAndRegister() async {
    if (!await _hasInternet()) {
      _showMessage(
        '🌐 No internet connection. Please try again.',
        Colors.redAccent.shade100,
      );
      setState(() {
        _pinErrorText = '🌐 No internet connection. Please try again.';
      });
      return;
    }
    setState(() {
      _pinErrorText = null;
    });
    if (ref.read(otpProvider.notifier).isExpired()) {
      _showMessage(
        'Your OTP has expired. Please request a new one.',
        Colors.red,
      );
      ref.read(otpProvider.notifier).clearOtp();
      _otpController.clear();
      setState(() {
        _remainingSeconds = 0;
      });
      _timer?.cancel();
      return;
    }

    final enteredOtp = _otpController.text.trim();
    final savedOtp = ref.read(otpProvider);
    final tempRegData = ref.read(tempRegisterProvider);

    if (savedOtp == null || tempRegData == null) {
      _showMessage('Please request an OTP first.', Colors.orange);
      return;
    }

    if (enteredOtp.length < 6) {
      _showMessage('Please enter the full 6-digit OTP.', Colors.orange);
      return;
    }

    if (enteredOtp == savedOtp) {
      ref
          .read(authProvider.notifier)
          .register(
            email: tempRegData['email'],
            password: tempRegData['password'],
            username: tempRegData['username'],
            firstName: tempRegData['firstName'],
            lastName: tempRegData['lastName'],
            gender: tempRegData['gender'],
            image: tempRegData['image'],
          );
    } else {
      _showMessage("Invalid OTP. Please try again.", Colors.red);
      _otpController.clear();
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    ref.watch(otpProvider);
    ref.watch(tempRegisterProvider);
    ref.listen<AsyncValue>(authProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          _showMessage("Registration Failed : $error", Colors.red);
        },
        data: (user) {
          if (user != null) {
            _showMessage("Account Created Successfully!", Colors.green);
            ref.read(otpProvider.notifier).clearOtp();
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/profile-setup',
              (route) => false,
            );
          }
        },
      );
    });

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Verification'),
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mark_email_read_outlined,
                    size: 64,
                    color: Colors.teal.shade400,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Enter Verification Code',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _isOtpSent
                      ? 'We have sent a 6-digit code to your device.\nPlease enter it below.'
                      : 'Tap the button below to generate your one-time password.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                if (_isOtpSent) ...[
                  Pinput(
                    length: 6,
                    controller: _otpController,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        border: Border.all(color: Colors.teal, width: 2),
                      ),
                    ),
                    submittedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        color: Colors.teal.shade50,
                        border: Border.all(color: Colors.teal.shade200),
                      ),
                    ),
                    errorPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        color: Colors.red.shade100,
                        border: Border.all(color: Colors.redAccent, width: 2),
                      ),
                    ),

                    forceErrorState: _pinErrorText != null,
                    onChanged: (value) {
                      if (_pinErrorText != null) {
                        setState(() {
                          _pinErrorText = null;
                        });
                      }
                    },
                    showCursor: true,
                    onCompleted: (pin) => _verifyAndRegister(),
                  ),
                  if (_pinErrorText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        _pinErrorText!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Didn't receive the code? ",
                        style: TextStyle(color: Colors.grey),
                      ),
                      if (_remainingSeconds > 0)
                        Text(
                          _formattedTime,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      else
                        InkWell(
                          onTap: _requestOtp,
                          child: Text(
                            "Resend",
                            style: TextStyle(
                              color: Colors.teal.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: authState.isLoading
                          ? null
                          : _verifyAndRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        disabledBackgroundColor: Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: authState.isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Verify & Create Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
