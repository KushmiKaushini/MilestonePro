import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'core/services/database_service.dart';
import 'features/notifications/services/notification_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Timezones for notifications
  tz.initializeTimeZones();

  // Initialize Notification Service
  await NotificationService.instance.initialize();
  await NotificationService.instance.requestPermissions();

  // Initialize Database
  await DatabaseService.initialize();

  runApp(
    const ProviderScope(
      child: MilestoneProApp(),
    ),
  );
}
