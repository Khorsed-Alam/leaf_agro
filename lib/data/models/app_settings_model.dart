class AppSettingsModel {
  final String language; // 'en' or 'bn'
  final String themeMode; // 'system', 'light', 'dark'
  final bool offlineOnlyMode;
  final bool autoSyncWhenOnline;
  final bool notificationsEnabled;
  final bool plantCareReminders;
  final bool detectionAlerts;

  const AppSettingsModel({
    this.language = 'en',
    this.themeMode = 'system',
    this.offlineOnlyMode = false,
    this.autoSyncWhenOnline = true,
    this.notificationsEnabled = true,
    this.plantCareReminders = true,
    this.detectionAlerts = true,
  });

  bool get isDarkMode => themeMode == 'dark';

  AppSettingsModel copyWith({
    String? language,
    String? themeMode,
    bool? isDarkMode,
    bool? offlineOnlyMode,
    bool? autoSyncWhenOnline,
    bool? notificationsEnabled,
    bool? plantCareReminders,
    bool? detectionAlerts,
  }) {
    return AppSettingsModel(
      language: language ?? this.language,
      themeMode: themeMode ??
          (isDarkMode != null ? (isDarkMode ? 'dark' : 'light') : this.themeMode),
      offlineOnlyMode: offlineOnlyMode ?? this.offlineOnlyMode,
      autoSyncWhenOnline: autoSyncWhenOnline ?? this.autoSyncWhenOnline,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      plantCareReminders: plantCareReminders ?? this.plantCareReminders,
      detectionAlerts: detectionAlerts ?? this.detectionAlerts,
    );
  }
}
