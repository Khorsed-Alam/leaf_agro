import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Screen 21 – Follow-up Inspection Suggestions
/// Guides farmers on practical visual observations to make when revisiting their crop.
/// Transparent: Strictly general observation suggestions, not guaranteed recovery metrics.
class FollowUpSuggestionsSection extends StatelessWidget {
  final bool isBn;

  const FollowUpSuggestionsSection({
    super.key,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      _InspectionItem(
        icon: Icons.filter_vintage_outlined,
        titleEn: 'Leaf Appearance',
        titleBn: 'পাতার বাহ্যিক রূপ',
        descEn:
            'Observe whether leaf spots, discoloration, lesions, or curling appear to be changing, fading, or spreading.',
        descBn:
            'পাতার দাগ, বিবর্ণতা, ক্ষত বা কোকড়ানো লক্ষণগুলো পরিবর্তিত হচ্ছে, কমছে বা বাড়ছে কিনা তা খেয়াল করুন।',
      ),
      _InspectionItem(
        icon: Icons.spa_outlined,
        titleEn: 'New Leaf Growth',
        titleBn: 'নতুন পাতার বৃদ্ধি',
        descEn:
            'Look for new green leaves or fresh shoots where appropriate for the crop growth stage. Note their appearance.',
        descBn:
            'গাছের বৃদ্ধির স্তর অনুযায়ী নতুন সবুজ পাতা বা কচি ডগা গজাতে শুরু করেছে কিনা তা পর্যবেক্ষণ করুন।',
      ),
      _InspectionItem(
        icon: Icons.hub_outlined,
        titleEn: 'Spread of Symptoms',
        titleBn: 'রোগের বিস্তার',
        descEn:
            'Check whether affected areas have expanded to neighboring leaves, branches, or adjacent plants in the field.',
        descBn:
            'আক্রান্ত দাগ বা লক্ষণগুলো পাশের সুস্থ পাতা, ডাল বা জমির আশেপাশের গাছে ছড়িয়ে পড়ছে কিনা তা খতিয়ে দেখুন।',
      ),
      _InspectionItem(
        icon: Icons.wb_sunny_outlined,
        titleEn: 'Overall Plant Condition',
        titleBn: 'গাছের সামগ্রিক সতেজতা',
        descEn:
            'Assess overall plant vigor, wilting levels, standing firmness, and general vitality under field conditions.',
        descBn:
            'গাছটি নুয়ে পড়ছে কিনা, সামগ্রিক সতেজতা বা বৃদ্ধির কোনো দৃশ্যমান পরিবর্তন আছে কিনা তা মূল্যায়ন করুন।',
      ),
      _InspectionItem(
        icon: Icons.medical_services_outlined,
        titleEn: 'Treatment & Care Actions',
        titleBn: 'প্রয়োগকৃত সেবা ও সার',
        descEn:
            'Take note of any bio-fungicides, irrigation adjustments, soil aeration, or pruning carried out since last inspection.',
        descBn:
            'পূর্ববর্তী পর্যবেক্ষণের পর থেকে সেচ, অনুমোদিত বালাইনাশক প্রয়োগ, নিড়ানি বা আক্রান্ত পাতা ছাঁটাইয়ের তথ্য লিপিবদ্ধ করুন।',
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderGreen,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.forestGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.checklist_rounded,
                  size: 18,
                  color: AppColors.forestGreen,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBn ? 'ফলো-আপ পর্যবেক্ষণ' : 'Follow-up Inspection',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.forestGreen,
                      ),
                    ),
                    Text(
                      isBn
                          ? 'নিয়মিত আপনার গাছ পর্যবেক্ষণ করুন এবং লক্ষণীয় পরিবর্তন লিখে রাখুন।'
                          : 'Regularly observe your plant and record any noticeable changes.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Suggestion list
          ...suggestions.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        item.icon,
                        size: 18,
                        color: AppColors.forestGreen,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBn ? item.titleBn : item.titleEn,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isBn ? item.descBn : item.descEn,
                            style: const TextStyle(
                              fontSize: 12,
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
            ),
          ),

          // Note disclaimer
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.freshGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.forestGreen,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isBn
                        ? 'এগুলো সাধারণ পর্যবেক্ষণ পরামর্শ। নতুন পাতা গজালেই রোগ পুরোপুরি দূর হয়েছে এমন দাবি করা যাবে না।'
                        : 'These are general inspection topics. New leaf growth alone does not guarantee a disease is eliminated.',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.forestGreen,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InspectionItem {
  final IconData icon;
  final String titleEn;
  final String titleBn;
  final String descEn;
  final String descBn;

  const _InspectionItem({
    required this.icon,
    required this.titleEn,
    required this.titleBn,
    required this.descEn,
    required this.descBn,
  });
}

