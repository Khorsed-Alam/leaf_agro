import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

/// Screen 24 – Detection Activity Card
/// Displays the genuine count of saved plant disease detections belonging to the user.
/// Tapping navigates to Screen 22 (Detection History).
class DetectionActivityCard extends StatelessWidget {
  final AsyncValue<int> detectionCountAsync;
  final bool isBn;

  const DetectionActivityCard({
    super.key,
    required this.detectionCountAsync,
    required this.isBn,
  });

  String _formatNumber(int number, bool isBn) {
    if (!isBn) return '$number';
    const enToBn = {
      '0': '০',
      '1': '১',
      '2': '২',
      '3': '৩',
      '4': '৪',
      '5': '৫',
      '6': '৬',
      '7': '৭',
      '8': '৮',
      '9': '৯',
    };
    return number.toString().split('').map((ch) => enToBn[ch] ?? ch).join('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGreen, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            try {
              context.push('/history');
            } catch (_) {}
          },
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.eco_rounded,
                          size: 18,
                          color: AppColors.forestGreen,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isBn ? 'আপনার ফসলের স্বাস্থ্য কার্যক্রম' : 'Your Plant Health Activity',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryText,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.secondaryText,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Count Presentation Row
                Row(
                  children: [
                    // Icon Badge
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.borderGreen,
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.document_scanner_rounded,
                        color: AppColors.forestGreen,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Metrics
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          detectionCountAsync.when(
                            data: (count) => Text(
                              _formatNumber(count, isBn),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: AppColors.forestGreen,
                                height: 1.0,
                                letterSpacing: -0.5,
                              ),
                            ),
                            loading: () => const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.forestGreen,
                              ),
                            ),
                            error: (_, __) => Text(
                              _formatNumber(0, isBn),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: AppColors.forestGreen,
                                height: 1.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isBn ? 'মোট স্ক্যান ও শনাক্তকরণ' : 'Total Detections',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryText,
                            ),
                          ),
                          Text(
                            isBn
                                ? 'আপনার সংরক্ষিত উদ্ভিদের রোগ নির্ণয় রেকর্ড'
                                : 'Your saved plant health scans',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
