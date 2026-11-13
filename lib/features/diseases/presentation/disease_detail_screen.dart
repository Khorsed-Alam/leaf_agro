import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/disease_model.dart';
import '../../../providers/crop_provider.dart';
import '../../../providers/disease_provider.dart';
import '../../../providers/settings_provider.dart';
import 'widgets/details/disease_action_buttons.dart';
import 'widgets/details/disease_causes_card.dart';
import 'widgets/details/disease_detail_header.dart';
import 'widgets/details/disease_detail_skeleton.dart';
import 'widgets/details/disease_hero_section.dart';
import 'widgets/details/disease_not_found_view.dart';
import 'widgets/details/disease_overview_card.dart';
import 'widgets/details/disease_severity_card.dart';
import 'widgets/details/disease_symptoms_card.dart';
import 'widgets/details/disease_visible_signs_card.dart';
import 'widgets/details/related_diseases_section.dart';

/// Screen 17 – Disease Details Screen
/// Educational disease information page providing verified botanical profiles,
/// field symptoms, visible foliar signs, pathogen causes, and direct routing
/// to verified treatment and prevention guidance.
class DiseaseDetailScreen extends ConsumerStatefulWidget {
  final int diseaseId;
  final bool isSample;
  final DiseaseModel? initialDisease;

  const DiseaseDetailScreen({
    super.key,
    required this.diseaseId,
    this.isSample = false,
    this.initialDisease,
  });

  @override
  ConsumerState<DiseaseDetailScreen> createState() =>
      _DiseaseDetailScreenState();
}

class _DiseaseDetailScreenState extends ConsumerState<DiseaseDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final isBn = ref.watch(settingsProvider).language == 'bn';

    // If an initial disease model is passed directly, use it; otherwise fetch from provider
    if (widget.initialDisease != null) {
      return _buildContent(widget.initialDisease!, isBn);
    }

    final diseaseAsync = ref.watch(diseaseByIdProvider(widget.diseaseId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DiseaseDetailHeader(
        title: isBn ? 'রোগের বিস্তারিত' : 'Disease Details',
        isBn: isBn,
      ),
      body: diseaseAsync.when(
        data: (disease) {
          if (disease == null) {
            return DiseaseNotFoundView(isBn: isBn);
          }
          return _buildContent(disease, isBn);
        },
        loading: () => const DiseaseDetailSkeleton(),
        error: (err, _) => _buildErrorView(isBn, err.toString()),
      ),
    );
  }

  Widget _buildContent(DiseaseModel disease, bool isBn) {
    final cropAsync = ref.watch(cropByIdProvider(disease.cropId));
    final crop = cropAsync.valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DiseaseDetailHeader(
        title: isBn ? disease.diseaseNameBn : disease.diseaseNameEn,
        isBn: isBn,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.forestGreen,
          onRefresh: () async {
            ref.invalidate(diseaseByIdProvider(widget.diseaseId));
            ref.invalidate(cropByIdProvider(disease.cropId));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),

                // 1. Hero Card: Headline, Crop Pill, Image, Sample Content Banner
                DiseaseHeroSection(
                  disease: disease,
                  crop: crop,
                  isBn: isBn,
                  isSample: widget.isSample || disease.isSample,
                ),

                // 2. Action Buttons: Treatment and Prevention Navigation
                DiseaseActionButtons(
                  disease: disease,
                  isBn: isBn,
                ),

                // 3. Overview Card: Simple explanation of disease & plant impact
                DiseaseOverviewCard(
                  disease: disease,
                  crop: crop,
                  isBn: isBn,
                ),

                // 4. Common Symptoms Card: Structured checklist from verified data
                DiseaseSymptomsCard(
                  disease: disease,
                  isBn: isBn,
                ),

                // 5. Visible Signs on Leaves: Foliar warning signs for field scouting
                DiseaseVisibleSignsCard(
                  disease: disease,
                  isBn: isBn,
                ),

                // 6. Possible Causes: Pathogen organism & favorable environmental conditions
                DiseaseCausesCard(
                  disease: disease,
                  isBn: isBn,
                ),

                // 7. Disease Severity: Literature risk classification when supported
                DiseaseSeverityCard(
                  disease: disease,
                  isBn: isBn,
                ),

                // 8. Related Diseases: Other catalogued diseases affecting this crop
                RelatedDiseasesSection(
                  currentDisease: disease,
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
                  ? 'তথ্য লোড করা সম্ভব হয়নি'
                  : 'Unable to Load Disease Information',
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
                ref.invalidate(diseaseByIdProvider(widget.diseaseId));
              },
            ),
          ],
        ),
      ),
    );
  }
}
