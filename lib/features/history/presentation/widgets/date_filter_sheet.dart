import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../models/history_filter_state.dart';

/// Bottom sheet dialog to select a date filter interval for detection history
class DateFilterSheet extends StatelessWidget {
  final HistoryDateFilter currentFilter;
  final DateTimeRange? currentCustomRange;
  final bool isBn;
  final void Function(HistoryDateFilter filter, DateTimeRange? range)
      onFilterSelected;

  const DateFilterSheet({
    super.key,
    required this.currentFilter,
    this.currentCustomRange,
    required this.isBn,
    required this.onFilterSelected,
  });

  static Future<void> show({
    required BuildContext context,
    required HistoryDateFilter currentFilter,
    DateTimeRange? currentCustomRange,
    required bool isBn,
    required void Function(HistoryDateFilter filter, DateTimeRange? range)
        onFilterSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DateFilterSheet(
        currentFilter: currentFilter,
        currentCustomRange: currentCustomRange,
        isBn: isBn,
        onFilterSelected: onFilterSelected,
      ),
    );
  }

  Future<void> _handleCustomRange(BuildContext context) async {
    final now = DateTime.now();
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: currentCustomRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 14)),
            end: now,
          ),
      helpText:
          isBn ? 'নির্দিষ্ট তারিখ সীমা নির্বাচন করুন' : 'Select Custom Date Range',
      confirmText: isBn ? 'প্রয়োগ করুন' : 'Apply',
      cancelText: isBn ? 'বাতিল' : 'Cancel',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.forestGreen,
              onPrimary: Colors.white,
              onSurface: AppColors.primaryText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      // Validate that start <= end (showDateRangePicker naturally enforces, but we guard explicitly)
      if (pickedRange.start.isBefore(pickedRange.end) ||
          pickedRange.start.isAtSameMomentAs(pickedRange.end)) {
        onFilterSelected(HistoryDateFilter.custom, pickedRange);
        if (context.mounted) Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isBn ? 'তারিখ অনুযায়ী ফিল্টার' : 'Filter by Date',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.forestGreen,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Options list
            ...HistoryDateFilter.values.map((filter) {
              final isSelected = currentFilter == filter;
              String label = isBn ? filter.labelBn() : filter.labelEn();

              if (filter == HistoryDateFilter.custom &&
                  currentCustomRange != null &&
                  isSelected) {
                label +=
                    ' (${DateFormatter.formatShortDate(currentCustomRange!.start)} - ${DateFormatter.formatShortDate(currentCustomRange!.end)})';
              }

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected
                      ? AppColors.forestGreen
                      : AppColors.secondaryText,
                ),
                title: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.forestGreen
                        : AppColors.primaryText,
                  ),
                ),
                onTap: () {
                  if (filter == HistoryDateFilter.custom) {
                    _handleCustomRange(context);
                  } else {
                    onFilterSelected(filter, null);
                    Navigator.pop(context);
                  }
                },
              );
            }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
