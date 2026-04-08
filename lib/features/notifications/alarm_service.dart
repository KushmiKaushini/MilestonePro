import 'dart:ui';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../core/utils/constants.dart';

/// Wraps [AndroidAlarmManager] to schedule "unmissable" background alarms.
///
/// On Android, the alarm fires even when the app is completely terminated.
/// The [_alarmCallback] top-level function is invoked in a background isolate.
class AlarmService {
  AlarmService._();
  static final AlarmService instance = AlarmService._();

  Future<void> initialize() async {
    await AndroidAlarmManager.initialize();
  }

  /// Schedule a one-shot exact alarm.
  ///
  /// [id] must be unique per alarm (use milestone Isar id).
  /// [milestoneUid] is passed via [params] to the isolate callback.
  Future<void> scheduleAlarm({
    required int id,
    required DateTime alarmTime,
    required String milestoneTitle,
    required String milestoneUid,
    bool requiresPuzzle = false,
  }) async {
    await AndroidAlarmManager.oneShotAt(
      alarmTime,
      id,
      _alarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
      params: {
        'milestoneUid': milestoneUid,
        'title': milestoneTitle,
        'requiresPuzzle': requiresPuzzle,
      },
    );
  }

  Future<void> cancelAlarm(int id) async {
    await AndroidAlarmManager.cancel(id);
  }
}

/// Top-level callback — runs in a separate background isolate.
@pragma('vm:entry-point')
Future<void> _alarmCallback(int id, Map<String, dynamic>? params) async {
  // We need to init the Flutter engine in this isolate.
  DartPluginRegistrant.ensureInitialized();

  final title = params?['title'] as String? ?? 'Milestone Alarm';
  final milestoneUid = params?['milestoneUid'] as String? ?? '';
  final requiresPuzzle = params?['requiresPuzzle'] as bool? ?? false;

  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );

  final androidDetails = AndroidNotificationDetails(
    AppConstants.criticalChannelId,
    'Critical Alarms',
    channelDescription: 'Unmissable milestone alarms',
    importance: Importance.max,
    priority: Priority.max,
    fullScreenIntent: true,
    category: AndroidNotificationCategory.alarm,
    visibility: NotificationVisibility.public,
    enableVibration: true,
    ongoing: requiresPuzzle, // Persistent until dismissed with puzzle
    autoCancel: !requiresPuzzle,
  );

  await plugin.show(
    id,
    '⏰ $title',
    requiresPuzzle
        ? 'Solve a quick challenge to dismiss this alarm.'
        : 'Tap to mark your milestone progress.',
    NotificationDetails(android: androidDetails),
    payload: 'alarm:$milestoneUid:${requiresPuzzle ? "puzzle" : "simple"}',
  );
}
