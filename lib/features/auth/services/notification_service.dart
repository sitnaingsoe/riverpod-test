import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static Future<void> initialize() async {
    const InitializationSettings initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _notificationsPlugin.initialize(settings: initSettings);
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  static Future<void> showOtpNotification(String otpCode) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'otp_channel_id_v3', // Channel ID
          'OTP Verification', // Channel Name
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          playSound: true,
        );
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(presentSound: true),
    );
    await _notificationsPlugin.show(
      id: 0,
      title: 'Your Verification Code',
      body: '🔒 $otpCode is your OTP. Do not share it with anyone.',
      notificationDetails: platformDetails,
    );
  }
}
