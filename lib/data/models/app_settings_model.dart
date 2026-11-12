class AppSettingsModel {
  final String language; // 'en' or 'bn'
  final bool isDarkMode;
  final bool offlineOnlyMode;
  final bool autoSyncWhenOnline;

  const AppSettingsModel({
    this.language = 'en',
    this.isDarkMode = false,
    this.offlineOnlyMode = false,
    this.autoSyncWhenOnline = true,
  });

  AppSettingsModel copyWith({
    String? language,
    bool? isDarkMode,
    bool? offlineOnlyMode,
    bool? autoSyncWhenOnline,
  }) {
    return AppSettingsModel(
      language: language ?? this.language,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      offlineOnlyMode: offlineOnlyMode ?? this.offlineOnlyMode,
      autoSyncWhenOnline: autoSyncWhenOnline ?? this.autoSyncWhenOnline,
    );
  }
}

