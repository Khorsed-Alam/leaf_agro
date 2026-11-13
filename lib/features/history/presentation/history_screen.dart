import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/crop_model.dart';
import '../../../data/models/prediction_history_model.dart';
import '../../../providers/crop_provider.dart';
import '../../../providers/history_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../home/presentation/widgets/dashboard_bottom_navigation.dart';
import 'models/history_filter_state.dart';
import 'widgets/crop_filter_sheet.dart';
import 'widgets/date_filter_sheet.dart';
import 'widgets/detection_history_card.dart';
import 'widgets/detection_statistics_grid.dart';
import 'widgets/empty_history_view.dart';
import 'widgets/history_filter_row.dart';
import 'widgets/history_header.dart';
import 'widgets/history_loading_skeleton.dart';
import 'widgets/history_search_bar.dart';
import 'widgets/no_matching_results_view.dart';

/// Screen 22 – Detection History Dashboard for AgriCare AI (LeafAgro)
/// Allows farmers to browse past diagnoses, search by crop/disease, filter by date & crop,
/// view accurate authentic scan statistics, and reopen historical AI detection results.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  HistoryFilterState _filterState = const HistoryFilterState();
  bool _isRefreshing = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });
    try {
      await ref.read(historyProvider.notifier).refresh();
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filterState = _filterState.copyWith(searchQuery: query.trim());
    });
  }

  void _onClearSearch() {
    _searchController.clear();
    setState(() {
      _filterState = _filterState.copyWith(searchQuery: '');
    });
  }

  void _onDateFilterSelected(HistoryDateFilter filter, DateTimeRange? range) {
    setState(() {
      _filterState = _filterState.copyWith(
        dateFilter: filter,
        customDateRange: range,
        clearCustomRange: filter != HistoryDateFilter.custom,
      );
    });
  }

  void _onCropFilterSelected(String crop) {
    setState(() {
      _filterState = _filterState.copyWith(selectedCrop: crop);
    });
  }

  void _onClearAllFilters() {
    _searchController.clear();
    setState(() {
      _filterState = _filterState.reset();
    });
  }

  bool _matchesDateFilter(DateTime date, HistoryDateFilter filter,
      DateTimeRange? customRange) {
    final now = DateTime.now();
    switch (filter) {
      case HistoryDateFilter.allTime:
        return true;
      case HistoryDateFilter.today:
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      case HistoryDateFilter.last7Days:
        return date.isAfter(now.subtract(const Duration(days: 7)));
      case HistoryDateFilter.last30Days:
        return date.isAfter(now.subtract(const Duration(days: 30)));
      case HistoryDateFilter.thisMonth:
        return date.year == now.year && date.month == now.month;
      case HistoryDateFilter.custom:
        if (customRange == null) return true;
        final start = DateTime(
          customRange.start.year,
          customRange.start.month,
          customRange.start.day,
        );
        final end = DateTime(
          customRange.end.year,
          customRange.end.month,
          customRange.end.day,
          23,
          59,
          59,
        );
        return date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            date.isBefore(end.add(const Duration(seconds: 1)));
    }
  }

  List<PredictionHistoryModel> _applyFilters(
      List<PredictionHistoryModel> allScans) {
    return allScans.where((scan) {
      final parts = scan.predictedClass.split('___');
      final crop = parts[0];
      final disease =
          parts.length > 1 ? parts[1].replaceAll('_', ' ') : 'Healthy';
      final isHealthy = disease.toLowerCase().contains('healthy') ||
          scan.predictedClass.toLowerCase().contains('healthy');

      // 1. Crop Filter
      if (_filterState.selectedCrop != 'All') {
        if (crop.toLowerCase() != _filterState.selectedCrop.toLowerCase()) {
          return false;
        }
      }

      // 2. Date Filter
      if (!_matchesDateFilter(
        scan.createdAt,
        _filterState.dateFilter,
        _filterState.customDateRange,
      )) {
        return false;
      }

      // 3. Search Query Filter
      if (_filterState.searchQuery.isNotEmpty) {
        final q = _filterState.searchQuery.toLowerCase();
        final matchesCrop = crop.toLowerCase().contains(q);
        final matchesDisease = disease.toLowerCase().contains(q);
        final matchesClass = scan.predictedClass.toLowerCase().contains(q);
        final matchesStatus = isHealthy
            ? ('healthy'.contains(q) || 'সুস্থ'.contains(q))
            : ('diseased'.contains(q) || 'রোগ'.contains(q));

        if (!matchesCrop &&
            !matchesDisease &&
            !matchesClass &&
            !matchesStatus) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _handleCardTap(PredictionHistoryModel scan) {
    context.push('/history/${scan.id}');
  }

  @override
  Widget build(BuildContext context) {
    final isBn = ref.watch(settingsProvider).language == 'bn';
    final historyAsync = ref.watch(historyProvider);
    final cropsAsync = ref.watch(cropProvider);
    final availableCrops = cropsAsync.valueOrNull ?? <CropModel>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(74),
        child: SafeArea(
          bottom: false,
          child: HistoryHeader(
            isBn: isBn,
            isRefreshing: _isRefreshing,
            onRefresh: _handleRefresh,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppColors.forestGreen,
          child: historyAsync.when(
            data: (allScans) {
              if (allScans.isEmpty) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: EmptyHistoryView(
                    isBn: isBn,
                    onScanFirstPlant: () => context.push('/detect'),
                  ),
                );
              }

              // Apply filtering
              final filteredScans = _applyFilters(allScans);

              // Calculate authentic statistics
              final statsScans =
                  _filterState.hasActiveFilter ? filteredScans : allScans;
              final totalCount = statsScans.length;
              final healthyCount = statsScans.where((s) {
                final parts = s.predictedClass.split('___');
                final disease = parts.length > 1
                    ? parts[1].replaceAll('_', ' ')
                    : 'Healthy';
                return disease.toLowerCase().contains('healthy') ||
                    s.predictedClass.toLowerCase().contains('healthy');
              }).length;
              final diseasedCount = totalCount - healthyCount;

              final sevenDaysAgo =
                  DateTime.now().subtract(const Duration(days: 7));
              final recentCount = statsScans
                  .where((s) => s.createdAt.isAfter(sevenDaysAgo))
                  .length;

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // 1. Search Bar
                  SliverToBoxAdapter(
                    child: HistorySearchBar(
                      controller: _searchController,
                      isBn: isBn,
                      onChanged: _onSearchChanged,
                      onClear: _onClearSearch,
                    ),
                  ),

                  // 2. Filter Row & Active Chips
                  SliverToBoxAdapter(
                    child: HistoryFilterRow(
                      filterState: _filterState,
                      matchingCount: filteredScans.length,
                      isBn: isBn,
                      onOpenDateFilter: () => DateFilterSheet.show(
                        context: context,
                        currentFilter: _filterState.dateFilter,
                        currentCustomRange: _filterState.customDateRange,
                        isBn: isBn,
                        onFilterSelected: _onDateFilterSelected,
                      ),
                      onOpenCropFilter: () => CropFilterSheet.show(
                        context: context,
                        selectedCrop: _filterState.selectedCrop,
                        availableCrops: availableCrops,
                        isBn: isBn,
                        onCropSelected: _onCropFilterSelected,
                      ),
                      onClearDateFilter: () => _onDateFilterSelected(
                          HistoryDateFilter.allTime, null),
                      onClearCropFilter: () => _onCropFilterSelected('All'),
                      onClearAll: _onClearAllFilters,
                    ),
                  ),

                  // 3. Detection Statistics Grid (4 compact cards)
                  SliverToBoxAdapter(
                    child: DetectionStatisticsGrid(
                      totalCount: totalCount,
                      diseasedCount: diseasedCount,
                      healthyCount: healthyCount,
                      recentCount: recentCount,
                      isFiltered: _filterState.hasActiveFilter,
                      isBn: isBn,
                    ),
                  ),

                  // 4. History List or No Matching Results
                  if (filteredScans.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: NoMatchingResultsView(
                        isBn: isBn,
                        onClearFilters: _onClearAllFilters,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.only(top: 4, bottom: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final scan = filteredScans[index];
                            return DetectionHistoryCard(
                              scan: scan,
                              isBn: isBn,
                              onTap: () => _handleCardTap(scan),
                            );
                          },
                          childCount: filteredScans.length,
                        ),
                      ),
                    ),
                ],
              );
            },
            loading: () => const SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: HistoryLoadingSkeleton(),
            ),
            error: (err, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 44,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isBn
                          ? 'ইতিহাস লোড করা যায়নি'
                          : 'Failed to load detection history',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      err.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _handleRefresh,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: Text(isBn ? 'পুনরায় চেষ্টা করুন' : 'Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.forestGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const DashboardBottomNavigation(selectedIndex: 2),
    );
  }
}
