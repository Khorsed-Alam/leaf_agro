import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_agro/core/theme/app_colors.dart';
import 'package:leaf_agro/data/models/disease_model.dart';
import 'package:leaf_agro/data/models/prediction_model.dart';
import 'package:leaf_agro/data/models/recommendation_model.dart';
import 'package:leaf_agro/providers/crop_provider.dart';
import 'package:leaf_agro/providers/detection_provider.dart';
import 'package:leaf_agro/providers/disease_provider.dart';
import 'package:leaf_agro/providers/settings_provider.dart';
import 'widgets/agricultural_practices_section.dart';
import 'widgets/detected_disease_summary_card.dart';
import 'widgets/immediate_actions_card.dart';
import 'widgets/prevention_nav_button.dart';
import 'widgets/safe_handling_reminders_card.dart';
import 'widgets/step_by_step_recommendations_card.dart';
import 'widgets/treatment_header.dart';
import 'widgets/treatment_not_found_view.dart';
import 'widgets/treatment_skeleton.dart';
import 'widgets/treatment_sources_section.dart';
import 'widgets/verified_treatments_section.dart';

/// Screen 18 – Treatment Recommendations Screen
/// Comprehensive agronomic guidance for farmers following plant disease detection.
/// Enforces pesticide safety rules, step-by-step action plans, and verified recommendations.
class TreatmentScreen extends ConsumerStatefulWidget {
  final int diseaseId;
  final bool isSample;
  final DiseaseModel? initialDisease;
  final PredictionModel? initialPrediction;
  final String? initialImagePath;

  const TreatmentScreen({
    super.key,
    required this.diseaseId,
    this.isSample = false,
    this.initialDisease,
    this.initialPrediction,
    this.initialImagePath,
  });

  @override
  ConsumerState<TreatmentScreen> createState() => _TreatmentScreenState();
}

class _TreatmentScreenState extends ConsumerState<TreatmentScreen> {
  @override
  Widget build(BuildContext context) {
    final isBn = ref.watch(settingsProvider).language == 'bn';

    // Fast-path if initial disease model is provided (e.g., tests or preview)
    if (widget.initialDisease != null) {
      final recsAsync =
          ref.watch(recommendationsByDiseaseProvider(widget.diseaseId));
      final recs = recsAsync.valueOrNull ?? [];
      return _buildContent(widget.initialDisease!, recs, isBn);
    }

    final diseaseAsync = ref.watch(diseaseByIdProvider(widget.diseaseId));

    return diseaseAsync.when(
      data: (disease) {
        if (disease == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: TreatmentHeader(isBn: isBn),
            body: TreatmentNotFoundView(isBn: isBn),
          );
        }
        final recsAsync =
            ref.watch(recommendationsByDiseaseProvider(widget.diseaseId));
        final recs = recsAsync.valueOrNull ?? [];
        return _buildContent(disease, recs, isBn);
      },
      loading: () => Scaffold(
        backgroundColor: AppColors.background,
        appBar: TreatmentHeader(isBn: isBn),
        body: const TreatmentSkeleton(),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: TreatmentHeader(isBn: isBn),
        body: _buildErrorView(isBn, err.toString()),
      ),
    );
  }

  Widget _buildContent(
    DiseaseModel disease,
    List<RecommendationModel> recs,
    bool isBn,
  ) {
    final cropAsync = ref.watch(cropByIdProvider(disease.cropId));
    final crop = cropAsync.valueOrNull;

    // Retrieve active detection context if present
    final detectionState = ref.watch(detectionProvider);
    final activePrediction =
        widget.initialPrediction ?? detectionState.prediction;
    final activeImage = widget.initialImagePath ?? detectionState.imagePath;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TreatmentHeader(isBn: isBn),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.forestGreen,
          onRefresh: () async {
            ref.invalidate(diseaseByIdProvider(widget.diseaseId));
            ref.invalidate(recommendationsByDiseaseProvider(widget.diseaseId));
            ref.invalidate(cropByIdProvider(disease.cropId));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),

                // 1. Detected Disease Summary Card (with original image & confidence score)
                DetectedDiseaseSummaryCard(
                  disease: disease,
                  crop: crop,
                  prediction: activePrediction,
                  imagePath: activeImage,
                  isBn: isBn,
                  isSample: widget.isSample || disease.isSample,
                ),

                // 2. What to Do First (Numbered immediate actions)
                ImmediateActionsCard(
                  disease: disease,
                  isBn: isBn,
                ),

                // 3. Agricultural Management Practices (Cultural sanitation, water, nutrients)
                AgriculturalPracticesSection(
                  disease: disease,
                  crop: crop,
                  isBn: isBn,
                ),

                // 4. Verified Recommended Treatment Options (with strict pesticide restrictions)
                VerifiedTreatmentsSection(
                  disease: disease,
                  recommendations: recs,
                  isBn: isBn,
                ),

                // 5. Step-by-Step Recommendation Sequence
                StepByStepRecommendationsCard(isBn: isBn),

                // 6. Important Safety Reminders (PPE, storage, mixing precautions)
                SafeHandlingRemindersCard(isBn: isBn),

                // 7. Source & Verification Information (BRRI, BARI, DAE)
                TreatmentSourcesSection(
                  recommendations: recs,
                  isBn: isBn,
                ),

                // 8. Prevention Tips Navigation Button
                PreventionNavButton(
                  disease: disease,
                  isBn: isBn,
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(bool isBn, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: Color(0xFFDC2626),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isBn
                  ? 'চিকিৎসা নির্দেশিকা লোড করা সম্ভব হয়নি'
                  : 'Unable to Load Treatment Guidance',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isBn
                  ? 'অনুগ্রহ করে নেটওয়ার্ক সংযোগ পরীক্ষা করে আবার চেষ্টা করুন।'
                  : 'Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestGreen,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(isBn ? 'পুনরায় চেষ্টা করুন' : 'Retry'),
              onPressed: () {
                ref.invalidate(diseaseByIdProvider(widget.diseaseId));
                ref.invalidate(
                    recommendationsByDiseaseProvider(widget.diseaseId));
              },
            ),
          ],
        ),
      ),
    );
  }
}
