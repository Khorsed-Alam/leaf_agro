import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Screen 22 – Detection Statistics Grid
/// Displays 4 compact statistic tiles:
/// Total Scans, Disease Detected, Healthy Results, and Recent Activity (last 7 days).
/// Dynamically calculated from genuine records.
class DetectionStatisticsGrid extends StatelessWidget {
  final int totalCount;
  final int diseasedCount;
  final int healthyCount;
  final int recentCount;
  final bool isFiltered;
  final bool isBn;

  const DetectionStatisticsGrid({
    super.key,
    required this.totalCount,
    required this.diseasedCount,
    required this.healthyCount,
    required this.recentCount,
    required this.isFiltered,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subtitle tag indicating whether statistics reflect full history or active filter
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 14,
                color: isFiltered ? AppColors.forestGreen : AppColors.secondaryText,
              ),
              const SizedBox(width: 4),
              Text(
                isFiltered
                    ? (isBn
                        ? 'ফিল্টারকৃত ফলাফল পরিসংখ্যান'
                        : 'Filtered Results Statistics')
                    : (isBn ? 'সার্বিক স্ক্যান পরিসংখ্যান' : 'Overall Scan Statistics'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isFiltered
                      ? AppColors.forestGreen
                      : AppColors.secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 2x2 Grid of Stat Cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: isBn ? 'মোট স্ক্যান' : 'Total Scans',
                  count: totalCount,
                  icon: Icons.document_scanner_rounded,
                  iconColor: AppColors.forestGreen,
                  bgColor: AppColors.forestGreen.withValues(alpha: 0.08),
                  borderColor: AppColors.borderGreen,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  title: isBn ? 'রোগ শনাক্ত' : 'Diseased',
                  count: diseasedCount,
                  icon: Icons.bug_report_rounded,
                  iconColor: AppColors.error,
                  bgColor: AppColors.errorContainer.withValues(alpha: 0.5),
                  borderColor: const Color(0xFFFCA5A5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: isBn ? 'সুস্থ উদ্ভিদ' : 'Healthy',
                  count: healthyCount,
                  icon: Icons.eco_rounded,
                  iconColor: AppColors.freshGreen,
                  bgColor: AppColors.freshGreen.withValues(alpha: 0.1),
                  borderColor: const Color(0xFF86EFAC),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  title: isBn ? 'সাম্প্রতিক (৭ দিন)' : 'Recent (7d)',
                  count: recentCount,
                  icon: Icons.update_rounded,
                  iconColor: const Color(0xFF2563EB),
                  bgColor: const Color(0xFFEFF6FF),
                  borderColor: const Color(0xFFBFDBFE),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color borderColor;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  count.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

