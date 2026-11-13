import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/detection_provider.dart';
import '../../../../data/models/prediction_model.dart';
import '../../data/models/plant_disease_prediction.dart';
import '../../data/models/selected_plant_image.dart';
import '../../data/services/plant_disease_inference_service.dart';
import 'selected_image_provider.dart';

/// Status of the on-device AI prediction workflow.
enum PlantDiseasePredictionStatus {
  /// Waiting for user to trigger analysis or select an image.
  idle,

  /// Decoding image, correcting orientation, and preparing Float32 tensor.
  preprocessing,

  /// Executing TFLite native interpreter run on-device.
  analyzing,

  /// Prediction successfully generated with verified class probabilities.
  success,

  /// An error occurred during preprocessing, tensor allocation, or inference.
  error,
}

/// Immutable state holding the active prediction, status, and error details.
class PlantDiseasePredictionState {
  final PlantDiseasePredictionStatus status;
  final PlantDiseasePrediction? prediction;
  final String? errorMessageEn;
  final String? errorMessageBn;
  final String? technicalDetails;
  final String? activeImagePath;

  const PlantDiseasePredictionState({
    this.status = PlantDiseasePredictionStatus.idle,
    this.prediction,
    this.errorMessageEn,
    this.errorMessageBn,
    this.technicalDetails,
    this.activeImagePath,
  });

  factory PlantDiseasePredictionState.idle() => const PlantDiseasePredictionState(
        status: PlantDiseasePredictionStatus.idle,
      );

  factory PlantDiseasePredictionState.preprocessing(String imagePath) =>
      PlantDiseasePredictionState(
        status: PlantDiseasePredictionStatus.preprocessing,
        activeImagePath: imagePath,
      );

  factory PlantDiseasePredictionState.analyzing(String imagePath) =>
      PlantDiseasePredictionState(
        status: PlantDiseasePredictionStatus.analyzing,
        activeImagePath: imagePath,
      );

  factory PlantDiseasePredictionState.success(
    PlantDiseasePrediction prediction,
  ) =>
      PlantDiseasePredictionState(
        status: PlantDiseasePredictionStatus.success,
        prediction: prediction,
        activeImagePath: prediction.imagePath,
      );

  factory PlantDiseasePredictionState.error({
    required String errorMessageEn,
    required String errorMessageBn,
    String? technicalDetails,
    String? imagePath,
  }) =>
      PlantDiseasePredictionState(
        status: PlantDiseasePredictionStatus.error,
        errorMessageEn: errorMessageEn,
        errorMessageBn: errorMessageBn,
        technicalDetails: technicalDetails,
        activeImagePath: imagePath,
      );

  bool get isBusy =>
      status == PlantDiseasePredictionStatus.preprocessing ||
      status == PlantDiseasePredictionStatus.analyzing;

  bool get isSuccess => status == PlantDiseasePredictionStatus.success;
  bool get hasError => status == PlantDiseasePredictionStatus.error;

  String getLocalizedMessage(bool isBn) {
    if (isBn && errorMessageBn != null && errorMessageBn!.isNotEmpty) {
      return errorMessageBn!;
    }
    return errorMessageEn ?? 'An unexpected error occurred.';
  }
}

/// StateNotifier managing on-device inference state transitions.
class PlantDiseasePredictionNotifier
    extends StateNotifier<PlantDiseasePredictionState> {
  final PlantDiseaseInferenceService _inferenceService;
  final Ref _ref;

  bool _isProcessing = false;
  String? _currentRequestId;

  PlantDiseasePredictionNotifier({
    required PlantDiseaseInferenceService inferenceService,
    required Ref ref,
  })  : _inferenceService = inferenceService,
        _ref = ref,
        super(PlantDiseasePredictionState.idle()) {
    // Listen to image selection changes: if image changes, reset previous prediction
    _ref.listen<SelectedImageState>(selectedImageProvider, (previous, next) {
      final prevPath = previous?.selectedImage?.imagePath;
      final nextPath = next.selectedImage?.imagePath;
      if (prevPath != nextPath && nextPath != null && state.prediction != null) {
        if (state.activeImagePath != nextPath) {
          reset();
        }
      }
    });
  }

  /// Resets state back to idle.
  void reset() {
    _currentRequestId = null;
    state = PlantDiseasePredictionState.idle();
  }

  /// Executes inference on the currently selected image.
  Future<void> runInference([SelectedPlantImage? explicitImage]) async {
    // 1. Duplicate execution guard
    if (_isProcessing) return;

    // 2. Resolve target image
    final selectedImage = explicitImage ??
        _ref.read(selectedImageProvider).selectedImage;
    final fallbackPath = _ref.read(detectionProvider).imagePath;

    final imagePath = selectedImage?.imagePath ?? fallbackPath;

    if (imagePath == null || imagePath.isEmpty) {
      state = PlantDiseasePredictionState.error(
        errorMessageEn: 'No leaf image found for analysis. Please select an image first.',
        errorMessageBn: 'বিশ্লেষণের জন্য কোনো পাতার ছবি পাওয়া যায়নি। অনুগ্রহ করে একটি ছবি নির্বাচন করুন।',
      );
      return;
    }

    _isProcessing = true;
    final requestId = DateTime.now().microsecondsSinceEpoch.toString();
    _currentRequestId = requestId;

    try {
      // Step A: Preprocessing state
      state = PlantDiseasePredictionState.preprocessing(imagePath);

      // Step B: Analyzing state
      state = PlantDiseasePredictionState.analyzing(imagePath);

      // Step C: Execute real inference
      final prediction = await _inferenceService.predictFromFile(imagePath);

      // Step D: Stale request check (image might have changed during async turn)
      if (_currentRequestId != requestId) {
        return;
      }

      state = PlantDiseasePredictionState.success(prediction);

      // Step E: Sync with legacy detectionProvider for downstream screen compatibility
      _syncWithLegacyDetectionProvider(prediction);
    } catch (e, st) {
      if (_currentRequestId != requestId) return;

      state = PlantDiseasePredictionState.error(
        errorMessageEn: 'Inference failed: $e',
        errorMessageBn: 'এআই বিশ্লেষণ সম্পন্ন করা যায়নি। অনুগ্রহ করে পুনরায় চেষ্টা করুন।',
        technicalDetails: st.toString(),
        imagePath: imagePath,
      );
    } finally {
      _isProcessing = false;
    }
  }

  /// Retries prediction for the current active image.
  Future<void> retry() async {
    final imagePath = state.activeImagePath;
    if (imagePath != null && imagePath.isNotEmpty) {
      final selectedImage = _ref.read(selectedImageProvider).selectedImage;
      await runInference(selectedImage);
    } else {
      await runInference();
    }
  }

  /// Bridges prediction to legacy [DetectionNotifier] to ensure compatibility with
  /// downstream UI widgets and result screens.
  void _syncWithLegacyDetectionProvider(PlantDiseasePrediction p) {
    try {
      final legacyPrediction = PredictionModel(
        className: p.predictedClassName,
        cropName: p.cropName,
        diseaseNameEn: p.diseaseNameEn,
        diseaseNameBn: p.diseaseNameBn,
        confidence: p.confidence,
        predictedAt: p.predictionTimestamp,
        modelVersion: p.modelVersion,
      );

      final notifier = _ref.read(detectionProvider.notifier);
      notifier.state = notifier.state.copyWith(
        status: DetectionStatus.success,
        prediction: legacyPrediction,
        imagePath: p.imagePath,
        errorMessage: null,
      );
    } catch (_) {
      // Ignored if detectionProvider is not available or mock
    }
  }
}

/// Application-level provider for [PlantDiseasePredictionNotifier].
final plantDiseasePredictionProvider = StateNotifierProvider<
    PlantDiseasePredictionNotifier, PlantDiseasePredictionState>((ref) {
  final inferenceService = ref.watch(plantDiseaseInferenceServiceProvider);
  return PlantDiseasePredictionNotifier(
    inferenceService: inferenceService,
    ref: ref,
  );
});
