import 'package:isar/isar.dart';

part 'app_settings.g.dart';

@collection
class AppSettings {
  Id id = Isar.autoIncrement;

  bool hasCompletedOnboarding = false;
  
  // Potential future settings
  bool notificationsEnabled = true;
  String? themeMode; // light, dark, system
}
