import 'package:flutter/material.dart';
import 'package:leaf_agro/core/theme/app_colors.dart';

/// Screen 18 – Step-by-Step Recommendation Sequence Card
/// Easy-to-follow chronological stages for field management.
class StepByStepRecommendationsCard extends StatelessWidget {
  final bool isBn;

  const StepByStepRecommendationsCard({
    super.key,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      _TreatmentStep(
        stepNumber: isBn ? 'ধাপ ১' : 'Step 1',
        title: isBn ? 'ফসল ও জমি পর্যবেক্ষণ' : 'Inspect the Crop & Field',
        description: isBn
            ? 'আক্রান্ত গাছের লক্ষণ ও পার্শ্ববর্তী উদ্ভিদের অবস্থা নিবিড়ভাবে পরীক্ষা করুন।'
            : 'Carefully assess lesion spread across affected foliage and neighbouring rows.',
        icon: Icons.search_rounded,
      ),
      _TreatmentStep(
        stepNumber: isBn ? 'ধাপ ২' : 'Step 2',
        title: isBn
            ? 'উপযুক্ত কৃষি ব্যবস্থাপনা প্রয়োগ'
            : 'Apply Cultural Management',
        description: isBn
            ? 'পানি নিষ্কাশন, সুষম সার প্রয়োগ ও আক্রান্ত অংশ সাবধানে পরিষ্কার রাখুন।'
            : 'Enforce drainage furrows, balanced nutrient application, and plant aeration.',
        icon: Icons.eco_rounded,
      ),
      _TreatmentStep(
        stepNumber: isBn ? 'ধাপ ৩' : 'Step 3',
        title: isBn ? 'অনুমোদিত সমাধান অনুসরণ' : 'Consult Verified Guidance',
        description: isBn
            ? 'উপজেলা কৃষি কর্মকর্তার অনুমোদন সাপেক্ষে লেবেল নির্দেশিকা অনুযায়ী ব্যবস্থা নিন।'
            : 'Follow official label directions under extension officer oversight where intervention is necessary.',
        icon: Icons.verified_user_rounded,
      ),
      _TreatmentStep(
        stepNumber: isBn ? 'ধাপ ৪' : 'Step 4',
        title: isBn ? 'ধারাবাহিক মনিটরিং' : 'Monitor Progress Regularly',
        description: isBn
            ? 'পরবর্তী ৫-৭ দিন নতুন পাতার বৃদ্ধি এবং লক্ষণের পরিবর্তন লক্ষ করুন।'
            : 'Monitor new leaf flushes over 5–7 days to ensure the infection has stabilized.',
        icon: Icons.visibility_rounded,
      ),
    ];

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
                  Icons.format_list_numbered_rounded,
                  size: 20,
                  color: AppColors.forestGreen,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isBn
                    ? 'পদক্ষেপভিত্তিক কর্মপরিকল্পনা'
                    : 'Step-by-Step Action Plan',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Steps
          Column(
            children: steps.map((s) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.forestGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        s.stepNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.title,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s.description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.secondaryText,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _TreatmentStep {
  final String stepNumber;
  final String title;
  final String description;
  final IconData icon;

  const _TreatmentStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.icon,
  });
}
