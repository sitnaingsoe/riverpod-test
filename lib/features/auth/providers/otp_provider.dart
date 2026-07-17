// ignore_for_file: unused_field

import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtpNotifier extends Notifier<String?> {
  DateTime? _expiryTime;
  @override
  String? build() {
    return null;
  }

  String generateOtp() {
    final random = Random();
    final otpCode = (100000 + random.nextInt(900000)).toString();
    _expiryTime = DateTime.now().add(const Duration(minutes: 1));
    state = otpCode;
    return otpCode;
  }

  bool isExpired() {
    if (_expiryTime == null) return true;
    return DateTime.now().isAfter(_expiryTime!);
  }

  void clearOtp() {
    state = null;
    _expiryTime = null;
  }
}

final otpProvider = NotifierProvider<OtpNotifier, String?>(() {
  return OtpNotifier();
});
