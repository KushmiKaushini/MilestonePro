import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'app.dart';
import 'features/notifications/notification_service.dart';

/// Top-level callback entry-point for NotificationService background taps.
@pragma('vm:entry-point')
void notificationTapBackground(dynamic details) {}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Timezone data (required by flutter_local_notifications) ──────────────
  tz.initializeTimeZones();

  // ── Notification service ──────────────────────────────────────────────────
  await NotificationService.instance.initialize();

  runApp(
    const ProviderScope(
      child: MilestoneProApp(),
    ),
  );
}
