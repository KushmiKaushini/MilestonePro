import 'package:isar/isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/isar_service.dart';
import '../models/app_settings.dart';

final settingsRepositoryProvider = Provider<SettingsRepository?>((ref) {
  return ref.watch(isarProvider).whenOrNull(data: SettingsRepository.new);
});

class SettingsRepository {
  const SettingsRepository(this._isar);
  final Isar _isar;

  Future<AppSettings> getSettings() async {
    final settings = await _isar.appSettings.where().findFirst();
    if (settings != null) return settings;
    
    // Create default
    final newSettings = AppSettings();
    await _isar.writeTxn(() => _isar.appSettings.put(newSettings));
    return newSettings;
  }

  Future<void> updateOnboardingCompleted(bool value) async {
    final settings = await getSettings();
    settings.hasCompletedOnboarding = value;
    await _isar.writeTxn(() => _isar.appSettings.put(settings));
  }
}

final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(settingsRepositoryProvider);
  if (repo == null) return false;
  final settings = await repo.getSettings();
  return settings.hasCompletedOnboarding;
});
