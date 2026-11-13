import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/local/tflite_datasource.dart';
import '../data/models/prediction_model.dart';
import '../data/models/disease_model.dart';
import '../data/models/recommendation_model.dart';
import '../data/repositories/detection_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum DetectionStatus { initial, imageSelected, analyzing, success, error }

class DetectionState {
  final DetectionStatus status;
  final String? imagePath;
  final PredictionModel? prediction;
  final DiseaseModel? diseaseDetails;
  final List<RecommendationModel> recommendations;
  final String? errorMessage;

  const DetectionState({
    this.status = DetectionStatus.initial,
    this.imagePath,
    this.prediction,
    this.diseaseDetails,
    this.recommendations = const [],
    this.errorMessage,
  });

  DetectionState copyWith({
    DetectionStatus? status,
    String? imagePath,
    PredictionModel? prediction,
    DiseaseModel? diseaseDetails,
    List<RecommendationModel>? recommendations,
    String? errorMessage,
  }) {
    return DetectionState(
      status: status ?? this.status,
      imagePath: imagePath ?? this.imagePath,
      prediction: prediction ?? this.prediction,
      diseaseDetails: diseaseDetails ?? this.diseaseDetails,
      recommendations: recommendations ?? this.recommendations,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final tfliteDataSourceProvider = Provider<TfliteDataSource>((ref) {
  final ds = TfliteDataSource();
  ref.onDispose(() => ds.dispose());
  return ds;
});

final detectionRepositoryProvider = Provider<DetectionRepository>((ref) {
  return DetectionRepository(ref.watch(tfliteDataSourceProvider));
});

class DetectionNotifier extends StateNotifier<DetectionState> {
  final DetectionRepository _repository;

  DetectionNotifier(this._repository) : super(const DetectionState());

  void selectImage(String path) {
    state = state.copyWith(
      status: DetectionStatus.imageSelected,
      imagePath: path,
      errorMessage: null,
    );
  }

  Future<void> runDetection() async {
    final imagePath = state.imagePath;
    if (imagePath == null) return;

    state = state.copyWith(status: DetectionStatus.analyzing);

    try {
      final prediction = await _repository.detectPlantDisease(imagePath);

      // Fetch matched disease details & recommendations from Supabase if online
      DiseaseModel? diseaseDetails;
      List<RecommendationModel> recs = [];

      try {
        final client = Supabase.instance.client;
        final diseaseRow = await client
            .from('disease_catalog')
            .select()
            .eq('class_name', prediction.className)
            .maybeSingle();

        if (diseaseRow != null) {
          diseaseDetails = DiseaseModel.fromJson(diseaseRow);
          final recRows = await client
              .from('recommendations')
              .select()
              .eq('disease_id', diseaseDetails.id);
          recs = (recRows as List).map((r) => RecommendationModel.fromJson(r)).toList();
        }
      } catch (_) {}

      state = state.copyWith(
        status: DetectionStatus.success,
        prediction: prediction,
        diseaseDetails: diseaseDetails,
        recommendations: recs,
      );
    } catch (e) {
      state = state.copyWith(
        status: DetectionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = const DetectionState();
  }
}

final detectionProvider =
    StateNotifierProvider<DetectionNotifier, DetectionState>((ref) {
  return DetectionNotifier(ref.watch(detectionRepositoryProvider));
});

