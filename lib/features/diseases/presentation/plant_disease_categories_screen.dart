import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/crop_model.dart';
import '../../../data/models/disease_model.dart';
import '../../../providers/crop_provider.dart';
import '../../../providers/disease_provider.dart';
import '../../../providers/settings_provider.dart';
import 'widgets/crop_filter_selector.dart';
import 'widgets/disease_category_card.dart';
import 'widgets/disease_empty_state.dart';
import 'widgets/disease_error_state.dart';
import 'widgets/disease_loading_skeleton.dart';
import 'widgets/disease_screen_header.dart';
import 'widgets/disease_search_field.dart';

/// Screen 09 – Plant Disease Categories Screen
/// Allows Bangladeshi farmers to browse verified plant diseases, filter by crop,
/// search by symptom or name, and view disease details.
class PlantDiseaseCategoriesScreen extends ConsumerStatefulWidget {
  final int? initialCropId;

  const PlantDiseaseCategoriesScreen({
    super.key,
    this.initialCropId,
  });

  @override
  ConsumerState<PlantDiseaseCategoriesScreen> createState() =>
      _PlantDiseaseCategoriesScreenState();
}

class _PlantDiseaseCategoriesScreenState
    extends ConsumerState<PlantDiseaseCategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  int? _selectedCropId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedCropId = widget.initialCropId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.trim().toLowerCase();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  void _onCropSelected(int? cropId) {
    setState(() {
      _selectedCropId = cropId;
    });
  }

  List<DiseaseModel> _filterDiseases(
    List<DiseaseModel> allDiseases,
    List<CropModel> crops,
  ) {
    return allDiseases.where((disease) {
      // 1. Filter by selected crop
      if (_selectedCropId != null && disease.cropId != _selectedCropId) {
        return false;
      }

      // 2. Filter by search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery;
        final matchesEn = disease.diseaseNameEn.toLowerCase().contains(query);
        final matchesBn = disease.diseaseNameBn.toLowerCase().contains(query);
        final matchesSymptomsEn =
            disease.symptomsEn.toLowerCase().contains(query);
        final matchesSymptomsBn =
            disease.symptomsBn.toLowerCase().contains(query);

        // Match associated crop name
        final crop = crops.cast<CropModel?>().firstWhere(
              (c) => c?.id == disease.cropId,
              orElse: () => null,
            );
        final matchesCropEn =
            crop?.nameEn.toLowerCase().contains(query) ?? false;
        final matchesCropBn =
            crop?.nameBn.toLowerCase().contains(query) ?? false;

        if (!matchesEn &&
            !matchesBn &&
            !matchesSymptomsEn &&
            !matchesSymptomsBn &&
            !matchesCropEn &&
            !matchesCropBn) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isBn = ref.watch(settingsProvider).language == 'bn';
    final diseasesAsync = ref.watch(allDiseasesProvider);
    final cropsAsync = ref.watch(cropProvider);

    final crops = cropsAsync.value ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Screen Header
            DiseaseScreenHeader(
              isBn: isBn,
              showBackButton: true,
            ),

            // 2. Crop Filter Selector (Horizontal Chips)
            CropFilterSelector(
              crops: crops,
              selectedCropId: _selectedCropId,
              onCropSelected: _onCropSelected,
              isBn: isBn,
            ),

            // 3. Search Diseases Field
            DiseaseSearchField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onClear: _clearSearch,
              isBn: isBn,
            ),

            // 4. Main Scrollable Disease Content
            Expanded(
              child: diseasesAsync.when(
                data: (allDiseases) {
                  if (allDiseases.isEmpty) {
                    return DiseaseEmptyState(
                      type: DiseaseEmptyType.catalogEmpty,
                      isBn: isBn,
                    );
                  }

                  final filteredDiseases = _filterDiseases(allDiseases, crops);

                  if (filteredDiseases.isEmpty) {
                    if (_searchQuery.isNotEmpty) {
                      return DiseaseEmptyState(
                        type: DiseaseEmptyType.noSearchResults,
                        onAction: _clearSearch,
                        isBn: isBn,
                      );
                    }
                    if (_selectedCropId != null) {
                      return DiseaseEmptyState(
                        type: DiseaseEmptyType.noDiseasesForCrop,
                        onAction: () => _onCropSelected(null),
                        isBn: isBn,
                      );
                    }
                  }

                  return RefreshIndicator(
                    color: AppColors.forestGreen,
                    onRefresh: () async {
                      ref.invalidate(allDiseasesProvider);
                      await ref.read(allDiseasesProvider.future);
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: filteredDiseases.length,
                      itemBuilder: (context, index) {
                        final disease = filteredDiseases[index];
                        final crop = crops.cast<CropModel?>().firstWhere(
                              (c) => c?.id == disease.cropId,
                              orElse: () => null,
                            );

                        return DiseaseCategoryCard(
                          disease: disease,
                          crop: crop,
                          isBn: isBn,
                        );
                      },
                    ),
                  );
                },
                loading: () => const DiseaseLoadingSkeleton(),
                error: (error, _) => DiseaseErrorState(
                  errorMessage: error.toString(),
                  onRetry: () => ref.invalidate(allDiseasesProvider),
                  isBn: isBn,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
