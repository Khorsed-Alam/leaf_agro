import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';

/// Content and guidance displayed exclusively when a plant is diagnosed as healthy
class HealthyActionsSection extends StatelessWidget {
  final bool isBn;

  const HealthyActionsSection({
    super.key,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.freshGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.freshGreen.withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    color: AppColors.forestGreen,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBn
                            ? 'আপনার গাছ সুস্থ দেখাচ্ছে!'
                            : 'Your plant looks healthy!',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.forestGreen,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isBn
                            ? 'এই ছবিতে কোনো সমর্থিত রোগ পাওয়া যায়নি। নিয়মিত পর্যবেক্ষণ এবং সুষম সার ও পানির ব্যবহার বজায় রাখুন।'
                            : 'No supported disease was detected in this image. Keep monitoring your plant and continue following good farming practices.',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.primaryText,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // General Good Crop Care & Prevention Guide
          SizedBox(
            height: 46,
            child: OutlinedButton.icon(
              onPressed: () {
                try {
                  context.push('/prevention/1');
                } catch (_) {}
              },
              icon: const Icon(Icons.spa_outlined, size: 18),
              label: Text(
                isBn
                    ? 'সাধারণ ফসল যত্ন ও প্রতিরোধ'
                    : 'Crop Care & Prevention Guide',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.forestGreen,
                side: const BorderSide(
                  color: AppColors.borderGreen,
                  width: 1.3,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
