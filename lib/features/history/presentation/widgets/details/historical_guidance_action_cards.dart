import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';

/// Screen 23 – Treatment, Prevention, and Recovery Action Cards
/// Provides direct links to Screen 18 (Treatment), Screen 19 (Prevention),
/// and Screen 21 (Recovery & Follow-up) preserving disease and crop context.
class HistoricalGuidanceActionCards extends StatelessWidget {
  final String scanId;
  final int? diseaseId;
  final int? cropId;
  final bool isHealthy;
  final bool isBn;

  const HistoricalGuidanceActionCards({
    super.key,
    required this.scanId,
    this.diseaseId,
    this.cropId,
    required this.isHealthy,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final validDiseaseId = diseaseId ?? 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Treatment Recommendations (Only for disease detection)
          if (!isHealthy) ...[
            _ActionTile(
              icon: Icons.healing_rounded,
              iconColor: const Color(0xFF2563EB),
              bgColor: const Color(0xFFEFF6FF),
              title: isBn
                  ? 'চিকিৎসা ও প্রতিকার নির্দেশিকা'
                  : 'Treatment Recommendations',
              subtitle: isBn
                  ? 'এই রোগের জন্য অনুমোদিত সমাধান ও পদক্ষেপ দেখুন'
                  : 'View available agricultural guidance for this disease',
              onTap: () {
                try {
                  context.push('/recommendations/$validDiseaseId');
                } catch (_) {}
              },
            ),
            const SizedBox(height: 8),
          ],

          // 2. Prevention & Plant Care
          _ActionTile(
            icon: Icons.shield_outlined,
            iconColor: AppColors.forestGreen,
            bgColor: AppColors.freshGreen.withValues(alpha: 0.1),
            title: isBn
                ? 'প্রতিরোধ ও দীর্ঘমেয়াদী যত্ন'
                : 'Prevention & Plant Care',
            subtitle: isBn
                ? 'ভবিষ্যতে রোগ আক্রমণ কমাতে প্রতিরোধমূলক ব্যবস্থা জানুন'
                : 'Learn proven practices to reduce future crop disease risk',
            onTap: () {
              try {
                if (cropId != null) {
                  context.push(
                      '/prevention/$validDiseaseId?cropId=$cropId');
                } else {
                  context.push('/prevention/$validDiseaseId');
                }
              } catch (_) {}
            },
          ),
          const SizedBox(height: 8),

          // 3. Plant Recovery & Follow-up Journal
          _ActionTile(
            icon: Icons.track_changes_rounded,
            iconColor: AppColors.forestGreen,
            bgColor: AppColors.forestGreen.withValues(alpha: 0.08),
            title: isBn
                ? 'গাছের পুনরুদ্ধার ও ফলো-আপ'
                : 'Plant Recovery & Follow-up',
            subtitle: isBn
                ? 'পূর্ববর্তী পরিবর্তনের সাথে মিলিয়ে নতুন পর্যবেক্ষণ রেকর্ড করুন'
                : 'Keep track of plant condition and record follow-up notes',
            onTap: () {
              try {
                context.push('/recovery/$scanId');
              } catch (_) {}
            },
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderGreen,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.secondaryText,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                  color: AppColors.secondaryText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
