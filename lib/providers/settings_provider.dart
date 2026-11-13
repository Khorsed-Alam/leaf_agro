import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../data/models/app_settings_model.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize via ProviderScope overrides in main.dart');
});

class SettingsNotifier extends StateNotifier<AppSettingsModel> {
  final SharedPreferences _prefs;

  SettingsNotifier(this._prefs)
      : super(
          AppSettingsModel(
            language: _prefs.getString(AppConstants.keyLanguage) ?? 'en',
            themeMode: _prefs.getString(AppConstants.keyThemeMode) ?? 'system',
            notificationsEnabled:
                _prefs.getBool(AppConstants.keyNotificationsEnabled) ?? true,
            plantCareReminders:
                _prefs.getBool(AppConstants.keyPlantCareReminders) ?? true,
            detectionAlerts:
                _prefs.getBool(AppConstants.keyDetectionAlerts) ?? true,
            offlineOnlyMode:
                _prefs.getBool(AppConstants.keyOfflineOnlyMode) ?? false,
          ),
        );

  Future<void> setLanguage(String code) async {
    await _prefs.setString(AppConstants.keyLanguage, code);
    state = state.copyWith(language: code);
  }

  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(AppConstants.keyThemeMode, mode);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> toggleDarkMode(bool enabled) async {
    final mode = enabled ? 'dark' : 'light';
    await setThemeMode(mode);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(AppConstants.keyNotificationsEnabled, enabled);
    state = state.copyWith(notificationsEnabled: enabled);
  }

  Future<void> setPlantCareReminders(bool enabled) async {
    await _prefs.setBool(AppConstants.keyPlantCareReminders, enabled);
    state = state.copyWith(plantCareReminders: enabled);
  }

  Future<void> setDetectionAlerts(bool enabled) async {
    await _prefs.setBool(AppConstants.keyDetectionAlerts, enabled);
    state = state.copyWith(detectionAlerts: enabled);
  }

  Future<void> toggleOfflineOnly(bool enabled) async {
    await _prefs.setBool(AppConstants.keyOfflineOnlyMode, enabled);
    state = state.copyWith(offlineOnlyMode: enabled);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettingsModel>((ref) {
  return SettingsNotifier(ref.watch(sharedPreferencesProvider));
});
