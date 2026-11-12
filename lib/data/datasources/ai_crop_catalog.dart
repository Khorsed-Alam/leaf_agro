import '../models/crop_model.dart';

/// Single source of truth for crops supported by the MobileNetV2 AI model
/// (assets/models/plant_disease_model.tflite, labels.json, model_metadata.json).
class AiCropCatalog {
  /// The 5 verified crop categories supported by the trained TensorFlow Lite model.
  static const List<String> supportedCropNames = [
    'Rice',
    'Potato',
    'Tomato',
    'Mango',
    'Jute',
  ];

  /// Number of disease classes trained per crop in labels.json
  static const Map<String, int> cropDiseaseCounts = {
    'Rice': 4, // Bacterial leaf blight, Brown spot, Leaf smut, healthy
    'Potato': 3, // Early blight, Late blight, healthy
    'Tomato': 6, // Bacterial spot, Early blight, Late blight, Leaf Mold, Septoria leaf spot, healthy
    'Mango': 3, // Anthracnose, Bacterial canker, healthy
    'Jute': 3, // Stem rot, Anthracnose, healthy
  };

  /// High quality, realistic crop imagery representing verified Bangladeshi crops
  static const List<CropModel> verifiedSupportedCrops = [
    CropModel(
      id: 1,
      nameEn: 'Rice',
      nameBn: 'ধান',
      descriptionEn: 'Golden staple paddy grain of Bangladesh, cultivated in Aus, Aman, and Boro seasons.',
      descriptionBn: 'বাংলাদেশের প্রধান খাদ্যশস্য, আউশ, আমন ও বোরো মৌসুমে ব্যাপকভাবে চাষ হয়।',
      imageUrl: 'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6',
      isActive: true,
    ),
    CropModel(
      id: 2,
      nameEn: 'Potato',
      nameBn: 'আলু',
      descriptionEn: 'High-yield tuber crop widely cultivated in Munshiganj, Bogura, and Rangpur.',
      descriptionBn: 'মুন্সীগঞ্জ ও বগুড়া অঞ্চলে প্রধান কন্দজাতীয় ফসল।',
      imageUrl: 'https://images.unsplash.com/photo-1518977676601-b53f82aba655',
      isActive: true,
    ),
    CropModel(
      id: 3,
      nameEn: 'Tomato',
      nameBn: 'টমেটো',
      descriptionEn: 'Popular nutrient-rich vegetable cultivated during winter and summer seasons.',
      descriptionBn: 'শীত ও গ্রীষ্মকালীন মৌসুমে সারা দেশে ব্যাপকভাবে চাষকৃত জনপ্রিয় সবজি।',
      imageUrl: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea',
      isActive: true,
    ),
    CropModel(
      id: 4,
      nameEn: 'Mango',
      nameBn: 'আম',
      descriptionEn: 'The King of Fruits, extensively grown in Rajshahi, Chapainawabganj, and Satkhira.',
      descriptionBn: 'ফলের রাজা, রাজশাহী ও চাঁপাইনবাবগঞ্জ অঞ্চলে প্রধান অর্থকরী ফল।',
      imageUrl: 'https://images.unsplash.com/photo-1553279768-865429fa0078',
      isActive: true,
    ),
    CropModel(
      id: 5,
      nameEn: 'Jute',
      nameBn: 'পাট',
      descriptionEn: 'The Golden Fibre of Bangladesh, historic commercial cash crop with high economic value.',
      descriptionBn: 'বাংলাদেশের সোনালী আঁশ, অন্যতম প্রধান ঐতিহ্যবাহী বাণিজ্যিক অর্থকরী ফসল।',
      imageUrl: 'https://images.unsplash.com/photo-1600681932179-c32278da47f9',
      isActive: true,
    ),
  ];

  /// Checks if a crop name is supported by the on-device AI model.
  static bool isSupported(String cropName) {
    return supportedCropNames.any(
      (name) => name.toLowerCase() == cropName.trim().toLowerCase(),
    );
  }

  /// Returns the number of detectable diseases for a supported crop.
  static int getDiseaseCount(String cropName) {
    for (final entry in cropDiseaseCounts.entries) {
      if (entry.key.toLowerCase() == cropName.trim().toLowerCase()) {
        return entry.value;
      }
    }
    return 0;
  }
}

