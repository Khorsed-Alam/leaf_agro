class AppConstants {
  static const String appName = 'AgriCare AI';
  static const String appVersion = '1.0.0';

  // AI Inference specifications
  static const int modelInputSize = 224;
  static const String tfliteModelAsset = 'assets/models/plant_disease_model.tflite';
  static const String labelsAsset = 'assets/models/labels.json';
  static const String metadataAsset = 'assets/models/model_metadata.json';

  // Default Confidence Threshold
  static const double confidenceThreshold = 0.65;

  // Local Storage Keys
  static const String keyUserToken = 'user_token';
  static const String keyLanguage = 'preferred_language';
  static const String keyIsFirstLaunch = 'is_first_launch';
  static const String keyOfflineHistory = 'offline_history';
}

