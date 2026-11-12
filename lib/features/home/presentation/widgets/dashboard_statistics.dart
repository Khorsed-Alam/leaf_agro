import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/history_provider.dart';
import '../../../../providers/settings_provider.dart';

class DashboardStatistics extends ConsumerWidget {
  const DashboardStatistics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isBn = settings.language == 'bn';
    final historyAsync = ref.watch(historyProvider);

    return historyAsync.maybeWhen(
      data: (items) {
        // If user has no scan history yet, hide section to avoid showing misleading/empty stats
        if (items.isEmpty) {
          return const SizedBox.shrink();
        }

        final totalScans = items.length;
        int healthyCount = 0;
        int diseaseCount = 0;

        for (final item in items) {
          final isHealthy = item.predictedClass.toLowerCase().contains('healthy');
          if (isHealthy) {
            healthyCount++;
          } else {
            diseaseCount++;
          }
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderGreen),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // 1. Total Scans
              Expanded(
                child: _buildStatItem(
                  icon: Icons.analytics_outlined,
                  iconColor: AppColors.forestGreen,
                  bgColor: AppColors.softNaturalGreen,
                  count: '$totalScans',
                  label: isBn ? 'মোট স্ক্যান' : 'Total Scans',
                ),
              ),

              Container(
                width: 1,
                height: 38,
                color: AppColors.borderGreen,
              ),

              // 2. Healthy
              Expanded(
                child: _buildStatItem(
                  icon: Icons.check_circle_outline_rounded,
                  iconColor: AppColors.freshGreen,
                  bgColor: const Color(0xFFDCFCE7),
                  count: '$healthyCount',
                  label: isBn ? 'সুস্থ ফসল' : 'Healthy',
                ),
              ),

              Container(
                width: 1,
                height: 38,
                color: AppColors.borderGreen,
              ),

              // 3. Diseases
              Expanded(
                child: _buildStatItem(
                  icon: Icons.coronavirus_outlined,
                  iconColor: const Color(0xFFDC2626),
                  bgColor: const Color(0xFFFEE2E2),
                  count: '$diseaseCount',
                  label: isBn ? 'রোগাক্রান্ত' : 'Diseased',
                ),
              ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String count,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 14, color: iconColor),
            ),
            const SizedBox(width: 6),
            Text(
              count,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }
}
