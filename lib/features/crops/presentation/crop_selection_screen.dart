import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/crop_model.dart';
import '../../../providers/crop_provider.dart';
import '../../../providers/settings_provider.dart';
import 'widgets/continue_button.dart';
import 'widgets/crop_search_field.dart';
import 'widgets/crop_selection_card.dart';
import 'widgets/crop_selection_header.dart';
import 'widgets/empty_crop_search_state.dart';

/// Screen 07 – Crop Selection Screen
/// Allows Bangladeshi farmers to select from verified AI-supported crops
/// (Rice, Potato, Tomato, Mango, Jute) with dynamic search, instant bilingual
/// support, single-crop selection state, and seamless routing to Screen 08 (Detection).
class CropSelectionScreen extends ConsumerStatefulWidget {
  const CropSelectionScreen({super.key});

  @override
  ConsumerState<CropSelectionScreen> createState() => _CropSelectionScreenState();
}

class _CropSelectionScreenState extends ConsumerState<CropSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  CropModel? _localSelectedCrop;

  @override
  void initState() {
    super.initState();
    // Initialize selection from existing state if previously set
    _localSelectedCrop = ref.read(selectedCropProvider);
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

  void _selectCrop(CropModel crop) {
    setState(() {
      _localSelectedCrop = crop;
    });
  }

  void _handleContinue() {
    final crop = _localSelectedCrop;
    if (crop == null) return;

    if (!crop.isAiSupported) {
      final isBn = ref.read(settingsProvider).language == 'bn';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isBn
                ? 'নির্বাচিত ফসলটি AI মডেল দ্বারা সমর্থিত নয়।'
                : 'The selected crop is not supported by the AI detection model.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Update global state and navigate to Screen 08 (Plant Disease Detection)
    ref.read(selectedCropProvider.notifier).state = crop;
    context.push('/detect');
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isBn = settings.language == 'bn';
    final cropsAsync = ref.watch(aiSupportedCropsProvider);

    return Scaffold(
      backgroundColor: AppColors.softNaturalGreen,
      body: SafeArea(
        child: Column(
          children: [
            // Top Section: Header & Search Field
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CropSelectionHeader(
                    isBn: isBn,
                    onBack: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  CropSearchField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    onClear: _clearSearch,
                    isBn: isBn,
                  ),
                ],
              ),
            ),

            // Middle Section: Responsive Crop Grid or Empty State
            Expanded(
              child: RefreshIndicator(
                color: AppColors.forestGreen,
                backgroundColor: Colors.white,
                onRefresh: () async {
                  ref.invalidate(cropProvider);
                  await ref.read(aiSupportedCropsProvider.future);
                },
                child: cropsAsync.when(
                  data: (crops) {
                    // Filter matching crops based on search query (English and Bangla)
                    final filteredCrops = crops.where((crop) {
                      if (_searchQuery.isEmpty) return true;
                      final matchesEn = crop.nameEn.toLowerCase().contains(_searchQuery);
                      final matchesBn = crop.nameBn.toLowerCase().contains(_searchQuery);
                      return matchesEn || matchesBn;
                    }).toList();

                    if (filteredCrops.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 40),
                          EmptyCropSearchState(
                            query: _searchController.text.trim(),
                            isBn: isBn,
                            onClear: _clearSearch,
                          ),
                        ],
                      );
                    }

                    return GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      itemCount: filteredCrops.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.86,
                      ),
                      itemBuilder: (context, index) {
                        final crop = filteredCrops[index];
                        final isSelected = _localSelectedCrop?.id == crop.id;

                        return CropSelectionCard(
                          crop: crop,
                          isSelected: isSelected,
                          isBn: isBn,
                          onTap: () => _selectCrop(crop),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.forestGreen),
                  ),
                  error: (_, __) => Center(
                    child: Text(
                      isBn ? 'ফসল তালিকা লোড করা যায়নি' : 'Failed to load crops',
                      style: const TextStyle(color: AppColors.secondaryText),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Section: Fixed Continue Button
            ContinueButton(
              selectedCrop: _localSelectedCrop,
              isBn: isBn,
              onContinue: _localSelectedCrop != null ? _handleContinue : null,
            ),
          ],
        ),
      ),
    );
  }
}

