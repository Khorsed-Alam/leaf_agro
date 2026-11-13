import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../data/models/recommendation_model.dart';

/// Screen 20 – Biological Management Section
/// Educational presentation of verified biological control agents and beneficial microorganisms.
/// Transparently displays verified biological options or an honest unavailable notice.
class BiologicalManagementSection extends StatelessWidget {
  final List<RecommendationModel> recommendations;
  final bool isBn;

  const BiologicalManagementSection({
    super.key,
    required this.recommendations,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final bioRecs = recommendations
        .where((r) => r.recommendationType.toLowerCase() == 'biological')
        .toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGreen),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestGreen.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: Color(0xFF059669),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBn ? 'জৈবিক ব্যবস্থাপনা' : 'Biological Management',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.forestGreen,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isBn
                          ? 'কিছু উদ্ভিদের রোগ ব্যবস্থাপনায় প্রাসঙ্গিক হতে পারে এমন জৈবিক উপায়গুলো জানুন।'
                          : 'Explore biological approaches that may be relevant to managing certain plant diseases.',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // If no verified biological information exists for this crop & disease
          if (bioRecs.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderGreen),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.secondaryText,
                    size: 19,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBn
                              ? 'এই ফসল ও রোগের জন্য কোনো যাচাইকৃত জৈবিক ব্যবস্থাপনা তথ্য বর্তমানে উপলব্ধ নেই।'
                              : 'No verified biological management information is currently available for this crop and disease.',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isBn
                              ? 'সরকারি কৃষি গবেষণা প্রতিষ্ঠানসমূহ (যেমন ব্রি, বারি) নির্দিষ্ট রোগ প্রতিরোধী জীবাণু মাঠপর্যায়ে মূল্যায়নের পরই কেবল সুপারিশ করে থাকে।'
                              : 'National agricultural research institutes (e.g., BRRI, BARI) endorse biological control agents only after formal multi-season field efficacy trials.',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.secondaryText,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Render verified biological options
            ...bioRecs.map((rec) => _buildBiologicalCard(rec)),
          ],
        ],
      ),
    );
  }

  Widget _buildBiologicalCard(RecommendationModel rec) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FDF9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGreen),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title & Category Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  isBn ? rec.titleBn : rec.titleEn,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.forestGreen,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Text(
                  isBn ? 'জৈব নিয়ন্ত্রণ' : 'Biocontrol Agent',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF047857),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Short practical explanation
          Text(
            isBn ? rec.contentBn : rec.contentEn,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.primaryText,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 10),

          // When it may be appropriate
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  color: Color(0xFF059669),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.primaryText,
                        height: 1.35,
                      ),
                      children: [
                        TextSpan(
                          text: isBn ? 'কখন প্রযোজ্য: ' : 'When Appropriate: ',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(
                          text: isBn
                              ? 'বীজ শোধন, চারা রোপণের পূর্বে বা রোগের প্রাথমিক লক্ষণ প্রকাশের সময় প্রতিরোধমূলক ব্যবস্থা হিসেবে।'
                              : 'Seed treatment, nursery soil blending, or preventive foliar colonization prior to extensive pathogen establishment.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Limitations & Precautions
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFD97706),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF92400E),
                        height: 1.35,
                      ),
                      children: [
                        TextSpan(
                          text: isBn
                              ? 'সীমাবদ্ধতা ও সতর্কতা: '
                              : 'Limitations & Precautions: ',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(
                          text: isBn
                              ? 'জৈব উপাদান মরে যাওয়া টিস্যু আরোগ্য করে না। এগুলো ঠাণ্ডা ছায়াযুক্ত স্থানে রাখতে হবে এবং সরাসরি রাসায়নিক বালাইনাশকের সাথে মেশানো নিষেধ।'
                              : 'Biological agents suppress rather than cure established necrotic tissue. Must be stored in cool shade and never combined with incompatible chemical biocides.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (rec.sourceName != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.verified_outlined,
                  color: AppColors.secondary,
                  size: 14,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    isBn
                        ? 'উৎস: ${rec.sourceName}'
                        : 'Source: ${rec.sourceName}',
                    style: const TextStyle(
                      fontSize: 11,
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
}
