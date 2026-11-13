import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/prediction_history_model.dart';
import '../../../data/models/prediction_model.dart';
import '../../../providers/crop_provider.dart';
import '../../../providers/detection_provider.dart';
import '../../../providers/history_provider.dart';
import '../../../providers/settings_provider.dart';
import 'widgets/result/ai_prediction_card.dart';
import 'widgets/result/detection_disclaimer.dart';
import 'widgets/result/detection_result_header.dart';
import 'widgets/result/disease_actions_section.dart';
import 'widgets/result/healthy_actions_section.dart';
import 'widgets/result/result_error_view.dart';
import 'widgets/result/result_image_card.dart';
import 'widgets/result/save_result_button.dart';
import 'widgets/result/scan_another_button.dart';

/// Screen 16 – AI Detection Result Screen for AgriCare AI (LeafAgro)
/// Displays the genuine AI diagnosis, confidence score, certainty distinction,
/// crop-specific treatment/prevention recommendations, and scan log saving.
class DetectionResultScreen extends ConsumerStatefulWidget {
  final PredictionModel? initialPrediction;
  final String? initialImagePath;

  const DetectionResultScreen({
    super.key,
    this.initialPrediction,
    this.initialImagePath,
  });

  @override
  ConsumerState<DetectionResultScreen> createState() =>
      _DetectionResultScreenState();
}

class _DetectionResultScreenState extends ConsumerState<DetectionResultScreen> {
  SaveState _saveState = SaveState.initial;

  Future<void> _handleSaveResult(
    PredictionModel prediction,
    String? imagePath,
    int? diseaseId,
  ) async {
    if (_saveState == SaveState.saving || _saveState == SaveState.saved) return;

    final isBn = ref.read(settingsProvider).language == 'bn';

    setState(() {
      _saveState = SaveState.saving;
    });

    try {
      String userId = 'guest';
      try {
        final currentUser = Supabase.instance.client.auth.currentUser;
        if (currentUser != null && currentUser.id.isNotEmpty) {
          userId = currentUser.id;
        }
      } catch (_) {}

      final historyRecord = PredictionHistoryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        diseaseId: diseaseId,
        predictedClass: prediction.className,
        confidence: prediction.confidence,
        imagePath: imagePath,
        modelVersion: prediction.modelVersion,
        createdAt: DateTime.now(),
        syncStatus: 'pending',
      );

      await ref.read(historyProvider.notifier).addScanRecord(historyRecord);

      if (!mounted) return;

      setState(() {
        _saveState = SaveState.saved;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isBn
                ? 'ফলাফল সফলভাবে ফিল্ড হিস্ট্রিতে সংরক্ষিত হয়েছে!'
                : 'Diagnosis successfully saved to field history!',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.forestGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saveState = SaveState.error;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isBn
                ? 'সংরক্ষণ ব্যর্থ হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।'
                : 'Failed to save result. Please try again.',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _handleScanAnother() {
    ref.read(detectionProvider.notifier).reset();
    try {
      context.go('/detect');
    } catch (_) {
      Navigator.of(context).maybePop();
    }
  }

  void _handleReturnHome() {
    try {
      context.go('/home');
    } catch (_) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBn = ref.watch(settingsProvider).language == 'bn';
    final detectionState = ref.watch(detectionProvider);
    final selectedCrop = ref.watch(selectedCropProvider);

    final prediction = widget.initialPrediction ?? detectionState.prediction;
    final imagePath = widget.initialImagePath ?? detectionState.imagePath;

    // Determine crop name
    final cropName = selectedCrop != null
        ? (isBn ? selectedCrop.nameBn : selectedCrop.nameEn)
        : (prediction?.cropName.isNotEmpty == true
            ? prediction?.cropName
            : null);

    if (prediction == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: ResultErrorView(
            errorMessage: detectionState.errorMessage,
            onScanAnother: _handleScanAnother,
            onReturnHome: _handleReturnHome,
            isBn: isBn,
          ),
        ),
      );
    }

    final isHealthy = prediction.isHealthy;
    final diseaseDetails = detectionState.diseaseDetails;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Screen Header (Heading, Subtitle, Exit Button)
              DetectionResultHeader(
                isBn: isBn,
                onClose: _handleReturnHome,
              ),

              // 2. Uploaded Leaf Image Card with Status Badge Overlay
              if (imagePath != null && imagePath.isNotEmpty)
                ResultImageCard(
                  imagePath: imagePath,
                  cropName: cropName,
                  isHealthy: isHealthy,
                  isBn: isBn,
                ),

              // 3. Main AI Prediction Card (Disease Name, Confidence %, Certainty note, Summary)
              AiPredictionCard(
                prediction: prediction,
                diseaseDescription: isBn
                    ? diseaseDetails?.symptomsBn
                    : diseaseDetails?.symptomsEn,
                isBn: isBn,
              ),

              // 4. Result-Specific Actions
              if (isHealthy)
                HealthyActionsSection(isBn: isBn)
              else
                DiseaseActionsSection(
                  diseaseId: diseaseDetails?.id,
                  isBn: isBn,
                ),

              const SizedBox(height: 6),

              // 5. Save Result Action Button
              SaveResultButton(
                onSave: () => _handleSaveResult(
                  prediction,
                  imagePath,
                  diseaseDetails?.id,
                ),
                state: _saveState,
                isBn: isBn,
              ),

              // 6. Scan Another Plant Action Button
              ScanAnotherButton(
                onScanAnother: _handleScanAnother,
                isBn: isBn,
              ),

              // 7. Trustworthy AI Disclaimer
              DetectionDisclaimer(isBn: isBn),
            ],
          ),
        ),
      ),
    );
  }
}
