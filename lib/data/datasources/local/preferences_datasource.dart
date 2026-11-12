import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

class PreferencesDataSource {
  final SharedPreferences _prefs;
  PreferencesDataSource(this._prefs);

  String getLanguage() {
    return _prefs.getString(AppConstants.keyLanguage) ?? 'en';
  }

  Future<void> setLanguage(String code) async {
    await _prefs.setString(AppConstants.keyLanguage, code);
  }

  bool isFirstLaunch() {
    return _prefs.getBool(AppConstants.keyIsFirstLaunch) ?? true;
  }

  Future<void> setFirstLaunchComplete() async {
    await _prefs.setBool(AppConstants.keyIsFirstLaunch, false);
  }
}

