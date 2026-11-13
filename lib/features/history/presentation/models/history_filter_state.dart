import 'package:flutter/material.dart';

enum HistoryDateFilter {
  allTime,
  today,
  last7Days,
  last30Days,
  thisMonth,
  custom;

  String labelEn() {
    switch (this) {
      case HistoryDateFilter.allTime:
        return 'All Time';
      case HistoryDateFilter.today:
        return 'Today';
      case HistoryDateFilter.last7Days:
        return 'Last 7 Days';
      case HistoryDateFilter.last30Days:
        return 'Last 30 Days';
      case HistoryDateFilter.thisMonth:
        return 'This Month';
      case HistoryDateFilter.custom:
        return 'Custom Range';
    }
  }

  String labelBn() {
    switch (this) {
      case HistoryDateFilter.allTime:
        return 'সকল সময়';
      case HistoryDateFilter.today:
        return 'আজ';
      case HistoryDateFilter.last7Days:
        return 'গত ৭ দিন';
      case HistoryDateFilter.last30Days:
        return 'গত ৩০ দিন';
      case HistoryDateFilter.thisMonth:
        return 'চলতি মাস';
      case HistoryDateFilter.custom:
        return 'নির্দিষ্ট সময়সীমা';
    }
  }
}

class HistoryFilterState {
  final String searchQuery;
  final HistoryDateFilter dateFilter;
  final DateTimeRange? customDateRange;
  final String selectedCrop; // 'All' or specific crop name

  const HistoryFilterState({
    this.searchQuery = '',
    this.dateFilter = HistoryDateFilter.allTime,
    this.customDateRange,
    this.selectedCrop = 'All',
  });

  bool get hasActiveFilter =>
      searchQuery.isNotEmpty ||
      dateFilter != HistoryDateFilter.allTime ||
      selectedCrop != 'All';

  HistoryFilterState copyWith({
    String? searchQuery,
    HistoryDateFilter? dateFilter,
    DateTimeRange? customDateRange,
    String? selectedCrop,
    bool clearCustomRange = false,
  }) {
    return HistoryFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      dateFilter: dateFilter ?? this.dateFilter,
      customDateRange: clearCustomRange
          ? null
          : (customDateRange ?? this.customDateRange),
      selectedCrop: selectedCrop ?? this.selectedCrop,
    );
  }

  HistoryFilterState reset() {
    return const HistoryFilterState();
  }
}
