import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/crop_provider.dart';
import '../../../providers/search_provider.dart';
import '../../../providers/settings_provider.dart';
import 'widgets/global_search_bar.dart';
import 'widgets/popular_crops_section.dart';
import 'widgets/recent_searches_section.dart';
import 'widgets/search_empty_state.dart';
import 'widgets/search_error_state.dart';
import 'widgets/search_loading_state.dart';
import 'widgets/search_results_section.dart';
import 'widgets/search_screen_header.dart';
import 'widgets/search_suggestions_section.dart';

/// Screen 10 – Global Search Screen | AgriCare AI (LeafAgro)
/// Allows Bangladeshi farmers to quickly find crops and plant diseases from
/// the application's database with debounced multi-field searching, real-time
/// suggestions, popular crops gallery, and local recent-search history.
class GlobalSearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;

  const GlobalSearchScreen({
    super.key,
    this.initialQuery,
  });

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  late final TextEditingController _searchController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');

    if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(globalSearchProvider.notifier).executeSearch(widget.initialQuery!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    ref.read(globalSearchProvider.notifier).onQueryChanged(query);
  }

  void _executeSearch(String term) {
    _searchController.text = term;
    _searchController.selection = TextSelection.collapsed(offset: term.length);
    _focusNode.unfocus();
    ref.read(globalSearchProvider.notifier).executeSearch(term);
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(globalSearchProvider.notifier).clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final isBn = ref.watch(settingsProvider).language == 'bn';
    final searchState = ref.watch(globalSearchProvider);
    final suggestions = ref.watch(searchSuggestionsProvider);
    final recentSearches = ref.watch(recentSearchesProvider);
    final cropsAsync = ref.watch(cropProvider);
    final allCrops = cropsAsync.value ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Compact Header
            SearchScreenHeader(isBn: isBn),

            // 2. Large Search Input Field
            GlobalSearchBar(
              controller: _searchController,
              focusNode: _focusNode,
              onChanged: _onQueryChanged,
              onSubmitted: _executeSearch,
              onClear: _clearSearch,
              isLoading: searchState.isLoading,
              isBn: isBn,
            ),

            // 3. Scrollable Content Area (Responsive to keyboard)
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (searchState.isLoading)
                      SearchLoadingState(isBn: isBn)
                    else if (searchState.errorMessage != null)
                      SearchErrorState(
                        errorMessage: searchState.errorMessage!,
                        onRetry: () => _executeSearch(_searchController.text),
                        isBn: isBn,
                      )
                    else if (searchState.hasNoResults)
                      SearchEmptyState(
                        onClear: _clearSearch,
                        isBn: isBn,
                      )
                    else if (searchState.hasResults)
                      SearchResultsSection(
                        matchedCrops: searchState.matchedCrops,
                        matchedDiseases: searchState.matchedDiseases,
                        allCrops: allCrops,
                        isBn: isBn,
                      )
                    else ...[
                      // Initial / Empty Query State
                      // A. Search Suggestions
                      SearchSuggestionsSection(
                        suggestions: suggestions,
                        onSuggestionTap: _executeSearch,
                        isBn: isBn,
                      ),

                      // B. Recent Searches Section
                      if (recentSearches.isNotEmpty)
                        RecentSearchesSection(
                          recentSearches: recentSearches,
                          onSelect: _executeSearch,
                          onRemove: (term) =>
                              ref.read(recentSearchesProvider.notifier).removeSearch(term),
                          onClearAll: () =>
                              ref.read(recentSearchesProvider.notifier).clearAll(),
                          isBn: isBn,
                        ),

                      // C. Popular Crops Gallery
                      PopularCropsSection(
                        crops: allCrops,
                        onCropTap: (crop) {
                          _focusNode.unfocus();
                          context.push('/crops/${crop.id}');
                        },
                        isBn: isBn,
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
