import '../../data/models/ai_model_metadata.dart';
import '../../data/models/disease_label.dart';

/// Lifecycle status of the on-device AI model in AgriCare AI.
enum AiModelStatus {
  /// The model has not started loading yet.
  initial,

  /// The model, metadata, and labels are currently loading and validating tensors.
  loading,

  /// The model is fully loaded, tensors are validated, and inference is ready.
  ready,

  /// An error occurred during asset loading, parsing, or interpreter initialization.
  error,
}

/// State object representing the readiness, metadata, and diagnostics of the AI model.
class AiModelState {
  final AiModelStatus status;
  final AiModelMetadata? metadata;
  final DiseaseLabels? labels;
  final List<int>? inputShape;
  final List<int>? outputShape;
  final String? errorMessage;
  final String? technicalDetails;
  final DateTime? initializedAt;

  const AiModelState({
    this.status = AiModelStatus.initial,
    this.metadata,
    this.labels,
    this.inputShape,
    this.outputShape,
    this.errorMessage,
    this.technicalDetails,
    this.initializedAt,
  });

  /// Factory for initial not-initialized state.
  factory AiModelState.initial() => const AiModelState(status: AiModelStatus.initial);

  /// Factory for loading state.
  factory AiModelState.loading() => const AiModelState(status: AiModelStatus.loading);

  /// Factory for ready state with complete metadata and labels.
  factory AiModelState.ready({
    required AiModelMetadata metadata,
    required DiseaseLabels labels,
    required List<int> inputShape,
    required List<int> outputShape,
  }) {
    return AiModelState(
      status: AiModelStatus.ready,
      metadata: metadata,
      labels: labels,
      inputShape: inputShape,
      outputShape: outputShape,
      initializedAt: DateTime.now(),
    );
  }

  /// Factory for error state with diagnostic information.
  factory AiModelState.error({
    required String message,
    String? technicalDetails,
  }) {
    return AiModelState(
      status: AiModelStatus.error,
      errorMessage: message,
      technicalDetails: technicalDetails,
    );
  }

  /// True when the model is ready for inference.
  bool get isReady => status == AiModelStatus.ready;

  /// True while the model is being initialized.
  bool get isLoading => status == AiModelStatus.loading;

  /// True if initialization failed.
  bool get hasError => status == AiModelStatus.error;

  /// Number of verified disease classes (19 when ready).
  int get classCount => labels?.numClasses ?? metadata?.numClasses ?? 0;

  /// Model architecture name (e.g. MobileNetV2).
  String get architecture => metadata?.architecture ?? 'MobileNetV2';

  /// Human-readable model title.
  String get modelName => metadata?.modelName ?? 'AgriCare AI Leaf Disease Detector';

  /// Preprocessing input resolution description (e.g. 224x224 RGB).
  String get resolutionDescription {
    if (metadata != null) {
      return '${metadata!.inputWidth}x${metadata!.inputHeight} ${metadata!.colorFormat}';
    }
    return '224x224 RGB';
  }

  /// Creates a copy with optionally modified properties.
  AiModelState copyWith({
    AiModelStatus? status,
    AiModelMetadata? metadata,
    DiseaseLabels? labels,
    List<int>? inputShape,
    List<int>? outputShape,
    String? errorMessage,
    String? technicalDetails,
    DateTime? initializedAt,
  }) {
    return AiModelState(
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      labels: labels ?? this.labels,
      inputShape: inputShape ?? this.inputShape,
      outputShape: outputShape ?? this.outputShape,
      errorMessage: errorMessage ?? this.errorMessage,
      technicalDetails: technicalDetails ?? this.technicalDetails,
      initializedAt: initializedAt ?? this.initializedAt,
    );
  }

  @override
  String toString() =>
      'AiModelState(status: ${status.name}, classes: $classCount, ready: $isReady)';
}
