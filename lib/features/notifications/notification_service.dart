import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../core/utils/constants.dart';

/// Singleton notification service.
///
/// Call [initialize] once in [main] before [runApp].
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Deep-link payload router — set by the app after startup.
  static void Function(String payload)? onNotificationTap;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      final success = await _plugin.initialize(
        settings: const InitializationSettings(android: androidInit, iOS: iosInit),
        onDidReceiveNotificationResponse: _handleTap,
        onDidReceiveBackgroundNotificationResponse: _backgroundTapHandler,
      );

      if (success == true) {
        if (Platform.isAndroid) {
          await _createChannels();
        }
        _initialized = true;
      }
    } catch (e) {
      debugPrint('NotificationService: Failed to initialize: $e');
    }
  }

  // ── Channels ────────────────────────────────────────────────────────────────

  Future<void> _createChannels() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        AppConstants.reminderChannelId,
        'Milestone Reminders',
        description: 'Reminders for upcoming milestones',
        importance: Importance.high,
        enableVibration: true,
      ),
    );

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        AppConstants.streakChannelId,
        'Streak Alerts',
        description: 'Escalating alerts to protect your streaks',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
      ),
    );

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        AppConstants.criticalChannelId,
        'Critical Alarms',
        description: 'Unmissable alarms for critical milestones',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
        showBadge: true,
      ),
    );
  }

  // ── Scheduling ───────────────────────────────────────────────────────────────

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String channelId = AppConstants.reminderChannelId,
    String? payload,
    bool fullScreen = false,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelId == AppConstants.criticalChannelId
          ? 'Critical Alarms'
          : 'Milestone Reminders',
      channelDescription: 'Milestone Pro notifications',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: fullScreen,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails:
          NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> showImmediate({
    required int id,
    required String title,
    required String body,
    String channelId = AppConstants.reminderChannelId,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      'Milestone Pro',
      importance: Importance.max,
      priority: Priority.max,
    );
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(android: androidDetails),
      payload: payload,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id: id);
  Future<void> cancelAll() => _plugin.cancelAll();

  // ── Permissions ───────────────────────────────────────────────────────────

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await androidPlugin?.requestNotificationsPermission() ?? false;
    }
    if (Platform.isIOS) {
      final iosPlugin = _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      return await iosPlugin?.requestPermissions(
              alert: true, badge: true, sound: true) ??
          false;
    }
    return false;
  }

  // ── Handlers ─────────────────────────────────────────────────────────────

  void _handleTap(NotificationResponse response) {
    if (response.payload != null) {
      onNotificationTap?.call(response.payload!);
    }
  }
}

@pragma('vm:entry-point')
void _backgroundTapHandler(NotificationResponse response) {
  // Background isolate: cannot use most Flutter APIs.
  // Simply mark handled; the foreground handler will fire on next launch.
}
