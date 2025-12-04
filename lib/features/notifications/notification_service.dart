// lib/features/notifications/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

/// Push Notification Service
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize notifications
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Show transaction notification
  Future<void> showTransactionNotification({
    required String title,
    required String body,
    required String transactionSignature,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'transactions',
      'Transactions',
      channelDescription: 'Transaction notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      transactionSignature.hashCode,
      title,
      body,
      details,
      payload: transactionSignature,
    );
  }

  /// Show price alert notification
  Future<void> showPriceAlert({
    required String token,
    required double price,
    required String direction,
  }) async {
    await _notifications.show(
      token.hashCode,
      'Price Alert: $token',
      '$token is $direction \$$price',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'price_alerts',
          'Price Alerts',
          channelDescription: 'Token price alerts',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// Show security alert
  Future<void> showSecurityAlert({
    required String title,
    required String message,
  }) async {
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch,
      title,
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'security',
          'Security Alerts',
          channelDescription: 'Security and account alerts',
          importance: Importance.max,
          priority: Priority.max,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      // Navigate to transaction details or relevant screen
      print('Notification tapped: $payload');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Cancel specific notification
  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }
}
