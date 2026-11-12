import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/prediction_history_model.dart';
import '../../../../providers/history_provider.dart';
import '../../../../providers/settings_provider.dart';
import 'detection_history_card.dart';

class RecentDetectionsSection extends ConsumerWidget {
  const RecentDetectionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isBn = settings.language == 'bn';
    final historyAsync = ref.watch(historyProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBn ? 'সাম্প্রতিক স্ক্যান' : 'Recent Detections',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isBn
                      ? 'আপনার সাম্প্রতিক ফসলের রোগ নির্ণয় বিবরণ'
                      : 'Your latest plant health diagnostic logs',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => context.push('/history'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.forestGreen,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isBn ? 'সবগুলো দেখুন' : 'View All',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Scans Content
        historyAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return _buildEmptyState(context, isBn);
            }

            // Sort newest first
            final sortedItems = List<PredictionHistoryModel>.from(items)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            final recentFour = sortedItems.take(4).toList();

            return Column(
              children: recentFour.map((scan) {
                return DetectionHistoryCard(
                  scan: scan,
                  isBn: isBn,
                  onTap: () => context.push('/history/${scan.id}'),
                );
              }).toList(),
            );
          },
          loading: () => Column(
            children: List.generate(3, (index) => _buildSkeletonItem()),
          ),
          error: (error, _) => _buildErrorState(ref, isBn),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isBn) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGreen),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.softNaturalGreen,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderGreen),
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              size: 32,
              color: AppColors.forestGreen,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isBn ? 'এখনো কোনো স্ক্যান করা হয়নি' : 'No diagnosis logs yet',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isBn
                ? 'আক্রান্ত পাতার ছবি তুলে স্ক্যান করলে ফলাফল এখানে সংরক্ষিত থাকবে।'
                : 'Scanned leaves and AI recommendations will appear here.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.secondaryText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => context.push('/detect'),
            icon: const Icon(Icons.add_a_photo_outlined, size: 16),
            label: Text(
              isBn ? 'প্রথম স্ক্যান করুন' : 'Scan First Plant',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.forestGreen,
              side: const BorderSide(color: AppColors.forestGreen, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref, bool isBn) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isBn
                  ? 'ইতিহাস লোড করা যায়নি।'
                  : 'Failed to load recent scan records.',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF991B1B),
              ),
            ),
          ),
          TextButton(
            onPressed: () => ref.read(historyProvider.notifier).refresh(),
            child: Text(
              isBn ? 'পুনরায় চেষ্টা' : 'Retry',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.forestGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGreen),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.softNaturalGreen,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.borderGreen,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 140,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.softNaturalGreen,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 80,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.borderGreen,
                    borderRadius: BorderRadius.circular(4),
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

