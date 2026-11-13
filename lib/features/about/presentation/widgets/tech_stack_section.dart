import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TechItem {
  final String name;
  final String roleEn;
  final String roleBn;
  final IconData icon;

  const TechItem({
    required this.name,
    required this.roleEn,
    required this.roleBn,
    required this.icon,
  });

  String role(bool isBn) => isBn ? roleBn : roleEn;
}

/// Screen 30 – Verified Technology Stack Section
class TechStackSection extends StatelessWidget {
  final bool isBn;

  const TechStackSection({
    super.key,
    required this.isBn,
  });

  static const List<TechItem> techStack = [
    TechItem(
      name: 'Flutter 3.x',
      roleEn: 'Cross-platform mobile application framework',
      roleBn: 'ক্রস-প্ল্যাটফর্ম মোবাইল অ্যাপ ফ্রেমওয়ার্ক',
      icon: Icons.phone_android_rounded,
    ),
    TechItem(
      name: 'Dart',
      roleEn: 'Type-safe programming language for core development',
      roleBn: 'অ্যাপ লজিক ও ইন্টারফেস ডেভেলপমেন্ট ভাষা',
      icon: Icons.code_rounded,
    ),
    TechItem(
      name: 'TensorFlow Lite',
      roleEn: 'On-device edge neural network inference runtime',
      roleBn: 'অন-ডিভাইস অফলাইন এআই ইনফারেন্স ইঞ্জিন',
      icon: Icons.memory_rounded,
    ),
    TechItem(
      name: 'MobileNetV2',
      roleEn: 'Lightweight convolutional neural network for disease diagnosis',
      roleBn: 'দ্রুত ও নির্ভুল উদ্ভিদ রোগ নির্ণয়কারী নিউরাল নেটওয়ার্ক',
      icon: Icons.hub_rounded,
    ),
    TechItem(
      name: 'Supabase',
      roleEn: 'Cloud authentication, real-time sync & storage services',
      roleBn: 'ইউজার অথেনটিকেশন, ক্লাউড সিঙ্ক ও স্টোরেজ ব্যাকএন্ড',
      icon: Icons.cloud_done_rounded,
    ),
    TechItem(
      name: 'PostgreSQL',
      roleEn: 'Secure relational database with Row Level Security (RLS)',
      roleBn: 'রো লেভেল সিকিউরিটি (RLS) সহ রিলেশনাল ডাটাবেস',
      icon: Icons.storage_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderGreen, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.softNaturalGreen,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderGreen, width: 1),
                ),
                child: const Icon(
                  Icons.layers_rounded,
                  color: AppColors.forestGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBn ? 'প্রযুক্তি কাঠামো' : 'Technology Stack',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.forestGreen,
                      ),
                    ),
                    Text(
                      isBn
                          ? 'এগ্রিকেয়ার এআই তৈরিতে ব্যবহৃত মূল প্রযুক্তিসমূহ'
                          : 'Technologies used to build AgriCare AI.',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Tech list
          ...techStack.map((tech) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.softNaturalGreen,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderGreen, width: 0.8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      tech.icon,
                      color: AppColors.forestGreen,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tech.name,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.forestGreen,
                          ),
                        ),
                        Text(
                          tech.role(isBn),
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
