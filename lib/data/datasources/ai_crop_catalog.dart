import 'package:flutter/material.dart';
import '../models/crop_model.dart';
import '../models/disease_model.dart';
import '../models/recommendation_model.dart';

/// Agronomic profile metadata for crops verified in Bangladesh
class CropProfile {
  final int cropId;
  final String categoryEn;
  final String categoryBn;
  final String growingSeasonEn;
  final String growingSeasonBn;
  final String waterRequirementEn;
  final String waterRequirementBn;
  final String sunlightRequirementEn;
  final String sunlightRequirementBn;
  final String soilPreferenceEn;
  final String soilPreferenceBn;
  final String growthDurationEn;
  final String growthDurationBn;

  const CropProfile({
    required this.cropId,
    required this.categoryEn,
    required this.categoryBn,
    required this.growingSeasonEn,
    required this.growingSeasonBn,
    required this.waterRequirementEn,
    required this.waterRequirementBn,
    required this.sunlightRequirementEn,
    required this.sunlightRequirementBn,
    required this.soilPreferenceEn,
    required this.soilPreferenceBn,
    required this.growthDurationEn,
    required this.growthDurationBn,
  });
}

/// Practical agricultural care tip for Bangladeshi farmers
class CropCareTip {
  final int id;
  final int cropId;
  final String categoryEn;
  final String categoryBn;
  final String titleEn;
  final String titleBn;
  final String descriptionEn;
  final String descriptionBn;
  final IconData icon;

  const CropCareTip({
    required this.id,
    required this.cropId,
    required this.categoryEn,
    required this.categoryBn,
    required this.titleEn,
    required this.titleBn,
    required this.descriptionEn,
    required this.descriptionBn,
    required this.icon,
  });
}

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
      descriptionEn: 'Rice is one of the most important staple crops in Bangladesh. Healthy crop management helps farmers improve yield and protect their fields.',
      descriptionBn: 'ধান বাংলাদেশের প্রধান খাদ্যশস্য। সঠিক পরিচর্যা ও রোগ নিয়ন্ত্রণ ফলন বৃদ্ধি ও ফসল সুরক্ষায় কার্যকর ভূমিকা রাখে।',
      imageUrl: 'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6',
      isActive: true,
    ),
    CropModel(
      id: 2,
      nameEn: 'Potato',
      nameBn: 'আলু',
      descriptionEn: 'High-yield tuber crop widely cultivated in Munshiganj, Bogura, and Rangpur during the winter Rabi season.',
      descriptionBn: 'মুন্সীগঞ্জ ও বগুড়া অঞ্চলে ব্যাপকভাবে উৎপাদিত প্রধান শীতকালীন কন্দজাতীয় অর্থকরী ফসল।',
      imageUrl: 'https://images.unsplash.com/photo-1518977676601-b53f82aba655',
      isActive: true,
    ),
    CropModel(
      id: 3,
      nameEn: 'Tomato',
      nameBn: 'টমেটো',
      descriptionEn: 'Popular nutrient-rich vegetable cultivated during winter and summer seasons across Bangladesh.',
      descriptionBn: 'শীত ও গ্রীষ্মকালীন মৌসুমে সারা দেশে ব্যাপকভাবে চাষকৃত জনপ্রিয় ও পুষ্টিকর সবজি।',
      imageUrl: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea',
      isActive: true,
    ),
    CropModel(
      id: 4,
      nameEn: 'Mango',
      nameBn: 'আম',
      descriptionEn: 'The King of Fruits, extensively grown in Rajshahi, Chapainawabganj, and Satkhira orchard belts.',
      descriptionBn: 'ফলের রাজা, রাজশাহী ও চাঁপাইনবাবগঞ্জ অঞ্চলে প্রধান বাণিজ্যিক ও অর্থকরী ফল।',
      imageUrl: 'https://images.unsplash.com/photo-1553279768-865429fa0078',
      isActive: true,
    ),
    CropModel(
      id: 5,
      nameEn: 'Jute',
      nameBn: 'পাট',
      descriptionEn: 'The Golden Fibre of Bangladesh, historic commercial cash crop with high economic and ecological value.',
      descriptionBn: 'বাংলাদেশের সোনালী আঁশ, অন্যতম প্রধান ঐতিহ্যবাহী বাণিজ্যিক অর্থকরী আঁশ ফসল।',
      imageUrl: 'https://images.unsplash.com/photo-1600681932179-c32278da47f9',
      isActive: true,
    ),
  ];

  /// Agronomic profiles for all 5 verified crops
  static const Map<int, CropProfile> verifiedProfiles = {
    1: CropProfile(
      cropId: 1,
      categoryEn: 'Cereal Grain',
      categoryBn: 'খাদ্যশস্য',
      growingSeasonEn: 'Aus, Aman, and Boro',
      growingSeasonBn: 'আউশ, আমন ও বোরো মৌসুম',
      waterRequirementEn: 'High (Standing water during tillering)',
      waterRequirementBn: 'প্রচুর পানি (কুশি পর্যায়ে ২-৩ ইঞ্চি পানি)',
      sunlightRequirementEn: 'Full Sun (6–8 hours daily)',
      sunlightRequirementBn: 'পূর্ণ সূর্যালোক (দৈনিক ৬-৮ ঘণ্টা)',
      soilPreferenceEn: 'Clay loam or silty clay',
      soilPreferenceBn: 'পলি ও এঁটেল দোআঁশ মাটি',
      growthDurationEn: '100 – 150 days',
      growthDurationBn: '১০০ – ১৫০ দিন',
    ),
    2: CropProfile(
      cropId: 2,
      categoryEn: 'Tuber Crop',
      categoryBn: 'কন্দজাতীয় ফসল',
      growingSeasonEn: 'Rabi / Winter (Nov – Mar)',
      growingSeasonBn: 'রবি / শীতকালীন (নভেম্বর - মার্চ)',
      waterRequirementEn: 'Moderate (Frequent light irrigation)',
      waterRequirementBn: 'পরিমিত সেচ (মাটিতে রস বজায় রাখা)',
      sunlightRequirementEn: 'Full Sun (6+ hours daily)',
      sunlightRequirementBn: 'পর্যাপ্ত রোদ (দৈনিক ৬+ ঘণ্টা)',
      soilPreferenceEn: 'Well-drained sandy loam, pH 5.5–6.5',
      soilPreferenceBn: 'উর্বর বেলে দোআঁশ মাটি, pH ৫.৫-৬.৫',
      growthDurationEn: '70 – 90 days',
      growthDurationBn: '৭০ – ৯০ দিন',
    ),
    3: CropProfile(
      cropId: 3,
      categoryEn: 'Solanaceous Vegetable',
      categoryBn: 'শাকসবজি',
      growingSeasonEn: 'Winter & Summer',
      growingSeasonBn: 'শীত ও গ্রীষ্মকালীন',
      waterRequirementEn: 'Moderate (Even moisture, avoid waterlogging)',
      waterRequirementBn: 'নিয়মিত সেচ (গোড়ায় পানি জমতে না দেওয়া)',
      sunlightRequirementEn: 'Direct Sunlight (6–8 hours)',
      sunlightRequirementBn: 'সরাসরি রোদ (৬-৮ ঘণ্টা)',
      soilPreferenceEn: 'Rich, organic sandy loam, pH 6.0–6.8',
      soilPreferenceBn: 'জৈব পদার্থ সমৃদ্ধ দোআঁশ মাটি, pH ৬.০-৬.৮',
      growthDurationEn: '90 – 120 days',
      growthDurationBn: '৯০ – ১২০ দিন',
    ),
    4: CropProfile(
      cropId: 4,
      categoryEn: 'Fruit Tree',
      categoryBn: 'ফলগাছ',
      growingSeasonEn: 'Summer Harvest (May – July)',
      growingSeasonBn: 'গ্রীষ্মকাল (বৈশাখ - আষাঢ়)',
      waterRequirementEn: 'Low to Moderate (Basin irrigation in fruit set)',
      waterRequirementBn: 'পরিমিত পানি (গুটি আসার পর রিং বেসিন সেচ)',
      sunlightRequirementEn: 'Full Sun (All day canopy light)',
      sunlightRequirementBn: 'উজ্জ্বল রোদ (ছাউনি মুক্ত আলো)',
      soilPreferenceEn: 'Deep alluvial, well-drained loam, pH 5.5–7.5',
      soilPreferenceBn: 'গভীর পলল দোআঁশ মাটি, pH ৫.৫-৭.৫',
      growthDurationEn: 'Perennial (Fruiting in 90–120 days)',
      growthDurationBn: 'বহুবর্ষজীবী (মুকুল থেকে ফল ৯০-১২০ দিন)',
    ),
    5: CropProfile(
      cropId: 5,
      categoryEn: 'Fibre Cash Crop',
      categoryBn: 'বাণিজ্যিক আঁশ ফসল',
      growingSeasonEn: 'Kharif-1 (March – August)',
      growingSeasonBn: 'খরিফ-১ (চৈত্র - আষাঢ়)',
      waterRequirementEn: 'High (Abundant monsoon rainfall)',
      waterRequirementBn: 'প্রচুর বৃষ্টিপাত ও আর্দ্রতা',
      sunlightRequirementEn: 'Intense Sunlight',
      sunlightRequirementBn: 'তীব্র সূর্যালোক',
      soilPreferenceEn: 'Fertile alluvial silt loam',
      soilPreferenceBn: 'পলল সমৃদ্ধ পলি দোআঁশ মাটি',
      growthDurationEn: '100 – 120 days',
      growthDurationBn: '১০০ – ১২০ দিন',
    ),
  };

  /// Verified field care tips for Bangladeshi agricultural conditions
  static const List<CropCareTip> verifiedCareTips = [
    // Rice Tips
    CropCareTip(
      id: 1,
      cropId: 1,
      categoryEn: 'Water Management',
      categoryBn: 'পানি ব্যবস্থাপনা',
      titleEn: 'Standing Water Depth',
      titleBn: 'জমিতে পানির উচ্চতা',
      descriptionEn: 'Maintain 2-3 inches of standing water during tillering and panicle initiation. Drain completely 10 days before harvest.',
      descriptionBn: 'কুশি ও থোর আসার সময় জমিতে ২-৩ ইঞ্চি পানি ধরে রাখুন। ধান কাটার ১০-১২ দিন পূর্বে জমির পানি সম্পূর্ণ বের করে দিন।',
      icon: Icons.water_drop_outlined,
    ),
    CropCareTip(
      id: 2,
      cropId: 1,
      categoryEn: 'Soil Care',
      categoryBn: 'মাটি ও সার ব্যবস্থাপনা',
      titleEn: 'Balanced Urea Application',
      titleBn: 'সুষম ইউরিয়া প্রয়োগ',
      descriptionEn: 'Apply urea in 3 equal splits to avoid excessive vegetative growth and decrease susceptibility to leaf blast and blight.',
      descriptionBn: 'ইউরিয়া সার সমান ৩ কিস্তিতে প্রয়োগ করুন। অতিরিক্ত ইউরিয়া ব্লাইট ও ব্লাস্ট রোগের ঝুঁকি বৃদ্ধি করে।',
      icon: Icons.eco_outlined,
    ),
    CropCareTip(
      id: 3,
      cropId: 1,
      categoryEn: 'Weed Control',
      categoryBn: 'আগাছা দমন',
      titleEn: 'Rotary Weeding & Cleaning',
      titleBn: 'আগাছা পরিষ্কার ও নিড়ানি',
      descriptionEn: 'Weed fields within 20-25 days of transplanting to eliminate alternative hosts for viral vectors.',
      descriptionBn: 'চারা রোপণের ২০-২৫ দিনের মধ্যে প্রথম নিড়ানি দিন এবং আইল পরিষ্কার রাখুন যাতে রোগের জীবাণু বিস্তার না ঘটে।',
      icon: Icons.grass_outlined,
    ),
    CropCareTip(
      id: 4,
      cropId: 1,
      categoryEn: 'Pest Monitoring',
      categoryBn: 'পোকা ও রোগ পর্যবেক্ষণ',
      titleEn: 'Daily Field Levee Inspection',
      titleBn: 'নিয়মিত জমি পরিদর্শন',
      descriptionEn: 'Inspect leaf blades in morning dew for water-soaked borders (bacterial blight) or spindle-shaped blast spots.',
      descriptionBn: 'সকালে শিশির ভেজা অবস্থায় পাতা পরীক্ষা করুন। বাদামী বা লম্বাটে দাগ দেখলে দ্রুত প্রতিরোধ ব্যবস্থা নিন।',
      icon: Icons.search_outlined,
    ),

    // Potato Tips
    CropCareTip(
      id: 5,
      cropId: 2,
      categoryEn: 'Soil Care',
      categoryBn: 'মাটি তোলা ও পরিচর্যা',
      titleEn: 'Timely Earthing Up',
      titleBn: 'গাছের গোড়ায় মাটি তোলা',
      descriptionEn: 'Earth up soil around potato stems at 30 and 50 days to shield growing tubers from sunlight greening and fungal spores.',
      descriptionBn: 'চারা গজানোর ৩০ ও ৫০ দিনে গাছের গোড়ায় মাটি তুলে দিন যাতে আলু সবুজ না হয় এবং রোগজীবাণু ভেতরে প্রবেশ করতে না পারে।',
      icon: Icons.landscape_outlined,
    ),
    CropCareTip(
      id: 6,
      cropId: 2,
      categoryEn: 'Water Management',
      categoryBn: 'সেচ ব্যবস্থাপনা',
      titleEn: 'Furrow Irrigation Control',
      titleBn: 'নালা সেচ নিয়ন্ত্রণ',
      descriptionEn: 'Irrigate inside furrows without submerging the ridges. Stop watering 10-14 days before harvest to firm tuber skin.',
      descriptionBn: 'নালার দুই-তৃতীয়াংশ উচ্চতায় সেচ দিন, বেড ডোবাবেন না। আলু তোলার ১০-১৪ দিন আগে সেচ বন্ধ রাখুন।',
      icon: Icons.water_drop_outlined,
    ),
    CropCareTip(
      id: 7,
      cropId: 2,
      categoryEn: 'Pest Monitoring',
      categoryBn: 'ধসা রোগ পর্যবেক্ষণ',
      titleEn: 'Late Blight Weather Alert',
      titleBn: 'কুয়াশাচ্ছন্ন আবহাওয়ায় সতর্কতা',
      descriptionEn: 'During persistent dense fog and high humidity, inspect lower foliage daily for water-soaked brown patches with white mold.',
      descriptionBn: 'টানা কুয়াশা ও স্যাঁতসেঁতে আবহাওয়ায় আলুর পাতার নিচে সাদা ছত্রাক ও পানিভেজা দাগ প্রতিদিন পরীক্ষা করুন।',
      icon: Icons.cloud_outlined,
    ),

    // Tomato Tips
    CropCareTip(
      id: 8,
      cropId: 3,
      categoryEn: 'Field Hygiene',
      categoryBn: 'খুঁটি ও মাচা তৈরি',
      titleEn: 'Staking & Trellising',
      titleBn: 'বাঁশের খুঁটি দেওয়া',
      descriptionEn: 'Stake growing plants with bamboo poles to keep leaves and fruit away from damp soil pathogens and improve ventilation.',
      descriptionBn: 'গাছ ২০-২৫ সেমি বড় হলে বাঁশের খুঁটি দিন, যাতে ভেজা মাটির ছত্রাক পাতায় না ছড়ায় এবং পর্যাপ্ত আলো-বাতাস পায়।',
      icon: Icons.vertical_align_top_outlined,
    ),
    CropCareTip(
      id: 9,
      cropId: 3,
      categoryEn: 'Water Management',
      categoryBn: 'সঠিক সেচ পদ্ধতি',
      titleEn: 'Base Watering Only',
      titleBn: 'গাছের গোড়ায় সেচ',
      descriptionEn: 'Water directly into the root zone. Avoid overhead splashing on foliage to minimize bacterial and fungal spore germination.',
      descriptionBn: 'গাছের গোড়ায় পানি দিন, পাতার ওপর পানি ছিটাবেন না। ভেজা পাতা ব্যাক্টেরিয়া ও ধসা রোগের প্রধান কারণ।',
      icon: Icons.water_drop_outlined,
    ),

    // Mango Tips
    CropCareTip(
      id: 10,
      cropId: 4,
      categoryEn: 'Field Hygiene',
      categoryBn: 'ডালপালা ছাঁটাই',
      titleEn: 'Canopy Pruning After Harvest',
      titleBn: 'ফল সংগ্রহের পর ডাল ছাঁটাই',
      descriptionEn: 'Prune dead, diseased, and overlapping inner branches after harvest to allow sun penetration and inhibit anthracnose.',
      descriptionBn: 'ফল সংগ্রহের পর শুকনো ও রোগাক্রান্ত ডাল কেটে ফেলুন, যাতে গাছের ভেতরে আলো-বাতাস সহজে প্রবেশ করতে পারে।',
      icon: Icons.content_cut_outlined,
    ),
    CropCareTip(
      id: 11,
      cropId: 4,
      categoryEn: 'Pest Monitoring',
      categoryBn: 'মুকুল সংরক্ষণ',
      titleEn: 'Inflorescence Inspection',
      titleBn: 'মুকুলের যত্ন ও পর্যবেক্ষণ',
      descriptionEn: 'Inspect young bloom panicles for powdery white mildew or black blossom blight. Protect pollinators during peak bloom.',
      descriptionBn: 'মুকুল আসার পর সাদা গুঁড়া বা কালো দাগ দেখা দিলে অনুমোদিত ব্যবস্থা নিন। পরাগায়নের সময় কীটনাশক ছিটাবেন না।',
      icon: Icons.spa_outlined,
    ),

    // Jute Tips
    CropCareTip(
      id: 12,
      cropId: 5,
      categoryEn: 'Soil Care',
      categoryBn: 'চারা পাতলাকরণ',
      titleEn: 'Seedling Thinning & Spacing',
      titleBn: 'চারা পাতলাকরণ ও ব্যবধান',
      descriptionEn: 'Thin crowded jute seedlings 15-20 days after germination to maintain 10 cm plant-to-plant spacing for sturdy fiber stems.',
      descriptionBn: 'চারা গজানোর ১৫-২০ দিন পর অতিরিক্ত চারা তুলে ফেলুন এবং গাছ থেকে গাছের দূরত্ব ১০ সেমি বজায় রাখুন।',
      icon: Icons.space_bar_outlined,
    ),
    CropCareTip(
      id: 13,
      cropId: 5,
      categoryEn: 'Water Management',
      categoryBn: 'পানি নিষ্কাশন',
      titleEn: 'Drainage in Early Growth',
      titleBn: 'জমির পানি নিষ্কাশন',
      descriptionEn: 'Young jute plants are sensitive to waterlogging. Ensure quick drainage of excess rainwater to prevent collar rot.',
      descriptionBn: 'প্রাথমিক অবস্থায় পাটের জমিতে পানি জমতে দেওয়া যাবে না। অতিরিক্ত বৃষ্টির পানি দ্রুত নিষ্কাশনের নালা রাখুন।',
      icon: Icons.water_outlined,
    ),
  ];

  /// 19 verified diseases mapped strictly 1-to-1 with assets/models/labels.json
  static const List<DiseaseModel> verifiedDiseases = [
    // ── Rice Diseases (Crop ID 1) ─────────────────────────────────────────────
    DiseaseModel(
      id: 101,
      cropId: 1,
      className: 'Rice___Bacterial_leaf_blight',
      diseaseNameEn: 'Bacterial Leaf Blight',
      diseaseNameBn: 'ব্যাকটেরিয়াল লিফ ব্লাইট',
      symptomsEn: 'Water-soaked translucent stripes on leaf margins turning wavy yellowish-white and desiccated.',
      symptomsBn: 'পাতার কিনারায় ঢেউ খেলানো পানিভেজা দাগ যা পরে হলুদ-সাদা হয়ে শুকিয়ে খড়ের মতো দেখায়।',
      causesEn: 'Xanthomonas oryzae pv. oryzae bacteria spread via floodwater and monsoon wind.',
      causesBn: 'জ্যান্থোমোনাস ব্যাকটেরিয়ার আক্রমণ যা সেচের পানি ও ঝড়ো বাতাসের মাধ্যমে বিস্তার লাভ করে।',
      isHealthy: false,
    ),
    DiseaseModel(
      id: 102,
      cropId: 1,
      className: 'Rice___Brown_spot',
      diseaseNameEn: 'Brown Spot',
      diseaseNameBn: 'বাদামী দাগ রোগ',
      symptomsEn: 'Small round to oval dark brown necrotic lesions across leaf blade, often with a grayish center.',
      symptomsBn: 'পাতায় ছোট গোলাকার বা ডিম্বাকৃতির গাঢ় বাদামী দাগ, অনেক সময় দাগের কেন্দ্রস্থল ধূসর বর্ণের হয়।',
      causesEn: 'Bipolaris oryzae fungus, especially severe in poor nutrient and drought stressed soils.',
      causesBn: 'বাইপোলারিস ওরিজি ছত্রাক, পুষ্টিহীন ও শুষ্ক মাটিতে এ রোগের প্রকোপ বেশি দেখা যায়।',
      isHealthy: false,
    ),
    DiseaseModel(
      id: 103,
      cropId: 1,
      className: 'Rice___Leaf_smut',
      diseaseNameEn: 'Leaf Smut',
      diseaseNameBn: 'পাতার স্মাট রোগ',
      symptomsEn: 'Slightly raised, angular black spots or powdery pustules scattered along leaf veins.',
      symptomsBn: 'পাতার শিরার পাশে ছোট কৌণিক কালো দাগ বা কালচে গুঁড়ার মতো ফোসকা দেখা যায়।',
      causesEn: 'Entyloma oryzae fungus surviving on crop residue in warm humid weather.',
      causesBn: 'এনটাইলোমা ওরিজি ছত্রাকের কারণে হয় যা আর্দ্র আবহাওয়ায় দ্রুত ছড়ায়।',
      isHealthy: false,
    ),
    DiseaseModel(
      id: 104,
      cropId: 1,
      className: 'Rice___healthy',
      diseaseNameEn: 'Healthy Rice Leaf',
      diseaseNameBn: 'সুস্থ ধান গাছ',
      symptomsEn: 'Vibrant, uniform green foliage free from lesions, chlorosis, and insect feeding marks.',
      symptomsBn: 'পাতায় কোনো রোগজীবাণু বা দাগ নেই, স্বাভাবিক সতেজ সবুজ ও শক্তিশালী গঠন।',
      causesEn: 'Optimal irrigation, certified seed, and balanced soil fertility management.',
      causesBn: 'সঠিক মাত্রার সার প্রয়োগ, সুস্থ বীজ ও চমৎকার পরিচর্যার সুফল।',
      isHealthy: true,
    ),

    // ── Potato Diseases (Crop ID 2) ───────────────────────────────────────────
    DiseaseModel(
      id: 201,
      cropId: 2,
      className: 'Potato___Early_blight',
      diseaseNameEn: 'Early Blight',
      diseaseNameBn: 'আগাম ধসা রোগ',
      symptomsEn: 'Dark brown to black concentric circular rings forming target-like patterns on mature leaves.',
      symptomsBn: 'পাতায় বাদামী বা কালো রঙের গোলাকার রিং বা টার্গেট বোর্ডের মতো দাগ সৃষ্টি হয়।',
      causesEn: 'Alternaria solani fungus thriving in alternating dry and wet periods.',
      causesBn: 'অল্টারনারিয়া সোলানি ছত্রাকের কারণে শুকনা ও ভেজা আবহাওয়ায় এটি দ্রুত বাড়ে।',
      isHealthy: false,
    ),
    DiseaseModel(
      id: 202,
      cropId: 2,
      className: 'Potato___Late_blight',
      diseaseNameEn: 'Late Blight',
      diseaseNameBn: 'নাবী ধসা রোগ',
      symptomsEn: 'Water-soaked irregular dark lesions turning black with fuzzy white mold on the leaf underside.',
      symptomsBn: 'পাতায় কালো পানিভেজা দাগ এবং কুয়াশাচ্ছন্ন আবহাওয়ায় পাতার উল্টো পিঠে সাদা ছত্রাক দেখা যায়।',
      causesEn: 'Phytophthora infestans oomycete in cool, cloudy, fog-heavy winter days.',
      causesBn: 'ফাইটোপথোরা ছত্রাক যা ঘন কুয়াশা ও ঠাণ্ডা স্যাঁতসেঁতে আবহাওয়ায় মহামারী আকারে ছড়ায়।',
      isHealthy: false,
    ),
    DiseaseModel(
      id: 203,
      cropId: 2,
      className: 'Potato___healthy',
      diseaseNameEn: 'Healthy Potato Leaf',
      diseaseNameBn: 'সুস্থ আলু গাছ',
      symptomsEn: 'Crisp green compound foliage with smooth margins and vigorous leaf stem growth.',
      symptomsBn: 'কোনো ধসা বা দাগমুক্ত নিখুঁত সতেজ আলু গাছ।',
      causesEn: 'Disease-free certified seed tubers and proper furrow drainage.',
      causesBn: 'উন্নত রোগমুক্ত বীজ আলু ও সঠিক সেচ ব্যবস্থাপনা।',
      isHealthy: true,
    ),

    // ── Tomato Diseases (Crop ID 3) ───────────────────────────────────────────
    DiseaseModel(
      id: 301,
      cropId: 3,
      className: 'Tomato___Bacterial_spot',
      diseaseNameEn: 'Bacterial Spot',
      diseaseNameBn: 'ব্যাকটেরিয়াল স্পট',
      symptomsEn: 'Small water-soaked dark spots with yellow halos, causing blossom drop and leaf yellowing.',
      symptomsBn: 'পাতায় ছোট কালো দাগ যার চারপাশে হলুদ বলয় থাকে, ফুল ঝরে পড়ে ও পাতা হলুদ হয়।',
      causesEn: 'Xanthomonas species bacteria spread by overhead watering and driving rain.',
      causesBn: 'জ্যান্থোমোনাস ব্যাকটেরিয়ার কারণে বৃষ্টি ও পানির ছিটার মাধ্যমে ছড়ায়।',
      isHealthy: false,
    ),
    DiseaseModel(
      id: 302,
      cropId: 3,
      className: 'Tomato___Early_blight',
      diseaseNameEn: 'Early Blight',
      diseaseNameBn: 'আগাম ধসা রোগ',
      symptomsEn: 'Concentric ring target-board brown lesions on lower leaves, moving progressively upward.',
      symptomsBn: 'গাছের নিচের পাতায় লক্ষ্যভেদী বা গোল গোল বলয়যুক্ত বাদামী দাগ দেখা দেয়।',
      causesEn: 'Alternaria linariae fungal infection from infected plant debris.',
      causesBn: 'অল্টারনারিয়া ছত্রাকের কারণে মাটির সংস্পর্শে থাকা পুরাতন পাতা থেকে ছড়ায়।',
      isHealthy: false,
    ),
    DiseaseModel(
      id: 303,
      cropId: 3,
      className: 'Tomato___Late_blight',
      diseaseNameEn: 'Late Blight',
      diseaseNameBn: 'নাবী ধসা রোগ',
      symptomsEn: 'Large dark gray greasy lesions rapidly expanding across leaves, stems, and green fruits.',
      symptomsBn: 'পাতা ও কাণ্ডে তৈলাক্ত ধূসর বা কালো পচা দাগ যা খুব দ্রুত পুরো গাছ নষ্ট করে দেয়।',
      causesEn: 'Phytophthora infestans favored by cool wet night temperatures and fog.',
      causesBn: 'স্যাঁতসেঁতে শীতের রাতে ফাইটোপথোরা ছত্রাকের দ্রুত বিস্তার।',
      isHealthy: false,
    ),
    DiseaseModel(
      id: 304,
      cropId: 3,
      className: 'Tomato___Leaf_Mold',
      diseaseNameEn: 'Leaf Mold',
      diseaseNameBn: 'লিফ মোল্ড রোগ',
      symptomsEn: 'Pale green or yellowish blotches on leaf upper surface with olive-brown velvety mold beneath.',
      symptomsBn: 'পাতার উপরে হালকা হলুদ দাগ এবং পাতার নিচে বাদামী মখমলের মতো ছত্রাকের আস্তরণ।',
      causesEn: 'Passalora fulva fungus in poorly ventilated and humid conditions.',
      causesBn: 'অতিরিক্ত আর্দ্রতা ও আলো-বাতাসহীন পরিবেশে ছত্রাকের আক্রমণ।',
      isHealthy: false,
    ),
    DiseaseModel(
      id: 305,
      cropId: 3,
      className: 'Tomato___Septoria_leaf_spot',
      diseaseNameEn: 'Septoria Leaf Spot',
      diseaseNameBn: 'সেপ্টোরিয়া লিফ স্পট',
      symptomsEn: 'Numerous small circular spots with dark brown margins and gray centers containing tiny black dots.',
      symptomsBn: 'পাতায় প্রচুর ছোট গোলাকার দাগ, কিনারা গাঢ় বাদামী এবং কেন্দ্রে ছোট কালো ফুসকুড়ি।',
      causesEn: 'Septoria lycopersici fungus overwintering on solanaceous weeds.',
      causesBn: 'সেপ্টোরিয়া ছত্রাকের আক্রমণ যা ভেজা আবহাওয়ায় দ্রুত বিস্তার পায়।',
      isHealthy: false,
    ),
    DiseaseModel(
      id: 306,
      cropId: 3,
      className: 'Tomato___healthy',
      diseaseNameEn: 'Healthy Tomato Leaf',
      diseaseNameBn: 'সুস্থ টমেটো গাছ',
      symptomsEn: 'Vibrant green serrated foliage without necrotic spots, mold, or leaf curl.',
      symptomsBn: 'কোনো রোগ বা দাগমুক্ত স্বাভাবিক শক্তিশালী টমেটো পাতা।',
      causesEn: 'Proper staking, drip base watering, and good air circulation.',
      causesBn: 'মাচা পদ্ধতি, পরিমিত সেচ ও সুষম পুষ্টি প্রয়োগ।',
      isHealthy: true,
    ),

    // ── Mango Diseases (Crop ID 4) ────────────────────────────────────────────
    DiseaseModel(
      id: 401,
      cropId: 4,
      className: 'Mango___Anthracnose',
      diseaseNameEn: 'Anthracnose',
      diseaseNameBn: 'অ্যানথ্রাকনোজ রোগ',
      symptomsEn: 'Dark brown to black angular necrotic spots on leaves, blossom blight, and sunken black fruit spots.',
      symptomsBn: 'পাতায় কালো বাদামী কোণাকৃতি দাগ, মুকুল পচা এবং ফলের গায়ে কালো ক্ষতের সৃষ্টি।',
      causesEn: 'Colletotrichum gloeosporioides fungus prevalent in cloudy, drizzling weather.',
      causesBn: 'কলেটোট্রিকাম ছত্রাক যা গুঁড়ি গুঁড়ি বৃষ্টি ও আর্দ্র বাতাসে ছড়ায়।',
      isHealthy: false,
    ),
    DiseaseModel(
      id: 402,
      cropId: 4,
      className: 'Mango___Bacterial_canker',
      diseaseNameEn: 'Bacterial Canker',
      diseaseNameBn: 'ব্যাকটেরিয়াল ক্যাঙ্কার',
      symptomsEn: 'Water-soaked angular lesions on leaf blades exudating gum; leaves become chlorotic and drop.',
      symptomsBn: 'পাতায় পানিভেজা দাগ যা থেকে আঠার মতো রস বের হয় এবং পাতা শুকিয়ে ঝরে পড়ে।',
      causesEn: 'Xanthomonas citri pv. mangiferaeindicae bacteria entering via natural openings or storm wounds.',
      causesBn: 'ঝড়ো বাতাসে গাছের পাতার ক্ষত দিয়ে জ্যান্থোমোনাস ব্যাকটেরিয়ার অনুপ্রবেশ।',
      isHealthy: false,
    ),
    DiseaseModel(
      id: 403,
      cropId: 4,
      className: 'Mango___healthy',
      diseaseNameEn: 'Healthy Mango Leaf',
      diseaseNameBn: 'সুস্থ আম গাছ',
      symptomsEn: 'Glossy, deep green leathery foliage without necrotic spots or insect defoliation.',
      symptomsBn: 'উজ্জ্বল গাঢ় সবুজ সতেজ পাতা, কোনো দাগ বা পচনমুক্ত সুস্থ অবস্থা।',
      causesEn: 'Annual canopy pruning, post-harvest orchard hygiene, and adequate sunlight.',
      causesBn: 'নিয়মিত ডাল ছাঁটাই, বাগান পরিষ্কার রাখা ও পর্যাপ্ত সূর্যের আলো।',
      isHealthy: true,
    ),

    // ── Jute Diseases (Crop ID 5) ─────────────────────────────────────────────
    DiseaseModel(
      id: 501,
      cropId: 5,
      className: 'Jute___Stem_rot',
      diseaseNameEn: 'Stem Rot',
      diseaseNameBn: 'কাণ্ড পচা রোগ',
      symptomsEn: 'Brownish black water-soaked lesions on the stem near the collar; stem softens and fiber disintegrates.',
      symptomsBn: 'গাছের গোড়ায় বা কাণ্ডে কালো দাগ পড়ে, কাণ্ড পচে যায় ও পাটের আঁশ দুর্বল হয়ে ভেঙে পড়ে।',
      causesEn: 'Macrophomina phaseolina fungus surviving in moist soil and infected seed.',
      causesBn: 'ম্যাক্রোফোমিনা ছত্রাক যা আর্দ্র মাটিতে এবং জীবাণুযুক্ত বীজের মাধ্যমে ছড়ায়।',
      isHealthy: false,
    ),
    DiseaseModel(
      id: 502,
      cropId: 5,
      className: 'Jute___Anthracnose',
      diseaseNameEn: 'Anthracnose',
      diseaseNameBn: 'অ্যানথ্রাকনোজ রোগ',
      symptomsEn: 'Small brownish spots on leaf lamina with yellow rings; stem develops elongated sunken brown cankers.',
      symptomsBn: 'পাতায় হলুদ বলয়যুক্ত বাদামী দাগ এবং কাণ্ডে লম্বাটে খোদাই করা বাদামী ক্ষত তৈরি হয়।',
      causesEn: 'Colletotrichum corchorum fungal pathogen under high temperature and humidity.',
      causesBn: 'উচ্চ তাপমাত্রা ও অতিরিক্ত আর্দ্রতায় কলেটোট্রিকাম ছত্রাকের সংক্রমণ।',
      isHealthy: false,
    ),
    DiseaseModel(
      id: 503,
      cropId: 5,
      className: 'Jute___healthy',
      diseaseNameEn: 'Healthy Jute Leaf',
      diseaseNameBn: 'সুস্থ পাট গাছ',
      symptomsEn: 'Lush green ovate foliage on sturdy upright fiber stems without discoloration or rot.',
      symptomsBn: 'মজবুত সোজা কাণ্ড ও উজ্জ্বল সবুজ সুস্থ পাতার সুস্থ পাট গাছ।',
      causesEn: 'Good drainage, certified seed, and weed-free early vegetative growth.',
      causesBn: 'পানি নিষ্কাশন ব্যবস্থা, বিশুদ্ধ বীজ ও সময়মতো আগাছা নিড়ানি।',
      isHealthy: true,
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

  /// Retrieve the agronomic profile for a crop ID
  static CropProfile? getCropProfile(int cropId) {
    return verifiedProfiles[cropId];
  }

  /// Retrieve verified agricultural care tips for a crop ID
  static List<CropCareTip> getCareTips(int cropId) {
    return verifiedCareTips.where((tip) => tip.cropId == cropId).toList();
  }

  /// Retrieve all verified model diseases for a crop ID
  static List<DiseaseModel> getVerifiedDiseasesForCrop(int cropId) {
    return verifiedDiseases.where((d) => d.cropId == cropId).toList();
  }

  /// Retrieve a specific disease by its unique integer ID
  static DiseaseModel? getDiseaseById(int diseaseId) {
    try {
      return verifiedDiseases.firstWhere((d) => d.id == diseaseId);
    } catch (_) {
      return null;
    }
  }

  /// Retrieve a disease by its exact TFLite model class name
  static DiseaseModel? getDiseaseByClassName(String className) {
    try {
      return verifiedDiseases.firstWhere((d) => d.className == className);
    } catch (_) {
      return null;
    }
  }

  /// Verified agricultural treatment and management recommendations
  /// based on official publications from BRRI, BARI, BJRI, and DAE Bangladesh.
  static const List<RecommendationModel> verifiedRecommendations = [
    // ── Rice: Bacterial Leaf Blight (101) ────────────────────────────────────
    RecommendationModel(
      id: 1011,
      diseaseId: 101,
      recommendationType: 'care',
      titleEn: 'Drain Standing Field Water',
      titleBn: 'জমির পানি অবিলম্বে নিষ্কাশন করুন',
      contentEn:
          'Drain floodwater from the field immediately to prevent bacterial movement through water flow. Temporarily stop urea top-dressing as excess nitrogen increases tissue susceptibility.',
      contentBn:
          'জমির অতিরিক্ত পানি বের করে দিন যাতে সেচের মাধ্যমে ব্যাকটেরিয়া দ্রুত ছড়াতে না পারে। সাময়িকভাবে ইউরিয়া সার উপরিপ্রয়োগ বন্ধ রাখুন, কারণ অতিরিক্ত নাইট্রোজেন গাছের রোগ প্রতিরোধ ক্ষমতা কমিয়ে দেয়।',
      sourceName: 'Bangladesh Rice Research Institute (BRRI)',
      sourceUrl: 'https://brri.gov.bd',
      isVerified: true,
    ),
    RecommendationModel(
      id: 1012,
      diseaseId: 101,
      recommendationType: 'treatment',
      titleEn: 'Potash Supplementation & Bio-bactericide',
      titleBn: 'পটাশ সার প্রয়োগ ও অনুমোদিত ব্যাকটেরিয়ানাশক',
      contentEn:
          'Apply 5 kg MOP (Muriate of Potash) per bigha to reinforce plant cell walls. In severe outbreaks, consult the local Upazila Agriculture Officer before applying an approved copper-hydroxide based bactericide strictly according to the product label.',
      contentBn:
          'বিঘা প্রতি ৫ কেজি এমওপি (পটাশ) সার প্রয়োগ করে গাছের রোগ প্রতিরোধ শক্তি বাড়ান। তীব্র আক্রমণে অনুমোদিত কপার-হাইড্রোক্সাইড জাতীয় ব্যাকটেরিয়ানাশক লেবেল নির্দেশিকা ও উপজেলা কৃষি কর্মকর্তার পরামর্শ অনুযায়ী স্প্রে করুন।',
      sourceName: 'BRRI Adhunik Dhaner Chash Handbook',
      sourceUrl: 'https://brri.gov.bd',
      isVerified: true,
    ),
    RecommendationModel(
      id: 1013,
      diseaseId: 101,
      recommendationType: 'prevention',
      titleEn: 'Resistant Cultivars & Clean Seed',
      titleBn: 'রোগ প্রতিরোধী জাত নির্বাচন ও সুস্থ বীজ',
      contentEn:
          'Use certified disease-free seeds and cultivate resistant cultivars such as BRRI dhan 28 or modern tolerant lines. Maintain 20x15 cm seedling spacing for optimal canopy ventilation.',
      contentBn:
          'উন্নত রোগমুক্ত প্রত্যয়িত বীজ ব্যবহার করুন। চারার সঠিক দূরত্ব (২০x১৫ সেমি) বজায় রেখে রোপণ করুন যাতে পাতার ভেতর আলো-বাতাস চলাচল করতে পারে।',
      sourceName: 'BRRI Extension Division',
      sourceUrl: 'https://brri.gov.bd',
      isVerified: true,
    ),

    // ── Rice: Brown Spot (102) ───────────────────────────────────────────────
    RecommendationModel(
      id: 1021,
      diseaseId: 102,
      recommendationType: 'care',
      titleEn: 'Soil Fertility & Balanced Micronutrients',
      titleBn: 'মাটির সুষম সার ও দস্তা প্রয়োগ',
      contentEn:
          'Brown spot is primarily an indicator of nutrient depletion. Top-dress with balanced potassium and zinc sulphate (1 kg/bigha) to reverse soil deficiency.',
      contentBn:
          'বাদামী দাগ মূলত মাটিতে পুষ্টিহীনতা নির্দেশ করে। জমিতে সুষম পটাশ এবং বিঘাপ্রতি ১ কেজি জিংক সালফেট প্রয়োগ করে মাটির ঘাটতি পূরণ করুন।',
      sourceName: 'BRRI Soil Science Division',
      sourceUrl: 'https://brri.gov.bd',
      isVerified: true,
    ),
    RecommendationModel(
      id: 1022,
      diseaseId: 102,
      recommendationType: 'treatment',
      titleEn: 'Approved Contact Fungicide Spray',
      titleBn: 'অনুমোদিত ছত্রাকনাশক স্প্রে',
      contentEn:
          'If lesions cover over 10% of flag leaf area, apply an approved triazole or contact fungicide according to official label directions under agricultural officer supervision.',
      contentBn:
          'পাতার ১০ ভাগের বেশি এলাকা দাগে আক্রান্ত হলে অনুমোদিত ট্রায়াজল বা স্পর্শক ছত্রাকনাশক সরকারি লেবেল নির্দেশিকা অনুযায়ী উপ-সহকারী কৃষি কর্মকর্তার পরামর্শে স্প্রে করুন।',
      sourceName: 'BRRI Plant Pathology Division',
      sourceUrl: 'https://brri.gov.bd',
      isVerified: true,
    ),

    // ── Rice: Leaf Smut (103) ────────────────────────────────────────────────
    RecommendationModel(
      id: 1031,
      diseaseId: 103,
      recommendationType: 'care',
      titleEn: 'Canopy Thinning & Weed Sanitation',
      titleBn: 'আইল পরিষ্কার ও আগাছা দমন',
      contentEn:
          'Remove alternate grassy weed hosts from field borders and bunds. Avoid excessive seedling density in nursery beds.',
      contentBn:
          'জমির আইল ও নালার চারপাশ থেকে আগাছা পরিষ্কার রাখুন যাতে ছত্রাকের বিকল্প আশ্রয় নষ্ট হয়। বীজতলায় অতিরিক্ত ঘন চারা পরিহার করুন।',
      sourceName: 'BRRI Plant Pathology Division',
      sourceUrl: 'https://brri.gov.bd',
      isVerified: true,
    ),

    // ── Potato: Early Blight (201) ───────────────────────────────────────────
    RecommendationModel(
      id: 2011,
      diseaseId: 201,
      recommendationType: 'care',
      titleEn: 'Lower Leaf Pruning & Soil Isolation',
      titleBn: 'নিচের রোগাক্রান্ত পাতা অপসারণ',
      contentEn:
          'Prune decaying lower leaves touching the soil surface to break fungal splash infection. Water plants in furrows rather than spraying overhead.',
      contentBn:
          'মাটির সংস্পর্শে থাকা নিচের আক্রান্ত পাতাগুলো ছিঁড়ে ধ্বংস করুন। গাছের ওপর থেকে পানি ছিটানোর পরিবর্তে ড্রেনের মাধ্যমে জমিতে সেচ দিন।',
      sourceName: 'Tuber Crops Research Centre (BARI)',
      sourceUrl: 'https://bari.gov.bd',
      isVerified: true,
    ),
    RecommendationModel(
      id: 2012,
      diseaseId: 201,
      recommendationType: 'treatment',
      titleEn: 'Protective Contact Fungicide',
      titleBn: 'প্রতিরোধমূলক ছত্রাকনাশক প্রয়োগ',
      contentEn:
          'Apply an approved contact protectant fungicide (such as Mancozeb) following label directions. Spray when warm, alternating dry-wet weather persists.',
      contentBn:
          'অনুমোদিত ম্যানকোজেব জাতীয় স্পর্শক ছত্রাকনাশক পণ্যের লেবেল অনুযায়ী স্প্রে করুন। শুকনা ও আর্দ্র আবহাওয়ার পরিবর্তনের সময় সতর্ক থাকুন।',
      sourceName: 'BARI Krishi Projukti Hatboi',
      sourceUrl: 'https://bari.gov.bd',
      isVerified: true,
    ),

    // ── Potato: Late Blight (202) ────────────────────────────────────────────
    RecommendationModel(
      id: 2021,
      diseaseId: 202,
      recommendationType: 'care',
      titleEn: 'Dense Fog Scouting & Evening Dryness',
      titleBn: 'কুয়াশাচ্ছন্ন সকালে দ্রুত পরিদর্শন ও শুকনো পাতা',
      contentEn:
          'Scout field corners early morning during continuous foggy and cool winter spells. Avoid late-afternoon irrigation so leaf canopies remain dry overnight.',
      contentBn:
          'ঘন কুয়াশার দিনে নিয়মিত সকালে আলু ক্ষেত ঘুরে দেখুন। বিকেলে জমিতে পানি দেবেন না যাতে রাতে পাতা ভেজা না থাকে।',
      sourceName: 'BARI Tuber Crops Research Centre',
      sourceUrl: 'https://bari.gov.bd',
      isVerified: true,
    ),
    RecommendationModel(
      id: 2022,
      diseaseId: 202,
      recommendationType: 'treatment',
      titleEn: 'Preventive Contact Fungicide Protocol',
      titleBn: 'অনুমোদিত স্পর্শক ছত্রাকনাশক প্রটোকল',
      contentEn:
          'As soon as fog begins, apply approved preventive fungicides strictly according to package label instructions. Ensure thorough coverage of leaf undersides. If blight symptoms appear, seek emergency guidance from the local Upazila extension officer.',
      contentBn:
          'কুয়াশা শুরু হওয়া মাত্রই অনুমোদিত ছত্রাকনাশক প্যাকেটের লেবেল অনুযায়ী পাতার উল্টো পিঠ ভিজিয়ে স্প্রে করুন। রোগের লক্ষণ দেখা দিলে দ্রুত উপজেলা কৃষি কর্মকর্তার জরুরি পরামর্শ নিন।',
      sourceName: 'BARI Plant Pathology Division',
      sourceUrl: 'https://bari.gov.bd',
      isVerified: true,
    ),

    // ── Tomato: Early Blight (302) ───────────────────────────────────────────
    RecommendationModel(
      id: 3021,
      diseaseId: 302,
      recommendationType: 'care',
      titleEn: 'Staking & Drip Root Irrigation',
      titleBn: 'গাছে খুঁটি দেওয়া ও গোড়ায় সেচ',
      contentEn:
          'Stake tomato vines with bamboo to elevate foliage away from wet soil. Irrigate at the plant base rather than splashing foliage with hoses.',
      contentBn:
          'বাঁশের খুঁটি দিয়ে গাছ সোজা করে বেঁধে রাখুন যাতে পাতা মাটিতে না ঠেকে। পাতার ওপর পানি না ছিটিয়ে সরাসরি গাছের গোড়ায় সেচ দিন।',
      sourceName: 'Horticulture Research Centre (BARI)',
      sourceUrl: 'https://bari.gov.bd',
      isVerified: true,
    ),

    // ── Tomato: Late Blight (303) ────────────────────────────────────────────
    RecommendationModel(
      id: 3031,
      diseaseId: 303,
      recommendationType: 'treatment',
      titleEn: 'Protective Organic or Copper Spray',
      titleBn: 'অনুমোদিত প্রতিরোধক স্প্রে ও ডাল ছাঁটাই',
      contentEn:
          'Remove severely blighted tomato stems and fruits in dry weather. Apply an approved preventive protectant according to registered pesticide labels under local extension officer advice.',
      contentBn:
          'শুকনো আবহাওয়ায় মারাত্মক আক্রান্ত ডাল ও পচা ফল সাবধানে তুলে ধ্বংস করুন। অনুমোদিত বালাইনাশকের লেবেল ও স্থানীয় কৃষি কর্মকর্তার নির্দেশ মোতাবেক স্প্রে করুন।',
      sourceName: 'BARI Vegetable Division',
      sourceUrl: 'https://bari.gov.bd',
      isVerified: true,
    ),

    // ── Mango: Anthracnose (401) ─────────────────────────────────────────────
    RecommendationModel(
      id: 4011,
      diseaseId: 401,
      recommendationType: 'care',
      titleEn: 'Canopy Pruning for Air Circulation',
      titleBn: 'গাছের ডাল ছাঁটাই ও আলো-বাতাস বৃদ্ধি',
      contentEn:
          'Prune dead, crisscrossing, and diseased twigs after fruit harvest. Open the interior canopy to direct sunlight to suppress fungal spore germination.',
      contentBn:
          'ফল সংগ্রহের পর মরা ও রোগাক্রান্ত ডালপালা কেটে পরিষ্কার করুন। গাছের ভেতর সূর্যের আলো ও বাতাস চলাচল নিশ্চিত করতে অতিরিক্ত ডাল ছাঁটাই করুন।',
      sourceName: 'Fruit Research Station, Rajshahi',
      sourceUrl: 'https://bari.gov.bd',
      isVerified: true,
    ),

    // ── Jute: Stem Rot (501) ─────────────────────────────────────────────────
    RecommendationModel(
      id: 5011,
      diseaseId: 501,
      recommendationType: 'care',
      titleEn: 'Surface Trench Drainage',
      titleBn: 'জমিতে নিকাশ নালা তৈরি',
      contentEn:
          'Excavate drainage furrows along the field perimeter. Waterlogged soil predisposes tender jute seedling collars to fungal collar rot.',
      contentBn:
          'জমির চারপাশে ড্রেন কেটে বৃষ্টির পানি দ্রুত বের করে দিন। জমিতে পানি জমে থাকলে পাটের কাণ্ডে ছত্রাকের আক্রমণ বাড়ে।',
      sourceName: 'Bangladesh Jute Research Institute (BJRI)',
      sourceUrl: 'https://bjri.gov.bd',
      isVerified: true,
    ),

    // ── Healthy Foliage (104, 203, 306, 403, 503) ───────────────────────────
    RecommendationModel(
      id: 9001,
      diseaseId: 104,
      recommendationType: 'care',
      titleEn: 'Maintain Balanced Crop Health',
      titleBn: 'সুষম পরিচর্যা ও সুস্থতা বজায় রাখা',
      contentEn:
          'Your plant foliage displays healthy vigor. Maintain balanced split fertilizer applications and regular scouting. No chemical pesticide application is required.',
      contentBn:
          'আপনার গাছের পাতা সুস্থ ও সতেজ। সঠিক মাত্রায় নিয়মিত সেচ ও সুষম সার বজায় রাখুন। কোনো বালাইনাশক স্প্রে করার প্রয়োজন নেই।',
      sourceName: 'Department of Agricultural Extension (DAE)',
      sourceUrl: 'https://dae.gov.bd',
      isVerified: true,
    ),
  ];

  /// Retrieve verified agricultural treatment and care recommendations for a disease
  static List<RecommendationModel> getRecommendationsForDisease(int diseaseId) {
    return verifiedRecommendations
        .where((rec) => rec.diseaseId == diseaseId)
        .toList();
  }
}
