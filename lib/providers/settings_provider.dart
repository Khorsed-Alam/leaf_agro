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
          ),
        );

  Future<void> setLanguage(String code) async {
    await _prefs.setString(AppConstants.keyLanguage, code);
    state = state.copyWith(language: code);
  }

  void toggleDarkMode(bool enabled) {
    state = state.copyWith(isDarkMode: enabled);
  }

  void toggleOfflineOnly(bool enabled) {
    state = state.copyWith(offlineOnlyMode: enabled);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettingsModel>((ref) {
  return SettingsNotifier(ref.watch(sharedPreferencesProvider));
});

