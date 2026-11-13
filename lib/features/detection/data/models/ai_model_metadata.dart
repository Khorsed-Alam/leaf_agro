import '../../../../core/errors/ai_model_exception.dart';

/// Dart model representing the verified metadata structure from model_metadata.json.
///
/// Encapsulates model architecture, input/output tensor specifications, preprocessing
/// contracts, and export metadata with strict null safety and schema validation.
class AiModelMetadata {
  final String modelName;
  final String modelVersion;
  final String architecture;
  final String? sourceKerasModel;
  final String? selectedStage;
  final String? selectedCheckpoint;
  final int inputWidth;
  final int inputHeight;
  final int inputChannels;
  final String colorFormat;
  final String inputDtype;
  final List<double> inputPixelRange;
  final String inputNormalization;
  final String normalizationFormula;
  final String tensorLayout;
  final List<int> outputShape;
  final String outputDtype;
  final String outputActivation;
  final int numClasses;
  final String labelsFile;
  final String primaryTfliteModel;
  final String targetPlatform;
  final Map<String, dynamic> tfliteExports;
  final String? trainingPhaseReference;
  final String? evaluationPhaseReference;
  final String? exportPhaseReference;
  final String? conversionTimestamp;
  final String? tensorflowVersion;
  final List<String> knownLimitations;
  final double? bestValidationLoss;
  final double? bestValidationAccuracy;

  const AiModelMetadata({
    required this.modelName,
    required this.modelVersion,
    required this.architecture,
    this.sourceKerasModel,
    this.selectedStage,
    this.selectedCheckpoint,
    required this.inputWidth,
    required this.inputHeight,
    required this.inputChannels,
    required this.colorFormat,
    required this.inputDtype,
    required this.inputPixelRange,
    required this.inputNormalization,
    required this.normalizationFormula,
    required this.tensorLayout,
    required this.outputShape,
    required this.outputDtype,
    required this.outputActivation,
    required this.numClasses,
    required this.labelsFile,
    required this.primaryTfliteModel,
    required this.targetPlatform,
    this.tfliteExports = const {},
    this.trainingPhaseReference,
    this.evaluationPhaseReference,
    this.exportPhaseReference,
    this.conversionTimestamp,
    this.tensorflowVersion,
    this.knownLimitations = const [],
    this.bestValidationLoss,
    this.bestValidationAccuracy,
  });

  /// Factory constructor to parse and validate JSON map.
  factory AiModelMetadata.fromJson(Map<String, dynamic> json) {
    // 1. Validate required string fields
    final modelName = json['model_name'] as String?;
    if (modelName == null || modelName.trim().isEmpty) {
      throw InvalidMetadataException('model_name', 'Field is required and must not be empty.');
    }

    final modelVersion = json['model_version'] as String?;
    if (modelVersion == null || modelVersion.trim().isEmpty) {
      throw InvalidMetadataException('model_version', 'Field is required.');
    }

    final architecture = json['architecture'] as String?;
    if (architecture == null || architecture.trim().isEmpty) {
      throw InvalidMetadataException('architecture', 'Field is required.');
    }

    // 2. Validate input dimensions
    final inputWidth = json['input_width'] as int?;
    if (inputWidth == null || inputWidth <= 0) {
      throw InvalidMetadataException('input_width', 'Must be a positive integer (e.g. 224).');
    }

    final inputHeight = json['input_height'] as int?;
    if (inputHeight == null || inputHeight <= 0) {
      throw InvalidMetadataException('input_height', 'Must be a positive integer (e.g. 224).');
    }

    final inputChannels = json['input_channels'] as int?;
    if (inputChannels == null || inputChannels <= 0) {
      throw InvalidMetadataException('input_channels', 'Must be a positive integer (e.g. 3).');
    }

    // 3. Validate class count
    final numClasses = json['num_classes'] as int?;
    if (numClasses == null || numClasses <= 0) {
      throw InvalidMetadataException('num_classes', 'Must be a positive integer representing output classes.');
    }

    // 4. Validate output shape
    final rawOutputShape = json['output_shape'];
    List<int> outputShape;
    if (rawOutputShape is List) {
      outputShape = rawOutputShape.map((e) => (e as num).toInt()).toList();
    } else {
      throw InvalidMetadataException('output_shape', 'Must be a list of integers (e.g. [1, 19]).');
    }

    // 5. Validate input pixel range
    final rawPixelRange = json['input_pixel_range'];
    List<double> inputPixelRange;
    if (rawPixelRange is List && rawPixelRange.length == 2) {
      inputPixelRange = rawPixelRange.map((e) => (e as num).toDouble()).toList();
    } else {
      inputPixelRange = const [0.0, 255.0];
    }

    // 6. Validate known limitations
    final rawLimitations = json['known_limitations'];
    List<String> knownLimitations = [];
    if (rawLimitations is List) {
      knownLimitations = rawLimitations.map((e) => e.toString()).toList();
    }

    return AiModelMetadata(
      modelName: modelName,
      modelVersion: modelVersion,
      architecture: architecture,
      sourceKerasModel: json['source_keras_model'] as String?,
      selectedStage: json['selected_stage'] as String?,
      selectedCheckpoint: json['selected_checkpoint'] as String?,
      inputWidth: inputWidth,
      inputHeight: inputHeight,
      inputChannels: inputChannels,
      colorFormat: json['color_format'] as String? ?? 'RGB',
      inputDtype: json['input_dtype'] as String? ?? 'float32',
      inputPixelRange: inputPixelRange,
      inputNormalization: json['input_normalization'] as String? ?? 'mobilenet_v2_internal_rescaling',
      normalizationFormula: json['normalization_formula'] as String? ?? 'pixel_val * (1.0 / 127.5) - 1.0',
      tensorLayout: json['tensor_layout'] as String? ?? 'NHWC ([batch, height, width, channels])',
      outputShape: outputShape,
      outputDtype: json['output_dtype'] as String? ?? 'float32',
      outputActivation: json['output_activation'] as String? ?? 'softmax',
      numClasses: numClasses,
      labelsFile: json['labels_file'] as String? ?? 'labels.json',
      primaryTfliteModel: json['primary_tflite_model'] as String? ?? 'plant_disease_model.tflite',
      targetPlatform: json['target_platform'] as String? ?? 'Android (TensorFlow Lite / Flutter tflite_flutter)',
      tfliteExports: json['tflite_exports'] is Map<String, dynamic>
          ? json['tflite_exports'] as Map<String, dynamic>
          : {},
      trainingPhaseReference: json['training_phase_reference'] as String?,
      evaluationPhaseReference: json['evaluation_phase_reference'] as String?,
      exportPhaseReference: json['export_phase_reference'] as String?,
      conversionTimestamp: json['conversion_timestamp'] as String?,
      tensorflowVersion: json['tensorflow_version'] as String?,
      knownLimitations: knownLimitations,
      bestValidationLoss: (json['best_validation_loss'] as num?)?.toDouble(),
      bestValidationAccuracy: (json['best_validation_accuracy'] as num?)?.toDouble(),
    );
  }

  /// Converts metadata instance to standard JSON map.
  Map<String, dynamic> toJson() {
    return {
      'model_name': modelName,
      'model_version': modelVersion,
      'architecture': architecture,
      if (sourceKerasModel != null) 'source_keras_model': sourceKerasModel,
      if (selectedStage != null) 'selected_stage': selectedStage,
      if (selectedCheckpoint != null) 'selected_checkpoint': selectedCheckpoint,
      'input_width': inputWidth,
      'input_height': inputHeight,
      'input_channels': inputChannels,
      'color_format': colorFormat,
      'input_dtype': inputDtype,
      'input_pixel_range': inputPixelRange,
      'input_normalization': inputNormalization,
      'normalization_formula': normalizationFormula,
      'tensor_layout': tensorLayout,
      'output_shape': outputShape,
      'output_dtype': outputDtype,
      'output_activation': outputActivation,
      'num_classes': numClasses,
      'labels_file': labelsFile,
      'primary_tflite_model': primaryTfliteModel,
      'target_platform': targetPlatform,
      'tflite_exports': tfliteExports,
      if (trainingPhaseReference != null) 'training_phase_reference': trainingPhaseReference,
      if (evaluationPhaseReference != null) 'evaluation_phase_reference': evaluationPhaseReference,
      if (exportPhaseReference != null) 'export_phase_reference': exportPhaseReference,
      if (conversionTimestamp != null) 'conversion_timestamp': conversionTimestamp,
      if (tensorflowVersion != null) 'tensorflow_version': tensorflowVersion,
      'known_limitations': knownLimitations,
      if (bestValidationLoss != null) 'best_validation_loss': bestValidationLoss,
      if (bestValidationAccuracy != null) 'best_validation_accuracy': bestValidationAccuracy,
    };
  }

  /// Validates internal consistency of the metadata properties.
  void validate() {
    if (inputWidth != 224 || inputHeight != 224 || inputChannels != 3) {
      throw InvalidMetadataException(
        'input_dimensions',
        'Model requires 224x224x3 input, but metadata defines ${inputWidth}x${inputHeight}x$inputChannels.',
      );
    }
    if (numClasses <= 0) {
      throw InvalidMetadataException('num_classes', 'Number of classes must be greater than zero.');
    }
    if (outputShape.isEmpty || outputShape.last != numClasses) {
      throw InvalidMetadataException(
        'output_shape',
        'Output shape last dimension (${outputShape.isEmpty ? "empty" : outputShape.last}) must match numClasses ($numClasses).',
      );
    }
  }

  /// Total number of expected input elements in flattened 1D buffer (1 * 224 * 224 * 3 = 150,528)
  int get expectedInputElements => 1 * inputWidth * inputHeight * inputChannels;

  @override
  String toString() =>
      'AiModelMetadata($modelName v$modelVersion, $architecture, ${inputWidth}x${inputHeight}x$inputChannels -> $numClasses classes)';
}
