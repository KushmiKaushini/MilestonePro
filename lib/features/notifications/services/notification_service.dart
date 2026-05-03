import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> requestPermissions() async {
    final androidImplementation = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (details) {},
    );

    // Create notification channel for Android 8.0+
    await _createNotificationChannel();
  }

  Future<void> _createNotificationChannel() async {
    final androidImplementation = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      final channel = AndroidNotificationChannel(
        'goal_reminders',
        'Goal Reminders',
        description: 'Notifications for your milestones',
        importance: Importance.max,
        showBadge: true,
      );
      await androidImplementation.createNotificationChannel(channel);
    }
  }

  Future<void> scheduleGoalReminder(int id, String title, DateTime scheduledDate) async {
    // Check notification permissions before scheduling
    final androidImplementation = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      final granted = await androidImplementation.areNotificationsEnabled();
      if (granted == false) {
        return; // Don't schedule if permissions not granted
      }
    }

    await _notifications.zonedSchedule(
      id: id,
      title: 'Milestone Pro',
      body: 'Don\'t forget your goal: $title',
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'goal_reminders',
          'Goal Reminders',
          channelDescription: 'Notifications for your milestones',
          importance: Importance.max,
          showWhen: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
