import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_agro/core/theme/app_colors.dart';
import 'package:leaf_agro/data/models/crop_model.dart';
import 'package:leaf_agro/data/models/disease_model.dart';
import 'package:leaf_agro/data/models/recommendation_model.dart';
import 'package:leaf_agro/providers/crop_provider.dart';
import 'package:leaf_agro/providers/disease_provider.dart';
import 'package:leaf_agro/providers/settings_provider.dart';
import 'widgets/prevention/crop_specific_advice_section.dart';
import 'widgets/prevention/disease_specific_prevention_section.dart';
import 'widgets/prevention/essential_practices_section.dart';
import 'widgets/prevention/healthy_crop_hero_section.dart';
import 'widgets/prevention/prevention_checklist_card.dart';
import 'widgets/prevention/prevention_header.dart';
import 'widgets/prevention/prevention_not_found_view.dart';
import 'widgets/prevention/prevention_skeleton.dart';
import 'widgets/prevention/selected_crop_context_card.dart';

/// Screen 19 – Prevention & Plant Care Screen
/// Interactive educational crop protection guide for Bangladeshi farmers.
/// Delivers crop-specific agronomic advice, disease-specific protocols,
/// 6 essential prevention principles, and a functional prevention checklist.
class PreventionScreen extends ConsumerStatefulWidget {
  final int? diseaseId;
  final int? cropId;
  final DiseaseModel? initialDisease;
  final CropModel? initialCrop;

  const PreventionScreen({
    super.key,
    this.diseaseId,
    this.cropId,
    this.initialDisease,
    this.initialCrop,
  });

  @override
  ConsumerState<PreventionScreen> createState() => _PreventionScreenState();
}

class _PreventionScreenState extends ConsumerState<PreventionScreen> {
  CropModel? _userSelectedCrop;

  @override
  Widget build(BuildContext context) {
    final isBn = ref.watch(settingsProvider).language == 'bn';

    // Fast-path if mock or initial models are provided (e.g., tests or preview)
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
              appBar: PreventionHeader(isBn: isBn),
              body: PreventionNotFoundView(isBn: isBn),
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
          appBar: PreventionHeader(isBn: isBn),
          body: const PreventionSkeleton(),
        ),
        error: (err, _) => _buildErrorScaffold(isBn, err.toString()),
      );
    }

    // 2. General crop prevention flow (no diseaseId passed)
    final globalSelectedCrop = ref.watch(selectedCropProvider);
    final effectiveCropId =
        _userSelectedCrop?.id ?? widget.cropId ?? globalSelectedCrop?.id ?? 1;
    final cropAsync = ref.watch(cropByIdProvider(effectiveCropId));

    return cropAsync.when(
      data: (crop) {
        final activeCrop = _userSelectedCrop ?? crop ?? globalSelectedCrop;
        return _buildScaffold(activeCrop, null, const [], isBn);
      },
      loading: () => Scaffold(
        backgroundColor: AppColors.background,
        appBar: PreventionHeader(isBn: isBn),
        body: const PreventionSkeleton(),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreventionHeader(isBn: isBn),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.forestGreen,
          onRefresh: () async {
            if (widget.diseaseId != null) {
              ref.invalidate(diseaseByIdProvider(widget.diseaseId!));
              ref.invalidate(
                  recommendationsByDiseaseProvider(widget.diseaseId!));
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

                // 1. Healthy Crop Hero Section (with realistic expectations)
                HealthyCropHeroSection(
                  crop: crop,
                  isBn: isBn,
                ),

                // 2. Selected Crop Information & Crop Switcher
                SelectedCropContextCard(
                  selectedCrop: crop,
                  selectedDisease: disease,
                  isBn: isBn,
                  onCropChanged: (newCrop) {
                    setState(() {
                      _userSelectedCrop = newCrop;
                    });
                  },
                ),

                // 3. Disease-Specific Prevention (Only rendered when disease context exists)
                if (disease != null)
                  DiseaseSpecificPreventionSection(
                    disease: disease,
                    recommendations: recs,
                    isBn: isBn,
                  ),

                // 4. Crop-Specific Agronomic Advice (Tailored per crop)
                CropSpecificAdviceSection(
                  crop: crop,
                  isBn: isBn,
                ),

                // 5. Essential Prevention Practices (6 foundation cards)
                EssentialPracticesSection(isBn: isBn),

                // 6. Interactive Prevention Checklist & Progress Tracker
                PreventionChecklistCard(
                  crop: crop,
                  isBn: isBn,
                ),

                const SizedBox(height: 36),
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
      appBar: PreventionHeader(isBn: isBn),
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
                    ? 'প্রতিরোধ তথ্য লোড করা সম্ভব হয়নি'
                    : 'Unable to Load Prevention Guidance',
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
                    ? 'নেটওয়ার্ক সংযোগ পরীক্ষা করে আবার চেষ্টা করুন।'
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
                  if (widget.diseaseId != null) {
                    ref.invalidate(diseaseByIdProvider(widget.diseaseId!));
                  }
                  if (widget.cropId != null) {
                    ref.invalidate(cropByIdProvider(widget.cropId!));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
