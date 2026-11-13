import '../../../../core/errors/ai_model_exception.dart';

/// Represents a single verified plant disease or healthy class associated with a model output neuron.
class DiseaseLabel {
  final int index;
  final String rawClassName;
  final String cropName;
  final String diseaseName;
  final bool isHealthy;

  const DiseaseLabel({
    required this.index,
    required this.rawClassName,
    required this.cropName,
    required this.diseaseName,
    required this.isHealthy,
  });

  /// Factory parser extracting crop and disease components from the raw class string (e.g. "Tomato___Early_blight").
  factory DiseaseLabel.fromRaw({
    required int index,
    required String rawClassName,
  }) {
    final parts = rawClassName.split('___');
    final crop = parts.isNotEmpty ? parts[0].replaceAll('_', ' ').trim() : 'Unknown';
    final rawDisease = parts.length > 1 ? parts[1].replaceAll('_', ' ').trim() : 'Healthy';
    final healthy = rawDisease.toLowerCase() == 'healthy' || rawClassName.toLowerCase().contains('healthy');
    final disease = healthy ? 'Healthy' : rawDisease;

    return DiseaseLabel(
      index: index,
      rawClassName: rawClassName,
      cropName: crop,
      diseaseName: disease,
      isHealthy: healthy,
    );
  }

  /// Returns user-friendly localized display name (English or Bengali).
  String getDisplayName(bool isBn) {
    if (isBn) {
      final bnCrop = _bengaliCrops[cropName] ?? cropName;
      if (isHealthy) {
        return '$bnCrop (সুস্থ)';
      }
      final bnDisease = _bengaliDiseases[diseaseName] ?? diseaseName;
      return '$bnCrop - $bnDisease';
    } else {
      if (isHealthy) {
        return '$cropName (Healthy)';
      }
      return '$cropName - $diseaseName';
    }
  }

  static const Map<String, String> _bengaliCrops = {
    'Rice': 'ধান',
    'Potato': 'আলু',
    'Tomato': 'টমেটো',
    'Mango': 'আম',
    'Jute': 'পাট',
  };

  static const Map<String, String> _bengaliDiseases = {
    'Bacterial leaf blight': 'ব্যাকটেরিয়াল লিফ ব্লাইট',
    'Brown spot': 'বাদামি দাগ (ব্রাউন স্পট)',
    'Leaf smut': 'পাতা ঝলসানো (লিফ স্মাট)',
    'Early blight': 'আর্লি ব্লাইট (আগাম ধসা)',
    'Late blight': 'লেট ব্লাইট (নাবী ধসা)',
    'Bacterial spot': 'ব্যাকটেরিয়াল দাগ',
    'Leaf Mold': 'লিফ মোল্ড (পাতার ছত্রাক)',
    'Septoria leaf spot': 'সেপ্টোরিয়া পাতার দাগ',
    'Anthracnose': 'অ্যানথ্রাকনোজ (ক্ষত রোগ)',
    'Bacterial canker': 'ব্যাকটেরিয়াল ক্যাঙ্কার',
    'Stem rot': 'কাণ্ড পচা রোগ',
    'Healthy': 'সুস্থ পাতা',
  };

  @override
  String toString() => 'DiseaseLabel(#$index: $rawClassName)';
}

/// Represents the immutable collection of all verified disease labels loaded from labels.json.
///
/// Preserves the EXACT index mapping corresponding 1-to-1 with model output neurons.
/// NEVER sorts or reorders class names.
class DiseaseLabels {
  final int numClasses;
  final List<String> classNames;
  final Map<String, int> classIndices;
  final List<String> supportedCrops;
  final List<DiseaseLabel> labels;

  const DiseaseLabels({
    required this.numClasses,
    required this.classNames,
    required this.classIndices,
    required this.supportedCrops,
    required this.labels,
  });

  /// Factory constructor to parse and validate labels.json.
  factory DiseaseLabels.fromJson(Map<String, dynamic> json) {
    final numClasses = json['num_classes'] as int?;
    if (numClasses == null || numClasses <= 0) {
      throw InvalidJsonException('labels.json', 'Invalid or missing "num_classes" field.');
    }

    final rawClassNames = json['class_names'];
    if (rawClassNames is! List || rawClassNames.isEmpty) {
      throw InvalidJsonException('labels.json', 'Missing or empty "class_names" list.');
    }

    final classNames = rawClassNames.map((e) => e.toString()).toList();
    if (classNames.length != numClasses) {
      throw InvalidJsonException(
        'labels.json',
        'class_names length (${classNames.length}) does not match num_classes ($numClasses).',
      );
    }

    // Parse class indices mapping
    final rawClassIndices = json['class_indices'];
    final Map<String, int> classIndices = {};
    if (rawClassIndices is Map) {
      rawClassIndices.forEach((key, value) {
        if (value is num) {
          classIndices[key.toString()] = value.toInt();
        }
      });
    } else {
      // Reconstruct strictly based on classNames order if missing
      for (int i = 0; i < classNames.length; i++) {
        classIndices[classNames[i]] = i;
      }
    }

    // Supported crops list
    final rawSupportedCrops = json['supported_crops'];
    List<String> supportedCrops = [];
    if (rawSupportedCrops is List) {
      supportedCrops = rawSupportedCrops.map((e) => e.toString()).toList();
    } else {
      // Derive distinct crops from class names
      supportedCrops = classNames.map((c) => c.split('___').first).toSet().toList();
    }

    // Generate DiseaseLabel entries in EXACT index order (never reordered)
    final List<DiseaseLabel> labels = [];
    for (int i = 0; i < classNames.length; i++) {
      final name = classNames[i];
      final verifiedIndex = classIndices[name] ?? i;
      if (verifiedIndex != i) {
        throw InvalidJsonException(
          'labels.json',
          'Inconsistent indexing for "$name": list position $i vs mapped index $verifiedIndex.',
        );
      }
      labels.add(DiseaseLabel.fromRaw(index: i, rawClassName: name));
    }

    return DiseaseLabels(
      numClasses: numClasses,
      classNames: List.unmodifiable(classNames),
      classIndices: Map.unmodifiable(classIndices),
      supportedCrops: List.unmodifiable(supportedCrops),
      labels: List.unmodifiable(labels),
    );
  }

  /// Safe lookup by model output neuron index.
  DiseaseLabel getLabelByIndex(int index) {
    if (index < 0 || index >= labels.length) {
      throw InvalidLabelIndexException(queriedIndex: index, totalClasses: labels.length);
    }
    return labels[index];
  }

  /// Safe lookup by raw class name.
  DiseaseLabel? getLabelByName(String rawName) {
    final idx = classIndices[rawName];
    if (idx != null && idx >= 0 && idx < labels.length) {
      return labels[idx];
    }
    return null;
  }

  /// Validates that the number of labels matches the model's actual output dimension.
  void validate(int expectedOutputClasses) {
    if (numClasses != expectedOutputClasses) {
      throw ClassCountMismatchException(
        labelCount: numClasses,
        modelOutputCount: expectedOutputClasses,
      );
    }
  }

  /// Total number of classes.
  int get length => labels.length;

  @override
  String toString() => 'DiseaseLabels($numClasses classes across ${supportedCrops.length} crops)';
}
