import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Screen 22 – Detection History Header
/// Displays screen title, subtitle, history emblem, and pull/tap refresh action.
class HistoryHeader extends StatelessWidget {
  final bool isBn;
  final bool isRefreshing;
  final VoidCallback onRefresh;

  const HistoryHeader({
    super.key,
    required this.isBn,
    required this.isRefreshing,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderGreen,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon badge
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.forestGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.manage_search_rounded,
              size: 24,
              color: AppColors.forestGreen,
            ),
          ),
          const SizedBox(width: 12),

          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isBn ? 'শনাক্তকরণ ইতিহাস' : 'Detection History',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.forestGreen,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isBn
                      ? 'পূর্ববর্তী ফসলের রোগ ও স্বাস্থ্য পরীক্ষার রেকর্ডসমূহ দেখুন।'
                      : 'View and manage your previous plant health scans.',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.secondaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Refresh Button
          IconButton(
            onPressed: isRefreshing ? null : onRefresh,
            icon: isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.forestGreen,
                    ),
                  )
                : const Icon(
                    Icons.refresh_rounded,
                    color: AppColors.forestGreen,
                  ),
            tooltip: isBn ? 'রিফ্রেশ করুন' : 'Refresh',
          ),
        ],
      ),
    );
  }
}

