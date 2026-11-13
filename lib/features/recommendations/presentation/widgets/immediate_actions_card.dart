import 'package:flutter/material.dart';
import 'package:leaf_agro/core/theme/app_colors.dart';
import 'package:leaf_agro/data/models/disease_model.dart';

/// Screen 18 – Immediate Actions Section ("What to Do First")
/// Actionable steps for farmers immediately upon identifying foliar symptoms.
class ImmediateActionsCard extends StatelessWidget {
  final DiseaseModel disease;
  final bool isBn;

  const ImmediateActionsCard({
    super.key,
    required this.disease,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final actions = _getImmediateSteps();

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
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.priority_high_rounded,
                  size: 20,
                  color: Color(0xFFD97706),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isBn ? 'প্রথমেই করণীয়' : 'What to Do First',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Action Steps
          Column(
            children: actions.map((action) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step Number Bubble
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: AppColors.forestGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          action.stepNumber,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                action.icon,
                                size: 16,
                                color: AppColors.forestGreen,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  action.heading,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            action.explanation,
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: AppColors.primaryText,
                              height: 1.45,
                            ),
                          ),
                          if (action.cautionNote != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    size: 13,
                                    color: Color(0xFFB45309),
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      action.cautionNote!,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF92400E),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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

  List<_ImmediateActionItem> _getImmediateSteps() {
    if (disease.isHealthy) {
      return [
        _ImmediateActionItem(
          stepNumber: '১' != '1' && isBn ? '১' : '1',
          icon: Icons.checklist_rounded,
          heading: isBn ? 'রুটিন মাঠ পরিদর্শন' : 'Routine Crop Scouting',
          explanation: isBn
              ? 'ফসলের চারপাশের জমিতে কোনো রোগজীবাণু বা পোকামাকড়ের আক্রমণ হচ্ছে কি না নিয়মিত নজর রাখুন।'
              : 'Continue regular field scouting across surrounding plots to detect any initial pest or foliar concerns early.',
        ),
        _ImmediateActionItem(
          stepNumber: isBn ? '২' : '2',
          icon: Icons.water_drop_outlined,
          heading:
              isBn ? 'পরিমিত সেচ ও সার' : 'Balanced Irrigation & Nutrients',
          explanation: isBn
              ? 'অতিরিক্ত সার বা অতিরিক্ত সেচ দেওয়া থেকে বিরত থাকুন যাতে গাছ শক্ত ও স্বাভাবিক থাকে।'
              : 'Maintain recommended irrigation schedules and avoid excessive nitrogen application to sustain vigor.',
        ),
      ];
    }

    return [
      _ImmediateActionItem(
        stepNumber: isBn ? '১' : '1',
        icon: Icons.search_rounded,
        heading: isBn
            ? 'আক্রান্ত গাছ ও চারপাশের জমি পরিদর্শন'
            : 'Inspect Affected Plants & Surrounding Field',
        explanation: isBn
            ? 'আক্রান্ত পাতার বিস্তার লক্ষ্য করুন এবং পার্শ্ববর্তী জমিতেও একই ধরনের দাগ রয়েছে কি না তা সতর্কতার সাথে পর্যবেক্ষণ করুন।'
            : 'Examine nearby plants to establish whether lesions are isolated or actively spreading across the plot boundary.',
        cautionNote: isBn
            ? 'অপ্রয়োজনে ভেজা পাতা স্পর্শ করে অন্যান্য গাছে রোগ ছড়াবেন না।'
            : 'Avoid handling wet foliage to prevent mechanical spore transfer.',
      ),
      _ImmediateActionItem(
        stepNumber: isBn ? '২' : '2',
        icon: Icons.water_outlined,
        heading: isBn
            ? 'সেচের পানি ও আর্দ্রতা নিয়ন্ত্রণ'
            : 'Manage Irrigation & Water Drainage',
        explanation: isBn
            ? 'জমিতে জমে থাকা পানি নিষ্কাশন করুন এবং বিকেলে পাতার ওপর পানি ছিটানো বন্ধ রাখুন যাতে রাতভর পাতা ভেজা না থাকে।'
            : 'Ensure proper field drainage and halt overhead sprinkler irrigation to reduce foliar moisture duration.',
        cautionNote: isBn
            ? 'দাঁড়িয়ে থাকা সেচের পানি জীবাণু ছড়ানোর প্রধান মাধ্যম।'
            : 'Standing water is a primary vector for bacterial and fungal transmission.',
      ),
      _ImmediateActionItem(
        stepNumber: isBn ? '৩' : '3',
        icon: Icons.support_agent_rounded,
        heading: isBn
            ? 'উপজেলা কৃষি কর্মকর্তার সাথে যোগাযোগ'
            : 'Consult Upazila Agriculture Extension Officer',
        explanation: isBn
            ? 'কোনো প্রকার রাসায়নিক প্রয়োগের পূর্বে স্থানীয় উপ-সহকারী কৃষি কর্মকর্তা (BS/SAAO)-এর সাথে লক্ষণগুলো মিলিয়ে নিশ্চিত পরামর্শ নিন।'
            : 'Consult your local Department of Agricultural Extension (DAE) Sub-Assistant Agriculture Officer for local field verification.',
      ),
    ];
  }
}

class _ImmediateActionItem {
  final String stepNumber;
  final IconData icon;
  final String heading;
  final String explanation;
  final String? cautionNote;

  const _ImmediateActionItem({
    required this.stepNumber,
    required this.icon,
    required this.heading,
    required this.explanation,
    this.cautionNote,
  });
}
