import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/datasources/ai_crop_catalog.dart';
import '../../../../data/models/crop_model.dart';
import '../../../../data/models/disease_model.dart';
import '../../../../data/models/prediction_model.dart';
import '../../../../data/models/recommendation_model.dart';
import '../../../../providers/crop_provider.dart';
import '../../../../providers/detection_provider.dart';
import '../../../../providers/disease_provider.dart';
import '../../../../providers/settings_provider.dart';
import 'widgets/solutions/agricultural_officer_guidance_card.dart';
import 'widgets/solutions/agricultural_safety_section.dart';
import 'widgets/solutions/biological_management_section.dart';
import 'widgets/solutions/crop_protection_products_section.dart';
import 'widgets/solutions/cultural_management_section.dart';
import 'widgets/solutions/regulatory_warning_card.dart';
import 'widgets/solutions/solutions_disease_summary_card.dart';
import 'widgets/solutions/solutions_header.dart';
import 'widgets/solutions/solutions_not_found_view.dart';
import 'widgets/solutions/solutions_skeleton.dart';

/// Screen 20 – Product & Solution Information Screen
/// Educational, farmer-friendly agricultural disease-management guidance.
/// Covers biological control, cultural practices, crop protection principles,
/// and essential agricultural chemical safety.
/// Purely informative: strictly non-commercial with no shopping cart or sales.
class SolutionsScreen extends ConsumerStatefulWidget {
  final int? diseaseId;
  final int? cropId;
  final DiseaseModel? initialDisease;
  final CropModel? initialCrop;
  final PredictionModel? initialPrediction;
  final String? initialImagePath;

  const SolutionsScreen({
    super.key,
    this.diseaseId,
    this.cropId,
    this.initialDisease,
    this.initialCrop,
    this.initialPrediction,
    this.initialImagePath,
  });

  @override
  ConsumerState<SolutionsScreen> createState() => _SolutionsScreenState();
}

class _SolutionsScreenState extends ConsumerState<SolutionsScreen> {
  CropModel? _userSelectedCrop;

  @override
  Widget build(BuildContext context) {
    final isBn = ref.watch(settingsProvider).language == 'bn';

    // Fast-path if initial models are provided (e.g. tests or direct preview)
    if (widget.initialCrop != null || widget.initialDisease != null) {
      final crop = _userSelectedCrop ?? widget.initialCrop;
      final disease = widget.initialDisease;
      final recsAsync = disease != null
          ? ref.watch(recommendationsByDiseaseProvider(disease.id))
          : const AsyncValue<List<RecommendationModel>>.data([]);
      final recs = recsAsync.valueOrNull ?? [];

      return _buildScaffold(crop, disease, recs, isBn);
    }

    // 1. If diseaseId is provided, resolve DiseaseModel first
    if (widget.diseaseId != null) {
      final diseaseAsync = ref.watch(diseaseByIdProvider(widget.diseaseId!));

      return diseaseAsync.when(
        data: (disease) {
          if (disease == null) {
            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: SolutionsHeader(isBn: isBn),
              body: SolutionsNotFoundView(isBn: isBn),
            );
          }

          final effectiveCropId =
              _userSelectedCrop?.id ?? widget.cropId ?? disease.cropId;
          final cropAsync = ref.watch(cropByIdProvider(effectiveCropId));
          final recsAsync =
              ref.watch(recommendationsByDiseaseProvider(disease.id));
          final recs = recsAsync.valueOrNull ?? [];
          final crop = cropAsync.valueOrNull ?? _userSelectedCrop;

          return _buildScaffold(crop, disease, recs, isBn);
        },
        loading: () => Scaffold(
          backgroundColor: AppColors.background,
          appBar: SolutionsHeader(isBn: isBn),
          body: const SolutionsSkeleton(),
        ),
        error: (err, _) => _buildErrorScaffold(isBn, err.toString()),
      );
    }

    // 2. Standalone general crop solution flow (no diseaseId provided)
    final globalSelectedCrop = ref.watch(selectedCropProvider);
    final effectiveCropId =
        _userSelectedCrop?.id ?? widget.cropId ?? globalSelectedCrop?.id ?? 1;
    final cropAsync = ref.watch(cropByIdProvider(effectiveCropId));

    return cropAsync.when(
      data: (crop) {
        final activeCrop = crop ??
            _userSelectedCrop ??
            AiCropCatalog.verifiedSupportedCrops.first;
        return _buildScaffold(activeCrop, null, const [], isBn);
      },
      loading: () => Scaffold(
        backgroundColor: AppColors.background,
        appBar: SolutionsHeader(isBn: isBn),
        body: const SolutionsSkeleton(),
      ),
      error: (err, _) => _buildErrorScaffold(isBn, err.toString()),
    );
  }

  Widget _buildScaffold(
    CropModel? crop,
    DiseaseModel? disease,
    List<RecommendationModel> recs,
    bool isBn,
  ) {
    final detectionState = ref.watch(detectionProvider);
    final activePrediction =
        widget.initialPrediction ?? detectionState.prediction;
    final activeImage = widget.initialImagePath ?? detectionState.imagePath;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SolutionsHeader(isBn: isBn),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.forestGreen,
          onRefresh: () async {
            if (disease != null) {
              ref.invalidate(diseaseByIdProvider(disease.id));
              ref.invalidate(recommendationsByDiseaseProvider(disease.id));
            }
            if (crop != null) {
              ref.invalidate(cropByIdProvider(crop.id));
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),

                // 1. Selected Disease & Crop Summary Card
                SolutionsDiseaseSummaryCard(
                  crop: crop,
                  disease: disease,
                  prediction: activePrediction,
                  imagePath: activeImage,
                  isBn: isBn,
                  onCropChanged: (newCrop) {
                    setState(() {
                      _userSelectedCrop = newCrop;
                    });
                  },
                ),

                // 2. Biological Management Options
                BiologicalManagementSection(
                  recommendations: recs,
                  isBn: isBn,
                ),

                // 3. Cultural Management Options
                CulturalManagementSection(
                  crop: crop,
                  disease: disease,
                  recommendations: recs,
                  isBn: isBn,
                ),

                // 4. Crop Protection Product Information (Educational, Non-Commercial)
                CropProtectionProductsSection(isBn: isBn),

                // 5. Agricultural Safety Information Cards
                AgriculturalSafetySection(isBn: isBn),

                // 6. Agricultural Officer Guidance Card with Screen 18 Navigation CTA
                AgriculturalOfficerGuidanceCard(
                  disease: disease,
                  isBn: isBn,
                ),

                // 7. Important Regulatory Warning
                RegulatoryWarningCard(isBn: isBn),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScaffold(bool isBn, String error) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SolutionsHeader(isBn: isBn),
      body: Center(
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
                    ? 'সমাধান সংক্রান্ত তথ্য লোড করা যায়নি'
                    : 'Unable to Load Solution Information',
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
                    ? 'সার্ভার বা নেটওয়ার্ক সংযোগে সমস্যা হয়েছে। পুনরায় চেষ্টা করুন।'
                    : 'Network or database error occurred. Please check your connection and retry.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryText,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestGreen,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (widget.diseaseId != null) {
                    ref.invalidate(diseaseByIdProvider(widget.diseaseId!));
                  }
                  if (widget.cropId != null) {
                    ref.invalidate(cropByIdProvider(widget.cropId!));
                  }
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  isBn ? 'পুনরায় চেষ্টা করুন' : 'Retry',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
