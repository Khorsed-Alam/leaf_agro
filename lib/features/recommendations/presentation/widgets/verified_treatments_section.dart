import 'package:flutter/material.dart';
import 'package:leaf_agro/core/theme/app_colors.dart';
import 'package:leaf_agro/data/models/disease_model.dart';
import 'package:leaf_agro/data/models/recommendation_model.dart';

/// Screen 18 – Verified Recommended Treatment Options Section
/// Renders verified recovery options with strict pesticide safety compliance.
class VerifiedTreatmentsSection extends StatelessWidget {
  final DiseaseModel disease;
  final List<RecommendationModel> recommendations;
  final bool isBn;

  const VerifiedTreatmentsSection({
    super.key,
    required this.disease,
    required this.recommendations,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final treatmentItems = recommendations
        .where((r) => r.recommendationType == 'treatment')
        .toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestGreen.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.softNaturalGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.medication_liquid_rounded,
                  size: 20,
                  color: AppColors.forestGreen,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isBn
                    ? 'অনুমোদিত চিকিৎসা ব্যবস্থা'
                    : 'Recommended Treatment Options',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Fallback or Verified Treatment List
          if (disease.isHealthy)
            _buildHealthyNotice()
          else if (treatmentItems.isEmpty)
            _buildUnavailableChemicalNotice()
          else
            Column(
              children: [
                ...treatmentItems.map((item) => _buildTreatmentCard(item)),
                const SizedBox(height: 12),
                _buildProductLabelMandatoryReminder(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHealthyNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF86EFAC)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.verified_rounded,
            size: 20,
            color: Color(0xFF15803D),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBn
                      ? 'কোনো বালাইনাশকের প্রয়োজন নেই'
                      : 'No Chemical Treatment Needed',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF14532D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isBn
                      ? 'উদ্ভিদটি সুস্থ অবস্থায় রয়েছে। অপ্রয়োজনীয় রাসায়নিক প্রয়োগ পরিবেশ ও ফসলের জন্য ক্ষতিকর।'
                      : 'The plant foliage appears healthy. Unnecessary chemical sprays harm natural predators and soil health.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF166534),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnavailableChemicalNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: Color(0xFFB45309),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isBn
                  ? 'বর্তমানে এই রোগের জন্য নির্দিষ্ট কোনো অনুমোদিত রাসায়নিক বালাইনাশক নির্দেশিকা তালিকাভুক্ত নেই। কীটনাশক ব্যবহারের পূর্বে অবশ্যই স্থানীয় উপজেলা কৃষি কর্মকর্তার পরামর্শ নিন।'
                  : 'Specific chemical treatment guidance is not available in the current verified information. Please consult your local agricultural extension officer before applying any pesticide.',
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF92400E),
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentCard(RecommendationModel item) {
    final title = isBn ? item.titleBn : item.titleEn;
    final content = isBn ? item.contentBn : item.contentEn;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.forestGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.healing_rounded,
                  size: 16,
                  color: AppColors.forestGreen,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
              if (item.isVerified)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 12,
                        color: Color(0xFF16A34A),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        isBn ? 'যাচাইকৃত' : 'Verified',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.primaryText,
              height: 1.5,
            ),
          ),
          if (item.sourceName != null && item.sourceName!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.source_outlined,
                  size: 13,
                  color: AppColors.secondaryText,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    isBn
                        ? 'উৎস: ${item.sourceName}'
                        : 'Source: ${item.sourceName}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.secondaryText,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductLabelMandatoryReminder() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: const Color(0xFFFCA5A5).withValues(alpha: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_rounded,
            size: 16,
            color: Color(0xFFDC2626),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isBn
                  ? 'বালাইনাশক ব্যবহারের পূর্বে অবশ্যই প্রস্তুতকারকের অনুমোদিত লেবেল এবং কৃষি সম্প্রসারণ অধিদপ্তরের (DAE) নির্দেশনা অনুসরণ করুন।'
                  : 'Always follow the registered product label instructions and local Department of Agricultural Extension (DAE) advice before applying any pesticide.',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF991B1B),
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
