import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../models/history_filter_state.dart';

/// Screen 22 – Filter Row & Active Filter Chips
/// Displays compact Date and Crop filter triggers, dismissible active chips,
/// Clear All button, and dynamic matching result counter.
class HistoryFilterRow extends StatelessWidget {
  final HistoryFilterState filterState;
  final int matchingCount;
  final bool isBn;
  final VoidCallback onOpenDateFilter;
  final VoidCallback onOpenCropFilter;
  final VoidCallback onClearDateFilter;
  final VoidCallback onClearCropFilter;
  final VoidCallback onClearAll;

  const HistoryFilterRow({
    super.key,
    required this.filterState,
    required this.matchingCount,
    required this.isBn,
    required this.onOpenDateFilter,
    required this.onOpenCropFilter,
    required this.onClearDateFilter,
    required this.onClearCropFilter,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final isDateActive = filterState.dateFilter != HistoryDateFilter.allTime;
    final isCropActive = filterState.selectedCrop != 'All';
    final hasActiveFilter = filterState.hasActiveFilter;

    // Date Label
    String dateLabel = isBn
        ? filterState.dateFilter.labelBn()
        : filterState.dateFilter.labelEn();
    if (filterState.dateFilter == HistoryDateFilter.custom &&
        filterState.customDateRange != null) {
      dateLabel =
          '${DateFormatter.formatShortDate(filterState.customDateRange!.start)} - ${DateFormatter.formatShortDate(filterState.customDateRange!.end)}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Trigger Buttons Row
          Row(
            children: [
              // Date Filter Trigger Button
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: OutlinedButton.icon(
                    onPressed: onOpenDateFilter,
                    icon: Icon(
                      Icons.calendar_month_outlined,
                      size: 16,
                      color: isDateActive
                          ? AppColors.forestGreen
                          : AppColors.secondaryText,
                    ),
                    label: Text(
                      isDateActive
                          ? dateLabel
                          : (isBn ? 'তারিখ ফিল্টার' : 'Filter Date'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isDateActive
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: isDateActive
                            ? AppColors.forestGreen
                            : AppColors.primaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isDateActive
                          ? AppColors.freshGreen.withValues(alpha: 0.1)
                          : AppColors.surfaceContainerLowest,
                      side: BorderSide(
                        color: isDateActive
                            ? AppColors.forestGreen
                            : AppColors.borderGreen,
                        width: isDateActive ? 1.4 : 1.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Crop Filter Trigger Button
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: OutlinedButton.icon(
                    onPressed: onOpenCropFilter,
                    icon: Icon(
                      Icons.eco_outlined,
                      size: 16,
                      color: isCropActive
                          ? AppColors.forestGreen
                          : AppColors.secondaryText,
                    ),
                    label: Text(
                      isCropActive
                          ? filterState.selectedCrop
                          : (isBn ? 'ফসল ফিল্টার' : 'Filter Crop'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isCropActive
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: isCropActive
                            ? AppColors.forestGreen
                            : AppColors.primaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isCropActive
                          ? AppColors.freshGreen.withValues(alpha: 0.1)
                          : AppColors.surfaceContainerLowest,
                      side: BorderSide(
                        color: isCropActive
                            ? AppColors.forestGreen
                            : AppColors.borderGreen,
                        width: isCropActive ? 1.4 : 1.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Active Filters & Match Counter Row
          if (hasActiveFilter) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (isDateActive)
                          Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: InputChip(
                              avatar: const Icon(
                                Icons.calendar_today_rounded,
                                size: 14,
                                color: AppColors.forestGreen,
                              ),
                              label: Text(
                                dateLabel,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.forestGreen,
                                ),
                              ),
                              onDeleted: onClearDateFilter,
                              deleteIconColor: AppColors.forestGreen,
                              backgroundColor: AppColors.freshGreen
                                  .withValues(alpha: 0.12),
                              side: const BorderSide(
                                color: AppColors.borderGreen,
                              ),
                              padding: const EdgeInsets.all(2),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        if (isCropActive)
                          Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: InputChip(
                              avatar: const Icon(
                                Icons.eco_rounded,
                                size: 14,
                                color: AppColors.forestGreen,
                              ),
                              label: Text(
                                filterState.selectedCrop,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.forestGreen,
                                ),
                              ),
                              onDeleted: onClearCropFilter,
                              deleteIconColor: AppColors.forestGreen,
                              backgroundColor: AppColors.freshGreen
                                  .withValues(alpha: 0.12),
                              side: const BorderSide(
                                color: AppColors.borderGreen,
                              ),
                              padding: const EdgeInsets.all(2),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onClearAll,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                  ),
                  child: Text(
                    isBn ? 'সব মুছুন' : 'Clear All',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 6),

          // Result Count Summary
          Text(
            isBn
                ? '$matchingCountটি স্ক্যান পাওয়া গেছে'
                : 'Showing $matchingCount scan${matchingCount == 1 ? '' : 's'}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

